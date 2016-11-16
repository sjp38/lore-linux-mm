Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 140DA6B0261
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 08:34:26 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so24779441wmu.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 05:34:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wg6si33287119wjb.146.2016.11.16.05.34.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Nov 2016 05:34:24 -0800 (PST)
Date: Wed, 16 Nov 2016 14:34:22 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 13/21] mm: Pass vm_fault structure into do_page_mkwrite()
Message-ID: <20161116133422.GL21785@quack2.suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-14-git-send-email-jack@suse.cz>
 <20161115224023.GM23021@node>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161115224023.GM23021@node>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 16-11-16 01:40:23, Kirill A. Shutemov wrote:
> On Fri, Nov 04, 2016 at 05:25:09AM +0100, Jan Kara wrote:
> > We will need more information in the ->page_mkwrite() helper for DAX to
> > be able to fully finish faults there. Pass vm_fault structure to
> > do_page_mkwrite() and use it there so that information propagates
> > properly from upper layers.
> > 
> > Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  mm/memory.c | 19 +++++++------------
> >  1 file changed, 7 insertions(+), 12 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 4da66c984c2c..c89f99c270bc 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2038,20 +2038,14 @@ static gfp_t __get_fault_gfp_mask(struct vm_area_struct *vma)
> >   *
> >   * We do this without the lock held, so that it can sleep if it needs to.
> >   */
> > -static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
> > -	       unsigned long address)
> > +static int do_page_mkwrite(struct vm_fault *vmf)
> >  {
> > -	struct vm_fault vmf;
> >  	int ret;
> > +	struct page *page = vmf->page;
> >  
> > -	vmf.address = address;
> > -	vmf.pgoff = page->index;
> > -	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
> > -	vmf.gfp_mask = __get_fault_gfp_mask(vma);
> > -	vmf.page = page;
> > -	vmf.cow_page = NULL;
> > +	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
> 
> This can be destructive: we loose rest of the flags here. It's probably
> okay in current state of the code, but may be should restore them before
> return from do_page_mkwrite()?

Yeah, probably makes sense as future-proofing. Changed.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
