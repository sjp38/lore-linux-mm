Date: Wed, 30 May 2007 13:07:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/7] KAMEZAWA Hiroyuki - migration by kernel
In-Reply-To: <Pine.LNX.4.64.0705302021040.7044@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0705301304200.2671@schroedinger.engr.sgi.com>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
 <20070529173649.1570.85922.sendpatchset@skynet.skynet.ie>
 <20070530114243.e3c3c75e.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0705302021040.7044@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 May 2007, Hugh Dickins wrote:

> I've taken a look at last.  It looks like a good fix to a real problem,
> but may I suggest a simpler version?  The anon_vma isn't usually held
> by a refcount, but by having a vma on its linked list: why not just
> put a dummy vma into that linked list?  No need to add a refcount.
> 
> The NUMA shmem_alloc_page already uses a dummy vma on its stack,
> so you can reasonably declare a vm_area_struct on unmap_and_move's
> stack.  No need for a special anon_vma_release, anon_vma_unlink
> should do fine.  I've not reworked your whole patch, but show
> what I think the mm/rmap.c part would be at the bottom.

Hummm.. shmem_alloc_pages version only uses the vma as a placeholder 
for memory policies. So we would put the page on a vma that is on the 
stack? That would mean changing the mapping of the page? Is that safe?

And then later we would be changing the mapping back to the old vma?
What guarantees that the old vma is not gone by then?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
