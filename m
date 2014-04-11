Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id E082E6B0035
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 08:50:14 -0400 (EDT)
Received: by mail-yk0-f179.google.com with SMTP id 9so4801012ykp.38
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 05:50:13 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id b21si7911307yhl.138.2014.04.11.05.50.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 05:50:13 -0700 (PDT)
Message-ID: <5347E4FB.2090705@oracle.com>
Date: Fri, 11 Apr 2014 08:50:03 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm,x86: warning at arch/x86/mm/pat.c:781 untrack_pfn+0x65/0xb0()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, suresh.b.siddha@intel.com, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on the following:


[ 3431.738346] WARNING: CPU: 12 PID: 17371 at arch/x86/mm/pat.c:781 untrack_pfn+0x65/0xb0()
[ 3431.741153] Modules linked in:
[ 3431.742138] CPU: 12 PID: 17371 Comm: trinity-c361 Not tainted 3.14.0-next-20140410-sasha-00022-gb3d9015-dirty #390
[ 3431.745365]  0000000000000009 ffff8801b5635be8 ffffffffae51f40b 0000000000005b10
[ 3431.747699]  0000000000000000 ffff8801b5635c28 ffffffffab15a37c ffff8801b5635c38
[ 3431.750401]  ffff8802e8fd2e00 0000000000000000 ffff8801b5635d68 ffff8801b5635d68
[ 3431.752853] Call Trace:
[ 3431.753625] dump_stack (lib/dump_stack.c:52)
[ 3431.755244] warn_slowpath_common (kernel/panic.c:418)
[ 3431.757062] warn_slowpath_null (kernel/panic.c:453)
[ 3431.758828] untrack_pfn (arch/x86/mm/pat.c:781 (discriminator 3))
[ 3431.760785] unmap_single_vma (mm/memory.c:1316)
[ 3431.762703] ? sched_clock (arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[ 3431.764366] ? sched_clock_local (kernel/sched/clock.c:214)
[ 3431.766253] ? move_page_tables (mm/mremap.c:156 mm/mremap.c:217)
[ 3431.768071] unmap_vmas (mm/memory.c:1366 (discriminator 1))
[ 3431.769686] unmap_region (mm/mmap.c:2361 (discriminator 3))
[ 3431.771776] ? validate_mm_rb (mm/mmap.c:401)
[ 3431.773606] ? vma_rb_erase (mm/mmap.c:446 include/linux/rbtree_augmented.h:219 include/linux/rbtree_augmented.h:227 mm/mmap.c:485)
[ 3431.775268] do_munmap (mm/mmap.c:3259 mm/mmap.c:2559)
[ 3431.777012] move_vma (mm/mremap.c:306)
[ 3431.778621] SyS_mremap (mm/mremap.c:439 mm/mremap.c:501 mm/mremap.c:470)
[ 3431.780576] tracesys (arch/x86/kernel/entry_64.S:749)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
