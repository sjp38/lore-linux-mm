Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B25256B0268
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 09:05:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v184so1893861wmf.1
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 06:05:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o91si334972eda.419.2017.11.21.06.05.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 06:05:05 -0800 (PST)
Date: Tue, 21 Nov 2017 15:05:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: general protection fault in __list_del_entry_valid (2)
Message-ID: <20171121140500.bgkpwcdk2dxesao4@dhcp22.suse.cz>
References: <001a113f996099503a055e793dd3@google.com>
 <0e1109ef-6d4a-e873-a809-6548776a00f9@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0e1109ef-6d4a-e873-a809-6548776a00f9@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: syzbot <bot+065a25551da6c9ab4283b7ae889c707a37ab2de3@syzkaller.appspotmail.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, minchan@kernel.org, shli@fb.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com, Al Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>

[Cc Al and Dave - email thread starts http://lkml.kernel.org/r/001a113f996099503a055e793dd3@google.com]

On Tue 21-11-17 20:11:26, Tetsuo Handa wrote:
> On 2017/11/21 16:35, syzbot wrote:
> > Hello,
> > 
> > syzkaller hit the following crash on ca91659962303d4fd5211a5e4e13df5cbb11e744
> > git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> > compiler: gcc (GCC) 7.1.1 20170620
> > .config is attached
> > Raw console output is attached.
> > 
> > Unfortunately, I don't have any reproducer for this bug yet.
> 
> Fault injection found an unchecked register_shrinker() return code.
> Wow, register_shrinker()/unregister_shinker() is possibly frequently called path?
> 
> 
> struct super_block *sget_userns(struct file_system_type *type,
> 				int (*test)(struct super_block *,void *),
> 				int (*set)(struct super_block *,void *),
> 				int flags, struct user_namespace *user_ns,
> 				void *data)
> {
> (...snipped...)
> 	spin_unlock(&sb_lock);
> 	get_filesystem(type);
> 	register_shrinker(&s->s_shrink); // Error check required.
> 	return s;

Yes, this is the case since numa aware shrinkers were introduced. I have
a bit hard time to follow the code flow but why cannot we simply
register the shrinker when we allocate the new super block? We
still have the s_umount held so the shrinker cannot race with the
registration code.

Something like the totally untested and possibly wrong
---
diff --git a/fs/super.c b/fs/super.c
index 994db21f59bf..1eb850413fdf 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -506,6 +506,11 @@ struct super_block *sget_userns(struct file_system_type *type,
 		s = alloc_super(type, (flags & ~SB_SUBMOUNT), user_ns);
 		if (!s)
 			return ERR_PTR(-ENOMEM);
+		if (register_shrinker(&s->s_shrink)) {
+			up_write(&s->s_umount);
+			destroy_super(s);
+			return ERR_PTR(-ENOMEM);
+		}
 		goto retry;
 	}
 
@@ -522,7 +527,6 @@ struct super_block *sget_userns(struct file_system_type *type,
 	hlist_add_head(&s->s_instances, &type->fs_supers);
 	spin_unlock(&sb_lock);
 	get_filesystem(type);
-	register_shrinker(&s->s_shrink);
 	return s;
 }
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
