Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2698DC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:25:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF0F1229F9
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:25:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF0F1229F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FE926B0006; Fri, 26 Jul 2019 05:25:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AE3A6B0007; Fri, 26 Jul 2019 05:25:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6777F6B0008; Fri, 26 Jul 2019 05:25:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4066B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:25:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w25so33721307edu.11
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:25:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DOcmVBSItfpur+2E1WbmgGbzf2c8cv4VtZWGMAIKoiY=;
        b=ORksB/WZZ7aEgCMlRy/Sj7G8QbeT5hDURPjz/WhizHnFD7T25xOQvokol5f+pQ4bzp
         Ng4dI9uIB+RPu8zkFikR5Om/k3IM2wgR7pjNM+qpdj2Z9PRsc1MmhVS71O3mHgJOyH3K
         6cOmD1MuqiMa4TzYjownVb674hApRqvOJuimDz1zaANXf01t4mH7I2sJdUDuaQhMzF+f
         052zvEsnoxdrstfxTFJAVKeCaU/mOcuVlM+S1/wUWl19nZqdXJ97HNDIaRikSovYTSnd
         x/fiuznco1OtHJvNSxYO9Zg5n2zXF13wurgG1VbEjdw9/ptdDSZlyLf3ansHDhU78lPs
         rIUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAV1+JZch2BYrKp4NSKYZMf124zeftfiF2DSbdm9P+ZPg7YRS7MT
	mQakpUHWYysifB9/8N35F6bXF/x/HeVZdUd3Z7acs2doZ+iQ4ijQF4Ncl7fH/pbnSU/YNuiWCXv
	Z18QoPKqVJIcu+CvIp2teIsDDz0sdH11ym1cX/UQHwrLQYHkHAZTLXMlaPF8bFMNqdw==
X-Received: by 2002:a50:b617:: with SMTP id b23mr81119009ede.135.1564133156645;
        Fri, 26 Jul 2019 02:25:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKJiisxg+h0ZRDlXEZfnq4VEjQOxiQMgSG+PL0hNYRjQdH67xj/oyd1p1HXjWiiQAIRv9O
X-Received: by 2002:a50:b617:: with SMTP id b23mr81118963ede.135.1564133155871;
        Fri, 26 Jul 2019 02:25:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564133155; cv=none;
        d=google.com; s=arc-20160816;
        b=g6TjXhEw3hZndLKDTjsDXmpg7ukJpNWPzchba9P34i7XxuQWFy9YQTtrzOTucpf1Qt
         vRxbEiq829+7UylDnUSNJeVQimyV9IWfLZqbte+XcxUXXkHYhbgqJptBU+5yULISge7U
         DiVaKWnrVVI7so98c6+95HruK6nEHgSOPzPupfwVN6OpMQ8F5FpOWfwJwpu1ooGfp7We
         bkwvwCufDYUYhD6j/TSaPhVaQ0Yvj4uJLJhnRgcfsIWgJYzJQGFwQfXP75GDd9GBMi89
         CaSZu1RjqvaseF+U7Y9Jgm2TMqe77dN9/E6HNE24Kof2lrdRBvJ0vTpUfZmQCJ/GHJ7Q
         JPbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DOcmVBSItfpur+2E1WbmgGbzf2c8cv4VtZWGMAIKoiY=;
        b=0t80+nS93ZI0GiWQWTEJcIXEWD6Q6iCAbMPgeybAEn+KfSdu09CBT4puGeqS90rXzn
         +uGZA9Rpjef9cL0+QmQsYDhl5GDboOiDylsFfcM5HX/Bqd6JDn2Qi+9wK7XuvjlWGmVd
         XEX2lOObfdkClJ8onxCasXqLdgKX3+689v0TlMiABTcClJnqAtYTOxzysWcJeBuXgvsV
         cP6w27FUPr31QPWPuvHgPMmycQqomY6LNLoSkQ9TW5kjglMsgEhPRbWtNtfNgRVnf12z
         irV2hdy05Dm45J54uFMTO/fO9cXQW0hH8pAKDthILuc4UGy+IrWDvqxIs5EPb8SxZZIC
         TpbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t20si11984226eda.247.2019.07.26.02.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 02:25:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3E144B603;
	Fri, 26 Jul 2019 09:25:55 +0000 (UTC)
Date: Fri, 26 Jul 2019 11:25:52 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, mhocko@suse.com,
	anshuman.khandual@arm.com, Jonathan.Cameron@huawei.com,
	vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 2/5] mm: Introduce a new Vmemmap page-type
Message-ID: <20190726092548.GA26268@linux>
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190725160207.19579-3-osalvador@suse.de>
 <7e8746ac-6a66-d73c-9f2a-4fc53c7e4c04@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7e8746ac-6a66-d73c-9f2a-4fc53c7e4c04@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 10:48:54AM +0200, David Hildenbrand wrote:
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> > ---
> >  include/linux/mm.h         | 17 +++++++++++++++++
> >  include/linux/mm_types.h   |  5 +++++
> >  include/linux/page-flags.h | 19 +++++++++++++++++++
> >  3 files changed, 41 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 45f0ab0ed4f7..432175f8f8d2 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -2904,6 +2904,23 @@ static inline bool debug_guardpage_enabled(void) { return false; }
> >  static inline bool page_is_guard(struct page *page) { return false; }
> >  #endif /* CONFIG_DEBUG_PAGEALLOC */
> >  
> > +static __always_inline struct page *vmemmap_head(struct page *page)
> > +{
> > +	return (struct page *)page->vmemmap_head;
> > +}
> > +
> > +static __always_inline unsigned long vmemmap_nr_sections(struct page *page)
> > +{
> > +	struct page *head = vmemmap_head(page);
> > +	return head->vmemmap_sections;
> > +}
> > +
> > +static __always_inline unsigned long vmemmap_nr_pages(struct page *page)
> > +{
> > +	struct page *head = vmemmap_head(page);
> > +	return head->vmemmap_pages - (page - head);
> > +}
> > +
> >  #if MAX_NUMNODES > 1
> >  void __init setup_nr_node_ids(void);
> >  #else
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 6a7a1083b6fb..51dd227f2a6b 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -170,6 +170,11 @@ struct page {
> >  			 * pmem backed DAX files are mapped.
> >  			 */
> >  		};
> > +		struct {        /* Vmemmap pages */
> > +			unsigned long vmemmap_head;
> > +			unsigned long vmemmap_sections; /* Number of sections */
> > +			unsigned long vmemmap_pages;    /* Number of pages */
> > +		};
> >  
> >  		/** @rcu_head: You can use this to free a page by RCU. */
> >  		struct rcu_head rcu_head;
> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > index f91cb8898ff0..75f302a532f9 100644
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -708,6 +708,7 @@ PAGEFLAG_FALSE(DoubleMap)
> >  #define PG_kmemcg	0x00000200
> >  #define PG_table	0x00000400
> >  #define PG_guard	0x00000800
> > +#define PG_vmemmap     0x00001000
> >  
> >  #define PageType(page, flag)						\
> >  	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
> > @@ -764,6 +765,24 @@ PAGE_TYPE_OPS(Table, table)
> >   */
> >  PAGE_TYPE_OPS(Guard, guard)
> >  
> > +/*
> > + * Vmemmap pages refers to those pages that are used to create the memmap
> > + * array, and reside within the same memory range that was hotppluged, so
> > + * they are self-hosted. (see include/linux/memory_hotplug.h)
> > + */
> > +PAGE_TYPE_OPS(Vmemmap, vmemmap)
> > +static __always_inline void SetPageVmemmap(struct page *page)
> > +{
> > +	__SetPageVmemmap(page);
> > +	__SetPageReserved(page);
> 
> So, the issue with some vmemmap pages is that the "struct pages" reside
> on the memory they manage. (it is nice, but complicated - e.g. when
> onlining/offlining)

Hi David,

Not really.
Vemmap pages are just skipped when onling/offlining handling.
We do not need them to a) send to the buddy and b) migrate them over.
A look at patch#4 will probably help, as the crux of the matter is there.

> 
> I would expect that you properly initialize the struct pages for the
> vmemmap pages (now it gets confusing :) ) when adding memory. The other
> struct pages are initialized when onlining/offlining.
> 
> So, at this point, the pages should already be marked reserved, no? Or
> are the struct pages for the vmemmap never initialized?
> 
> What zone do these vmemmap pages have? They are not assigned to any zone
> and will never be :/

This patch is only a preparation, the real "fun" is in patch#4.

Vmemmap pages initialization occurs in mhp_mark_vmemmap_pages, called from
__add_pages() (patch#4).
In there we a) mark the page as vmemmap and b) initialize the fields we need to
track some medata (sections, pages and head).

In __init_single_page(), when onlining, the rest of the fields will be set up
properly (zone, refcount, etc).

Chunk from patch#4:

static void __meminit __init_single_page(struct page *page, unsigned long pfn,
                                unsigned long zone, int nid)
{
        if (PageVmemmap(page))
                /*
                 * Vmemmap pages need to preserve their state.
                 */
                goto preserve_state;

        mm_zero_struct_page(page);
        page_mapcount_reset(page);
        INIT_LIST_HEAD(&page->lru);
preserve_state:
        init_page_count(page);
        set_page_links(page, zone, nid, pfn);
        page_cpupid_reset_last(page);
        page_kasan_tag_reset(page);

So, vmemmap pages will fall within the same zone as the range we are adding,
that does not change.

> > +}
> > +
> > +static __always_inline void ClearPageVmemmap(struct page *page)
> > +{
> > +	__ClearPageVmemmap(page);
> > +	__ClearPageReserved(page);
> 
> You sure you want to clear the reserved flag here? Is this function
> really needed?
> 
> (when you add memory, you can mark all relevant pages as vmemmap pages,
> which is valid until removing the memory)
> 
> Let's draw a picture so I am not confused
> 
> [ ------ added memory ------ ]
> [ vmemmap]
> 
> The first page of the added memory is a vmemmap page AND contains its
> own vmemmap, right?

Not only the first page.
Depending on how large is the chunk you are adding, the number of vmemmap
pages will vary, because we need to cover the memmaps for the range.

e.g:

 - 128MB (1 section) = 512 vmemmap pages at the beginning of the range
 - 256MB (2 section) = 1024 vmemmap pages at the beginning of the range
 ...

> When adding memory, you would initialize set all struct pages of the
> vmemmap (residing on itself) and set them to SetPageVmemmap().
> 
> When removing memory, there is nothing to do, all struct pages are
> dropped. So why do we need the ClearPageVmemmap() ?

Well, it is not really needed as we only call ClearPageVmemmap when we are
actually removing the memory with vmemmap_free()->...
So one could argue that since the memory is going away, there is no need
to clear anything in there.

I just made it for consistency purposes.

Can drop it if feeling strong here.

-- 
Oscar Salvador
SUSE L3

