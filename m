Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B9A2C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 22:36:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D01772081B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 22:36:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RJbuSDeb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D01772081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B40B8E0003; Thu,  7 Mar 2019 17:36:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4646C8E0002; Thu,  7 Mar 2019 17:36:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 352898E0003; Thu,  7 Mar 2019 17:36:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7538E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 17:36:06 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id h3so10347916itb.4
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 14:36:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ekxiUXeLJ2RIYTCQxRaX4seXlOohBS+8PUfBLLMLNlA=;
        b=EthdE135EuMxZCfjkuaEbFJP548/o8gn1S5utzO1j18B6F0DCV7UfuFNhuAMH3Dv/n
         syrJWAAyPnNTVzZZ7srihW0X9kXhWC6QE40yvEbm4NbIBeLbIZmhKlTzasiwlSgvf5LD
         P/QOnn3loCovdXs+i/1wgh8rxv3mqmoa0NJ0XsgT8JlBYmFqReycePCp342C6lCJSm8y
         UufewwKOZ6bnnkgeEWM3QJaj7/1ejWYiwiL/egyb/EDaEaal6d01FMtdDe3NNriPaQFs
         OL6qfWra+YElaoGtWHi44urTkkW8drVrOibGQyDrR0Qt38L2z3wHE2twuxvNsfTVj5dE
         acpA==
X-Gm-Message-State: APjAAAUkdQPtPDLnV6ifN2d5dnkYvq9KmrFS1wtNi0fD/YzuuvYJdJt0
	FTdvXlDPj8p6nnv2dIjZ8cn3ZruKXGerYw3f1ziEAhCl8NrE3DVAfju2tdGmBSmZZxM63JUplns
	WsKhT09lE6DeraohGMGLGdw/AeNoeLvbuuoVpBQpkT6XPNMLpTDtEG4ZUoHWzFtuBYDszeZo+b/
	uQMuPccXbJE2la3xtwzpwCf373uAmbcaar2xMmGrHzOjGZVGaU2VtAKHhhak47Q27E4HIfyQpHm
	XmTGRnyCWpX5qUCKLkroB9Lx9hZR9RfaHIb0w0KWesoEaHxAu88C+Rrqg4kbOwv09tpqrEEwKjh
	MVWn6V9V+RWLzOCGqxXzytdejqckAhw6qZiz+fHt+Biz2RdanFmVQQlnEBoUwwT6c7I82Gk8L7z
	H
X-Received: by 2002:a5d:9053:: with SMTP id v19mr8342350ioq.49.1551998165701;
        Thu, 07 Mar 2019 14:36:05 -0800 (PST)
X-Received: by 2002:a5d:9053:: with SMTP id v19mr8342316ioq.49.1551998164535;
        Thu, 07 Mar 2019 14:36:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551998164; cv=none;
        d=google.com; s=arc-20160816;
        b=Hiik4bYniwCOp0KDTFs4mYVL9oAehqCyhl+WRfGBjXiXEzwuF6TZ1ehYUwFpbk6vZ0
         imXbo5LJn9NxlnZI6nQmm6Bq3W6FgZBYySeB86hpg3N0RVkH6d+sKZEp/SW7P8HcH7WK
         iLpT7BLiw3c0fD0PPkBjVNqtEzgCr4elS0Sh3RWT4JplSrRyMpuv3TOr2J60oK8U1YEi
         TNGpN/kyZ9NlOuxGr0Gy/qmTxcSGf+/soLiJlmQTnK+3pMfRUvL5RMlWodtOoDrPMXK6
         D+JvIbWrXxJiuq5f0qz7M+IxNjVAaq3Rw1p5ivdQY3idbWZLhuztDSW9xMKih2GVb19U
         jlUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ekxiUXeLJ2RIYTCQxRaX4seXlOohBS+8PUfBLLMLNlA=;
        b=kbm6Emo4OsUqC4LqiISa8TT+nZYYYYRvGNC+f0HoVoUN4AxPWUwJK0iBdPZIBG87BC
         o48zq5gZiqyj9Qq1wFfzGjTME6LIjE6xCkFznLNyScOqWAS08zGqZUyIAIqhbUIq2T7v
         QJUlFCLWCYXYs6XUay3Ix5+gglsU7zpgjC/uivLeIcqmw9vat/UvId1950P7nYwpZska
         c79XrYhomKov+GsvlVzPYbpPzItAd7SJtm+UYC+bwo9LrMDi8Llok1Krn7uDNTCEPw2Y
         L3LaA4mItvrrRSBLDFsa/DSGMA7+BKUNaqkpma1qeZwLnbv+6yFOOBFFJrxdYeT26CuX
         EIig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RJbuSDeb;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h16sor11745707itb.18.2019.03.07.14.36.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 14:36:04 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RJbuSDeb;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ekxiUXeLJ2RIYTCQxRaX4seXlOohBS+8PUfBLLMLNlA=;
        b=RJbuSDebtolMBUcZ5Slh2zwxszBKn0q39a5N3hmItvKWPvUS82rg97qqDRLbYGxedH
         zNb0gg0nbQmBot72AUdpid1A2Rwxh16f7yNEEh3FDaT9BbwkXrqGoPF1fgh5nl9SyLnl
         vTzEt1SqGTCnepLaBhGNQF6qPQMWbOlQvu8n/XnJiSZMXwuzZMxbRdag0gRnuNaxcQIR
         CfWrsFPH6ZZQ8jrVh4TL+65FmbqWpWMk8NKDnoz+tyZZWhHPLZg4rpWEFLwVfEPerkEX
         jLgJ1FJ35WlBQ7iM+A6K0vJnyt8Od6RDaWct2l5WiRpp+BTAptlsLTluiQhBCNURN2sC
         3+Qg==
X-Google-Smtp-Source: APXvYqz8vigw8jNXF+Vo2OeIkFKa1/H/Li6ea8Fog2hmvDjvTSi8mWVFdfyK+nX4OmAQYExf2UVYRi7rvxcfIbM7pMc=
X-Received: by 2002:a24:45e3:: with SMTP id c96mr6297486itd.89.1551998163941;
 Thu, 07 Mar 2019 14:36:03 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com> <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com> <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
In-Reply-To: <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 7 Mar 2019 14:35:53 -0800
Message-ID: <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free pages
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 7, 2019 at 1:40 PM David Hildenbrand <david@redhat.com> wrote:
>
> On 07.03.19 22:32, Alexander Duyck wrote:
> > On Thu, Mar 7, 2019 at 11:30 AM David Hildenbrand <david@redhat.com> wrote:
> >>
> >> On 07.03.19 20:23, Nitesh Narayan Lal wrote:
> >>>
> >>> On 3/7/19 1:30 PM, Alexander Duyck wrote:
> >>>> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>>>> This patch enables the kernel to scan the per cpu array
> >>>>> which carries head pages from the buddy free list of order
> >>>>> FREE_PAGE_HINTING_MIN_ORDER (MAX_ORDER - 1) by
> >>>>> guest_free_page_hinting().
> >>>>> guest_free_page_hinting() scans the entire per cpu array by
> >>>>> acquiring a zone lock corresponding to the pages which are
> >>>>> being scanned. If the page is still free and present in the
> >>>>> buddy it tries to isolate the page and adds it to a
> >>>>> dynamically allocated array.
> >>>>>
> >>>>> Once this scanning process is complete and if there are any
> >>>>> isolated pages added to the dynamically allocated array
> >>>>> guest_free_page_report() is invoked. However, before this the
> >>>>> per-cpu array index is reset so that it can continue capturing
> >>>>> the pages from buddy free list.
> >>>>>
> >>>>> In this patch guest_free_page_report() simply releases the pages back
> >>>>> to the buddy by using __free_one_page()
> >>>>>
> >>>>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> >>>> I'm pretty sure this code is not thread safe and has a few various issues.
> >>>>
> >>>>> ---
> >>>>>  include/linux/page_hinting.h |   5 ++
> >>>>>  mm/page_alloc.c              |   2 +-
> >>>>>  virt/kvm/page_hinting.c      | 154 +++++++++++++++++++++++++++++++++++
> >>>>>  3 files changed, 160 insertions(+), 1 deletion(-)
> >>>>>
> >>>>> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting.h
> >>>>> index 90254c582789..d554a2581826 100644
> >>>>> --- a/include/linux/page_hinting.h
> >>>>> +++ b/include/linux/page_hinting.h
> >>>>> @@ -13,3 +13,8 @@
> >>>>>
> >>>>>  void guest_free_page_enqueue(struct page *page, int order);
> >>>>>  void guest_free_page_try_hinting(void);
> >>>>> +extern int __isolate_free_page(struct page *page, unsigned int order);
> >>>>> +extern void __free_one_page(struct page *page, unsigned long pfn,
> >>>>> +                           struct zone *zone, unsigned int order,
> >>>>> +                           int migratetype);
> >>>>> +void release_buddy_pages(void *obj_to_free, int entries);
> >>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>>>> index 684d047f33ee..d38b7eea207b 100644
> >>>>> --- a/mm/page_alloc.c
> >>>>> +++ b/mm/page_alloc.c
> >>>>> @@ -814,7 +814,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
> >>>>>   * -- nyc
> >>>>>   */
> >>>>>
> >>>>> -static inline void __free_one_page(struct page *page,
> >>>>> +inline void __free_one_page(struct page *page,
> >>>>>                 unsigned long pfn,
> >>>>>                 struct zone *zone, unsigned int order,
> >>>>>                 int migratetype)
> >>>>> diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
> >>>>> index 48b4b5e796b0..9885b372b5a9 100644
> >>>>> --- a/virt/kvm/page_hinting.c
> >>>>> +++ b/virt/kvm/page_hinting.c
> >>>>> @@ -1,5 +1,9 @@
> >>>>>  #include <linux/mm.h>
> >>>>>  #include <linux/page_hinting.h>
> >>>>> +#include <linux/page_ref.h>
> >>>>> +#include <linux/kvm_host.h>
> >>>>> +#include <linux/kernel.h>
> >>>>> +#include <linux/sort.h>
> >>>>>
> >>>>>  /*
> >>>>>   * struct guest_free_pages- holds array of guest freed PFN's along with an
> >>>>> @@ -16,6 +20,54 @@ struct guest_free_pages {
> >>>>>
> >>>>>  DEFINE_PER_CPU(struct guest_free_pages, free_pages_obj);
> >>>>>
> >>>>> +/*
> >>>>> + * struct guest_isolated_pages- holds the buddy isolated pages which are
> >>>>> + * supposed to be freed by the host.
> >>>>> + * @pfn: page frame number for the isolated page.
> >>>>> + * @order: order of the isolated page.
> >>>>> + */
> >>>>> +struct guest_isolated_pages {
> >>>>> +       unsigned long pfn;
> >>>>> +       unsigned int order;
> >>>>> +};
> >>>>> +
> >>>>> +void release_buddy_pages(void *obj_to_free, int entries)
> >>>>> +{
> >>>>> +       int i = 0;
> >>>>> +       int mt = 0;
> >>>>> +       struct guest_isolated_pages *isolated_pages_obj = obj_to_free;
> >>>>> +
> >>>>> +       while (i < entries) {
> >>>>> +               struct page *page = pfn_to_page(isolated_pages_obj[i].pfn);
> >>>>> +
> >>>>> +               mt = get_pageblock_migratetype(page);
> >>>>> +               __free_one_page(page, page_to_pfn(page), page_zone(page),
> >>>>> +                               isolated_pages_obj[i].order, mt);
> >>>>> +               i++;
> >>>>> +       }
> >>>>> +       kfree(isolated_pages_obj);
> >>>>> +}
> >>>> You shouldn't be accessing __free_one_page without holding the zone
> >>>> lock for the page. You might consider confining yourself to one zone
> >>>> worth of hints at a time. Then you can acquire the lock once, and then
> >>>> return the memory you have freed.
> >>> That is correct.
> >>>>
> >>>> This is one of the reasons why I am thinking maybe a bit in the page
> >>>> and then spinning on that bit in arch_alloc_page might be a nice way
> >>>> to get around this. Then you only have to take the zone lock when you
> >>>> are finding the pages you want to hint on and setting the bit
> >>>> indicating they are mid hint. Otherwise you have to take the zone lock
> >>>> to pull pages out, and to put them back in and the likelihood of a
> >>>> lock collision is much higher.
> >>> Do you think adding a new flag to the page structure will be acceptable?
> >>
> >> My lesson learned: forget it. If (at all) reuse some other one that
> >> might be safe in that context. Hard to tell if that is even possible and
> >> will be accepted upstream.
> >
> > I was thinking we could probably just resort to reuse. Essentially
> > what we are looking at doing is idle page tracking so my thought is to
> > see if we can just reuse those bits in the buddy allocator. Then we
> > would essentially have 3 stages, young, "hinting", and idle.
>
> Haven't thought this through, but I wonder if 2 stages would even be
> enough right now, But well, you have a point that idle *might* reduce
> the amount of pages hinted multiple time (although that might still
> happen when we want to hint with different page sizes / buddy merging).

Splitting wouldn't be so much an issue as merging. The problem is if
you are merging pages you have to assume the page is no longer hinted,
and need to hint for the new higher order page. The worst case
scenerio would be a page that is hinted, merged, split, and then has
to be hinted again because the information on hit being hinted is
lost.

> >
> >> Spinning is not the solution. What you would want is the buddy to
> >> actually skip over these pages and only try to use them (-> spin) when
> >> OOM. Core mm changes (see my other reply).
> >
> > It is more of a workaround. Ideally we should almost never encounter
> > this anyway as what we really want to be doing is performing hints on
> > cold pages, so hopefully we will be on the other end of the LRU list
> > from any active allocations.
> >
> >> This all sounds like future work which can be built on top of this work.
> >
> > Actually I was kind of thinking about this the other way. The simple
> > spin approach is a good first step. If we have a bit or two in the
> > page that tells us if the page is available or not we could then
> > follow-up with optimizations to only allocate either a young or idle
> > page and doesn't bother with pages being "hinted", at least in the
> > first pass.
> >
> > As it currently stands we are only really performing hints on higher
> > order pages anyway so if we happen to encounter a slight delay under
> > memory pressure it probably wouldn't be that noticeable versus the
>
> Well, the issue is that with your approach one pending hinting request
> might block all other VCPUs in the worst case until hitning is done.
> Something that is not possible with Niteshs approach. It will never
> block allocation paths (well apart from the zone lock and the OOM
> thingy). And I think this is important.
>
> It is a fundamental design problem until we fix core mm. Your other
> synchronous approach doesn't have this problem either.

Even with the approach I had there are still possibilities for all
VCPUs eventually becoming hung if the host is holding the write lock
on the mmap semaphore.

My initial thought was to try and reduce the amount of time we need to
sit on the zone lock since we have to hold it to isolate the pages,
and then to put them back in the buddy. However the idle bits approach
will be just as difficult to deal with due to potential for splits and
merges while performing the hint.

> > memory system having to go through and try to compact things from some
> > lower order pages. In my mind us introducing a delay in memory
> > allocation in the case of a collision would be preferable versus us
> > triggering allocation failures.
> >
>
> Valid points, I think to see which approach would be the better starting
> point is to have a version that does what you propose and compare it.
> Essentially to find out how severe this "blocking other VCPUs" thingy
> can be.

I figure if nothing else the current solution probably is just in need
of a few tweaks. In my mind the simplest solution is still to have a
single bit somewhere for tracking what pages we have hinted on on
which ones we haven't. However we could probably skip the second bit
and just put the pages in isolation while we are performing the hint
and that would get rid of the need for a second bit.

With us hinting currently on MAX_ORDER - 1 pages only that actually
takes care of the risk of a merge really wiping out any data about
what has been hinted on and what hasn't.

The only other thing I still want to try and see if I can do is to add
a jiffies value to the page private data in the case of the buddy
pages. With that we could track the age of the page so it becomes
easier to only target pages that are truly going cold rather than
trying to grab pages that were added to the freelist recently.

