Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AB1548D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:46:34 -0500 (EST)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p13LkWkW005069
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:46:32 -0800
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by hpaq2.eem.corp.google.com with ESMTP id p13LkTVm020278
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:46:31 -0800
Received: by pvh11 with SMTP id 11so371525pvh.18
        for <linux-mm@kvack.org>; Thu, 03 Feb 2011 13:46:29 -0800 (PST)
Date: Thu, 3 Feb 2011 13:46:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 2/6] pagewalk: only split huge pages when
 necessary
In-Reply-To: <1296768812.8299.1644.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1102031343530.1307@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel> <20110201003359.8DDFF665@kernel> <alpine.DEB.2.00.1102031257490.948@chino.kir.corp.google.com> <1296768812.8299.1644.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 3 Feb 2011, Dave Hansen wrote:

> > > diff -puN mm/pagewalk.c~pagewalk-dont-always-split-thp mm/pagewalk.c
> > > --- linux-2.6.git/mm/pagewalk.c~pagewalk-dont-always-split-thp	2011-01-27 10:57:02.309914973 -0800
> > > +++ linux-2.6.git-dave/mm/pagewalk.c	2011-01-27 10:57:02.317914965 -0800
> > > @@ -33,19 +33,35 @@ static int walk_pmd_range(pud_t *pud, un
> > >  
> > >  	pmd = pmd_offset(pud, addr);
> > >  	do {
> > > +	again:
> > 
> > checkpatch will warn about the indent.
> > 
> > >  		next = pmd_addr_end(addr, end);
> > > -		split_huge_page_pmd(walk->mm, pmd);
> > > -		if (pmd_none_or_clear_bad(pmd)) {
> > > +		if (pmd_none(*pmd)) {
> > 
> > Not sure why this has been changed from pmd_none_or_clear_bad(), that's 
> > been done even prior to THP.
> 
> The bad check will trigger on huge pmds.  We can not use it here.  We
> can, however, use pmd_none().  The bad check was moved below to where we
> actually dereference the pmd.
> 

Ah, right, thanks.

> > >  			if (walk->pte_hole)
> > >  				err = walk->pte_hole(addr, next, walk);
> > >  			if (err)
> > >  				break;
> > >  			continue;
> > >  		}
> > > +		/*
> > > +		 * This implies that each ->pmd_entry() handler
> > > +		 * needs to know about pmd_trans_huge() pmds
> > > +		 */
> > 
> > Probably needs to be documented somewhere for users of pagewalk?
> 
> Probably, but we don't currently have any central documentation for it.
> Guess we could make some, or just ensure that all the users got updated.
> Any ideas where to put it other than the mm_walk struct?
> 

I think noting it where struct mm_walk is declared would be best (just a 
"/* must handle pmd_trans_huge() */" would be sufficient) although 
eventually it might be cleaner to add a ->pmd_huge_entry().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
