Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id EAAF06B00A2
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 12:20:01 -0500 (EST)
Message-ID: <4F145BE7.1060802@ah.jp.nec.com>
Date: Mon, 16 Jan 2012 12:18:31 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] pagemap: avoid splitting thp when reading /proc/pid/pagemap
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Sat, Jan 14, 2012 at 06:00:26PM +0100, Andrea Arcangeli wrote:
> On Thu, Jan 12, 2012 at 02:34:53PM -0500, Naoya Horiguchi wrote:
> > +		if (pmd_trans_splitting(*pmd)) {
> > +			spin_unlock(&walk->mm->page_table_lock);
> > +			wait_split_huge_page(vma->anon_vma, pmd);
> > +		} else {
> > +			for (; addr != end; addr += PAGE_SIZE) {
> > +				unsigned long offset = (addr & ~PAGEMAP_WALK_MASK)
> > +					>> PAGE_SHIFT;
> > +				pfn = thp_pte_to_pagemap_entry(*(pte_t *)pmd,
> > +							       offset);
> 
> What is this that then morphs into a pme (which still has a cast
> inside its creation)? thp_pte_to_pagemap_entry don't seem to be passed
> ptes too. The only case where it is valid to do a cast like that is
> when a function is used by both ptes sand pmds and the code tends to
> work for both with minimal modification to differentiate the two
> cases. Considering the function that gets the cast is called thp_ this
> is hardly the case here.

Agreed.

> Why don't you pass the pmd and then do "if (pmd_present(pmd))
> page_to_pfn(pmd_page(pmd)) ? What's the argument for the cast. I'm
> just reviewing this series and maybe it was covered in previous
> versions.

OK, I can do this by introducing pmd_pte as you commented in another email.

> I don't get this pme thing for something as trivial as above that
> shouldn't require any cast at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
