Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7156B0277
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:27 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id h4so16216818qtj.11
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:27 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a24si2431272qka.63.2018.04.04.12.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:26 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 64/79] mm/buffer: use _page_has_buffers() instead of page_has_buffers()
Date: Wed,  4 Apr 2018 15:18:18 -0400
Message-Id: <20180404191831.5378-29-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

The former need the address_space for which the buffer_head is being
lookup.

----------------------------------------------------------------------
@exists@
identifier M;
expression E;
@@
struct address_space *M;
...
-page_buffers(E)
+_page_buffers(E, M)

@exists@
identifier M, F;
expression E;
@@
F(..., struct address_space *M, ...) {...
-page_buffers(E)
+_page_buffers(E, M)
...}

@exists@
identifier M;
expression E;
@@
struct address_space *M;
...
-page_has_buffers(E)
+_page_has_buffers(E, M)

@exists@
identifier M, F;
expression E;
@@
F(..., struct address_space *M, ...) {...
-page_has_buffers(E)
+_page_has_buffers(E, M)
...}

@exists@
identifier I;
expression E;
@@
struct inode *I;
...
-page_buffers(E)
+_page_buffers(E, I->i_mapping)

@exists@
identifier I, F;
expression E;
@@
F(..., struct inode *I, ...) {...
-page_buffers(E)
+_page_buffers(E, I->i_mapping)
...}

@exists@
identifier I;
expression E;
@@
struct inode *I;
...
-page_has_buffers(E)
+_page_has_buffers(E, I->i_mapping)

@exists@
identifier I, F;
expression E;
@@
F(..., struct inode *I, ...) {...
-page_has_buffers(E)
+_page_has_buffers(E, I->i_mapping)
...}
----------------------------------------------------------------------

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 mm/migrate.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index c2a613283fa2..e4b20ac6cf36 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -768,10 +768,10 @@ int buffer_migrate_page(struct address_space *mapping,
 	struct buffer_head *bh, *head;
 	int rc;
 
-	if (!page_has_buffers(page))
+	if (!_page_has_buffers(page, mapping))
 		return migrate_page(mapping, newpage, page, mode);
 
-	head = page_buffers(page);
+	head = _page_buffers(page, mapping);
 
 	rc = migrate_page_move_mapping(mapping, newpage, page, head, mode, 0);
 
-- 
2.14.3
