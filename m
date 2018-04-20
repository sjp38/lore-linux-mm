Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 806186B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 01:30:25 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x5-v6so4330844pln.21
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 22:30:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s13-v6si4732851plp.102.2018.04.19.22.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 22:30:23 -0700 (PDT)
Message-Id: <201804200529.w3K5TdvM009951@www262.sakura.ne.jp>
Subject: Re: general protection fault in =?ISO-2022-JP?B?a2VybmZzX2tpbGxfc2I=?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 20 Apr 2018 14:29:39 +0900
References: <20180420024440.GB686@sol.localdomain> <20180420033450.GC686@sol.localdomain>
In-Reply-To: <20180420033450.GC686@sol.localdomain>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+151de3f2be6b40ac8026@syzkaller.appspotmail.com>, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-fsdevel@vger.kernel.org

Eric Biggers wrote:
> But, there is still a related bug: when mounting sysfs, if register_shrinker()
> fails in sget_userns(), then kernfs_kill_sb() gets called, which frees the
> 'struct kernfs_super_info'.  But, the 'struct kernfs_super_info' is also freed
> in kernfs_mount_ns() by:
> 
>         sb = sget_userns(fs_type, kernfs_test_super, kernfs_set_super, flags,
>                          &init_user_ns, info);
>         if (IS_ERR(sb) || sb->s_fs_info != info)
>                 kfree(info);
>         if (IS_ERR(sb))
>                 return ERR_CAST(sb);
> 
> I guess the problem is that sget_userns() shouldn't take ownership of the 'info'
> if it returns an error -- but, it actually does if register_shrinker() fails,
> resulting in a double free.
> 
> Here is a reproducer and the KASAN splat.  This is on Linus' tree (87ef12027b9b)
> with vfs/for-linus merged in.

I'm waiting for response from Michal Hocko regarding
http://lkml.kernel.org/r/201804111909.EGC64586.QSFLFJFOVHOOtM@I-love.SAKURA.ne.jp .

> 
> #define _GNU_SOURCE
> #include <fcntl.h>
> #include <sched.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/mount.h>
> #include <sys/stat.h>
> #include <unistd.h>
> 
> int main()
> {
>         int fd, i;
>         char buf[16];
> 
>         unshare(CLONE_NEWNET);
>         system("echo N > /sys/kernel/debug/failslab/ignore-gfp-wait");
>         system("echo 0 | tee /sys/kernel/debug/fail*/verbose");
>         fd = open("/proc/thread-self/fail-nth", O_WRONLY);
>         for (i = 0; ; i++) {
>                 write(fd, buf, sprintf(buf, "%d", i));
>                 mount("sysfs", "mnt", "sysfs", 0, NULL);
>                 umount("mnt");
>         }
> }
