Date: Mon, 25 Oct 2004 17:29:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: objrmap and nonlinear vma:s
In-Reply-To: <1098702692.23463.123.camel@kubu.opensource.se>
Message-ID: <Pine.LNX.4.44.0410251705280.14867-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <damm@opensource.se>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2004, Magnus Damm wrote:
> 
> I am currently investigating how to unmap a physical page belonging to a
> nonlinear file backed vma. 
> 
> By studying the 2.6.9 source code and by reading the excellent VMM book
> by Mel Gorman I believe that:
> 
> - physical pages belonging to linear file backed vma:s are currently
> reverse mapped using the prio_tree i_mmap.
> 
> - physical pages belonging to nonlinear file backed vma:s are currently
> reverse mapped using the linked list i_mmap_nonlinear.
> 
> Please let me know if something above is incorrect.

The above is correct.

> The reverse mapping code for nonlinear vma:s does not seem to scale very
> well today with the linked list implementation. It seems to me that the
> assumption is made that the number of users of nonlinear vma:s are few
> and that they probably not very often want do anything resulting in a
> reverse mapping operation.

Correct (well, the users might be many, but the kind of apps using
them few, and it's exceptional to want to do an rmap of them, yes).

> Some questions:
> 
> 1) Is everyone happy with the solution today? Is the linked list
> implementation fast enough? It seems to me that the nonlinear code in
> try_to_unmap_file() is good enough for swap but does not always unmap
> the requested page. This behavior is not very suitable for memory
> hotswap. And a linear scan of all page tables is not very suitable for
> swap.

Correct.  And however desirable, memory hotswap is exceptional too, yes?

> 2) Any particular reason why the prio_tree is avoided for nonlinear
> vma:s?

Their non-linearity makes the prio_tree useless for them.

> We could modify the code to use one "union shared" together with
> one vm_pgoff per page in struct vm_area_struct for nonlinear vma:s. That
> way it would be possible to rmap nonlinear vma:s with the prio_tree. But
> maybe that is unholy misuse of the prio_tree data structure, who knows.

Sorry, I don't understand "one vm_pgoff per page in struct vm_area_struct".
Allocate and associate a prio_tree node with each page, perhaps.

> 3) Using prio_tree to rmap nonlinear vma:s like above would of course
> lead to a higher memory use per page belonging to a nonlinear vma. That
> raises the question why nonlinear vma:s aren't implemented as several
> vma:s - one vma per page?

Non-linear vmas were introduced precisely to avoid the crippling memory
and search overhead of having the per-page vmas some apps used to need.
Non-linear vmas in themselves are awkward and regrettable, but better
than not having that option at all.

> I mean, if remap_file_pages() should be able
> to change protection per page in the future - exactly what do we have
> then? Several vma:s?

There was a patch by Ingo in -mm for a while, to change protection
per page: the non-linear vma remained a single non-linear vma.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
