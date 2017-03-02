Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53E9C6B0398
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:14:15 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u63so27740248wmu.0
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:14:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u74si10986646wrc.274.2017.03.02.07.14.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:14:13 -0800 (PST)
Date: Thu, 2 Mar 2017 16:14:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302151411.GM1404@dhcp22.suse.cz>
References: <20170302103520.GC1404@dhcp22.suse.cz>
 <20170302122426.GA3213@bfoster.bfoster>
 <20170302124909.GE1404@dhcp22.suse.cz>
 <20170302130009.GC3213@bfoster.bfoster>
 <20170302132755.GG1404@dhcp22.suse.cz>
 <20170302134157.GD3213@bfoster.bfoster>
 <20170302135001.GI1404@dhcp22.suse.cz>
 <20170302142315.GE3213@bfoster.bfoster>
 <20170302143441.GL1404@dhcp22.suse.cz>
 <20170302145131.GF3213@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302145131.GF3213@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>, Christoph Hellwig <hch@lst.de>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu 02-03-17 09:51:31, Brian Foster wrote:
> On Thu, Mar 02, 2017 at 03:34:41PM +0100, Michal Hocko wrote:
> > On Thu 02-03-17 09:23:15, Brian Foster wrote:
> > > On Thu, Mar 02, 2017 at 02:50:01PM +0100, Michal Hocko wrote:
> > > > On Thu 02-03-17 08:41:58, Brian Foster wrote:
> > > > > On Thu, Mar 02, 2017 at 02:27:55PM +0100, Michal Hocko wrote:
> > > > [...]
> > > > > > I see your argument about being in sync with other kmem helpers but
> > > > > > those are bit different because regular page/slab allocators allow never
> > > > > > fail semantic (even though this is mostly ignored by those helpers which
> > > > > > implement their own retries but that is a different topic).
> > > > > > 
> > > > > 
> > > > > ... but what I'm trying to understand here is whether this failure
> > > > > scenario is specific to vmalloc() or whether the other kmem_*()
> > > > > functions are susceptible to the same problem. For example, suppose we
> > > > > replaced this kmem_zalloc_greedy() call with a kmem_zalloc(PAGE_SIZE,
> > > > > KM_SLEEP) call. Could we hit the same problem if the process is killed?
> > > > 
> > > > Well, kmem_zalloc uses kmalloc which can also fail when we are out of
> > > > memory but in that case we can expect the OOM killer releasing some
> > > > memory which would allow us to make a forward progress on the next
> > > > retry. So essentially retrying around kmalloc is much more safe in this
> > > > regard. Failing vmalloc might be permanent because there is no vmalloc
> > > > space to allocate from or much more likely due to already mentioned
> > > > patch. So vmalloc is different, really.
> > > 
> > > Right.. that's why I'm asking. So it's technically possible but highly
> > > unlikely due to the different failure characteristics. That seems
> > > reasonable to me, then. 
> > > 
> > > To be clear, do we understand what causes the vzalloc() failure to be
> > > effectively permanent in this specific reproducer? I know you mention
> > > above that we could be out of vmalloc space, but that doesn't clarify
> > > whether there are other potential failure paths or then what this has to
> > > do with the fact that the process was killed. Does the pending signal
> > > cause the subsequent failures or are you saying that there is some other
> > > root cause of the failure, this process would effectively be spinning
> > > here anyways, and we're just noticing it because it's trying to exit?
> > 
> > In this particular case it is fatal_signal_pending that causes the
> > permanent failure. This check has been added to prevent from complete
> > memory reserves depletion on OOM when a killed task has a free ticket to
> > reserves and vmalloc requests can be really large. In this case there
> > was no OOM killer going on but fsstress has SIGKILL pending for other
> > reason. Most probably as a result of the group_exit when all threads
> > are killed (see zap_process). I could have turn fatal_signal_pending
> > into tsk_is_oom_victim which would be less likely to hit but in
> > principle fatal_signal_pending should be better because we do want to
> > bail out when the process is existing as soon as possible.
> > 
> > What I really wanted to say is that there are other possible permanent
> > failure paths in vmalloc AFAICS. They are much less probable but they
> > still exist.
> > 
> > Does that make more sense now?
> 
> Yes, thanks. That explains why this crops up now where it hasn't in the
> past. Please include that background in the commit log description.

OK, does this sound better. I am open to any suggestions to improve this
of course

: xfs: allow kmem_zalloc_greedy to fail
: 
: Even though kmem_zalloc_greedy is documented it might fail the current
: code doesn't really implement this properly and loops on the smallest
: allowed size for ever. This is a problem because vzalloc might fail
: permanently - we might run out of vmalloc space or since 5d17a73a2ebe
: ("vmalloc: back off when the current task is killed") when the current
: task is killed. The later one makes the failure scenario much more
: probable than it used to be. Fix this by bailing out if the minimum size
: request failed.
: 
: This has been noticed by a hung generic/269 xfstest by Xiong Zhou.
: 
: fsstress: vmalloc: allocation failure, allocated 12288 of 20480 bytes, mode:0x14080c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_ZERO), nodemask=(null)
: fsstress cpuset=/ mems_allowed=0-1
: CPU: 1 PID: 23460 Comm: fsstress Not tainted 4.10.0-master-45554b2+ #21
: Hardware name: HP ProLiant DL380 Gen9/ProLiant DL380 Gen9, BIOS P89 10/05/2016
: Call Trace:
:  dump_stack+0x63/0x87
:  warn_alloc+0x114/0x1c0
:  ? alloc_pages_current+0x88/0x120
:  __vmalloc_node_range+0x250/0x2a0
:  ? kmem_zalloc_greedy+0x2b/0x40 [xfs]
:  ? free_hot_cold_page+0x21f/0x280
:  vzalloc+0x54/0x60
:  ? kmem_zalloc_greedy+0x2b/0x40 [xfs]
:  kmem_zalloc_greedy+0x2b/0x40 [xfs]
:  xfs_bulkstat+0x11b/0x730 [xfs]
:  ? xfs_bulkstat_one_int+0x340/0x340 [xfs]
:  ? selinux_capable+0x20/0x30
:  ? security_capable+0x48/0x60
:  xfs_ioc_bulkstat+0xe4/0x190 [xfs]
:  xfs_file_ioctl+0x9dd/0xad0 [xfs]
:  ? do_filp_open+0xa5/0x100
:  do_vfs_ioctl+0xa7/0x5e0
:  SyS_ioctl+0x79/0x90
:  do_syscall_64+0x67/0x180
:  entry_SYSCALL64_slow_path+0x25/0x25
: 
: fsstress keeps looping inside kmem_zalloc_greedy without any way out
: because vmalloc keeps failing due to fatal_signal_pending.
: 
: Reported-by: Xiong Zhou <xzhou@redhat.com>
: Analyzed-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
: Signed-off-by: Michal Hocko <mhocko@suse.com>

> Also, that kind of makes me think that a fatal_signal_pending() check is
> still appropriate in the loop, even if we want to drop the infinite
> retry loop in kmem_zalloc_greedy() as well. There's no sense in doing
> however many retries are left before we return and that's also more
> explicit for the next person who goes to change this code in the future.

I am not objecting to adding fatal_signal_pending as well I just thought
that from the logic POV breaking after reaching the minimum size is just
the right thing to do. We can optimize further by checking
fatal_signal_pending and reducing retries when we know it doesn't make
much sense but that should be done on top as an optimization IMHO.

> Otherwise, I'm fine with breaking the infinite retry loop at the same
> time. It looks like Christoph added this function originally so this
> should probably require his ack as well..

What do you think Christoph?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
