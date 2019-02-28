Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 211E3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 17:54:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C825820C01
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 17:54:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="D6ouqv1G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C825820C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FDF18E0003; Thu, 28 Feb 2019 12:54:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4ADCB8E0001; Thu, 28 Feb 2019 12:54:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C3C18E0003; Thu, 28 Feb 2019 12:54:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13F118E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 12:54:13 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id e1so16018387iod.23
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 09:54:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4GsBb/zGrVdUQYJA1B0OjvALHOlIwmY2YbdIpuIpRiU=;
        b=DHY8IGYFztu9d+YXKB09l96NgRqvZzkLIPQX0mKuazUW7zEQs4dXQwVuXuX/2D8pxy
         avvLPxLHuLm2nR3WtOCvQU2b+D3BBAqnZ8I6BALr2FCseah6l2q/buXeY/Zq13//vIPe
         cwvXokgY4UKJUECWqmfLpHPOBDTB+7ii8kA7qTW/y6ds5u0pYD+ozNPcVP1qY2obiC95
         zpLuyHOdQQQQA6dVHIOev1cHasWVscGPUH6k+DsQwS/9uh6TJeKzZi7jGDsaf7I7aitP
         Ch1dGBRds/91atZ+kJ5U0AQP/yFLHgc64BxY5y79ADQ28ZeKcDgEWzAYdw5OWZ5tfdsr
         SB7A==
X-Gm-Message-State: APjAAAVEZY6ERZ00xGJtmtHYonblZ2NP32bWxpVS+U1gClijuErDnFDF
	jw7yz/lQTidoykQka0jWopQ1JRE0gIYoCchp4AMC6FNKE5bFFNoIYZL3PFL1LkIJGUEMTlugnwt
	PxDvpEi6NjfPBi7lJlll0eMTOVF7Xu6Ud/XCmNzx1lnhMgDXZRxH1yTOjjcn0N4nKTPdPmbWYzk
	eyw7XHrBgYJmYNEuMwsuCcyVvwKM4C3dvnaePXr3tnFy1hLAgE+Tw8cYDmHsWOkJ/ig0ZSv4mnE
	BN/TpRi2+fdPtV3XjolShlI42E2Blzs7Fv5CJNv0MIs9pBSr9MeofLY1iIBz2PVj3D+BYVvOycN
	nHclPexhxkh6nBOP/2TIUYAD93naB02LmRDFHOYMhe+KgxQEBtmIdWwlWDYg8W7nOxN0TMMcXAf
	B
X-Received: by 2002:a02:4904:: with SMTP id z4mr168862jaa.46.1551376452833;
        Thu, 28 Feb 2019 09:54:12 -0800 (PST)
X-Received: by 2002:a02:4904:: with SMTP id z4mr168821jaa.46.1551376451844;
        Thu, 28 Feb 2019 09:54:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551376451; cv=none;
        d=google.com; s=arc-20160816;
        b=RuW1Iim7ByXMK0CbJYwA/D64PNhE7oqQAVXBGAGsu0A0mdKLTikTtlEXABUOwdg6H7
         uZRRwAEE3q6vAlriMUcNcSrN9MyCMCjS6LkBnRN0CePDjlSQcD+3xDc0OT00ScNyRvAH
         6CvN1oSzbip0/7hBKS8A/hZgZX63k6Sw+4dZqKuMhKpGqmqa3diExTk+tO77xShpdgcx
         o+D7yyWEtv+FqxepBE+4y9/hPUfn99H6+lNPg/74SGVqoQ/4m7pXZlB0uOkSNZ9VSex7
         G2aZU4OqxmgSxua3+SVwPpnZKbCjEmHGWfVM65MqKC3GynsJbUrMdxsz37ejhyTkdwyn
         mBOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4GsBb/zGrVdUQYJA1B0OjvALHOlIwmY2YbdIpuIpRiU=;
        b=VYapA2RKDzGnDS6GyagrYaZG/C04A+4tCXWJz2xgXdYQYZ2WGAv8/PpVyM7Xrqhm8N
         cgCXkvJSrDb6pW3GYk8Z/Ym27YnB7jWMusovudVRyUm3Y62Kd31BZKl/Yim3eM7u0RTT
         kBML/GeI3yvJcxy1oPAgPSOEozxBXJSauPJb6So6UcZYsMgqDBEm+zF1Alsjx0k84Z/M
         75A782mYmzJYLjDhb8As4Mxx+A3cuF4oBjtYWepkQs1rXU1iggcKPyjAZExEcZ+RXlGS
         EvVMbWoTM+HRNc00O4xybfuz1Rgx+KtWX8YuqKnbD4g56WTPT0DPTmVCtnIxX8iZa3NM
         yJ0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=D6ouqv1G;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8sor10615395iob.146.2019.02.28.09.54.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 09:54:11 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=D6ouqv1G;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4GsBb/zGrVdUQYJA1B0OjvALHOlIwmY2YbdIpuIpRiU=;
        b=D6ouqv1GCQsfSsG3biNBcMQ7ane/lKi6C6o0VwbtOpvPIhNngjN9myBHxv7FWIqXVo
         JRnSvdUkXYAYVROMYjKCZZwFQShRu/1f2KHqJzGE5CG8fVVJDSNAVpitw2/rRoyP1f9Y
         LA8/N1FPirOh+jBo292MkTf6u/yKfDmQ0qLTH0LnUODW8S8g574DBqGAInXX7meU+P9K
         +snfDX5d4Mzb6vcvCM2iVGmClfkVCS9C7Qj+UalE4FjmXxNH2gyY1mL0QV1wLd481uYf
         GegXGB0j99URq5LUD66eqViR3rAGX4nfUZwsT9Ai8j4VwFzag/3lwppMjrIJP6MTwUkJ
         2wtw==
X-Google-Smtp-Source: APXvYqwfQDKQhT2WygWw1UsU1oBWFsJfl7kUl9TOPwtRqXS6iGdhFS4roNyy20LEPjW9t7s2rT/tIMbxOCimO+bADbY=
X-Received: by 2002:a6b:6b18:: with SMTP id g24mr300903ioc.282.1551376451272;
 Thu, 28 Feb 2019 09:54:11 -0800 (PST)
MIME-Version: 1.0
References: <00000000000024b3aa0582f1cde7@google.com> <CACT4Y+byrcaasUaEJj=hcemEEBBkon=VC24gPwGXHzfeRP0E3w@mail.gmail.com>
 <20190228174250.GB663@sol.localdomain> <54e34bcb-7de7-4488-cead-3ea3a2b71ed7@kernel.dk>
In-Reply-To: <54e34bcb-7de7-4488-cead-3ea3a2b71ed7@kernel.dk>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 28 Feb 2019 18:53:58 +0100
Message-ID: <CACT4Y+Zy4uY+guS3ZBZAtg-ES5-351mKSOfKxpZySafur+XvCw@mail.gmail.com>
Subject: Re: BUG: Bad page state (6)
To: Jens Axboe <axboe@kernel.dk>
Cc: Eric Biggers <ebiggers@kernel.org>, 
	syzbot <syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, arunks@codeaurora.org, 
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

On Thu, Feb 28, 2019 at 6:51 PM Jens Axboe <axboe@kernel.dk> wrote:
>
> On 2/28/19 10:42 AM, Eric Biggers wrote:
> > On Thu, Feb 28, 2019 at 11:36:21AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> >> On Thu, Feb 28, 2019 at 11:32 AM syzbot
> >> <syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com> wrote:
> >>>
> >>> Hello,
> >>>
> >>> syzbot found the following crash on:
> >>>
> >>> HEAD commit:    42fd8df9d1d9 Add linux-next specific files for 20190228
> >>> git tree:       linux-next
> >>> console output: https://syzkaller.appspot.com/x/log.txt?x=179ba9e0c00000
> >>> kernel config:  https://syzkaller.appspot.com/x/.config?x=c0f38652d28b522f
> >>> dashboard link: https://syzkaller.appspot.com/bug?extid=6f5a9b79b75b66078bf0
> >>> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> >>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12ed6bd0c00000
> >>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10690c8ac00000
> >>>
> >>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> >>> Reported-by: syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com
> >>
> >> +Jens, Eric,
> >>
> >> Looks similar to:
> >> https://groups.google.com/forum/#!msg/syzkaller-bugs/E3v3XQweVBw/6BPrkIYJIgAJ
> >> Perhaps the fixing commit is not in the build yet?
> >>
> >>
> >>> BUG: Bad page state in process syz-executor193  pfn:9225a
> >>> page:ffffea0002489680 count:0 mapcount:0 mapping:ffff88808652fd80 index:0x81
> >>> shmem_aops
> >>> name:"memfd:cgroup2"
> >>> flags: 0x1fffc000008000e(referenced|uptodate|dirty|swapbacked)
> >>> raw: 01fffc000008000e ffff88809277fac0 ffff88809277fac0 ffff88808652fd80
> >>> raw: 0000000000000081 0000000000000000 00000000ffffffff 0000000000000000
> >>> page dumped because: non-NULL mapping
> >>> Modules linked in:
> >>> CPU: 0 PID: 7659 Comm: syz-executor193 Not tainted 5.0.0-rc8-next-20190228
> >>> #45
> >>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> >>> Google 01/01/2011
> >>> Call Trace:
> >>>   __dump_stack lib/dump_stack.c:77 [inline]
> >>>   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> >>>   bad_page.cold+0xda/0xff mm/page_alloc.c:586
> >>>   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1013
> >>>   free_pages_check mm/page_alloc.c:1022 [inline]
> >>>   free_pages_prepare mm/page_alloc.c:1112 [inline]
> >>>   free_pcp_prepare mm/page_alloc.c:1137 [inline]
> >>>   free_unref_page_prepare mm/page_alloc.c:3001 [inline]
> >>>   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3070
> >>>   release_pages+0x60d/0x1940 mm/swap.c:794
> >>>   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
> >>>   activate_page_drain mm/swap.c:297 [inline]
> >>>   lru_add_drain_cpu+0x3b1/0x520 mm/swap.c:596
> >>>   lru_add_drain+0x20/0x60 mm/swap.c:647
> >>>   exit_mmap+0x290/0x530 mm/mmap.c:3134
> >>>   __mmput kernel/fork.c:1047 [inline]
> >>>   mmput+0x15f/0x4c0 kernel/fork.c:1068
> >>>   exit_mm kernel/exit.c:546 [inline]
> >>>   do_exit+0x816/0x2fa0 kernel/exit.c:863
> >>>   do_group_exit+0x135/0x370 kernel/exit.c:980
> >>>   __do_sys_exit_group kernel/exit.c:991 [inline]
> >>>   __se_sys_exit_group kernel/exit.c:989 [inline]
> >>>   __x64_sys_exit_group+0x44/0x50 kernel/exit.c:989
> >>>   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
> >>>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >>> RIP: 0033:0x442a58
> >>> Code: 00 00 be 3c 00 00 00 eb 19 66 0f 1f 84 00 00 00 00 00 48 89 d7 89 f0
> >>> 0f 05 48 3d 00 f0 ff ff 77 21 f4 48 89 d7 44 89 c0 0f 05 <48> 3d 00 f0 ff
> >>> ff 76 e0 f7 d8 64 41 89 01 eb d8 0f 1f 84 00 00 00
> >>> RSP: 002b:00007ffe99e2faf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> >>> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000442a58
> >>> RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
> >>> RBP: 00000000004c2468 R08: 00000000000000e7 R09: ffffffffffffffd0
> >>> R10: 0000000002000005 R11: 0000000000000246 R12: 0000000000000001
> >>> R13: 00000000006d4180 R14: 0000000000000000 R15: 0000000000000000
> >>>
> >>>
> >>> ---
> >>> This bug is generated by a bot. It may contain errors.
> >>> See https://goo.gl/tpsmEJ for more information about syzbot.
> >>> syzbot engineers can be reached at syzkaller@googlegroups.com.
> >>>
> >>> syzbot will keep track of this bug report. See:
> >>> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> >>> syzbot.
> >>> syzbot can test patches for this bug, for details see:
> >>> https://goo.gl/tpsmEJ#testing-patches
> >>>
> >>> --
> >>> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> >>> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> >>> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/00000000000024b3aa0582f1cde7%40google.com.
> >>> For more options, visit https://groups.google.com/d/optout.
> >>
> >> --
> >> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> >> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> >> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/CACT4Y%2BbyrcaasUaEJj%3DhcemEEBBkon%3DVC24gPwGXHzfeRP0E3w%40mail.gmail.com.
> >> For more options, visit https://groups.google.com/d/optout.
> >
> > It bisects down to the same patch ("block: implement bio helper to add iter bvec
> > pages to bio") so apparently it's just still broken despite Jens' fix.
> >
> > BTW, as this is trivially bisectable with the reproducer, I still don't see why
> > syzbot can't do the bisection itself and use get_maintainer.pl on the broken
> > patch to actually send the report to the right person:
> >
> > $ ./scripts/get_maintainer.pl 0001-block-implement-bio-helper-to-add-iter-bvec-pages-to.patch
> > Jens Axboe <axboe@kernel.dk> (maintainer:BLOCK LAYER)
> > linux-block@vger.kernel.org (open list:BLOCK LAYER)
> > linux-kernel@vger.kernel.org (open list)
> >
> > Spamming unrelated lists and maintainers not only prevents the bug from being
> > fixed, but it also reduces the average usefulness of syzbot reports which
> > teaches people to ignore them.
>
> Huh, weird. Where's the reproducer for this one?

Under the "C reproducer" link.

