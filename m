Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B76AA6B0260
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:01:51 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v138so117059247qka.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 02:01:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qh8si40267712wjb.173.2016.10.17.02.01.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 02:01:50 -0700 (PDT)
Date: Mon, 17 Oct 2016 11:01:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 03/20] mm: Use pgoff in struct vm_fault instead of
 passing it separately
Message-ID: <20161017090149.GE3359@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-4-git-send-email-jack@suse.cz>
 <20161014184251.GB27575@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161014184251.GB27575@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri 14-10-16 12:42:51, Ross Zwisler wrote:
> On Tue, Sep 27, 2016 at 06:08:07PM +0200, Jan Kara wrote:
> > struct vm_fault has already pgoff entry. Use it instead of passing pgoff
> > as a separate argument and then assigning it later.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  mm/memory.c | 35 ++++++++++++++++++-----------------
> >  1 file changed, 18 insertions(+), 17 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 447a1ef4a9e3..4c2ec9a9d8af 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2275,7 +2275,7 @@ static int wp_pfn_shared(struct vm_fault *vmf, pte_t orig_pte)
> >  	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
> >  		struct vm_fault vmf2 = {
> >  			.page = NULL,
> > -			.pgoff = linear_page_index(vma, vmf->address),
> > +			.pgoff = vmf->pgoff,
> 
> I think there is one path where vmf->pgoff isn't set here.  Here's the path:
> 
> __collapse_huge_page_swapin()
>   do_swap_page()
>     do_wp_page()
>       wp_pfn_shared()
> 
> We then use an uninitialized vmf->pgoff to set up vmf2->pgoff, which we pass
> to vm_ops->pfn_mkwrite().
> 
> I think all we need to do to fix this is initialize .pgoff in
> __collapse_huge_page_swapin().  With this one change:
> 
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Thanks for catching this. I don't think that bug had any visible effect
since for anonymous pages (which is what do_swap_page() handles) we won't
enter wp_pfn_shared() but it is definitely good to fix this.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
