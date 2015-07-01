Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A3A796B006E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 12:09:24 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so170253001wiw.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 09:09:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ht7si4114436wjb.176.2015.07.01.09.09.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 09:09:23 -0700 (PDT)
Date: Wed, 1 Jul 2015 18:09:18 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 44/51] writeback: implement bdi_wait_for_completion()
Message-ID: <20150701160918.GH7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-45-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-45-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:58, Tejun Heo wrote:
> If the completion of a wb_writeback_work can be waited upon by setting
> its ->done to a struct completion and waiting on it; however, for
> cgroup writeback support, it's necessary to issue multiple work items
> to multiple bdi_writebacks and wait for the completion of all.
> 
> This patch implements wb_completion which can wait for multiple work
> items and replaces the struct completion with it.  It can be defined
> using DEFINE_WB_COMPLETION_ONSTACK(), used for multiple work items and
> waited for by wb_wait_for_completion().
> 
> Nobody currently issues multiple work items and this patch doesn't
> introduce any behavior changes.

One more thing...

> @@ -161,17 +178,34 @@ static void wb_queue_work(struct bdi_writeback *wb,
>  	trace_writeback_queue(wb->bdi, work);
>  
>  	spin_lock_bh(&wb->work_lock);
> -	if (!test_bit(WB_registered, &wb->state)) {
> -		if (work->done)
> -			complete(work->done);
> +	if (!test_bit(WB_registered, &wb->state))
>  		goto out_unlock;

This seems like a change in behavior. Previously unregistered wbs just
completed the work->done, now you don't complete them. Is that intentional?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
