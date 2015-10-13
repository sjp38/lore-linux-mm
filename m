Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3B66B0255
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 11:13:02 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so93232882wic.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 08:13:01 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id my3si23539272wic.118.2015.10.13.08.12.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Oct 2015 08:12:52 -0700 (PDT)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 13 Oct 2015 16:12:51 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id B55C117D8062
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 16:12:53 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9DFCm1h35586248
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 15:12:48 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9DFClVo020362
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 09:12:48 -0600
Date: Tue, 13 Oct 2015 17:12:46 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [RFC] futex: prevent endless loop on s390x with emulated
 hugepages
Message-ID: <20151013171246.0a7b255e@mschwide>
In-Reply-To: <561D0C5A.6030505@suse.cz>
References: <1443107148-28625-1-git-send-email-vbabka@suse.cz>
	<20150928134928.2214dae2@mschwide>
	<561CEF77.3050309@suse.cz>
	<561D0C5A.6030505@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yong Sun <yosun@suse.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org, Zhang Yi <wetpzy@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>

On Tue, 13 Oct 2015 15:51:22 +0200
Vlastimil Babka <vbabka@suse.cz> wrote:

> On 10/13/2015 01:48 PM, Vlastimil Babka wrote:
> > On 09/28/2015 01:49 PM, Martin Schwidefsky wrote:
> >> On Thu, 24 Sep 2015 17:05:48 +0200
> >> Vlastimil Babka <vbabka@suse.cz> wrote:
> >
> > [...]
> >
> >>> However, __get_user_pages_fast() is still broken. The get_user_pages_fast()
> >>> wrapper will hide this in the common case. The other user of the __ variant
> >>> is kvm, which is mentioned as the reason for removal of emulated hugepages.
> >>> The call of page_cache_get_speculative() looks also broken in this scenario
> >>> on debug builds because of VM_BUG_ON_PAGE(PageTail(page), page). With
> >>> CONFIG_TINY_RCU enabled, there's plain atomic_inc(&page->_count) which also
> >>> probably shouldn't happen for a tail page...
> >>
> >> It boils down to __get_user_pages_fast being broken for emulated large pages,
> >> doesn't it? My preferred fix would be to get __get_user_page_fast to work
> >> in this case.
> >
> > I agree, but didn't know enough of the architecture to attempt such fix
> > :) Thanks!
> >
> >> For 3.12 a patch would look like this (needs more testing
> >> though):
> >
> > FWIW it works for me in the particular LTP test, but as you said, it
> > needs more testing and breaking stable would suck.
> 
> I'm trying to break the patch on 3.12 with trinity, let's see...
> Tried also to review it, although it's unlikely I'll catch some 
> s390x-specific gotchas. For example, can't say what the effect of 
> _SEGMENT_ENTRY_CO removal will be - before, the bit was set for 
> non-emulated hugepages, and now the same bit is set for emulated ones?
> Or if pmd_bad() was also broken before, and now isn't? But otherwise the 
> change seems OK, besides some nitpick below.

The _SEGMENT_ENTRY_CO is the segment change-override bit. This allows the
machine to skip storage-key updates for the dirty bit. Linux uses the 
storage keys only for KVM which does not allow any kind of large page
to be present. The latest PoP remove the change-override bits again,
it never had an effect. As the bit is ignored I can reuse it as the
software large page bit.

> >> @@ -103,7 +104,7 @@ static inline int gup_pmd_range(pud_t *pudp, pud_t pud, unsigned long addr,
> >>    		unsigned long end, int write, struct page **pages, int *nr)
> >>    {
> >>    	unsigned long next;
> >> -	pmd_t *pmdp, pmd;
> >> +	pmd_t *pmdp, pmd, pmd_orig;
> >>
> >>    	pmdp = (pmd_t *) pudp;
> >>    #ifdef CONFIG_64BIT
> >> @@ -112,7 +113,7 @@ static inline int gup_pmd_range(pud_t *pudp, pud_t pud, unsigned long addr,
> >>    	pmdp += pmd_index(addr);
> >>    #endif
> >>    	do {
> >> -		pmd = *pmdp;
> >> +		pmd = pmd_orig = *pmdp;
> >>    		barrier();
> >>    		next = pmd_addr_end(addr, end);
> >>    		/*
> >> @@ -127,8 +128,9 @@ static inline int gup_pmd_range(pud_t *pudp, pud_t pud, unsigned long addr,
> >>    		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
> >>    			return 0;
> >>    		if (unlikely(pmd_large(pmd))) {
> >> -			if (!gup_huge_pmd(pmdp, pmd, addr, next,
> >> -					  write, pages, nr))
> >> +			if (!gup_huge_pmd(pmdp, pmd_orig,
> >> +					  pmd_swlarge_deref(pmd),
> >> +					  addr, next, write, pages, nr))
> >>    				return 0;
> >>    		} else if (!gup_pte_range(pmdp, pmd, addr, next,
> >>    					  write, pages, nr))
> 
> The "pmd" variable isn't changed anywhere in this loop after the initial 
> assignment, so the extra "pmd_orig" variable isn't needed.

That is true, I will remove the pmd_orig variable.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
