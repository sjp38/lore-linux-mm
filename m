Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 50F8C6B0007
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 13:35:41 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 18-v6so9183800pgn.4
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 10:35:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p5-v6si42427190pga.576.2018.11.05.10.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 10:35:40 -0800 (PST)
Date: Mon, 5 Nov 2018 19:35:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/1] memory_hotplug: fix the panic when memory end is
 not
Message-ID: <20181105183533.GQ4361@dhcp22.suse.cz>
References: <20181105150401.97287-1-zaslonko@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105150401.97287-1-zaslonko@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

On Mon 05-11-18 16:04:00, Mikhail Zaslonko wrote:
[...]
> Another approach was to fix memmap_init() and initialize struct pages
> beyond the end.

Yes I still do not want to give up at least this option. We do have
struct pages for the full section. Leaving som of them uninitialized is
just asking for problems. And adding special cases to some hotplug paths
just makes the code harder to follow and maintain.

So

> Since struct pages are allocated section-wise we can try to
> round the size parameter passed to the memmap_init() function up to the
> section boundary thus forcing the mapping initialization for the entire
> section. But then it leads to another VM_BUG_ON panic due to
> zone_spans_pfn() sanity check triggered for the first page of each page
> block from set_pageblock_migratetype() function:
>  page dumped because: VM_BUG_ON_PAGE(!zone_spans_pfn(page_zone(page), pfn))
>       Call Trace:
>       ([<00000000003013f8>] set_pfnblock_flags_mask+0xe8/0x140)
>        [<00000000003014aa>] set_pageblock_migratetype+0x5a/0x70
>        [<0000000000bef706>] memmap_init_zone+0x25e/0x2e0
>        [<00000000010fc3d8>] free_area_init_node+0x530/0x558
>        [<00000000010fcf02>] free_area_init_nodes+0x81a/0x8f0
>        [<00000000010e7fdc>] paging_init+0x124/0x130
>        [<00000000010e4dfa>] setup_arch+0xbf2/0xcc8
>        [<00000000010de9e6>] start_kernel+0x7e/0x588
>        [<000000000010007c>] startup_continue+0x7c/0x300
>       Last Breaking-Event-Address:
>        [<00000000003013f8>] set_pfnblock_flags_mask+0xe8/0x1401
> We might ignore this check for the struct pages beyond the "end" but I'm not
> sure about further implications.

find out all these implictions or do something like below (untested)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a919ba5cb3c8..a3f9ad8e40ee 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5544,6 +5544,21 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			cond_resched();
 		}
 	}
+
+#ifdef CONFIG_SPARSEMEM
+	/*
+	 * If we do not have a zone which doesn't span the rest of the
+	 * section then we should at least initialize those pages. We
+	 * could blow up on a poisoned page in some paths which depend
+	 * on full pageblocks being allocated (e.g. memory hotplug).
+	 */
+	while (end_pfn % PAGES_PER_SECTION) {
+		__init_single_page(pfn_to_page(end_pfn), end_pfn, zone, nid);
+		end_pfn++
+	}
+
+#endif
+
 }
 
 #ifdef CONFIG_ZONE_DEVICE
-- 
Michal Hocko
SUSE Labs
