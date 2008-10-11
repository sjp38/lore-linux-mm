Message-ID: <48F069B8.6050709@inria.fr>
Date: Sat, 11 Oct 2008 10:54:16 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: use a radix-tree to make do_move_pages() complexity
 linear
References: <48EDF9DA.7000508@inria.fr> <20081010125010.164bcbb8.akpm@linux-foundation.org> <48EFB6E6.4080708@inria.fr> <48EFBBE9.5000703@linux-foundation.org>
In-Reply-To: <48EFBBE9.5000703@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nathalie.furmento@labri.fr
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Would it be possible to restructure this in such a way that we work in chunks
> of 100 or so pages each so that we can avoid the vmalloc?
>
> We also could do a kmalloc for each individual struct pm_struct with the radix
> tree which would also avoid the vmalloc but still keep the need to allocate
> 4MB for temporary struct pm_structs.
>
> Or get rid of the pm_struct altogether by storing the address of the node
> vector somewhere and retrieve the node as needed from the array. This would
> allow storing the struct page * pointers in the radix tree.
>   

I have been thinking about all this, and here's some ideas:
* do_pages_stat() may easily be rewritten without the huge pm array. It
just need to user-space pointers to the page and status arrays. It
traverses the first array , and for each page does: doing get_user() the
address, retrieve the page node, and put_user() the result in the status
array. No need to allocate any single page_to_node structure.
* If we split the migration in small chunks (such as one page of pm's),
the quadratic complexity doesn't matter that much. There will be at most
several dozens of pm in the chunk array, so the linear search in
new_page_node() won't be that slow, it may even be faster than the
overall cost of adding a radix-tree to improve this search. So we can
keep the internal code unchanged and just add the chunking around it.
* One thing that bothers me is move_pages() returning -ENOENT when no
page are given to migrate_pages(). I don't see why having 100/100 pages
not migrated would return a different error than having only 99/100
pages not migrated. We have the status array to place -ENOENT for all
these pages. If the user doesn't know where his pages are allocated, he
shouldn't get a different return value depending on how many pages were
already on the right node. And actually, this convention makes
user-space application harder to write since you need to treat -ENOENT
as a success unless you already knew for sure where your pages were
allocated. And the big thing is that this convention makes the chunking
painfully/uselessly more complex. Breaking user-ABI is bad, but fixing
crazy ABI...

Here are some other numbers from the above (dirty) implementation,
migrating from node #2 to #3 on a quad-quad-core opteron 2347HE with
vanilla 2.6.27:

length		move_pages (us)	move_pages with patch (us)
4kB		126		98
40kB		198		168
400kB		963		937
4MB		12503		11930
40MB		246867		11848

It seems to be even slightly better than the previous patch (but the
kernel are a bit different). And I quickly checked that it scales well
up to 4GB buffers.

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
