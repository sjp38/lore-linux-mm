Date: Mon, 10 Apr 2000 16:12:18 -0700
Message-Id: <200004102312.QAA05115@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <20000410232149.M17648@redhat.com> (sct@redhat.com)
Subject: Re: zap_page_range(): TLB flush race
References: <200004082331.QAA78522@google.engr.sgi.com> <E12e4mo-0003Pn-00@the-village.bc.nu> <20000410232149.M17648@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sct@redhat.com
Cc: alan@lxorguk.ukuu.org.uk, kanoj@google.engr.sgi.com, manfreds@colorfullife.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

   On Sun, Apr 09, 2000 at 12:37:05AM +0100, Alan Cox wrote:
   > 
   > Basically establish_pte() has to be architecture specific, as some processors
   > need different orders either to avoid races or to handle cpu specific
   > limitations.

   What exactly do different architectures need which set_pte() doesn't 
   already allow them to do magic in?  

Doing a properly synchronized PTE update and Cache/TLB flush when the
mapping can exist on multiple processors is not most efficiently done
if we take some generic setup.

The idea is that if we encapsulate the "flush_cache; set_pte;
flush_tlb" operations into a single arch-specific routine, the
implementation can then implement the most efficient solution possible
to this SMP problem.

For example, the fastest way to atomically update an existing PTE on
an SMP system using a software TLB miss scheme is wildly different
from that on an SMP system using a hardware replaced TLB.

For example, with a software TLB miss scheme it might be something
like this:

	establish_pte() {
		capture_cpus(mm->cpu_vm_mask);
		everybody_flush_cache_page(mm->cpu_vm_mask, ...);
		atomic_set_pte(ptep, entry);
		everybody_flush_tlb_page(mm->cpu_vm_mask, ...);
		release_cpus(mm->cpu_vm_mask);
	}

With the obvious important optimizations for when mm->count is one,
etc.

The other case is when we are checking the dirty status of a pte
in vmscan, something similar is needed there as well:

	pte_t atomic_pte_check_dirty() {
		capture_cpus(mm->cpu_vm_mask);
		entry = *ptep;
		if (pte_dirty(entry)) {
			everybody_flush_cache_page(mm->cpu_vm_mask, ...);
			pte_clear(ptep);
			everybody_flush_tlb_page(mm->cpu_vm_mask, ...);
		}
		release_cpus(mm->cpu_vm_mask);
		return entry;
	}

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
