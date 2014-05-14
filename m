Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8336B003A
	for <linux-mm@kvack.org>; Wed, 14 May 2014 17:29:18 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so101267eei.28
        for <linux-mm@kvack.org>; Wed, 14 May 2014 14:29:17 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id u49si2570162eef.82.2014.05.14.14.29.16
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 14:29:17 -0700 (PDT)
Date: Thu, 15 May 2014 00:29:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: hangs in collapse_huge_page
Message-ID: <20140514212915.GB15970@node.dhcp.inet.fi>
References: <534DE5C0.2000408@oracle.com>
 <20140430154230.GA23371@node.dhcp.inet.fi>
 <536EC5A0.3000204@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <536EC5A0.3000204@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, May 10, 2014 at 08:34:40PM -0400, Sasha Levin wrote:
> On 04/30/2014 11:42 AM, Kirill A. Shutemov wrote:
> > Sasha, please try patch below.
> 
> That patch really solved the problem for me, I didn't see a single hang
> up until today. So I suspect that while that patch is good there is another
> (smaller) case which may case a hang.

Looks like my patch didn't fix the problem but hide it. Most like due some
shift in timings because of additional lock/unlock.

I'll try to look more for a real issue.

> 
> [ 6006.253399] INFO: task khugepaged:3814 blocked for more than 1200 seconds.
> [ 6006.254711]       Tainted: G        W     3.15.0-rc4-next-20140508-sasha-00020-gec9304b-dirty #452
> [ 6006.257591] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 6006.260710] khugepaged      D ffff8805bb7a64b8  4968  3814      2 0x00000000
> [ 6006.263261]  ffff880291e61b48 0000000000000002 ffffffff955890d0 ffff8802927f0000
> [ 6006.264986]  ffff880291e61fd8 00000000001d7840 00000000001d7840 00000000001d7840
> [ 6006.265923]  ffff8805b040b000 ffff8802927f0000 ffff880291e61b38 ffff8802927f0000
> [ 6006.267193] Call Trace:
> [ 6006.267629] ? _raw_spin_unlock_irq (arch/x86/include/asm/paravirt.h:819 include/linux/spinlock_api_smp.h:168 kernel/locking/spinlock.c:199)
> [ 6006.268673] schedule (kernel/sched/core.c:2765)
> [ 6006.269674] rwsem_down_write_failed (kernel/locking/rwsem-xadd.c:289)
> [ 6006.270998] ? get_parent_ip (kernel/sched/core.c:2485)
> [ 6006.271984] call_rwsem_down_write_failed (arch/x86/lib/rwsem.S:106)
> [ 6006.273240] ? khugepaged_scan_mm_slot (mm/huge_memory.c:1991 mm/huge_memory.c:2598)
> [ 6006.274327] ? lock_contended (kernel/locking/lockdep.c:3734 kernel/locking/lockdep.c:3812)
> [ 6006.275299] ? down_write (kernel/locking/rwsem.c:50 (discriminator 2))
> [ 6006.276126] ? collapse_huge_page.isra.31 (mm/huge_memory.c:1991 mm/huge_memory.c:2385)
> [ 6006.277281] collapse_huge_page.isra.31 (mm/huge_memory.c:1991 mm/huge_memory.c:2385)
> [ 6006.278328] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
> [ 6006.279534] ? put_lock_stats.isra.12 (arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
> [ 6006.281314] ? khugepaged_scan_mm_slot (include/linux/spinlock.h:343 mm/huge_memory.c:2540 mm/huge_memory.c:2636)
> [ 6006.282140] ? get_parent_ip (kernel/sched/core.c:2485)
> [ 6006.283039] khugepaged_scan_mm_slot (mm/huge_memory.c:2640)
> [ 6006.284074] khugepaged (include/linux/spinlock.h:343 mm/huge_memory.c:2720 mm/huge_memory.c:2753)
> [ 6006.284986] ? bit_waitqueue (kernel/sched/wait.c:291)
> [ 6006.285864] ? khugepaged_scan_mm_slot (mm/huge_memory.c:2746)
> [ 6006.286897] kthread (kernel/kthread.c:210)
> [ 6006.287705] ? kthread_create_on_node (kernel/kthread.c:176)
> [ 6006.288796] ret_from_fork (arch/x86/kernel/entry_64.S:553)
> [ 6006.289668] ? kthread_create_on_node (kernel/kthread.c:176)
> [ 6006.291708] 1 lock held by khugepaged/3814:
> [ 6006.292368] #0: (&mm->mmap_sem){++++++}, at: collapse_huge_page.isra.31 (mm/huge_memory.c:1991 mm/huge_memory.c:2385)
> 
> 
> Thanks,
> Sasha
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
