Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 650A86B026F
	for <linux-mm@kvack.org>; Mon, 14 May 2018 21:14:00 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f23-v6so10854301wra.20
        for <linux-mm@kvack.org>; Mon, 14 May 2018 18:14:00 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id h25-v6si6174533wmi.24.2018.05.14.18.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 18:13:58 -0700 (PDT)
Date: Tue, 15 May 2018 02:13:55 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] shmem: don't call put_super() when fill_super() failed.
Message-ID: <20180515011355.GM30522@ZenIV.linux.org.uk>
References: <201805150027.w4F0RZ27055056@www262.sakura.ne.jp>
 <20180515003912.GL30522@ZenIV.linux.org.uk>
 <201805150052.w4F0qbgv062016@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805150052.w4F0qbgv062016@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Eric Biggers <ebiggers3@gmail.com>, syzbot+d2586fde8fdcead3647f@syzkaller.appspotmail.com, hughd@google.com, syzkaller-bugs@googlegroups.com, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Tue, May 15, 2018 at 09:52:37AM +0900, Tetsuo Handa wrote:
> > On Tue, May 15, 2018 at 09:27:35AM +0900, Tetsuo Handa wrote:
> > > Eric Biggers wrote:
> > > > > I'm not following, since generic_shutdown_super() only calls ->put_super() if
> > > > > ->s_root is set, which only happens at the end of shmem_fill_super().  Isn't the
> > > > > real problem that s_shrink is registered too early, causing super_cache_count()
> > > > > and shmem_unused_huge_count() to potentially run before shmem_fill_super() has
> > > > > completed?  Or alternatively, the problem is that super_cache_count() doesn't
> > > > > check for SB_ACTIVE.
> > > > > 
> > > > 
> > > > Coincidentally, this is already going to be fixed by commit 79f546a696bff259
> > > > ("fs: don't scan the inode cache before SB_BORN is set") in vfs/for-linus.
> > > > 
> > > 
> > > Just an idea, but if shrinker registration is too early, can't we postpone it
> > > like below?
> > 
> > Wonderful.  And when ->mount() returns you a subtree of the same filesystem again,
> > that will do what, exactly?
> > 
> Can't we detect it via list_empty(&sb->s_shrink.list) test
> before calling register_shrinker_prepared(&sb->s_shrink) ?

What for?  Seriously, what's the benefit of doing that in such a convoluted way?
Avoiding a trivial check in super_cache_count()?  The same check we normally
do in places where we are not holding an active reference to superblock and
want to make sure it's alive, at that...
