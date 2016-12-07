Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 76D746B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 14:54:36 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j128so616001570pfg.4
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 11:54:36 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m39si25292149plg.186.2016.12.07.11.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 11:54:35 -0800 (PST)
Subject: Re: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
 <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
 <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
 <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
 <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
 <20161207183817.GE28786@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
Date: Wed, 7 Dec 2016 11:54:34 -0800
MIME-Version: 1.0
In-Reply-To: <20161207183817.GE28786@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, "Li, Liang Z" <liang.z.li@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

We're talking about a bunch of different stuff which is all being
conflated.  There are 3 issues here that I can see.  I'll attempt to
summarize what I think is going on:

1. Current patches do a hypercall for each order in the allocator.
   This is inefficient, but independent from the underlying data
   structure in the ABI, unless bitmaps are in play, which they aren't.
2. Should we have bitmaps in the ABI, even if they are not in use by the
   guest implementation today?  Andrea says they have zero benefits
   over a pfn/len scheme.  Dave doesn't think they have zero benefits
   but isn't that attached to them.  QEMU's handling gets more
   complicated when using a bitmap.
3. Should the ABI contain records each with a pfn/len pair or a
   pfn/order pair?
   3a. 'len' is more flexible, but will always be a power-of-two anyway
	for high-order pages (the common case)
   3b. if we decide not to have a bitmap, then we basically have plenty
	of space for 'len' and should just do it
   3c. It's easiest for the hypervisor to turn pfn/len into the
       madvise() calls that it needs.

Did I miss anything?

On 12/07/2016 10:38 AM, Andrea Arcangeli wrote:
> On Wed, Dec 07, 2016 at 08:57:01AM -0800, Dave Hansen wrote:
>> It is more space-efficient.  We're fitting the order into 6 bits, which
>> would allows the full 2^64 address space to be represented in one entry,
> 
> Very large order is the same as very large len, 6 bits of order or 8
> bytes of len won't really move the needle here, simpler code is
> preferable.

Agreed.  But without seeing them side-by-side I'm not sure we can say
which is simpler.

> The main benefit of "len" is that it can be more granular, plus it's
> simpler than the bitmap too. Eventually all this stuff has to end up
> into a madvisev (not yet upstream but somebody posted it for jemalloc
> and should get merged eventually).
> 
> So the bitmap shall be demuxed to a addr,len array anyway, the bitmap
> won't ever be sent to the madvise syscall, which makes the
> intermediate representation with the bitmap a complication with
> basically no benefits compared to a (N, [addr1,len1], .., [addrN,
> lenN]) representation.

FWIW, I don't feel that strongly about the bitmap.  Li had one
originally, but I think the code thus far has demonstrated a huge
benefit without even having a bitmap.

I've got no objections to ripping the bitmap out of the ABI.

>> and leaves room for the bitmap size to be encoded as well, if we decide
>> we need a bitmap in the future.
> 
> How would a bitmap ever be useful with very large page-order?

Surely we can think of a few ways...

A bitmap is 64x more dense if the lists are unordered.  It means being
able to store ~32k*2M=64G worth of 2M pages in one data page vs. ~1G.
That's 64x fewer cachelines to touch, 64x fewer pages to move to the
hypervisor and lets us allocate 1/64th the memory.  Given a maximum
allocation that we're allowed, it lets us do 64x more per-pass.

Now, are those benefits worth it?  Maybe not, but let's not pretend they
don't exist. ;)

>> If that was purely a length, we'd be limited to 64*4k pages per entry,
>> which isn't even a full large page.
> 
> I don't follow here.
> 
> What we suggest is to send the data down represented as (N,
> [addr1,len1], ..., [addrN, lenN]) which allows infinite ranges each
> one of maximum length 2^64, so 2^64 multiplied infinite times if you
> wish. Simplifying the code and not having any bitmap at all and no :6
> :6 bits either.
> 
> The high order to low order loop of allocations is the interesting part
> here, not the bitmap, and the fact of doing a single vmexit to send
> the large ranges.

Yes, the current code sends one batch of pages up to the hypervisor per
order.  But, this has nothing to do with the underlying data structure,
or the choice to have an order vs. len in the ABI.

What you describe here is obviously more efficient.

> Considering the loop that allocates starting from MAX_ORDER..1, the
> chance the bitmap is actually getting filled with more than one bit at
> page_shift of PAGE_SHIFT should be very low after some uptime.

Yes, if bitmaps were in use, this is true.  I think a guest populating
bitmaps would probably not use the same algorithm.

> By the very nature of this loop, if we already exacerbates all high
> order buddies, the page-order 0 pages obtained are going to be fairly
> fragmented reducing the usefulness of the bitmap and potentially only
> wasting CPU/memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
