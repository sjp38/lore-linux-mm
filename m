Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF4B8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:33:42 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p13L8Rvs007044
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 16:08:38 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id BE1174DE8026
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:32:57 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p13LXY3v123322
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 16:33:35 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p13LXYDX023284
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 14:33:34 -0700
Subject: Re: [RFC][PATCH 2/6] pagewalk: only split huge pages when necessary
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1102031257490.948@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel>
	 <20110201003359.8DDFF665@kernel>
	 <alpine.DEB.2.00.1102031257490.948@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 03 Feb 2011 13:33:32 -0800
Message-ID: <1296768812.8299.1644.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 2011-02-03 at 13:22 -0800, David Rientjes wrote:
> > diff -puN mm/pagewalk.c~pagewalk-dont-always-split-thp mm/pagewalk.c
> > --- linux-2.6.git/mm/pagewalk.c~pagewalk-dont-always-split-thp	2011-01-27 10:57:02.309914973 -0800
> > +++ linux-2.6.git-dave/mm/pagewalk.c	2011-01-27 10:57:02.317914965 -0800
> > @@ -33,19 +33,35 @@ static int walk_pmd_range(pud_t *pud, un
> >  
> >  	pmd = pmd_offset(pud, addr);
> >  	do {
> > +	again:
> 
> checkpatch will warn about the indent.
> 
> >  		next = pmd_addr_end(addr, end);
> > -		split_huge_page_pmd(walk->mm, pmd);
> > -		if (pmd_none_or_clear_bad(pmd)) {
> > +		if (pmd_none(*pmd)) {
> 
> Not sure why this has been changed from pmd_none_or_clear_bad(), that's 
> been done even prior to THP.

The bad check will trigger on huge pmds.  We can not use it here.  We
can, however, use pmd_none().  The bad check was moved below to where we
actually dereference the pmd.

> >  			if (walk->pte_hole)
> >  				err = walk->pte_hole(addr, next, walk);
> >  			if (err)
> >  				break;
> >  			continue;
> >  		}
> > +		/*
> > +		 * This implies that each ->pmd_entry() handler
> > +		 * needs to know about pmd_trans_huge() pmds
> > +		 */
> 
> Probably needs to be documented somewhere for users of pagewalk?

Probably, but we don't currently have any central documentation for it.
Guess we could make some, or just ensure that all the users got updated.
Any ideas where to put it other than the mm_walk struct?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
