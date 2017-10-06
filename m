Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE1196B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 11:26:05 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id o191so6891983vkd.1
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 08:26:05 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x3si388472vkf.216.2017.10.06.08.26.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 08:26:04 -0700 (PDT)
Subject: Re: [PATCH v10 05/10] mm: zero reserved and unavailable struct pages
References: <20171005211124.26524-1-pasha.tatashin@oracle.com>
 <20171005211124.26524-6-pasha.tatashin@oracle.com>
 <20171006123057.6gu5xnk3usw2hvzb@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <bcf24369-ac37-cedd-a264-3396fb5cf39e@oracle.com>
Date: Fri, 6 Oct 2017 11:25:16 -0400
MIME-Version: 1.0
In-Reply-To: <20171006123057.6gu5xnk3usw2hvzb@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Michal,

> 
> As I've said in other reply this should go in only if the scenario you
> describe is real. I am somehow suspicious to be honest. I simply do not
> see how those weird struct pages would be in a valid pfn range of any
> zone.
> 

There are examples of both when unavailable memory is not part of any 
zone, and where it is part of zones.

I run Linux in kvm with these arguments:

         qemu-system-x86_64
         -enable-kvm
         -cpu kvm64
         -kernel $kernel
         -initrd $initrd
         -m 512
         -smp 2
         -device e1000,netdev=net0
         -netdev user,id=net0
         -boot order=nc
         -no-reboot
         -watchdog i6300esb
         -watchdog-action debug
         -rtc base=localtime
         -serial stdio
         -display none
         -monitor null

This patch reports that there are 98 unavailable pages.

They are: pfn 0 and pfns in range [159, 255].

Note, trim_low_memory_range() reserves only pfns in range [0, 15], it 
does not reserve [159, 255] ones.

e820__memblock_setup() reports linux that the following physical ranges 
are available:
     [1 , 158]
[256, 130783]

Notice, that exactly unavailable pfns are missing!

Now, lets check what we have in zone 0: [1, 131039]

pfn 0, is not part of the zone, but pfns [1, 158], are.

However, the bigger problem we have if we do not initialize these struct 
pages is with memory hotplug. Because, that path operates at 2M 
boundaries (section_nr). And checks if 2M range of pages is hot 
removable. It starts with first pfn from zone, rounds it down to 2M 
boundary (sturct pages are allocated at 2M boundaries when vmemmap is 
created), and and checks if that section is hot removable. In this case 
start with pfn 1 and convert it down to pfn 0.

Later pfn is converted to struct page, and some fields are checked. Now, 
if we do not zero struct pages, we get unpredictable results. In fact 
when CONFIG_VM_DEBUG is enabled, and we explicitly set all vmemmap 
memory to ones, I am getting the following panic with kernel test 
without this patch applied:

[   23.277793] BUG: unable to handle kernel NULL pointer dereference at 
          (null)
[   23.278863] IP: is_pageblock_removable_nolock+0x35/0x90
[   23.279619] PGD 0 P4D 0
[   23.280031] Oops: 0000 [#1] PREEMPT
[   23.280527] CPU: 0 PID: 249 Comm: udevd Not tainted 
4.14.0-rc3_pt_memset10-00335-g5e2c7478bed5-dirty #8
[   23.281735] task: ffff88001f4e2900 task.stack: ffffc90000314000
[   23.282532] RIP: 0010:is_pageblock_removable_nolock+0x35/0x90
[   23.283275] RSP: 0018:ffffc90000317d60 EFLAGS: 00010202
[   23.283948] RAX: ffffffffffffffff RBX: ffff88001d92b000 RCX: 
0000000000000000
[   23.284862] RDX: 0000000000000000 RSI: 0000000000200000 RDI: 
ffff88001d92b000
[   23.285771] RBP: ffffc90000317d80 R08: 00000000000010c8 R09: 
0000000000000000
[   23.286542] R10: 0000000000000000 R11: 0000000000000000 R12: 
ffff88001db2b000
[   23.287264] R13: ffffffff81af6d00 R14: ffff88001f7d5000 R15: 
ffffffff82a1b6c0
[   23.287971] FS:  00007f4eb857f7c0(0000) GS:ffffffff81c27000(0000) 
knlGS:0000000000000000
[   23.288775] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   23.289355] CR2: 0000000000000000 CR3: 000000001f4e6000 CR4: 
00000000000006b0
[   23.290066] Call Trace:
[   23.290323]  ? is_mem_section_removable+0x5a/0xd0
[   23.290798]  show_mem_removable+0x6b/0xa0
[   23.291204]  dev_attr_show+0x1b/0x50
[   23.291565]  sysfs_kf_seq_show+0xa1/0x100
[   23.291967]  kernfs_seq_show+0x22/0x30
[   23.292349]  seq_read+0x1ac/0x3a0
[   23.292687]  kernfs_fop_read+0x36/0x190
[   23.293074]  ? security_file_permission+0x90/0xb0
[   23.293547]  __vfs_read+0x16/0x30
[   23.293884]  vfs_read+0x81/0x130
[   23.294214]  SyS_read+0x44/0xa0
[   23.294537]  entry_SYSCALL_64_fastpath+0x1f/0xbd
[   23.295003] RIP: 0033:0x7f4eb7c660a0
[   23.295364] RSP: 002b:00007ffda6cffe28 EFLAGS: 00000246 ORIG_RAX: 
0000000000000000
[   23.296152] RAX: ffffffffffffffda RBX: 00000000000003de RCX: 
00007f4eb7c660a0
[   23.296934] RDX: 0000000000001000 RSI: 00007ffda6cffec8 RDI: 
0000000000000005
[   23.297963] RBP: 00007ffda6cffde8 R08: 7379732f73656369 R09: 
6f6d656d2f6d6574
[   23.299198] R10: 726f6d656d2f7972 R11: 0000000000000246 R12: 
0000000000000022
[   23.300400] R13: 0000561d68ea7710 R14: 0000000000000000 R15: 
00007ffda6d05c78
[   23.301591] Code: c1 ea 35 49 c1 e8 2b 48 8b 14 d5 c0 b6 a1 82 41 83 
e0 03 48 85 d2 74 0c 48 c1 e8 29 25 f0 0f 00 00 48 01 c2 4d 69 c0 98 
05 00 00 <48> 8b 02 48 89 fa 48 83 e0 f8 49 8b 88 28 b5 d3 81 48 29 c2 49
[   23.304739] RIP: is_pageblock_removable_nolock+0x35/0x90 RSP: 
ffffc90000317d60
[   23.305940] CR2: 0000000000000000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
