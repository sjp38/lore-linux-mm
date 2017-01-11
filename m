Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA0DE6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 02:06:23 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 5so1278036423pgj.6
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 23:06:23 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id k25si4851808pfg.178.2017.01.10.23.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 23:06:22 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id y143so39229747pfb.0
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 23:06:22 -0800 (PST)
Date: Tue, 10 Jan 2017 23:06:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: Respect FOLL_FORCE/FOLL_COW for thp
In-Reply-To: <alpine.LSU.2.11.1701102112120.2361@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1701102300001.2996@eggly.anvils>
References: <20170105053658.GA36383@juliacomputing.com> <20170105150558.GE17319@node.shutemov.name> <alpine.LSU.2.11.1701102112120.2361@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Keno Fischer <keno@juliacomputing.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, gthelen@google.com, npiggin@gmail.com, w@1wt.eu, oleg@redhat.com, keescook@chromium.org, luto@kernel.org, mhocko@suse.com, rientjes@google.com, hughd@google.com

On Tue, 10 Jan 2017, Hugh Dickins wrote:
> On Thu, 5 Jan 2017, Kirill A. Shutemov wrote:
> > On Thu, Jan 05, 2017 at 12:36:58AM -0500, Keno Fischer wrote:
> > >  struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
> > >  		pmd_t *pmd, int flags)
> > >  {
> > > @@ -783,7 +793,7 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
> > >  
> > >  	assert_spin_locked(pmd_lockptr(mm, pmd));
> > >  
> > > -	if (flags & FOLL_WRITE && !pmd_write(*pmd))
> > > +	if (flags & FOLL_WRITE && !can_follow_write_pmd(*pmd, flags))
> > >  		return NULL;
> > 
> > I don't think this part is needed: once we COW devmap PMD entry, we split
> > it into PTE table, so IIUC we never get here with PMD.
> 
> Hi Kirill,
> 
> Would you mind double-checking that?  You certainly know devmap
> better than me, but I feel safer with Keno's original as above.
> 
> I can see that fs/dax.c dax_iomap_pmd_fault() does
> 
> 	/* Fall back to PTEs if we're going to COW */
> 	if (write && !(vma->vm_flags & VM_SHARED))
> 		goto fallback;
> 
> But isn't there a case of O_RDWR fd, VM_SHARED PROT_READ mmap, and
> FOLL_FORCE write to it, which does not COW (but relies on FOLL_COW)?

And now I think I'm wrong, but please double-check even so: I think that
case gets ruled out by the !is_cow_mapping(vm_flags) check in mm/gup.c,
where we used to have a WARN_ON_ONCE() for a while.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
