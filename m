Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A56C6B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 05:37:46 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id n71so20997iod.0
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 02:37:46 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n186si2077897itd.52.2017.08.28.02.37.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 02:37:44 -0700 (PDT)
Date: Mon, 28 Aug 2017 11:37:27 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
Message-ID: <20170828093727.5wldedputadanssh@hirez.programming.kicks-ass.net>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Sun, Aug 27, 2017 at 03:18:23AM +0300, Kirill A. Shutemov wrote:
> On Fri, Aug 18, 2017 at 12:05:13AM +0200, Laurent Dufour wrote:
> > +	/*
> > +	 * Can't call vm_ops service has we don't know what they would do
> > +	 * with the VMA.
> > +	 * This include huge page from hugetlbfs.
> > +	 */
> > +	if (vma->vm_ops)
> > +		goto unlock;
> 
> I think we need to have a way to white-list safe ->vm_ops.

Either that, or simply teach all ->fault() callbacks about speculative
faults. Shouldn't be too hard, just 'work'.

> > +
> > +	if (unlikely(!vma->anon_vma))
> > +		goto unlock;
> 
> It deserves a comment.

Yes, that was very much not intended. It wrecks most of the fun. This
really _should_ work for file maps too.

> > +	/*
> > +	 * Do a speculative lookup of the PTE entry.
> > +	 */
> > +	local_irq_disable();
> > +	pgd = pgd_offset(mm, address);
> > +	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
> > +		goto out_walk;
> > +
> > +	p4d = p4d_alloc(mm, pgd, address);
> > +	if (p4d_none(*p4d) || unlikely(p4d_bad(*p4d)))
> > +		goto out_walk;
> > +
> > +	pud = pud_alloc(mm, p4d, address);
> > +	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> > +		goto out_walk;
> > +
> > +	pmd = pmd_offset(pud, address);
> > +	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
> > +		goto out_walk;
> > +
> > +	/*
> > +	 * The above does not allocate/instantiate page-tables because doing so
> > +	 * would lead to the possibility of instantiating page-tables after
> > +	 * free_pgtables() -- and consequently leaking them.
> > +	 *
> > +	 * The result is that we take at least one !speculative fault per PMD
> > +	 * in order to instantiate it.
> > +	 */
> 
> 
> Doing all this job and just give up because we cannot allocate page tables
> looks very wasteful to me.
> 
> Have you considered to look how we can hand over from speculative to
> non-speculative path without starting from scratch (when possible)?

So we _can_ in fact allocate and install page-tables, but we have to be
very careful about it. The interesting case is where we race with
free_pgtables() and install a page that was just taken out.

But since we already have the VMA I think we can do something like:

	if (p*g_none()) {
		p*d_t *new = p*d_alloc_one(mm, address);

		spin_lock(&mm->page_table_lock);
		if (!vma_changed_or_dead(vma,seq)) {
			if (p*d_none())
				p*d_populate(mm, p*d, new);
			else
				p*d_free(new);

			new = NULL;
		}
		spin_unlock(&mm->page_table_lock);

		if (new) {
			p*d_free(new);
			goto out_walk;
		}
	}

I just never bothered with that, figured we ought to get the basics
working before trying to be clever.

> > +	/* Transparent huge pages are not supported. */
> > +	if (unlikely(pmd_trans_huge(*pmd)))
> > +		goto out_walk;
> 
> That's looks like a blocker to me.
> 
> Is there any problem with making it supported (besides plain coding)?

Not that I can remember, but I never really looked at THP, I don't think
we even had that when I did the first versions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
