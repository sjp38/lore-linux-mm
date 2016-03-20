Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id AC78B82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:38 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id x3so237566398pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hc1si9272707pac.16.2016.03.20.11.41.46
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 28/71] dlm: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:35 +0300
Message-Id: <1458499278-1516-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christine Caulfield <ccaulfie@redhat.com>, David Teigland <teigland@redhat.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Christine Caulfield <ccaulfie@redhat.com>
Cc: David Teigland <teigland@redhat.com>
---
 fs/dlm/lowcomms.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 00640e70ed7a..1ab012a27d9f 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -640,7 +640,7 @@ static int receive_from_sock(struct connection *con)
 		con->rx_page = alloc_page(GFP_ATOMIC);
 		if (con->rx_page == NULL)
 			goto out_resched;
-		cbuf_init(&con->cb, PAGE_CACHE_SIZE);
+		cbuf_init(&con->cb, PAGE_SIZE);
 	}
 
 	/*
@@ -657,7 +657,7 @@ static int receive_from_sock(struct connection *con)
 	 * buffer and the start of the currently used section (cb.base)
 	 */
 	if (cbuf_data(&con->cb) >= con->cb.base) {
-		iov[0].iov_len = PAGE_CACHE_SIZE - cbuf_data(&con->cb);
+		iov[0].iov_len = PAGE_SIZE - cbuf_data(&con->cb);
 		iov[1].iov_len = con->cb.base;
 		iov[1].iov_base = page_address(con->rx_page);
 		nvec = 2;
@@ -675,7 +675,7 @@ static int receive_from_sock(struct connection *con)
 	ret = dlm_process_incoming_buffer(con->nodeid,
 					  page_address(con->rx_page),
 					  con->cb.base, con->cb.len,
-					  PAGE_CACHE_SIZE);
+					  PAGE_SIZE);
 	if (ret == -EBADMSG) {
 		log_print("lowcomms: addr=%p, base=%u, len=%u, read=%d",
 			  page_address(con->rx_page), con->cb.base,
@@ -1416,7 +1416,7 @@ void *dlm_lowcomms_get_buffer(int nodeid, int len, gfp_t allocation, char **ppc)
 	spin_lock(&con->writequeue_lock);
 	e = list_entry(con->writequeue.prev, struct writequeue_entry, list);
 	if ((&e->list == &con->writequeue) ||
-	    (PAGE_CACHE_SIZE - e->end < len)) {
+	    (PAGE_SIZE - e->end < len)) {
 		e = NULL;
 	} else {
 		offset = e->end;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
