Subject: Re: objrmap and nonlinear vma:s
From: Magnus Damm <damm@opensource.se>
In-Reply-To: <Pine.LNX.4.44.0410251705280.14867-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0410251705280.14867-100000@localhost.localdomain>
Content-Type: text/plain
Message-Id: <1098732916.23458.198.camel@kubu.opensource.se>
Mime-Version: 1.0
Date: Mon, 25 Oct 2004 21:35:17 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2004-10-25 at 18:29, Hugh Dickins wrote:
> On Mon, 25 Oct 2004, Magnus Damm wrote:

> > The reverse mapping code for nonlinear vma:s does not seem to scale very
> > well today with the linked list implementation. It seems to me that the
> > assumption is made that the number of users of nonlinear vma:s are few
> > and that they probably not very often want do anything resulting in a
> > reverse mapping operation.
> 
> Correct (well, the users might be many, but the kind of apps using
> them few, and it's exceptional to want to do an rmap of them, yes).

So, say that I run some kind of PC emulator that nonlinearly mmap():s
512 MiB memory on my desktop machine that has 512 MiB RAM. After a while
the page out is needed. Would I then be better off if the emulator had
mapped all pages in separate vma:s instead of used nonlinear vma:s?

> > Some questions:
> > 
> > 1) Is everyone happy with the solution today? Is the linked list
> > implementation fast enough? It seems to me that the nonlinear code in
> > try_to_unmap_file() is good enough for swap but does not always unmap
> > the requested page. This behavior is not very suitable for memory
> > hotswap. And a linear scan of all page tables is not very suitable for
> > swap.
> 
> Correct.  And however desirable, memory hotswap is exceptional too, yes?

Yes, I guess it is a rather uncommon operation. But OTOH might these
machines that have hotswap memory hardware run some kind of database
server that nonlinearly mmap():s files to improve performance...
It is probably _very_ uncommon. But how common is page out?

> 
> > We could modify the code to use one "union shared" together with
> > one vm_pgoff per page in struct vm_area_struct for nonlinear vma:s. That
> > way it would be possible to rmap nonlinear vma:s with the prio_tree. But
> > maybe that is unholy misuse of the prio_tree data structure, who knows.
> 
> Sorry, I don't understand "one vm_pgoff per page in struct vm_area_struct".
> Allocate and associate a prio_tree node with each page, perhaps.

Exactly what I meant. Sorry for my vagueness.

Instead of only adding linear vma:s to the prio_tree we in the nonlinear
case add one single-page range per each page belonging to the vma range.
And then we use the prio_tree to rmap both linear and nonlinear vma:s.

But maybe that could be considered as misuse of prio_tree and of course
we have the memory usage trade off and the added complexity which might
slow down remap_file_pages()...

> > 3) Using prio_tree to rmap nonlinear vma:s like above would of course
> > lead to a higher memory use per page belonging to a nonlinear vma. That
> > raises the question why nonlinear vma:s aren't implemented as several
> > vma:s - one vma per page?
> 
> Non-linear vmas were introduced precisely to avoid the crippling memory
> and search overhead of having the per-page vmas some apps used to need.
> Non-linear vmas in themselves are awkward and regrettable, but better
> than not having that option at all.

While at it, my VMM book by Mel Gorman basically says that the search
used by get_unmapped_area() is slow for large number of mappings. Is it
still true with 2.6?

> > I mean, if remap_file_pages() should be able
> > to change protection per page in the future - exactly what do we have
> > then? Several vma:s?
> 
> There was a patch by Ingo in -mm for a while, to change protection
> per page: the non-linear vma remained a single non-linear vma.

Ok. Thanks for your input.

/ magnus


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
