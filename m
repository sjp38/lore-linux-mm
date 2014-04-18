Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 07E376B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 15:17:35 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1694640pdj.36
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 12:17:35 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id fd9si16809383pad.429.2014.04.18.12.17.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 12:17:35 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so1745080pad.0
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 12:17:34 -0700 (PDT)
Date: Fri, 18 Apr 2014 12:16:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 16/16] mm: filemap: Prefetch page->flags if
 !PageUptodate
In-Reply-To: <1397832643-14275-17-git-send-email-mgorman@suse.de>
Message-ID: <alpine.LSU.2.11.1404181149310.13030@eggly.anvils>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de> <1397832643-14275-17-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, 18 Apr 2014, Mel Gorman wrote:

> The write_end handler is likely to call SetPageUptodate which is an atomic
> operation so prefetch the line.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

This one seems a little odd to me: it feels as if you're compensating
for your mark_page_accessed() movement, but in too shmem-specific a way.

I see write_ends do SetPageUptodate more often than I was expecting
(with __block_commit_write() doing so even when PageUptodate already),
but even so...

Given that the write_end is likely to want to SetPageDirty, and sure
to want to clear_bit_unlock(PG_locked, &page->flags), wouldn't it be
better and less mysterious just to prefetchw(&page->flags) here
unconditionally?

(But I'm also afraid that this sets a precedent for an avalanche of
dubious prefetchw patches all over.)

Hugh

> ---
>  mm/filemap.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index c28f69c..40713da 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2551,6 +2551,9 @@ again:
>  		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
>  		flush_dcache_page(page);
>  
> +		if (!PageUptodate(page))
> +			prefetchw(&page->flags);
> +
>  		status = a_ops->write_end(file, mapping, pos, bytes, copied,
>  						page, fsdata);
>  		if (unlikely(status < 0))
> -- 
> 1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
