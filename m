Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5OKsCnx020232
	for <linux-mm@kvack.org>; Sat, 24 Jun 2006 15:54:12 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5OL9l7p36743632
	for <linux-mm@kvack.org>; Sat, 24 Jun 2006 14:09:47 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5OKsBnB43011507
	for <linux-mm@kvack.org>; Sat, 24 Jun 2006 13:54:11 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1FuF8t-00044B-00
	for <linux-mm@kvack.org>; Sat, 24 Jun 2006 13:54:11 -0700
Date: Sat, 24 Jun 2006 13:53:40 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Re: [PATCH 10/14] Conversion of nr_dirty to per zone counter
In-Reply-To: <20060624050424.d2160354.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0606241350400.15600@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
 <20060621154511.18741.8677.sendpatchset@schroedinger.engr.sgi.com>
 <20060624050424.d2160354.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606241354050.15634@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: mbligh@google.com, linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fix NR_UNSTABLE_NFS accounting

Move the decrement of NR_UNSTABLE higher in the loop where the page is still
available and get rid of the old hokus pokus that just caused us grief.

Tested on: NUMA IA64 and a x86_64 single processor configuration.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-mm1/fs/nfs/pagelist.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/nfs/pagelist.c	2006-06-24 10:25:25.787101004 -0700
+++ linux-2.6.17-mm1/fs/nfs/pagelist.c	2006-06-24 11:58:54.579382227 -0700
@@ -154,7 +154,6 @@ void nfs_clear_request(struct nfs_page *
 {
 	struct page *page = req->wb_page;
 	if (page != NULL) {
-		dec_zone_page_state(page, NR_UNSTABLE_NFS);
 		page_cache_release(page);
 		req->wb_page = NULL;
 	}
Index: linux-2.6.17-mm1/fs/nfs/write.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/nfs/write.c	2006-06-24 10:25:25.781241992 -0700
+++ linux-2.6.17-mm1/fs/nfs/write.c	2006-06-24 13:34:59.385737173 -0700
@@ -1397,6 +1397,7 @@ static void nfs_commit_done(struct rpc_t
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
+		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 
 		dprintk("NFS: commit (%s/%Ld %d@%Ld)",
 			req->wb_context->dentry->d_inode->i_sb->s_id,
@@ -1422,8 +1423,6 @@ static void nfs_commit_done(struct rpc_t
 		dprintk(" mismatch\n");
 		nfs_mark_request_dirty(req);
 	next:
-		if (req->wb_page)
-			dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		nfs_clear_page_writeback(req);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
