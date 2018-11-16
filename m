Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 044716B0687
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 19:07:22 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id l131so14166683pga.2
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 16:07:21 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bj11si9211117plb.21.2018.11.15.16.07.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 16:07:20 -0800 (PST)
Date: Thu, 15 Nov 2018 16:07:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 5/5] mm, memory_hotplug: be more verbose for memory
 offline failures
Message-Id: <20181115160716.18b9956ee64932abe9428ef1@linux-foundation.org>
In-Reply-To: <20181107101830.17405-6-mhocko@kernel.org>
References: <20181107101830.17405-1-mhocko@kernel.org>
	<20181107101830.17405-6-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed,  7 Nov 2018 11:18:30 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> There is only very limited information printed when the memory offlining
> fails:
> [ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-0x8267fffffff] failed due to signal backoff
> 
> This tells us that the failure is triggered by the userspace
> intervention but it doesn't tell us much more about the underlying
> reason. It might be that the page migration failes repeatedly and the
> userspace timeout expires and send a signal or it might be some of the
> earlier steps (isolation, memory notifier) takes too long.
> 
> If the migration failes then it would be really helpful to see which
> page that and its state. The same applies to the isolation phase. If we
> fail to isolate a page from the allocator then knowing the state of the
> page would be helpful as well.
> 
> Dump the page state that fails to get isolated or migrated. This will
> tell us more about the failure and what to focus on during debugging.
> 
> ...
>
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1388,10 +1388,8 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  						    page_is_file_cache(page));
>  
>  		} else {
> -#ifdef CONFIG_DEBUG_VM
> -			pr_alert("failed to isolate pfn %lx\n", pfn);
> +			pr_warn("failed to isolate pfn %lx\n", pfn);
>  			dump_page(page, "isolation failed");
> -#endif
>  			put_page(page);
>  			/* Because we don't have big zone->lock. we should
>  			   check this again here. */
> @@ -1411,8 +1409,14 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  		/* Allocate a new page from the nearest neighbor node */
>  		ret = migrate_pages(&source, new_node_page, NULL, 0,
>  					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
> -		if (ret)
> +		if (ret) {
> +			list_for_each_entry(page, &source, lru) {
> +				pr_warn("migrating pfn %lx failed ",
> +				       page_to_pfn(page), ret);
> +				dump_page(page, NULL);
> +			}

./include/linux/kern_levels.h:5:18: warning: too many arguments for format [-Wformat-extra-args]
 #define KERN_SOH "\001"  /* ASCII Start Of Header */
                  ^
./include/linux/kern_levels.h:12:22: note: in expansion of macro a??KERN_SOHa??
 #define KERN_WARNING KERN_SOH "4" /* warning conditions */
                      ^~~~~~~~
./include/linux/printk.h:310:9: note: in expansion of macro a??KERN_WARNINGa??
  printk(KERN_WARNING pr_fmt(fmt), ##__VA_ARGS__)
         ^~~~~~~~~~~~
./include/linux/printk.h:311:17: note: in expansion of macro a??pr_warninga??
 #define pr_warn pr_warning
                 ^~~~~~~~~~
mm/memory_hotplug.c:1414:5: note: in expansion of macro a??pr_warna??
     pr_warn("migrating pfn %lx failed ",
     ^~~~~~~

--- a/mm/memory_hotplug.c~mm-memory_hotplug-be-more-verbose-for-memory-offline-failures-fix
+++ a/mm/memory_hotplug.c
@@ -1411,7 +1411,7 @@ do_migrate_range(unsigned long start_pfn
 					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
 		if (ret) {
 			list_for_each_entry(page, &source, lru) {
-				pr_warn("migrating pfn %lx failed ",
+				pr_warn("migrating pfn %lx failed: %d",
 				       page_to_pfn(page), ret);
 				dump_page(page, NULL);
 			}
