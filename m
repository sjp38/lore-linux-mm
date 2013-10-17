Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A358C6B0035
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 02:01:34 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1765544pad.30
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 23:01:34 -0700 (PDT)
Date: Thu, 17 Oct 2013 15:01:53 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 00/15] slab: overload struct slab over struct page to
 reduce memory usage
Message-ID: <20131017060153.GB26617@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20131016133457.60fa71f893cd2962d8ec6ff3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131016133457.60fa71f893cd2962d8ec6ff3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, Oct 16, 2013 at 01:34:57PM -0700, Andrew Morton wrote:
> On Wed, 16 Oct 2013 17:43:57 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > There is two main topics in this patchset. One is to reduce memory usage
> > and the other is to change a management method of free objects of a slab.
> > 
> > The SLAB allocate a struct slab for each slab. The size of this structure
> > except bufctl array is 40 bytes on 64 bits machine. We can reduce memory
> > waste and cache footprint if we overload struct slab over struct page.
> 
> Seems a good idea from a quick look.

Thanks :)

> 
> A thought: when we do things like this - adding additional
> interpretations to `struct page', we need to bear in mind that other
> unrelated code can inspect that pageframe.  It is not correct to assume
> that because slab "owns" this page, no other code will be looking at it
> and interpreting its contents.
> 
> One example is mm/memory-failure.c:memory_failure().  It starts with a
> raw pfn, uses that to get at the `struct page', then starts playing
> around with it.  Will that code still work correctly when some of the
> page's fields have been overlayed with slab-specific contents?

Yes, it would work correctly since the SLUB already overload many fields
of struct page with slab-specific contents. One exception is mapping field
which isn't overloaded by the SLUB. But I guess there is no problem,
because the code inspecting random struct page may be already check
PageSlab() or PageLRU() and then skip it if so.

> 
> And memory_failure() is just one example - another is compact_zone()
> and there may well be others.
> 
> This issue hasn't been well thought through.  Given a random struct
> page, there isn't any protocol to determine what it actually *is*. 
> It's a plain old variant record, but it lacks the agreed-upon tag field
> which tells users which variant is currently in use.

With PageSlab(), we can determine that this page is the slab page.
Do we need more? Is there another user who overload struct page?

Thanks.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
