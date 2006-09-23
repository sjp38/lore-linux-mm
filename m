Date: Fri, 22 Sep 2006 20:02:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: One idea to free up page flags on NUMA
Message-ID: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

Andrew asked for a way to free up page flags and I think there is a way to 
get rid of both the node information and the sparse field in the page 
flags.

For that we adopt some ideas from VIRTUAL_MEM_MAP. Virtual memmap has the 
disadvantage that it needs a page table and thus is wasting TLB entries on 
i386 and x86_64.  But it has the advantage that page_address() and
virt_to_page() are simple add / subtract shift operations. Plus one can 
can use the super fast hardware table walker on i386 and x86_64. Plus the 
cpu is using its special optimized TLB caches to store the mappings.

Sparse has the ability to configure larger and smaller chunk sizes. Lets 
say we do that with VMEMMAP. Say we use huge pages as the basic unit
to map the memmap array.

Then one block of 2M can map 32768 pages (assuming 128 byte struct page 
size) which is around 128 Megabytes. The TLB pressure is significantly 
reduced.

So we would have a 3 level page table to index into that array that is 
comparable to a sparsemem tree.

We do not need all bits of the virtual memmap address to index
since we shift the address by PAGE_SHIFT. We could use the 
higher portion to store the node number (Hmm... Not all bits
are supported for virtual mappings, right? But that would also reduce the 
number of bits that need to be mapped through pfns.)

Then the node number could be retrieved from the address of the page 
struct without even having to touch the page flags. page_zone would 
avoid yet another lookup. The section ID and the section 
tables are replaced by the page table and the hardware walker.

The memory plugin / plugout could still work like under sparse. It is just 
a matter managing the page table to add and remove sections of memmap. The 
page table is actually very much like the sparse tree. The code could 
likely be made to work with a page table.

By that scheme we would win 6 bits on NUMAQ (32bit) and would save around 
20-30 bits on 64 bit machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
