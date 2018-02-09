Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60C5A6B0266
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 15:36:56 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id w101so5050566wrc.18
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 12:36:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j17si2193179wre.173.2018.02.09.12.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 12:36:54 -0800 (PST)
Date: Fri, 9 Feb 2018 12:36:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 1/1] mm: initialize pages on demand during boot
Message-Id: <20180209123615.4715623481fa07f7b14fd447@linux-foundation.org>
In-Reply-To: <20180209192216.20509-2-pasha.tatashin@oracle.com>
References: <20180209192216.20509-1-pasha.tatashin@oracle.com>
	<20180209192216.20509-2-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, m.mizuma@jp.fujitsu.com, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri,  9 Feb 2018 14:22:16 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> Deferred page initialization allows the boot cpu to initialize a small
> subset of the system's pages early in boot, with other cpus doing the rest
> later on.
> 
> It is, however, problematic to know how many pages the kernel needs during
> boot.  Different modules and kernel parameters may change the requirement,
> so the boot cpu either initializes too many pages or runs out of memory.
> 
> To fix that, initialize early pages on demand.  This ensures the kernel
> does the minimum amount of work to initialize pages during boot and leaves
> the rest to be divided in the multithreaded initialization path
> (deferred_init_memmap).
> 
> The on-demand code is permanently disabled using static branching once
> deferred pages are initialized.  After the static branch is changed to
> false, the overhead is up-to two branch-always instructions if the zone
> watermark check fails or if rmqueue fails.

lgtm, I'll toss it in for some testing.

A couple of tweaks:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-initialize-pages-on-demand-during-boot-fix

fix typo in comment, make deferred_pages static

Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN include/linux/memblock.h~mm-initialize-pages-on-demand-during-boot-fix include/linux/memblock.h
diff -puN mm/memblock.c~mm-initialize-pages-on-demand-during-boot-fix mm/memblock.c
diff -puN mm/page_alloc.c~mm-initialize-pages-on-demand-during-boot-fix mm/page_alloc.c
--- a/mm/page_alloc.c~mm-initialize-pages-on-demand-during-boot-fix
+++ a/mm/page_alloc.c
@@ -1568,14 +1568,14 @@ static int __init deferred_init_memmap(v
 }
 
 /*
- * This lock grantees that only one thread at a time is allowed to grow zones
+ * This lock guarantees that only one thread at a time is allowed to grow zones
  * (decrease number of deferred pages).
  * Protects first_deferred_pfn field in all zones during early boot before
  * deferred pages are initialized.  Deferred pages are initialized in
  * page_alloc_init_late() soon after smp_init() is complete.
  */
 static __initdata DEFINE_SPINLOCK(deferred_zone_grow_lock);
-DEFINE_STATIC_KEY_TRUE(deferred_pages);
+static DEFINE_STATIC_KEY_TRUE(deferred_pages);
 
 /*
  * If this zone has deferred pages, try to grow it by initializing enough
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
