Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F25926B00B7
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 13:15:57 -0400 (EDT)
Received: by pzk26 with SMTP id 26so599416pzk.14
        for <linux-mm@kvack.org>; Fri, 10 Sep 2010 10:15:56 -0700 (PDT)
Date: Fri, 10 Sep 2010 10:15:46 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 3/4] hugetlb, rmap: fix confusing page locking in
 hugetlb_cow()
In-Reply-To: <1284092586-1179-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LFD.2.00.1009101011140.9670@i5.linux-foundation.org>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1284092586-1179-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Fri, 10 Sep 2010, Naoya Horiguchi wrote:
>  
> -	if (!pagecache_page) {
> -		page = pte_page(entry);
> +	/*
> +	 * hugetlb_cow() requires page locks of pte_page(entry) and
> +	 * pagecache_page, so here we need take the former one
> +	 * when page != pagecache_page or !pagecache_page.
> +	 */
> +	page = pte_page(entry);
> +	if (page != pagecache_page)
>  		lock_page(page);

Why isn't this a potential deadlock? You have two pages, and lock them 
both. Is there some ordering guarantee that says that 'pagecache_page' and 
'page' will always be in a certain relationship so that you cannot get 
A->B and B->A lock ordering?

Please document that ordering rule if so.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
