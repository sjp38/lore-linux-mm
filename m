From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200009120234.TAA39381@google.engr.sgi.com>
Subject: Re: [PATCH] workaround for lost dirty bits on x86 SMP
Date: Mon, 11 Sep 2000 19:34:04 -0700 (PDT)
In-Reply-To: <Pine.LNX.3.96.1000911210010.7937B-100000@kanga.kvack.org> from "bcrl@redhat.com" at Sep 11, 2000 09:36:35 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bcrl@redhat.com
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> 
> On Mon, 11 Sep 2000, Kanoj Sarcar wrote:
> 
> > One of the worst races is in the page stealing path, when the stealer
> > thread checks whether the page is dirty, decides to pte_clear(), and
> > right then, the user dirties the pte, before the stealer thread has done
> > the flush_tlb. Are you trying to handle this situation?
> 
> That's the one.  It also crops up in msync, munmap and such.
> 
> > FWIW, previous notes/patches on this topic can be found at
> > 
> > 	http://reality.sgi.com/kanoj_engr/smppte.patch
> > 
> > and this also tries to handle the filemap cases. 
> 
> Right, that doesn't look so good -- it walks over the memory an extra pass
> or two, which is not good.

Not really, I thought I had it in a state where the bare minimum
was being done. Of course, this was the non-PAE version ...

> 
> > I _think_ that with your patch, the page fault rate would go up, so
> > it would be appropriate to generate some benchmark numbers.
> 
> Yes, the fault rate will go up, but only for clean-but-writable pages that
> are written to and only on SMP kernels.  We already do this on SPARC
> (which the _PAGE_W trick was modeled after) and MIPS, so the overhead
> should be reasonably low.  Note that we may wish to do this anyways to
> keep track of the number of pinned pages in the system.

Yes, this approach is mentioned in the web page, alongwith the 
types of apps that will see the greatest hit:

"Note that an alternate solution to the ia32 SMP pte race is to change 
PAGE_SHARED in include/asm-i386/pgtable.h to not drop in _PAGE_RW. On a 
write fault, mark the pte dirty, as well as drop in the _PAGE_RW bit into 
the pte. Basically, behave as if the processor does not have a hardware 
dirty bit, and adopt the same strategy as in the alpha/mips code. 
Disadvantage - take an extra fault on shm/file mmap'ed pages when a 
program accesses the page, *then* dirties it (no change if the first access 
is a write)."

> 
> > I would be willing to port the patch on the web page to 2.4, but 
> > thus far, my impression is that Linus is not happy with its
> > implementation ...
> 
> The alternative is to replace pte_clear on a clean but writable pte with
> an xchg to get the old pte value.  For non-threaded programs the
> locked bus cycles will slow things down for no real gain.  Another
> possibility is to implement real tlb shootdown.
> 
> Fwiw, with the patch, running a make -j bzImage on a 4 way box does not
> seem to have made a difference.  A patched run:
> 
> bcrl@toolbox linux-v2.4.0-test8]$ time make -j -s bzImage
> init.c:74: warning: `get_bad_pmd_table' defined but not used
> Root device is (8, 1)
> Boot sector 512 bytes.
> Setup is 4522 bytes.
> System is 873 kB
> 294.04user 23.81system 1:26.78elapsed 366%CPU (0avgtext+0avgdata
> 0maxresident)k
> 0inputs+0outputs (382013major+542948minor)pagefaults 0swaps
> [bcrl@toolbox linux-v2.4.0-test8]$ 
> 
> vs unpatched:
> 
> [bcrl@toolbox linux-v2.4.0-test8]$ time make -j -s bzImage
> init.c:74: warning: `get_bad_pmd_table' defined but not used
> Root device is (8, 1)
> Boot sector 512 bytes.
> Setup is 4522 bytes.
> System is 873 kB
> 294.19user 23.94system 1:26.88elapsed 366%CPU (0avgtext+0avgdata
> 0maxresident)k
> 0inputs+0outputs (382013major+542947minor)pagefaults 0swaps
> [bcrl@toolbox linux-v2.4.0-test8]$ 
> 
> So it's in the noise for this case (hot cache for both runs).  It probably
> makes a bigger difference for threaded programs in the presense of lots of
> msync/memory pressure, but the overhead in tlb shootdown on cleaning the

With the above type of apps, you do not need too high a _memory_ pressure
to trigger this, just compute pressure. Each time you come in to drop in
the "dirty" bit, you would need to do establish_pte(), which does a 
flush_tlb_page(), which gets costly when you have higher cpu counts. 

This of course depends on how smart flush_tlb_page is, and the processor
involved.

Kanoj

> dirty bit probably dwarfs the extra page fault, not to mention the actual
> io taking place.  There are other areas that need improving before
> write-faults on clean-writable pages make much of a difference.
> 
> 		-ben
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
