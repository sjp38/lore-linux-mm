Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 5DA5C6B0071
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 21:10:35 -0500 (EST)
Date: Thu, 6 Dec 2012 18:10:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] HWPOISON, hugetlbfs: fix RSS-counter warning
Message-Id: <20121206181024.f8a77240.akpm@linux-foundation.org>
In-Reply-To: <1354843362-3680-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20121206144008.9b376ec7.akpm@linux-foundation.org>
	<1354843362-3680-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Tony Luck <tony.luck@intel.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu,  6 Dec 2012 20:22:42 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> > --- a/mm/rmap.c~hwpoison-hugetlbfs-fix-rss-counter-warning-fix
> > +++ a/mm/rmap.c
> > @@ -1249,14 +1249,14 @@ int try_to_unmap_one(struct page *page, 
> >  	update_hiwater_rss(mm);
> >  
> >  	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> > -		if (PageHuge(page))
> > -			;
> > -		else if (PageAnon(page))
> > -			dec_mm_counter(mm, MM_ANONPAGES);
> > -		else
> > -			dec_mm_counter(mm, MM_FILEPAGES);
> > -		set_pte_at(mm, address, pte,
> > -				swp_entry_to_pte(make_hwpoison_entry(page)));
> > +		if (!PageHuge(page)) {
> > +			if (PageAnon(page))
> > +				dec_mm_counter(mm, MM_ANONPAGES);
> > +			else
> > +				dec_mm_counter(mm, MM_FILEPAGES);
> > +			set_pte_at(mm, address, pte,
> > +				   swp_entry_to_pte(make_hwpoison_entry(page)));
> > +		}
> 
> This set_pte_at() should come outside the if-block, or error containment
> does not work.

Doh.  C is really hard!

--- a/mm/rmap.c~hwpoison-hugetlbfs-fix-rss-counter-warning-fix-fix
+++ a/mm/rmap.c
@@ -1254,9 +1254,9 @@ int try_to_unmap_one(struct page *page, 
 				dec_mm_counter(mm, MM_ANONPAGES);
 			else
 				dec_mm_counter(mm, MM_FILEPAGES);
-			set_pte_at(mm, address, pte,
-				   swp_entry_to_pte(make_hwpoison_entry(page)));
 		}
+		set_pte_at(mm, address, pte,
+			   swp_entry_to_pte(make_hwpoison_entry(page)));
 	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
