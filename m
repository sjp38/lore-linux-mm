Date: Tue, 19 Feb 2002 09:29:04 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <E16d1E8-00010D-00@starship.berlin>
Message-ID: <Pine.LNX.4.33.0202190923390.26476-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>


On Tue, 19 Feb 2002, Daniel Phillips wrote:
> >
> > At that point you might as well make the TLB shootdown global (ie you keep
> > track of a mask of CPU's whose TLB's you want to kill, and any pmd that
> > has count > 1 just makes that mask be "all CPU's").
>
> How do we know when to do the global tlb flush?

See above.

Basically, the algorithm is:

	invalidate_cpu_mask = 0;

	.. for each page swapped out ..

		pte = ptep_get_and_clear(ptep);
		save_pte_and_mm(pte_page(pte));
		mask = mm->cpu_vm_mask;
		if (page_count(pmd_page) > 1)
			mask = ~0UL;
		invalidate_cpu_mask |= mask;

and then at the end you just do

	flush_tlb_cpus(invalidate_cpu_mask);
	for_each_page_saved() {
		free_page(page);
	}

(yeah, yeah, add cache coherency etc).

		Linus


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
