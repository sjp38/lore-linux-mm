Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1513E6007F3
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 09:57:10 -0400 (EDT)
Received: by pvc30 with SMTP id 30so1654157pvc.14
        for <linux-mm@kvack.org>; Sun, 18 Jul 2010 06:57:09 -0700 (PDT)
Message-ID: <4C43083E.6020201@gmail.com>
Date: Sun, 18 Jul 2010 21:57:18 +0800
From: Wang Sheng-Hui <crosslonelyover@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] turn BUG_ON for out of bound in mb_cache_entry_find_first/mb_cache_entry_find_next
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

In mb_cache_entry_find_first/mb_cache_entry_find_next, macro
mb_assert is used to do assertion on index, but it just prints
KERN_ERR info if defined.
Currently, only ext2/ext3/ext4 use the function with index set 0.
But for potential usage by other subsystems, I think we shoud report BUG
if we got some index out of bound here.


Following patch is against 2.6.35-rc3, and should be
applied after the first patch.Please check it.

Signed-off-by: Wang Sheng-Hui <crosslonelyover@gmail.com>
---
 fs/mbcache.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/mbcache.c b/fs/mbcache.c
index 5697d9e..ed25979 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -614,7 +614,7 @@ mb_cache_entry_find_first(struct mb_cache *cache,
int index,
 	struct list_head *l;
 	struct mb_cache_entry *ce;

-	mb_assert(index < mb_cache_indexes(cache));
+	BUG_ON((index < 0) || (index >= mb_cache_indexes(cache)));
 	spin_lock(&mb_cache_spinlock);
 	l = cache->c_indexes_hash[index][bucket].next;
 	ce = __mb_cache_entry_find(l, &cache->c_indexes_hash[index][bucket],
@@ -652,7 +652,7 @@ mb_cache_entry_find_next(struct mb_cache_entry
*prev, int index,
 	struct list_head *l;
 	struct mb_cache_entry *ce;

-	mb_assert(index < mb_cache_indexes(cache));
+	BUG_ON((index < 0) || (index >= mb_cache_indexes(cache)));
 	spin_lock(&mb_cache_spinlock);
 	l = prev->e_indexes[index].o_list.next;
 	ce = __mb_cache_entry_find(l, &cache->c_indexes_hash[index][bucket],
-- 
1.7.1.1



-- 
Thanks and Regards,
shenghui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
