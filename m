Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C2DA76B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 11:29:19 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id g49so12672243qta.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:29:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p102si564046qkp.108.2017.01.18.08.29.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 08:29:18 -0800 (PST)
Date: Wed, 18 Jan 2017 17:29:14 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v1 1/1] mm/ksm: improve deduplication of zero pages with
 colouring
Message-ID: <20170118162914.GF10177@redhat.com>
References: <1484237834-15803-1-git-send-email-imbrenda@linux.vnet.ibm.com>
 <20170112172132.GM4947@redhat.com>
 <1e1e7589-9713-e6a4-f57c-bfd94eb3e1e9@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1e1e7589-9713-e6a4-f57c-bfd94eb3e1e9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, borntraeger@de.ibm.com, hughd@google.com, izik.eidus@ravellosystems.com, chrisw@sous-sol.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed, Jan 18, 2017 at 04:15:56PM +0100, Claudio Imbrenda wrote:
> I'm not sure it would make sense to have this for archs that don't have
> page coloring. Merging empty pages together instead of with the

It's still good to be able to exercise this code on all archs (if
nothing else for debugging purposes). There's nothing arch dependent
in it after all.

> ZERO_PAGE() would save exactly one page and it would bring no speed
> advantages (or rather: not using the ZERO_PAGE() would not bring any
> speed penalty).
> That's why I have #ifdef'd it to have it only when page coloring is
> present. Also, for what I could see, only MIPS and s390 have page
> coloring; I don't like the idea of imposing any overhead to all the
> other archs.

With a sysctl disabled by default, the only overhead is 8 bytes and a
branch?

> I agree that this should be toggleable with a sysfs control, since it's
> a change that can potentially negatively affect the performance in some
> cases. I'm adding it in the next iteration.

Yes the sysctl can be useful for archs doing page coloring too, but I
would add to all.

> Unless the userspace in the guests is creating lots of pages full of
> zeroes :)

One question comes to mind though, why is the app doing memset(0), if
the app limited itself to just reading the memory it'd use page
colored zero pages that wouldn't risk to become PageKsm. That is true
both for bare metal and guest with KSM in host. This looks a not
optimal app.

> Honestly I don't think this patch will bring any benefits regarding
> metadata -- one page more or less in the metadata won't change much. Our
> issue is just the reading speed of the deduplicated empty pages.

The metadata amount changes, for each shared zero page we'd need to
allocate a rmap_item.

The KSMscale introducing stable_node_chain/dup is precisely meant to
deal with not creating a too large rmap_item chain. Because there can
be plenty of those rmap_items, we've to create multiple zero pages and
multiple stable nodes for those zero pages to limit the maximum number
of rmap_items linked in a stable_node. This then limits the maximum
cost of a rmap_walk on a PageKsm during page migration for compaction
or swapping etc..

The KSMscale fix is needed regardless to avoid KSM to hang a very
large server, because there is no guarantee the most equal page will
be a zero page, it could be 0xff or anything.

However if one knows there's a disproportionate amount of memory as
zero (i.e. certain guest OS do that, that to me would be the main
motivation for the patch), he could prefer to use your sysctl instead
of creating the rmap_item metadata on the zero pages.

> > memcpy for every merge-candidate page to save some metadata, it's very
> 
> I'm confused, why memcpy? did you mean memcmp? We are not doing any
> additional memops except in the case when a candidate non-empty page
> happens to have the same checksum as an empty page, in which case we
> have an extra memcmp compared to the normal operation.

I meant memcmp sorry. So if this is further filtered by the
precomputed zero page cksum, the only concern would be then how likely
the cksum would provide a false positive, in which case there will be
one more memcmp for every merge.

> Maybe an even less intrusive change could be to check in replace_page if
> is_zero_pfn(page_to_pfn(kpage)). And of course I would #ifdef that too,
> to avoid the overhead for archs without page coloring.

It's just one branch, the costly things are memcmp. As long as it's
not memcmp I wouldn't worry about one branch in replace_page and in
the caller. replace_page isn't even a fast path, the fast path is
generally the code that scans the memory. The actual real merging is
not as frequent. So I wouldn't use #ifdefs and I'd use the sysctl
instead, potentially also enabled on all archs (or only on those with
page coloring but possible to enable manually on all archs).

> So if the replacement page is a ZERO_PAGE() no get_page() and no
> page_add_anon_rmap() would be performed, and the set_pte_at_notify()
> would have pte_mkspecial(pfn_pte(page_to_pfn(kpage))) instead of mk_pte() .

That should fix your patch I think yes.

Singling out zero pages was discussed before, just without KSMscale
it's an incomplete fix and just a band aid.

Actually even for your case it's incomplete and only covers a subset
of apps, what if the app initializes all ram to 0xff instead of zero
and keep reading from it? (it would make more sense to initialize the
memory if it wasn't zero in fact) You'd get the same slowdown as you
get now with the same zero page I think.

The real fix also for this, would have to have a stable tree for each
page color possible, but that is not the same as a having a stable
tree for each NUMA node (which is already implemented). There are
likely too many colors (even if you're not fully associative) so you'd
penalize the "compression" ratio if you were to implement a generic
fix that doesn't single out the zero page.

I've never been particularly excited about optimizing bad apps that
initialize a lot of RAM as zero when they could depend on the mmap
behavior instead and get zero pages in the first place (or bad guest
OS). Overall the main reason why I'm quite positive about adding this
as an optimization is because after reading it (even if not complete)
it seems non intrusive enough and some corner case may benefit, but if
we do it, we can as well leave it available to all archs so it's
easier to test and reproduce any problem too.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
