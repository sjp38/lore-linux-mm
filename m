Message-ID: <45181B4F.6060602@shadowen.org>
Date: Mon, 25 Sep 2006 19:09:19 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: virtual mmap basics
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com> <4517CB69.9030600@shadowen.org> <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Mon, 25 Sep 2006, Andy Whitcroft wrote:
> 
>> pfn_valid is most commonly required on virtual mem_map setups as its
>> implementation (currently) violates the 'contiguious and present' out to
>> MAX_ORDER constraint that the buddy expects.  So we have additional
>> frequent checks on pfn_valid in the allocator to check for it when there
>> are holes within zones (which is virtual memmaps in all but name).
> 
> Why would the page allocator require frequent calls to pfn_valid? One 
> you have the free lists setup then there is no need for it AFAIK.
> 
> Still pfn_valid with virtual memmap is still comparable to sparses 
> current implementation. If the cpu has an instruction to check the 
> validity of an address then it will be superior.

If you are not guarenteeing contiuity of mem_map out to MAX_ORDER you
have to add additional checks.  These are only enabled on ia64, see
CONFIG_HOLES_IN_ZONES and only if we have VIRTUAL_MEM_MAP defined.  As a
key example when this is defined we have to add a
pfn_valid(page_to_pfn()) stanza to page_is_buddy() which is used heavily
on page free.  This is a problem when this check is not cheap such as
appears to be true in ia64 where we do do a number of checks on segments
boundaries, then we try and read the first word of the entry.  This is
done as a user access, and if my reading is correct we take and handle a
fault if the page is missing.  This on top of the fetches required to
load the MMU sound like they increase not decrease the complexity of
this operation?

>> We also need to consider the size of the mem_map.  The reason we have a
>> problem with smaller machines is that virtual space in zone NORMAL is
>> limited.  The mem_map here has to be contigious and spase in KVA, this
>> is exactly the resource we are short of.
> 
> The point of the virtual memmap is that it does not have to be contiguous 
> and it is sparse. Sparsemem could use that format and then we would be 
> able to optimize important VM function such as virt_to_page() and 
> page_address().

The point I am making here is its not the cost of storage of the active
segments of the mem_map that are the issue.  We have GB's of memory in
highmem we can use to back it.  The problem is the kernel virtual
address space we need to use to represent the mem_map, which includes
the holes; on 32bit it is this KVA  which is in short supply.  We cannot
reuse the holes as they are needed by the implementation.

The problem we have is that 32bit needs sparsemem to be truly sparse in
KVA terms.  So we need a sparse implementation which keeps the KVA
footprint down, the virtual mem_map cannot cater to that usage model.

It may have value for 64bit systems, but I'd like to see some
comparitive numbers showing the benefit, as to my eye at least you are
hiding much of the work to be done not eliminating it.  And at least in
some cases adding significant overhead.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
