Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2DEC6B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 04:34:06 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n71so20413855iod.0
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 01:34:06 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q63si2139018iof.355.2017.08.29.01.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 01:34:05 -0700 (PDT)
Date: Tue, 29 Aug 2017 10:33:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
Message-ID: <20170829083352.qrsxvk3lkiydi3o2@hirez.programming.kicks-ass.net>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
 <20170828093727.5wldedputadanssh@hirez.programming.kicks-ass.net>
 <1503954877.4850.19.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503954877.4850.19.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, Aug 29, 2017 at 07:14:37AM +1000, Benjamin Herrenschmidt wrote:
> On Mon, 2017-08-28 at 11:37 +0200, Peter Zijlstra wrote:
> > > Doing all this job and just give up because we cannot allocate page tables
> > > looks very wasteful to me.
> > > 
> > > Have you considered to look how we can hand over from speculative to
> > > non-speculative path without starting from scratch (when possible)?
> > 
> > So we _can_ in fact allocate and install page-tables, but we have to be
> > very careful about it. The interesting case is where we race with
> > free_pgtables() and install a page that was just taken out.
> > 
> > But since we already have the VMA I think we can do something like:
> 
> That makes me extremely nervous... there could be all sort of
> assumptions esp. in arch code about the fact that we never populate the
> tree without the mm sem.

That _would_ be somewhat dodgy, because that means it needs to rely on
taking mmap_sem for _writing_ to undo things and arch/powerpc/ doesn't
have many down_write.*mmap_sem:

$ git grep "down_write.*mmap_sem" arch/powerpc/
arch/powerpc/kernel/vdso.c:     if (down_write_killable(&mm->mmap_sem))
arch/powerpc/kvm/book3s_64_vio.c:       down_write(&current->mm->mmap_sem);
arch/powerpc/mm/mmu_context_iommu.c:    down_write(&mm->mmap_sem);
arch/powerpc/mm/subpage-prot.c: down_write(&mm->mmap_sem);
arch/powerpc/mm/subpage-prot.c: down_write(&mm->mmap_sem);
arch/powerpc/mm/subpage-prot.c:         down_write(&mm->mmap_sem);

Then again, I suppose it could be relying on the implicit down_write
from things like munmap() and the like..

And things _ought_ to be ordered by the various PTLs
(mm->page_table_lock and pmd->lock) which of course doesn't mean
something accidentally snuck through.

> We'd have to audit archs closely. Things like the page walk cache
> flushing on power etc...

If you point me where to look, I'll have a poke around. I'm not
quite sure what you mean with pagewalk cache flushing. Your hash thing
flushes everything inside the PTL IIRC and the radix code appears fairly
'normal'.

> I don't mind the "retry" .. .we've brought stuff in the L1 cache
> already which I would expect to be the bulk of the overhead, and the
> allocation case isn't that common. Do we have numbers to show how
> destrimental this is today ?

No numbers, afaik. And like I said, I didn't consider this an actual
problem when I did these patches. But since Kirill asked ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
