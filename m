Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5978C6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:17:42 -0400 (EDT)
Received: by wigg3 with SMTP id g3so79236170wig.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 07:17:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o19si22329474wjr.59.2015.06.15.07.17.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Jun 2015 07:17:40 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] jbd2: get rid of open coded allocation retry loop
Date: Mon, 15 Jun 2015 16:17:34 +0200
Message-Id: <1434377854-17959-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

insert_revoke_hash does an open coded endless allocation loop if
journal_oom_retry is true. It doesn't implement any allocation fallback
strategy between the retries, though. The memory allocator doesn't know
about the never fail requirement so it cannot potentially help to move
on with the allocation (e.g. use memory reserves).

Get rid of the retry loop and use __GFP_NOFAIL instead. We will lose the
debugging message but I am not sure it is anyhow helpful.

Do the same for journal_alloc_journal_head which is doing a similar
thing.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---

Hi,
While looking at something unrelated I have encountered the following
two open coded endless loops around allocation request. I have converted
them to use __GFP_NOFAIL in lines of http://marc.info/?l=linux-mm&m=143377014630186&w=2.

journal_oom_retry is hardcoded to 1 and used only at a single place in
jbd2 code so I guess it is just a left over. Nevertheless, I have kept
it there because I do not understand its historical purpose. Anyway
it seems like removing it would allow some more clean ups because
insert_revoke_hash doesn't have any other failure modes (same applies to
jbd2_journal_set_revoke). Let me know if you would be interested in
such a cleanup.

Thanks!

 fs/jbd2/journal.c |  6 ++----
 fs/jbd2/revoke.c  | 15 +++++----------
 2 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index b96bd8076b70..218414703f11 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -2362,10 +2362,8 @@ static struct journal_head *journal_alloc_journal_head(void)
 	if (!ret) {
 		jbd_debug(1, "out of memory for journal_head\n");
 		pr_notice_ratelimited("ENOMEM in %s, retrying.\n", __func__);
-		while (!ret) {
-			yield();
-			ret = kmem_cache_zalloc(jbd2_journal_head_cache, GFP_NOFS);
-		}
+		ret = kmem_cache_zalloc(jbd2_journal_head_cache,
+				GFP_NOFS | __GFP_NOFAIL);
 	}
 	return ret;
 }
diff --git a/fs/jbd2/revoke.c b/fs/jbd2/revoke.c
index c6cbaef2bda1..f9eb93e1b3cb 100644
--- a/fs/jbd2/revoke.c
+++ b/fs/jbd2/revoke.c
@@ -141,11 +141,13 @@ static int insert_revoke_hash(journal_t *journal, unsigned long long blocknr,
 {
 	struct list_head *hash_list;
 	struct jbd2_revoke_record_s *record;
+	gfp_t gfp_mask = GFP_NOFS;
 
-repeat:
-	record = kmem_cache_alloc(jbd2_revoke_record_cache, GFP_NOFS);
+	if (journal_oom_retry)
+		gfp_mask |= __GFP_NOFAIL;
+	record = kmem_cache_alloc(jbd2_revoke_record_cache, gfp_mask);
 	if (!record)
-		goto oom;
+		return -ENOMEM;
 
 	record->sequence = seq;
 	record->blocknr = blocknr;
@@ -154,13 +156,6 @@ static int insert_revoke_hash(journal_t *journal, unsigned long long blocknr,
 	list_add(&record->hash, hash_list);
 	spin_unlock(&journal->j_revoke_lock);
 	return 0;
-
-oom:
-	if (!journal_oom_retry)
-		return -ENOMEM;
-	jbd_debug(1, "ENOMEM in %s, retrying\n", __func__);
-	yield();
-	goto repeat;
 }
 
 /* Find a revoke record in the journal's hash table. */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
