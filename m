Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5956B0708
	for <linux-mm@kvack.org>; Sun, 13 May 2018 06:33:09 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b36-v6so8765057pli.2
        for <linux-mm@kvack.org>; Sun, 13 May 2018 03:33:09 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d12-v6sor2705934pgn.150.2018.05.13.03.33.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 May 2018 03:33:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201805131920.GJJ58398.OHFVOOSQtLMJFF@I-love.SAKURA.ne.jp>
References: <000000000000eec34b056c128997@google.com> <CACT4Y+aRyMWXS0K0bqAVgBOTh=vXEY0dwM91vdSkJ75zgy+k-A@mail.gmail.com>
 <201805131920.GJJ58398.OHFVOOSQtLMJFF@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 13 May 2018 12:32:47 +0200
Message-ID: <CACT4Y+asb-Anvn3ENyUVDGVivFUDT5XXz750ioi5MqWDtgvwRg@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in corrupted
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+3417712847e7219a60ee@syzkaller.appspotmail.com>, Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, hmclauchlan@fb.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Philippe Ombredanne <pombredanne@nexb.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Thomas Gleixner <tglx@linutronix.de>

On Sun, May 13, 2018 at 12:20 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Dmitry Vyukov wrote:
>> This looks very similar to "KASAN: use-after-free Read in fuse_kill_sb_blk":
>> https://groups.google.com/d/msg/syzkaller-bugs/4C4oiBX8vZ0/0NTQRcUYBgAJ
>>
>> which you fixed with "fuse: don't keep dead fuse_conn at fuse_fill_super().":
>> https://groups.google.com/d/msg/syzkaller-bugs/4C4oiBX8vZ0/W6pi8NdbBgAJ
>>
>> However, here we have use-after-free in fuse_kill_sb_anon instead of
>> use_kill_sb_blk. Do you think your patch will fix this as well?
>
> Yes, for fuse_kill_sb_anon() and fuse_kill_sb_blk() are symmetrical.
> I'm waiting for Miklos Szeredi to apply that patch.


Thanks for confirming. Let's do:

#syz fix: fuse: don't keep dead fuse_conn at fuse_fill_super().


> static inline struct fuse_conn *get_fuse_conn_super(struct super_block *sb)
> {
>         return sb->s_fs_info;
> }
>
> static struct file_system_type fuse_fs_type = {
>         .owner          = THIS_MODULE,
>         .name           = "fuse",
>         .fs_flags       = FS_HAS_SUBTYPE,
>         .mount          = fuse_mount,
>         .kill_sb        = fuse_kill_sb_anon,
> };
>
> static struct file_system_type fuseblk_fs_type = {
>         .owner          = THIS_MODULE,
>         .name           = "fuseblk",
>         .mount          = fuse_mount_blk,
>         .kill_sb        = fuse_kill_sb_blk,
>         .fs_flags       = FS_REQUIRES_DEV | FS_HAS_SUBTYPE,
> };
>
> static void fuse_kill_sb_anon(struct super_block *sb)
> {
>         struct fuse_conn *fc = get_fuse_conn_super(sb);
>
>         if (fc) {
>                 down_write(&fc->killsb);
>                 fc->sb = NULL;
>                 up_write(&fc->killsb);
>         }
>
>         kill_anon_super(sb);
> }
>
> static void fuse_kill_sb_blk(struct super_block *sb)
> {
>         struct fuse_conn *fc = get_fuse_conn_super(sb);
>
>         if (fc) {
>                 down_write(&fc->killsb);
>                 fc->sb = NULL;
>                 up_write(&fc->killsb);
>         }
>
>         kill_block_super(sb);
> }
