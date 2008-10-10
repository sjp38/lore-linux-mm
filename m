Message-ID: <48EFBBE9.5000703@linux-foundation.org>
Date: Fri, 10 Oct 2008 15:32:41 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: use a radix-tree to make do_move_pages() complexity
 linear
References: <48EDF9DA.7000508@inria.fr> <20081010125010.164bcbb8.akpm@linux-foundation.org> <48EFB6E6.4080708@inria.fr>
In-Reply-To: <48EFB6E6.4080708@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nathalie.furmento@labri.fr
List-ID: <linux-mm.kvack.org>

Brice Goglin wrote:

> Just try sys_move_pages() on a 10-100MB buffer, you'll get something
> like 50MB/s on a recent Opteron machine. This throughput decreases
> significantly with the number of pages. With this patch, we get about
> 350MB/s and the throughput is stable when the migrated buffer gets
> larger. I don't have detailled numbers at hand, I'll send them by monday.

Migration throughput is optimal for sys_move_pages() and the cpuset migration.
Some comparison would be useful.

With 100MB you have ~250k pages which will require a vmalloc of 4MB for the
struct pm struct array to control the migration of each individual page.

Would it be possible to restructure this in such a way that we work in chunks
of 100 or so pages each so that we can avoid the vmalloc?

We also could do a kmalloc for each individual struct pm_struct with the radix
tree which would also avoid the vmalloc but still keep the need to allocate
4MB for temporary struct pm_structs.

Or get rid of the pm_struct altogether by storing the address of the node
vector somewhere and retrieve the node as needed from the array. This would
allow storing the struct page * pointers in the radix tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
