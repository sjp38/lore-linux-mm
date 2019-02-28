Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C3D2C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 18:04:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E1520863
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 18:04:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZXevkxKN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E1520863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 631168E0003; Thu, 28 Feb 2019 13:04:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B7758E0001; Thu, 28 Feb 2019 13:04:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 458BC8E0003; Thu, 28 Feb 2019 13:04:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18B318E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:04:15 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id p12so16305247iod.14
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 10:04:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zagh5EVKxzE3Td/3/VyKezplDQ1Wb1sgvSmMyS1oxlE=;
        b=leRl0QCyDlowGVn0GI34Urh7tNQdd/ptQ4zSR5tpjN5te0QaGAl5qRiB5UtHT4ZPJn
         GFRHatO/nuwYIdWY9sWYecPbDYw0F3WptDC8sK/bPNBffF37AabfF9ngucBobHALiOic
         hV0gZExMWIzVsRxftxRWS1L+ZjJABEnKI7YwSzMDBVmPUVSq9mMUK/zXZW4IteJlhols
         TN44xZdPYic5DHI14YzGFcEFQpKgssNNks/QJse+WE5dc8EzuoQ7bqRrIZKMzGtv0+Re
         QH/hJxc0EoIGNdVd7R/jh9+8Ji5+BD0XdirV/9XjuHgKA7rfC4vCW+xCS2Oa56r2Njqi
         lKbA==
X-Gm-Message-State: APjAAAXqqfza+SnV9RoQeAa3/fC+5U6tj6A3JFaVXpzuXzbWfJwxXDwo
	nbCaPZPBoWpWWr1FuFB1wY7v917ZEiv7BvrqsDaxKeAE5cgdr7vmAYq8ZxZ2tOd4VQoBA5hJrIf
	PFxKCHLeG45w8cLTH/edQVxv1ctR/rbTfigLfxKPWFuxJh7obx7D5vtfCgxkrbFyjf05GrkvL1q
	GY8qw9Yrip7iKcPHrp/Pe7wZFCKkaEvK4h28VG8OGyvd3/ZYnYkBjLsZBcOL5Xh9xXwRnB9Kuey
	EvL8n0NmMPl55zop79Ae4qSKaF3isLSQ8yXH1oO6WTWZ5uR/vCVWmg7RllYVX3ASvt4J2n5jI94
	+hPOh0C5TwEnn1UFUYETtIZOnYFSn1CtZXyS93WI6mQU/k9rbyORYmGctH4k2RxLjsMZ4XYO5J3
	J
X-Received: by 2002:a05:660c:6c3:: with SMTP id z3mr684691itk.83.1551377054760;
        Thu, 28 Feb 2019 10:04:14 -0800 (PST)
X-Received: by 2002:a05:660c:6c3:: with SMTP id z3mr684638itk.83.1551377053756;
        Thu, 28 Feb 2019 10:04:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551377053; cv=none;
        d=google.com; s=arc-20160816;
        b=SGQNpllgurDZq87RCQpRz8X6QD2EjJN3e5t7MqPTAIKb+CvF2VU9f9UjD80l+O4cKN
         Y/J4fIBfFS/o7qCPZaIkrkAYp/BAJOtLn/LuvTgy4tifn14qU5yBQJenrkMdjo5fKZkB
         UlZEAXNP0heis/RQH6mWvYfZ2pZDTXxCwnFtwhmeMMHj2KP5dG0+tw8d0ECr1PPh8CrS
         I6IVJO6du4z/wGCL83FrVi/lB8KkpFGVsw1S7C2fV5piwz0ilhsNi6l+VqLjXrjndvgY
         0O9UpD45IDSk1F+iq1Nj9Lwe8Fp0KGF+tCXrSJiHKOtRYbXb4lRB5hGWiCJB5e1nAxWn
         zvZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zagh5EVKxzE3Td/3/VyKezplDQ1Wb1sgvSmMyS1oxlE=;
        b=gd3hbrkyd7qHH3iYA53yX87ljWK2Hz8Sd6ApB7VjVn5zY1xGdymk/VfSFe3fO+y43P
         6TDnpkhLPL9R6mNssDrPCDOOueXWYrjn32Sg1XmYpBd7kHSzPCxdJ30aQhPyy29B0Fje
         odxLvUJVd0Km6SJsXqPaQ7gBueGxvQOWi9LRB6rKoPrYsW4QLXjTpLsC9qhlWsRSW5Pq
         ZGnUX5+akkKhFw5m9q9YJ0COWpqQanIqfj81nI+f5y3h+R0/kTvR+SSlDs0OteFuPLej
         NLyAUFK67OQXvnJfAKiXcvNOh/FaiR1mKKPxXPtHsu0Ts3EC6riNwA5wOyKG9oQTDxrk
         Zfng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZXevkxKN;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t82sor10512444iod.102.2019.02.28.10.04.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 10:04:13 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZXevkxKN;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zagh5EVKxzE3Td/3/VyKezplDQ1Wb1sgvSmMyS1oxlE=;
        b=ZXevkxKNaUybDqsZkUcd1FOt7UcMpZ18nh8+GiAyocFiq5D8fD2uMgx5NqhSDw5R08
         BwcCdOT6ku1Vi72PVEUfmbVJeVh5wXYF5aImpDcjIFsvCSjOhWUykKQB02Grp0JUoFCj
         DirzaRGcWJ2C427bU8YYZDq//fyOet2rcyjQWhZG2I5e+NwR3rU3CpGLoURo10jWHTwR
         avr2qzBxpBsLjZ7CfS7YVBWJ5Zl/jAQRr+ReML/gytELrv9zIFxlpCmiYbP6OgdcBU/7
         evau8HG+8MZxOMQ1ahT7+zD6H7rtOCvY5fC0fZ36SuGqJiRY0QpG9SsEf87EvQARs/OF
         BEQg==
X-Google-Smtp-Source: APXvYqzGXHM8eq9STfpB2vhsIFkcdn8uai22UFnx8WwQDLq7UteVp0ap2J85XHxnoy704hqfMAlsxM0bFzXuZTHlGUY=
X-Received: by 2002:a6b:6b18:: with SMTP id g24mr327666ioc.282.1551377053137;
 Thu, 28 Feb 2019 10:04:13 -0800 (PST)
MIME-Version: 1.0
References: <00000000000024b3aa0582f1cde7@google.com> <CACT4Y+byrcaasUaEJj=hcemEEBBkon=VC24gPwGXHzfeRP0E3w@mail.gmail.com>
 <20190228174250.GB663@sol.localdomain>
In-Reply-To: <20190228174250.GB663@sol.localdomain>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 28 Feb 2019 19:04:01 +0100
Message-ID: <CACT4Y+bL1hYRqHxqrcbStMq6k+E_1Ycqoft3JTnVnKEWuhdLAA@mail.gmail.com>
Subject: Re: BUG: Bad page state (6)
To: Eric Biggers <ebiggers@kernel.org>
Cc: syzbot <syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com>, 
	Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, arunks@codeaurora.org, 
	Dan Williams <dan.j.williams@intel.com>, Lance Roy <ldr709@gmail.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, nborisov@suse.com, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, yuehaibing@huawei.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 6:42 PM Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Thu, Feb 28, 2019 at 11:36:21AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> > On Thu, Feb 28, 2019 at 11:32 AM syzbot
> > <syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com> wrote:
> > >
> > > Hello,
> > >
> > > syzbot found the following crash on:
> > >
> > > HEAD commit:    42fd8df9d1d9 Add linux-next specific files for 20190228
> > > git tree:       linux-next
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=179ba9e0c00000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=c0f38652d28b522f
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=6f5a9b79b75b66078bf0
> > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12ed6bd0c00000
> > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10690c8ac00000
> > >
> > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > Reported-by: syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com
> >
> > +Jens, Eric,
> >
> > Looks similar to:
> > https://groups.google.com/forum/#!msg/syzkaller-bugs/E3v3XQweVBw/6BPrkIYJIgAJ
> > Perhaps the fixing commit is not in the build yet?
> >
> >
> > > BUG: Bad page state in process syz-executor193  pfn:9225a
> > > page:ffffea0002489680 count:0 mapcount:0 mapping:ffff88808652fd80 index:0x81
> > > shmem_aops
> > > name:"memfd:cgroup2"
> > > flags: 0x1fffc000008000e(referenced|uptodate|dirty|swapbacked)
> > > raw: 01fffc000008000e ffff88809277fac0 ffff88809277fac0 ffff88808652fd80
> > > raw: 0000000000000081 0000000000000000 00000000ffffffff 0000000000000000
> > > page dumped because: non-NULL mapping
> > > Modules linked in:
> > > CPU: 0 PID: 7659 Comm: syz-executor193 Not tainted 5.0.0-rc8-next-20190228
> > > #45
> > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > Google 01/01/2011
> > > Call Trace:
> > >   __dump_stack lib/dump_stack.c:77 [inline]
> > >   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> > >   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> > >   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1013
> > >   free_pages_check mm/page_alloc.c:1022 [inline]
> > >   free_pages_prepare mm/page_alloc.c:1112 [inline]
> > >   free_pcp_prepare mm/page_alloc.c:1137 [inline]
> > >   free_unref_page_prepare mm/page_alloc.c:3001 [inline]
> > >   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3070
> > >   release_pages+0x60d/0x1940 mm/swap.c:794
> > >   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
> > >   activate_page_drain mm/swap.c:297 [inline]
> > >   lru_add_drain_cpu+0x3b1/0x520 mm/swap.c:596
> > >   lru_add_drain+0x20/0x60 mm/swap.c:647
> > >   exit_mmap+0x290/0x530 mm/mmap.c:3134
> > >   __mmput kernel/fork.c:1047 [inline]
> > >   mmput+0x15f/0x4c0 kernel/fork.c:1068
> > >   exit_mm kernel/exit.c:546 [inline]
> > >   do_exit+0x816/0x2fa0 kernel/exit.c:863
> > >   do_group_exit+0x135/0x370 kernel/exit.c:980
> > >   __do_sys_exit_group kernel/exit.c:991 [inline]
> > >   __se_sys_exit_group kernel/exit.c:989 [inline]
> > >   __x64_sys_exit_group+0x44/0x50 kernel/exit.c:989
> > >   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
> > >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > RIP: 0033:0x442a58
> > > Code: 00 00 be 3c 00 00 00 eb 19 66 0f 1f 84 00 00 00 00 00 48 89 d7 89 f0
> > > 0f 05 48 3d 00 f0 ff ff 77 21 f4 48 89 d7 44 89 c0 0f 05 <48> 3d 00 f0 ff
> > > ff 76 e0 f7 d8 64 41 89 01 eb d8 0f 1f 84 00 00 00
> > > RSP: 002b:00007ffe99e2faf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> > > RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000442a58
> > > RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
> > > RBP: 00000000004c2468 R08: 00000000000000e7 R09: ffffffffffffffd0
> > > R10: 0000000002000005 R11: 0000000000000246 R12: 0000000000000001
> > > R13: 00000000006d4180 R14: 0000000000000000 R15: 0000000000000000
> > >
> > >
> > > ---
> > > This bug is generated by a bot. It may contain errors.
> > > See https://goo.gl/tpsmEJ for more information about syzbot.
> > > syzbot engineers can be reached at syzkaller@googlegroups.com.
> > >
> > > syzbot will keep track of this bug report. See:
> > > https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> > > syzbot.
> > > syzbot can test patches for this bug, for details see:
> > > https://goo.gl/tpsmEJ#testing-patches
> > >
> > > --
> > > You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> > > To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> > > To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/00000000000024b3aa0582f1cde7%40google.com.
> > > For more options, visit https://groups.google.com/d/optout.
> >
> > --
> > You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> > To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> > To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/CACT4Y%2BbyrcaasUaEJj%3DhcemEEBBkon%3DVC24gPwGXHzfeRP0E3w%40mail.gmail.com.
> > For more options, visit https://groups.google.com/d/optout.
>
> It bisects down to the same patch ("block: implement bio helper to add iter bvec
> pages to bio") so apparently it's just still broken despite Jens' fix.
>
> BTW, as this is trivially bisectable with the reproducer, I still don't see why
> syzbot can't do the bisection itself and use get_maintainer.pl on the broken
> patch to actually send the report to the right person:
>
> $ ./scripts/get_maintainer.pl 0001-block-implement-bio-helper-to-add-iter-bvec-pages-to.patch
> Jens Axboe <axboe@kernel.dk> (maintainer:BLOCK LAYER)
> linux-block@vger.kernel.org (open list:BLOCK LAYER)
> linux-kernel@vger.kernel.org (open list)
>
> Spamming unrelated lists and maintainers not only prevents the bug from being
> fixed, but it also reduces the average usefulness of syzbot reports which
> teaches people to ignore them.


It can. It's just lots of work to code generic logic that can reliably
handle all possible cases in fully automated fashion, build production
pipeline that will schedule and execute all of this, built in
necessary introspection, design persistent data formats, etc.

