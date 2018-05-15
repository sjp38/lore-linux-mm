Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7336B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 20:39:18 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p7-v6so10816957wrj.4
        for <linux-mm@kvack.org>; Mon, 14 May 2018 17:39:18 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id b79-v6si9249398wrd.260.2018.05.14.17.39.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 17:39:17 -0700 (PDT)
Date: Tue, 15 May 2018 01:39:12 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] shmem: don't call put_super() when fill_super() failed.
Message-ID: <20180515003912.GL30522@ZenIV.linux.org.uk>
References: <20180514170423.GA252575@gmail.com>
 <20180514171154.GB252575@gmail.com>
 <201805150027.w4F0RZ27055056@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805150027.w4F0RZ27055056@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Eric Biggers <ebiggers3@gmail.com>, syzbot+d2586fde8fdcead3647f@syzkaller.appspotmail.com, hughd@google.com, syzkaller-bugs@googlegroups.com, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Tue, May 15, 2018 at 09:27:35AM +0900, Tetsuo Handa wrote:
> Eric Biggers wrote:
> > > I'm not following, since generic_shutdown_super() only calls ->put_super() if
> > > ->s_root is set, which only happens at the end of shmem_fill_super().  Isn't the
> > > real problem that s_shrink is registered too early, causing super_cache_count()
> > > and shmem_unused_huge_count() to potentially run before shmem_fill_super() has
> > > completed?  Or alternatively, the problem is that super_cache_count() doesn't
> > > check for SB_ACTIVE.
> > > 
> > 
> > Coincidentally, this is already going to be fixed by commit 79f546a696bff259
> > ("fs: don't scan the inode cache before SB_BORN is set") in vfs/for-linus.
> > 
> 
> Just an idea, but if shrinker registration is too early, can't we postpone it
> like below?

Wonderful.  And when ->mount() returns you a subtree of the same filesystem again,
that will do what, exactly?
