Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B210C8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:36:16 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id d11so10579475wrq.18
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 02:36:16 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id z4si32292175wme.21.2019.01.21.02.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 02:36:10 -0800 (PST)
Subject: Re: [PATCH v3 3/3] powerpc/32: Add KASAN support
References: <cover.1547289808.git.christophe.leroy@c-s.fr>
 <935f9f83393affb5d55323b126468ecb90373b88.1547289808.git.christophe.leroy@c-s.fr>
 <e4b343fa-702b-294f-7741-bb85ed877cdf@virtuozzo.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <fbb4451f-293e-4f2d-2928-da8d8c1f7ef4@c-s.fr>
Date: Mon, 21 Jan 2019 11:36:08 +0100
MIME-Version: 1.0
In-Reply-To: <e4b343fa-702b-294f-7741-bb85ed877cdf@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org



Le 15/01/2019 à 18:23, Andrey Ryabinin a écrit :
> 
> 
> On 1/12/19 2:16 PM, Christophe Leroy wrote:
> 
>> +KASAN_SANITIZE_early_32.o := n
>> +KASAN_SANITIZE_cputable.o := n
>> +KASAN_SANITIZE_prom_init.o := n
>> +
> 
> Usually it's also good idea to disable branch profiling - define DISABLE_BRANCH_PROFILING
> either in top of these files or via Makefile. Branch profiling redefines if() statement and calls
> instrumented ftrace_likely_update in every if().
> 
> 
> 
>> diff --git a/arch/powerpc/mm/kasan_init.c b/arch/powerpc/mm/kasan_init.c
>> new file mode 100644
>> index 000000000000..3edc9c2d2f3e
> 
>> +void __init kasan_init(void)
>> +{
>> +	struct memblock_region *reg;
>> +
>> +	for_each_memblock(memory, reg)
>> +		kasan_init_region(reg);
>> +
>> +	pr_info("KASAN init done\n");
> 
> Without "init_task.kasan_depth = 0;" kasan will not repot bugs.
> 
> There is test_kasan module. Make sure that it produce reports.
> 

I get the following report with test_kasan module.

Could you have a look at it and tell if everything is as expected ?

Thanks
Christophe

[  667.298897] kasan test: kmalloc_oob_right out-of-bounds to right
[  667.299036] 
==================================================================
[  667.306263] BUG: KASAN: slab-out-of-bounds in 
kmalloc_oob_right+0x74/0x94 [test_kasan]
[  667.313929] Write of size 1 at addr c53996fb by task exe/340
[  667.319451]
[  667.321021] CPU: 0 PID: 340 Comm: exe Not tainted 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  667.321072] Call Trace:
[  667.321248] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  667.321452] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  667.321741] [c5649ce0] [c95d41d4] kmalloc_oob_right+0x74/0x94 
[test_kasan]
[  667.322022] [c5649d00] [c95d5510] kmalloc_tests_init+0x18/0x2d0 
[test_kasan]
[  667.322214] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  667.322428] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  667.322630] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  667.322834] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  667.323027] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  667.323193] --- interrupt: c01 at 0xfd6b914
[  667.323193]     LR = 0x1001364c
[  667.323239]
[  667.324561] Allocated by task 340:
[  667.327993]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  667.328241]  kmalloc_oob_right+0x44/0x94 [test_kasan]
[  667.328477]  kmalloc_tests_init+0x18/0x2d0 [test_kasan]
[  667.328622]  do_one_initcall+0x40/0x278
[  667.328792]  do_init_module+0xcc/0x59c
[  667.328948]  load_module+0x2bc4/0x320c
[  667.329107]  sys_init_module+0x114/0x138
[  667.329250]  ret_from_syscall+0x0/0x38
[  667.329298]
[  667.330580] Freed by task 335:
[  667.333667]  __kasan_slab_free+0x120/0x22c
[  667.333788]  kfree+0x74/0x270
[  667.333950]  load_elf_binary+0xb0/0x162c
[  667.334129]  search_binary_handler+0x120/0x374
[  667.334297]  __do_execve_file+0x834/0xb20
[  667.334460]  sys_execve+0x40/0x54
[  667.334605]  ret_from_syscall+0x0/0x38
[  667.334652]
[  667.335954] The buggy address belongs to the object at c5399680
[  667.335954]  which belongs to the cache kmalloc-128 of size 128
[  667.347675] The buggy address is located 123 bytes inside of
[  667.347675]  128-byte region [c5399680, c5399700)
[  667.357847] The buggy address belongs to the page:
[  667.362634] page:c7fd9cc0 count:1 mapcount:0 mapping:c5007a80 index:0x0
[  667.362745] flags: 0x200(slab)
[  667.362973] raw: 00000200 00000100 00000200 c5007a80 00000000 
005500ab ffffffff 00000001
[  667.363043] page dumped because: kasan: bad access detected
[  667.363083]
[  667.364384] Memory state around the buggy address:
[  667.369190]  c5399580: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
[  667.375645]  c5399600: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
[  667.382099] >c5399680: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03
[  667.388496]                                                         ^
[  667.394921]  c5399700: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
[  667.401377]  c5399780: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
[  667.407767] 
==================================================================
[  667.414904] Disabling lock debugging due to kernel taint
[  667.421182] kasan test: kmalloc_oob_left out-of-bounds to left
[  667.421314] 
==================================================================
[  667.428466] BUG: KASAN: slab-out-of-bounds in 
kmalloc_oob_left+0x74/0x9c [test_kasan]
[  667.436045] Read of size 1 at addr c58e9ddf by task exe/340
[  667.441483]
[  667.443064] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  667.443115] Call Trace:
[  667.443290] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  667.443492] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  667.443779] [c5649ce0] [c95d4268] kmalloc_oob_left+0x74/0x9c [test_kasan]
[  667.444057] [c5649d00] [c95d5514] kmalloc_tests_init+0x1c/0x2d0 
[test_kasan]
[  667.444246] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  667.444458] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  667.444658] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  667.444859] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  667.445051] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  667.445215] --- interrupt: c01 at 0xfd6b914
[  667.445215]     LR = 0x1001364c
[  667.445260]
[  667.446593] Allocated by task 340:
[  667.450025]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  667.450191]  do_init_module+0x2c/0x59c
[  667.450346]  load_module+0x2bc4/0x320c
[  667.450503]  sys_init_module+0x114/0x138
[  667.450645]  ret_from_syscall+0x0/0x38
[  667.450691]
[  667.452009] Freed by task 276:
[  667.455096]  __kasan_slab_free+0x120/0x22c
[  667.455214]  kfree+0x74/0x270
[  667.455344]  single_release+0x54/0x6c
[  667.455516]  close_pdeo+0x128/0x224
[  667.455680]  proc_reg_release+0x110/0x128
[  667.455811]  __fput+0xec/0x2d4
[  667.455934]  task_work_run+0x13c/0x15c
[  667.456101]  do_notify_resume+0x3d8/0x438
[  667.456248]  do_user_signal+0x2c/0x34
[  667.456294]
[  667.457641] The buggy address belongs to the object at c58e9dc0
[  667.457641]  which belongs to the cache kmalloc-16 of size 16
[  667.469191] The buggy address is located 15 bytes to the right of
[  667.469191]  16-byte region [c58e9dc0, c58e9dd0)
[  667.479708] The buggy address belongs to the page:
[  667.484495] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  667.484606] flags: 0x200(slab)
[  667.484833] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  667.484900] page dumped because: kasan: bad access detected
[  667.484940]
[  667.486244] Memory state around the buggy address:
[  667.491051]  c58e9c80: 00 00 fc fc 00 00 fc fc 00 00 fc fc 00 00 fc fc
[  667.497505]  c58e9d00: 00 00 fc fc 00 00 fc fc 00 00 fc fc 00 00 fc fc
[  667.503959] >c58e9d80: 00 00 fc fc 00 00 fc fc 00 04 fc fc 00 07 fc fc
[  667.510354]                                             ^
[  667.515748]  c58e9e00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  667.522204]  c58e9e80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  667.528595] 
==================================================================
[  667.803662] kasan test: kmalloc_node_oob_right kmalloc_node(): 
out-of-bounds to right
[  667.803806] 
==================================================================
[  667.811008] BUG: KASAN: slab-out-of-bounds in 
kmalloc_node_oob_right+0x74/0x94 [test_kasan]
[  667.819105] Write of size 1 at addr c59a4300 by task exe/340
[  667.824627]
[  667.826209] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  667.826260] Call Trace:
[  667.826436] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  667.826640] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  667.826931] [c5649ce0] [c95d4304] kmalloc_node_oob_right+0x74/0x94 
[test_kasan]
[  667.827211] [c5649d00] [c95d5518] kmalloc_tests_init+0x20/0x2d0 
[test_kasan]
[  667.827402] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  667.827616] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  667.827818] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  667.828022] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  667.828216] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  667.828382] --- interrupt: c01 at 0xfd6b914
[  667.828382]     LR = 0x1001364c
[  667.828428]
[  667.829737] Allocated by task 340:
[  667.833169]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  667.833420]  kmalloc_node_oob_right+0x44/0x94 [test_kasan]
[  667.833656]  kmalloc_tests_init+0x20/0x2d0 [test_kasan]
[  667.833801]  do_one_initcall+0x40/0x278
[  667.833970]  do_init_module+0xcc/0x59c
[  667.834125]  load_module+0x2bc4/0x320c
[  667.834284]  sys_init_module+0x114/0x138
[  667.834427]  ret_from_syscall+0x0/0x38
[  667.834475]
[  667.835756] Freed by task 319:
[  667.838843]  __kasan_slab_free+0x120/0x22c
[  667.838963]  kfree+0x74/0x270
[  667.839137]  kobject_uevent_env+0x15c/0x65c
[  667.839299]  led_trigger_set+0x3f0/0x4fc
[  667.839451]  led_trigger_store+0xd8/0x164
[  667.839593]  kernfs_fop_write+0x18c/0x218
[  667.839721]  __vfs_write+0x5c/0x258
[  667.839843]  vfs_write+0xe4/0x248
[  667.839966]  ksys_write+0x58/0xd8
[  667.840111]  ret_from_syscall+0x0/0x38
[  667.840158]
[  667.841475] The buggy address belongs to the object at c59a3300
[  667.841475]  which belongs to the cache kmalloc-4k of size 4096
[  667.853196] The buggy address is located 0 bytes to the right of
[  667.853196]  4096-byte region [c59a3300, c59a4300)
[  667.863798] The buggy address belongs to the page:
[  667.868586] page:c7fdcd00 count:1 mapcount:0 mapping:c50075a0 
index:0x0 compound_mapcount: 0
[  667.868727] flags: 0x10200(slab|head)
[  667.868956] raw: 00010200 00000100 00000200 c50075a0 00000000 
000f001f ffffffff 00000001
[  667.869025] page dumped because: kasan: bad access detected
[  667.869065]
[  667.870334] Memory state around the buggy address:
[  667.875141]  c59a4200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  667.881595]  c59a4280: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  667.888049] >c59a4300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  667.894436]            ^
[  667.896998]  c59a4380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  667.903454]  c59a4400: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  667.909845] 
==================================================================
[  667.923434] kasan test: kmalloc_pagealloc_oob_right kmalloc pagealloc 
allocation: out-of-bounds to right
[  667.923647] 
==================================================================
[  667.930896] BUG: KASAN: slab-out-of-bounds in 
kmalloc_pagealloc_oob_right+0x78/0x98 [test_kasan]
[  667.939503] Write of size 1 at addr c5bd800a by task exe/340
[  667.945024]
[  667.946607] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  667.946657] Call Trace:
[  667.946833] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  667.947035] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  667.947325] [c5649ce0] [c95d4674] 
kmalloc_pagealloc_oob_right+0x78/0x98 [test_kasan]
[  667.947603] [c5649d00] [c95d551c] kmalloc_tests_init+0x24/0x2d0 
[test_kasan]
[  667.947792] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  667.948004] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  667.948204] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  667.948406] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  667.948597] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  667.948760] --- interrupt: c01 at 0xfd6b914
[  667.948760]     LR = 0x1001364c
[  667.948806]
[  667.950115] The buggy address belongs to the page:
[  667.954903] page:c7fdde80 count:1 mapcount:0 mapping:00000000 
index:0x0 compound_mapcount: 0
[  667.955038] flags: 0x10000(head)
[  667.955260] raw: 00010000 00000100 00000200 00000000 00000000 
00000000 ffffffff 00000001
[  667.955327] page dumped because: kasan: bad access detected
[  667.955367]
[  667.956652] Memory state around the buggy address:
[  667.961458]  c5bd7f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  667.967912]  c5bd7f80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  667.974367] >c5bd8000: 00 02 fe fe fe fe fe fe fe fe fe fe fe fe fe fe
[  667.980755]               ^
[  667.983574]  c5bd8080: fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe
[  667.990030]  c5bd8100: fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe
[  667.996420] 
==================================================================
[  668.222064] kasan test: kmalloc_pagealloc_uaf kmalloc pagealloc 
allocation: use-after-free
[  668.222349] 
==================================================================
[  668.229525] BUG: KASAN: use-after-free in 
kmalloc_pagealloc_uaf+0x78/0x94 [test_kasan]
[  668.237274] Write of size 1 at addr c5bd0000 by task exe/340
[  668.242796]
[  668.244378] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  668.244429] Call Trace:
[  668.244606] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  668.244810] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  668.245100] [c5649ce0] [c95d470c] kmalloc_pagealloc_uaf+0x78/0x94 
[test_kasan]
[  668.245381] [c5649d00] [c95d5520] kmalloc_tests_init+0x28/0x2d0 
[test_kasan]
[  668.245573] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  668.245787] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  668.245989] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  668.246192] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  668.246386] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  668.246552] --- interrupt: c01 at 0xfd6b914
[  668.246552]     LR = 0x1001364c
[  668.246598]
[  668.247886] The buggy address belongs to the page:
[  668.252671] page:c7fdde80 count:0 mapcount:-128 mapping:00000000 
index:0x0
[  668.252769] flags: 0x0()
[  668.252994] raw: 00000000 c7fdcf84 c0982ae8 00000000 00000000 
00000002 ffffff7f 00000000
[  668.253062] page dumped because: kasan: bad access detected
[  668.253102]
[  668.254337] Memory state around the buggy address:
[  668.259143]  c5bcff00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  668.265597]  c5bcff80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  668.272052] >c5bd0000: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[  668.278439]            ^
[  668.281001]  c5bd0080: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[  668.287458]  c5bd0100: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[  668.293847] 
==================================================================
[  668.310744] kasan test: kmalloc_pagealloc_invalid_free kmalloc 
pagealloc allocation: invalid-free
[  668.310957] 
==================================================================
[  668.318156] BUG: KASAN: double-free or invalid-free in 
kmalloc_tests_init+0x2c/0x2d0 [test_kasan]
[  668.326705]
[  668.328286] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  668.328337] Call Trace:
[  668.328512] [c5649c80] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  668.328724] [c5649cb0] [c0176c24] kasan_report_invalid_free+0x48/0x74
[  668.328888] [c5649ce0] [c0173c14] kfree+0x1f8/0x270
[  668.329176] [c5649d00] [c95d5524] kmalloc_tests_init+0x2c/0x2d0 
[test_kasan]
[  668.329365] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  668.329577] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  668.329777] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  668.329978] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  668.330170] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  668.330334] --- interrupt: c01 at 0xfd6b914
[  668.330334]     LR = 0x1001364c
[  668.330379]
[  668.331622] The buggy address belongs to the page:
[  668.336410] page:c7fdde80 count:1 mapcount:0 mapping:00000000 
index:0x0 compound_mapcount: 0
[  668.336545] flags: 0x10000(head)
[  668.336767] raw: 00010000 00000100 00000200 00000000 00000000 
00000000 ffffffff 00000001
[  668.336834] page dumped because: kasan: bad access detected
[  668.336873]
[  668.338158] Memory state around the buggy address:
[  668.342965]  c5bcff00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  668.349419]  c5bcff80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  668.355874] >c5bd0000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  668.362260]            ^
[  668.364822]  c5bd0080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  668.371279]  c5bd0100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  668.377668] 
==================================================================
[  668.528086] kasan test: kmalloc_large_oob_right kmalloc large 
allocation: out-of-bounds to right
[  668.528279] 
==================================================================
[  668.535471] BUG: KASAN: slab-out-of-bounds in 
kmalloc_large_oob_right+0x74/0x94 [test_kasan]
[  668.543735] Write of size 1 at addr c5498700 by task exe/340
[  668.549257]
[  668.550840] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  668.550891] Call Trace:
[  668.551068] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  668.551272] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  668.551561] [c5649ce0] [c95d4398] kmalloc_large_oob_right+0x74/0x94 
[test_kasan]
[  668.551842] [c5649d00] [c95d5528] kmalloc_tests_init+0x30/0x2d0 
[test_kasan]
[  668.552034] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  668.552248] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  668.552450] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  668.552655] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  668.552848] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  668.553013] --- interrupt: c01 at 0xfd6b914
[  668.553013]     LR = 0x1001364c
[  668.553059]
[  668.554367] Allocated by task 340:
[  668.557799]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  668.558049]  kmalloc_large_oob_right+0x44/0x94 [test_kasan]
[  668.558285]  kmalloc_tests_init+0x30/0x2d0 [test_kasan]
[  668.558430]  do_one_initcall+0x40/0x278
[  668.558599]  do_init_module+0xcc/0x59c
[  668.558756]  load_module+0x2bc4/0x320c
[  668.558915]  sys_init_module+0x114/0x138
[  668.559058]  ret_from_syscall+0x0/0x38
[  668.559106]
[  668.560386] Freed by task 173:
[  668.563473]  __kasan_slab_free+0x120/0x22c
[  668.563595]  kfree+0x74/0x270
[  668.563763]  consume_skb+0x38/0x138
[  668.563935]  skb_free_datagram+0x1c/0x80
[  668.564104]  netlink_recvmsg+0x1d0/0x4d4
[  668.564270]  ___sys_recvmsg+0xd8/0x194
[  668.564436]  __sys_recvmsg+0x40/0x8c
[  668.564563]  sys_socketcall+0xf8/0x210
[  668.564709]  ret_from_syscall+0x0/0x38
[  668.564756]
[  668.566106] The buggy address belongs to the object at c5490800
[  668.566106]  which belongs to the cache kmalloc-32k of size 32768
[  668.578000] The buggy address is located 32512 bytes inside of
[  668.578000]  32768-byte region [c5490800, c5498800)
[  668.588514] The buggy address belongs to the page:
[  668.593302] page:c7fda400 count:1 mapcount:0 mapping:c5007330 
index:0x0 compound_mapcount: 0
[  668.593443] flags: 0x10200(slab|head)
[  668.593672] raw: 00010200 00000100 00000200 c5007330 00000000 
00030007 ffffffff 00000001
[  668.593741] page dumped because: kasan: bad access detected
[  668.593781]
[  668.595051] Memory state around the buggy address:
[  668.599857]  c5498600: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  668.606311]  c5498680: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  668.612765] >c5498700: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  668.619152]            ^
[  668.621714]  c5498780: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  668.628171]  c5498800: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  668.634561] 
==================================================================
[  668.645940] kasan test: kmalloc_oob_krealloc_more out-of-bounds after 
krealloc more
[  668.646103] 
==================================================================
[  668.653286] BUG: KASAN: slab-out-of-bounds in 
kmalloc_oob_krealloc_more+0x8c/0xac [test_kasan]
[  668.661723] Write of size 1 at addr c53e8ca3 by task exe/340
[  668.667245]
[  668.668827] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  668.668877] Call Trace:
[  668.669052] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  668.669254] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  668.669543] [c5649ce0] [c95d4838] kmalloc_oob_krealloc_more+0x8c/0xac 
[test_kasan]
[  668.669823] [c5649d00] [c95d552c] kmalloc_tests_init+0x34/0x2d0 
[test_kasan]
[  668.670012] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  668.670225] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  668.670426] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  668.670627] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  668.670819] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  668.670982] --- interrupt: c01 at 0xfd6b914
[  668.670982]     LR = 0x1001364c
[  668.671027]
[  668.672354] Allocated by task 340:
[  668.675786]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  668.675935]  krealloc+0xb0/0xe8
[  668.676185]  kmalloc_oob_krealloc_more+0x58/0xac [test_kasan]
[  668.676419]  kmalloc_tests_init+0x34/0x2d0 [test_kasan]
[  668.676563]  do_one_initcall+0x40/0x278
[  668.676730]  do_init_module+0xcc/0x59c
[  668.676885]  load_module+0x2bc4/0x320c
[  668.677042]  sys_init_module+0x114/0x138
[  668.677185]  ret_from_syscall+0x0/0x38
[  668.677231]
[  668.678543] Freed by task 0:
[  668.681460]  __kasan_slab_free+0x120/0x22c
[  668.681579]  kfree+0x74/0x270
[  668.681726]  rcu_process_callbacks+0x384/0x620
[  668.681858]  __do_softirq+0x134/0x48c
[  668.681904]
[  668.683231] The buggy address belongs to the object at c53e8c90
[  668.683231]  which belongs to the cache kmalloc-32 of size 32
[  668.694778] The buggy address is located 19 bytes inside of
[  668.694778]  32-byte region [c53e8c90, c53e8cb0)
[  668.704780] The buggy address belongs to the page:
[  668.709568] page:c7fd9f40 count:1 mapcount:0 mapping:c5007cf0 index:0x0
[  668.709676] flags: 0x200(slab)
[  668.709903] raw: 00000200 00000100 00000200 c5007cf0 00000000 
015502ab ffffffff 00000001
[  668.709970] page dumped because: kasan: bad access detected
[  668.710010]
[  668.711317] Memory state around the buggy address:
[  668.716124]  c53e8b80: 00 fc fc fc 00 00 00 fc fc fc fb fb fb fb fc fc
[  668.722579]  c53e8c00: 00 00 00 04 fc fc 00 00 00 04 fc fc 00 00 00 00
[  668.729033] >c53e8c80: fc fc 00 00 03 fc fc fc 00 00 00 00 fc fc 00 00
[  668.735421]                        ^
[  668.739014]  c53e8d00: 00 00 fc fc 00 00 00 00 fc fc 00 00 00 00 fc fc
[  668.745470]  c53e8d80: 00 00 00 00 fc fc 00 00 00 00 fc fc 00 00 00 00
[  668.751860] 
==================================================================
[  669.016775] kasan test: kmalloc_oob_krealloc_less out-of-bounds after 
krealloc less
[  669.016942] 
==================================================================
[  669.024120] BUG: KASAN: slab-out-of-bounds in 
kmalloc_oob_krealloc_less+0x8c/0xac [test_kasan]
[  669.032474] Write of size 1 at addr c53e8bdf by task exe/340
[  669.037995]
[  669.039577] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  669.039628] Call Trace:
[  669.039803] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  669.040007] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  669.040299] [c5649ce0] [c95d48e4] kmalloc_oob_krealloc_less+0x8c/0xac 
[test_kasan]
[  669.040580] [c5649d00] [c95d5530] kmalloc_tests_init+0x38/0x2d0 
[test_kasan]
[  669.040771] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  669.040984] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  669.041187] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  669.041390] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  669.041584] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  669.041750] --- interrupt: c01 at 0xfd6b914
[  669.041750]     LR = 0x1001364c
[  669.041796]
[  669.043105] Allocated by task 340:
[  669.046537]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  669.046687]  krealloc+0xb0/0xe8
[  669.046940]  kmalloc_oob_krealloc_less+0x58/0xac [test_kasan]
[  669.047176]  kmalloc_tests_init+0x38/0x2d0 [test_kasan]
[  669.047321]  do_one_initcall+0x40/0x278
[  669.047491]  do_init_module+0xcc/0x59c
[  669.047648]  load_module+0x2bc4/0x320c
[  669.047806]  sys_init_module+0x114/0x138
[  669.047951]  ret_from_syscall+0x0/0x38
[  669.047998]
[  669.049294] Freed by task 0:
[  669.052211]  __kasan_slab_free+0x120/0x22c
[  669.052332]  kfree+0x74/0x270
[  669.052479]  rcu_process_callbacks+0x384/0x620
[  669.052612]  __do_softirq+0x134/0x48c
[  669.052659]
[  669.053981] The buggy address belongs to the object at c53e8bd0
[  669.053981]  which belongs to the cache kmalloc-32 of size 32
[  669.065529] The buggy address is located 15 bytes inside of
[  669.065529]  32-byte region [c53e8bd0, c53e8bf0)
[  669.075531] The buggy address belongs to the page:
[  669.080318] page:c7fd9f40 count:1 mapcount:0 mapping:c5007cf0 index:0x0
[  669.080428] flags: 0x200(slab)
[  669.080655] raw: 00000200 00000100 00000200 c5007cf0 00000000 
015502ab ffffffff 00000001
[  669.080724] page dumped because: kasan: bad access detected
[  669.080764]
[  669.082068] Memory state around the buggy address:
[  669.086874]  c53e8a80: 00 00 00 fc fc fc 00 00 00 fc fc fc 00 00 00 00
[  669.093328]  c53e8b00: fc fc 00 00 00 fc fc fc 00 00 00 fc fc fc 00 00
[  669.099783] >c53e8b80: 00 fc fc fc 00 00 00 fc fc fc 00 07 fc fc fc fc
[  669.106177]                                             ^
[  669.111572]  c53e8c00: 00 00 00 04 fc fc 00 00 00 04 fc fc 00 00 00 00
[  669.118028]  c53e8c80: fc fc fb fb fb fb fc fc 00 00 00 00 fc fc 00 00
[  669.124418] 
==================================================================
[  669.137359] kasan test: kmalloc_oob_16 kmalloc out-of-bounds for 
16-bytes access
[  669.137538] 
==================================================================
[  669.144772] BUG: KASAN: slab-out-of-bounds in 
kmalloc_oob_16+0x94/0xdc [test_kasan]
[  669.152181] Write of size 16 at addr c58eada0 by task exe/340
[  669.157790]
[  669.159371] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  669.159421] Call Trace:
[  669.159597] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  669.159799] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  669.160086] [c5649ce0] [c95d444c] kmalloc_oob_16+0x94/0xdc [test_kasan]
[  669.160365] [c5649d00] [c95d5534] kmalloc_tests_init+0x3c/0x2d0 
[test_kasan]
[  669.160554] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  669.160765] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  669.160966] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  669.161167] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  669.161360] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  669.161523] --- interrupt: c01 at 0xfd6b914
[  669.161523]     LR = 0x1001364c
[  669.161569]
[  669.162900] Allocated by task 340:
[  669.166332]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  669.166578]  kmalloc_oob_16+0x48/0xdc [test_kasan]
[  669.166812]  kmalloc_tests_init+0x3c/0x2d0 [test_kasan]
[  669.166955]  do_one_initcall+0x40/0x278
[  669.167121]  do_init_module+0xcc/0x59c
[  669.167275]  load_module+0x2bc4/0x320c
[  669.167432]  sys_init_module+0x114/0x138
[  669.167575]  ret_from_syscall+0x0/0x38
[  669.167620]
[  669.168919] Freed by task 338:
[  669.172004]  __kasan_slab_free+0x120/0x22c
[  669.172122]  kfree+0x74/0x270
[  669.172264]  walk_component+0x150/0x478
[  669.172399]  link_path_walk+0x374/0x63c
[  669.172535]  path_openat+0xe4/0x15f8
[  669.172674]  do_filp_open+0xd0/0x120
[  669.172843]  do_open_execat+0x64/0x264
[  669.173010]  __do_execve_file+0xa0c/0xb20
[  669.173172]  sys_execve+0x40/0x54
[  669.173318]  ret_from_syscall+0x0/0x38
[  669.173364]
[  669.174722] The buggy address belongs to the object at c58eada0
[  669.174722]  which belongs to the cache kmalloc-16 of size 16
[  669.186269] The buggy address is located 0 bytes inside of
[  669.186269]  16-byte region [c58eada0, c58eadb0)
[  669.196187] The buggy address belongs to the page:
[  669.200974] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  669.201083] flags: 0x200(slab)
[  669.201310] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  669.201378] page dumped because: kasan: bad access detected
[  669.201417]
[  669.202723] Memory state around the buggy address:
[  669.207530]  c58eac80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  669.213984]  c58ead00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  669.220438] >c58ead80: fb fb fc fc 00 05 fc fc 00 00 fc fc fb fb fc fc
[  669.226828]                           ^
[  669.230678]  c58eae00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  669.237134]  c58eae80: fb fb fc fc fb fb fc fc fb fb fc fc 00 04 fc fc
[  669.243524] 
==================================================================
[  669.521937] kasan test: kmalloc_oob_in_memset out-of-bounds in memset
[  669.522086] 
==================================================================
[  669.529294] BUG: KASAN: slab-out-of-bounds in 
kmalloc_oob_in_memset+0x78/0x90 [test_kasan]
[  669.537306] Write of size 671 at addr c5881b00 by task exe/340
[  669.543000]
[  669.544581] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  669.544632] Call Trace:
[  669.544808] [c5649c50] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  669.545012] [c5649c80] [c0176d34] kasan_report+0xe4/0x168
[  669.545186] [c5649cc0] [c0175700] memset+0x2c/0x4c
[  669.545477] [c5649ce0] [c95d497c] kmalloc_oob_in_memset+0x78/0x90 
[test_kasan]
[  669.545759] [c5649d00] [c95d5538] kmalloc_tests_init+0x40/0x2d0 
[test_kasan]
[  669.545949] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  669.546163] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  669.546366] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  669.546570] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  669.546764] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  669.546929] --- interrupt: c01 at 0xfd6b914
[  669.546929]     LR = 0x1001364c
[  669.546976]
[  669.548281] Allocated by task 340:
[  669.551713]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  669.551963]  kmalloc_oob_in_memset+0x44/0x90 [test_kasan]
[  669.552199]  kmalloc_tests_init+0x40/0x2d0 [test_kasan]
[  669.552346]  do_one_initcall+0x40/0x278
[  669.552515]  do_init_module+0xcc/0x59c
[  669.552672]  load_module+0x2bc4/0x320c
[  669.552831]  sys_init_module+0x114/0x138
[  669.552976]  ret_from_syscall+0x0/0x38
[  669.553023]
[  669.554300] Freed by task 131:
[  669.557387]  __kasan_slab_free+0x120/0x22c
[  669.557508]  kfree+0x74/0x270
[  669.557682]  pskb_expand_head+0x2b0/0x434
[  669.557843]  netlink_trim+0xfc/0x114
[  669.558009]  netlink_broadcast_filtered+0x48/0x530
[  669.558169]  nlmsg_notify+0x7c/0x128
[  669.558330]  fib6_add+0xd44/0x11d4
[  669.558461]  __ip6_ins_rt+0x5c/0x88
[  669.558598]  ip6_ins_rt+0x34/0x44
[  669.558777]  __ipv6_ifa_notify+0x388/0x38c
[  669.558945]  ipv6_ifa_notify+0x68/0x88
[  669.559076]  addrconf_dad_completed+0x54/0x49c
[  669.559201]  addrconf_dad_work+0x558/0x84c
[  669.559369]  process_one_work+0x408/0x78c
[  669.559524]  worker_thread+0xb4/0x83c
[  669.559657]  kthread+0x144/0x184
[  669.559811]  ret_from_kernel_thread+0x14/0x1c
[  669.559858]
[  669.561223] The buggy address belongs to the object at c5881b00
[  669.561223]  which belongs to the cache kmalloc-1k of size 1024
[  669.572943] The buggy address is located 0 bytes inside of
[  669.572943]  1024-byte region [c5881b00, c5881f00)
[  669.583031] The buggy address belongs to the page:
[  669.587818] page:c7fdc400 count:1 mapcount:0 mapping:c5007740 index:0x0
[  669.587929] flags: 0x200(slab)
[  669.588156] raw: 00000200 00000100 00000200 c5007740 00000000 
000e001d ffffffff 00000001
[  669.588225] page dumped because: kasan: bad access detected
[  669.588265]
[  669.589567] Memory state around the buggy address:
[  669.594374]  c5881c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  669.600828]  c5881d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  669.607282] >c5881d80: 00 00 00 02 fc fc fc fc fc fc fc fc fc fc fc fc
[  669.613671]                     ^
[  669.617005]  c5881e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  669.623462]  c5881e80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  669.629852] 
==================================================================
[  669.643287] kasan test: kmalloc_oob_memset_2 out-of-bounds in memset2
[  669.643423] 
==================================================================
[  669.650641] BUG: KASAN: slab-out-of-bounds in 
kmalloc_oob_memset_2+0x7c/0x94 [test_kasan]
[  669.658563] Write of size 2 at addr c58eae07 by task exe/340
[  669.664085]
[  669.665668] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  669.665718] Call Trace:
[  669.665891] [c5649c50] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  669.666095] [c5649c80] [c0176d34] kasan_report+0xe4/0x168
[  669.666267] [c5649cc0] [c0175700] memset+0x2c/0x4c
[  669.666556] [c5649ce0] [c95d4a10] kmalloc_oob_memset_2+0x7c/0x94 
[test_kasan]
[  669.666836] [c5649d00] [c95d553c] kmalloc_tests_init+0x44/0x2d0 
[test_kasan]
[  669.667026] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  669.667239] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  669.667440] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  669.667643] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  669.667836] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  669.668002] --- interrupt: c01 at 0xfd6b914
[  669.668002]     LR = 0x1001364c
[  669.668046]
[  669.669366] Allocated by task 340:
[  669.672799]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  669.673048]  kmalloc_oob_memset_2+0x44/0x94 [test_kasan]
[  669.673283]  kmalloc_tests_init+0x44/0x2d0 [test_kasan]
[  669.673426]  do_one_initcall+0x40/0x278
[  669.673594]  do_init_module+0xcc/0x59c
[  669.673750]  load_module+0x2bc4/0x320c
[  669.673909]  sys_init_module+0x114/0x138
[  669.674051]  ret_from_syscall+0x0/0x38
[  669.674098]
[  669.675387] Freed by task 276:
[  669.678473]  __kasan_slab_free+0x120/0x22c
[  669.678594]  kfree+0x74/0x270
[  669.678724]  single_release+0x54/0x6c
[  669.678897]  close_pdeo+0x128/0x224
[  669.679064]  proc_reg_release+0x110/0x128
[  669.679197]  __fput+0xec/0x2d4
[  669.679320]  task_work_run+0x13c/0x15c
[  669.679487]  do_notify_resume+0x3d8/0x438
[  669.679636]  do_user_signal+0x2c/0x34
[  669.679682]
[  669.681018] The buggy address belongs to the object at c58eae00
[  669.681018]  which belongs to the cache kmalloc-16 of size 16
[  669.692565] The buggy address is located 7 bytes inside of
[  669.692565]  16-byte region [c58eae00, c58eae10)
[  669.702482] The buggy address belongs to the page:
[  669.707268] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  669.707380] flags: 0x200(slab)
[  669.707607] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  669.707674] page dumped because: kasan: bad access detected
[  669.707713]
[  669.709018] Memory state around the buggy address:
[  669.713825]  c58ead00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  669.720279]  c58ead80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  669.726734] >c58eae00: 00 fc fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  669.733120]               ^
[  669.735941]  c58eae80: fb fb fc fc fb fb fc fc fb fb fc fc 00 04 fc fc
[  669.742397]  c58eaf00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  669.748787] 
==================================================================
[  670.056503] kasan test: kmalloc_oob_memset_4 out-of-bounds in memset4
[  670.056640] 
==================================================================
[  670.063818] BUG: KASAN: slab-out-of-bounds in 
kmalloc_oob_memset_4+0x7c/0x94 [test_kasan]
[  670.071743] Write of size 4 at addr c58eae25 by task exe/340
[  670.077263]
[  670.078847] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  670.078898] Call Trace:
[  670.079074] [c5649c50] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  670.079279] [c5649c80] [c0176d34] kasan_report+0xe4/0x168
[  670.079452] [c5649cc0] [c0175700] memset+0x2c/0x4c
[  670.079743] [c5649ce0] [c95d4aa4] kmalloc_oob_memset_4+0x7c/0x94 
[test_kasan]
[  670.080025] [c5649d00] [c95d5540] kmalloc_tests_init+0x48/0x2d0 
[test_kasan]
[  670.080216] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  670.080431] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  670.080635] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  670.080839] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  670.081034] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  670.081201] --- interrupt: c01 at 0xfd6b914
[  670.081201]     LR = 0x1001364c
[  670.081247]
[  670.082546] Allocated by task 340:
[  670.085978]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  670.086229]  kmalloc_oob_memset_4+0x44/0x94 [test_kasan]
[  670.086465]  kmalloc_tests_init+0x48/0x2d0 [test_kasan]
[  670.086611]  do_one_initcall+0x40/0x278
[  670.086782]  do_init_module+0xcc/0x59c
[  670.086941]  load_module+0x2bc4/0x320c
[  670.087101]  sys_init_module+0x114/0x138
[  670.087246]  ret_from_syscall+0x0/0x38
[  670.087293]
[  670.088563] Freed by task 276:
[  670.091652]  __kasan_slab_free+0x120/0x22c
[  670.091774]  kfree+0x74/0x270
[  670.091906]  single_release+0x54/0x6c
[  670.092080]  close_pdeo+0x128/0x224
[  670.092249]  proc_reg_release+0x110/0x128
[  670.092383]  __fput+0xec/0x2d4
[  670.092509]  task_work_run+0x13c/0x15c
[  670.092678]  do_notify_resume+0x3d8/0x438
[  670.092828]  do_user_signal+0x2c/0x34
[  670.092874]
[  670.094198] The buggy address belongs to the object at c58eae20
[  670.094198]  which belongs to the cache kmalloc-16 of size 16
[  670.105743] The buggy address is located 5 bytes inside of
[  670.105743]  16-byte region [c58eae20, c58eae30)
[  670.115660] The buggy address belongs to the page:
[  670.120447] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  670.120560] flags: 0x200(slab)
[  670.120789] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  670.120858] page dumped because: kasan: bad access detected
[  670.120899]
[  670.122198] Memory state around the buggy address:
[  670.127004]  c58ead00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.133458]  c58ead80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.139912] >c58eae00: fb fb fc fc 00 fc fc fc fb fb fc fc fb fb fc fc
[  670.146302]                           ^
[  670.150152]  c58eae80: fb fb fc fc fb fb fc fc fb fb fc fc 00 04 fc fc
[  670.156608]  c58eaf00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.162998] 
==================================================================
[  670.176210] kasan test: kmalloc_oob_memset_8 out-of-bounds in memset8
[  670.176342] 
==================================================================
[  670.183528] BUG: KASAN: slab-out-of-bounds in 
kmalloc_oob_memset_8+0x7c/0x94 [test_kasan]
[  670.191450] Write of size 8 at addr c58eae41 by task exe/340
[  670.196972]
[  670.198555] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  670.198605] Call Trace:
[  670.198779] [c5649c50] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  670.198982] [c5649c80] [c0176d34] kasan_report+0xe4/0x168
[  670.199153] [c5649cc0] [c0175700] memset+0x2c/0x4c
[  670.199443] [c5649ce0] [c95d4b38] kmalloc_oob_memset_8+0x7c/0x94 
[test_kasan]
[  670.199722] [c5649d00] [c95d5544] kmalloc_tests_init+0x4c/0x2d0 
[test_kasan]
[  670.199912] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  670.200125] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  670.200327] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  670.200530] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  670.200723] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  670.200887] --- interrupt: c01 at 0xfd6b914
[  670.200887]     LR = 0x1001364c
[  670.200931]
[  670.202255] Allocated by task 340:
[  670.205686]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  670.205934]  kmalloc_oob_memset_8+0x44/0x94 [test_kasan]
[  670.206168]  kmalloc_tests_init+0x4c/0x2d0 [test_kasan]
[  670.206312]  do_one_initcall+0x40/0x278
[  670.206480]  do_init_module+0xcc/0x59c
[  670.206637]  load_module+0x2bc4/0x320c
[  670.206794]  sys_init_module+0x114/0x138
[  670.206937]  ret_from_syscall+0x0/0x38
[  670.206983]
[  670.208274] Freed by task 276:
[  670.211360]  __kasan_slab_free+0x120/0x22c
[  670.211479]  kfree+0x74/0x270
[  670.211611]  single_release+0x54/0x6c
[  670.211782]  close_pdeo+0x128/0x224
[  670.211947]  proc_reg_release+0x110/0x128
[  670.212079]  __fput+0xec/0x2d4
[  670.212202]  task_work_run+0x13c/0x15c
[  670.212368]  do_notify_resume+0x3d8/0x438
[  670.212515]  do_user_signal+0x2c/0x34
[  670.212561]
[  670.213904] The buggy address belongs to the object at c58eae40
[  670.213904]  which belongs to the cache kmalloc-16 of size 16
[  670.225452] The buggy address is located 1 bytes inside of
[  670.225452]  16-byte region [c58eae40, c58eae50)
[  670.235368] The buggy address belongs to the page:
[  670.240155] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  670.240265] flags: 0x200(slab)
[  670.240493] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  670.240560] page dumped because: kasan: bad access detected
[  670.240599]
[  670.241906] Memory state around the buggy address:
[  670.246712]  c58ead00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.253167]  c58ead80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.259621] >c58eae00: fb fb fc fc fb fb fc fc 00 fc fc fc fb fb fc fc
[  670.266014]                                       ^
[  670.270894]  c58eae80: fb fb fc fc fb fb fc fc fb fb fc fc 00 04 fc fc
[  670.277349]  c58eaf00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.283740] 
==================================================================
[  670.574861] kasan test: kmalloc_oob_memset_16 out-of-bounds in memset16
[  670.574999] 
==================================================================
[  670.582162] BUG: KASAN: slab-out-of-bounds in 
kmalloc_oob_memset_16+0x7c/0x94 [test_kasan]
[  670.590260] Write of size 16 at addr c58eae81 by task exe/340
[  670.595865]
[  670.597448] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  670.597499] Call Trace:
[  670.597674] [c5649c50] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  670.597880] [c5649c80] [c0176d34] kasan_report+0xe4/0x168
[  670.598053] [c5649cc0] [c0175700] memset+0x2c/0x4c
[  670.598344] [c5649ce0] [c95d4bcc] kmalloc_oob_memset_16+0x7c/0x94 
[test_kasan]
[  670.598626] [c5649d00] [c95d5548] kmalloc_tests_init+0x50/0x2d0 
[test_kasan]
[  670.598816] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  670.599031] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  670.599234] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  670.599439] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  670.599634] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  670.599801] --- interrupt: c01 at 0xfd6b914
[  670.599801]     LR = 0x1001364c
[  670.599847]
[  670.601148] Allocated by task 340:
[  670.604580]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  670.604834]  kmalloc_oob_memset_16+0x44/0x94 [test_kasan]
[  670.605070]  kmalloc_tests_init+0x50/0x2d0 [test_kasan]
[  670.605215]  do_one_initcall+0x40/0x278
[  670.605385]  do_init_module+0xcc/0x59c
[  670.605543]  load_module+0x2bc4/0x320c
[  670.605704]  sys_init_module+0x114/0x138
[  670.605851]  ret_from_syscall+0x0/0x38
[  670.605897]
[  670.607166] Freed by task 276:
[  670.610253]  __kasan_slab_free+0x120/0x22c
[  670.610374]  kfree+0x74/0x270
[  670.610506]  single_release+0x54/0x6c
[  670.610681]  close_pdeo+0x128/0x224
[  670.610849]  proc_reg_release+0x110/0x128
[  670.610983]  __fput+0xec/0x2d4
[  670.611107]  task_work_run+0x13c/0x15c
[  670.611275]  do_notify_resume+0x3d8/0x438
[  670.611424]  do_user_signal+0x2c/0x34
[  670.611471]
[  670.612798] The buggy address belongs to the object at c58eae80
[  670.612798]  which belongs to the cache kmalloc-16 of size 16
[  670.624345] The buggy address is located 1 bytes inside of
[  670.624345]  16-byte region [c58eae80, c58eae90)
[  670.634260] The buggy address belongs to the page:
[  670.639048] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  670.639158] flags: 0x200(slab)
[  670.639387] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  670.639457] page dumped because: kasan: bad access detected
[  670.639497]
[  670.640799] Memory state around the buggy address:
[  670.645604]  c58ead80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.652058]  c58eae00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.658513] >c58eae80: 00 00 fc fc fb fb fc fc fb fb fc fc 00 04 fc fc
[  670.664901]                  ^
[  670.667978]  c58eaf00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.674434]  c58eaf80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.680825] 
==================================================================
[  670.693766] kasan test: kmalloc_uaf use-after-free
[  670.693923] 
==================================================================
[  670.701091] BUG: KASAN: use-after-free in kmalloc_uaf+0x78/0x94 
[test_kasan]
[  670.707899] Write of size 1 at addr c58eaea8 by task exe/340
[  670.713422]
[  670.715004] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  670.715055] Call Trace:
[  670.715229] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  670.715433] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  670.715719] [c5649ce0] [c95d450c] kmalloc_uaf+0x78/0x94 [test_kasan]
[  670.715997] [c5649d00] [c95d554c] kmalloc_tests_init+0x54/0x2d0 
[test_kasan]
[  670.716187] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  670.716400] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  670.716601] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  670.716804] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  670.716998] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  670.717164] --- interrupt: c01 at 0xfd6b914
[  670.717164]     LR = 0x1001364c
[  670.717209]
[  670.718531] Allocated by task 340:
[  670.721965]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  670.722210]  kmalloc_uaf+0x44/0x94 [test_kasan]
[  670.722446]  kmalloc_tests_init+0x54/0x2d0 [test_kasan]
[  670.722588]  do_one_initcall+0x40/0x278
[  670.722756]  do_init_module+0xcc/0x59c
[  670.722912]  load_module+0x2bc4/0x320c
[  670.723069]  sys_init_module+0x114/0x138
[  670.723213]  ret_from_syscall+0x0/0x38
[  670.723260]
[  670.724550] Freed by task 340:
[  670.727635]  __kasan_slab_free+0x120/0x22c
[  670.727754]  kfree+0x74/0x270
[  670.727998]  kmalloc_uaf+0x70/0x94 [test_kasan]
[  670.728233]  kmalloc_tests_init+0x54/0x2d0 [test_kasan]
[  670.728375]  do_one_initcall+0x40/0x278
[  670.728543]  do_init_module+0xcc/0x59c
[  670.728698]  load_module+0x2bc4/0x320c
[  670.728855]  sys_init_module+0x114/0x138
[  670.728998]  ret_from_syscall+0x0/0x38
[  670.729044]
[  670.730356] The buggy address belongs to the object at c58eaea0
[  670.730356]  which belongs to the cache kmalloc-16 of size 16
[  670.741901] The buggy address is located 8 bytes inside of
[  670.741901]  16-byte region [c58eaea0, c58eaeb0)
[  670.751818] The buggy address belongs to the page:
[  670.756605] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  670.756716] flags: 0x200(slab)
[  670.756944] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  670.757012] page dumped because: kasan: bad access detected
[  670.757052]
[  670.758354] Memory state around the buggy address:
[  670.763163]  c58ead80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.769616]  c58eae00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.776070] >c58eae80: fb fb fc fc fb fb fc fc fb fb fc fc 00 04 fc fc
[  670.782461]                           ^
[  670.786311]  c58eaf00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.792765]  c58eaf80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  670.799157] 
==================================================================
[  671.084949] kasan test: kmalloc_uaf_memset use-after-free in memset
[  671.085122] 
==================================================================
[  671.092328] BUG: KASAN: use-after-free in 
kmalloc_tests_init+0x58/0x2d0 [test_kasan]
[  671.099824] Write of size 33 at addr c534b0c0 by task exe/340
[  671.105430]
[  671.107012] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  671.107063] Call Trace:
[  671.107238] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  671.107443] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  671.107616] [c5649ce0] [c0175700] memset+0x2c/0x4c
[  671.107907] [c5649d00] [c95d5550] kmalloc_tests_init+0x58/0x2d0 
[test_kasan]
[  671.108098] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  671.108314] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  671.108518] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  671.108724] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  671.108918] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  671.109085] --- interrupt: c01 at 0xfd6b914
[  671.109085]     LR = 0x1001364c
[  671.109132]
[  671.110452] Allocated by task 340:
[  671.113886]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  671.114137]  kmalloc_uaf_memset+0x44/0x90 [test_kasan]
[  671.114374]  kmalloc_tests_init+0x58/0x2d0 [test_kasan]
[  671.114520]  do_one_initcall+0x40/0x278
[  671.114689]  do_init_module+0xcc/0x59c
[  671.114846]  load_module+0x2bc4/0x320c
[  671.115005]  sys_init_module+0x114/0x138
[  671.115151]  ret_from_syscall+0x0/0x38
[  671.115198]
[  671.116472] Freed by task 340:
[  671.119559]  __kasan_slab_free+0x120/0x22c
[  671.119681]  kfree+0x74/0x270
[  671.119927]  kmalloc_uaf_memset+0x70/0x90 [test_kasan]
[  671.120167]  kmalloc_tests_init+0x58/0x2d0 [test_kasan]
[  671.120312]  do_one_initcall+0x40/0x278
[  671.120481]  do_init_module+0xcc/0x59c
[  671.120640]  load_module+0x2bc4/0x320c
[  671.120801]  sys_init_module+0x114/0x138
[  671.120945]  ret_from_syscall+0x0/0x38
[  671.120992]
[  671.122276] The buggy address belongs to the object at c534b0c0
[  671.122276]  which belongs to the cache kmalloc-64 of size 64
[  671.133824] The buggy address is located 0 bytes inside of
[  671.133824]  64-byte region [c534b0c0, c534b100)
[  671.143741] The buggy address belongs to the page:
[  671.148527] page:c7fd9a40 count:1 mapcount:0 mapping:c5007c20 index:0x0
[  671.148637] flags: 0x200(slab)
[  671.148866] raw: 00000200 00000100 00000200 c5007c20 00000000 
00aa0155 ffffffff 00000001
[  671.148935] page dumped because: kasan: bad access detected
[  671.148975]
[  671.150277] Memory state around the buggy address:
[  671.155084]  c534af80: fc fc fc fc 00 00 00 00 04 fc fc fc fc fc fc fc
[  671.161538]  c534b000: 00 00 00 00 00 00 fc fc fc fc fc fc fb fb fb fb
[  671.167993] >c534b080: fb fb fb fb fc fc fc fc fb fb fb fb fb fb fb fb
[  671.174383]                                    ^
[  671.179007]  c534b100: fc fc fc fc 00 00 00 00 04 fc fc fc fc fc fc fc
[  671.185461]  c534b180: 00 00 00 00 04 fc fc fc fc fc fc fc fb fb fb fb
[  671.191853] 
==================================================================
[  671.204460] kasan test: kmalloc_uaf2 use-after-free after another kmalloc
[  671.204676] 
==================================================================
[  671.211859] BUG: KASAN: use-after-free in kmalloc_uaf2+0x9c/0xd4 
[test_kasan]
[  671.218755] Write of size 1 at addr c534b088 by task exe/340
[  671.224277]
[  671.225860] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  671.225910] Call Trace:
[  671.226085] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  671.226288] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  671.226574] [c5649ce0] [c95d45c4] kmalloc_uaf2+0x9c/0xd4 [test_kasan]
[  671.226854] [c5649d00] [c95d5554] kmalloc_tests_init+0x5c/0x2d0 
[test_kasan]
[  671.227044] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  671.227257] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  671.227458] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  671.227659] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  671.227853] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  671.228018] --- interrupt: c01 at 0xfd6b914
[  671.228018]     LR = 0x1001364c
[  671.228063]
[  671.229387] Allocated by task 340:
[  671.232819]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  671.233065]  kmalloc_uaf2+0x48/0xd4 [test_kasan]
[  671.233299]  kmalloc_tests_init+0x5c/0x2d0 [test_kasan]
[  671.233442]  do_one_initcall+0x40/0x278
[  671.233609]  do_init_module+0xcc/0x59c
[  671.233765]  load_module+0x2bc4/0x320c
[  671.233922]  sys_init_module+0x114/0x138
[  671.234066]  ret_from_syscall+0x0/0x38
[  671.234111]
[  671.235407] Freed by task 340:
[  671.238491]  __kasan_slab_free+0x120/0x22c
[  671.238609]  kfree+0x74/0x270
[  671.238851]  kmalloc_uaf2+0x78/0xd4 [test_kasan]
[  671.239085]  kmalloc_tests_init+0x5c/0x2d0 [test_kasan]
[  671.239228]  do_one_initcall+0x40/0x278
[  671.239395]  do_init_module+0xcc/0x59c
[  671.239550]  load_module+0x2bc4/0x320c
[  671.239707]  sys_init_module+0x114/0x138
[  671.239850]  ret_from_syscall+0x0/0x38
[  671.239897]
[  671.241211] The buggy address belongs to the object at c534b060
[  671.241211]  which belongs to the cache kmalloc-64 of size 64
[  671.252758] The buggy address is located 40 bytes inside of
[  671.252758]  64-byte region [c534b060, c534b0a0)
[  671.262761] The buggy address belongs to the page:
[  671.267547] page:c7fd9a40 count:1 mapcount:0 mapping:c5007c20 index:0x0
[  671.267657] flags: 0x200(slab)
[  671.267885] raw: 00000200 00000100 00000200 c5007c20 00000000 
00aa0155 ffffffff 00000001
[  671.267953] page dumped because: kasan: bad access detected
[  671.267993]
[  671.269296] Memory state around the buggy address:
[  671.274104]  c534af80: fc fc fc fc 00 00 00 00 04 fc fc fc fc fc fc fc
[  671.280561]  c534b000: 00 00 00 00 00 00 fc fc fc fc fc fc fb fb fb fb
[  671.287012] >c534b080: fb fb fb fb fc fc fc fc fb fb fb fb fb fb fb fb
[  671.293399]               ^
[  671.296220]  c534b100: fc fc fc fc 00 00 00 00 04 fc fc fc fc fc fc fc
[  671.302676]  c534b180: 00 00 00 00 04 fc fc fc fc fc fc fc fb fb fb fb
[  671.309066] 
==================================================================
[  671.597554] kasan test: kmem_cache_oob out-of-bounds in kmem_cache_alloc
[  671.597819] 
==================================================================
[  671.604991] BUG: KASAN: slab-out-of-bounds in 
kmem_cache_oob+0x9c/0xd0 [test_kasan]
[  671.612398] Read of size 1 at addr c5e180c8 by task exe/340
[  671.617834]
[  671.619417] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  671.619469] Call Trace:
[  671.619645] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  671.619848] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  671.620138] [c5649ce0] [c95d4d10] kmem_cache_oob+0x9c/0xd0 [test_kasan]
[  671.620420] [c5649d00] [c95d5558] kmalloc_tests_init+0x60/0x2d0 
[test_kasan]
[  671.620611] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  671.620826] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  671.621030] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  671.621234] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  671.621428] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  671.621596] --- interrupt: c01 at 0xfd6b914
[  671.621596]     LR = 0x1001364c
[  671.621642]
[  671.622944] Allocated by task 340:
[  671.626376]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  671.626504]  kmem_cache_alloc+0xf4/0x210
[  671.626752]  kmem_cache_oob+0x78/0xd0 [test_kasan]
[  671.626989]  kmalloc_tests_init+0x60/0x2d0 [test_kasan]
[  671.627135]  do_one_initcall+0x40/0x278
[  671.627305]  do_init_module+0xcc/0x59c
[  671.627463]  load_module+0x2bc4/0x320c
[  671.627623]  sys_init_module+0x114/0x138
[  671.627769]  ret_from_syscall+0x0/0x38
[  671.627816]
[  671.629132] Freed by task 0:
[  671.631954] (stack is not available)
[  671.635476]
[  671.637007] The buggy address belongs to the object at c5e18000
[  671.637007]  which belongs to the cache test_cache of size 200
[  671.648642] The buggy address is located 0 bytes to the right of
[  671.648642]  200-byte region [c5e18000, c5e180c8)
[  671.659156] The buggy address belongs to the page:
[  671.663942] page:c7fdf0c0 count:1 mapcount:0 mapping:c540a560 index:0x0
[  671.664054] flags: 0x200(slab)
[  671.664283] raw: 00000200 00000100 00000200 c540a560 00000000 
003e007d ffffffff 00000001
[  671.664353] page dumped because: kasan: bad access detected
[  671.664393]
[  671.665694] Memory state around the buggy address:
[  671.670501]  c5e17f80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  671.676954]  c5e18000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  671.683409] >c5e18080: 00 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc
[  671.689802]                                       ^
[  671.694680]  c5e18100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  671.701137]  c5e18180: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  671.707528] 
==================================================================
[  671.758410] 
=============================================================================
[  671.766368] BUG test_cache (Tainted: G    B            ): Objects 
remaining in test_cache on __kmem_cache_shutdown()
[  671.776719] 
-----------------------------------------------------------------------------
[  671.776719]
[  671.786325] INFO: Slab 0x(ptrval) objects=62 used=1 fp=0x(ptrval) 
flags=0x0200
[  671.793514] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  671.793563] Call Trace:
[  671.793752] [c5649bf0] [c016ebe0] slab_err+0x98/0xac (unreliable)
[  671.793956] [c5649c90] [c01748f4] __kmem_cache_shutdown+0x15c/0x338
[  671.794160] [c5649cf0] [c013c3b4] kmem_cache_destroy+0x68/0x114
[  671.794463] [c5649d00] [c95d5558] kmalloc_tests_init+0x60/0x2d0 
[test_kasan]
[  671.794656] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  671.794868] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  671.795071] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  671.795275] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  671.795468] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  671.795633] --- interrupt: c01 at 0xfd6b914
[  671.795633]     LR = 0x1001364c
[  671.795738] INFO: Object 0x(ptrval) @offset=0
[  671.909762] kmem_cache_destroy test_cache: Slab cache still has objects
[  671.931546] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  671.931601] Call Trace:
[  671.931790] [c5649cf0] [c013c45c] kmem_cache_destroy+0x110/0x114 
(unreliable)
[  671.932116] [c5649d00] [c95d5558] kmalloc_tests_init+0x60/0x2d0 
[test_kasan]
[  671.932310] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  671.932526] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  671.932730] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  671.932934] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  671.933130] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  671.933300] --- interrupt: c01 at 0xfd6b914
[  671.933300]     LR = 0x1001364c
[  671.952750] kasan test: memcg_accounted_kmem_cache allocate memcg 
accounted object
[  672.556766] kasan test: kasan_stack_oob out-of-bounds on stack
[  672.556850] kasan test: kasan_global_oob out-of-bounds global variable
[  672.556922] kasan test: kasan_alloca_oob_left out-of-bounds to left 
on alloca
[  672.556995] kasan test: kasan_alloca_oob_right out-of-bounds to right 
on alloca
[  672.557070] kasan test: ksize_unpoisons_memory ksize() unpoisons the 
whole allocated chunk
[  672.557200] 
==================================================================
[  672.564395] BUG: KASAN: slab-out-of-bounds in 
ksize_unpoisons_memory+0x8c/0xac [test_kasan]
[  672.572578] Write of size 1 at addr c539ab40 by task exe/340
[  672.578098]
[  672.579682] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  672.579734] Call Trace:
[  672.579909] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  672.580114] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  672.580406] [c5649ce0] [c95d5100] ksize_unpoisons_memory+0x8c/0xac 
[test_kasan]
[  672.580689] [c5649d00] [c95d5570] kmalloc_tests_init+0x78/0x2d0 
[test_kasan]
[  672.580880] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  672.581096] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  672.581299] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  672.581503] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  672.581697] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  672.581864] --- interrupt: c01 at 0xfd6b914
[  672.581864]     LR = 0x1001364c
[  672.581910]
[  672.583208] Allocated by task 340:
[  672.586642]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  672.586892]  ksize_unpoisons_memory+0x44/0xac [test_kasan]
[  672.587129]  kmalloc_tests_init+0x78/0x2d0 [test_kasan]
[  672.587275]  do_one_initcall+0x40/0x278
[  672.587445]  do_init_module+0xcc/0x59c
[  672.587602]  load_module+0x2bc4/0x320c
[  672.587761]  sys_init_module+0x114/0x138
[  672.587906]  ret_from_syscall+0x0/0x38
[  672.587953]
[  672.589227] Freed by task 338:
[  672.592316]  __kasan_slab_free+0x120/0x22c
[  672.592437]  kfree+0x74/0x270
[  672.592602]  load_elf_binary+0xb0/0x162c
[  672.592782]  search_binary_handler+0x120/0x374
[  672.592950]  __do_execve_file+0x834/0xb20
[  672.593114]  sys_execve+0x40/0x54
[  672.593259]  ret_from_syscall+0x0/0x38
[  672.593307]
[  672.594603] The buggy address belongs to the object at c539aac0
[  672.594603]  which belongs to the cache kmalloc-128 of size 128
[  672.606324] The buggy address is located 0 bytes to the right of
[  672.606324]  128-byte region [c539aac0, c539ab40)
[  672.616840] The buggy address belongs to the page:
[  672.621625] page:c7fd9cc0 count:1 mapcount:0 mapping:c5007a80 index:0x0
[  672.621738] flags: 0x200(slab)
[  672.621967] raw: 00000200 00000100 00000200 c5007a80 00000000 
005500ab ffffffff 00000001
[  672.622038] page dumped because: kasan: bad access detected
[  672.622077]
[  672.623375] Memory state around the buggy address:
[  672.628183]  c539aa00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  672.634637]  c539aa80: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00
[  672.641090] >c539ab00: 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc fc
[  672.647483]                                    ^
[  672.652106]  c539ab80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[  672.658562]  c539ac00: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
[  672.664951] 
==================================================================
[  672.814421] kasan test: copy_user_test out-of-bounds in copy_from_user()
[  672.814499] 
==================================================================
[  672.821643] BUG: KASAN: slab-out-of-bounds in _copy_from_user+0x48/0xc4
[  672.828089] Write of size 11 at addr c58eb020 by task exe/340
[  672.833699]
[  672.835280] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  672.835331] Call Trace:
[  672.835504] [c5649c50] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  672.835708] [c5649c80] [c0176d34] kasan_report+0xe4/0x168
[  672.835929] [c5649cc0] [c0307be0] _copy_from_user+0x48/0xc4
[  672.836230] [c5649ce0] [c95d51b4] copy_user_test+0x94/0x1bc [test_kasan]
[  672.836512] [c5649d00] [c95d5574] kmalloc_tests_init+0x7c/0x2d0 
[test_kasan]
[  672.836703] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  672.836917] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  672.837121] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  672.837326] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  672.837522] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  672.837687] --- interrupt: c01 at 0xfd6b914
[  672.837687]     LR = 0x1001364c
[  672.837733]
[  672.839067] Allocated by task 340:
[  672.842500]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  672.842749]  copy_user_test+0x28/0x1bc [test_kasan]
[  672.842985]  kmalloc_tests_init+0x7c/0x2d0 [test_kasan]
[  672.843131]  do_one_initcall+0x40/0x278
[  672.843301]  do_init_module+0xcc/0x59c
[  672.843458]  load_module+0x2bc4/0x320c
[  672.843619]  sys_init_module+0x114/0x138
[  672.843764]  ret_from_syscall+0x0/0x38
[  672.843812]
[  672.845085] Freed by task 276:
[  672.848173]  __kasan_slab_free+0x120/0x22c
[  672.848295]  kfree+0x74/0x270
[  672.848427]  single_release+0x54/0x6c
[  672.848601]  close_pdeo+0x128/0x224
[  672.848768]  proc_reg_release+0x110/0x128
[  672.848903]  __fput+0xec/0x2d4
[  672.849028]  task_work_run+0x13c/0x15c
[  672.849197]  do_notify_resume+0x3d8/0x438
[  672.849346]  do_user_signal+0x2c/0x34
[  672.849393]
[  672.850719] The buggy address belongs to the object at c58eb020
[  672.850719]  which belongs to the cache kmalloc-16 of size 16
[  672.862264] The buggy address is located 0 bytes inside of
[  672.862264]  16-byte region [c58eb020, c58eb030)
[  672.872182] The buggy address belongs to the page:
[  672.876968] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  672.877079] flags: 0x200(slab)
[  672.877309] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  672.877377] page dumped because: kasan: bad access detected
[  672.877418]
[  672.878717] Memory state around the buggy address:
[  672.883527]  c58eaf00: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[  672.889979]  c58eaf80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  672.896433] >c58eb000: fb fb fc fc 00 02 fc fc fb fb fc fc fb fb fc fc
[  672.902824]                           ^
[  672.906673]  c58eb080: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  672.913129]  c58eb100: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  672.919520] 
==================================================================
[  672.932289] kasan test: copy_user_test out-of-bounds in copy_to_user()
[  672.932363] 
==================================================================
[  672.939457] BUG: KASAN: slab-out-of-bounds in _copy_to_user+0x9c/0xbc
[  672.945733] Read of size 11 at addr c58eb020 by task exe/340
[  672.951255]
[  672.952840] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  672.952890] Call Trace:
[  672.953061] [c5649c50] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  672.953264] [c5649c80] [c0176d34] kasan_report+0xe4/0x168
[  672.953480] [c5649cc0] [c0307cf8] _copy_to_user+0x9c/0xbc
[  672.953781] [c5649ce0] [c95d51d4] copy_user_test+0xb4/0x1bc [test_kasan]
[  672.954060] [c5649d00] [c95d5574] kmalloc_tests_init+0x7c/0x2d0 
[test_kasan]
[  672.954249] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  672.954461] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  672.954662] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  672.954866] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  672.955058] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  672.955224] --- interrupt: c01 at 0xfd6b914
[  672.955224]     LR = 0x1001364c
[  672.955269]
[  672.956538] Allocated by task 340:
[  672.959969]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  672.960219]  copy_user_test+0x28/0x1bc [test_kasan]
[  672.960454]  kmalloc_tests_init+0x7c/0x2d0 [test_kasan]
[  672.960597]  do_one_initcall+0x40/0x278
[  672.960766]  do_init_module+0xcc/0x59c
[  672.960924]  load_module+0x2bc4/0x320c
[  672.961081]  sys_init_module+0x114/0x138
[  672.961226]  ret_from_syscall+0x0/0x38
[  672.961272]
[  672.962558] Freed by task 276:
[  672.965645]  __kasan_slab_free+0x120/0x22c
[  672.965764]  kfree+0x74/0x270
[  672.965896]  single_release+0x54/0x6c
[  672.966070]  close_pdeo+0x128/0x224
[  672.966236]  proc_reg_release+0x110/0x128
[  672.966369]  __fput+0xec/0x2d4
[  672.966493]  task_work_run+0x13c/0x15c
[  672.966660]  do_notify_resume+0x3d8/0x438
[  672.966809]  do_user_signal+0x2c/0x34
[  672.966855]
[  672.968190] The buggy address belongs to the object at c58eb020
[  672.968190]  which belongs to the cache kmalloc-16 of size 16
[  672.979735] The buggy address is located 0 bytes inside of
[  672.979735]  16-byte region [c58eb020, c58eb030)
[  672.989653] The buggy address belongs to the page:
[  672.994439] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  672.994550] flags: 0x200(slab)
[  672.994778] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  672.994845] page dumped because: kasan: bad access detected
[  672.994885]
[  672.996188] Memory state around the buggy address:
[  673.000996]  c58eaf00: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[  673.007450]  c58eaf80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.013904] >c58eb000: fb fb fc fc 00 02 fc fc fb fb fc fc fb fb fc fc
[  673.020295]                           ^
[  673.024144]  c58eb080: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.030600]  c58eb100: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.036990] 
==================================================================
[  673.327457] kasan test: copy_user_test out-of-bounds in 
__copy_from_user()
[  673.327537] 
==================================================================
[  673.334723] BUG: KASAN: slab-out-of-bounds in 
copy_user_test+0xd0/0x1bc [test_kasan]
[  673.342217] Write of size 11 at addr c58eb020 by task exe/340
[  673.347825]
[  673.349408] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  673.349459] Call Trace:
[  673.349637] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  673.349842] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  673.350130] [c5649ce0] [c95d51f0] copy_user_test+0xd0/0x1bc [test_kasan]
[  673.350412] [c5649d00] [c95d5574] kmalloc_tests_init+0x7c/0x2d0 
[test_kasan]
[  673.350605] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  673.350821] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  673.351025] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  673.351231] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  673.351426] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  673.351592] --- interrupt: c01 at 0xfd6b914
[  673.351592]     LR = 0x1001364c
[  673.351638]
[  673.352936] Allocated by task 340:
[  673.356367]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  673.356619]  copy_user_test+0x28/0x1bc [test_kasan]
[  673.356855]  kmalloc_tests_init+0x7c/0x2d0 [test_kasan]
[  673.357000]  do_one_initcall+0x40/0x278
[  673.357168]  do_init_module+0xcc/0x59c
[  673.357324]  load_module+0x2bc4/0x320c
[  673.357483]  sys_init_module+0x114/0x138
[  673.357626]  ret_from_syscall+0x0/0x38
[  673.357673]
[  673.358954] Freed by task 276:
[  673.362040]  __kasan_slab_free+0x120/0x22c
[  673.362161]  kfree+0x74/0x270
[  673.362293]  single_release+0x54/0x6c
[  673.362465]  close_pdeo+0x128/0x224
[  673.362632]  proc_reg_release+0x110/0x128
[  673.362764]  __fput+0xec/0x2d4
[  673.362888]  task_work_run+0x13c/0x15c
[  673.363057]  do_notify_resume+0x3d8/0x438
[  673.363208]  do_user_signal+0x2c/0x34
[  673.363256]
[  673.364587] The buggy address belongs to the object at c58eb020
[  673.364587]  which belongs to the cache kmalloc-16 of size 16
[  673.376132] The buggy address is located 0 bytes inside of
[  673.376132]  16-byte region [c58eb020, c58eb030)
[  673.386050] The buggy address belongs to the page:
[  673.390836] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  673.390947] flags: 0x200(slab)
[  673.391175] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  673.391245] page dumped because: kasan: bad access detected
[  673.391285]
[  673.392585] Memory state around the buggy address:
[  673.397393]  c58eaf00: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[  673.403847]  c58eaf80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.410301] >c58eb000: fb fb fc fc 00 02 fc fc fb fb fc fc fb fb fc fc
[  673.416691]                           ^
[  673.420541]  c58eb080: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.426997]  c58eb100: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.433387] 
==================================================================
[  673.446960] kasan test: copy_user_test out-of-bounds in __copy_to_user()
[  673.447031] 
==================================================================
[  673.454258] BUG: KASAN: slab-out-of-bounds in 
copy_user_test+0xfc/0x1bc [test_kasan]
[  673.461753] Read of size 11 at addr c58eb020 by task exe/340
[  673.467275]
[  673.468858] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  673.468909] Call Trace:
[  673.469084] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  673.469286] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  673.469573] [c5649ce0] [c95d521c] copy_user_test+0xfc/0x1bc [test_kasan]
[  673.469851] [c5649d00] [c95d5574] kmalloc_tests_init+0x7c/0x2d0 
[test_kasan]
[  673.470042] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  673.470256] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  673.470457] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  673.470660] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  673.470853] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  673.471019] --- interrupt: c01 at 0xfd6b914
[  673.471019]     LR = 0x1001364c
[  673.471064]
[  673.472385] Allocated by task 340:
[  673.475818]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  673.476065]  copy_user_test+0x28/0x1bc [test_kasan]
[  673.476301]  kmalloc_tests_init+0x7c/0x2d0 [test_kasan]
[  673.476444]  do_one_initcall+0x40/0x278
[  673.476612]  do_init_module+0xcc/0x59c
[  673.476768]  load_module+0x2bc4/0x320c
[  673.476925]  sys_init_module+0x114/0x138
[  673.477067]  ret_from_syscall+0x0/0x38
[  673.477113]
[  673.478403] Freed by task 276:
[  673.481490]  __kasan_slab_free+0x120/0x22c
[  673.481610]  kfree+0x74/0x270
[  673.481740]  single_release+0x54/0x6c
[  673.481911]  close_pdeo+0x128/0x224
[  673.482077]  proc_reg_release+0x110/0x128
[  673.482209]  __fput+0xec/0x2d4
[  673.482331]  task_work_run+0x13c/0x15c
[  673.482500]  do_notify_resume+0x3d8/0x438
[  673.482648]  do_user_signal+0x2c/0x34
[  673.482694]
[  673.484036] The buggy address belongs to the object at c58eb020
[  673.484036]  which belongs to the cache kmalloc-16 of size 16
[  673.495583] The buggy address is located 0 bytes inside of
[  673.495583]  16-byte region [c58eb020, c58eb030)
[  673.505500] The buggy address belongs to the page:
[  673.510287] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  673.510396] flags: 0x200(slab)
[  673.510622] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  673.510690] page dumped because: kasan: bad access detected
[  673.510729]
[  673.512037] Memory state around the buggy address:
[  673.516842]  c58eaf00: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[  673.523297]  c58eaf80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.529751] >c58eb000: fb fb fc fc 00 02 fc fc fb fb fc fc fb fb fc fc
[  673.536142]                           ^
[  673.539991]  c58eb080: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.546447]  c58eb100: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.552838] 
==================================================================
[  673.835827] kasan test: copy_user_test out-of-bounds in 
__copy_from_user_inatomic()
[  673.835905] 
==================================================================
[  673.843082] BUG: KASAN: slab-out-of-bounds in 
copy_user_test+0x128/0x1bc [test_kasan]
[  673.850662] Write of size 11 at addr c58eb020 by task exe/340
[  673.856272]
[  673.857853] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  673.857905] Call Trace:
[  673.858080] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  673.858285] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  673.858574] [c5649ce0] [c95d5248] copy_user_test+0x128/0x1bc [test_kasan]
[  673.858855] [c5649d00] [c95d5574] kmalloc_tests_init+0x7c/0x2d0 
[test_kasan]
[  673.859046] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  673.859261] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  673.859463] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  673.859668] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  673.859863] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  673.860029] --- interrupt: c01 at 0xfd6b914
[  673.860029]     LR = 0x1001364c
[  673.860075]
[  673.861380] Allocated by task 340:
[  673.864812]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  673.865062]  copy_user_test+0x28/0x1bc [test_kasan]
[  673.865299]  kmalloc_tests_init+0x7c/0x2d0 [test_kasan]
[  673.865444]  do_one_initcall+0x40/0x278
[  673.865615]  do_init_module+0xcc/0x59c
[  673.865773]  load_module+0x2bc4/0x320c
[  673.865932]  sys_init_module+0x114/0x138
[  673.866077]  ret_from_syscall+0x0/0x38
[  673.866123]
[  673.867399] Freed by task 276:
[  673.870488]  __kasan_slab_free+0x120/0x22c
[  673.870609]  kfree+0x74/0x270
[  673.870741]  single_release+0x54/0x6c
[  673.870913]  close_pdeo+0x128/0x224
[  673.871080]  proc_reg_release+0x110/0x128
[  673.871213]  __fput+0xec/0x2d4
[  673.871337]  task_work_run+0x13c/0x15c
[  673.871506]  do_notify_resume+0x3d8/0x438
[  673.871655]  do_user_signal+0x2c/0x34
[  673.871702]
[  673.873032] The buggy address belongs to the object at c58eb020
[  673.873032]  which belongs to the cache kmalloc-16 of size 16
[  673.884578] The buggy address is located 0 bytes inside of
[  673.884578]  16-byte region [c58eb020, c58eb030)
[  673.894494] The buggy address belongs to the page:
[  673.899282] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  673.899395] flags: 0x200(slab)
[  673.899625] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  673.899694] page dumped because: kasan: bad access detected
[  673.899734]
[  673.901033] Memory state around the buggy address:
[  673.905838]  c58eaf00: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[  673.912293]  c58eaf80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.918748] >c58eb000: fb fb fc fc 00 02 fc fc fb fb fc fc fb fb fc fc
[  673.925136]                           ^
[  673.928987]  c58eb080: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.935442]  c58eb100: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  673.941833] 
==================================================================
[  673.954463] kasan test: copy_user_test out-of-bounds in 
__copy_to_user_inatomic()
[  673.954535] 
==================================================================
[  673.961759] BUG: KASAN: slab-out-of-bounds in 
copy_user_test+0x154/0x1bc [test_kasan]
[  673.969339] Read of size 11 at addr c58eb020 by task exe/340
[  673.974860]
[  673.976444] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  673.976494] Call Trace:
[  673.976668] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  673.976870] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  673.977160] [c5649ce0] [c95d5274] copy_user_test+0x154/0x1bc [test_kasan]
[  673.977439] [c5649d00] [c95d5574] kmalloc_tests_init+0x7c/0x2d0 
[test_kasan]
[  673.977630] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  673.977843] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  673.978045] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  673.978249] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  673.978441] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  673.978607] --- interrupt: c01 at 0xfd6b914
[  673.978607]     LR = 0x1001364c
[  673.978651]
[  673.979971] Allocated by task 340:
[  673.983401]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  673.983650]  copy_user_test+0x28/0x1bc [test_kasan]
[  673.983885]  kmalloc_tests_init+0x7c/0x2d0 [test_kasan]
[  673.984030]  do_one_initcall+0x40/0x278
[  673.984198]  do_init_module+0xcc/0x59c
[  673.984354]  load_module+0x2bc4/0x320c
[  673.984512]  sys_init_module+0x114/0x138
[  673.984655]  ret_from_syscall+0x0/0x38
[  673.984701]
[  673.985990] Freed by task 276:
[  673.989077]  __kasan_slab_free+0x120/0x22c
[  673.989197]  kfree+0x74/0x270
[  673.989327]  single_release+0x54/0x6c
[  673.989499]  close_pdeo+0x128/0x224
[  673.989664]  proc_reg_release+0x110/0x128
[  673.989796]  __fput+0xec/0x2d4
[  673.989918]  task_work_run+0x13c/0x15c
[  673.990086]  do_notify_resume+0x3d8/0x438
[  673.990235]  do_user_signal+0x2c/0x34
[  673.990281]
[  673.991622] The buggy address belongs to the object at c58eb020
[  673.991622]  which belongs to the cache kmalloc-16 of size 16
[  674.003168] The buggy address is located 0 bytes inside of
[  674.003168]  16-byte region [c58eb020, c58eb030)
[  674.013086] The buggy address belongs to the page:
[  674.017872] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  674.017982] flags: 0x200(slab)
[  674.018210] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  674.018277] page dumped because: kasan: bad access detected
[  674.018316]
[  674.019622] Memory state around the buggy address:
[  674.024429]  c58eaf00: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[  674.030883]  c58eaf80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  674.037338] >c58eb000: fb fb fc fc 00 02 fc fc fb fb fc fc fb fb fc fc
[  674.043727]                           ^
[  674.047578]  c58eb080: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  674.054034]  c58eb100: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  674.060424] 
==================================================================
[  674.346609] kasan test: copy_user_test out-of-bounds in 
strncpy_from_user()
[  674.346689] 
==================================================================
[  674.353778] BUG: KASAN: slab-out-of-bounds in 
strncpy_from_user+0x48/0x240
[  674.360487] Write of size 11 at addr c58eb020 by task exe/340
[  674.366094]
[  674.367678] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  674.367731] Call Trace:
[  674.367904] [c5649c40] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  674.368108] [c5649c70] [c0176d34] kasan_report+0xe4/0x168
[  674.368323] [c5649cb0] [c03202f8] strncpy_from_user+0x48/0x240
[  674.368627] [c5649ce0] [c95d52a4] copy_user_test+0x184/0x1bc [test_kasan]
[  674.368908] [c5649d00] [c95d5574] kmalloc_tests_init+0x7c/0x2d0 
[test_kasan]
[  674.369100] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  674.369315] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  674.369518] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  674.369724] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  674.369919] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  674.370086] --- interrupt: c01 at 0xfd6b914
[  674.370086]     LR = 0x1001364c
[  674.370132]
[  674.371463] Allocated by task 340:
[  674.374894]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  674.375146]  copy_user_test+0x28/0x1bc [test_kasan]
[  674.375383]  kmalloc_tests_init+0x7c/0x2d0 [test_kasan]
[  674.375527]  do_one_initcall+0x40/0x278
[  674.375697]  do_init_module+0xcc/0x59c
[  674.375854]  load_module+0x2bc4/0x320c
[  674.376015]  sys_init_module+0x114/0x138
[  674.376162]  ret_from_syscall+0x0/0x38
[  674.376209]
[  674.377481] Freed by task 276:
[  674.380568]  __kasan_slab_free+0x120/0x22c
[  674.380691]  kfree+0x74/0x270
[  674.380824]  single_release+0x54/0x6c
[  674.380998]  close_pdeo+0x128/0x224
[  674.381165]  proc_reg_release+0x110/0x128
[  674.381299]  __fput+0xec/0x2d4
[  674.381424]  task_work_run+0x13c/0x15c
[  674.381592]  do_notify_resume+0x3d8/0x438
[  674.381743]  do_user_signal+0x2c/0x34
[  674.381792]
[  674.383113] The buggy address belongs to the object at c58eb020
[  674.383113]  which belongs to the cache kmalloc-16 of size 16
[  674.394659] The buggy address is located 0 bytes inside of
[  674.394659]  16-byte region [c58eb020, c58eb030)
[  674.404577] The buggy address belongs to the page:
[  674.409363] page:c7fdc740 count:1 mapcount:0 mapping:c5007dc0 index:0x0
[  674.409474] flags: 0x200(slab)
[  674.409703] raw: 00000200 00000100 00000200 c5007dc0 00000000 
02000401 ffffffff 00000001
[  674.409772] page dumped because: kasan: bad access detected
[  674.409812]
[  674.411112] Memory state around the buggy address:
[  674.415920]  c58eaf00: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[  674.422374]  c58eaf80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  674.428827] >c58eb000: fb fb fc fc 00 02 fc fc fb fb fc fc fb fb fc fc
[  674.435218]                           ^
[  674.439067]  c58eb080: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  674.445524]  c58eb100: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[  674.451914] 
==================================================================
[  674.466513] kasan test: use_after_scope_test use-after-scope on int
[  674.466592] kasan test: use_after_scope_test use-after-scope on array
[  674.470775] kasan test: kmem_cache_double_free double-free on heap object
[  674.471059] 
==================================================================
[  674.478286] BUG: KASAN: double-free or invalid-free in 
kmem_cache_double_free+0xac/0xc4 [test_kasan]
[  674.487095]
[  674.488679] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  674.488730] Call Trace:
[  674.488906] [c5649b30] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  674.489118] [c5649b60] [c0176c24] kasan_report_invalid_free+0x48/0x74
[  674.489296] [c5649b90] [c0175620] __kasan_slab_free+0x198/0x22c
[  674.489467] [c5649cc0] [c0173838] kmem_cache_free+0x64/0x228
[  674.489754] [c5649ce0] [c95d4df0] kmem_cache_double_free+0xac/0xc4 
[test_kasan]
[  674.490029] [c5649d00] [c95d557c] kmalloc_tests_init+0x84/0x2d0 
[test_kasan]
[  674.490219] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  674.490432] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  674.490633] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  674.490837] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  674.491031] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  674.491194] --- interrupt: c01 at 0xfd6b914
[  674.491194]     LR = 0x1001364c
[  674.491239]
[  674.492547] Allocated by task 340:
[  674.495981]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  674.496108]  kmem_cache_alloc+0xf4/0x210
[  674.496355]  kmem_cache_double_free+0x78/0xc4 [test_kasan]
[  674.496584]  kmalloc_tests_init+0x84/0x2d0 [test_kasan]
[  674.496727]  do_one_initcall+0x40/0x278
[  674.496893]  do_init_module+0xcc/0x59c
[  674.497050]  load_module+0x2bc4/0x320c
[  674.497208]  sys_init_module+0x114/0x138
[  674.497354]  ret_from_syscall+0x0/0x38
[  674.497400]
[  674.498652] Freed by task 340:
[  674.501739]  __kasan_slab_free+0x120/0x22c
[  674.501866]  kmem_cache_free+0x64/0x228
[  674.502112]  kmem_cache_double_free+0xa0/0xc4 [test_kasan]
[  674.502340]  kmalloc_tests_init+0x84/0x2d0 [test_kasan]
[  674.502483]  do_one_initcall+0x40/0x278
[  674.502650]  do_init_module+0xcc/0x59c
[  674.502807]  load_module+0x2bc4/0x320c
[  674.502966]  sys_init_module+0x114/0x138
[  674.503112]  ret_from_syscall+0x0/0x38
[  674.503158]
[  674.504460] The buggy address belongs to the object at c5528000
[  674.504460]  which belongs to the cache test_cache of size 200
[  674.516091] The buggy address is located 0 bytes inside of
[  674.516091]  200-byte region [c5528000, c55280c8)
[  674.526092] The buggy address belongs to the page:
[  674.530877] page:c7fda940 count:1 mapcount:0 mapping:c540a700 index:0x0
[  674.530988] flags: 0x200(slab)
[  674.531216] raw: 00000200 00000100 00000200 c540a700 00000000 
003e007d ffffffff 00000001
[  674.531284] page dumped because: kasan: bad access detected
[  674.531323]
[  674.532630] Memory state around the buggy address:
[  674.537436]  c5527f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  674.543890]  c5527f80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  674.550345] >c5528000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[  674.556731]            ^
[  674.559293]  c5528080: fb fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc
[  674.565750]  c5528100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  674.572138] 
==================================================================
[  674.880790] kasan test: kmem_cache_invalid_free invalid-free of heap 
object
[  674.881044] 
==================================================================
[  674.888197] BUG: KASAN: double-free or invalid-free in 
kmem_cache_invalid_free+0xa0/0xc4 [test_kasan]
[  674.897089]
[  674.898670] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  674.898722] Call Trace:
[  674.898899] [c5649b30] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  674.899113] [c5649b60] [c0176c24] kasan_report_invalid_free+0x48/0x74
[  674.899293] [c5649b90] [c0175620] __kasan_slab_free+0x198/0x22c
[  674.899467] [c5649cc0] [c0173838] kmem_cache_free+0x64/0x228
[  674.899756] [c5649ce0] [c95d4ea8] kmem_cache_invalid_free+0xa0/0xc4 
[test_kasan]
[  674.900031] [c5649d00] [c95d5580] kmalloc_tests_init+0x88/0x2d0 
[test_kasan]
[  674.900222] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  674.900437] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  674.900639] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  674.900845] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  674.901040] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  674.901206] --- interrupt: c01 at 0xfd6b914
[  674.901206]     LR = 0x1001364c
[  674.901251]
[  674.902542] Allocated by task 340:
[  674.905975]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  674.906103]  kmem_cache_alloc+0xf4/0x210
[  674.906351]  kmem_cache_invalid_free+0x78/0xc4 [test_kasan]
[  674.906584]  kmalloc_tests_init+0x88/0x2d0 [test_kasan]
[  674.906730]  do_one_initcall+0x40/0x278
[  674.906899]  do_init_module+0xcc/0x59c
[  674.907056]  load_module+0x2bc4/0x320c
[  674.907217]  sys_init_module+0x114/0x138
[  674.907364]  ret_from_syscall+0x0/0x38
[  674.907411]
[  674.908731] Freed by task 0:
[  674.911551] (stack is not available)
[  674.915074]
[  674.916605] The buggy address belongs to the object at c5528000
[  674.916605]  which belongs to the cache test_cache of size 200
[  674.928237] The buggy address is located 1 bytes inside of
[  674.928237]  200-byte region [c5528000, c55280c8)
[  674.938237] The buggy address belongs to the page:
[  674.943024] page:c7fda940 count:1 mapcount:0 mapping:c540a7d0 index:0x0
[  674.943136] flags: 0x200(slab)
[  674.943365] raw: 00000200 00000100 00000200 c540a7d0 00000000 
003e007d ffffffff 00000001
[  674.943434] page dumped because: kasan: bad access detected
[  674.943475]
[  674.944775] Memory state around the buggy address:
[  674.949581]  c5527f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  674.956036]  c5527f80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  674.962491] >c5528000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  674.968876]            ^
[  674.971438]  c5528080: 00 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc
[  674.977895]  c5528100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  674.984285] 
==================================================================
[  675.126818] kasan test: kasan_memchr out-of-bounds in memchr
[  675.126994] kasan test: kasan_memcmp out-of-bounds in memcmp
[  675.127158] kasan test: kasan_strings use-after-free in strchr
[  675.127309] 
==================================================================
[  675.134382] BUG: KASAN: use-after-free in strchr+0x1c/0x80
[  675.139762] Read of size 1 at addr c53e8e20 by task exe/340
[  675.145200]
[  675.146784] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  675.146836] Call Trace:
[  675.147010] [c5649c50] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  675.147215] [c5649c80] [c0176d34] kasan_report+0xe4/0x168
[  675.147385] [c5649cc0] [c072ec4c] strchr+0x1c/0x80
[  675.147684] [c5649ce0] [c95d5440] kasan_strings+0x60/0x118 [test_kasan]
[  675.147966] [c5649d00] [c95d558c] kmalloc_tests_init+0x94/0x2d0 
[test_kasan]
[  675.148157] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  675.148372] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  675.148577] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  675.148781] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  675.148976] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  675.149143] --- interrupt: c01 at 0xfd6b914
[  675.149143]     LR = 0x1001364c
[  675.149189]
[  675.150483] Allocated by task 340:
[  675.153915]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  675.154163]  kasan_strings+0x44/0x118 [test_kasan]
[  675.154400]  kmalloc_tests_init+0x94/0x2d0 [test_kasan]
[  675.154545]  do_one_initcall+0x40/0x278
[  675.154714]  do_init_module+0xcc/0x59c
[  675.154872]  load_module+0x2bc4/0x320c
[  675.155033]  sys_init_module+0x114/0x138
[  675.155179]  ret_from_syscall+0x0/0x38
[  675.155225]
[  675.156501] Freed by task 340:
[  675.159587]  __kasan_slab_free+0x120/0x22c
[  675.159709]  kfree+0x74/0x270
[  675.159954]  kasan_strings+0x54/0x118 [test_kasan]
[  675.160191]  kmalloc_tests_init+0x94/0x2d0 [test_kasan]
[  675.160337]  do_one_initcall+0x40/0x278
[  675.160508]  do_init_module+0xcc/0x59c
[  675.160667]  load_module+0x2bc4/0x320c
[  675.160828]  sys_init_module+0x114/0x138
[  675.160973]  ret_from_syscall+0x0/0x38
[  675.161019]
[  675.162306] The buggy address belongs to the object at c53e8e10
[  675.162306]  which belongs to the cache kmalloc-32 of size 32
[  675.173853] The buggy address is located 16 bytes inside of
[  675.173853]  32-byte region [c53e8e10, c53e8e30)
[  675.183856] The buggy address belongs to the page:
[  675.188642] page:c7fd9f40 count:1 mapcount:0 mapping:c5007cf0 index:0x0
[  675.188753] flags: 0x200(slab)
[  675.188982] raw: 00000200 00000100 00000200 c5007cf0 00000000 
015502ab ffffffff 00000001
[  675.189051] page dumped because: kasan: bad access detected
[  675.189091]
[  675.190392] Memory state around the buggy address:
[  675.195199]  c53e8d00: 00 00 fc fc 00 00 00 00 fc fc 00 00 00 00 fc fc
[  675.201653]  c53e8d80: 00 00 00 00 fc fc 00 00 00 00 fc fc 00 00 00 00
[  675.208108] >c53e8e00: fc fc fb fb fb fb fc fc 00 00 00 00 fc fc fb fb
[  675.214497]                        ^
[  675.218089]  c53e8e80: fb fb fc fc fb fb fb fb fc fc fb fb fb fb fc fc
[  675.224544]  c53e8f00: 00 00 00 04 fc fc fb fb fb fb fc fc fb fb fb fb
[  675.230935] 
==================================================================
[  675.383353] kasan test: kasan_strings use-after-free in strrchr
[  675.383430] 
==================================================================
[  675.390498] BUG: KASAN: use-after-free in strrchr+0x30/0x64
[  675.395964] Read of size 1 at addr c53e8e20 by task exe/340
[  675.401403]
[  675.402986] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  675.403038] Call Trace:
[  675.403212] [c5649c50] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  675.403415] [c5649c80] [c0176d34] kasan_report+0xe4/0x168
[  675.403587] [c5649cc0] [c072ed48] strrchr+0x30/0x64
[  675.403888] [c5649ce0] [c95d545c] kasan_strings+0x7c/0x118 [test_kasan]
[  675.404170] [c5649d00] [c95d558c] kmalloc_tests_init+0x94/0x2d0 
[test_kasan]
[  675.404362] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  675.404576] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  675.404779] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  675.404983] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  675.405177] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  675.405344] --- interrupt: c01 at 0xfd6b914
[  675.405344]     LR = 0x1001364c
[  675.405390]
[  675.406684] Allocated by task 340:
[  675.410118]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  675.410366]  kasan_strings+0x44/0x118 [test_kasan]
[  675.410603]  kmalloc_tests_init+0x94/0x2d0 [test_kasan]
[  675.410750]  do_one_initcall+0x40/0x278
[  675.410919]  do_init_module+0xcc/0x59c
[  675.411078]  load_module+0x2bc4/0x320c
[  675.411238]  sys_init_module+0x114/0x138
[  675.411384]  ret_from_syscall+0x0/0x38
[  675.411430]
[  675.412704] Freed by task 340:
[  675.415789]  __kasan_slab_free+0x120/0x22c
[  675.415910]  kfree+0x74/0x270
[  675.416155]  kasan_strings+0x54/0x118 [test_kasan]
[  675.416391]  kmalloc_tests_init+0x94/0x2d0 [test_kasan]
[  675.416537]  do_one_initcall+0x40/0x278
[  675.416706]  do_init_module+0xcc/0x59c
[  675.416865]  load_module+0x2bc4/0x320c
[  675.417024]  sys_init_module+0x114/0x138
[  675.417169]  ret_from_syscall+0x0/0x38
[  675.417215]
[  675.418509] The buggy address belongs to the object at c53e8e10
[  675.418509]  which belongs to the cache kmalloc-32 of size 32
[  675.430055] The buggy address is located 16 bytes inside of
[  675.430055]  32-byte region [c53e8e10, c53e8e30)
[  675.440057] The buggy address belongs to the page:
[  675.444844] page:c7fd9f40 count:1 mapcount:0 mapping:c5007cf0 index:0x0
[  675.444955] flags: 0x200(slab)
[  675.445184] raw: 00000200 00000100 00000200 c5007cf0 00000000 
015502ab ffffffff 00000001
[  675.445253] page dumped because: kasan: bad access detected
[  675.445293]
[  675.446595] Memory state around the buggy address:
[  675.451401]  c53e8d00: 00 00 fc fc 00 00 00 00 fc fc 00 00 00 00 fc fc
[  675.457856]  c53e8d80: 00 00 00 00 fc fc 00 00 00 00 fc fc 00 00 00 00
[  675.464310] >c53e8e00: fc fc fb fb fb fb fc fc 00 00 00 00 fc fc fb fb
[  675.470698]                        ^
[  675.474291]  c53e8e80: fb fb fc fc fb fb fb fb fc fc fb fb fb fb fc fc
[  675.480747]  c53e8f00: 00 00 00 04 fc fc fb fb fb fb fc fc fb fb fb fb
[  675.487138] 
==================================================================
[  675.500419] kasan test: kasan_strings use-after-free in strcmp
[  675.500491] 
==================================================================
[  675.507536] BUG: KASAN: use-after-free in strcmp+0x30/0x90
[  675.512918] Read of size 1 at addr c53e8e20 by task exe/340
[  675.518358]
[  675.519942] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  675.519994] Call Trace:
[  675.520167] [c5649c50] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  675.520369] [c5649c80] [c0176d34] kasan_report+0xe4/0x168
[  675.520536] [c5649cc0] [c072ebd0] strcmp+0x30/0x90
[  675.520833] [c5649ce0] [c95d5480] kasan_strings+0xa0/0x118 [test_kasan]
[  675.521113] [c5649d00] [c95d558c] kmalloc_tests_init+0x94/0x2d0 
[test_kasan]
[  675.521303] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  675.521514] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  675.521716] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  675.521919] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  675.522111] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  675.522275] --- interrupt: c01 at 0xfd6b914
[  675.522275]     LR = 0x1001364c
[  675.522320]
[  675.523640] Allocated by task 340:
[  675.527073]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  675.527321]  kasan_strings+0x44/0x118 [test_kasan]
[  675.527556]  kmalloc_tests_init+0x94/0x2d0 [test_kasan]
[  675.527699]  do_one_initcall+0x40/0x278
[  675.527867]  do_init_module+0xcc/0x59c
[  675.528024]  load_module+0x2bc4/0x320c
[  675.528182]  sys_init_module+0x114/0x138
[  675.528327]  ret_from_syscall+0x0/0x38
[  675.528373]
[  675.529658] Freed by task 340:
[  675.532745]  __kasan_slab_free+0x120/0x22c
[  675.532865]  kfree+0x74/0x270
[  675.533109]  kasan_strings+0x54/0x118 [test_kasan]
[  675.533343]  kmalloc_tests_init+0x94/0x2d0 [test_kasan]
[  675.533486]  do_one_initcall+0x40/0x278
[  675.533654]  do_init_module+0xcc/0x59c
[  675.533810]  load_module+0x2bc4/0x320c
[  675.533967]  sys_init_module+0x114/0x138
[  675.534112]  ret_from_syscall+0x0/0x38
[  675.534157]
[  675.535463] The buggy address belongs to the object at c53e8e10
[  675.535463]  which belongs to the cache kmalloc-32 of size 32
[  675.547010] The buggy address is located 16 bytes inside of
[  675.547010]  32-byte region [c53e8e10, c53e8e30)
[  675.557012] The buggy address belongs to the page:
[  675.561799] page:c7fd9f40 count:1 mapcount:0 mapping:c5007cf0 index:0x0
[  675.561909] flags: 0x200(slab)
[  675.562137] raw: 00000200 00000100 00000200 c5007cf0 00000000 
015502ab ffffffff 00000001
[  675.562204] page dumped because: kasan: bad access detected
[  675.562243]
[  675.563549] Memory state around the buggy address:
[  675.568356]  c53e8d00: 00 00 fc fc 00 00 00 00 fc fc 00 00 00 00 fc fc
[  675.574809]  c53e8d80: 00 00 00 00 fc fc 00 00 00 00 fc fc 00 00 00 00
[  675.581265] >c53e8e00: fc fc fb fb fb fb fc fc 00 00 00 00 fc fc fb fb
[  675.587653]                        ^
[  675.591247]  c53e8e80: fb fb fc fc fb fb fb fb fc fc fb fb fb fb fc fc
[  675.597702]  c53e8f00: 00 00 00 04 fc fc fb fb fb fb fc fc fb fb fb fb
[  675.604091] 
==================================================================
[  675.894391] kasan test: kasan_strings use-after-free in strncmp
[  675.894468] kasan test: kasan_strings use-after-free in strlen
[  675.894536] kasan test: kasan_strings use-after-free in strnlen
[  675.894600] 
==================================================================
[  675.901698] BUG: KASAN: use-after-free in strnlen+0x24/0x88
[  675.907165] Read of size 1 at addr c53e8e20 by task exe/340
[  675.912603]
[  675.914186] CPU: 0 PID: 340 Comm: exe Tainted: G    B 
5.0.0-rc2-s3k-dev-00559-g88aa407c4bce-dirty #778
[  675.914237] Call Trace:
[  675.914412] [c5649c70] [c0176998] 
print_address_description+0x6c/0x2b0 (unreliable)
[  675.914617] [c5649ca0] [c0176d34] kasan_report+0xe4/0x168
[  675.914788] [c5649ce0] [c072eeb4] strnlen+0x24/0x88
[  675.915091] [c5649d00] [c95d558c] kmalloc_tests_init+0x94/0x2d0 
[test_kasan]
[  675.915283] [c5649d10] [c0003a44] do_one_initcall+0x40/0x278
[  675.915497] [c5649d80] [c00b2bc0] do_init_module+0xcc/0x59c
[  675.915700] [c5649db0] [c00b1384] load_module+0x2bc4/0x320c
[  675.915904] [c5649ec0] [c00b1ae0] sys_init_module+0x114/0x138
[  675.916099] [c5649f40] [c001211c] ret_from_syscall+0x0/0x38
[  675.916267] --- interrupt: c01 at 0xfd6b914
[  675.916267]     LR = 0x1001364c
[  675.916312]
[  675.917626] Allocated by task 340:
[  675.921059]  __kasan_kmalloc.isra.0+0xc8/0x1b0
[  675.921309]  kasan_strings+0x44/0x118 [test_kasan]
[  675.921546]  kmalloc_tests_init+0x94/0x2d0 [test_kasan]
[  675.921690]  do_one_initcall+0x40/0x278
[  675.921858]  do_init_module+0xcc/0x59c
[  675.922016]  load_module+0x2bc4/0x320c
[  675.922174]  sys_init_module+0x114/0x138
[  675.922318]  ret_from_syscall+0x0/0x38
[  675.922365]
[  675.923645] Freed by task 340:
[  675.926731]  __kasan_slab_free+0x120/0x22c
[  675.926851]  kfree+0x74/0x270
[  675.927097]  kasan_strings+0x54/0x118 [test_kasan]
[  675.927334]  kmalloc_tests_init+0x94/0x2d0 [test_kasan]
[  675.927479]  do_one_initcall+0x40/0x278
[  675.927647]  do_init_module+0xcc/0x59c
[  675.927804]  load_module+0x2bc4/0x320c
[  675.927962]  sys_init_module+0x114/0x138
[  675.928107]  ret_from_syscall+0x0/0x38
[  675.928154]
[  675.929450] The buggy address belongs to the object at c53e8e10
[  675.929450]  which belongs to the cache kmalloc-32 of size 32
[  675.940997] The buggy address is located 16 bytes inside of
[  675.940997]  32-byte region [c53e8e10, c53e8e30)
[  675.950999] The buggy address belongs to the page:
[  675.955786] page:c7fd9f40 count:1 mapcount:0 mapping:c5007cf0 index:0x0
[  675.955897] flags: 0x200(slab)
[  675.956127] raw: 00000200 00000100 00000200 c5007cf0 00000000 
015502ab ffffffff 00000001
[  675.956196] page dumped because: kasan: bad access detected
[  675.956236]
[  675.957536] Memory state around the buggy address:
[  675.962343]  c53e8d00: 00 00 fc fc 00 00 00 00 fc fc 00 00 00 00 fc fc
[  675.968796]  c53e8d80: 00 00 00 00 fc fc 00 00 00 00 fc fc 00 00 00 00
[  675.975251] >c53e8e00: fc fc fb fb fb fb fc fc 00 00 00 00 fc fc fb fb
[  675.981640]                        ^
[  675.985233]  c53e8e80: fb fb fc fc fb fb fb fb fc fc fb fb fb fb fc fc
[  675.991688]  c53e8f00: 00 00 00 04 fc fc fb fb fb fb fc fc fb fb fb fb
[  675.998080] 
==================================================================
[  721.624809] random: crng init done
