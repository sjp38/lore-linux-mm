Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5A26B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 05:57:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e26so44053603pfd.4
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 02:57:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si3930026pls.167.2017.10.09.02.56.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 02:56:58 -0700 (PDT)
Date: Mon, 9 Oct 2017 11:56:55 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/page-writeback.c: fix bug caused by disable periodic
 writeback
Message-ID: <20171009095655.GF17917@quack2.suse.cz>
References: <1507330684-2205-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1507330684-2205-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, mhocko@suse.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 07-10-17 06:58:04, Yafang Shao wrote:
> After disable periodic writeback by writing 0 to
> dirty_writeback_centisecs, the handler wb_workfn() will not be
> entered again until the dirty background limit reaches or
> sync syscall is executed or no enough free memory available or
> vmscan is triggered.
> So the periodic writeback can't be enabled by writing a non-zero
> value to dirty_writeback_centisecs
> As it can be disabled by sysctl, it should be able to enable by 
> sysctl as well.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  mm/page-writeback.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 0b9c5cb..e202f37 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1972,7 +1972,13 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
>  int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
>  	void __user *buffer, size_t *length, loff_t *ppos)
>  {
> -	proc_dointvec(table, write, buffer, length, ppos);
> +	unsigned int old_interval = dirty_writeback_interval;
> +	int ret;
> +
> +	ret = proc_dointvec(table, write, buffer, length, ppos);
> +	if (!ret && !old_interval && dirty_writeback_interval)
> +		wakeup_flusher_threads(0, WB_REASON_PERIODIC);
> +

I agree it is good to schedule some writeback. However Jens has some
changes queued in linux-block tree in this area so your change won't apply.
So please base your changes on his tree.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
