Date: Tue, 20 Mar 2007 07:00:17 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070320060017.GA21978@wotan.suse.de>
References: <20070221023735.6306.83373.sendpatchset@linux.site> <200703171317.01074.blaisorblade@yahoo.it> <20070318025010.GA1671@wotan.suse.de> <200703192144.28969.blaisorblade@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200703192144.28969.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Bill Irwin <bill.irwin@oracle.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 19, 2007 at 09:44:28PM +0100, Blaisorblade wrote:
> On Sunday 18 March 2007 03:50, Nick Piggin wrote:
> > > >
> > > > Yes, I believe that is the case, however I wonder if that is going to
> > > > be a problem for you to distinguish between write faults for clean
> > > > writable ptes, and write faults for readonly ptes?
> > >
> > > I wouldn't be able to distinguish them, but am I going to get write
> > > faults for clean ptes when vma_wants_writenotify() is false (as seems to
> > > be for tmpfs)? I guess not.
> > >
> > > For tmpfs pages, clean writable PTEs are mapped as writable so they won't
> > > give any problem, since vma_wants_writenotify() is false for tmpfs.
> > > Correct?
> >
> > Yes, that should be the case. So would this mean that nonlinear protections
> > don't work on regular files?
> 
> They still work in most cases (including for UML), but if the initial mmap() 
> specified PROT_WRITE, that is ignored, for pages which are not remapped via 
> remap_file_pages(). UML uses PROT_NONE for the initial mmap, so that's no 
> problem.

But how are you going to distinguish a write fault on a readonly pte for
dirty page accounting vs a read-only nonlinear protection?

You can't store any more data in a present pte AFAIK, so you'd have to
have some out of band data. At which point, you may as well just forget
about vma_wants_writenotify vmas, considering that everybody is using
shmem/ramfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
