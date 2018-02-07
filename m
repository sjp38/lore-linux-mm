Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFD6B6B036E
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 16:05:39 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w102so1214163wrb.21
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 13:05:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 4si1745976wmw.138.2018.02.07.13.05.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 13:05:38 -0800 (PST)
Date: Wed, 7 Feb 2018 13:05:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v2] mm, swap, frontswap: Fix THP swap if frontswap
 enabled
Message-Id: <20180207130534.259cd71a595c6275b2da38d3@linux-foundation.org>
In-Reply-To: <20180207070035.30302-1-ying.huang@intel.com>
References: <20180207070035.30302-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed,  7 Feb 2018 15:00:35 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> From: Huang Ying <huang.ying.caritas@gmail.com>
> 
> It was reported by Sergey Senozhatsky that if THP (Transparent Huge
> Page) and frontswap (via zswap) are both enabled, when memory goes low
> so that swap is triggered, segfault and memory corruption will occur
> in random user space applications as follow,
> 
> kernel: urxvt[338]: segfault at 20 ip 00007fc08889ae0d sp 00007ffc73a7fc40 error 6 in libc-2.26.so[7fc08881a000+1ae000]
>  #0  0x00007fc08889ae0d _int_malloc (libc.so.6)
>  #1  0x00007fc08889c2f3 malloc (libc.so.6)
>  #2  0x0000560e6004bff7 _Z14rxvt_wcstoutf8PKwi (urxvt)
>  #3  0x0000560e6005e75c n/a (urxvt)
>  #4  0x0000560e6007d9f1 _ZN16rxvt_perl_interp6invokeEP9rxvt_term9hook_typez (urxvt)
>  #5  0x0000560e6003d988 _ZN9rxvt_term9cmd_parseEv (urxvt)
>  #6  0x0000560e60042804 _ZN9rxvt_term6pty_cbERN2ev2ioEi (urxvt)
>  #7  0x0000560e6005c10f _Z17ev_invoke_pendingv (urxvt)
>  #8  0x0000560e6005cb55 ev_run (urxvt)
>  #9  0x0000560e6003b9b9 main (urxvt)
>  #10 0x00007fc08883af4a __libc_start_main (libc.so.6)
>  #11 0x0000560e6003f9da _start (urxvt)
> 
> After bisection, it was found the first bad commit is
> bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped
> out").
> 
> The root cause is as follow.
> 
> When the pages are written to swap device during swapping out in
> swap_writepage(), zswap (fontswap) is tried to compress the pages
> instead to improve the performance.  But zswap (frontswap) will treat
> THP as normal page, so only the head page is saved.  After swapping
> in, tail pages will not be restored to its original contents, so cause
> the memory corruption in the applications.
> 
> This is fixed via splitting THP before writing the page to swap device
> if frontswap is enabled.  To deal with the situation where frontswap
> is enabled at runtime, whether the page is THP is checked before using
> frontswap during swapping out too.
>
> ...
>
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -250,7 +250,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>  		unlock_page(page);
>  		goto out;
>  	}
> -	if (frontswap_store(page) == 0) {
> +	if (!PageTransHuge(page) && frontswap_store(page) == 0) {
>  		set_page_writeback(page);
>  		unlock_page(page);
>  		end_page_writeback(page);
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 006047b16814..0b7c7883ce64 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -934,6 +934,9 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
>  
>  	/* Only single cluster request supported */
>  	WARN_ON_ONCE(n_goal > 1 && cluster);
> +	/* Frontswap doesn't support THP */
> +	if (frontswap_enabled() && cluster)
> +		goto noswap;
>  

hm.  This is assuming that "cluster==true" means "this is thp swap". 
That's presently true, but is it appropriate that get_swap_pages() is
peeking at "cluster" to work out why it is being called?

Or would it be cleaner to do this in get_swap_page()?  Something like

--- a/mm/swap_slots.c~a
+++ a/mm/swap_slots.c
@@ -317,8 +317,11 @@ swp_entry_t get_swap_page(struct page *p
 	entry.val = 0;
 
 	if (PageTransHuge(page)) {
-		if (IS_ENABLED(CONFIG_THP_SWAP))
-			get_swap_pages(1, true, &entry);
+		/* Frontswap doesn't support THP */
+		if (!frontswap_enabled()) {
+			if (IS_ENABLED(CONFIG_THP_SWAP))
+				get_swap_pages(1, true, &entry);
+		}
 		return entry;
 	}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
