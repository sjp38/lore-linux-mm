Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB866B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 06:35:20 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id qs7so92435071wjc.4
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 03:35:20 -0800 (PST)
Received: from mail-wj0-x242.google.com (mail-wj0-x242.google.com. [2a00:1450:400c:c01::242])
        by mx.google.com with ESMTPS id s20si4180674wrb.195.2017.01.11.03.35.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 03:35:17 -0800 (PST)
Received: by mail-wj0-x242.google.com with SMTP id ey1so11344946wjd.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 03:35:17 -0800 (PST)
Date: Wed, 11 Jan 2017 14:35:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Respect FOLL_FORCE/FOLL_COW for thp
Message-ID: <20170111113515.GB4895@node.shutemov.name>
References: <20170105053658.GA36383@juliacomputing.com>
 <20170105150558.GE17319@node.shutemov.name>
 <alpine.LSU.2.11.1701102112120.2361@eggly.anvils>
 <alpine.LSU.2.11.1701102300001.2996@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1701102300001.2996@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Keno Fischer <keno@juliacomputing.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, gthelen@google.com, npiggin@gmail.com, w@1wt.eu, oleg@redhat.com, keescook@chromium.org, luto@kernel.org, mhocko@suse.com, rientjes@google.com

On Tue, Jan 10, 2017 at 11:06:10PM -0800, Hugh Dickins wrote:
> On Tue, 10 Jan 2017, Hugh Dickins wrote:
> > On Thu, 5 Jan 2017, Kirill A. Shutemov wrote:
> > > On Thu, Jan 05, 2017 at 12:36:58AM -0500, Keno Fischer wrote:
> > > >  struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
> > > >  		pmd_t *pmd, int flags)
> > > >  {
> > > > @@ -783,7 +793,7 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
> > > >  
> > > >  	assert_spin_locked(pmd_lockptr(mm, pmd));
> > > >  
> > > > -	if (flags & FOLL_WRITE && !pmd_write(*pmd))
> > > > +	if (flags & FOLL_WRITE && !can_follow_write_pmd(*pmd, flags))
> > > >  		return NULL;
> > > 
> > > I don't think this part is needed: once we COW devmap PMD entry, we split
> > > it into PTE table, so IIUC we never get here with PMD.
> > 
> > Hi Kirill,
> > 
> > Would you mind double-checking that?  You certainly know devmap
> > better than me, but I feel safer with Keno's original as above.
> > 
> > I can see that fs/dax.c dax_iomap_pmd_fault() does
> > 
> > 	/* Fall back to PTEs if we're going to COW */
> > 	if (write && !(vma->vm_flags & VM_SHARED))
> > 		goto fallback;
> > 
> > But isn't there a case of O_RDWR fd, VM_SHARED PROT_READ mmap, and
> > FOLL_FORCE write to it, which does not COW (but relies on FOLL_COW)?
> 
> And now I think I'm wrong, but please double-check even so: I think that
> case gets ruled out by the !is_cow_mapping(vm_flags) check in mm/gup.c,
> where we used to have a WARN_ON_ONCE() for a while.

Right, !is_cow_mapping(vm_flags) will filter the case out.

Also there's no way we will get FOLL_COW set for file THP (dax or not): we
never return VM_FAULT_WRITE there.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
