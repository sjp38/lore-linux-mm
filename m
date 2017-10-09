Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8582A6B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 18:42:18 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p77so3448713lfg.2
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 15:42:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y18si9230671wry.12.2017.10.09.15.42.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 15:42:17 -0700 (PDT)
Date: Mon, 9 Oct 2017 15:42:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page-writeback.c: fix bug caused by disable periodic
 writeback
Message-Id: <20171009154212.bdf3645a2dce5d540657914b@linux-foundation.org>
In-Reply-To: <1507330684-2205-1-git-send-email-laoar.shao@gmail.com>
References: <1507330684-2205-1-git-send-email-laoar.shao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: jack@suse.cz, mhocko@suse.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

On Sat,  7 Oct 2017 06:58:04 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:

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
> ...
>
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
>  	return 0;

We could do with a code comment here, explaining why this code exists.

And...  I'm not sure it works correctly?  For example, if a device
doesn't presently have bdi_has_dirty_io() then wakeup_flusher_threads()
will skip it and the periodic writeback still won't be started?

(why does the dirty_writeback_interval==0 special case exist, btw? 
Seems to be a strange thing to do).

(and what happens if the interval was set to 1 hour and the user
rewrites that to 1 second?  Does that change take 1 hour to take
effect?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
