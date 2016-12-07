Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4526B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 15:28:28 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id x26so271703288qtb.6
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 12:28:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q70si6621754qke.113.2016.12.07.12.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 12:28:27 -0800 (PST)
Date: Wed, 7 Dec 2016 21:28:24 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
 fast (de)inflating & fast live migration
Message-ID: <20161207202824.GH28786@redhat.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
 <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
 <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
 <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
 <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
 <20161207183817.GE28786@redhat.com>
 <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: David Hildenbrand <david@redhat.com>, "Li, Liang Z" <liang.z.li@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Wed, Dec 07, 2016 at 11:54:34AM -0800, Dave Hansen wrote:
> We're talking about a bunch of different stuff which is all being
> conflated.  There are 3 issues here that I can see.  I'll attempt to
> summarize what I think is going on:
> 
> 1. Current patches do a hypercall for each order in the allocator.
>    This is inefficient, but independent from the underlying data
>    structure in the ABI, unless bitmaps are in play, which they aren't.
> 2. Should we have bitmaps in the ABI, even if they are not in use by the
>    guest implementation today?  Andrea says they have zero benefits
>    over a pfn/len scheme.  Dave doesn't think they have zero benefits
>    but isn't that attached to them.  QEMU's handling gets more
>    complicated when using a bitmap.
> 3. Should the ABI contain records each with a pfn/len pair or a
>    pfn/order pair?
>    3a. 'len' is more flexible, but will always be a power-of-two anyway
> 	for high-order pages (the common case)

Len wouldn't be a power of two practically only if we detect adjacent
pages of smaller order that may merge into larger orders we already
allocated (or the other way around).

[addr=2M, len=2M] allocated at order 9 pass
[addr=4M, len=1M] allocated at order 8 pass -> merge as [addr=2M, len=3M]

Not sure if it would be worth it, but that unless we do this, page-order or
len won't make much difference.

>    3b. if we decide not to have a bitmap, then we basically have plenty
> 	of space for 'len' and should just do it
>    3c. It's easiest for the hypervisor to turn pfn/len into the
>        madvise() calls that it needs.
> 
> Did I miss anything?

I think you summarized fine all my arguments in your summary.

> FWIW, I don't feel that strongly about the bitmap.  Li had one
> originally, but I think the code thus far has demonstrated a huge
> benefit without even having a bitmap.
> 
> I've got no objections to ripping the bitmap out of the ABI.

I think we need to see a statistic showing the number of bits set in
each bitmap in average, after some uptime and lru churn, like running
stresstest app for a while with I/O and then inflate the balloon and
count:

1) how many bits were set vs total number of bits used in bitmaps

2) how many times bitmaps were used vs bitmap_len = 0 case of single
   page

My guess would be like very low percentage for both points.

> Surely we can think of a few ways...
> 
> A bitmap is 64x more dense if the lists are unordered.  It means being
> able to store ~32k*2M=64G worth of 2M pages in one data page vs. ~1G.
> That's 64x fewer cachelines to touch, 64x fewer pages to move to the
> hypervisor and lets us allocate 1/64th the memory.  Given a maximum
> allocation that we're allowed, it lets us do 64x more per-pass.
> 
> Now, are those benefits worth it?  Maybe not, but let's not pretend they
> don't exist. ;)

In the best case there are benefits obviously, the question is how
common the best case is.

The best case if I understand correctly is all high order not
available, but plenty of order 0 pages available at phys address X,
X+8k, X+16k, X+(8k*nr_bits_in_bitmap). How common is that 0 pages
exist but they're not at an address < X or > X+(8k*nr_bits_in_bitmap)?

> Yes, the current code sends one batch of pages up to the hypervisor per
> order.  But, this has nothing to do with the underlying data structure,
> or the choice to have an order vs. len in the ABI.
> 
> What you describe here is obviously more efficient.

And it isn't possible with the current ABI.

So there is a connection with the MAX_ORDER..0 allocation loop and the
ABI change, but I agree any of the ABI proposed would still allow for
it this logic to be used. Bitmap or not bitmap, the loop would still
work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
