Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id B996A6B0032
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 16:38:41 -0400 (EDT)
Received: by qgfh3 with SMTP id h3so24227686qgf.13
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 13:38:41 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id f135si1967080qhe.122.2015.03.08.13.38.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Mar 2015 13:38:41 -0700 (PDT)
Received: by qgdz60 with SMTP id z60so24271457qgd.5
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 13:38:40 -0700 (PDT)
Date: Sun, 8 Mar 2015 16:38:39 -0400
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm: hangs in free_pages_prepare
Message-ID: <20150308203838.GA10442@dhcp22.suse.cz>
References: <54FB4590.20102@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54FB4590.20102@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm >> Andrew Morton" <akpm@linux-foundation.org>

On Sat 07-03-15 13:38:08, Sasha Levin wrote:
[...]
> [ 1573.730097] ? kasan_free_pages (mm/kasan/kasan.c:301)
> [ 1573.788680] free_pages_prepare (mm/page_alloc.c:791)
> [ 1573.788680] ? free_hot_cold_page (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) mm/page_alloc.c:1579 (discriminator 2))
> [ 1573.788680] free_hot_cold_page (mm/page_alloc.c:1543)
> [ 1573.788680] __free_pages (mm/page_alloc.c:2957)
> [ 1573.788680] ? __vunmap (mm/vmalloc.c:1460 (discriminator 2))
> [ 1573.788680] __vunmap (mm/vmalloc.c:1460 (discriminator 2))

__vunmap is doing:
                for (i = 0; i < area->nr_pages; i++) {
                        struct page *page = area->pages[i];

                        BUG_ON(!page);
                        __free_page(page);
                }

is it possible that nr_pages is a huge number (a large vmalloc area)? I
do not see any cond_resched down __free_page path at least. vfree
delayes the call to workqueue when called from irq context and vunmap is
marked as might_sleep). So to me it looks like it would be safe. Something
for vmalloc familiar people, though.

Anyway, the loop seems to be there since ages so I guess somebody just
started calling vmalloc for huge areas recently so it shown up.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
