Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5OKg5X4021233
	for <linux-mm@kvack.org>; Sat, 24 Jun 2006 13:42:05 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5OIIs8s16204713
	for <linux-mm@kvack.org>; Sat, 24 Jun 2006 11:18:54 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5OIIrnB43020340
	for <linux-mm@kvack.org>; Sat, 24 Jun 2006 11:18:54 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1FuCib-0003y8-00
	for <linux-mm@kvack.org>; Sat, 24 Jun 2006 11:18:53 -0700
Date: Sat, 24 Jun 2006 11:14:13 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Re: [PATCH 10/14] Conversion of nr_dirty to per zone counter
In-Reply-To: <20060624050424.d2160354.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0606241005440.14998@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
 <20060621154511.18741.8677.sendpatchset@schroedinger.engr.sgi.com>
 <20060624050424.d2160354.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606241118490.15259@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: mbligh@google.com, linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 24 Jun 2006, Andrew Morton wrote:

> > The counter aggregation for nr_dirty had to be undone in the NFS layer since
> > we summed up the page counts from multiple zones. Someone more familiar with
> > NFS should probably review what I have done.
> 
> After fixing all the bugs, and with just a trivial, trivial, trivial amount
> of testing, the NFS unstable pages count goes negative and the machine
> hangs in balance_dirty_pages().

Ahh... SMP / NUMA configurations may mask a problem here by returning 
counters <0 as 0. I did not do this specific test on an UP system when 
I chased down the NFS counter issues. When I tested this on SMP/NUMA 
NR_UNSTABLE correctly went up and down while copying a file.

On a UP system the counters do not have deltas and therefore no <0 
checking is necessary. I guess we expose the problem that way.

> Christoph, this just isn't good enough and we need to do something
> significant to reduce the number of compilation errors and runtime bugs
> which you keep on sending.

I should probably switch my main development environment to be exactly 
like yours so that bugs that are trivial to you are also trivial to me. 
So need to set up a i386 development machine I guess.
r
But them my company would like to have the major development platform to 
be IA64.

I hope to have a fix soon .... This only surfaces on UP as far as I can 
tell.

Temporary safe fix if its urgent (this messes up inter zone NR_UNSTABLE 
accounting but there is nothing that uses zone specific NR_UNSTABLE 
yet)



Index: linux-2.6.17/fs/nfs/pagelist.c
===================================================================
--- linux-2.6.17.orig/fs/nfs/pagelist.c	2006-06-24 03:50:10.000000000 -0700
+++ linux-2.6.17/fs/nfs/pagelist.c	2006-06-24 04:11:17.000000000 -0700
@@ -154,7 +154,6 @@
 {
 	struct page *page = req->wb_page;
 	if (page != NULL) {
-		dec_zone_page_state(page, NR_UNSTABLE_NFS);
 		page_cache_release(page);
 		req->wb_page = NULL;
 	}
Index: linux-2.6.17/fs/nfs/write.c
===================================================================
--- linux-2.6.17.orig/fs/nfs/write.c	2006-06-24 03:49:04.000000000 -0700
+++ linux-2.6.17/fs/nfs/write.c	2006-06-24 04:04:21.000000000 -0700
@@ -1424,6 +1424,9 @@
 	next:
 		if (req->wb_page)
 			dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		else	/* Page is gone but we do not know which zone so use
+			 * the zone of ZERO_PAGE for now */
+			dec_zone_page_state(ZERO_PAGE(0), NR_UNSTABLE_NFS);
 		nfs_clear_page_writeback(req);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
