Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 736FB6B003C
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:18:48 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so8213380eek.7
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:18:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o46si28118649eem.189.2014.04.15.21.18.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:18:47 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 08/19] Set PF_FSTRANS while write_cache_pages calls
 ->writepage
Message-ID: <20140416040336.10604.34673.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com

It is normally safe for direct reclaim to enter filesystems
even when a page is locked - as can happen if ->writepage
allocates memory with GFP_KERNEL (which xfs does).

However if a localhost NFS mount is present, then a flush-*
thread might hold a page locked and then in direct reclaim,
ask nfs to commit an inode (nfs_release_page).  When nfsd
performs the fsync it might try to lock the same page, which leads to
a deadlock.

A ->writepage should not allocate much memory, or do so very often, so
it is safe to set PF_FSTRANS, and this removes the possible deadlock.

This was not detected by lockdep as it doesn't monitor the page lock.
It was found as a real deadlock in testing.

Signed-off-by: NeilBrown  <neilb@suse.de>
---
 mm/page-writeback.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 7106cb1aca8e..572e70b9a3f7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1909,6 +1909,7 @@ retry:
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
+			unsigned int pflags;
 
 			/*
 			 * At this point, the page may be truncated or
@@ -1960,8 +1961,10 @@ continue_unlock:
 			if (!clear_page_dirty_for_io(page))
 				goto continue_unlock;
 
+			current_set_flags_nested(&pflags, PF_FSTRANS);
 			trace_wbc_writepage(wbc, mapping->backing_dev_info);
 			ret = (*writepage)(page, wbc, data);
+			current_restore_flags_nested(&pflags, PF_FSTRANS);
 			if (unlikely(ret)) {
 				if (ret == AOP_WRITEPAGE_ACTIVATE) {
 					unlock_page(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
