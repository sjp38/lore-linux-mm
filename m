Date: Mon, 07 Jul 2008 19:24:06 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] Make CONFIG_MIGRATION available for s390
In-Reply-To: <20080707090635.GA6797@shadowen.org>
References: <1215354957.9842.19.camel@localhost.localdomain> <20080707090635.GA6797@shadowen.org>
Message-Id: <20080707185433.5A5D.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> > Index: linux-2.6/include/linux/migrate.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/migrate.h
> > +++ linux-2.6/include/linux/migrate.h
> > @@ -13,6 +13,7 @@ static inline int vma_migratable(struct 
> >  {
> >  	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
> >  		return 0;
> > +#ifdef CONFIG_NUMA
> >  	/*
> >  	 * Migration allocates pages in the highest zone. If we cannot
> >  	 * do so then migration (at least from node to node) is not
> > @@ -22,6 +23,7 @@ static inline int vma_migratable(struct 
> >  		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
> >  								< policy_zone)
> >  			return 0;
> > +#endif
> 
> include/linux/mempolicy.h already has a !NUMA section could we not just
> define policy_zone as 0 in that and leave this code unconditionally
> compiled?  Perhaps also adding a NUMA_BUILD && to this 'if' should that
> be clearer.
> 
Ah, yes. It's better. :-)


> But this does make me feel uneasy.  Are we really saying all memory on
> an s390 is migratable.  That seems unlikely. As I understand the NUMA
> case, we only allow migration of memory in the last zone (last two if we
> have a MOVABLE zone) why are things different just because we have a
> single 'node'.  Hmmm.  I suspect strongly that something is missnamed
> more than there is a problem.

If my understanding is correct, even if this policy_zone check is removed,
page isolation will just fail due to some busy pages.
In hotplug case, it means giving up of hotremoving,
and kernel must be rollback to make same condition of previous
starting offline_pages().
This check means just "early" check, but not so effective for hotremoving,
I think....


Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
