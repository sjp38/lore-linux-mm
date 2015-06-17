Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9D72C6B006E
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 03:10:38 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so32061010pdb.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 00:10:38 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id og9si4871736pbc.66.2015.06.17.00.10.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 00:10:37 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so31917910pdb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 00:10:37 -0700 (PDT)
Date: Wed, 17 Jun 2015 16:11:02 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCHv2 8/8] zsmalloc: register a shrinker to trigger
 auto-compaction
Message-ID: <20150617071102.GA3517@swordfish>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-9-git-send-email-sergey.senozhatsky@gmail.com>
 <20150616144730.GD31387@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150616144730.GD31387@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

On (06/16/15 23:47), Minchan Kim wrote:
[..]
> 
> I like the idea but still have a concern to lack of fragmented zspages
> during memory pressure because auto-compaction will prevent fragment
> most of time. Surely, using fragment space as buffer in heavy memory
> pressure is not intened design so it could be fragile but I'm afraid
> this feature might accelrate it and it ends up having a problem and
> change current behavior in zram as swap.
> 
> I hope you test this feature with considering my concern.
> Of course, I will test it with enough time.
> 

OK, to explore "compaction leaves no fragmentation in classes" I did some
heavy testing today -- parallel copy/remove of the linux kernel, git, glibc;
parallel builds (-j4), parallel clean ups (make clean); git gc, etc.


device's IO stats:
cat /sys/block/zram0/stata??
   277050        0  2216400     1463  8442846        0 67542768   106536        0   107810   108146

device's MM stats:
cat /sys/block/zram0/mm_stata??
 3095515136 2020518768 2057990144        0 2645716992     2030   182119


We auto-compacted (mostly auto-compacted, because I triggered manual compaction
less than 5 times)    182119  objects.


Now, during the compaction I also accounted the number of classes that ended up to
be 'fully compacted' (class->OBJ_ALLOCATED) == class->OBJ_USED) and 'partially
compacted'.


And the results (after 1377 compactions) are:

 pool compaction nr:1377 (full:487 part:35498)



So, we 'fully compact'-ed only 487/(35498 + 487) == 0.0135

roughtly ~1.35%

This argument does not stand anymore. We leave 'holes' in classes in ~98% of the
cases.



code that I used to gather those stats:

---

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 55cfda8..894773a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -253,6 +253,9 @@ struct zs_pool {
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry		*stat_dentry;
 #endif
+	int			compaction_nr;
+	long			full_compact;
+	long			part_compact;
 };
 
 /*
@@ -1717,6 +1720,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	struct zs_compact_control cc;
 	struct page *src_page;
 	struct page *dst_page = NULL;
+	bool compacted = false;
 
 	spin_lock(&class->lock);
 	while ((src_page = isolate_source_page(class))) {
@@ -1726,6 +1730,8 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		if (!zs_can_compact(class))
 			break;
 
+		compacted = true;
+
 		cc.index = 0;
 		cc.s_page = src_page;
 
@@ -1751,6 +1757,13 @@ out:
 	if (src_page)
 		putback_zspage(pool, class, src_page);
 
+	if (compacted) {
+		if (zs_stat_get(class, OBJ_ALLOCATED) == zs_stat_get(class, OBJ_USED))
+			pool->full_compact++;
+		else
+			pool->part_compact++;
+	}
+
 	spin_unlock(&class->lock);
 }
 
@@ -1767,6 +1780,11 @@ unsigned long zs_compact(struct zs_pool *pool)
 			continue;
 		__zs_compact(pool, class);
 	}
+
+	pool->compaction_nr++;
+	pr_err("pool compaction nr:%d (full:%ld part:%ld)\n", pool->compaction_nr,
+			pool->full_compact, pool->part_compact);
+
 	return pool->num_migrated;
 }
 EXPORT_SYMBOL_GPL(zs_compact);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
