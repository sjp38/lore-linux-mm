Date: Wed, 18 Sep 2002 20:11:53 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: free_more_memory() calls try_to_free_pages() with a NULL classzone
Message-ID: <376979708.1032379912@[10.10.2.3]>
In-Reply-To: <20020919025439.GI28202@holomorphy.com>
References: <20020919025439.GI28202@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I'm not convinced contig_page_data is supposed to even be defined.

It's not. Thus this:

zone = contig_page_data.node_zonelists[GFP_NOFS&GFP_ZONEMASK].zones[0];

should have been caught at compile time.

The fact that we define it in numa.c is even more amusing.

If you fix what you pointed out, and add the appended, does it
compile?

--- 2.5.36-mm1/mm/numa.c.old	2002-09-18 19:47:11.000000000 -0700
+++ 2.5.36-mm1/mm/numa.c	2002-09-18 19:47:32.000000000 -0700
@@ -11,11 +11,11 @@
 
 int numnodes = 1;	/* Initialized for UMA platforms */
 
+#ifndef CONFIG_DISCONTIGMEM
+
 static bootmem_data_t contig_bootmem_data;
 pg_data_t contig_page_data = { .bdata = &contig_bootmem_data };
 
-#ifndef CONFIG_DISCONTIGMEM
-
 /*
  * This is meant to be invoked by platforms whose physical memory starts
  * at a considerably higher value than 0. Examples are Super-H, ARM, m68k.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
