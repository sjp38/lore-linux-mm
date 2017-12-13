Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B08B6B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:57:43 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so1168335wmd.0
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:57:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v21sor1195764edb.5.2017.12.13.04.57.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 04:57:41 -0800 (PST)
Date: Wed, 13 Dec 2017 15:57:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Message-ID: <20171213125739.fllckbl3o4nonmpx@node.shutemov.name>
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com

On Wed, Dec 13, 2017 at 01:22:11PM +0100, Peter Zijlstra wrote:
> On Tue, Dec 12, 2017 at 10:00:08AM -0800, Andy Lutomirski wrote:
> > On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > > From: Peter Zijstra <peterz@infradead.org>
> > >
> > > In order to create VMAs that are not accessible to userspace create a new
> > > VM_NOUSER flag. This can be used in conjunction with
> > > install_special_mapping() to inject 'kernel' data into the userspace map.
> > >
> > > Similar to how arch_vm_get_page_prot() allows adding _PAGE_flags to
> > > pgprot_t, introduce arch_vm_get_page_prot_excl() which masks
> > > _PAGE_flags from pgprot_t and use this to implement VM_NOUSER for x86.
> > 
> > How does this interact with get_user_pages(), etc?
> 
> So I went through that code and I think I found a bug related to this.
> 
> get_user_pages_fast() will ultimately end up doing
> pte_access_permitted() before getting the page, follow_page OTOH does
> not do this, which makes for a curious difference between the two.
> 
> So I'm thinking we want the below irrespective of the VM_NOUSER patch,
> but with VM_NOUSER it would mean write(2) will no longer be able to
> access the page.

Oh..

We do call pte_access_permitted(), but only for write access.
See can_follow_write_pte().

The issue seems bigger: we also need such calls for other page table levels :-/

Dave, what is effect of this on protection keys?

> 
> diff --git a/mm/gup.c b/mm/gup.c
> index dfcde13f289a..b852f37a2b0c 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -153,6 +153,11 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
>  	}
>  
>  	if (flags & FOLL_GET) {
> +		if (!pte_access_permitted(pte, !!(flags & FOLL_WRITE))) {
> +			page = ERR_PTR(-EFAULT);
> +			goto out;
> +		}
> +
>  		get_page(page);
>  
>  		/* drop the pgmap reference now that we hold the page */
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
