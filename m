Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA726B0006
	for <linux-mm@kvack.org>; Mon, 14 May 2018 16:59:36 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id n3-v6so16489462otk.7
        for <linux-mm@kvack.org>; Mon, 14 May 2018 13:59:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 7-v6si3245314oid.19.2018.05.14.13.59.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 13:59:34 -0700 (PDT)
Subject: Re: [PATCH] shmem: don't call put_super() when fill_super() failed.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201805140657.w4E6vV4a035377@www262.sakura.ne.jp>
	<20180514170423.GA252575@gmail.com>
	<20180514171154.GB252575@gmail.com>
In-Reply-To: <20180514171154.GB252575@gmail.com>
Message-Id: <201805150559.IBC65633.OFQOOJFHSFVMLt@I-love.SAKURA.ne.jp>
Date: Tue, 15 May 2018 05:59:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ebiggers3@gmail.com
Cc: syzbot+d2586fde8fdcead3647f@syzkaller.appspotmail.com, viro@ZenIV.linux.org.uk, hughd@google.com, syzkaller-bugs@googlegroups.com, linux-mm@kvack.org, dchinner@redhat.com

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

Indeed. This is use before initialisation bug which will be fixed by commit 79f546a696bff259.

#syz fix: fs: don't scan the inode cache before SB_BORN is set
