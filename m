Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20B678E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 03:57:16 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id y88so12166791pfi.9
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:57:16 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 11 Dec 2018 09:57:11 +0100
From: osalvador@suse.de
Subject: Re: [PATCH] mm, memory_hotplug: Don't bail out in do_migrate_range
 prematurely
In-Reply-To: <20181211085042.2696-1-osalvador@suse.de>
References: <20181211085042.2696-1-osalvador@suse.de>
Message-ID: <01021c8571af27995acbaaca7a1a68f0@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, david@redhat.com, pasha.tatashin@soleen.com, dan.j.williams@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, owner-linux-mm@kvack.org

On 2018-12-11 09:50, Oscar Salvador wrote:

> -		} else {
> -			pr_warn("failed to isolate pfn %lx\n", pfn);
> -			dump_page(page, "isolation failed");
> -			put_page(page);
> -			/* Because we don't have big zone->lock. we should
> -			   check this again here. */
> -			if (page_count(page)) {
> -				not_managed++;
> -				ret = -EBUSY;
> -				break;

I forgot that here we should at least leave the put_page().
But leave also the dump_page() and the pr_warn().

--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1394,6 +1394,10 @@ do_migrate_range(unsigned long start_pfn, 
unsigned long end_pfn)
                                 inc_node_page_state(page, 
NR_ISOLATED_ANON +
                                                     
page_is_file_cache(page));

+               } else {
+                       pr_warn("failed to isolate pfn %lx\n", pfn);
+                       dump_page(page, "isolation failed");
+                       put_page(page);
                 }
         }
         if (!list_empty(&source)) {
