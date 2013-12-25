Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C46126B0035
	for <linux-mm@kvack.org>; Tue, 24 Dec 2013 19:35:23 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so5025822pab.5
        for <linux-mm@kvack.org>; Tue, 24 Dec 2013 16:35:23 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id dv5si16785135pbb.133.2013.12.24.16.35.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Dec 2013 16:35:22 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 25 Dec 2013 06:05:19 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 23D663940057
	for <linux-mm@kvack.org>; Wed, 25 Dec 2013 06:05:17 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBP0ZCPY54853874
	for <linux-mm@kvack.org>; Wed, 25 Dec 2013 06:05:13 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBP0ZFkp009578
	for <linux-mm@kvack.org>; Wed, 25 Dec 2013 06:05:15 +0530
Date: Wed, 25 Dec 2013 08:35:13 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/thp: fix vmas tear down race with thp splitting
Message-ID: <52ba284a.e560440a.7eeb.ffff92bcSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387850059-18525-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <52B9A65D.8060300@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="CUfgB8w4ZwR/yMy5"
Content-Disposition: inline
In-Reply-To: <52B9A65D.8060300@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--CUfgB8w4ZwR/yMy5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Cc Andrea,
On Tue, Dec 24, 2013 at 10:21:01AM -0500, Sasha Levin wrote:
>On 12/23/2013 08:54 PM, Wanpeng Li wrote:
>>Sasha reports unmap_page_range tears down pmd range which is race with thp
>>splitting during page reclaim. Transparent huge page will be splitting
>>during page reclaim. However, split pmd lock which held by __split_trans_huge_lock
>>can't prevent __split_huge_page_refcount running in parallel. This patch fix
>>it by hold compound lock to check if __split_huge_page_refcount is running
>>underneath, in that case zap huge pmd range should be fallback.
>>
>>[  265.474585] kernel BUG at mm/huge_memory.c:1440!
>>[  265.475129] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>[  265.476684] Dumping ftrace buffer:
>>[  265.477144]    (ftrace buffer empty)
>>[  265.478398] Modules linked in:
>>[  265.478807] CPU: 8 PID: 11344 Comm: trinity-c206 Tainted: G        W    3.13.0-rc5-next-20131223-sasha-00015-gec22156-dirty #8
>>[  265.480172] task: ffff8801cb573000 ti: ffff8801cbd3a000 task.ti: ffff8801cbd3a000
>>[  265.480172] RIP: 0010:[<ffffffff812c7f70>]  [<ffffffff812c7f70>] zap_huge_pmd+0x170/0x1f0
>>[  265.480172] RSP: 0000:ffff8801cbd3bc78  EFLAGS: 00010246
>>[  265.480172] RAX: 015fffff80090018 RBX: ffff8801cbd3bde8 RCX: ffffffffffffff9c
>>[  265.480172] RDX: ffffffffffffffff RSI: 0000000000000008 RDI: ffff8800bffd2000
>>[  265.480172] RBP: ffff8801cbd3bcb8 R08: 0000000000000000 R09: 0000000000000000
>>[  265.480172] R10: 0000000000000001 R11: 0000000000000000 R12: ffffea0002856740
>>[  265.480172] R13: ffffea0002d50000 R14: 00007ff915000000 R15: 00007ff930e48fff
>>[  265.480172] FS:  00007ff934899700(0000) GS:ffff88014d400000(0000) knlGS:0000000000000000
>>[  265.480172] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>[  265.480172] CR2: 00007ff93428a000 CR3: 000000010babe000 CR4: 00000000000006e0
>>[  265.480172] Stack:
>>[  265.480172]  00000000000004dd ffff8801ccbfbb60 ffff8801cbd3bcb8 ffff8801cbb15540
>>[  265.480172]  00007ff915000000 00007ff930e49000 ffff8801cbd3bde8 00007ff930e48fff
>>[  265.480172]  ffff8801cbd3bd48 ffffffff812885b6 ffff88005f5d20c0 00007ff915200000
>>[  265.480172] Call Trace:
>>[  265.480172]  [<ffffffff812885b6>] unmap_page_range+0x2c6/0x410
>>[  265.480172]  [<ffffffff81288801>] unmap_single_vma+0x101/0x120
>>[  265.480172]  [<ffffffff81288881>] unmap_vmas+0x61/0xa0
>>[  265.480172]  [<ffffffff8128f730>] exit_mmap+0xd0/0x170
>>[  265.480172]  [<ffffffff81138860>] mmput+0x70/0xe0
>>[  265.480172]  [<ffffffff8113c89d>] exit_mm+0x18d/0x1a0
>>[  265.480172]  [<ffffffff811ea355>] ? acct_collect+0x175/0x1b0
>>[  265.480172]  [<ffffffff8113ed0f>] do_exit+0x26f/0x520
>>[  265.480172]  [<ffffffff8113f069>] do_group_exit+0xa9/0xe0
>>[  265.480172]  [<ffffffff8113f0b7>] SyS_exit_group+0x17/0x20
>>[  265.480172]  [<ffffffff845f10d0>] tracesys+0xdd/0xe2
>>[  265.480172] Code: 0f 0b 66 0f 1f 84 00 00 00 00 00 eb fe 66 0f 1f
>>44 00 00 48 8b 03 f0 48 81 80 50 03 00 00 00 fe ff ff 49 8b 45 00 f6
>>c4 40 75 10 <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 48 8b 03
>>f0 48
>>[  265.480172] RIP  [<ffffffff812c7f70>] zap_huge_pmd+0x170/0x1f0
>>[  265.480172]  RSP <ffff8801cbd3bc78>
>>
>>Reported-by: Sasha Levin <sasha.levin@oracle.com>
>>Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>---
>
>Ran a round of testing overnight. While the BUG seems to be gone I'm now getting:
>
>

Ah, I think the patch below fix it. However, as Kirill point out, we still need 
to figure out the root issue. 

Regards,
Wanpeng Li 

>
>Thanks,
>Sasha

--CUfgB8w4ZwR/yMy5
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-2.patch"


--CUfgB8w4ZwR/yMy5--
