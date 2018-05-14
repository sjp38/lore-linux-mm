Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 123176B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 14:07:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a127-v6so3832544wmh.6
        for <linux-mm@kvack.org>; Mon, 14 May 2018 11:07:23 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id p202-v6si5689333wmd.227.2018.05.14.11.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 11:07:21 -0700 (PDT)
Date: Mon, 14 May 2018 19:07:10 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] shmem: don't call put_super() when fill_super() failed.
Message-ID: <20180514180710.GK30522@ZenIV.linux.org.uk>
References: <201805140657.w4E6vV4a035377@www262.sakura.ne.jp>
 <20180514170423.GA252575@gmail.com>
 <20180514171154.GB252575@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180514171154.GB252575@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot+d2586fde8fdcead3647f@syzkaller.appspotmail.com, hughd@google.com, syzkaller-bugs@googlegroups.com, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Mon, May 14, 2018 at 10:11:54AM -0700, Eric Biggers wrote:

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

Exactly.  While we are at it, we could add

static void shmem_kill_super(struct super_block *sb)
{
        struct shmem_sb_info *sbinfo = SHMEM_SB(sb);

	kill_litter_super(sb);
	if (sbinfo) {
		percpu_counter_destroy(&sbinfo->used_blocks);
		mpol_put(sbinfo->mpol);
		kfree(sbinfo);
	}
}

use that for ->kill_sb() and to hell with shmem_put_super() *and* its call in
cleanup path of shmem_fill_super() - these err = -E...; goto failed; in there
become simply return -E...;
