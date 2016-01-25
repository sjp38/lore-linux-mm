Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 021EF6B0256
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:35:02 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id n5so74979214wmn.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 03:35:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id le8si27938643wjb.80.2016.01.25.03.35.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 03:35:01 -0800 (PST)
Date: Mon, 25 Jan 2016 12:35:13 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: filemap: Avoid unnecessary calls to lock_page
 when waiting for IO to complete during a read
Message-ID: <20160125113513.GE20933@quack.suse.cz>
References: <1453716204-20409-1-git-send-email-mgorman@techsingularity.net>
 <1453716204-20409-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453716204-20409-3-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 25-01-16 10:03:24, Mel Gorman wrote:
> In the generic read paths the kernel looks up a page in the page cache
> and if it's up to date, it is used. If not, the page lock is acquired to
> wait for IO to complete and then check the page.  If multiple processes
> are waiting on IO, they all serialise against the lock and duplicate the
> checks. This is unnecessary.
> 
> The page lock in itself does not give any guarantees to the callers about
> the page state as it can be immediately truncated or reclaimed after the
> page is unlocked. It's sufficient to wait_on_page_locked and then continue
> if the page is up to date on wakeup.
> 
> It is possible that a truncated but up-to-date page is returned but the
> reference taken during read prevents it disappearing underneath the caller
> and the data is still valid if PageUptodate.
> 
> The overall impact is small as even if processes serialise on the lock,
> the lock section is tiny once the IO is complete. Profiles indicated that
> unlock_page and friends are generally a tiny portion of a read-intensive
> workload.  An artifical test was created that had instances of dd access
> a cache-cold file on an ext4 filesystem and measure how long the read took.
> 
> paralleldd
>                                     4.4.0                 4.4.0
>                                   vanilla             avoidlock
> Amean    Elapsd-1          5.28 (  0.00%)        5.15 (  2.50%)
> Amean    Elapsd-4          5.29 (  0.00%)        5.17 (  2.12%)
> Amean    Elapsd-7          5.28 (  0.00%)        5.18 (  1.78%)
> Amean    Elapsd-12         5.20 (  0.00%)        5.33 ( -2.50%)
> Amean    Elapsd-21         5.14 (  0.00%)        5.21 ( -1.41%)
> Amean    Elapsd-30         5.30 (  0.00%)        5.12 (  3.38%)
> Amean    Elapsd-48         5.78 (  0.00%)        5.42 (  6.21%)
> Amean    Elapsd-79         6.78 (  0.00%)        6.62 (  2.46%)
> Amean    Elapsd-110        9.09 (  0.00%)        8.99 (  1.15%)
> Amean    Elapsd-128       10.60 (  0.00%)       10.43 (  1.66%)
> 
> The impact is small but intuitively, it makes sense to avoid unnecessary
> calls to lock_page.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

The patch looks good. One small nit below, otherwise feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

> ---
>  mm/filemap.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 49 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index aa38593d0cd5..235ee2b0b5da 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1649,6 +1649,15 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
>  					index, last_index - index);
>  		}
>  		if (!PageUptodate(page)) {
> +			/*
> +			 * See comment in do_read_cache_page on why
> +			 * wait_on_page_locked is used to avoid unnecessarily
> +			 * serialisations and why it's safe.
> +			 */
> +			wait_on_page_locked(page);
> +			if (PageUptodate(page))
> +				goto page_ok;
> +

We want a wait_on_page_locked_killable() here to match the
lock_page_killable() later in do_generic_file_read()?

									Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
