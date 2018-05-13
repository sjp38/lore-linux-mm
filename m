Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB136B0707
	for <linux-mm@kvack.org>; Sun, 13 May 2018 06:20:44 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f10-v6so8742237pln.21
        for <linux-mm@kvack.org>; Sun, 13 May 2018 03:20:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o6-v6si6672634pls.234.2018.05.13.03.20.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 May 2018 03:20:42 -0700 (PDT)
Subject: Re: KASAN: use-after-free Read in corrupted
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <000000000000eec34b056c128997@google.com>
	<CACT4Y+aRyMWXS0K0bqAVgBOTh=vXEY0dwM91vdSkJ75zgy+k-A@mail.gmail.com>
In-Reply-To: <CACT4Y+aRyMWXS0K0bqAVgBOTh=vXEY0dwM91vdSkJ75zgy+k-A@mail.gmail.com>
Message-Id: <201805131920.GJJ58398.OHFVOOSQtLMJFF@I-love.SAKURA.ne.jp>
Date: Sun, 13 May 2018 19:20:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, syzbot+3417712847e7219a60ee@syzkaller.appspotmail.com, miklos@szeredi.hu
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, hmclauchlan@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

Dmitry Vyukov wrote:
> This looks very similar to "KASAN: use-after-free Read in fuse_kill_sb_blk":
> https://groups.google.com/d/msg/syzkaller-bugs/4C4oiBX8vZ0/0NTQRcUYBgAJ
> 
> which you fixed with "fuse: don't keep dead fuse_conn at fuse_fill_super().":
> https://groups.google.com/d/msg/syzkaller-bugs/4C4oiBX8vZ0/W6pi8NdbBgAJ
> 
> However, here we have use-after-free in fuse_kill_sb_anon instead of
> use_kill_sb_blk. Do you think your patch will fix this as well?

Yes, for fuse_kill_sb_anon() and fuse_kill_sb_blk() are symmetrical.
I'm waiting for Miklos Szeredi to apply that patch.

static inline struct fuse_conn *get_fuse_conn_super(struct super_block *sb)
{
	return sb->s_fs_info;
}

static struct file_system_type fuse_fs_type = {
	.owner          = THIS_MODULE,
	.name           = "fuse",
	.fs_flags       = FS_HAS_SUBTYPE,
	.mount          = fuse_mount,
	.kill_sb        = fuse_kill_sb_anon,
};

static struct file_system_type fuseblk_fs_type = {
	.owner          = THIS_MODULE,
	.name           = "fuseblk",
	.mount          = fuse_mount_blk,
	.kill_sb        = fuse_kill_sb_blk,
	.fs_flags       = FS_REQUIRES_DEV | FS_HAS_SUBTYPE,
};

static void fuse_kill_sb_anon(struct super_block *sb)
{
	struct fuse_conn *fc = get_fuse_conn_super(sb);

	if (fc) {
		down_write(&fc->killsb);
		fc->sb = NULL;
		up_write(&fc->killsb);
	}

	kill_anon_super(sb);
}

static void fuse_kill_sb_blk(struct super_block *sb)
{
	struct fuse_conn *fc = get_fuse_conn_super(sb);

	if (fc) {
		down_write(&fc->killsb);
		fc->sb = NULL;
		up_write(&fc->killsb);
	}

	kill_block_super(sb);
}
