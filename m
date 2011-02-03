Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECC88D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:35:53 -0500 (EST)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p13LKqA1007048
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 14:20:52 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p13LYpnj143952
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 14:34:52 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p13LYpof022177
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 14:34:51 -0700
Subject: Re: [RFC][PATCH 5/6] teach smaps_pte_range() about THP pmds
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1102031319070.1307@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel>
	 <20110201003403.736A24DF@kernel>
	 <alpine.DEB.2.00.1102031319070.1307@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 03 Feb 2011 13:34:50 -0800
Message-ID: <1296768890.8299.1648.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 2011-02-03 at 13:22 -0800, David Rientjes wrote:
> > @@ -385,6 +386,17 @@ static int smaps_pte_range(pmd_t *pmd, u
> >  	pte_t *pte;
> >  	spinlock_t *ptl;
> >  
> > +	if (pmd_trans_huge(*pmd)) {
> > +		if (pmd_trans_splitting(*pmd)) {
> > +			spin_unlock(&walk->mm->page_table_lock);
> > +			wait_split_huge_page(vma->anon_vma, pmd);
> > +			spin_lock(&walk->mm->page_table_lock);
> > +			goto normal_ptes;
> > +		}
> > +		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_SIZE, walk);
> > +		return 0;
> > +	}
> > +normal_ptes:
> 
> Small nitpick: the label isn't necessary, just use an else-clause on your 
> nested conditional.

Works for me.

> >  	split_huge_page_pmd(walk->mm, pmd);
> >  
> >  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > diff -puN mm/vmscan.c~teach-smaps_pte_range-about-thp-pmds mm/vmscan.c
> > diff -puN include/trace/events/vmscan.h~teach-smaps_pte_range-about-thp-pmds include/trace/events/vmscan.h
> > diff -puN mm/pagewalk.c~teach-smaps_pte_range-about-thp-pmds mm/pagewalk.c
> > diff -puN mm/huge_memory.c~teach-smaps_pte_range-about-thp-pmds mm/huge_memory.c
> > diff -puN mm/memory.c~teach-smaps_pte_range-about-thp-pmds mm/memory.c
> > diff -puN include/linux/huge_mm.h~teach-smaps_pte_range-about-thp-pmds include/linux/huge_mm.h
> > diff -puN mm/internal.h~teach-smaps_pte_range-about-thp-pmds mm/internal.h
> > _
> 
> What are all these?

Junk.  I'll pull them out.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
