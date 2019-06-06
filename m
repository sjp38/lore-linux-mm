Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C766EC28D1A
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 07:48:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DD7B207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 07:48:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DD7B207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17B8A6B026D; Thu,  6 Jun 2019 03:48:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 106556B026F; Thu,  6 Jun 2019 03:48:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0EFE6B0270; Thu,  6 Jun 2019 03:48:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82F236B026D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 03:48:06 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id o20so243699lfb.13
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 00:48:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=JK17x2cwVDdx8OCB6Q0BVSiTlnsrZvjaItr9VGRYwhs=;
        b=E+yzUg77W8R837k8yH9ZFXC7NtBNZmxxW02MBhVRmK9geAgYeGjn46ecOtULMq9kON
         ig6cnSVcPG/PqIIsiIL6v2eaIkoH0gpD/A22xZzE/MzEfjSJlokFENRw+ce+dvPXLKuK
         oJ2Jq4kb3l42Ohr7vVszIavNlC4V1vM3RCQ/+z6rrVBaVIILC0I2kGgt6P0gzQSs4JrF
         6KhiS+JH2IGp7vZhbRgSPfn9/yQ2Bs2Qp0SAsmToq+sAL2ztAq2XFQi61JsSY9+KdvSS
         eF4KE0Islkpv1VZWsKQ6DULO/MZsfd4zSWrV0zJI9w2hY88adV4ziTue89Js+fSE9+Ro
         cCbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVGN5CNxa539YxxcR1tRMWQ4ZhskRT4p69Vr2PTcdIEtRrButjw
	czPtZ3O0nvWO2ncOES4NNH+wUOyvG1zW7ivkbBCRPAGubx9dSp4HeRcquchNr/at/P9AGge3f56
	s2r5L7EcupT79MEqdjLWsYkjwXWzH6PAt77zKhNLWwj4OrBMH810fRUK0wyFSnA1ZQA==
X-Received: by 2002:ac2:41d7:: with SMTP id d23mr19613189lfi.118.1559807285744;
        Thu, 06 Jun 2019 00:48:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfmyZzbIlcb/zIg+LxNcdxWOaYvKzNO4AzUmTR9xdsDcCd5lA/iVpHFpWWlNCWnckwohtY
X-Received: by 2002:ac2:41d7:: with SMTP id d23mr19613102lfi.118.1559807283785;
        Thu, 06 Jun 2019 00:48:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559807283; cv=none;
        d=google.com; s=arc-20160816;
        b=fc4JpGtbaCmvXWaoXGYQw6FqQ3hKIj7GSXbn2v8su1IAkcU8Zs6CtdZe9FWiM+5+IX
         Etv5MM1qDVTDaJ/J+4gGcR8hLqGPkDmmMDdAcc1q3VP7ZqIYlET9XS5e2vQoIfFSfh3d
         WtZvkUBK44rp/sG2EFacbz2UqRwJSA4gqswik2ITRgqgHtR2gAZwQbuUvn8wTu0fCGGI
         AsrtOBAN/gJxAeN6LLIRpp4VhcraVpjNzU9hKcA5DqRyDrt5z8Ii0vRVPvGlp87EVAl7
         hU6LYsiG6HPtIWXXaQtx3tdXEG8XKDspNlLNQVqC1KUt5eYcfVwsAPd6yF+vbjf6WunJ
         VB6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=JK17x2cwVDdx8OCB6Q0BVSiTlnsrZvjaItr9VGRYwhs=;
        b=ShTdN3T3KbkQxT2sDLs8W60jhOkHo6Fd/lpIafpbsd02zIjcO3nifplkN2zg+d4V4H
         3PF5248i0AzLf+Gou2ofn42AocL3l1Sxob8av8xZA14sDYrZVy6NJLlkucqwFfK66MYO
         Li189MvNDcr63InZrNC5YFM9thSCFEZzflenoQZ6qlpOcBQaug1OnfVr6kU0I3PDAn8G
         9mdKQYiJZXzwEHlqhZnJSaGRgISdwZqkQNaU6euvFT6dRFdd44jVzD8cw0O/7WYW52yA
         W7TtMpHn03TorTXs2lqYnK41mGEYsXZIKwlEg2veACI9u1iqG4A7MYve2z3XjMfm+5XF
         PG2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id z74si660737ljb.146.2019.06.06.00.48.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 00:48:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hYn7g-0006Xz-Cu; Thu, 06 Jun 2019 10:47:44 +0300
Subject: Re: KASAN: use-after-free Read in unregister_shrinker
To: syzbot <syzbot+83a43746cebef3508b49@syzkaller.appspotmail.com>,
 akpm@linux-foundation.org, bfields@fieldses.org, bfields@redhat.com,
 chris@chrisdown.name, daniel.m.jordan@oracle.com, guro@fb.com,
 hannes@cmpxchg.org, jlayton@kernel.org, laoar.shao@gmail.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org,
 mgorman@techsingularity.net, mhocko@suse.com, sfr@canb.auug.org.au,
 syzkaller-bugs@googlegroups.com, yang.shi@linux.alibaba.com
References: <0000000000005a4b99058a97f42e@google.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <b67a0f5d-c508-48a7-7643-b4251c749985@virtuozzo.com>
Date: Thu, 6 Jun 2019 10:47:43 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <0000000000005a4b99058a97f42e@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05.06.2019 21:42, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    b2924447 Add linux-next specific files for 20190605
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=17e867eea00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=4248d6bc70076f7d
> dashboard link: https://syzkaller.appspot.com/bug?extid=83a43746cebef3508b49
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1122965aa00000
> 
> The bug was bisected to:
> 
> commit db17b61765c2c63b9552d316551550557ff0fcfd
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri May 17 13:03:38 2019 +0000
> 
>     nfsd4: drc containerization
> 
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=110cd22ea00000
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=130cd22ea00000
> console output: https://syzkaller.appspot.com/x/log.txt?x=150cd22ea00000
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+83a43746cebef3508b49@syzkaller.appspotmail.com
> Fixes: db17b61765c2 ("nfsd4: drc containerization")
> 
> ==================================================================
> BUG: KASAN: use-after-free in __list_del_entry_valid+0xe6/0xf5 lib/list_debug.c:51
> Read of size 8 at addr ffff88808a5bd128 by task syz-executor.2/12471
> 
> CPU: 0 PID: 12471 Comm: syz-executor.2 Not tainted 5.2.0-rc3-next-20190605 #9
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:77 [inline]
>  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
>  print_address_description.cold+0xd4/0x306 mm/kasan/report.c:351
>  __kasan_report.cold+0x1b/0x36 mm/kasan/report.c:482
>  kasan_report+0x12/0x20 mm/kasan/common.c:614
>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/generic_report.c:132
>  __list_del_entry_valid+0xe6/0xf5 lib/list_debug.c:51
>  __list_del_entry include/linux/list.h:117 [inline]
>  list_del include/linux/list.h:125 [inline]
>  unregister_shrinker+0xb2/0x2e0 mm/vmscan.c:443
>  nfsd_reply_cache_shutdown+0x26/0x360 fs/nfsd/nfscache.c:194
>  nfsd_exit_net+0x170/0x4b0 fs/nfsd/nfsctl.c:1272
>  ops_exit_list.isra.0+0xaa/0x150 net/core/net_namespace.c:154
>  setup_net+0x400/0x740 net/core/net_namespace.c:333
>  copy_net_ns+0x1df/0x340 net/core/net_namespace.c:439
>  create_new_namespaces+0x400/0x7b0 kernel/nsproxy.c:107
>  unshare_nsproxy_namespaces+0xc2/0x200 kernel/nsproxy.c:206
>  ksys_unshare+0x444/0x980 kernel/fork.c:2718
>  __do_sys_unshare kernel/fork.c:2786 [inline]
>  __se_sys_unshare kernel/fork.c:2784 [inline]
>  __x64_sys_unshare+0x31/0x40 kernel/fork.c:2784
>  do_syscall_64+0xfd/0x680 arch/x86/entry/common.c:301
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x459279
> Code: fd b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 cb b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:00007f7ae73e1c78 EFLAGS: 00000246 ORIG_RAX: 0000000000000110
> RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 0000000000459279
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000040000000
> RBP: 000000000075bfc0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 00007f7ae73e26d4
> R13: 00000000004c84ef R14: 00000000004decb0 R15: 00000000ffffffff
> 
> Allocated by task 12460:
>  save_stack+0x23/0x90 mm/kasan/common.c:71
>  set_track mm/kasan/common.c:79 [inline]
>  __kasan_kmalloc mm/kasan/common.c:489 [inline]
>  __kasan_kmalloc.constprop.0+0xcf/0xe0 mm/kasan/common.c:462
>  kasan_kmalloc+0x9/0x10 mm/kasan/common.c:503
>  __do_kmalloc mm/slab.c:3654 [inline]
>  __kmalloc+0x15c/0x740 mm/slab.c:3663
>  kmalloc include/linux/slab.h:552 [inline]
>  kzalloc include/linux/slab.h:742 [inline]
>  ops_init+0xff/0x410 net/core/net_namespace.c:120
>  setup_net+0x2d3/0x740 net/core/net_namespace.c:316
>  copy_net_ns+0x1df/0x340 net/core/net_namespace.c:439
>  create_new_namespaces+0x400/0x7b0 kernel/nsproxy.c:107
>  unshare_nsproxy_namespaces+0xc2/0x200 kernel/nsproxy.c:206
>  ksys_unshare+0x444/0x980 kernel/fork.c:2718
>  __do_sys_unshare kernel/fork.c:2786 [inline]
>  __se_sys_unshare kernel/fork.c:2784 [inline]
>  __x64_sys_unshare+0x31/0x40 kernel/fork.c:2784
>  do_syscall_64+0xfd/0x680 arch/x86/entry/common.c:301
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> Freed by task 12460:
>  save_stack+0x23/0x90 mm/kasan/common.c:71
>  set_track mm/kasan/common.c:79 [inline]
>  __kasan_slab_free+0x102/0x150 mm/kasan/common.c:451
>  kasan_slab_free+0xe/0x10 mm/kasan/common.c:459
>  __cache_free mm/slab.c:3426 [inline]
>  kfree+0x106/0x2a0 mm/slab.c:3753
>  ops_init+0xd1/0x410 net/core/net_namespace.c:135
>  setup_net+0x2d3/0x740 net/core/net_namespace.c:316
>  copy_net_ns+0x1df/0x340 net/core/net_namespace.c:439
>  create_new_namespaces+0x400/0x7b0 kernel/nsproxy.c:107
>  unshare_nsproxy_namespaces+0xc2/0x200 kernel/nsproxy.c:206
>  ksys_unshare+0x444/0x980 kernel/fork.c:2718
>  __do_sys_unshare kernel/fork.c:2786 [inline]
>  __se_sys_unshare kernel/fork.c:2784 [inline]
>  __x64_sys_unshare+0x31/0x40 kernel/fork.c:2784
>  do_syscall_64+0xfd/0x680 arch/x86/entry/common.c:301
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> The buggy address belongs to the object at ffff88808a5bcdc0
>  which belongs to the cache kmalloc-1k of size 1024
> The buggy address is located 872 bytes inside of
>  1024-byte region [ffff88808a5bcdc0, ffff88808a5bd1c0)
> The buggy address belongs to the page:
> page:ffffea0002296f00 refcount:1 mapcount:0 mapping:ffff8880aa400ac0 index:0x0 compound_mapcount: 0
> flags: 0x1fffc0000010200(slab|head)
> raw: 01fffc0000010200 ffffea000249ea08 ffffea000235a588 ffff8880aa400ac0
> raw: 0000000000000000 ffff88808a5bc040 0000000100000007 0000000000000000
> page dumped because: kasan: bad access detected
> 
> Memory state around the buggy address:
>  ffff88808a5bd000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff88808a5bd080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>> ffff88808a5bd100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>                                   ^
>  ffff88808a5bd180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
>  ffff88808a5bd200: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00
> ==================================================================

This may be connected with that shrinker unregistering is forgotten on error path.

---
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index ea39497205f0..8705e7d09717 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -181,6 +181,7 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
 
 	return 0;
 out_nomem:
+	unregister_shrinker(&nn->nfsd_reply_cache_shrinker);
 	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
 	return -ENOMEM;
 }

