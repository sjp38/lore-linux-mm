Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8666B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 09:35:06 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id g33so1201567plb.13
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:35:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p64si1541752pfl.131.2017.12.13.06.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 06:35:05 -0800 (PST)
Date: Wed, 13 Dec 2017 15:34:55 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Message-ID: <20171213143455.oqigy6m53qhuu7k4@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213125739.fllckbl3o4nonmpx@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com

On Wed, Dec 13, 2017 at 03:57:40PM +0300, Kirill A. Shutemov wrote:
> On Wed, Dec 13, 2017 at 01:22:11PM +0100, Peter Zijlstra wrote:

> > get_user_pages_fast() will ultimately end up doing
> > pte_access_permitted() before getting the page, follow_page OTOH does
> > not do this, which makes for a curious difference between the two.
> > 
> > So I'm thinking we want the below irrespective of the VM_NOUSER patch,
> > but with VM_NOUSER it would mean write(2) will no longer be able to
> > access the page.
> 
> Oh..
> 
> We do call pte_access_permitted(), but only for write access.
> See can_follow_write_pte().

My can_follow_write_pte() looks like:

static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
{
	return pte_write(pte) ||
		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_dirty(pte));
}

am I perchance looking at the wrong tee?

> The issue seems bigger: we also need such calls for other page table levels :-/

Sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
