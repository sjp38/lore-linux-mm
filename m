From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Date: Sat, 17 Mar 2007 13:17:00 +0100
References: <20070221023735.6306.83373.sendpatchset@linux.site> <200703130001.13467.blaisorblade@yahoo.it> <20070313011904.GA2746@wotan.suse.de>
In-Reply-To: <20070313011904.GA2746@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703171317.01074.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Bill Irwin <bill.irwin@oracle.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 13 March 2007 02:19, Nick Piggin wrote:
> On Tue, Mar 13, 2007 at 12:01:13AM +0100, Blaisorblade wrote:
> > On Wednesday 07 March 2007 11:02, Nick Piggin wrote:
> > > > Yeah, tmpfs/shm segs are what I was thinking about. If UML can live
> > > > with that as well, then I think it might be a good option.
> > >
> > > Oh, hmm.... if you can truncate these things then you still need to
> > > force unmap so you still need i_mmap_nonlinear.
> >
> > Well, we don't need truncate(), but MADV_REMOVE for memory hotunplug,
> > which is way similar I guess.
> >
> > About the restriction to tmpfs, I have just discovered
> > '[PATCH] mm: tracking shared dirty pages' (commit
> > d08b3851da41d0ee60851f2c75b118e1f7a5fc89), which already partially
> > conflicts with remap_file_pages for file-based mmaps (and that's fully
> > fine, for now).
> >
> > Even if UML does not need it, till now if there is a VMA protection and a
> > page hasn't been remapped with remap_file_pages, the VMA protection is
> > used (just because it makes sense).
> >
> > However, it is only used when the PTE is first created - we can never
> > change protections on a VMA  - so it vma_wants_writenotify() is true (on
> > all file-based and on no shmfs based mapping, right?), and we
> > write-protect the VMA, it will always be write-protected.
>
> Yes, I believe that is the case, however I wonder if that is going to be
> a problem for you to distinguish between write faults for clean writable
> ptes, and write faults for readonly ptes?
I wouldn't be able to distinguish them, but am I going to get write faults for 
clean ptes when vma_wants_writenotify() is false (as seems to be for tmpfs)? 
I guess not.

For tmpfs pages, clean writable PTEs are mapped as writable so they won't give 
any problem, since vma_wants_writenotify() is false for tmpfs. Correct?

> > Also, I'm curious. Since my patches are already changing
> > remap_file_pages() code, should they be absolutely merged after yours?
>
> Is there a big clash? I don't think I did a great deal to fremap.c (mainly
> just removing stuff)...
Hopefully, we just both modify sys_remap_file_pages(), I'll see soon.
-- 
Inform me of my mistakes, so I can add them to my list!
Paolo Giarrusso, aka Blaisorblade
http://www.user-mode-linux.org/~blaisorblade
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
