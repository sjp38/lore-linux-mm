Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B57B26B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 17:13:15 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id f185so4572686itc.2
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 14:13:15 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z125si2134342itf.107.2017.12.13.14.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 14:13:14 -0800 (PST)
Date: Wed, 13 Dec 2017 23:12:33 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Message-ID: <20171213221233.GC3326@worktop>
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <20171213215022.GA27778@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213215022.GA27778@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

On Wed, Dec 13, 2017 at 01:50:22PM -0800, Matthew Wilcox wrote:
> On Tue, Dec 12, 2017 at 06:32:26PM +0100, Thomas Gleixner wrote:
> > From: Peter Zijstra <peterz@infradead.org>
> > 
> > In order to create VMAs that are not accessible to userspace create a new
> > VM_NOUSER flag. This can be used in conjunction with
> > install_special_mapping() to inject 'kernel' data into the userspace map.
> 
> Maybe I misunderstand the intent behind this, but I was recently looking
> at something kind of similar.  I was calling it VM_NOTLB and it wouldn't
> put TLB entries into the userspace map at all.  The idea was to be able
> to use the user address purely as a handle for specific kernel pages,
> which were guaranteed to never be mapped into userspace, so we didn't
> need to send TLB invalidations when we took those pages away from the user
> process again.  But we'd be able to pass the address to read() or write().
> 
> So I was going to check the VMA flags in no_page_table() and return the
> struct page that was notmapped there.  I didn't get as far as constructing
> a prototype yet, and I'm not entirely sure I understand the purpose of
> this patch, so perhaps there's no synergy here at all (and perhaps my
> idea wouldn't have worked anyway).

Yeah, completely different. This here actually needs the page table
entries. Currently we keep the LDT in kernel memory, but with PTI we
loose the entire kernel map.

Since the LDT is strictly per process, the idea was to actually inject
it into the userspace map. Except of course, userspace must not actually
be able to access it. So by mapping it !_PAGE_USER its 'invisible'.

But the CPU very much needs the mapping, it will load the LDT entries
through them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
