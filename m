Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAB28E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 05:37:32 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y35so1791319edb.5
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 02:37:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si1227690eda.325.2018.12.07.02.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 02:37:30 -0800 (PST)
Date: Fri, 7 Dec 2018 11:37:28 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/4] filemap: kill page_cache_read usage in filemap_fault
Message-ID: <20181207103728.GD13008@quack2.suse.cz>
References: <20181130195812.19536-1-josef@toxicpanda.com>
 <20181130195812.19536-3-josef@toxicpanda.com>
 <20181207095750.GC13008@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181207095750.GC13008@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Fri 07-12-18 10:57:50, Jan Kara wrote:
> On Fri 30-11-18 14:58:10, Josef Bacik wrote:
> > If we do not have a page at filemap_fault time we'll do this weird
> > forced page_cache_read thing to populate the page, and then drop it
> > again and loop around and find it.  This makes for 2 ways we can read a
> > page in filemap_fault, and it's not really needed.  Instead add a
> > FGP_FOR_MMAP flag so that pagecache_get_page() will return a unlocked
> > page that's in pagecache.  Then use the normal page locking and readpage
> > logic already in filemap_fault.  This simplifies the no page in page
> > cache case significantly.
> > 
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> 
> Thanks for the patch. I like the simplification but I think it could be
> even improved... see below.
> 
> > @@ -2449,9 +2426,11 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
> >  		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
> >  		ret = VM_FAULT_MAJOR;
> >  retry_find:
> > -		page = find_get_page(mapping, offset);
> > +		page = pagecache_get_page(mapping, offset,
> > +					  FGP_CREAT|FGP_FOR_MMAP,
> > +					  vmf->gfp_mask);
> >  		if (!page)
> > -			goto no_cached_page;
> > +			return vmf_error(-ENOMEM);
> 
> So why don't you just do:
> 
> 		page = pagecache_get_page(mapping, offset,
> 					  FGP_CREAT | FGP_LOCK, vmf->gfp_mask);
> 		if (!page)
> 			return vmf_error(-ENOMEM);
> 		goto check_uptodate;
> 
> where check_uptodate would be a label before 'PageUptodate' check?
> 
> Then you don't have to introduce new flag for pagecache_get_page() and you
> also don't have to unlock and then lock again the page... And you can still
> delete all the code you've deleted.

Ah, you don't want lock_page() to block in case someone raced with you and
instantiated the page so that you can drop mmap_sem. OK, the patch looks
good to me then. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
