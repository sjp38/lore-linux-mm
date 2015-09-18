Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 06F9F6B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 05:10:44 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so23483759wic.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 02:10:43 -0700 (PDT)
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com. [195.75.94.103])
        by mx.google.com with ESMTPS id y3si9788314wie.92.2015.09.18.02.10.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Sep 2015 02:10:42 -0700 (PDT)
Received: from /spool/local
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 18 Sep 2015 10:10:42 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3424E1B0806B
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 10:12:22 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8I9AegG33882144
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 09:10:40 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8I8AeLJ022359
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 02:10:40 -0600
Date: Fri, 18 Sep 2015 11:10:38 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150918111038.58c3a8de@mschwide>
In-Reply-To: <20150918085301.GC2035@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
	<1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
	<20150917193152.GJ2000@uranus>
	<20150918085835.597fb036@mschwide>
	<20150918071549.GA2035@uranus>
	<20150918102001.0e0389c7@mschwide>
	<20150918085301.GC2035@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, 18 Sep 2015 11:53:01 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Fri, Sep 18, 2015 at 10:20:01AM +0200, Martin Schwidefsky wrote:
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index e2d46ad..b029d42 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -754,7 +754,7 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
> >  
> >  	if (pte_present(ptent)) {
> >  		ptent = pte_wrprotect(ptent);
> > -		ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
> > +		ptent = pte_clear_soft_dirty(ptent);
> >  	} else if (is_swap_pte(ptent)) {
> >  		ptent = pte_swp_clear_soft_dirty(ptent);
> >  	}
> > @@ -768,7 +768,7 @@ static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
> >  	pmd_t pmd = *pmdp;
> >  
> >  	pmd = pmd_wrprotect(pmd);
> > -	pmd = pmd_clear_flags(pmd, _PAGE_SOFT_DIRTY);
> > +	pmd = pmd_clear_soft_dirty(pmd);
> >  
> 
> You know, these are only two lines where we use _PAGE_SOFT_DIRTY
> directly, so I don't see much point in adding 22 lines of code
> for that. Maybe we can leave it as is?
 
Only x86 has pte_clear_flags. And the two lines require that there is exactly
one bit in the PTE for soft-dirty. An alternative encoding will not be allowed.
And the current set of primitives is asymmetric, there are functions to query
and set the bit pte_soft_dirty and pte_mksoft_dirty but no function to clear
the bit.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
