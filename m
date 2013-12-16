Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 00C6F6B0035
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 23:04:45 -0500 (EST)
Received: by mail-oa0-f51.google.com with SMTP id i7so4441586oag.24
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 20:04:45 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bx5si6713865oec.39.2013.12.15.20.04.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 15 Dec 2013 20:04:45 -0800 (PST)
Message-ID: <52AE7B10.2080201@oracle.com>
Date: Sun, 15 Dec 2013 23:01:20 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: shm: hang in shmem_fallocate
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running latest -next, I've noticed that
quite often there's a hang happening inside shmem_fallocate. There are several processes stuck
trying to acquire inode->i_mutex (for more than 2 minutes), while the process that holds it has
the following stack trace:

[ 2059.561282] Call Trace:
[ 2059.561557]  [<ffffffff81175588>] ? sched_clock_cpu+0x108/0x120
[ 2059.562444]  [<ffffffff8118e1fa>] ? get_lock_stats+0x2a/0x60
[ 2059.563247]  [<ffffffff8118e23e>] ? put_lock_stats+0xe/0x30
[ 2059.563930]  [<ffffffff8118e1fa>] ? get_lock_stats+0x2a/0x60
[ 2059.564646]  [<ffffffff810adc13>] ? x2apic_send_IPI_mask+0x13/0x20
[ 2059.565431]  [<ffffffff811b3224>] ? __rcu_read_unlock+0x44/0xb0
[ 2059.566161]  [<ffffffff811d48d5>] ? generic_exec_single+0x55/0x80
[ 2059.566992]  [<ffffffff8128bd45>] ? page_remove_rmap+0x295/0x320
[ 2059.567782]  [<ffffffff843afe8c>] ? _raw_spin_lock+0x6c/0x80
[ 2059.568390]  [<ffffffff8127c6cc>] ? zap_pte_range+0xec/0x590
[ 2059.569157]  [<ffffffff8127c8d0>] ? zap_pte_range+0x2f0/0x590
[ 2059.569907]  [<ffffffff810c6560>] ? flush_tlb_mm_range+0x360/0x360
[ 2059.570855]  [<ffffffff843aa863>] ? preempt_schedule+0x53/0x80
[ 2059.571613]  [<ffffffff81077086>] ? ___preempt_schedule+0x56/0xb0
[ 2059.572526]  [<ffffffff810c6536>] ? flush_tlb_mm_range+0x336/0x360
[ 2059.573368]  [<ffffffff8127a6eb>] ? tlb_flush_mmu+0x3b/0x90
[ 2059.574152]  [<ffffffff8127a754>] ? tlb_finish_mmu+0x14/0x40
[ 2059.574951]  [<ffffffff8127d276>] ? zap_page_range_single+0x146/0x160
[ 2059.575797]  [<ffffffff81193768>] ? trace_hardirqs_on+0x8/0x10
[ 2059.576629]  [<ffffffff8127d303>] ? unmap_mapping_range+0x73/0x180
[ 2059.577362]  [<ffffffff8127d38e>] ? unmap_mapping_range+0xfe/0x180
[ 2059.578194]  [<ffffffff8125eeb7>] ? truncate_inode_page+0x37/0x90
[ 2059.579013]  [<ffffffff8126bc61>] ? shmem_undo_range+0x711/0x830
[ 2059.579807]  [<ffffffff8127d3f8>] ? unmap_mapping_range+0x168/0x180
[ 2059.580729]  [<ffffffff8126bd98>] ? shmem_truncate_range+0x18/0x40
[ 2059.581598]  [<ffffffff8126c0a9>] ? shmem_fallocate+0x99/0x2f0
[ 2059.582325]  [<ffffffff81278eae>] ? madvise_vma+0xde/0x1c0
[ 2059.583049]  [<ffffffff8119555a>] ? __lock_release+0x1da/0x1f0
[ 2059.583816]  [<ffffffff812d0cb6>] ? do_fallocate+0x126/0x170
[ 2059.584581]  [<ffffffff81278ec4>] ? madvise_vma+0xf4/0x1c0
[ 2059.585302]  [<ffffffff81279118>] ? SyS_madvise+0x188/0x250
[ 2059.586012]  [<ffffffff843ba5d0>] ? tracesys+0xdd/0xe2
[ 2059.586689]  ffff880f39bc3db8 0000000000000002 ffff880fce4b0000 ffff880fce4b0000
[ 2059.587768]  ffff880f39bc2010 00000000001d78c0 00000000001d78c0 00000000001d78c0
[ 2059.588840]  ffff880fce6a0000 ffff880fce4b0000 ffff880fe5bd6d40 ffff880fa88e8ab0


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
