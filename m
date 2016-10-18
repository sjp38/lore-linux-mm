Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35F6F280251
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:37:16 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n3so8605144lfn.5
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 03:37:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 75si1053790lfq.347.2016.10.18.03.37.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 03:37:14 -0700 (PDT)
Date: Tue, 18 Oct 2016 12:37:12 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 11/20] mm: Remove unnecessary vma->vm_ops check
Message-ID: <20161018103712.GP3359@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-12-git-send-email-jack@suse.cz>
 <20161017194041.GB21002@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161017194041.GB21002@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon 17-10-16 13:40:41, Ross Zwisler wrote:
> On Tue, Sep 27, 2016 at 06:08:15PM +0200, Jan Kara wrote:
> > We don't check whether vma->vm_ops is NULL in do_shared_fault() so
> > there's hardly any point in checking it in wp_page_shared() which gets
> > called only for shared file mappings as well.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  mm/memory.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index a4522e8999b2..63d9c1a54caf 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2301,7 +2301,7 @@ static int wp_page_shared(struct vm_fault *vmf, struct page *old_page)
> >  
> >  	get_page(old_page);
> >  
> > -	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
> > +	if (vma->vm_ops->page_mkwrite) {
> >  		int tmp;
> >  
> >  		pte_unmap_unlock(vmf->pte, vmf->ptl);
> > -- 
> > 2.6.6
> 
> Does this apply equally to the check in wp_pfn_shared()?  Both
> wp_page_shared() and wp_pfn_shared() are called for shared file mappings via
> do_wp_page().

Yes, it does apply there as well. Added to the commit. There are actually
more places with these checks which don't seem necessary but I didn't want
to do more cleanups than I need... But at least these two come logically
together.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
