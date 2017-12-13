Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB4A46B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:32:22 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id o124so2466841ioo.20
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:32:22 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d142si1358078ioe.265.2017.12.13.07.32.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 07:32:21 -0800 (PST)
Date: Wed, 13 Dec 2017 16:32:02 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Message-ID: <20171213153202.qtxnloxoc66lhsbf@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name>
 <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com

On Wed, Dec 13, 2017 at 07:14:41AM -0800, Dave Hansen wrote:
> On 12/13/2017 04:57 AM, Kirill A. Shutemov wrote:
> > Dave, what is effect of this on protection keys?
> 
> The goal was to make pkeys-protected userspace memory access
> _consistent_ with normal access.  Specifically, we want a kernel to
> disallow access (or writes) to memory where userspace mapping has a pkey
> whose permissions are in conflict with the access.
> 
> For instance:
> 
> This will fault writing a byte to 'addr':
> 
> 	char *addr = malloc(PAGE_SIZE);
> 	pkey_mprotect(addr, PAGE_SIZE, 13);
> 	pkey_deny_access(13);
> 	*addr[0] = 'f';
> 
> But this will write one byte to addr successfully (if it uses the kernel
> mapping of the physical page backing 'addr'):
> 
> 	char *addr = malloc(PAGE_SIZE);
> 	pkey_mprotect(addr, PAGE_SIZE, 13);
> 	pkey_deny_access(13);
> 	read(fd, addr, 1);
> 

This seems confused to me; why are these two cases different?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
