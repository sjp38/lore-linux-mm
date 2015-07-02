Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4746B0260
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 23:01:54 -0400 (EDT)
Received: by qget71 with SMTP id t71so27643344qge.2
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 20:01:54 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id 186si4817191qhw.24.2015.07.01.20.01.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 20:01:53 -0700 (PDT)
Received: by qgii30 with SMTP id i30so27679777qgi.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 20:01:53 -0700 (PDT)
Date: Wed, 1 Jul 2015 23:01:50 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 44/51] writeback: implement bdi_wait_for_completion()
Message-ID: <20150702030150.GL26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-45-git-send-email-tj@kernel.org>
 <20150701160918.GH7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701160918.GH7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Wed, Jul 01, 2015 at 06:09:18PM +0200, Jan Kara wrote:
> > @@ -161,17 +178,34 @@ static void wb_queue_work(struct bdi_writeback *wb,
> >  	trace_writeback_queue(wb->bdi, work);
> >  
> >  	spin_lock_bh(&wb->work_lock);
> > -	if (!test_bit(WB_registered, &wb->state)) {
> > -		if (work->done)
> > -			complete(work->done);
> > +	if (!test_bit(WB_registered, &wb->state))
> >  		goto out_unlock;
> 
> This seems like a change in behavior. Previously unregistered wbs just
> completed the work->done, now you don't complete them. Is that intentional?

If nothing is queued, the cnt is never increased and the wait becomes
noop.  The default states are different between completion and
wb_completion.  There's no need to do anything to indicate that
nothing needs to be waited.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
