Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE9F6B0269
	for <linux-mm@kvack.org>; Mon, 14 May 2018 20:52:50 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i130-v6so10886726iti.0
        for <linux-mm@kvack.org>; Mon, 14 May 2018 17:52:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q186-v6si7532485itd.37.2018.05.14.17.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 17:52:42 -0700 (PDT)
Message-Id: <201805150052.w4F0qbgv062016@www262.sakura.ne.jp>
Subject: Re: [PATCH] shmem: don't call =?ISO-2022-JP?B?cHV0X3N1cGVyKCkgd2hlbiBm?=
 =?ISO-2022-JP?B?aWxsX3N1cGVyKCkgZmFpbGVkLg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 15 May 2018 09:52:37 +0900
References: <201805150027.w4F0RZ27055056@www262.sakura.ne.jp> <20180515003912.GL30522@ZenIV.linux.org.uk>
In-Reply-To: <20180515003912.GL30522@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Eric Biggers <ebiggers3@gmail.com>, syzbot+d2586fde8fdcead3647f@syzkaller.appspotmail.com, hughd@google.com, syzkaller-bugs@googlegroups.com, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

> On Tue, May 15, 2018 at 09:27:35AM +0900, Tetsuo Handa wrote:
> > Eric Biggers wrote:
> > > > I'm not following, since generic_shutdown_super() only calls ->put_super() if
> > > > ->s_root is set, which only happens at the end of shmem_fill_super().  Isn't the
> > > > real problem that s_shrink is registered too early, causing super_cache_count()
> > > > and shmem_unused_huge_count() to potentially run before shmem_fill_super() has
> > > > completed?  Or alternatively, the problem is that super_cache_count() doesn't
> > > > check for SB_ACTIVE.
> > > > 
> > > 
> > > Coincidentally, this is already going to be fixed by commit 79f546a696bff259
> > > ("fs: don't scan the inode cache before SB_BORN is set") in vfs/for-linus.
> > > 
> > 
> > Just an idea, but if shrinker registration is too early, can't we postpone it
> > like below?
> 
> Wonderful.  And when ->mount() returns you a subtree of the same filesystem again,
> that will do what, exactly?
> 
Can't we detect it via list_empty(&sb->s_shrink.list) test
before calling register_shrinker_prepared(&sb->s_shrink) ?
