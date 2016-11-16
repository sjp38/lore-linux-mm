Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C84986B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 08:39:20 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so24977934wmw.0
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 05:39:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gg3si5398254wjb.268.2016.11.16.05.39.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Nov 2016 05:39:19 -0800 (PST)
Date: Wed, 16 Nov 2016 14:39:17 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 16/21] mm: Provide helper for finishing mkwrite faults
Message-ID: <20161116133917.GM21785@quack2.suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-17-git-send-email-jack@suse.cz>
 <20161115225210.GP23021@node>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161115225210.GP23021@node>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 16-11-16 01:52:10, Kirill A. Shutemov wrote:
> On Fri, Nov 04, 2016 at 05:25:12AM +0100, Jan Kara wrote:
> > Provide a helper function for finishing write faults due to PTE being
> > read-only. The helper will be used by DAX to avoid the need of
> > complicating generic MM code with DAX locking specifics.
> > 
> > Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Signed-off-by: Jan Kara <jack@suse.cz>
...
> > -		/*
> > -		 * Since we dropped the lock we need to revalidate
> > -		 * the PTE as someone else may have changed it.  If
> > -		 * they did, we just return, as we can count on the
> > -		 * MMU to tell us if they didn't also make it writable.
> > -		 */
> > -		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
> > -						vmf->address, &vmf->ptl);
> > -		if (!pte_same(*vmf->pte, vmf->orig_pte)) {
> > +		tmp = finish_mkwrite_fault(vmf);
> > +		if (unlikely(!tmp || (tmp &
> > +				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
> 
> Looks like the second part of condition is never true here, right? Not
> that it would matter, having the next patch in the queue.

Yeah, I had the condition like this to handle the standard set of return
values. And as you say, the next patch even makes this condition have a
real effect.

> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
