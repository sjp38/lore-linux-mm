Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9D36C6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 05:09:45 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so2366690eei.14
        for <linux-mm@kvack.org>; Thu, 22 May 2014 02:09:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h47si14005308eey.79.2014.05.22.02.09.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 02:09:44 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/3] fs/superblock: Unregister sb shrinker before ->kill_sb()
Date: Thu, 22 May 2014 10:09:37 +0100
Message-Id: <1400749779-24879-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1400749779-24879-1-git-send-email-mgorman@suse.de>
References: <1400749779-24879-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Dave@kvack.org, "Chinner <david"@fromorbit.com, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

From: Dave Chinner <david@fromorbit.com>

We will like to unregister the sb shrinker before ->kill_sb().
This will allow cached objects to be counted without call to
grab_super_passive() to update ref count on sb. We want
to avoid locking during memory reclamation especially when
we are skipping the memory reclaim when we are out of
cached objects.

This is safe because grab_super_passive does a try-lock on the sb->s_umount
now, and so if we are in the unmount process, it won't ever block.
That means what used to be a deadlock and races we were avoiding
by using grab_super_passive() is now:

        shrinker                        umount

        down_read(shrinker_rwsem)
                                        down_write(sb->s_umount)
                                        shrinker_unregister
                                          down_write(shrinker_rwsem)
                                            <blocks>
        grab_super_passive(sb)
          down_read_trylock(sb->s_umount)
            <fails>
        <shrinker aborts>
        ....
        <shrinkers finish running>
        up_read(shrinker_rwsem)
                                          <unblocks>
                                          <removes shrinker>
                                          up_write(shrinker_rwsem)
                                        ->kill_sb()
                                        ....

So it is safe to deregister the shrinker before ->kill_sb().

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/super.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 48377f7..a852b1a 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -276,10 +276,8 @@ void deactivate_locked_super(struct super_block *s)
 	struct file_system_type *fs = s->s_type;
 	if (atomic_dec_and_test(&s->s_active)) {
 		cleancache_invalidate_fs(s);
-		fs->kill_sb(s);
-
-		/* caches are now gone, we can safely kill the shrinker now */
 		unregister_shrinker(&s->s_shrink);
+		fs->kill_sb(s);
 
 		put_filesystem(fs);
 		put_super(s);
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
