Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BDC9F6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:14:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u3so1951175pfl.5
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:14:46 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 5si1521656plx.33.2017.12.13.07.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 07:14:44 -0800 (PST)
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com>
Date: Wed, 13 Dec 2017 07:14:41 -0800
MIME-Version: 1.0
In-Reply-To: <20171213125739.fllckbl3o4nonmpx@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com

On 12/13/2017 04:57 AM, Kirill A. Shutemov wrote:
> Dave, what is effect of this on protection keys?

The goal was to make pkeys-protected userspace memory access
_consistent_ with normal access.  Specifically, we want a kernel to
disallow access (or writes) to memory where userspace mapping has a pkey
whose permissions are in conflict with the access.

For instance:

This will fault writing a byte to 'addr':

	char *addr = malloc(PAGE_SIZE);
	pkey_mprotect(addr, PAGE_SIZE, 13);
	pkey_deny_access(13);
	*addr[0] = 'f';

But this will write one byte to addr successfully (if it uses the kernel
mapping of the physical page backing 'addr'):

	char *addr = malloc(PAGE_SIZE);
	pkey_mprotect(addr, PAGE_SIZE, 13);
	pkey_deny_access(13);
	read(fd, addr, 1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
