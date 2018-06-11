Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 399026B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 08:11:33 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id a5-v6so11962199plp.8
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 05:11:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d66-v6si17744898pgc.141.2018.06.11.05.11.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 05:11:31 -0700 (PDT)
Date: Mon, 11 Jun 2018 05:11:29 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Distinguishing VMalloc pages
Message-ID: <20180611121129.GB12912@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org


I think we all like the idea of being able to look at a page [1] and
determine what it's used for.  We have two places that we already look:

PageSlab
page_type

It's not possible to use page_type for VMalloc pages because that field
is in use for mapcount.  We don't want to use another page flag bit.

I tried to use the page->mapping field in my earlier patch and that was
a problem because page_mapping() would return non-NULL, which broke
user-space unmapping of vmalloced pages through the zap_pte_range ->
set_page_dirty path.

I can see two alternatives to pursue here.  One is that we already have
special casing in page_mapping():

 	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
 		return NULL;

So changing:
-#define MAPPING_VMalloc                (void *)0x440
+#define MAPPING_VMalloc                (void *)0x441

in my original patch would lead to page_mapping() returning NULL.
Are there other paths where having a special value in page->mapping is
going to cause a problem?  Indeed, is having the PAGE_MAPPING_ANON bit
set in these pages going to cause a problem?  I just don't know those
code paths well enough.

Another possibility is putting a special value in one of the other
fields of struct page.

1. page->private is not available; everybody uses that field for
everything already, and there's no way that any value could be special
enough to be unique.
2. page->index (on 32-bit systems) can already have all possible values.
3. page->lru.  The second word is already used for many random things,
but the first word is always either a pointer or compound_head (with
bit 0 set).  So we could use a set of values with bits 0 & 1 clear, and
below 4kB (ie 1023 values total) to distinguish pages.

Any preferences/recommendations/words of warning?

[1] It may be helpful to refer to the 'new64' tab for a visual depiction:
https://docs.google.com/spreadsheets/d/1tvCszs_7FXrjei9_mtFiKV6nW1FLnYyvPvW-qNZhdog/edit#gid=1941250461
