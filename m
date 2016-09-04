Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A78B6B0038
	for <linux-mm@kvack.org>; Sun,  4 Sep 2016 19:31:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c132so259788928pfg.2
        for <linux-mm@kvack.org>; Sun, 04 Sep 2016 16:31:15 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id e4si25688546pav.216.2016.09.04.16.31.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 04 Sep 2016 16:31:14 -0700 (PDT)
Subject: Re: mm: GPF in __insert_vmap_area
References: <CACT4Y+ZByeFG4bYEPPSKH9ZfGquj560EqxJAo0BfjrqMguFVTw@mail.gmail.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57CCAE89.9080906@zoho.com>
Date: Mon, 5 Sep 2016 07:30:17 +0800
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZByeFG4bYEPPSKH9ZfGquj560EqxJAo0BfjrqMguFVTw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>
Cc: zijun_hu@htc.com, syzkaller <syzkaller@googlegroups.com>

On 09/03/2016 08:15 PM, Dmitry Vyukov wrote:
> Hello,
> 
> While running syzkaller fuzzer I've got the following GPF:
> 
> general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 2 PID: 4268 Comm: syz-executor Not tainted 4.8.0-rc3-next-20160825+ #8
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88006a6527c0 task.stack: ffff880052630000
> RIP: 0010:[<ffffffff82e1ccd6>]  [<ffffffff82e1ccd6>]
> __list_add_valid+0x26/0xd0 lib/list_debug.c:23
> RSP: 0018:ffff880052637a18  EFLAGS: 00010202
> RAX: dffffc0000000000 RBX: 0000000000000000 RCX: ffffc90001c87000
> RDX: 0000000000000001 RSI: ffff88001344cdb0 RDI: 0000000000000008
> RBP: ffff880052637a30 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: ffffffff8a5deee0 R12: ffff88006cc47230
> R13: ffff88001344cdb0 R14: ffff88006cc47230 R15: 0000000000000000
> FS:  00007fbacc97e700(0000) GS:ffff88006d200000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020de7000 CR3: 000000003c4d2000 CR4: 00000000000006e0
> DR0: 000000000000001e DR1: 000000000000001e DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> Stack:
>  ffff88006cc47200 ffff88001344cd98 ffff88006cc47200 ffff880052637a78
>  ffffffff817bc6d1 ffff88006cc47208 ffffed000d988e41 ffff88006cc47208
>  ffff88006cc3e680 ffffc900035b7000 ffffc900035a7000 ffff88006cc47200
> Call Trace:
>  [<     inline     >] __list_add_rcu include/linux/rculist.h:51
>  [<     inline     >] list_add_rcu include/linux/rculist.h:78
>  [<ffffffff817bc6d1>] __insert_vmap_area+0x1c1/0x3c0 mm/vmalloc.c:340
>  [<ffffffff817bf544>] alloc_vmap_area+0x614/0x890 mm/vmalloc.c:458
>  [<ffffffff817bf8a8>] __get_vm_area_node+0xe8/0x340 mm/vmalloc.c:1377
>  [<ffffffff817c332a>] __vmalloc_node_range+0xaa/0x6d0 mm/vmalloc.c:1687
>  [<     inline     >] __vmalloc_node mm/vmalloc.c:1736
>  [<ffffffff817c39ab>] __vmalloc+0x5b/0x70 mm/vmalloc.c:1742
>  [<ffffffff8166ae9c>] bpf_prog_alloc+0x3c/0x190 kernel/bpf/core.c:82
>  [<ffffffff85c40ba9>] bpf_prog_create_from_user+0xa9/0x2c0
> net/core/filter.c:1132
>  [<     inline     >] seccomp_prepare_filter kernel/seccomp.c:373
>  [<     inline     >] seccomp_prepare_user_filter kernel/seccomp.c:408
>  [<     inline     >] seccomp_set_mode_filter kernel/seccomp.c:737
>  [<ffffffff815d7687>] do_seccomp+0x317/0x1800 kernel/seccomp.c:787
>  [<ffffffff815d8f84>] prctl_set_seccomp+0x34/0x60 kernel/seccomp.c:830
>  [<     inline     >] SYSC_prctl kernel/sys.c:2157
>  [<ffffffff813ccf8f>] SyS_prctl+0x82f/0xc80 kernel/sys.c:2075
>  [<ffffffff86e10700>] entry_SYSCALL_64_fastpath+0x23/0xc1
> Code: 00 00 00 00 00 55 48 b8 00 00 00 00 00 fc ff df 48 89 e5 41 54
> 49 89 fc 48 8d 7a 08 53 48 89 d3 48 89 fa 48 83 ec 08 48 c1 ea 03 <80>
> 3c 02 00 75 7c 48 8b 53 08 48 39 f2 75 37 48 89 f2 48 b8 00
> RIP  [<ffffffff82e1ccd6>] __list_add_valid+0x26/0xd0 lib/list_debug.c:23
>  RSP <ffff880052637a18>
> ---[ end trace 983e625f02f00d9f ]---
> Kernel panic - not syncing: Fatal exception
> 
> On commit 0f98f121e1670eaa2a2fbb675e07d6ba7f0e146f of linux-next.
> Unfortunately it is not reproducible.
> The crashing line is:
>         CHECK_DATA_CORRUPTION(next->prev != prev,
> 
> It crashed on KASAN check at (%rax, %rdx), this address corresponds to
> next address = 0x8. So next was ~NULL.
> 
Hi Dmitry
i am not sure for the real reason of the GPF panic
i have been browsing mm/vmalloc.c recently and have found several bugs perhaps
i hope it maybe help you

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e7..1429ee6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -321,10 +321,10 @@ static void __insert_vmap_area(struct vmap_area *va)
 
 		parent = *p;
 		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
-		if (va->va_start < tmp_va->va_end)
-			p = &(*p)->rb_left;
-		else if (va->va_end > tmp_va->va_start)
-			p = &(*p)->rb_right;
+		if (va->va_end <= tmp_va->va_start)
+			p = &parent->rb_left;
+		else if (va->va_start >= tmp_va->va_end)
+			p = &parent->rb_right;
 		else
 			BUG();
 	}
@@ -432,6 +432,9 @@ nocache:
 
 		if (!first)
 			goto found;
+
+		if (addr > first->va_end)
+			first = list_next_entry(first, list);
 	}
 
 	/* from the starting point, walk areas until a suitable hole is found */
@@ -594,7 +597,9 @@ static unsigned long lazy_max_pages(void)
 {
 	unsigned int log;
 
-	log = fls(num_online_cpus());
+	log = num_online_cpus();
+	if (log > 1)
+		log = (unsigned int)get_count_order(log);
 
 	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
