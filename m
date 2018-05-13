Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA4756B06EC
	for <linux-mm@kvack.org>; Sun, 13 May 2018 07:56:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j14-v6so8267231pfn.11
        for <linux-mm@kvack.org>; Sun, 13 May 2018 04:56:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a70-v6sor3763911pfc.150.2018.05.13.04.56.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 May 2018 04:56:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201805131947.IJC65168.OOFOMFJHLVQStF@I-love.SAKURA.ne.jp>
References: <000000000000eec34b056c128997@google.com> <CACT4Y+aRyMWXS0K0bqAVgBOTh=vXEY0dwM91vdSkJ75zgy+k-A@mail.gmail.com>
 <201805131920.GJJ58398.OHFVOOSQtLMJFF@I-love.SAKURA.ne.jp>
 <CACT4Y+asb-Anvn3ENyUVDGVivFUDT5XXz750ioi5MqWDtgvwRg@mail.gmail.com> <201805131947.IJC65168.OOFOMFJHLVQStF@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 13 May 2018 13:56:01 +0200
Message-ID: <CACT4Y+ZwLPx1uQo=oxvOtbo4Jjb-J-S-QJ_wMhP=DkCPQjbzZg@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in corrupted
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+3417712847e7219a60ee@syzkaller.appspotmail.com>, Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Philippe Ombredanne <pombredanne@nexb.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Thomas Gleixner <tglx@linutronix.de>

On Sun, May 13, 2018 at 12:47 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Dmitry Vyukov wrote:
>> On Sun, May 13, 2018 at 12:20 PM, Tetsuo Handa
>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> > Dmitry Vyukov wrote:
>> >> This looks very similar to "KASAN: use-after-free Read in fuse_kill_sb_blk":
>> >> https://groups.google.com/d/msg/syzkaller-bugs/4C4oiBX8vZ0/0NTQRcUYBgAJ
>> >>
>> >> which you fixed with "fuse: don't keep dead fuse_conn at fuse_fill_super().":
>> >> https://groups.google.com/d/msg/syzkaller-bugs/4C4oiBX8vZ0/W6pi8NdbBgAJ
>> >>
>> >> However, here we have use-after-free in fuse_kill_sb_anon instead of
>> >> use_kill_sb_blk. Do you think your patch will fix this as well?
>> >
>> > Yes, for fuse_kill_sb_anon() and fuse_kill_sb_blk() are symmetrical.
>> > I'm waiting for Miklos Szeredi to apply that patch.
>>
>>
>> Thanks for confirming. Let's do:
>>
>> #syz fix: fuse: don't keep dead fuse_conn at fuse_fill_super().
>>
> Excuse me, but that patch is not yet applied to any git tree. Isn't the rule that
>
>   If you forgot to add the Reported-by tag, once the fix for this bug is merged into any tree, please reply to this email with:
>   #syz fix: exact-commit-title

Sorry, the doc is not 100% precisely express the situation. I think
this was discussed several times, but the info is scattered.
What matters in the end is that syzbot discovers the commit using the
title in the tested trees. For example, consider that a commit is
merged into some sub-sub-system tree, its commit title can still
change (for example, an upper subsystem maintainer decided to fix it
up, unlikely, but possible), or the commit can be simply dropped if
upper subsystem maintainer does not like it.
On the other hand, for significant portion of commits once they are
just mailed we are reasonably sure that they will appear upstream
under the original title.

So the full situation is more like:
First you need to decide if you want to deal with this bug sooner or
later (we usually want to deal with them sooner).
If you want to deal with it sooner, the criteria is that you are
"reasonably sure that the commit will reach upstream under this
title", for whatever reason. If it turns out to be wrong, then we will
need to get back to it later and fix up commit title.
If you want to deal with it later, then you can wait till it reaches
upstream and then use syz fix with the actual title.

So I did "syz fix" in the hope that the commit will be taken upstream
as-is, and we don't need to get back to it later.
It also has a useful consequence that the commit that at least was
_meant_ to fix it is recorded on mailing lists. So if it's not fixed
after 3 months, we can find the commit and check if it was forgotten
or renamed or something else.

What do you think of this update to docs:
https://github.com/dvyukov/syzkaller/commit/90075c45aa4422c4656020a3c4e1d6d7a04424ed
Does it make situation clearer?


> ? That's the reason I keep
>
>   KASAN: use-after-free Read in fuse_kill_sb_blk
>   https://syzkaller.appspot.com/bug?id=a07a680ed0a9290585ca424546860464dd9658db
>
> report "open()" table but I want keyword column available in the "open()" table
> so that we can announce that "patch is proposed and waiting for review" state.

I wonder if marking the bug with "syz fix" is actually the right way
to handle this. There will be a note about the commit that is supposed
to fix this for both humans reading the email thread and syzbot. Then,
on dashboard it will go to "fix pending" state, which clearly
distinguishes them from other "open" bugs. And we can see that the
commit is still not present in any tested trees by looking at the last
column (Patched: 0/6). I was also thinking of recording time when "syz
fix" command was issued and then marking bugs with red if "syz fix"
was issued more than X months ago, but syzbot still has not discovered
the commit in any trees (useful for detecting typos in commit titles,
or renamed commits).
When we issue such command, we could say something like "Tentatively
marking this as fixed with: ..." to make it clear what happens.
What do you think?
