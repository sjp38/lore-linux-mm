Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB116B0343
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 06:26:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n11so9699552wma.5
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 03:26:16 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id c40si2534119wra.181.2017.03.24.03.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 03:24:39 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id t189so9430137wmt.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 03:24:38 -0700 (PDT)
Date: Fri, 24 Mar 2017 13:24:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [x86/mm/gup] 2947ba054a [   71.329069] kernel BUG at
 include/linux/pagemap.h:151!
Message-ID: <20170324102436.xltop6udkx5pg4oq@node.shutemov.name>
References: <20170319225124.xodpqjldom6ceazz@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170319225124.xodpqjldom6ceazz@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Fengguang Wu <fengguang.wu@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, LKP <lkp@01.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Mon, Mar 20, 2017 at 06:51:24AM +0800, Fengguang Wu wrote:
> [   71.329069] kernel BUG at include/linux/pagemap.h:151!
> [   71.332456] invalid opcode: 0000 [#1]
> [   71.334359] CPU: 0 PID: 458 Comm: trinity-c0 Not tainted 4.11.0-rc2-00251-g2947ba0 #1
> [   71.338444] task: ffff88001f19ab00 task.stack: ffff88001f084000
> [   71.340586] RIP: 0010:gup_pud_range+0x56f/0x63d
> [   71.342886] RSP: 0018:ffff88001f087ba8 EFLAGS: 00010046
> [   71.345607] RAX: 0000000080000000 RBX: 000000000164e000 RCX: ffff88001e0badc0
> [   71.347923] RDX: dead000000000100 RSI: 0000000000000001 RDI: ffff88001e0badc0
> [   71.350249] RBP: ffff88001f087c38 R08: ffff88001f087cf8 R09: ffff88001f087c6c
> [   71.352741] R10: 0000000000000000 R11: ffff88001f19b0f0 R12: ffff88001f087c6c
> [   71.356086] R13: ffff88001e0badc0 R14: 800000001e7b7867 R15: 0000000000000000
> [   71.359328] FS:  00007f7ea7b60700(0000) GS:ffffffffae02f000(0000) knlGS:0000000000000000
> [   71.361945] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   71.363806] CR2: 00000000013eb130 CR3: 0000000017ddb000 CR4: 00000000000006f0
> [   71.366122] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   71.368424] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000d0602
> [   71.370729] Call Trace:
> [   71.371537]  __get_user_pages_fast+0x107/0x136
> [   71.373435]  get_user_pages_fast+0x78/0x89
> [   71.375447]  get_futex_key+0xfd/0x350
> [   71.376999]  ? simple_write_end+0x83/0xbe
> [   71.378614]  futex_requeue+0x1a3/0x585
> [   71.380244]  do_futex+0x834/0x86f
> [   71.381893]  ? kvm_clock_read+0x16/0x1e
> [   71.383794]  ? paravirt_sched_clock+0x9/0xd
> [   71.385857]  ? lock_release+0x11e/0x328
> [   71.387760]  SyS_futex+0x125/0x135
> [   71.389446]  ? write_seqcount_end+0x1a/0x1f
> [   71.391499]  ? vtime_account_user+0x4b/0x50
> [   71.393404]  do_syscall_64+0x61/0x74
> [   71.394806]  entry_SYSCALL64_slow_path+0x25/0x25

Looks like a false-negative in_atomic() in page_cache_get_speculative().
We are under local_irq_save() it should be atomic enough.

Not sure why other architectures haven't seen this before. Maybe TINY_RCU
plus PREEMPT is not common enough.

And unlike other architectures which uses generic GUP_fast(), we don't
really need page_cache_get_speculative() x86. get_page() would work
perfectly fine as we don't free pages until IPI broadcast is completed.
So if you saw it in page tables it will not go away under you.

I'm not sure what is the best way to fix this.
Few options:
 - Drop the VM_BUG();
 - Bump preempt count during __get_user_pages_fast();
 - Use get_page() instead of page_cache_get_speculative() on x86.

Any opinions?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
