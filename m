Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 650A46B000D
	for <linux-mm@kvack.org>; Mon, 14 May 2018 20:41:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e20-v6so11716102pff.14
        for <linux-mm@kvack.org>; Mon, 14 May 2018 17:41:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p7-v6si8361481pgd.96.2018.05.14.17.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 14 May 2018 17:41:42 -0700 (PDT)
Date: Mon, 14 May 2018 17:41:37 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <20180515004137.GA5168@bombadil.infradead.org>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boazh@netapp.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Mon, May 14, 2018 at 10:37:38PM +0300, Boaz Harrosh wrote:
> On 14/05/18 22:15, Matthew Wilcox wrote:
> > On Mon, May 14, 2018 at 08:28:01PM +0300, Boaz Harrosh wrote:
> >> On a call to mmap an mmap provider (like an FS) can put
> >> this flag on vma->vm_flags.
> >>
> >> The VM_LOCAL_CPU flag tells the Kernel that the vma will be used
> >> from a single-core only, and therefore invalidation (flush_tlb) of
> >> PTE(s) need not be a wide CPU scheduling.
> > 
> > I still don't get this.  You're opening the kernel up to being exploited
> > by any application which can persuade it to set this flag on a VMA.
> > 
> 
> No No this is not an application accessible flag this can only be set
> by the mmap implementor at ->mmap() time (Say same as VM_VM_MIXEDMAP).
> 
> Please see the zuf patches for usage (Again apologise for pushing before
> a user)
> 
> The mmap provider has all the facilities to know that this can not be
> abused, not even by a trusted Server.

I don't think page tables work the way you think they work.

+               err = vm_insert_pfn_prot(zt->vma, zt_addr, pfn, prot);

That doesn't just insert it into the local CPU's page table.  Any CPU
which directly accesses or even prefetches that address will also get
the translation into its cache.
