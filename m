Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53DCD6B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 12:17:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so24169893pfb.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 09:17:17 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a18si773036pgn.328.2017.01.18.09.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 09:17:16 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0IHGon5039283
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 12:17:15 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0a-001b2d01.pphosted.com with ESMTP id 282b6wch8v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 12:17:15 -0500
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Wed, 18 Jan 2017 17:17:12 -0000
Subject: Re: [PATCH v1 1/1] mm/ksm: improve deduplication of zero pages with
 colouring
References: <1484237834-15803-1-git-send-email-imbrenda@linux.vnet.ibm.com>
 <20170112172132.GM4947@redhat.com>
 <1e1e7589-9713-e6a4-f57c-bfd94eb3e1e9@linux.vnet.ibm.com>
 <20170118162914.GF10177@redhat.com>
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Date: Wed, 18 Jan 2017 18:17:09 +0100
MIME-Version: 1.0
In-Reply-To: <20170118162914.GF10177@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <4ac20fb0-d9d2-e73f-2f17-1f69929756b7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, borntraeger@de.ibm.com, hughd@google.com, izik.eidus@ravellosystems.com, chrisw@sous-sol.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On 18/01/17 17:29, Andrea Arcangeli wrote:
> It's still good to be able to exercise this code on all archs (if
> nothing else for debugging purposes). There's nothing arch dependent
> in it after all.

If it's fine for you, I'm definitely not going to complain :)

>> ZERO_PAGE() would save exactly one page and it would bring no speed
>> advantages (or rather: not using the ZERO_PAGE() would not bring any
>> speed penalty).
>> That's why I have #ifdef'd it to have it only when page coloring is
>> present. Also, for what I could see, only MIPS and s390 have page
>> coloring; I don't like the idea of imposing any overhead to all the
>> other archs.
> 
> With a sysctl disabled by default, the only overhead is 8 bytes and a
> branch?

Yes, I'm sometimes excessively paranoid.

>> I agree that this should be toggleable with a sysfs control, since it's
>> a change that can potentially negatively affect the performance in some
>> cases. I'm adding it in the next iteration.
> 
> Yes the sysctl can be useful for archs doing page coloring too, but I
> would add to all.
> 
>> Unless the userspace in the guests is creating lots of pages full of
>> zeroes :)
> 
> One question comes to mind though, why is the app doing memset(0), if
> the app limited itself to just reading the memory it'd use page
> colored zero pages that wouldn't risk to become PageKsm. That is true
> both for bare metal and guest with KSM in host. This looks a not
> optimal app.

I didn't really make a good example, although I can think of scenarios
where that could legitimately happen. Another case would be a KVM guest.
It will have a bunch of colored zero pages somewhere, but if KSM merges
those together, the advantages of colored zero pages disappear in the guest.

>> Honestly I don't think this patch will bring any benefits regarding
>> metadata -- one page more or less in the metadata won't change much. Our
>> issue is just the reading speed of the deduplicated empty pages.
> 
> The metadata amount changes, for each shared zero page we'd need to
> allocate a rmap_item.
> 
> The KSMscale introducing stable_node_chain/dup is precisely meant to
> deal with not creating a too large rmap_item chain. Because there can
> be plenty of those rmap_items, we've to create multiple zero pages and
> multiple stable nodes for those zero pages to limit the maximum number
> of rmap_items linked in a stable_node. This then limits the maximum
> cost of a rmap_walk on a PageKsm during page migration for compaction
> or swapping etc..
> 
> The KSMscale fix is needed regardless to avoid KSM to hang a very
> large server, because there is no guarantee the most equal page will
> be a zero page, it could be 0xff or anything.
> 
> However if one knows there's a disproportionate amount of memory as
> zero (i.e. certain guest OS do that, that to me would be the main
> motivation for the patch), he could prefer to use your sysctl instead
> of creating the rmap_item metadata on the zero pages.

Ok, sorry, I had completely misunderstood what you had meant the first
time. Now I got it.

>>> memcpy for every merge-candidate page to save some metadata, it's very
>>
>> I'm confused, why memcpy? did you mean memcmp? We are not doing any
>> additional memops except in the case when a candidate non-empty page
>> happens to have the same checksum as an empty page, in which case we
>> have an extra memcmp compared to the normal operation.
> 
> I meant memcmp sorry. So if this is further filtered by the
> precomputed zero page cksum, the only concern would be then how likely
> the cksum would provide a false positive, in which case there will be
> one more memcmp for every merge.
> 
>> Maybe an even less intrusive change could be to check in replace_page if
>> is_zero_pfn(page_to_pfn(kpage)). And of course I would #ifdef that too,
>> to avoid the overhead for archs without page coloring.
> 
> It's just one branch, the costly things are memcmp. As long as it's
> not memcmp I wouldn't worry about one branch in replace_page and in
> the caller. replace_page isn't even a fast path, the fast path is
> generally the code that scans the memory. The actual real merging is
> not as frequent. So I wouldn't use #ifdefs and I'd use the sysctl
> instead, potentially also enabled on all archs (or only on those with
> page coloring but possible to enable manually on all archs).

Ok!

>> So if the replacement page is a ZERO_PAGE() no get_page() and no
>> page_add_anon_rmap() would be performed, and the set_pte_at_notify()
>> would have pte_mkspecial(pfn_pte(page_to_pfn(kpage))) instead of mk_pte() .
> 
> That should fix your patch I think yes.
> 
> Singling out zero pages was discussed before, just without KSMscale
> it's an incomplete fix and just a band aid.
> 
> Actually even for your case it's incomplete and only covers a subset
> of apps, what if the app initializes all ram to 0xff instead of zero
> and keep reading from it? (it would make more sense to initialize the
> memory if it wasn't zero in fact) You'd get the same slowdown as you
> get now with the same zero page I think.

That's true. As I said above, my previous example was not very well
thought. The more realistic scenario is that of having the colored zero
pages of a guest merged.

> The real fix also for this, would have to have a stable tree for each
> page color possible, but that is not the same as a having a stable
> tree for each NUMA node (which is already implemented). There are
> likely too many colors (even if you're not fully associative) so you'd
> penalize the "compression" ratio if you were to implement a generic
> fix that doesn't single out the zero page.

Also in general it's not probable that the same non-zero data will be
read very often at different guest-physical addresses. A stable tree for
each color would pretty much defeat the purpose of KSM.

> I've never been particularly excited about optimizing bad apps that
> initialize a lot of RAM as zero when they could depend on the mmap
> behavior instead and get zero pages in the first place (or bad guest
> OS). Overall the main reason why I'm quite positive about adding this
> as an optimization is because after reading it (even if not complete)
> it seems non intrusive enough and some corner case may benefit, but if
> we do it, we can as well leave it available to all archs so it's
> easier to test and reproduce any problem too.

Ok, I'll fix and respin my patch then.

Thanks,

Claudio

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
