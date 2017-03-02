Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF126B0389
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 09:51:34 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id m67so8163827qkf.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 06:51:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s186si7083299qkh.188.2017.03.02.06.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 06:51:33 -0800 (PST)
Date: Thu, 2 Mar 2017 09:51:31 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302145131.GF3213@bfoster.bfoster>
References: <42eb5d53-5ceb-a9ce-791a-9469af30810c@I-love.SAKURA.ne.jp>
 <20170302103520.GC1404@dhcp22.suse.cz>
 <20170302122426.GA3213@bfoster.bfoster>
 <20170302124909.GE1404@dhcp22.suse.cz>
 <20170302130009.GC3213@bfoster.bfoster>
 <20170302132755.GG1404@dhcp22.suse.cz>
 <20170302134157.GD3213@bfoster.bfoster>
 <20170302135001.GI1404@dhcp22.suse.cz>
 <20170302142315.GE3213@bfoster.bfoster>
 <20170302143441.GL1404@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302143441.GL1404@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, Mar 02, 2017 at 03:34:41PM +0100, Michal Hocko wrote:
> On Thu 02-03-17 09:23:15, Brian Foster wrote:
> > On Thu, Mar 02, 2017 at 02:50:01PM +0100, Michal Hocko wrote:
> > > On Thu 02-03-17 08:41:58, Brian Foster wrote:
> > > > On Thu, Mar 02, 2017 at 02:27:55PM +0100, Michal Hocko wrote:
> > > [...]
> > > > > I see your argument about being in sync with other kmem helpers but
> > > > > those are bit different because regular page/slab allocators allow never
> > > > > fail semantic (even though this is mostly ignored by those helpers which
> > > > > implement their own retries but that is a different topic).
> > > > > 
> > > > 
> > > > ... but what I'm trying to understand here is whether this failure
> > > > scenario is specific to vmalloc() or whether the other kmem_*()
> > > > functions are susceptible to the same problem. For example, suppose we
> > > > replaced this kmem_zalloc_greedy() call with a kmem_zalloc(PAGE_SIZE,
> > > > KM_SLEEP) call. Could we hit the same problem if the process is killed?
> > > 
> > > Well, kmem_zalloc uses kmalloc which can also fail when we are out of
> > > memory but in that case we can expect the OOM killer releasing some
> > > memory which would allow us to make a forward progress on the next
> > > retry. So essentially retrying around kmalloc is much more safe in this
> > > regard. Failing vmalloc might be permanent because there is no vmalloc
> > > space to allocate from or much more likely due to already mentioned
> > > patch. So vmalloc is different, really.
> > 
> > Right.. that's why I'm asking. So it's technically possible but highly
> > unlikely due to the different failure characteristics. That seems
> > reasonable to me, then. 
> > 
> > To be clear, do we understand what causes the vzalloc() failure to be
> > effectively permanent in this specific reproducer? I know you mention
> > above that we could be out of vmalloc space, but that doesn't clarify
> > whether there are other potential failure paths or then what this has to
> > do with the fact that the process was killed. Does the pending signal
> > cause the subsequent failures or are you saying that there is some other
> > root cause of the failure, this process would effectively be spinning
> > here anyways, and we're just noticing it because it's trying to exit?
> 
> In this particular case it is fatal_signal_pending that causes the
> permanent failure. This check has been added to prevent from complete
> memory reserves depletion on OOM when a killed task has a free ticket to
> reserves and vmalloc requests can be really large. In this case there
> was no OOM killer going on but fsstress has SIGKILL pending for other
> reason. Most probably as a result of the group_exit when all threads
> are killed (see zap_process). I could have turn fatal_signal_pending
> into tsk_is_oom_victim which would be less likely to hit but in
> principle fatal_signal_pending should be better because we do want to
> bail out when the process is existing as soon as possible.
> 
> What I really wanted to say is that there are other possible permanent
> failure paths in vmalloc AFAICS. They are much less probable but they
> still exist.
> 
> Does that make more sense now?

Yes, thanks. That explains why this crops up now where it hasn't in the
past. Please include that background in the commit log description.

Also, that kind of makes me think that a fatal_signal_pending() check is
still appropriate in the loop, even if we want to drop the infinite
retry loop in kmem_zalloc_greedy() as well. There's no sense in doing
however many retries are left before we return and that's also more
explicit for the next person who goes to change this code in the future.

Otherwise, I'm fine with breaking the infinite retry loop at the same
time. It looks like Christoph added this function originally so this
should probably require his ack as well..

Brian

> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
