Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9ABF3C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 02:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 420F220656
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 02:17:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="awrtA7A/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 420F220656
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D63D68E0003; Thu, 27 Jun 2019 22:17:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D141C8E0002; Thu, 27 Jun 2019 22:17:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB5328E0003; Thu, 27 Jun 2019 22:17:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 957608E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 22:17:54 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id j144so5895229ywa.15
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 19:17:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ibD3B/EuuR/59/QG00Y+ZaZmcuQXpKuzxrjxPyCsSA4=;
        b=UYkUlfXu/ni4qDsiNf3h/rJOZfjHhCh96g9yxKsxmK98Zu8hx7idTLotFQ+I5kOBja
         4adRxVSjlAPKPjKCpikW8kqJ+TCzTXUhzGDF0HULjvGp4Yz8S/4M6UWj5Z/jY7GUOOKi
         t/Yox1H7R2PllvBa8Tg4tShX588c282V9PQM5Ec2s4KD7JnlI86Zk0aBVqUhSc0jiE47
         0qTkRu/guiCrMUgLJtDy6VykAhlOivvcMc3af3oLjxoVF1c5KHPE7a6azJmokMJb7gV7
         aSBvwoRdqBDSgRmhzb9EuEa95dB6oE+VcdkWlhAAxS32UsIfaXHn/lPiGGLqUgpuyq4J
         o0IA==
X-Gm-Message-State: APjAAAW1fYstWZsaK6vlnIwf3OP3bB/F6CUMKrmcQ2DlTnYDkCRf8emJ
	KcYB6u7Vd+GEHGMqvVzG5gUtxMVl8Sfl9Nwb/fsB2U5pZM7QC0ljZAwggVhfl0pZwPtBKhMYZCf
	HxGPcSn7H97InSlkakT6g6HThqhbiUSw1g/phRVNuk8bmu/7mecT6JDhOBOEm4VciIg==
X-Received: by 2002:a25:df55:: with SMTP id w82mr84767ybg.116.1561688274343;
        Thu, 27 Jun 2019 19:17:54 -0700 (PDT)
X-Received: by 2002:a25:df55:: with SMTP id w82mr84751ybg.116.1561688273650;
        Thu, 27 Jun 2019 19:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561688273; cv=none;
        d=google.com; s=arc-20160816;
        b=jNwlLaK7EMAL43xTb/0e+6/idyYNRcJXJM+Ae1qIKZ/GgY5lhyc0o6YWnB1QzfCg8o
         7LTe7Z1Y8tqSELcx8oIMCKtGIUMdCb64OkzZeKcqhYtFkrEG7LSG2wtgw8ZCW2kBZalF
         6Bd8FhOY+/Ix0xcwRSvjXI5OwIo27uJ7sRFnlFL5BgYJb4Cjz7YFMgorCme+ZKy6A/eG
         pOWGhe130t8qe3lOCBoGNnNDTDVpAWqiaOWNDBkcOKvRL5bChvWZL2d2KMLfCi9OQbA0
         kfyaRNIDGz6cAMKMB49gaYFe1T5gc+XCn1bm+0g4pVsaM/4Wp8djjpUadzgLdE5tFjCA
         gG4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ibD3B/EuuR/59/QG00Y+ZaZmcuQXpKuzxrjxPyCsSA4=;
        b=jVTF1jhYH7rYn78si9T6K+ugAiMoz2E5bzWidg3tQSJetvevOtAmapTTzse0uxPLDw
         Umv+NWbMxIjyaYd4YPaIFFzOhJ67eol090pVG9hma1u617SkWxlyeJql0zgYl+CK80BK
         gYy8BS0R3uoNkmbNXOsOfDkTJYXGWhRrqRttA1pQN8GrZA5uXNcKDVX9yIajT0AmMuRc
         sakV6Fjw5UVwD8Q7ZSkmfQC59lGXetkxT+Uq3vfeM+feZUrvSL3p0exmEDC7mZzmRemr
         RKOXGElLCge51lJydA5BjJc3Xt9WrmbAZLuv8CrmY8BiqrpzHdkrkRfjfDqXQK9m89AY
         QDDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="awrtA7A/";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor347832ybh.209.2019.06.27.19.17.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 19:17:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="awrtA7A/";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ibD3B/EuuR/59/QG00Y+ZaZmcuQXpKuzxrjxPyCsSA4=;
        b=awrtA7A/YuN+zmQJPqbtUleuKyvjg6A0tJpSNBjNRmZq4OuPxqGWedPeRnBQn4Utjv
         nk98MtbTNb478DEXPChwnOaCU3YTLFfxWO/BuQLukMKu4GgUu90ngQQPYBU9AGCJrvuP
         GdX4Ys2a8CFdKSDbXq2bOOTnop7hM0QRlNG0rr9gz2H7/LF1IwkKrT9u0nTEZ2/Y3x9W
         wFT5azmUDUR4xceH98veZ+nvA+BuwZU+SKdhRwz4hLTy6GFjTjtWj27c9AnXaIqSb1cy
         Pdze7nRpyNKRz9jPRdOak1n0Wb6BA/Ecxp9JSRnl0ODl+kZDzc+46LavxfjoevfNLJ4o
         NJnQ==
X-Google-Smtp-Source: APXvYqwF1lSv64rIEIapmHrZ6IHwmSEzU8bnvHcvSHkQLK5z0KHWArfvRZvZYwhEP9Zv+BKQmxlncbYgeftk+2J0lwI=
X-Received: by 2002:a25:7c05:: with SMTP id x5mr4806862ybc.358.1561688272976;
 Thu, 27 Jun 2019 19:17:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190624212631.87212-1-shakeelb@google.com> <20190624212631.87212-3-shakeelb@google.com>
 <20190626065118.GJ17798@dhcp22.suse.cz>
In-Reply-To: <20190626065118.GJ17798@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 27 Jun 2019 19:17:41 -0700
Message-ID: <CALvZod7-g1mcxZTdcXnU_ApCZt6pNKFFy7MpY0aXUcO7bJp=SA@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] oom: decouple mems_allowed from oom_unkillable_task
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Paul Jackson <pj@sgi.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 11:55 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 24-06-19 14:26:31, Shakeel Butt wrote:
> > The commit ef08e3b4981a ("[PATCH] cpusets: confine oom_killer to
> > mem_exclusive cpuset") introduces a heuristic where a potential
> > oom-killer victim is skipped if the intersection of the potential victim
> > and the current (the process triggered the oom) is empty based on the
> > reason that killing such victim most probably will not help the current
> > allocating process. However the commit 7887a3da753e ("[PATCH] oom:
> > cpuset hint") changed the heuristic to just decrease the oom_badness
> > scores of such potential victim based on the reason that the cpuset of
> > such processes might have changed and previously they might have
> > allocated memory on mems where the current allocating process can
> > allocate from.
> >
> > Unintentionally commit 7887a3da753e ("[PATCH] oom: cpuset hint")
> > introduced a side effect as the oom_badness is also exposed to the
> > user space through /proc/[pid]/oom_score, so, readers with different
> > cpusets can read different oom_score of th same process.
> >
> > Later the commit 6cf86ac6f36b ("oom: filter tasks not sharing the same
> > cpuset") fixed the side effect introduced by 7887a3da753e by moving the
> > cpuset intersection back to only oom-killer context and out of
> > oom_badness. However the combination of the commit ab290adbaf8f ("oom:
> > make oom_unkillable_task() helper function") and commit 26ebc984913b
> > ("oom: /proc/<pid>/oom_score treat kernel thread honestly")
> > unintentionally brought back the cpuset intersection check into the
> > oom_badness calculation function.
>
> Thanks for this excursion into the history. I think it is very useful.
>
> > Other than doing cpuset/mempolicy intersection from oom_badness, the
> > memcg oom context is also doing cpuset/mempolicy intersection which is
> > quite wrong and is caught by syzcaller with the following report:
> >
> > kasan: CONFIG_KASAN_INLINE enabled
> > kasan: GPF could be caused by NULL-ptr deref or user memory access
> > general protection fault: 0000 [#1] PREEMPT SMP KASAN
> > CPU: 0 PID: 28426 Comm: syz-executor.5 Not tainted 5.2.0-rc3-next-20190607
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > Google 01/01/2011
> > RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> > RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
> > RIP: 0010:oom_unkillable_task mm/oom_kill.c:168 [inline]
> > RIP: 0010:oom_unkillable_task+0x180/0x400 mm/oom_kill.c:155
> > Code: c1 ea 03 80 3c 02 00 0f 85 80 02 00 00 4c 8b a3 10 07 00 00 48 b8 00
> > 00 00 00 00 fc ff df 4d 8d 74 24 10 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f
> > 85 67 02 00 00 49 8b 44 24 10 4c 8d a0 68 fa ff ff
> > RSP: 0018:ffff888000127490 EFLAGS: 00010a03
> > RAX: dffffc0000000000 RBX: ffff8880a4cd5438 RCX: ffffffff818dae9c
> > RDX: 100000000c3cc602 RSI: ffffffff818dac8d RDI: 0000000000000001
> > RBP: ffff8880001274d0 R08: ffff888000086180 R09: ffffed1015d26be0
> > R10: ffffed1015d26bdf R11: ffff8880ae935efb R12: 8000000061e63007
> > R13: 0000000000000000 R14: 8000000061e63017 R15: 1ffff11000024ea6
> > FS:  00005555561f5940(0000) GS:ffff8880ae800000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000000000607304 CR3: 000000009237e000 CR4: 00000000001426f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> > Call Trace:
> >   oom_evaluate_task+0x49/0x520 mm/oom_kill.c:321
> >   mem_cgroup_scan_tasks+0xcc/0x180 mm/memcontrol.c:1169
> >   select_bad_process mm/oom_kill.c:374 [inline]
> >   out_of_memory mm/oom_kill.c:1088 [inline]
> >   out_of_memory+0x6b2/0x1280 mm/oom_kill.c:1035
> >   mem_cgroup_out_of_memory+0x1ca/0x230 mm/memcontrol.c:1573
> >   mem_cgroup_oom mm/memcontrol.c:1905 [inline]
> >   try_charge+0xfbe/0x1480 mm/memcontrol.c:2468
> >   mem_cgroup_try_charge+0x24d/0x5e0 mm/memcontrol.c:6073
> >   mem_cgroup_try_charge_delay+0x1f/0xa0 mm/memcontrol.c:6088
> >   do_huge_pmd_wp_page_fallback+0x24f/0x1680 mm/huge_memory.c:1201
> >   do_huge_pmd_wp_page+0x7fc/0x2160 mm/huge_memory.c:1359
> >   wp_huge_pmd mm/memory.c:3793 [inline]
> >   __handle_mm_fault+0x164c/0x3eb0 mm/memory.c:4006
> >   handle_mm_fault+0x3b7/0xa90 mm/memory.c:4053
> >   do_user_addr_fault arch/x86/mm/fault.c:1455 [inline]
> >   __do_page_fault+0x5ef/0xda0 arch/x86/mm/fault.c:1521
> >   do_page_fault+0x71/0x57d arch/x86/mm/fault.c:1552
> >   page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1156
> > RIP: 0033:0x400590
> > Code: 06 e9 49 01 00 00 48 8b 44 24 10 48 0b 44 24 28 75 1f 48 8b 14 24 48
> > 8b 7c 24 20 be 04 00 00 00 e8 f5 56 00 00 48 8b 74 24 08 <89> 06 e9 1e 01
> > 00 00 48 8b 44 24 08 48 8b 14 24 be 04 00 00 00 8b
> > RSP: 002b:00007fff7bc49780 EFLAGS: 00010206
> > RAX: 0000000000000001 RBX: 0000000000760000 RCX: 0000000000000000
> > RDX: 0000000000000000 RSI: 000000002000cffc RDI: 0000000000000001
> > RBP: fffffffffffffffe R08: 0000000000000000 R09: 0000000000000000
> > R10: 0000000000000075 R11: 0000000000000246 R12: 0000000000760008
> > R13: 00000000004c55f2 R14: 0000000000000000 R15: 00007fff7bc499b0
> > Modules linked in:
> > ---[ end trace a65689219582ffff ]---
> > RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> > RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
> > RIP: 0010:oom_unkillable_task mm/oom_kill.c:168 [inline]
> > RIP: 0010:oom_unkillable_task+0x180/0x400 mm/oom_kill.c:155
> > Code: c1 ea 03 80 3c 02 00 0f 85 80 02 00 00 4c 8b a3 10 07 00 00 48 b8 00
> > 00 00 00 00 fc ff df 4d 8d 74 24 10 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f
> > 85 67 02 00 00 49 8b 44 24 10 4c 8d a0 68 fa ff ff
> > RSP: 0018:ffff888000127490 EFLAGS: 00010a03
> > RAX: dffffc0000000000 RBX: ffff8880a4cd5438 RCX: ffffffff818dae9c
> > RDX: 100000000c3cc602 RSI: ffffffff818dac8d RDI: 0000000000000001
> > RBP: ffff8880001274d0 R08: ffff888000086180 R09: ffffed1015d26be0
> > R10: ffffed1015d26bdf R11: ffff8880ae935efb R12: 8000000061e63007
> > R13: 0000000000000000 R14: 8000000061e63017 R15: 1ffff11000024ea6
> > FS:  00005555561f5940(0000) GS:ffff8880ae800000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000001b2f823000 CR3: 000000009237e000 CR4: 00000000001426f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> >
> > The fix is to decouple the cpuset/mempolicy intersection check from
> > oom_unkillable_task() and make sure cpuset/mempolicy intersection check
> > is only done in the global oom context.
>
> Thanks for the changelog update. This looks really great to me.
>
> > Reported-by: syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
>
> I think that VM_BUG_ON in has_intersects_mems_allowed is over protective
> and it makes the rest of the code a bit more convoluted than necessary.
> Is there any reason we just do the check and return true there? Btw.
> has_intersects_mems_allowed sounds like a misnomer to me. It suggests
> to be a more generic function while it has some memcg implications which
> are not trivial to spot without digging deeper. I would go with
> oom_cpuset_eligible or something along those lines.
>

I will change the name to "oom_cpuset_eligible".

> Anyway
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

