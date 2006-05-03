Subject: Re: [patch 00/14] remap_file_pages protection support
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200605030320.50055.blaisorblade@yahoo.it>
References: <20060430172953.409399000@zion.home.lan>
	 <4456D5ED.2040202@yahoo.com.au>
	 <1146590207.5202.17.camel@localhost.localdomain>
	 <200605030320.50055.blaisorblade@yahoo.it>
Content-Type: text/plain
Date: Wed, 03 May 2006 10:35:18 -0400
Message-Id: <1146666919.5154.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Ulrich Drepper <drepper@redhat.com>, Val Henson <val.henson@intel.com>, Bob Picco <bob.picco@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-05-03 at 03:20 +0200, Blaisorblade wrote:
> On Tuesday 02 May 2006 19:16, Lee Schermerhorn wrote:
> > On Tue, 2006-05-02 at 13:45 +1000, Nick Piggin wrote:
> > > blaisorblade@yahoo.it wrote:
> 
> > > I think I would rather this all just folded under VM_NONLINEAR rather
> > > than having this extra MANYPROTS thing, no? (you're already doing that in
> > > one direction).
> 
> > One way I've seen this done on other systems
> 
> I'm curious, which ones?

Let's see:  System V [4.2MP] back in the days of USL [Unix Systems Labs]
did this, as did [does] Digital/Compaq/HP Tru64 on alpha.  I'm not sure
if the latter came from the original Mach/OSF code or from Bob Picco's
rewrite thereof back in the 90's.

> 
> > is to use something like a 
> > prio tree [e.g., see the shared policy support for shmem] for sub-vma
> > protection ranges.
> Which sub-vma ranges? The ones created with mprotect?
> 
> I'm curious about what is the difference between this sub-tree and the main 
> tree... you have some point, but I miss which one :-) Actually when doing a 
> lookup in the main tree the extra nodes in the subtree are not searched, so 
> you get an advantage.

True, you still have locate the protection range in the subtree and then
still walk the page tables to install the new protections.  Of course,
in the bad old days, the only time I saw thousands or 10s of thousands
of different mappings/vmas/regions/whatever was in vm stress tests.
Until squid came along, that is.  Then we encountered, on large memory
alpha systems, 100s of thousands of mmaped files.  Had to replace the
linear [honest] vma/mapping list at that point ;-).

> 
> One possible point is that a VMA maps to one mmap() call (with splits from 
> mremap(),mprotect(),partial munmap()s), and then they use sub-VMAs instead of 
> VMA splits.

Yeah.  That was the point--in response to Nick's comment about the
disconnect betwen the protections as reported by the vma and the actual
pte protections.
> 
> > Most vmas [I'm guessing here] will have only the 
> > original protections or will be reprotected in toto.
> 
> > So, one need only 
> > allocate/populate the protection tree when sub-vma protections are
> > requested.   Then, one can test protections via the vma, perhaps with
> > access/check macros to hide the existence of the protection tree.  Of
> > course, adding a tree-like structure could introduce locking
> > complications/overhead in some paths where we'd rather not [just
> > guessing again].  Might be more overhead than just mucking with the ptes
> > [for UML], but would keep the ptes in sync with the vma's view of
> > "protectedness".
> >
> > Lee
> 
> Ok, there are two different situations, I'm globally unconvinced until I 
> understand the usefulness of a different sub-tree.
> 
> a) UML. The answer is _no_ to all guesses, since we must implement page tables 
> of a guest virtual machine via mmap() or remap_file_pages. And they're as 
> fragmented as they get (we get one-page-wide VMAs currently).
> 
> b) the proposed glibc usage. The original Ulrich's request (which I cut down 
> because of problems with objrmap) was to have one mapping per DSO, including 
> code,data and guard page. So you have three protections in one VMA.
> 
> However, this is doable via this remap_file_pages, adding something for 
> handling private VMAs (handling movement of the anonymous memory you get on 
> writes); but it's slow on swapout, since it stops using objrmap. So I've not 
> thought to do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
