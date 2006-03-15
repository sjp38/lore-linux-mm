Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2FFvYRu023960
	for <linux-mm@kvack.org>; Wed, 15 Mar 2006 10:57:34 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2FFvYoH164216
	for <linux-mm@kvack.org>; Wed, 15 Mar 2006 10:57:34 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k2FFvXmO013829
	for <linux-mm@kvack.org>; Wed, 15 Mar 2006 10:57:34 -0500
Date: Wed, 15 Mar 2006 07:56:46 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [discuss] Re: BUG in x86_64 hugepage support
Message-ID: <20060315155646.GA7775@us.ibm.com>
References: <4417E359.76F0.0078.0@novell.com> <200603151003.k2FA30g14232@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200603151003.k2FA30g14232@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Jan Beulich' <JBeulich@novell.com>, david@gibson.dropbear.id.au, linux-mm@kvack.org, Andreas Kleen <ak@suse.de>, agl@us.ibm.com, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

On 15.03.2006 [02:03:00 -0800], Chen, Kenneth W wrote:
> Nishanth Aravamudan wrote on Tuesday, March 14, 2006 11:31 PM
> > Description: We currently fail mprotect testing in libhugetlbfs
> > because the PSE bit in the hugepage PTEs gets unset. In the case
> > where we know that a filled hugetlb PTE is going to have its
> > protection changed, make sure it stays a hugetlb PTE by setting the
> > PSE bit in the new protection flags.
> 
> Jan Beulich wrote on Wednesday, March 15, 2006 12:50 AM
> > This is architecture independent code - you shouldn't be using
> > _PAGE_PSE here. Probably x86-64 (and then likely also i386) should
> > define their own set_huge_pte_at(), and use that# to or in the
> > needed flag?
> 
> 
> Yeah, that will do.  i386, x86_64 should also clean up pte_mkhuge()
> macro.  The unconditional setting of _PAGE_PRESENT bit was a leftover
> stuff from the good'old day of pre-faulting hugetlb page.  
> 
> 
> 
> [patch] fix i386/x86-64 _PAGE_PSE bit when changing page protection
> 
> On i386 and x86-64, pte flag _PAGE_PSE collides with _PAGE_PROTNONE.
> The identify of hugetlb pte is lost when changing page protection via
> mprotect. A page fault occurs later will trigger a bug check in
> huge_pte_alloc().
> 
> The fix is to always make new pte a hugetlb pte and also to clean up
> legacy code where _PAGE_PRESENT is forced on in the pre-faulting day.
> 
> 
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

I can confirm this fixes the BUGs I was seeing on x86_64 testing of
libhugetlbfs' mprotect support.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
