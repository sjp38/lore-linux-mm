Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 125216B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 01:42:01 -0400 (EDT)
Received: by iajr24 with SMTP id r24so9295235iaj.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 22:42:00 -0700 (PDT)
Date: Mon, 9 Apr 2012 22:41:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] thp, memcg: split hugepage for memcg oom on cow
In-Reply-To: <4F838385.9070309@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1204092241180.27689@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com> <4F838385.9070309@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Tue, 10 Apr 2012, KAMEZAWA Hiroyuki wrote:

> > @@ -3502,13 +3503,24 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  							  pmd, flags);
> >  	} else {
> >  		pmd_t orig_pmd = *pmd;
> > +		int ret;
> > +
> >  		barrier();
> >  		if (pmd_trans_huge(orig_pmd)) {
> >  			if (flags & FAULT_FLAG_WRITE &&
> >  			    !pmd_write(orig_pmd) &&
> > -			    !pmd_trans_splitting(orig_pmd))
> > -				return do_huge_pmd_wp_page(mm, vma, address,
> > -							   pmd, orig_pmd);
> > +			    !pmd_trans_splitting(orig_pmd)) {
> > +				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
> > +							  orig_pmd);
> > +				/*
> > +				 * If COW results in an oom memcg, the huge pmd
> > +				 * will already have been split, so retry the
> > +				 * fault on the pte for a smaller charge.
> > +				 */
> 
> 
> IIUC, do_huge_pmd_wp_page_fallback() can return VM_FAULT_OOM. So, this check
> is not related only to memcg.
> 

You're right, and if we do that then we infinitely loop trying to handle 
the pagefault instead of returning.  I'll post a v2 of the patch that 
fixes this, thanks for catching it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
