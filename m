Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 55DEC6B0036
	for <linux-mm@kvack.org>; Sat, 10 May 2014 20:34:49 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id rd18so704995iec.38
        for <linux-mm@kvack.org>; Sat, 10 May 2014 17:34:49 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id nx5si6208443icb.98.2014.05.10.17.34.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 10 May 2014 17:34:47 -0700 (PDT)
Message-ID: <536EC5A0.3000204@oracle.com>
Date: Sat, 10 May 2014 20:34:40 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: hangs in collapse_huge_page
References: <534DE5C0.2000408@oracle.com> <20140430154230.GA23371@node.dhcp.inet.fi>
In-Reply-To: <20140430154230.GA23371@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/30/2014 11:42 AM, Kirill A. Shutemov wrote:
> On Tue, Apr 15, 2014 at 10:06:56PM -0400, Sasha Levin wrote:
>> > Hi all,
>> > 
>> > I often see hung task triggering in khugepaged within collapse_huge_page().
>> > 
>> > I've initially assumed the case may be that the guests are too loaded and
>> > the warning occurs because of load, but after increasing the timeout to
>> > 1200 sec I still see the warning.
> I suspect it's race (although I didn't track down exact scenario) with
> __khugepaged_exit().
> 
> Comment in __khugepaged_exit() says that khugepaged_test_exit() always
> called under mmap_sem:
> 
> 2045 void __khugepaged_exit(struct mm_struct *mm)
> ...
> 2063         } else if (mm_slot) {
> 2064                 /*
> 2065                  * This is required to serialize against
> 2066                  * khugepaged_test_exit() (which is guaranteed to run
> 2067                  * under mmap sem read mode). Stop here (after we
> 2068                  * return all pagetables will be destroyed) until
> 2069                  * khugepaged has finished working on the pagetables
> 2070                  * under the mmap_sem.
> 2071                  */
> 2072                 down_write(&mm->mmap_sem);
> 2073                 up_write(&mm->mmap_sem);
> 2074         }
> 2075 }
> 
> But this is not true. At least khugepaged_scan_mm_slot() calls it without
> the sem:
> 
> 2566 static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
> 2567                                             struct page **hpage)
> ...
> 2046 {
> 2047         struct mm_slot *mm_slot;
> 2048         int free = 0;
> 2049 
> 2050         spin_lock(&khugepaged_mm_lock);
> 2051         mm_slot = get_mm_slot(mm);
> 2052         if (mm_slot && khugepaged_scan.mm_slot != mm_slot) {
> 2053                 hash_del(&mm_slot->hash);
> 2054                 list_del(&mm_slot->mm_node);
> 2055                 free = 1;
> 2056         }
> 2057         spin_unlock(&khugepaged_mm_lock);
> 2058 
> 2059         if (free) {
> 2060                 clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
> 2061                 free_mm_slot(mm_slot);
> 2062                 mmdrop(mm);
> 
> Not sure yet if it's a real problem or not. Andrea, could you comment on
> this?
> 
> Sasha, please try patch below.

That patch really solved the problem for me, I didn't see a single hang
up until today. So I suspect that while that patch is good there is another
(smaller) case which may case a hang.

[ 6006.253399] INFO: task khugepaged:3814 blocked for more than 1200 seconds.
[ 6006.254711]       Tainted: G        W     3.15.0-rc4-next-20140508-sasha-00020-gec9304b-dirty #452
[ 6006.257591] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 6006.260710] khugepaged      D ffff8805bb7a64b8  4968  3814      2 0x00000000
[ 6006.263261]  ffff880291e61b48 0000000000000002 ffffffff955890d0 ffff8802927f0000
[ 6006.264986]  ffff880291e61fd8 00000000001d7840 00000000001d7840 00000000001d7840
[ 6006.265923]  ffff8805b040b000 ffff8802927f0000 ffff880291e61b38 ffff8802927f0000
[ 6006.267193] Call Trace:
[ 6006.267629] ? _raw_spin_unlock_irq (arch/x86/include/asm/paravirt.h:819 include/linux/spinlock_api_smp.h:168 kernel/locking/spinlock.c:199)
[ 6006.268673] schedule (kernel/sched/core.c:2765)
[ 6006.269674] rwsem_down_write_failed (kernel/locking/rwsem-xadd.c:289)
[ 6006.270998] ? get_parent_ip (kernel/sched/core.c:2485)
[ 6006.271984] call_rwsem_down_write_failed (arch/x86/lib/rwsem.S:106)
[ 6006.273240] ? khugepaged_scan_mm_slot (mm/huge_memory.c:1991 mm/huge_memory.c:2598)
[ 6006.274327] ? lock_contended (kernel/locking/lockdep.c:3734 kernel/locking/lockdep.c:3812)
[ 6006.275299] ? down_write (kernel/locking/rwsem.c:50 (discriminator 2))
[ 6006.276126] ? collapse_huge_page.isra.31 (mm/huge_memory.c:1991 mm/huge_memory.c:2385)
[ 6006.277281] collapse_huge_page.isra.31 (mm/huge_memory.c:1991 mm/huge_memory.c:2385)
[ 6006.278328] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 6006.279534] ? put_lock_stats.isra.12 (arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[ 6006.281314] ? khugepaged_scan_mm_slot (include/linux/spinlock.h:343 mm/huge_memory.c:2540 mm/huge_memory.c:2636)
[ 6006.282140] ? get_parent_ip (kernel/sched/core.c:2485)
[ 6006.283039] khugepaged_scan_mm_slot (mm/huge_memory.c:2640)
[ 6006.284074] khugepaged (include/linux/spinlock.h:343 mm/huge_memory.c:2720 mm/huge_memory.c:2753)
[ 6006.284986] ? bit_waitqueue (kernel/sched/wait.c:291)
[ 6006.285864] ? khugepaged_scan_mm_slot (mm/huge_memory.c:2746)
[ 6006.286897] kthread (kernel/kthread.c:210)
[ 6006.287705] ? kthread_create_on_node (kernel/kthread.c:176)
[ 6006.288796] ret_from_fork (arch/x86/kernel/entry_64.S:553)
[ 6006.289668] ? kthread_create_on_node (kernel/kthread.c:176)
[ 6006.291708] 1 lock held by khugepaged/3814:
[ 6006.292368] #0: (&mm->mmap_sem){++++++}, at: collapse_huge_page.isra.31 (mm/huge_memory.c:1991 mm/huge_memory.c:2385)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
