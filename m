Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id CE7446B00A8
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 18:48:00 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i8so4492963qcq.4
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 15:48:00 -0800 (PST)
Received: from mail-qc0-x22e.google.com (mail-qc0-x22e.google.com [2607:f8b0:400d:c01::22e])
        by mx.google.com with ESMTPS id a51si2983175qge.110.2014.02.20.15.47.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Feb 2014 15:47:59 -0800 (PST)
Received: by mail-qc0-f174.google.com with SMTP id x13so4559963qcv.33
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 15:47:59 -0800 (PST)
Message-ID: <5306942C.2070902@gmail.com>
Date: Thu, 20 Feb 2014 18:47:56 -0500
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/11] pagewalk: update page table walker core
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Hi Naoya,

This patch seems to trigger a NULL ptr deref here. I didn't have a change to look into it yet
but here's the spew:

[  281.650503] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
[  281.651577] IP: [<ffffffff811a31fc>] __lock_acquire+0xbc/0x580
[  281.652453] PGD 40b88d067 PUD 40b88c067 PMD 0
[  281.653143] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  281.653869] Dumping ftrace buffer:
[  281.654430]    (ftrace buffer empty)
[  281.654975] Modules linked in:
[  281.655441] CPU: 4 PID: 12314 Comm: trinity-c361 Tainted: G        W 
3.14.0-rc3-next-20140220-sasha-00008-gab7e7ac-dirty #113
[  281.657622] task: ffff8804242ab000 ti: ffff880424348000 task.ti: ffff880424348000
[  281.658503] RIP: 0010:[<ffffffff811a31fc>]  [<ffffffff811a31fc>] __lock_acquire+0xbc/0x580
[  281.660025] RSP: 0018:ffff880424349ab8  EFLAGS: 00010002
[  281.660761] RAX: 0000000000000086 RBX: 0000000000000018 RCX: 0000000000000000
[  281.660761] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000018
[  281.660761] RBP: ffff880424349b28 R08: 0000000000000001 R09: 0000000000000000
[  281.660761] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8804242ab000
[  281.660761] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000001
[  281.660761] FS:  00007f36534b0700(0000) GS:ffff88052bc00000(0000) knlGS:0000000000000000
[  281.660761] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  281.660761] CR2: 0000000000000018 CR3: 000000040b88e000 CR4: 00000000000006e0
[  281.660761] Stack:
[  281.660761]  ffff880424349ae8 ffffffff81180695 ffff8804242ab038 0000000000000004
[  281.660761]  00000000001d8500 ffff88052bdd8500 ffff880424349b18 ffffffff81180915
[  281.660761]  ffffffff876a68b0 ffff8804242ab000 0000000000000000 0000000000000001
[  281.660761] Call Trace:
[  281.660761]  [<ffffffff81180695>] ? sched_clock_local+0x25/0x90
[  281.660761]  [<ffffffff81180915>] ? sched_clock_cpu+0xc5/0x110
[  281.660761]  [<ffffffff811a3842>] lock_acquire+0x182/0x1d0
[  281.660761]  [<ffffffff812990d8>] ? walk_pte_range+0xb8/0x170
[  281.660761]  [<ffffffff811a3daa>] ? __lock_release+0x1da/0x1f0
[  281.660761]  [<ffffffff8438ae5b>] _raw_spin_lock+0x3b/0x70
[  281.660761]  [<ffffffff812990d8>] ? walk_pte_range+0xb8/0x170
[  281.660761]  [<ffffffff812990d8>] walk_pte_range+0xb8/0x170
[  281.660761]  [<ffffffff812993a1>] walk_pmd_range+0x211/0x240
[  281.660761]  [<ffffffff812994fb>] walk_pud_range+0x12b/0x160
[  281.660761]  [<ffffffff81299639>] walk_pgd_range+0x109/0x140
[  281.660761]  [<ffffffff812996a5>] __walk_page_range+0x35/0x40
[  281.660761]  [<ffffffff81299862>] walk_page_range+0xf2/0x130
[  281.660761]  [<ffffffff812a8ccc>] queue_pages_range+0x6c/0x90
[  281.660761]  [<ffffffff812a8d80>] ? queue_pages_hugetlb+0x90/0x90
[  281.660761]  [<ffffffff812a8cf0>] ? queue_pages_range+0x90/0x90
[  281.660761]  [<ffffffff812a8f50>] ? change_prot_numa+0x30/0x30
[  281.660761]  [<ffffffff812ac9f1>] do_mbind+0x311/0x330
[  281.660761]  [<ffffffff811815c1>] ? vtime_account_user+0x91/0xa0
[  281.660761]  [<ffffffff8124f1a8>] ? context_tracking_user_exit+0xa8/0x1c0
[  281.660761]  [<ffffffff812aca99>] SYSC_mbind+0x89/0xb0
[  281.660761]  [<ffffffff812acac9>] SyS_mbind+0x9/0x10
[  281.660761]  [<ffffffff84395360>] tracesys+0xdd/0xe2
[  281.660761] Code: c2 04 47 49 85 be fa 0b 00 00 48 c7 c7 bb 85 49 85 e8 d9 7b f9 ff 31 c0 e9 9c 
04 00 00 66 90 44 8b 1d a9 b8 ac 04 45 85 db 74 0c <48> 81 3b 40 61 3f 87 75 06 0f 1f 00 45 31 c0 83 
fe 01 77 0c 89
[  281.660761] RIP  [<ffffffff811a31fc>] __lock_acquire+0xbc/0x580
[  281.660761]  RSP <ffff880424349ab8>
[  281.660761] CR2: 0000000000000018
[  281.660761] ---[ end trace b6e188d329664196 ]---

Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
