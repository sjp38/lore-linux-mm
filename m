Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1E04A6B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 08:53:18 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so386550eek.3
        for <linux-mm@kvack.org>; Tue, 13 May 2014 05:53:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p43si9076659eem.183.2014.05.13.05.53.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 05:53:16 -0700 (PDT)
Date: Tue, 13 May 2014 13:53:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140513125313.GR23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1399974350-11089-20-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 10:45:50AM +0100, Mel Gorman wrote:
>  void unlock_page(struct page *page)
>  {
> +	wait_queue_head_t *wqh = clear_page_waiters(page);
> +
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +
> +	/*
> +	 * No additional barrier needed due to clear_bit_unlock barriering all updates
> +	 * before waking waiters
> +	 */
>  	clear_bit_unlock(PG_locked, &page->flags);
> -	smp_mb__after_clear_bit();
> -	wake_up_page(page, PG_locked);

This is wrong. The smp_mb__after_clear_bit() is still required to ensure
that the cleared bit is visible before the wakeup on all architectures.

---8<---
diff --git a/mm/filemap.c b/mm/filemap.c
index 6ac066e..028b5a1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -819,11 +819,8 @@ void unlock_page(struct page *page)
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
-	/*
-	 * No additional barrier needed due to clear_bit_unlock barriering all updates
-	 * before waking waiters
-	 */
 	clear_bit_unlock(PG_locked, &page->flags);
+	smp_mb__after_clear_bit();
 
 	/*
 	 * Wake the queue if waiters were detected. Ordinarily this wakeup

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
