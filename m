Date: Fri, 4 Aug 2000 18:52:16 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200008050152.SAA89298@apollo.backplane.com>
Subject: Re: RFC: design for new VM
References: <Pine.LNX.4.10.10008041655420.11340-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Chris Wedgwood <cw@f00f.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

:I agree that from a page table standpoint you should be correct. 
:
:I don't think that the other issues are as easily resolved, though.
:Especially with address space ID's on other architectures it can get
:_really_ interesting to do TLB invalidates correctly to other CPU's etc
:(you need to keep track of who shares parts of your page tables etc).
:
:...
:>     mismatch, such as call mprotect(), the shared page table would be split.
:
:Right. But what about the TLB?

    I'm not advocating trying to share TLB entries, that would be 
    a disaster.  I'm contemplating just the physical page table structure.
    e.g. if you mmap() a 1GB file shared (or private read-only) into 300
    independant processes, it should be possible to share all the meta-data
    required to support that mapping except for the TLB entries themselves.
    ASNs shouldn't make a difference... presumably the tags on the TLB
    entries are added on after the metadata lookup.  I'm also not advocating
    attempting to share intermediate 'partial' in-memory TLB caches (hash
    tables or other structures).  Those are typically fixed in size,
    per-cpu, and would not be impacted by scale.

:You have to have some page table locking mechanism for SMP eventually: I
:think you miss some of the problems because the current FreeBSD SMP stuff
:is mostly still "big kernel lock" (outdated info?), and you'll end up
:kicking yourself in a big way when you have the 300 processes sharing the
:same lock for that region..

    If it were a long-held lock I'd worry, but if it's a lock on a pte
    I don't think it can hurt.  After all, even with separate page tables
    if 300 processes fault on the same backing file offset you are going
    to hit a bottleneck with MP locking anyway, just at a deeper level
    (the filesystem rather then the VM system).  The BSDI folks did a lot
    of testing with their fine-grained MP implementation and found that
    putting a global lock around the entire VM system had absolutely no 
    impact on MP performance.

:>     (Linux falls on its face for other reasons, mainly the fact that it
:>     maps all of physical memory into KVM in order to manage it).
:
:Not true any more.. Trying to map 64GB of RAM convinced us otherwise ;)

    Oh, that's cool!  I don't think anyone in FreeBSDland has bothered with
    large-memory (> 4GB) memory configurations, there doesn't seem to be 
    much demand for such a thing on IA32.

:>     I think the loss of MP locking for this situation is outweighed by the
:>     benefit of a huge reduction in page faults -- rather then see 300 
:>     processes each take a page fault on the same page, only the first process
:>     would and the pte would already be in place when the others got to it.
:>     When it comes right down to it, page faults on shared data sets are not
:>     really an issue for MP scaleability.
:
:I think you'll find that there are all these small details that just
:cannot be solved cleanly. Do you want to be stuck with a x86-only
:solution?
:
:That said, I cannot honestly say that I have tried very hard to come up
:with solutions. I just have this feeling that it's a dark ugly hole that I
:wouldn't want to go down..
:
:			Linus

    Well, I don't think this is x86-specific.  Or, that is, I don't think it
    would pollute the machine-independant code.  FreeBSD has virtually no
    notion of 'page tables' outside the i386-specific VM files... it doesn't
    use page tables (or two-level page-like tables... is Linux still using
    those?) to store meta information at all in the higher levels of the
    kernel.  It uses architecture-independant VM objects and vm_map_entry
    structures for that.  Physical page tables on FreeBSD are 
    throw-away-at-any-time entities.  The actual implementation of the
    'page table' in the IA32 sense occurs entirely in the machine-dependant
    subdirectory for IA32.  

    A page-table sharing mechanism would have to implement the knowledge --
    the 'potential' for sharing at a higher level (the vm_map_entry 
    structure), but it would be up to the machine-dependant VM code to
    implement any actual sharing given that knowledge.  So while the specific
    implementation for IA32 is definitely machine-specific, it would have
    no effect on other OS ports (of course, we have only one other
    working port at the moment, to the alpha, but you get the idea).

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
