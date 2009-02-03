Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B18A05F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 20:58:04 -0500 (EST)
Received: by rv-out-0708.google.com with SMTP id f25so1669962rvb.26
        for <linux-mm@kvack.org>; Mon, 02 Feb 2009 17:58:03 -0800 (PST)
Date: Tue, 3 Feb 2009 10:57:44 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] fix mlocked page counter mismatch
Message-ID: <20090203015744.GA16179@barrios-desktop>
References: <20090202061622.GA13286@barrios-desktop> <1233594995.17895.144.camel@lts-notebook> <20090202232719.GC13532@barrios-desktop> <1233625686.17895.219.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1233625686.17895.219.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > Thank you for testing. 
> 
> I did test this on 29-rc3 on a 4 socket x dual core x86_64 platform and
> it seems to resolve the statistics miscount.  How do you want to
> proceed.  Do you want to repost with this version of patch?  Or shall I?

I will repost this patch with your ACK and tested-by if you allow it. 

> 
> Regards,
> Lee
> 
> > > 
> > > 
> > > Index: linux-2.6.29-rc3/mm/rmap.c
> > > ===================================================================
> > > --- linux-2.6.29-rc3.orig/mm/rmap.c	2009-01-30 14:13:56.000000000 -0500
> > > +++ linux-2.6.29-rc3/mm/rmap.c	2009-02-02 11:27:11.000000000 -0500
> > > @@ -1072,7 +1072,8 @@ static int try_to_unmap_file(struct page
> > >  	spin_lock(&mapping->i_mmap_lock);
> > >  	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
> > >  		if (MLOCK_PAGES && unlikely(unlock)) {
> > > -			if (!(vma->vm_flags & VM_LOCKED))
> > > +			if (!((vma->vm_flags & VM_LOCKED) &&
> > > +			      page_mapped_in_vma(page, vma)))
> > >  				continue;	/* must visit all vmas */
> > >  			ret = SWAP_MLOCK;
> > >  		} else {
> > > 
> > 

-- 
Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
