Date: Mon, 18 Sep 2006 23:12:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <20060918173134.d3850903.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609182309050.3152@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060918132818.603196e2.akpm@osdl.org> <Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>
 <20060918161528.9714c30c.akpm@osdl.org> <Pine.LNX.4.64.0609181642210.30206@schroedinger.engr.sgi.com>
 <20060918165808.c410d1d4.akpm@osdl.org> <Pine.LNX.4.64.0609181711210.30365@schroedinger.engr.sgi.com>
 <20060918173134.d3850903.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hmmm... Actually one can get much better code. If I remove the padding
from struct zone then struct zone shrinks from 0x480 to 0x400 in length 
on i386 smp and then we get code without a multiply operation:

00000787 <__inc_zone_page_state>:
 787:   8b 00                   mov    (%eax),%eax
 789:   c1 e8 0f                shr    $0xf,%eax
 78c:   25 00 04 00 00          and    $0x400,%eax
 791:   05 00 00 00 00          add    $0x0,%eax
 796:   e9 58 fe ff ff          jmp    5f3 <__inc_zone_state>

Is there some way to get a structure to be sized a power of two? This is 
so nice and small that one would do good to inline __inc_zone_page_state.


Remove padding from struct zone

Index: linux-2.6.18-rc6-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.18-rc6-mm1.orig/include/linux/mmzone.h	2006-09-18 20:20:34.000000000 -0700
+++ linux-2.6.18-rc6-mm1/include/linux/mmzone.h	2006-09-18 20:34:24.000000000 -0700
@@ -31,21 +31,6 @@
 
 struct pglist_data;
 
-/*
- * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
- * So add a wild amount of padding here to ensure that they fall into separate
- * cachelines.  There are very few zone structures in the machine, so space
- * consumption is not a concern here.
- */
-#if defined(CONFIG_SMP)
-struct zone_padding {
-	char x[0];
-} ____cacheline_internodealigned_in_smp;
-#define ZONE_PADDING(name)	struct zone_padding name;
-#else
-#define ZONE_PADDING(name)
-#endif
-
 enum zone_stat_item {
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
@@ -186,9 +171,6 @@
 #endif
 	struct free_area	free_area[MAX_ORDER];
 
-
-	ZONE_PADDING(_pad1_)
-
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;	
 	struct list_head	active_list;
@@ -231,7 +213,6 @@
 	int prev_priority;
 
 
-	ZONE_PADDING(_pad2_)
 	/* Rarely used or read-mostly fields */
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
