Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id F1A9E6B0006
	for <linux-mm@kvack.org>; Mon, 14 May 2018 20:27:56 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id s201-v6so16779120ita.1
        for <linux-mm@kvack.org>; Mon, 14 May 2018 17:27:56 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f207-v6si7643889itd.82.2018.05.14.17.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 17:27:40 -0700 (PDT)
Message-Id: <201805150027.w4F0RZ27055056@www262.sakura.ne.jp>
Subject: Re: [PATCH] shmem: don't call =?ISO-2022-JP?B?cHV0X3N1cGVyKCkgd2hlbiBm?=
 =?ISO-2022-JP?B?aWxsX3N1cGVyKCkgZmFpbGVkLg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 15 May 2018 09:27:35 +0900
References: <20180514170423.GA252575@gmail.com> <20180514171154.GB252575@gmail.com>
In-Reply-To: <20180514171154.GB252575@gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: syzbot+d2586fde8fdcead3647f@syzkaller.appspotmail.com, viro@ZenIV.linux.org.uk, hughd@google.com, syzkaller-bugs@googlegroups.com, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

Eric Biggers wrote:
> > I'm not following, since generic_shutdown_super() only calls ->put_super() if
> > ->s_root is set, which only happens at the end of shmem_fill_super().  Isn't the
> > real problem that s_shrink is registered too early, causing super_cache_count()
> > and shmem_unused_huge_count() to potentially run before shmem_fill_super() has
> > completed?  Or alternatively, the problem is that super_cache_count() doesn't
> > check for SB_ACTIVE.
> > 
> 
> Coincidentally, this is already going to be fixed by commit 79f546a696bff259
> ("fs: don't scan the inode cache before SB_BORN is set") in vfs/for-linus.
> 

Just an idea, but if shrinker registration is too early, can't we postpone it
like below?

--- a/fs/super.c
+++ b/fs/super.c
@@ -521,7 +521,6 @@ struct super_block *sget_userns(struct file_system_type *type,
 	hlist_add_head(&s->s_instances, &type->fs_supers);
 	spin_unlock(&sb_lock);
 	get_filesystem(type);
-	register_shrinker_prepared(&s->s_shrink);
 	return s;
 }
 
@@ -1287,6 +1286,7 @@ struct dentry *
 	WARN((sb->s_maxbytes < 0), "%s set sb->s_maxbytes to "
 		"negative value (%lld)\n", type->name, sb->s_maxbytes);
 
+	register_shrinker_prepared(&sb->s_shrink);
 	up_write(&sb->s_umount);
 	free_secdata(secdata);
 	return root;
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -313,6 +313,7 @@ int prealloc_shrinker(struct shrinker *shrinker)
 	shrinker->nr_deferred = kzalloc(size, GFP_KERNEL);
 	if (!shrinker->nr_deferred)
 		return -ENOMEM;
+	INIT_LIST_HEAD(&shrinker->list);
 	return 0;
 }
 
