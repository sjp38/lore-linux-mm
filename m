Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F776C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:41:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23EF42084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:41:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fja1SAdn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23EF42084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFAFB6B0003; Wed, 15 May 2019 10:41:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD3386B0006; Wed, 15 May 2019 10:41:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C1236B0007; Wed, 15 May 2019 10:41:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC426B0003
	for <linux-mm@kvack.org>; Wed, 15 May 2019 10:41:57 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id b26so616245vsl.4
        for <linux-mm@kvack.org>; Wed, 15 May 2019 07:41:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=kyqrOi+JSDiqriYxvI1BLUk2O3fUbri6hLyp92DBSeE=;
        b=m0nz5kKl86aL63jYxoOKLMb02KIxoZsisV6Ph+kCzds9Hwp+MnO8ytxhj4c5SGQEw8
         VCo08u+crj56j3JWvhyMlLgrsyFUNXZ1cd5CKCJuhMWstcoZdd0A4bf3rxOLUEUZmUSm
         3UqFQJ25c2j7BFFIZP34XG4l8BFfcwopP7OXjDRq9WUGUXfog5XTcH80n47P/w4ftcL6
         pXE8/yp6lWziOf3vMm3VZR4Wu/ajfuz+kfkPraSSNLZKCMgRvyq/119jcXshUCBddgAv
         hpYENKd+vwPlw0MvqaJUkqNQ9No0VKo5mRt0fRYItgey8FyOZNyRwCer3sU39ywzecvS
         j1jQ==
X-Gm-Message-State: APjAAAUvs6V33KyTGx7LKNQONINNfZS/5RjqPAWiA/bqs0ayWL2uLoIL
	bQt723cmHRuIvy8JYP+ao13MFEdyxBtVrcSKpSmh3XvwaWGvixOEokfydLsseOrzQA4ghoRspde
	xbAUwEF7LpU19pgztEN0J6DBpkYLy4gbnxmaJhCZ74jrctVwnJQc2wwiwP3esVc6fBg==
X-Received: by 2002:a67:b348:: with SMTP id b8mr12944038vsm.144.1557931317058;
        Wed, 15 May 2019 07:41:57 -0700 (PDT)
X-Received: by 2002:a67:b348:: with SMTP id b8mr12943991vsm.144.1557931316140;
        Wed, 15 May 2019 07:41:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557931316; cv=none;
        d=google.com; s=arc-20160816;
        b=mE1w2Q8mC2xQoO3EDlLZA+Mb0BTei21/htXNlKhTnLBBk+V9B23T6p1RQN+xxbtiti
         RO693sOAnKY+VfZrm3zPnPI6Dqb4UOKn/cgDDot/+etrWJ5ohQMYOaSaz6yLt+1063w/
         bC8JL0lwlgD7DgCqLmoNSvv8rl0ia9WTCn7rdqi2VRd0hflre1yXwfGmATQZY5PaIWKH
         oBqIp6TBUskuyC2aIYIJL4586PZ2Orz12Z8M7lf4B/XkSA/ugYqAkr2WruMMcKv62Afz
         rDPIP6ehiXfMtwBWYHxM4LwKM0i9oucE0iNfzAc9gINTrQtSD0ESsl8kl3GbdVUkYntQ
         fYpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=kyqrOi+JSDiqriYxvI1BLUk2O3fUbri6hLyp92DBSeE=;
        b=v4HrOItPHABxPGEGP+7Ifyh4+KURbVR4UKltqEWoXgEM5v331L0i8bWubwGu8/Xitu
         orGTWvUteK0SO5RRXagEzJfqZxNEq5KiaIaakchuoc/e1qDNHtWrgDsU+kq0lUPHlN/G
         Fe46tvYEio9n4IsFSf8OjJiOZTfkXBjQw7llKyJr7xUrWR1Z4iIAId4Rn+JrYRCgzrAC
         vwlyYByoIpme+7i2/DQ0enWGFtTj/8o06+GNbhva3GxMpNLZ3rZ9gQBbqa7PKougE+8N
         qEwv+i/LP1mp/6b5VIxucvb8zf4r1/VRmj9aF3I54uvdvvSdJm0EYoGP2H/iiMGpiUIR
         LNcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fja1SAdn;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14sor1027278vsp.5.2019.05.15.07.41.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 07:41:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fja1SAdn;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=kyqrOi+JSDiqriYxvI1BLUk2O3fUbri6hLyp92DBSeE=;
        b=fja1SAdncJKzVEpsr6jccnpaV7vbGu5OCk0r9Je+XDP9UpjODRhjIfaT31oqvm2LlN
         DCg4uj+LmtnjOnOsn96zCTA8Q0MHlfxH8P2yQjZjJjxtag9efgMXfYKz8beigXzpf3/+
         X/SMUrBGInK43TFKnXnfH5J88/1azv/KulaF4RlNxIcRcgdpjppZwNMwBPq7do2SHkmc
         qXUT/T6XAofGuoRK18+100QF5mWi1dbmPcI/eg5rGh6CK92wWKZnqgt9K0QSH8O/1mol
         5YUkVI0lGmPXn736aUaIAsXzQAJz5bRFZSs/lSktPXPEBQEezWEibFTE7raxdRYAJgSA
         65ig==
X-Google-Smtp-Source: APXvYqxvU/yjs/eG1W5tPjt2ohsn6xjNIutmqtITlHpOqtZGM2YjzMYaVrPb1QCfoOmFOnxtHPG6P5O1efiCK2jnK3c=
X-Received: by 2002:a67:7241:: with SMTP id n62mr19856742vsc.217.1557931315562;
 Wed, 15 May 2019 07:41:55 -0700 (PDT)
MIME-Version: 1.0
References: <00000000000016eb330575bd2fab@google.com> <CAG_fn=WwdgnCQ2fOw_LEXwv7Fdbmshxo57XJXNbfbawDndJZ_Q@mail.gmail.com>
 <CAG_fn=UjeL9BmAq+FDK01n4mH7ieQXpxkRRxAbDPd5UcC7eZPw@mail.gmail.com>
 <06a3b403-7fe3-24fd-0ce2-9a604f3bbe62@kernel.dk> <CAG_fn=UgdYm4YHpWkwv=Us1m1Fms64JCPEOkUR1+6pxJako7bg@mail.gmail.com>
In-Reply-To: <CAG_fn=UgdYm4YHpWkwv=Us1m1Fms64JCPEOkUR1+6pxJako7bg@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 15 May 2019 16:41:44 +0200
Message-ID: <CAG_fn=WnfGgyRMdS1Q+5w8A1WkaC6Ji+vpAEzAZFwiatRC=LtQ@mail.gmail.com>
Subject: Re: KMSAN: kernel-infoleak in copy_page_to_iter (2)
To: Jens Axboe <axboe@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, bart.vanassche@wdc.com, 
	matias.bjorling@wdc.com, Andi Kleen <ak@linux.intel.com>, jack@suse.cz, 
	jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, mawilcox@microsoft.com, mgorman@techsingularity.net, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Potapenko <glider@google.com>
Date: Wed, Jan 2, 2019 at 11:09 AM
To: Jens Axboe
Cc: Andrew Morton, <bart.vanassche@wdc.com>,
<matias.bjorling@wdc.com>, Andi Kleen, <jack@suse.cz>,
<jlayton@redhat.com>, LKML, Linux Memory Management List,
<mawilcox@microsoft.com>, <mgorman@techsingularity.net>,
<syzkaller-bugs@googlegroups.com>

> On Wed, Dec 19, 2018 at 2:23 PM Jens Axboe <axboe@kernel.dk> wrote:
> >
> > On 12/19/18 3:23 AM, Alexander Potapenko wrote:
> > > On Thu, Sep 13, 2018 at 11:23 AM Alexander Potapenko <glider@google.c=
om> wrote:
> > >>
> > >> On Thu, Sep 13, 2018 at 11:18 AM syzbot
> > >> <syzbot+2dcfeaf8cb49b05e8f1a@syzkaller.appspotmail.com> wrote:
> > >>>
> > >>> Hello,
> > >>>
> > >>> syzbot found the following crash on:
> > >>>
> > >>> HEAD commit:    123906095e30 kmsan: introduce kmsan_interrupt_enter=
()/kmsa..
> > >>> git tree:       https://github.com/google/kmsan.git/master
> > >>> console output: https://syzkaller.appspot.com/x/log.txt?x=3D1249fcb=
8400000
> > >>> kernel config:  https://syzkaller.appspot.com/x/.config?x=3D848e407=
57852af3e
> > >>> dashboard link: https://syzkaller.appspot.com/bug?extid=3D2dcfeaf8c=
b49b05e8f1a
> > >>> compiler:       clang version 7.0.0 (trunk 334104)
> > >>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=3D116ef=
050400000
> > >>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=3D122870f=
f800000
> > >>>
> > >>> IMPORTANT: if you fix the bug, please add the following tag to the =
commit:
> > >>> Reported-by: syzbot+2dcfeaf8cb49b05e8f1a@syzkaller.appspotmail.com
> > >>>
> > >>> random: sshd: uninitialized urandom read (32 bytes read)
> > >>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > >>> BUG: KMSAN: kernel-infoleak in copyout lib/iov_iter.c:140 [inline]
> > >>> BUG: KMSAN: kernel-infoleak in copy_page_to_iter_iovec lib/iov_iter=
.c:212
> > >>> [inline]
> > >>> BUG: KMSAN: kernel-infoleak in copy_page_to_iter+0x754/0x1b70
> > >>> lib/iov_iter.c:716
> > >>> CPU: 0 PID: 4516 Comm: blkid Not tainted 4.17.0+ #9
> > >>> Hardware name: Google Google Compute Engine/Google Compute Engine, =
BIOS
> > >>> Google 01/01/2011
> > >>> Call Trace:
> > >>>   __dump_stack lib/dump_stack.c:77 [inline]
> > >>>   dump_stack+0x185/0x1d0 lib/dump_stack.c:113
> > >>>   kmsan_report+0x188/0x2a0 mm/kmsan/kmsan.c:1125
> > >>>   kmsan_internal_check_memory+0x17e/0x1f0 mm/kmsan/kmsan.c:1238
> > >>>   kmsan_copy_to_user+0x7a/0x160 mm/kmsan/kmsan.c:1261
> > >>>   copyout lib/iov_iter.c:140 [inline]
> > >>>   copy_page_to_iter_iovec lib/iov_iter.c:212 [inline]
> > >>>   copy_page_to_iter+0x754/0x1b70 lib/iov_iter.c:716
> > >>>   generic_file_buffered_read mm/filemap.c:2185 [inline]
> > >>>   generic_file_read_iter+0x2ef8/0x44d0 mm/filemap.c:2362
> > >>>   blkdev_read_iter+0x20d/0x280 fs/block_dev.c:1930
> > >>>   call_read_iter include/linux/fs.h:1778 [inline]
> > >>>   new_sync_read fs/read_write.c:406 [inline]
> > >>>   __vfs_read+0x775/0x9d0 fs/read_write.c:418
> > >>>   vfs_read+0x36c/0x6b0 fs/read_write.c:452
> > >>>   ksys_read fs/read_write.c:578 [inline]
> > >>>   __do_sys_read fs/read_write.c:588 [inline]
> > >>>   __se_sys_read fs/read_write.c:586 [inline]
> > >>>   __x64_sys_read+0x1bf/0x3e0 fs/read_write.c:586
> > >>>   do_syscall_64+0x15b/0x230 arch/x86/entry/common.c:287
> > >>>   entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > >>> RIP: 0033:0x7fdeff68f310
> > >>> RSP: 002b:00007ffe999660b8 EFLAGS: 00000246 ORIG_RAX: 0000000000000=
000
> > >>> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007fdeff68f310
> > >>> RDX: 0000000000000100 RSI: 0000000001e78df8 RDI: 0000000000000003
> > >>> RBP: 0000000001e78dd0 R08: 0000000000000028 R09: 0000000001680000
> > >>> R10: 0000000000000000 R11: 0000000000000246 R12: 0000000001e78030
> > >>> R13: 0000000000000100 R14: 0000000001e78080 R15: 0000000001e78de8
> > >>>
> > >>> Uninit was created at:
> > >>>   kmsan_save_stack_with_flags mm/kmsan/kmsan.c:282 [inline]
> > >>>   kmsan_alloc_meta_for_pages+0x161/0x3a0 mm/kmsan/kmsan.c:819
> > >>>   kmsan_alloc_page+0x82/0xe0 mm/kmsan/kmsan.c:889
> > >>>   __alloc_pages_nodemask+0xf7b/0x5cc0 mm/page_alloc.c:4402
> > >>>   alloc_pages_current+0x6b1/0x970 mm/mempolicy.c:2093
> > >>>   alloc_pages include/linux/gfp.h:494 [inline]
> > >>>   __page_cache_alloc+0x95/0x320 mm/filemap.c:946
> > >>>   pagecache_get_page+0x52b/0x1450 mm/filemap.c:1577
> > >>>   grab_cache_page_write_begin+0x10d/0x190 mm/filemap.c:3089
> > >>>   block_write_begin+0xf9/0x3a0 fs/buffer.c:2068
> > >>>   blkdev_write_begin+0xf5/0x110 fs/block_dev.c:584
> > >>>   generic_perform_write+0x438/0x9d0 mm/filemap.c:3139
> > >>>   __generic_file_write_iter+0x43b/0xa10 mm/filemap.c:3264
> > >>>   blkdev_write_iter+0x3a8/0x5f0 fs/block_dev.c:1910
> > >>>   do_iter_readv_writev+0x81c/0xa20 include/linux/fs.h:1778
> > >>>   do_iter_write+0x30d/0xd50 fs/read_write.c:959
> > >>>   vfs_writev fs/read_write.c:1004 [inline]
> > >>>   do_writev+0x3be/0x820 fs/read_write.c:1039
> > >>>   __do_sys_writev fs/read_write.c:1112 [inline]
> > >>>   __se_sys_writev fs/read_write.c:1109 [inline]
> > >>>   __x64_sys_writev+0xe1/0x120 fs/read_write.c:1109
> > >>>   do_syscall_64+0x15b/0x230 arch/x86/entry/common.c:287
> > >>>   entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > >>>
> > >>> Bytes 4-255 of 256 are uninitialized
> > >>> Memory access starts at ffff8801b9903000
> > >>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > >> This particular report was caused by the repro program writing a byt=
e
> > >> to /dev/nullb0 and /sbin/blkid reading from that device in the
> > >> background.
> > >> But it turns out that simply running `cat /dev/nullb0` already print=
s
> > >> uninitialized kernel memory.
> > >> Is this the intended behavior of the null block driver?
> > > A friendly ping, this bug is still reproducible on syzbot.
> >
> > Does this fix it?
> There must be something wrong with my tool, as it stops reporting this
> bug when I apply your patch.
> However when I run `cat /dev/nullb0 | strings` and wait long enough I
> start seeing meaningful strings (file names, env dumps etc.)
> I suspect this is still unexpected, right?
A friendly ping, as we're still seeing similar errors.
> > diff --git a/drivers/block/null_blk_main.c b/drivers/block/null_blk_mai=
n.c
> > index 62c9654b9ce8..08808c572692 100644
> > --- a/drivers/block/null_blk_main.c
> > +++ b/drivers/block/null_blk_main.c
> > @@ -655,7 +655,7 @@ static struct nullb_page *null_alloc_page(gfp_t gfp=
_flags)
> >         if (!t_page)
> >                 goto out;
> >
> > -       t_page->page =3D alloc_pages(gfp_flags, 0);
> > +       t_page->page =3D alloc_pages(gfp_flags | __GFP_ZERO, 0);
> >         if (!t_page->page)
> >                 goto out_freepage;
> >
> >
> > --
> > Jens Axboe
> >
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

