Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 3D2D86B00CF
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 17:40:10 -0500 (EST)
Date: Thu, 6 Dec 2012 14:40:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] HWPOISON, hugetlbfs: fix RSS-counter warning
Message-Id: <20121206144008.9b376ec7.akpm@linux-foundation.org>
In-Reply-To: <1354745673-31035-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <3908561D78D1C84285E8C5FCA982C28F1C963B15@ORSMSX108.amr.corp.intel.com>
	<1354745673-31035-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Tony Luck <tony.luck@intel.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed,  5 Dec 2012 17:14:33 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Hi Tony,
> 
> On Wed, Dec 05, 2012 at 10:04:50PM +0000, Luck, Tony wrote:
> > 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> > -		if (PageAnon(page))
> > +		if (PageHuge(page))
> > +			;
> > +		else if (PageAnon(page))
> >  			dec_mm_counter(mm, MM_ANONPAGES);
> >  		else
> >  			dec_mm_counter(mm, MM_FILEPAGES);
> > 
> > This style minimizes the "diff" ... but wouldn't it be nicer to say:
> > 
> > 		if (!PageHuge(page)) {
> > 			old code in here
> > 		}
> > 
> 
> I think this need more lines in diff because old code should be
> indented without any logical change.

I do agree with Tony on this.  While it is nice to keep the diff
looking simple, it is more important that the resulting code be clean
and idiomatic.

--- a/mm/rmap.c~hwpoison-hugetlbfs-fix-rss-counter-warning-fix
+++ a/mm/rmap.c
@@ -1249,14 +1249,14 @@ int try_to_unmap_one(struct page *page, 
 	update_hiwater_rss(mm);
 
 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
-		if (PageHuge(page))
-			;
-		else if (PageAnon(page))
-			dec_mm_counter(mm, MM_ANONPAGES);
-		else
-			dec_mm_counter(mm, MM_FILEPAGES);
-		set_pte_at(mm, address, pte,
-				swp_entry_to_pte(make_hwpoison_entry(page)));
+		if (!PageHuge(page)) {
+			if (PageAnon(page))
+				dec_mm_counter(mm, MM_ANONPAGES);
+			else
+				dec_mm_counter(mm, MM_FILEPAGES);
+			set_pte_at(mm, address, pte,
+				   swp_entry_to_pte(make_hwpoison_entry(page)));
+		}
 	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
