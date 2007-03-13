Date: Tue, 13 Mar 2007 02:19:04 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070313011904.GA2746@wotan.suse.de>
References: <20070221023735.6306.83373.sendpatchset@linux.site> <20070307094947.GE8609@wotan.suse.de> <20070307100242.GG8609@wotan.suse.de> <200703130001.13467.blaisorblade@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200703130001.13467.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Bill Irwin <bill.irwin@oracle.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 13, 2007 at 12:01:13AM +0100, Blaisorblade wrote:
> On Wednesday 07 March 2007 11:02, Nick Piggin wrote:
> > >
> > > Yeah, tmpfs/shm segs are what I was thinking about. If UML can live with
> > > that as well, then I think it might be a good option.
> >
> > Oh, hmm.... if you can truncate these things then you still need to
> > force unmap so you still need i_mmap_nonlinear.
> 
> Well, we don't need truncate(), but MADV_REMOVE for memory hotunplug, which is 
> way similar I guess.
> 
> About the restriction to tmpfs, I have just discovered 
> '[PATCH] mm: tracking shared dirty pages' (commit 
> d08b3851da41d0ee60851f2c75b118e1f7a5fc89), which already partially conflicts 
> with remap_file_pages for file-based mmaps (and that's fully fine, for now).
> 
> Even if UML does not need it, till now if there is a VMA protection and a page 
> hasn't been remapped with remap_file_pages, the VMA protection is used (just 
> because it makes sense).
> 
> However, it is only used when the PTE is first created - we can never change 
> protections on a VMA  - so it vma_wants_writenotify() is true (on all 
> file-based and on no shmfs based mapping, right?), and we write-protect the 
> VMA, it will always be write-protected.

Yes, I believe that is the case, however I wonder if that is going to be
a problem for you to distinguish between write faults for clean writable
ptes, and write faults for readonly ptes?

> That's no problem for UML, but for any other user (I guess I'll have to 
> prevent callers from trying such stuff - I started from a pretty generic 
> patch).
> 
> > But come to think of it, I still don't think nonlinear mappings are
> > too bad as they are ;)
> 
> Btw, I really like removing ->populate and merging the common code together. 
> filemap_populate and shmem_populate are so obnoxiously different that I 
> already wanted to do that (after merging remap_file_pages() core).

Yeah they are also frustratingly similar to filemap_nopage and shmem_nopage,
and duplicate a lot of the same code ;)

> Also, I'm curious. Since my patches are already changing remap_file_pages() 
> code, should they be absolutely merged after yours?

Is there a big clash? I don't think I did a great deal to fremap.c (mainly
just removing stuff)...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
