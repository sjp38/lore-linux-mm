Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id EFA826B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 07:34:22 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so6992537qkh.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 04:34:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j78si608613qhc.65.2015.06.16.04.34.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 04:34:22 -0700 (PDT)
Subject: [BUG] fs: inotify_handle_event() reading un-init memory
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 16 Jun 2015 13:33:18 +0200
Message-ID: <20150616113300.10621.35439.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

Caught by kmemcheck.

Don't know the fix... just pointed at the bug.

Introduced in commit 7053aee26a3 ("fsnotify: do not share
events between notification groups").
---
 fs/notify/inotify/inotify_fsnotify.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
index 2cd900c2c737..370d66dc4ddb 100644
--- a/fs/notify/inotify/inotify_fsnotify.c
+++ b/fs/notify/inotify/inotify_fsnotify.c
@@ -96,11 +96,12 @@ int inotify_handle_event(struct fsnotify_group *group,
 	i_mark = container_of(inode_mark, struct inotify_inode_mark,
 			      fsn_mark);
 
+	// new object alloc here
 	event = kmalloc(alloc_len, GFP_KERNEL);
 	if (unlikely(!event))
 		return -ENOMEM;
 
-	fsn_event = &event->fse;
+	fsn_event = &event->fse; // This looks wrong!?! read from un-init mem?
 	fsnotify_init_event(fsn_event, inode, mask);
 	event->wd = i_mark->wd;
 	event->sync_cookie = cookie;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
