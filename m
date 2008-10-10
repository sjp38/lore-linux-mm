Date: Fri, 10 Oct 2008 12:50:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: use a radix-tree to make do_move_pages() complexity
 linear
Message-Id: <20081010125010.164bcbb8.akpm@linux-foundation.org>
In-Reply-To: <48EDF9DA.7000508@inria.fr>
References: <48EDF9DA.7000508@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, nathalie.furmento@labri.fr
List-ID: <linux-mm.kvack.org>

On Thu, 09 Oct 2008 14:32:26 +0200
Brice Goglin <Brice.Goglin@inria.fr> wrote:

> Add a radix-tree in do_move_pages() to associate each page with
> the struct page_to_node that describes its migration.
> new_page_node() can now easily find out the page_to_node of the
> given page instead of traversing the whole page_to_node array.
> So the overall complexity is linear instead of quadratic.
> 
> We still need the page_to_node array since it is allocated by the
> caller (sys_move_page()) and used by do_pages_stat() when no target
> nodes are given by the application. And we need room to store all
> these page_to_node entries for do_move_pages() as well anyway.
> 
> If a page is given twice by the application, the old code would
> return -EBUSY (failure from the second isolate_lru_page()). Now,
> radix_tree_insert() will return -EEXIST, and we convert it back
> to -EBUSY to keep the user-space ABI.
> 
> The radix-tree is emptied at the end of do_move_pages() since
> new_page_node() doesn't know when an entry is used for the last
> time (unmap_and_move() could try another pass later).
> Marking pp->page as ZERO_PAGE(0) was actually never used. We now
> set it to NULL when pp is not in the radix-tree. It is faster
> than doing a loop of radix_tree_lookup_gang()+delete().

Any O(n*n) code always catches up with us in the end.  But I do think
that to merge this code we'd need some description of the problem which
we fixed.

Please send a description of the situation under which the current code
performs unacceptably.  Some before-and-after quantitative measurements
would be good.

Because it could be (as far as I know) that the problem is purely
theoretical, in which case we might not want the patch at all.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
