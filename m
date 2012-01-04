Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 007306B00B5
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 19:05:06 -0500 (EST)
Date: Tue, 3 Jan 2012 16:05:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscam: check page order in isolating lru pages
Message-Id: <20120103160505.6f7a9aab.akpm@linux-foundation.org>
In-Reply-To: <CAJd=RBCuh=zDLZ7J9sV_p_ghoXP-VX6PEAx01t8p_pziTimxnA@mail.gmail.com>
References: <CAJd=RBBJG+hLLc3mR-WzByU1gZEcdFUAoZzyir+1A4a0tVnSmg@mail.gmail.com>
	<4EFCA4F9.7070703@gmail.com>
	<CAJd=RBCuh=zDLZ7J9sV_p_ghoXP-VX6PEAx01t8p_pziTimxnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>

On Sat, 31 Dec 2011 22:55:22 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> From: Hillf Danton <dhillf@gmail.com>
> Subject: [PATCH] mm: vmscam: check page order in isolating lru pages
> 
> Before try to isolate physically contiguous pages, check for page order is
> added, and if it is not regular page, we should give up the attempt.

Well..  why?  Neither the changelog nor the code comments explain why
we skip these pages.  They should!

> --- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
> +++ b/mm/vmscan.c	Sat Dec 31 22:44:16 2011
> @@ -1162,6 +1162,7 @@ static unsigned long isolate_lru_pages(u
>  		unsigned long end_pfn;
>  		unsigned long page_pfn;
>  		int zone_id;
> +		unsigned int isolated_pages = 1;
> 
>  		page = lru_to_page(src);
>  		prefetchw_prev_lru_page(page, src, flags);
> @@ -1172,7 +1173,7 @@ static unsigned long isolate_lru_pages(u
>  		case 0:
>  			mem_cgroup_lru_del(page);
>  			list_move(&page->lru, dst);
> -			nr_taken += hpage_nr_pages(page);
> +			isolated_pages = hpage_nr_pages(page);
>  			break;
> 
>  		case -EBUSY:
> @@ -1184,8 +1185,12 @@ static unsigned long isolate_lru_pages(u
>  			BUG();
>  		}
> 
> +		nr_taken += isolated_pages;
>  		if (!order)
>  			continue;
> +		/* try pfn-based isolation only for regular page */
> +		if (isolated_pages != 1)
> +			continue;
> 
>  		/*
>  		 * Attempt to take all pages in the order aligned region
> @@ -1227,7 +1232,6 @@ static unsigned long isolate_lru_pages(u
>  				break;
> 
>  			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
> -				unsigned int isolated_pages;
> 
>  				mem_cgroup_lru_del(cursor_page);
>  				list_move(&cursor_page->lru, dst);

The code has become rather awkward.

I don't like the trick of reusing a local (isolated_pages) for other
purposes later on in the function.  This introduces risk that someone
will add a usage of the local for its original application after it has
been reused.  And it's a little bit deceiving for readers - they first
have to work out "oh, it's being reused for something else".  It would
be better to use two identifiers.  The compiler is good at reusing
registers (and sometimes stack slots) if the earlier local has gone
dead.

Also, why do we test hpage_nr_pages() here?  Why not directly test
PageTransHuge()?


iow, something like this?

--- a/mm/vmscan.c~mm-vmscam-check-page-order-in-isolating-lru-pages-fix
+++ a/mm/vmscan.c
@@ -1173,7 +1173,6 @@ static unsigned long isolate_lru_pages(u
 		unsigned long end_pfn;
 		unsigned long page_pfn;
 		int zone_id;
-		unsigned int isolated_pages = 1;
 
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
@@ -1184,7 +1183,7 @@ static unsigned long isolate_lru_pages(u
 		case 0:
 			mem_cgroup_lru_del(page);
 			list_move(&page->lru, dst);
-			isolated_pages = hpage_nr_pages(page);
+			nr_taken += hpage_nr_pages(page);
 			break;
 
 		case -EBUSY:
@@ -1196,11 +1195,11 @@ static unsigned long isolate_lru_pages(u
 			BUG();
 		}
 
-		nr_taken += isolated_pages;
 		if (!order)
 			continue;
-		/* try pfn-based isolation only for regular page */
-		if (isolated_pages != 1)
+
+		/* Try pfn-based isolation only for regular pages */
+		if (PageTransHuge(page) != 1)
 			continue;
 
 		/*
@@ -1243,6 +1242,7 @@ static unsigned long isolate_lru_pages(u
 				break;
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
+				unsigned int isolated_pages;
 
 				mem_cgroup_del_lru(cursor_page);
 				list_move(&cursor_page->lru, dst);


If hpage_nr_pages() is the official way of testing for a thp page
then I guess this is the wrong thing to do!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
