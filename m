Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB2C96B027B
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:38:45 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w7-v6so3843747qto.9
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:38:45 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0130.outbound.protection.outlook.com. [104.47.1.130])
        by mx.google.com with ESMTPS id g9-v6si1704604qtk.14.2018.08.07.08.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 08:38:44 -0700 (PDT)
Subject: [PATCH RFC 06/10] fs: Shrink only (SB_ACTIVE|SB_BORN) superblocks
 in super_cache_scan()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 07 Aug 2018 18:38:36 +0300
Message-ID: <153365631661.19074.12075476211623702890.stgit@localhost.localdomain>
In-Reply-To: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, ktkhai@virtuozzo.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This patch prepares superblock shrinker for delayed unregistering.
It makes super_cache_scan() avoid shrinking of not active superblocks.
SB_ACTIVE is used as such the indicator. In case of superblock is not
active, super_cache_scan() just exits with SHRINK_STOP as result.

Note, that SB_ACTIVE is cleared in generic_shutdown_super() and this
is made under s_umount mutex. Function super_cache_scan() also takes
the mutex, so it can't skip this flag cleared.

SB_BORN check is added to super_cache_scan() just for uniformity
with super_cache_count(), while super_cache_count() received SB_ACTIVE
check just for uniformity with super_cache_scan().

After this patch super_cache_scan() becomes to ignore unregistering
superblocks, so this function is OK with splitting unregister_shrinker().
Next patches prepare super_cache_count() to follow this way.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/super.c b/fs/super.c
index 457834278e37..9222cfc196bf 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -79,6 +79,11 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	if (!trylock_super(sb))
 		return SHRINK_STOP;
 
+	if ((sb->s_flags & (SB_BORN|SB_ACTIVE)) != (SB_BORN|SB_ACTIVE)) {
+		freed = SHRINK_STOP;
+		goto unlock;
+	}
+
 	if (sb->s_op->nr_cached_objects)
 		fs_objects = sb->s_op->nr_cached_objects(sb, sc);
 
@@ -110,6 +115,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 		freed += sb->s_op->free_cached_objects(sb, sc);
 	}
 
+unlock:
 	up_read(&sb->s_umount);
 	return freed;
 }
@@ -136,7 +142,7 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 	 * avoid this situation, so do the same here. The memory barrier is
 	 * matched with the one in mount_fs() as we don't hold locks here.
 	 */
-	if (!(sb->s_flags & SB_BORN))
+	if ((sb->s_flags & (SB_BORN|SB_ACTIVE)) != (SB_BORN|SB_ACTIVE))
 		return 0;
 	smp_rmb();
 
