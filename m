Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A40EF6B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 06:10:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w17so666824pfn.17
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 03:10:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k3si534681pgq.83.2018.04.11.03.10.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 03:10:23 -0700 (PDT)
Subject: Re: WARNING in kill_block_super
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <6c95e826-4b9f-fb21-b311-830411e58480@I-love.SAKURA.ne.jp>
	<20180411005938.GN30522@ZenIV.linux.org.uk>
	<201804110128.w3B1S6M6092645@www262.sakura.ne.jp>
	<20180411013836.GO30522@ZenIV.linux.org.uk>
In-Reply-To: <20180411013836.GO30522@ZenIV.linux.org.uk>
Message-Id: <201804111909.EGC64586.QSFLFJFOVHOOtM@I-love.SAKURA.ne.jp>
Date: Wed, 11 Apr 2018 19:09:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@ZenIV.linux.org.uk, mhocko@suse.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, linux-mm@kvack.org, dvyukov@google.com, syzbot+5a170e19c963a2e0df79@syzkaller.appspotmail.com

Al Viro wrote:
> On Wed, Apr 11, 2018 at 10:28:06AM +0900, Tetsuo Handa wrote:
> > Al Viro wrote:
> > > On Wed, Apr 04, 2018 at 07:53:07PM +0900, Tetsuo Handa wrote:
> > > > Al and Michal, are you OK with this patch?
> > > 
> > > First of all, it does *NOT* fix the problems with careless ->kill_sb().
> > > The fuse-blk case is the only real rationale so far.  Said that,
> > > 
> > 
> > Please notice below one as well. Fixing all careless ->kill_sb() will be too
> > difficult to backport. For now, avoid calling deactivate_locked_super() is
> > safer.
> 
> How will that fix e.g. jffs2?

You can send patches which my patch does not fix.

> 
> > [upstream] WARNING: refcount bug in put_pid_ns
> > https://syzkaller.appspot.com/bug?id=17e202b4794da213570ba33ac2f70277ef1ce015
> 
> Should be fixed by 8e666cb33597 in that series, AFAICS.

OK.



Al Viro wrote:
> On Wed, Apr 04, 2018 at 07:53:07PM +0900, Tetsuo Handa wrote:
> > Al and Michal, are you OK with this patch?
> 
> First of all, it does *NOT* fix the problems with careless ->kill_sb().
> The fuse-blk case is the only real rationale so far.  Said that,
> 
> > @@ -166,6 +166,7 @@ static void destroy_unused_super(struct super_block *s)
> >  	security_sb_free(s);
> >  	put_user_ns(s->s_user_ns);
> >  	kfree(s->s_subtype);
> > +	kfree(s->s_shrink.nr_deferred);
> 
> is probably better done with an inlined helper (fs/super.c has no business knowing
> about ->nr_deferred name, and there probably will be other users of that
> preallocation of yours).  And the same helper would be better off zeroing the
> pointer, same as unregister_shrinker() does.
> 
> 
> > -int register_shrinker(struct shrinker *shrinker)
> > +int prepare_shrinker(struct shrinker *shrinker)
> 
> preallocate_shrinker(), perhaps?
> 
> > +int register_shrinker(struct shrinker *shrinker)
> > +{
> > +	int err = prepare_shrinker(shrinker);
> > +
> > +	if (err)
> > +		return err;
> > +	register_shrinker_prepared(shrinker);
> 
> 	if (!err)
> 		register_....;
> 	return err;
> 
> would be better, IMO.
> 

OK. Here is version 2. What do you think?



>From 9d035f5bee3861cb73c4d323c03121f431edf760 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 11 Apr 2018 11:44:46 +0900
Subject: [PATCH v2] mm,vmscan: Allow preallocating memory for
 register_shrinker().

syzbot is catching so many bugs triggered by commit 9ee332d99e4d5a97
("sget(): handle failures of register_shrinker()"). That commit expected
that calling kill_sb() from deactivate_locked_super() without successful
fill_super() is safe. But it turned out that there are many bugs which
exist before that commit, and also that that commit caused regressions
in several cases.

For example, [1] is a report where sb->s_mode (which seems to be either
FMODE_READ | FMODE_EXCL | FMODE_WRITE or FMODE_READ | FMODE_EXCL) is not
assigned unless sget() succeeds. But it does not worth complicate sget()
so that register_shrinker() failure path can safely call
kill_block_super() via kill_sb(). Making alloc_super() fail if memory
allocation for register_shrinker() failed is much simpler.

Although this patch hides some of bugs revealed by that commit, this patch
allows preallocating memory for the shrinker. By this change, we can avoid
calling deactivate_locked_super() from sget_userns(). Manual auditing and
syzbot tests will eventually reveal remaining bugs.

[1] https://syzkaller.appspot.com/bug?id=588996a25a2587be2e3a54e8646728fb9cae44e7

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: syzbot <syzbot+84371b6062cb639d797e@syzkaller.appspotmail.com> # WARNING: refcount bug in should_fail
Reported-by: syzbot <syzbot+5a170e19c963a2e0df79@syzkaller.appspotmail.com> # WARNING in kill_block_super
Reported-by: syzbot <syzbot+66a731f39da94bb14930@syzkaller.appspotmail.com> # WARNING: refcount bug in put_pid_ns
Reported-by: syzbot <syzbot+7a1cff37dbbef9e7ba4c@syzkaller.appspotmail.com> # KASAN: use-after-free Read in alloc_pid
Reported-by: syzbot <syzbot+151de3f2be6b40ac8026@syzkaller.appspotmail.com> # general protection fault in kernfs_kill_sb
Cc: stable <stable@vger.kernel.org> # 4.15+
Cc: Al Viro <vilo@zeniv.linux.org.uk>
Cc: Michal Hocko <mhocko@suse.com>
---
 fs/super.c               |  9 ++++-----
 include/linux/shrinker.h | 21 +++++++++++++++++++--
 mm/vmscan.c              | 20 +++++++++++++++-----
 3 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 672538c..5a839cd8 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -166,6 +166,7 @@ static void destroy_unused_super(struct super_block *s)
 	security_sb_free(s);
 	put_user_ns(s->s_user_ns);
 	kfree(s->s_subtype);
+	unallocate_shrinker(&s->s_shrink);
 	/* no delays needed */
 	destroy_super_work(&s->destroy_work);
 }
@@ -251,6 +252,8 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	s->s_shrink.count_objects = super_cache_count;
 	s->s_shrink.batch = 1024;
 	s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
+	if (preallocate_shrinker(&s->s_shrink))
+		goto fail;
 	return s;
 
 fail:
@@ -517,11 +520,7 @@ struct super_block *sget_userns(struct file_system_type *type,
 	hlist_add_head(&s->s_instances, &type->fs_supers);
 	spin_unlock(&sb_lock);
 	get_filesystem(type);
-	err = register_shrinker(&s->s_shrink);
-	if (err) {
-		deactivate_locked_super(s);
-		s = ERR_PTR(err);
-	}
+	register_preallocated_shrinker(&s->s_shrink);
 	return s;
 }
 
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 388ff29..ae5f557 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -75,6 +75,23 @@ struct shrinker {
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
 
-extern int register_shrinker(struct shrinker *);
-extern void unregister_shrinker(struct shrinker *);
+extern int preallocate_shrinker(struct shrinker *shrinker);
+extern void register_preallocated_shrinker(struct shrinker *shrinker);
+extern void unallocate_shrinker(struct shrinker *shrinker);
+extern void unregister_shrinker(struct shrinker *shrinker);
+
+/*
+ * Try to replace register_shrinker() with preallocate_shrinker() and
+ * register_preallocated_shrinker() if that makes error handling easier.
+ * Call unallocate_shrinker() if a shrinker is discarded between after
+ * preallocate_shrinker() and before register_preallocated_shrinker().
+ */
+static inline int register_shrinker(struct shrinker *shrinker)
+{
+	int err = preallocate_shrinker(shrinker);
+
+	if (!err)
+		register_preallocated_shrinker(shrinker);
+	return err;
+}
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4390a8d..17b3073 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -258,7 +258,7 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
 /*
  * Add a shrinker callback to be called from the vm.
  */
-int register_shrinker(struct shrinker *shrinker)
+int preallocate_shrinker(struct shrinker *shrinker)
 {
 	size_t size = sizeof(*shrinker->nr_deferred);
 
@@ -268,17 +268,28 @@ int register_shrinker(struct shrinker *shrinker)
 	shrinker->nr_deferred = kzalloc(size, GFP_KERNEL);
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
+	return 0;
+}
+EXPORT_SYMBOL(preallocate_shrinker);
 
+void register_preallocated_shrinker(struct shrinker *shrinker)
+{
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
 	up_write(&shrinker_rwsem);
-	return 0;
 }
-EXPORT_SYMBOL(register_shrinker);
+EXPORT_SYMBOL(register_preallocated_shrinker);
 
 /*
  * Remove one
  */
+void unallocate_shrinker(struct shrinker *shrinker)
+{
+	kfree(shrinker->nr_deferred);
+	shrinker->nr_deferred = NULL;
+}
+EXPORT_SYMBOL(unallocate_shrinker);
+
 void unregister_shrinker(struct shrinker *shrinker)
 {
 	if (!shrinker->nr_deferred)
@@ -286,8 +297,7 @@ void unregister_shrinker(struct shrinker *shrinker)
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
-	kfree(shrinker->nr_deferred);
-	shrinker->nr_deferred = NULL;
+	unallocate_shrinker(shrinker);
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
-- 
1.8.3.1
