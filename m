Date: Mon, 25 Sep 2006 14:00:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: virtual mmap basics
In-Reply-To: <45181B4F.6060602@shadowen.org>
Message-ID: <Pine.LNX.4.64.0609251354460.24262@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
 <4517CB69.9030600@shadowen.org> <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
 <45181B4F.6060602@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2006, Andy Whitcroft wrote:

> If you are not guarenteeing contiuity of mem_map out to MAX_ORDER you
> have to add additional checks.  These are only enabled on ia64, see
> CONFIG_HOLES_IN_ZONES and only if we have VIRTUAL_MEM_MAP defined.  As a
> key example when this is defined we have to add a
> pfn_valid(page_to_pfn()) stanza to page_is_buddy() which is used heavily
> on page free.  This is a problem when this check is not cheap such as
> appears to be true in ia64 where we do do a number of checks on segments
> boundaries, then we try and read the first word of the entry.  This is
> done as a user access, and if my reading is correct we take and handle a
> fault if the page is missing.  This on top of the fetches required to
> load the MMU sound like they increase not decrease the complexity of
> this operation?

Ahh the buddy checks. The node structure contains the pfn boundaries which 
could be checked. The check can be implemented in a cheap way on IA64 
because we have an instruction to check the validity of a mapping.

> > The point of the virtual memmap is that it does not have to be contiguous 
> > and it is sparse. Sparsemem could use that format and then we would be 
> > able to optimize important VM function such as virt_to_page() and 
> > page_address().
> 
> The point I am making here is its not the cost of storage of the active
> segments of the mem_map that are the issue.  We have GB's of memory in
> highmem we can use to back it.  The problem is the kernel virtual
> address space we need to use to represent the mem_map, which includes
> the holes; on 32bit it is this KVA  which is in short supply.  We cannot
> reuse the holes as they are needed by the implementation.

I just talked with Martin and he told me that the address space on 32 bit 
systems must be mostly linear due to the scarcity of it. So I cannot see 
any issue there.

> The problem we have is that 32bit needs sparsemem to be truly sparse in
> KVA terms.  So we need a sparse implementation which keeps the KVA
> footprint down, the virtual mem_map cannot cater to that usage model.

Huh? I have given some numbers in another thread that contradict this.

> It may have value for 64bit systems, but I'd like to see some
> comparitive numbers showing the benefit, as to my eye at least you are
> hiding much of the work to be done not eliminating it.  And at least in
> some cases adding significant overhead.

Multiple lookups in virt_to_page, page_address compared to none is not 
enough? Are you telling me that multiple table lookups are 
performance wise better than a simple address calculation?

I really wish you could show one case in which the virtual memmap approach 
would not be advantageous. It looks as if this may be somehow possible 
with sparse on 32 bit but I do not understand how this could be possible 
given the lack of sparsity of a 32 bit address space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
