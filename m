Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82DA86B0279
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 05:54:13 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h7-v6so7316704lfc.13
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 02:54:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i25-v6sor110992lfb.5.2018.06.12.02.54.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 02:54:11 -0700 (PDT)
Subject: Re: Distinguishing VMalloc pages
References: <20180611121129.GB12912@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <c99d981a-d55e-1759-a14a-4ef856072618@gmail.com>
Date: Tue, 12 Jun 2018 12:54:09 +0300
MIME-Version: 1.0
In-Reply-To: <20180611121129.GB12912@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On 11/06/18 15:11, Matthew Wilcox wrote:
> 
> I think we all like the idea of being able to look at a page [1] and
> determine what it's used for.  We have two places that we already look:
> 
> PageSlab
> page_type
> 
> It's not possible to use page_type for VMalloc pages because that field
> is in use for mapcount.  We don't want to use another page flag bit.
> 
> I tried to use the page->mapping field in my earlier patch and that was
> a problem because page_mapping() would return non-NULL, which broke
> user-space unmapping of vmalloced pages through the zap_pte_range ->
> set_page_dirty path.

This seems pretty similar to what I am doing in a preparatory patch for
pmalloc (I'm still working on this, I just got swamped in day-job 
related stuff, but I am progressing toward an example with IMA).
So it looks like my patch won't work, after all?

Although, in your case, you noticed a problem with userspace, while I do
not care at all about that, so maybe there is some wriggling space there ...

> 
> I can see two alternatives to pursue here.  One is that we already have
> special casing in page_mapping():
> 
>   	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
>   		return NULL;
> 
> So changing:
> -#define MAPPING_VMalloc                (void *)0x440
> +#define MAPPING_VMalloc                (void *)0x441
> 
> in my original patch would lead to page_mapping() returning NULL.
> Are there other paths where having a special value in page->mapping is
> going to cause a problem?  Indeed, is having the PAGE_MAPPING_ANON bit
> set in these pages going to cause a problem?  I just don't know those
> code paths well enough.
> 
> Another possibility is putting a special value in one of the other
> fields of struct page.
> 
> 1. page->private is not available; everybody uses that field for
> everything already, and there's no way that any value could be special
> enough to be unique.
> 2. page->index (on 32-bit systems) can already have all possible values.
> 3. page->lru.  The second word is already used for many random things,
> but the first word is always either a pointer or compound_head (with
> bit 0 set).  So we could use a set of values with bits 0 & 1 clear, and
> below 4kB (ie 1023 values total) to distinguish pages.
> 
> Any preferences/recommendations/words of warning?


Why not having a reference (either direct or indirect) to the actual
vmap area, and then the flag there, instead?

I do not know the specific use case you have in mind - if any - but I
think that if one is already trying to figure out what sort of use the
vmalloc page is put to, then probably pretty soon there will be a need
for a reference to the area.

So what if the page could hold a reference the area, where there would
be more space available for specifying what it is used for?

--
igor
