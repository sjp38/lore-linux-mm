Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8741D6B026E
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:10:41 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id y49-v6so16786081oti.11
        for <linux-mm@kvack.org>; Wed, 23 May 2018 11:10:41 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w20-v6si6385635oie.43.2018.05.23.11.10.40
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 11:10:40 -0700 (PDT)
Date: Wed, 23 May 2018 19:10:06 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <20180523181004.txe4x6rx52wtcvjx@lakrids.cambridge.arm.com>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <010001637399f796-3ffe3ed2-2fb1-4d43-84f0-6a65b6320d66-000000@email.amazonses.com>
 <5aea6aa0-88cc-be7a-7012-7845499ced2c@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5aea6aa0-88cc-be7a-7012-7845499ced2c@netapp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boazh@netapp.com>
Cc: Christopher Lameter <cl@linux.com>, Jeff Moyer <jmoyer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Tue, May 22, 2018 at 07:05:48PM +0300, Boaz Harrosh wrote:
> On 18/05/18 17:14, Christopher Lameter wrote:
> > On Tue, 15 May 2018, Boaz Harrosh wrote:
> > 
> >>> I don't think page tables work the way you think they work.
> >>>
> >>> +               err = vm_insert_pfn_prot(zt->vma, zt_addr, pfn, prot);
> >>>
> >>> That doesn't just insert it into the local CPU's page table.  Any CPU
> >>> which directly accesses or even prefetches that address will also get
> >>> the translation into its cache.
> >>>
> >>
> >> Yes I know, but that is exactly the point of this flag. I know that this
> >> address is only ever accessed from a single core. Because it is an mmap (vma)
> >> of an O_TMPFILE-exclusive file created in a core-pinned thread and I allow
> >> only that thread any kind of access to this vma. Both the filehandle and the
> >> mmaped pointer are kept on the thread stack and have no access from outside.
> >>
> >> So the all point of this flag is the kernel driver telling mm that this
> >> address is enforced to only be accessed from one core-pinned thread.
> > 
> > But there are no provisions for probhiting accesses from other cores?
> > 
> > This means that a casual accidental write from a thread executing on
> > another core can lead to arbitrary memory corruption because the cache
> > flushing has been bypassed.
> 
> No this is not accurate. A "casual accidental write" will not do any harm.
> Only a well concerted malicious server can exploit this. A different thread
> on a different core will need to hit the exact time to read from the exact
> pointer at the narrow window while the IO is going on. fault-in a TLB at the
> time of the valid mapping.

TLB entries can be allocated at any time, for any reason. Even if a
program doesn't explicitly read from the exact pointer at that time, it
doesn't guarantee that a TLB entry won't be allocated.

> Then later after the IO has ended and before any
> of the threads where scheduled out, maliciously write. 

... or, regardless of the application's wishes, the core mm code decides
it needs to swap this page out (only doing local TLB invalidation), and
later pages it back in.

Several things can happen, e.g.

* a casual write can corrupt the original page, which is now in use for
  something else.

* a CPU might re-allocate a TLB entry for that page, finding it
  conflicts with an existing entry. This is *fatal* on some
  architectures.

> All the while the App has freed its buffers and the buffer was used
> for something else.  Please bear in mind that this is only As root, in
> an /sbin/ executable signed by the Kernel's key.

That isn't enforced by the core API additions, and regardless, root does
not necessarily imply access to kernel-internal stuff (e.g. if the
lockdown stuff goes in).

Claiming that root access means we don't need to care about robustness
is not a good argument.

[...]

> So lets start from the Beginning.
> 
> How can we implement "Private memory"?

Use separate processes rather than threads. Each will have a separate
mm, so the arch can get away with local TLB invalidation.

If you wish to share portions of memory between these processes, we have
shared memory APIs to do so.

Thanks,
Mark.
