Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8226B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 15:26:35 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o6LJQWPA028520
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 12:26:32 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by hpaq12.eem.corp.google.com with ESMTP id o6LJQUbw011122
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 12:26:30 -0700
Received: by pzk33 with SMTP id 33so2782480pzk.14
        for <linux-mm@kvack.org>; Wed, 21 Jul 2010 12:26:29 -0700 (PDT)
Date: Wed, 21 Jul 2010 12:26:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 5/6] jbd: remove dependency on __GFP_NOFAIL
In-Reply-To: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1007211225130.18279@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
Cc: Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The kzalloc() in start_this_handle() is failable, so remove __GFP_NOFAIL
from its mask.

Cc: Andreas Dilger <adilger@sun.com>
Cc: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/jbd/transaction.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/jbd/transaction.c b/fs/jbd/transaction.c
--- a/fs/jbd/transaction.c
+++ b/fs/jbd/transaction.c
@@ -99,8 +99,7 @@ static int start_this_handle(journal_t *journal, handle_t *handle)
 
 alloc_transaction:
 	if (!journal->j_running_transaction) {
-		new_transaction = kzalloc(sizeof(*new_transaction),
-						GFP_NOFS|__GFP_NOFAIL);
+		new_transaction = kzalloc(sizeof(*new_transaction), GFP_NOFS);
 		if (!new_transaction) {
 			ret = -ENOMEM;
 			goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
