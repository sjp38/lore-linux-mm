Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16ABCC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:36:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C73F62171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:36:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="o1SZRd5s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C73F62171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 584F88E0003; Thu, 28 Feb 2019 05:36:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5335C8E0001; Thu, 28 Feb 2019 05:36:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44C098E0003; Thu, 28 Feb 2019 05:36:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4288E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:36:34 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id q141so7910980itc.2
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:36:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TG2Sh1vGe2zW5taB3axe7bGfGTyXgNIoMQVtjw+a9WY=;
        b=GxtV4IVzNbwwEF3AXX8FkfeBufPfUxIvsv64smF07bKTQQobIOmLyIswhHyU1ufoM+
         BJwP/xvWVbmtdLMEeq7tq1hVl2gRdSLo4Qmd+coMF8eGR8AIomceKKpOEkVA8Kt6ctI7
         LAoSX+USlyGohT7ttlW7XVR8rHaLaMEkg1zW2bPhxsxKa/BBKU9aavwLQx5ZMYoqY3dP
         GQ5e9P10HU+JjOCyRtLH2AykyUIDulKXqSVznlA2CW2ORkClKTs3YdxveChAgT9fmAOX
         619n4+gEoQPWpCQen+WZsFn98rhQrmbN4ciPeh3fzSZJY7RXFLj/a1WmCwqhQqgtiNHy
         17CQ==
X-Gm-Message-State: AHQUAua3lF9QMQUFnzckf20Qy3VyC5MCM+3Qsz54ElCY5CMwBxw3FNtL
	OvY870lgSVG/i+xPrdFhkZdLhoXa6Ii4VosdRdONW52sv7yJE0aKy0UAOZGZGTdnKZxEz24c7Gk
	gXhN7asVYvrzWmtTp3+J3fayeN+azudcLXlFXPEOEnKSrkwuqO7pA4gRyQfBvdvLaDugcYE5AOn
	r50zKg5Wzy4lLFBzgOw7H1oJy2LEWLKKnGGJI5R+vbabg0Zd03z2F/+B7l8oBRTWtiVw07gt4gJ
	KcOyZdsT6k2NwJfS0QmKGhagDb9Z/69MKXvmF6kJ84tK8uKsbxnlsAo0uvfp2xcxjFjR1H0cWSi
	ApWRzdVjVxx8xXKl8dR3F8A5GU1Gc9zES8V8xOVENgua3jrE2BWPKjnNnKlU7Gg0cuxX1rEO8Al
	G
X-Received: by 2002:a24:41e2:: with SMTP id b95mr2580527itd.115.1551350193884;
        Thu, 28 Feb 2019 02:36:33 -0800 (PST)
X-Received: by 2002:a24:41e2:: with SMTP id b95mr2580490itd.115.1551350193005;
        Thu, 28 Feb 2019 02:36:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551350193; cv=none;
        d=google.com; s=arc-20160816;
        b=n4D3kGivp70C2bkj1IttmoKoSMYspHe/c+VAZNfMIzAGn17yHkeI+cbzHklEeZrWZo
         r9WKMOEBJMm6++TlH14v/ahx2tPFo5Lu2MVe55VV46FAMj56GuduHQQ5VZjaiDjeO6LU
         0XL15hRokPfS10yqujqfU2rUh5pUwhIlhnGbfahrPqsLdU9/95TmG9E4AYQ2Nk/OcjpX
         /zEsKyTnORfPGNTfNDHCGNg9+gCBr0gvMv2JA3h0Oc4Gi2SkFuf39rSRgcNfdajjMIJm
         EyJ0bSyd8IYbwsCgIAXMzQl1QUlIkxkGP/GBO67mpNVqIYSkJRi03FB5fmSgERK6k5a+
         Dfqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TG2Sh1vGe2zW5taB3axe7bGfGTyXgNIoMQVtjw+a9WY=;
        b=WkpWjVAzPlohjtQBUpKduIQY6R5ON90Gyxn55Q/lzqSRmFChGlHSWw2PB2Q0CSxMZd
         nOCbFxkKgCKstjuel3Whvxb6qCtcymuzt2LYJBadQ4fwK2O/pTeAev7f5pQiI6nUvadJ
         Po4tN2Imi8rLK4vVgldCNADjbZ06RLp305fJHTSGMka2LNi8sUSSfJbRc9AiQLyCGYpi
         Kc9CKVPRK5xaYGDfNTRQ5Nx8CSXbanKdWlzljJASYacyahTG/L0ef9oFS7HOcLBY6tUA
         Ll8IsqMH5kjI57dIg+WldzRbk7ptrlGXxqJGBhR1XkRbrJh01y544pbTrowdKqCsRSDW
         txeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=o1SZRd5s;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u21sor3928161iof.44.2019.02.28.02.36.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 02:36:32 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=o1SZRd5s;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TG2Sh1vGe2zW5taB3axe7bGfGTyXgNIoMQVtjw+a9WY=;
        b=o1SZRd5sZ8ky1TT+/5Jt3JkN+1k53KLcPjsze1Lmt8u2VAV9gOe6cLCsUWT/2K4qmM
         MUqj6NvOSkm/LX+4vD0olqSKueBXd6sCHV/WWilxgUPXoruRxYgj5BqbcFtWSRi4kRub
         CYh5Z/qGHS09JmsDSPCk+eH9IEJEu2ayjwr1+s/pRwNxIJndRvfjwCCuVbxvBsWLHkfk
         /x9gwBzJdQxO9R1S5dv5BL8cz056A13vI0vFtNAofSxZDoc2MTTivBw7W98C9YXjWanf
         ud91l2aE0QBSHwKM6B5My497y57XUBCOoEWEyR4dDfBigPVFBu732pJPg2goN6ihiKcy
         pCWA==
X-Google-Smtp-Source: APXvYqyCef3EvphHHF9vAB7qSxnCUEYiQjXURkJ14X72OX5R2/TA3iQPQfPmXT9wQONnsVjUMNv0KPfur/S61vXwYiQ=
X-Received: by 2002:a5d:84c3:: with SMTP id z3mr4811563ior.11.1551350192504;
 Thu, 28 Feb 2019 02:36:32 -0800 (PST)
MIME-Version: 1.0
References: <00000000000024b3aa0582f1cde7@google.com>
In-Reply-To: <00000000000024b3aa0582f1cde7@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 28 Feb 2019 11:36:21 +0100
Message-ID: <CACT4Y+byrcaasUaEJj=hcemEEBBkon=VC24gPwGXHzfeRP0E3w@mail.gmail.com>
Subject: Re: BUG: Bad page state (6)
To: syzbot <syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com>, 
	Jens Axboe <axboe@kernel.dk>, Eric Biggers <ebiggers@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, arunks@codeaurora.org, 
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

On Thu, Feb 28, 2019 at 11:32 AM syzbot
<syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    42fd8df9d1d9 Add linux-next specific files for 20190228
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=179ba9e0c00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=c0f38652d28b522f
> dashboard link: https://syzkaller.appspot.com/bug?extid=6f5a9b79b75b66078bf0
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12ed6bd0c00000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10690c8ac00000
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com

+Jens, Eric,

Looks similar to:
https://groups.google.com/forum/#!msg/syzkaller-bugs/E3v3XQweVBw/6BPrkIYJIgAJ
Perhaps the fixing commit is not in the build yet?


> BUG: Bad page state in process syz-executor193  pfn:9225a
> page:ffffea0002489680 count:0 mapcount:0 mapping:ffff88808652fd80 index:0x81
> shmem_aops
> name:"memfd:cgroup2"
> flags: 0x1fffc000008000e(referenced|uptodate|dirty|swapbacked)
> raw: 01fffc000008000e ffff88809277fac0 ffff88809277fac0 ffff88808652fd80
> raw: 0000000000000081 0000000000000000 00000000ffffffff 0000000000000000
> page dumped because: non-NULL mapping
> Modules linked in:
> CPU: 0 PID: 7659 Comm: syz-executor193 Not tainted 5.0.0-rc8-next-20190228
> #45
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
>   bad_page.cold+0xda/0xff mm/page_alloc.c:586
>   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1013
>   free_pages_check mm/page_alloc.c:1022 [inline]
>   free_pages_prepare mm/page_alloc.c:1112 [inline]
>   free_pcp_prepare mm/page_alloc.c:1137 [inline]
>   free_unref_page_prepare mm/page_alloc.c:3001 [inline]
>   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3070
>   release_pages+0x60d/0x1940 mm/swap.c:794
>   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
>   activate_page_drain mm/swap.c:297 [inline]
>   lru_add_drain_cpu+0x3b1/0x520 mm/swap.c:596
>   lru_add_drain+0x20/0x60 mm/swap.c:647
>   exit_mmap+0x290/0x530 mm/mmap.c:3134
>   __mmput kernel/fork.c:1047 [inline]
>   mmput+0x15f/0x4c0 kernel/fork.c:1068
>   exit_mm kernel/exit.c:546 [inline]
>   do_exit+0x816/0x2fa0 kernel/exit.c:863
>   do_group_exit+0x135/0x370 kernel/exit.c:980
>   __do_sys_exit_group kernel/exit.c:991 [inline]
>   __se_sys_exit_group kernel/exit.c:989 [inline]
>   __x64_sys_exit_group+0x44/0x50 kernel/exit.c:989
>   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x442a58
> Code: 00 00 be 3c 00 00 00 eb 19 66 0f 1f 84 00 00 00 00 00 48 89 d7 89 f0
> 0f 05 48 3d 00 f0 ff ff 77 21 f4 48 89 d7 44 89 c0 0f 05 <48> 3d 00 f0 ff
> ff 76 e0 f7 d8 64 41 89 01 eb d8 0f 1f 84 00 00 00
> RSP: 002b:00007ffe99e2faf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000442a58
> RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
> RBP: 00000000004c2468 R08: 00000000000000e7 R09: ffffffffffffffd0
> R10: 0000000002000005 R11: 0000000000000246 R12: 0000000000000001
> R13: 00000000006d4180 R14: 0000000000000000 R15: 0000000000000000
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> syzbot.
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/00000000000024b3aa0582f1cde7%40google.com.
> For more options, visit https://groups.google.com/d/optout.

