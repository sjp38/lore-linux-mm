Date: Mon, 25 Oct 2004 09:15:01 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: objrmap and nonlinear vma:s
Message-ID: <20041025161501.GW17038@holomorphy.com>
References: <1098702692.23463.123.camel@kubu.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1098702692.23463.123.camel@kubu.opensource.se>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <damm@opensource.se>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2004 at 01:11:33PM +0200, Magnus Damm wrote:
> I am currently investigating how to unmap a physical page belonging to a
> nonlinear file backed vma. 
> By studying the 2.6.9 source code and by reading the excellent VMM book
> by Mel Gorman I believe that:
> - physical pages belonging to linear file backed vma:s are currently
> reverse mapped using the prio_tree i_mmap.

That description is somewhat vague. The prio_tree is a 2-dimensional
search structure indexed by start and end of file offset range, similar
to the more commonly-known k-d trees and the like. One must know the
file offset range covered by a vma for this to work.


On Mon, Oct 25, 2004 at 01:11:33PM +0200, Magnus Damm wrote:
> - physical pages belonging to nonlinear file backed vma:s are currently
> reverse mapped using the linked list i_mmap_nonlinear.
> Please let me know if something above is incorrect.
> The reverse mapping code for nonlinear vma:s does not seem to scale very
> well today with the linked list implementation. It seems to me that the
> assumption is made that the number of users of nonlinear vma:s are few
> and that they probably not very often want do anything resulting in a
> reverse mapping operation.

This is for two obvious reasons. The first is linear search for the vma.
The second is that the virtual position of a physical page at a given
file offset within a nonlinear vma is not predictable, so there is a
second linear search within the vma.


On Mon, Oct 25, 2004 at 01:11:33PM +0200, Magnus Damm wrote:
> Some questions:
> 1) Is everyone happy with the solution today? Is the linked list
> implementation fast enough? It seems to me that the nonlinear code in
> try_to_unmap_file() is good enough for swap but does not always unmap
> the requested page. This behavior is not very suitable for memory
> hotswap. And a linear scan of all page tables is not very suitable for
> swap.

It's not a linear scan of all page tables. It's a rather restricted
subset. The linked list you're referring to is actually not the aspect
that makes it "slow". It's the pagetable scan beneath the nonlinear
vmas.


On Mon, Oct 25, 2004 at 01:11:33PM +0200, Magnus Damm wrote:
> 2) Any particular reason why the prio_tree is avoided for nonlinear
> vma:s? We could modify the code to use one "union shared" together with
> one vm_pgoff per page in struct vm_area_struct for nonlinear vma:s. That
> way it would be possible to rmap nonlinear vma:s with the prio_tree. But
> maybe that is unholy misuse of the prio_tree data structure, who knows.
> 3) Using prio_tree to rmap nonlinear vma:s like above would of course
> lead to a higher memory use per page belonging to a nonlinear vma. That
> raises the question why nonlinear vma:s aren't implemented as several
> vma:s - one vma per page? I mean, if remap_file_pages() should be able
> to change protection per page in the future - exactly what do we have
> then? Several vma:s?

Please read what I wrote above. Your "suggestion" is actually not
sufficiently well-described, so I'm not doing much with it. Before
going on with further suggestions, you may also want to notice that the
precise point of remap_file_pages() is to prevent kernel data structure
proliferation in the cases where your suggestions would create some new
data structure for every pte under the nonlinear vma. That space
overhead is prohibitive and renders workloads reliant on
remap_file_pages() nonfunctional.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
