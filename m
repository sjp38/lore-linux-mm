Date: Tue, 30 Oct 2007 12:39:20 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
In-Reply-To: <1193741356.13775.2.camel@matrix>
Message-ID: <Pine.LNX.4.64.0710301232220.9601@blonde.wat.veritas.com>
References: <1193064057.16541.1.camel@matrix>  <20071029004002.60c7182a.akpm@linux-foundation.org>
  <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
 <1193677302.27652.56.camel@twins>  <45a44e480710291051s7ffbb582x64ea9524c197b48a@mail.gmail.com>
  <1193681839.27652.60.camel@twins> <1193696211.5644.100.camel@lappy>
 <45a44e480710291822w5864b3beofcf432930d3e68d3@mail.gmail.com>
 <1193738177.27652.69.camel@twins> <1193741356.13775.2.camel@matrix>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stefani Seibold <stefani@seibold.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Jaya Kumar <jayakumar.lkml@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Oct 2007, Stefani Seibold wrote:
> 
> the question is how can i get all pte's from a vmalloc'ed memory. Due to
> the zeroed mapping pointer i dont see how to do this?

The mapping pointer is zeroed because you've done nothing to set it.
Below is how I answered you a week ago.  But this is new territory
(extending page_mkclean to work on more than just pagecache pages),
I'm still unsure what would be the safest way to do it.

On Mon, 22 Oct 2007, Stefani Seibold wrote:
> 
> i have a problem with vmalloc() and vm_ops.page_mkwrite().
> 
> ReadOnly access works, but on a write access the VM will
> endless invoke the vm_ops.page_mkwrite() handler.
> 
> I tracked down the problem to the
> 	struct page.mapping pointer,
> which is NULL.
> 
> The problem original occurs with the fb_defio driver (driver/video/fb_defio.c).
> This driver use the vm_ops.page_mkwrite() handler for tracking the modified pages,
> which will be in an extra thread handled, to perform the IO and clean and
> write protect all pages with page_clean().

Interesting.  You need to ask Jaya (CC'ed) since he's the one
who put that code into fb_defio.c, exported page_mkclean, and
should have tested it.

> 
> I am not sure if the is a feature of the new rmap code or a bug.

page_mkclean was written in the belief that it was being used on
pagecache pages.  I'm not sure how deeply engrained that belief is.

If it can easily and safely be used on something else, that may be
nice: though there's a danger we'll keep breaking and re-breaking
it if there's only one driver using it in an unusual way.  CC'ed
Peter since he's the one who most needs to be aware of this.

> 
> Is there an way to get a similar functionality? Currently, i have no
> idea
> how to get the ptep from a page alloced with vmalloc().

A pagecache page would have page->mapping initialized to point to
the struct address_space of the vma, and page->index to the offset
(in PAGE_SIZE units): see mm/filemap.c:add_to_page_cache.  Without
page->mapping set, page_mkclean_file won't be able to find the vmas
in which the page might appear; and without page->index set, it
won't be able to find where the page should be in those vmas.

If such a driver does not put its pages into the page cache (the
safer course? I'm unsure), then it needs to set page->mapping and
page->index appropriately (and reset page->mapping to NULL before
freeing).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
