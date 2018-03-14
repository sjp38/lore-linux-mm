Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 373AC6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 13:33:50 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bb5-v6so1712877plb.22
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 10:33:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 61-v6si2304902plq.737.2018.03.14.10.33.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Mar 2018 10:33:48 -0700 (PDT)
Date: Wed, 14 Mar 2018 10:33:43 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH v19 0/8] mm: security: ro protection for dynamic data
Message-ID: <20180314173343.GJ29631@bombadil.infradead.org>
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <a9bfc57f-1591-21b6-1676-b60341a2fadd@huawei.com>
 <20180314115653.GD29631@bombadil.infradead.org>
 <8623382b-cdbe-8862-8c2f-fa5bc6a1213a@huawei.com>
 <20180314130418.GG29631@bombadil.infradead.org>
 <9623b0d1-4ace-b3e7-b861-edba03b8a8cd@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9623b0d1-4ace-b3e7-b861-edba03b8a8cd@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: keescook@chromium.org, david@fromorbit.com, rppt@linux.vnet.ibm.com, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Mar 14, 2018 at 06:11:22PM +0200, Igor Stoppa wrote:
> On 14/03/18 15:04, Matthew Wilcox wrote:
> > but the principle it uses
> > seems like a better match to me than the rather complex genalloc.
> 
> It uses meta data in a different way than genalloc.
> There is probably a tipping point where one implementation becomes more
> space-efficient than the other.

Certainly there are always tradeoffs in writing a memory allocator.

> Probably page_frag does well with relatively large allocations, while
> genalloc seems to be better for small (few allocation units) allocations.

I don't understand why you would think that.  If you allocate 4096 1-byte
elements, page_frag will just use up a page.  Doing the same thing with
genalloc requires allocating two bits per byte (1kB of bitmap), plus
other overheads.

> Also, in case of high variance in the size of the allocations, genalloc
> requires the allocation unit to be small enough to fit the smallest
> request (otherwise one must accept some slack), while page_frag doesn't
> care if the allocation is small or large.

Right; internal versus external fragmentation.  The bane of memory
allocators ;-)

> page_frag otoh, seems to not support the reuse of space that was freed,
> since there is only

To a certain extent it does.  If you free everything on a page, and that
page is still in the page_frag_cache, it will get reused.

> But could you please explain to what you are referring to, when you say
> that page_frag has "significantly lower overhead" ?

Less CPU time taken per allocation, less metadata stored per object.

> Ex: if the pfree is called only on error paths, is it ok to not claim
> back the memory released, if it's less than one page?

Yes, I think that's a great example.

> To be clear: I do not want to hold to genalloc just because I have
> already implemented it. I can at least sketch a version with page_frag,
> but I would like to understand why its trade-offs are better :-)
> 
> > Just allocate some pages and track the offset within those pages that 
> 
> > is the current allocation point.
> 
> 
> > It's less than 100 lines of code!
> 
> Strictly speaking it is true, but it all relies on other functions,
> which must be rewritten, because they use linear address, while this
> must work with virtual (vmalloc) addresses.

No, that's basically the whole thing.  I think an implementation of
pmalloc which used a page_frag-style allocator would be larger than
100 lines, but I don't think it would have to be significantly larger
than that.

> Also, I see that the code relies a lot on order of allocation.
> I think we had similar discussion wrt compound pages.
> 
> It seems to me wasteful, if I have a request of, say, 5 pages, and I end
> up allocating 8.

Yes, but the other three pages are available for use by the pmalloc pool.
Now, at pmalloc_protect() time, you might well want to release the unused
pages by calling make_alloc_exact() and hand those three pages back to the
page allocator.

> I do not recall anyone giving a justification like:
> "yeah, it uses extra pages, but it's preferable, for reasons X, Y and Z,
> so it's a good trade-off"

Sometimes it is, sometimes it isn't.

> Could it be that it's normal RAM is considered less precious than the
> special memory genalloc is written for, so normal RAM is not really
> proactively reused, while special memory is treated as a more valuable
> resource that should not be wasted?

We're certainly at the point where normal RAM is pretty cheap.  A 16GB
DIMM is $200, so that's $12.50 per gigabyte.  We have more of a problem
with fragmentation than we do with squeezing every last byte out of
the system.

Of course, Linux still runs on tiny systems, and we don't want to
unnecessarily bloat the kernel.  And cachelines are also a precious
resource; the fewer we touch, the faster the system runs.  The bitmap
in genalloc can easily occupy several cachelines; the page_frag allocator
touches a single cacheline for most allocations.
