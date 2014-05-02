Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 46C146B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 12:39:37 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id dc16so2794441qab.14
        for <linux-mm@kvack.org>; Fri, 02 May 2014 09:39:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g6si47219480yhd.80.2014.05.02.09.39.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 09:39:36 -0700 (PDT)
Message-ID: <5363CA40.2000808@oracle.com>
Date: Fri, 02 May 2014 12:39:28 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: invalid memory access in zap_pte_range
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running latest -next
kernel I've stumbled on the following:

[ 5470.347501] BUG: unable to handle kernel paging request at ffffea0003480088
[ 5470.349619] IP: zap_pte_range (mm/memory.c:1137)
[ 5470.350338] PGD 37fcc067 PUD 37fcb067 PMD 0
[ 5470.350338] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 5470.350338] Dumping ftrace buffer:
[ 5470.350338]    (ftrace buffer empty)
[ 5470.350338] Modules linked in:
[ 5470.350338] CPU: 3 PID: 38591 Comm: trinity-c207 Tainted: G        W     3.15.0-rc3-next-20140430-sasha-00016-g4e281fa-dirty #429
[ 5470.361024] task: ffff88017136b000 ti: ffff88016f068000 task.ti: ffff88016f068000
[ 5470.361024] RIP: zap_pte_range (mm/memory.c:1137)
[ 5470.361024] RSP: 0018:ffff88016f069c88  EFLAGS: 00010246
[ 5470.361024] RAX: ffffea0003480080 RBX: ffff880341a2fd88 RCX: 0000000003480080
[ 5470.361024] RDX: ffff880341a2fd88 RSI: 00000000403b1000 RDI: ffff880159b05000
[ 5470.361024] RBP: ffff88016f069d28 R08: ffff88034beb6400 R09: ffff88017136bcf0
[ 5470.361024] R10: 0000000000000001 R11: 0000000000000000 R12: ffffea0003480080
[ 5470.361024] R13: ffff88016f069e18 R14: 00000000403b2000 R15: 00000000403b1000
[ 5470.361024] FS:  00007f59dec96700(0000) GS:ffff88010cc00000(0000) knlGS:0000000000000000
[ 5470.361024] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 5470.361024] CR2: ffffea0003480088 CR3: 00000001748b7000 CR4: 00000000000006a0
[ 5470.361024] DR0: 00000000006de000 DR1: 0000000000000000 DR2: 0000000000000000
[ 5470.361024] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 5470.361024] Stack:
[ 5470.361024]  ffff88016f069e18 00000000d2002000 00000000d2002fff ffff88017136b000
[ 5470.361024]  0000000000000000 0000000000000001 ffff880354664008 ffff88033fcfc640
[ 5470.361024]  00000000d2002730 ffff88034beb6400 0000000000000000 ffff880159b05000
[ 5470.361024] Call Trace:
[ 5470.361024] unmap_single_vma (mm/memory.c:1261 mm/memory.c:1282 mm/memory.c:1307 mm/memory.c:1353)
[ 5470.361024] unmap_vmas (mm/memory.c:1382 (discriminator 1))
[ 5470.361024] unmap_region (mm/mmap.c:2368 (discriminator 3))
[ 5470.361024] ? put_lock_stats.isra.12 (kernel/locking/lockdep.c:254)
[ 5470.361024] ? validate_mm_rb (mm/mmap.c:409)
[ 5470.361024] ? vma_rb_erase (mm/mmap.c:454 include/linux/rbtree_augmented.h:219 include/linux/rbtree_augmented.h:227 mm/mmap.c:493)
[ 5470.361024] do_munmap (mm/mmap.c:3264 mm/mmap.c:2566)
[ 5470.361024] ? vm_munmap (mm/mmap.c:2577)
[ 5470.361024] vm_munmap (mm/mmap.c:2578)
[ 5470.361024] SyS_munmap (mm/mmap.c:2583)
[ 5470.361024] tracesys (arch/x86/kernel/entry_64.S:746)
[ 5470.361024] Code: e8 de a6 26 03 49 8b 4c 24 10 48 39 c8 74 1c 48 8b 7d b8 48 c1 e1 0c 48 89 da 48 83 c9 40 4c 89 fe e8 95 db ff ff 0f 1f 44 00 00 <41> f6 44 24 08 01 74 08 83 6d c8 01 eb 33 66 90 f6 45 a0 40 74
[ 5470.361024] RIP zap_pte_range (mm/memory.c:1137)
[ 5470.361024]  RSP <ffff88016f069c88>
[ 5470.361024] CR2: ffffea0003480088


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
