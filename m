Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m992GxOa017421
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Oct 2008 11:17:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E7AA2AC026
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 11:16:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 683EA12C046
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 11:16:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 53D771DB803B
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 11:16:59 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DF841DB803C
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 11:16:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
In-Reply-To: <20081008213831.GA23729@x200.localdomain>
References: <1223052415-18956-2-git-send-email-mel@csn.ul.ie> <20081008213831.GA23729@x200.localdomain>
Message-Id: <20081009104014.DEBD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Oct 2008 11:16:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi

> > It is useful to verify a hugepage-aware application is using the expected
> > pagesizes for its memory regions. This patch creates an entry called
> > KernelPageSize in /proc/pid/smaps that is the size of page used by the
> > kernel to back a VMA. The entry is not called PageSize as it is possible
> > the MMU uses a different size. This extension should not break any sensible
> > parser that skips lines containing unrecognised information.
> 
> > +		   "KernelPageSize: %8lu kB\n",
> 
> > +unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
> > +{
> > +	struct hstate *hstate;
> > +
> > +	if (!is_vm_hugetlb_page(vma))
> > +		return PAGE_SIZE;
> > +
> > +	hstate = hstate_vma(vma);
> > +	VM_BUG_ON(!hstate);
> > +
> > +	return 1UL << (hstate->order + PAGE_SHIFT);
> 			    ^^^^
> VM_BUG_ON is unneeded because kernel will oops here if hstate is NULL.

yup.


> Also, in /proc/*/maps it's printed only for hugetlb vmas and called
> hpagesize, in smaps it's printed for every vma and called
> KernelPageSize. All of this is inconsistent.

Is this a problem?
/proc/*/maps and /proc/*/smaps are different purpose file.

/proc/*/maps:  summary & suppressed information & easy readable
/proc/*/smaps: verbose output

Already some information output only smaps.


> And app will verify once that hugepages are of right size, so Pss cost
> argument for changing /proc/*/maps seems weak to me.

sorry, I don't understand yet.
Why pss cost changed?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
