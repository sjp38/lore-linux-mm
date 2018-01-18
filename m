Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18E956B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 16:55:23 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id p4so16851832wrf.4
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 13:55:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z10si6747874wre.396.2018.01.18.13.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 13:55:21 -0800 (PST)
Date: Thu, 18 Jan 2018 13:55:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-Id: <20180118135518.639141f0b0ea8bb047ab6306@linux-foundation.org>
In-Reply-To: <bug-198497-27@https.bugzilla.kernel.org/>
References: <bug-198497-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, Matthew Wilcox <willy@infradead.org>, peter@rimuhosting.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).


On Thu, 18 Jan 2018 01:21:56 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=198497
> 
>             Bug ID: 198497
>            Summary: handle_mm_fault / xen_pmd_val / radix_tree_lookup_slot
>                     Null pointer
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: Linux app1.vpsgate.com
>                     4.14.13-rh10-20180115190010.xenU.i386 #1 SMP Mon Jan
>                     15 19:04:55 UTC 2018 i686 GNU/Linux
>           Hardware: Intel
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: peter@rimuhosting.com
>         Regression: No

Does this look familiar to anyone?

> On a Xen VM running as pvh
> 
> [    3.499843] Adding 131068k swap on /dev/xvda9.  Priority:-2 extents:1
> across:131068k SSFS
> [    3.547312] EXT4-fs (xvda1): re-mounted. Opts: (null)
> [    3.988606] EXT4-fs (xvda1): re-mounted. Opts: errors=remount-ro
> [   24.647744] BUG: unable to handle kernel NULL pointer dereference at
> 00000008
> [   24.647801] IP: __radix_tree_lookup+0x14/0xa0
> [   24.647811] *pdpt = 00000000253d6027 *pde = 0000000000000000 
> [   24.647828] Oops: 0000 [#1] SMP
> [   24.647842] CPU: 5 PID: 3600 Comm: java Not tainted
> 4.14.13-rh10-20180115190010.xenU.i386 #1
> [   24.647855] task: e52518c0 task.stack: e4e7a000
> [   24.647866] EIP: __radix_tree_lookup+0x14/0xa0
> [   24.647876] EFLAGS: 00010286 CPU: 5
> [   24.647884] EAX: 00000004 EBX: 00000007 ECX: 00000000 EDX: 00000000
> [   24.647895] ESI: 00000000 EDI: 00000000 EBP: e4e7bdb8 ESP: e4e7bda0
> [   24.647904]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0069
> [   24.647917] CR0: 80050033 CR2: 00000008 CR3: 25360000 CR4: 00002660
> [   24.647930] Call Trace:
> [   24.647942]  radix_tree_lookup_slot+0x13/0x30
> [   24.647955]  find_get_entry+0x1d/0x120
> [   24.647963]  pagecache_get_page+0x1f/0x230
> [   24.647975]  lookup_swap_cache+0x42/0x140
> [   24.647983]  swap_readahead_detect+0x66/0x2e0
> [   24.647993]  do_swap_page+0x1fa/0x860
> [   24.648010]  ? __raw_callee_save___pv_queued_spin_unlock+0x9/0x10
> [   24.648026]  ? xen_pmd_val+0x10/0x20
> [   24.648035]  handle_mm_fault+0x6f8/0x1020
> [   24.648046]  __do_page_fault+0x18a/0x450
> [   24.648055]  ? vmalloc_sync_all+0x250/0x250
> [   24.648063]  do_page_fault+0x21/0x30
> [   24.648074]  common_exception+0x45/0x4a
> [   24.648082] EIP: 0xb76d873e
> [   24.648088] EFLAGS: 00010206 CPU: 5
> [   24.648096] EAX: 76a10000 EBX: 76a1cd14 ECX: 00000006 EDX: 00000006
> [   24.648105] ESI: 00000040 EDI: b796c380 EBP: 77881008 ESP: 77880ff8
> [   24.648115]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
> [   24.648124] Code: ff ff ff 00 47 03 e9 69 ff ff ff 8b 45 08 89 06 e9 1f ff
> ff ff 66 90 55 89 e5 57 89 d7 56 53 83 ec 0c 89 45 ec 89 4d e8 8b 45 ec <8b> 58
> 04 89 d8 83 e0 03 48 89 5d f0 75 64 89 d8 83 e0 fe 0f b6
> [   24.648195] EIP: __radix_tree_lookup+0x14/0xa0 SS:ESP: 0069:e4e7bda0
> [   24.648205] CR2: 0000000000000008
> [   24.648273] ---[ end trace ed356e59f215ce07 ]---
> [   28.890326] BUG: unable to handle kernel NULL pointer dereference at
> 00000008
> [   28.890372] IP: __radix_tree_lookup+0x14/0xa0
> [   28.890382] *pdpt = 0000000025488027 *pde = 0000000000000000 
> [   28.890396] Oops: 0000 [#2] SMP
> [   28.890408] CPU: 7 PID: 3542 Comm: java Tainted: G      D        
> 4.14.13-rh10-20180115190010.xenU.i386 #1
> [   28.890423] task: e8691080 task.stack: e52a6000
> [   28.890433] EIP: __radix_tree_lookup+0x14/0xa0
> [   28.890442] EFLAGS: 00010286 CPU: 7
> [   28.890449] EAX: 00000004 EBX: 00000007 ECX: 00000000 EDX: 00000000
> [   28.890459] ESI: 00000000 EDI: 00000000 EBP: e52a7db8 ESP: e52a7da0
> [   28.890469]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0069
> [   28.890484] CR0: 80050033 CR2: 00000008 CR3: 25161000 CR4: 00002660
> [   28.890498] Call Trace:
> [   28.890510]  radix_tree_lookup_slot+0x13/0x30
> [   28.890522]  find_get_entry+0x1d/0x120
> [   28.890531]  pagecache_get_page+0x1f/0x230
> [   28.890541]  lookup_swap_cache+0x42/0x140
> [   28.890550]  swap_readahead_detect+0x66/0x2e0
> [   28.890559]  do_swap_page+0x1fa/0x860
> [   28.890573]  ? __raw_callee_save___pv_queued_spin_unlock+0x9/0x10
> [   28.890588]  ? xen_pmd_val+0x10/0x20
> [   28.890597]  handle_mm_fault+0x6f8/0x1020
> [   28.890607]  __do_page_fault+0x18a/0x450
> [   28.890616]  ? vmalloc_sync_all+0x250/0x250
> [   28.890681]  do_page_fault+0x21/0x30
> [   28.890707]  common_exception+0x45/0x4a
> [   28.890715] EIP: 0xb779774f
> [   28.890722] EFLAGS: 00010202 CPU: 7
> [   28.890730] EAX: 00000000 EBX: 66dd9d6c ECX: 02000000 EDX: 00000001
> [   28.890740] ESI: 02000000 EDI: 00000000 EBP: 674fe068 ESP: 674fe058
> [   28.890751]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
> [   28.890759] Code: ff ff ff 00 47 03 e9 69 ff ff ff 8b 45 08 89 06 e9 1f ff
> ff ff 66 90 55 89 e5 57 89 d7 56 53 83 ec 0c 89 45 ec 89 4d e8 8b 45 ec <8b> 58
> 04 89 d8 83 e0 03 48 89 5d f0 75 64 89 d8 83 e0 fe 0f b6
> [   28.890830] EIP: __radix_tree_lookup+0x14/0xa0 SS:ESP: 0069:e52a7da0
> [   28.890841] CR2: 0000000000000008
> [   28.890886] ---[ end trace ed356e59f215ce08 ]---
> 
> # java -version
> java version "1.7.0_51"
> Java(TM) SE Runtime Environment (build 1.7.0_51-b13)
> Java HotSpot(TM) Server VM (build 24.51-b03, mixed mode)
> 
> ~# free -m
>              total       used       free     shared    buffers     cached
> Mem:          5418        572       4846          0         25        245
> -/+ buffers/cache:        301       5117
> Swap:          127          0        127
> 
> # uptime
>  01:21:08 up  2:02,  3 users,  load average: 13.47, 13.65, 13.63
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
