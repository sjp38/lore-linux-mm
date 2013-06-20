Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 1BBE56B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 18:52:01 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hq4so67522wib.2
        for <linux-mm@kvack.org>; Thu, 20 Jun 2013 15:51:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51C334FA.6080604@gmail.com>
References: <1371741150-10861-1-git-send-email-unix140@gmail.com>
	<51C334FA.6080604@gmail.com>
Date: Fri, 21 Jun 2013 01:51:59 +0300
Message-ID: <CAEnQRZA8tjSVdQPMXcf+3WZNa7OfbA-92WCiCbbieQSXTBu1NQ@mail.gmail.com>
Subject: Re: [PATCH] mm: fix overflow in alloc_vmap_area
From: Daniel Baluta <dbaluta@ixiacom.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Ghennadi Procopciuc <unix140@gmail.com>, akpm@linux-foundation.org, js1304@gmail.com, rientjes@google.com, minchan@kernel.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>

On Thu, Jun 20, 2013 at 7:59 PM, Zhang Yanfei <zhangyanfei.yes@gmail.com> wrote:
> On 06/20/2013 11:12 PM, Ghennadi Procopciuc wrote:
>> Inserting the following kernel module:
>>
>> <snip>
>>
>> static int simple_test_init(void)
>> {
>>         size_t i, j;
>>         void *address;
>>
>>         for (i = 0 * MB; i<  60 * MB; i += 1 * MB) {
>>                 for (j = i; j<  i + 1 * MB; j += KB) {
>>                         address = vmalloc(j);
>>                         vfree(address);
>>                 }
>>         }
>>
>>         return 0;
>> }
>>
>> </snip>
>>
>> triggers BUG at mm/vmalloc.c:310 on a x86 machine:
>>
>> [   95.218283] Kernel BUG at c1126cdb [verbose debug info unavailable]
>> [   95.218306] invalid opcode: 0000 [#1] SMP
>> [   95.218324] Modules linked in: lkma_test(OF+)<snip lots of not tainted modules>
>> [   95.218559] Pid: 2419, comm: insmod Tainted: GF          O 3.9.0+ #57 Hewlett-Packard HP Compaq 8200 Elite CMT PC/1494
>> [   95.218597] EIP: 0060:[<c1126cdb>] EFLAGS: 00010207 CPU: 3
>> [   95.218617] EIP is at __insert_vmap_area+0xfb/0x100
>> [   95.218635] EAX: f85dc000 EBX: ef05cac0 ECX: f7be08c4 EDX: 00000007
>> [   95.218657] ESI: f2ed044c EDI: c1a220b8 EBP: f027bd34 ESP: f027bd14
>> [   95.218680]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
>> [   95.218699] CR0: 80050033 CR2: b5995118 CR3: 30364000 CR4: 000407f0
>> [   95.218721] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>> [   95.218743] DR6: ffff0ff0 DR7: 00000400
>> [   95.218758] Process insmod (pid: 2419, ti=f027a000 task=efe64010 task.ti=f027a000)
>> [   95.218784] Stack:
>> [   95.218792]  c177b964 fecfb000 f85e2000 00000000 f85dc000 ffbfe000 f02da1c0 0007f000
>> [   95.218829]  f027bd7c c112802d c177b9b0 fecfb000 01305000 ffbfe000 00000001 ef05cac0
>> [   95.218866]  00000000 00000000 f83fe000 01304fff f83fe000 ffffffff 01305000 ef05c500
>> [   95.218903] Call Trace:
>> [   95.218915]  [<f85e2000>] ? 0xf85e1fff
>> [   95.218930]  [<f85dc000>] ? 0xf85dbfff
>> [   95.218945]  [<c112802d>] alloc_vmap_area.isra.16+0x1bd/0x2f0
>> [   95.218967]  [<c112867f>] __get_vm_area_node.isra.17+0x8f/0x130
>> [   95.218988]  [<c1128d77>] __vmalloc_node_range+0x57/0x200
>> [   95.219009]  [<f85f3075>] ? lkma_test_init+0x45/0x70 [lkma_test]
>> [   95.219031]  [<c1128f82>] __vmalloc_node+0x62/0x70
>> [   95.219049]  [<f85f3075>] ? lkma_test_init+0x45/0x70 [lkma_test]
>> [   95.219071]  [<c1129058>] vmalloc+0x38/0x40
>> [   95.219087]  [<f85f3075>] ? lkma_test_init+0x45/0x70 [lkma_test]
>> [   95.219109]  [<f85f3075>] lkma_test_init+0x45/0x70 [lkma_test]
>> [   95.219131]  [<f85f3030>] ? kzalloc+0x10/0x10 [lkma_test]
>> [   95.219151]  [<c1001222>] do_one_initcall+0x112/0x160
>> [   95.219171]  [<c15ca3cf>] ? set_section_ro_nx+0x54/0x59
>> [   95.219190]  [<c1099b69>] load_module+0x1d79/0x2660
>> [   95.219209]  [<c114721d>] ? create_object+0x19d/0x280
>> [   95.219230]  [<c109a4c8>] sys_init_module+0x78/0xb0
>> [   95.219250]  [<c15d9801>] sysenter_do_call+0x12/0x22
>> [   95.219268] Code: 39 03 73 0c 8b 3f 89 f0 83 c7 08 e9 3d ff ff ff 8b 46 f4 39 43 04 76 13 8b 3f 89 f0 83 c7 04 e9 29 ff ff ff e8 fb 1b 4a 00 eb ab<0f>  0b 8d 76 00 55 89 e5 56 53 66 66 66 66 90 83 60 0c df 89 c6
>> [   95.219415] EIP: [<c1126cdb>] __insert_vmap_area+0xfb/0x100 SS:ESP 0068:f027bd14
>> [   95.228313] ---[ end trace e0a1efb2acb97c98 ]---
>>
>> A printk placed in __insert_vmap_area will show:
>>
>> [   95.218256] va->va_start=0xfecfb000 tmp_va->va_end=0xf85e2000 va->va_end=0 tmp_va->va_start=0xf85dc000
>>
>> and another one, before sum operation in alloc_vmap_area:
>>
>> [   95.218204] addr = 0xfecfb000 size = 19943424 vend = 0xffbfe000
>>
>> If after addition the result is smaller than one of the arguments,
>> then an overflow occurred. In our case there is an obvious overflow.
>>
>> Signed-off-by: Ghennadi Procopciuc <unix140@gmail.com>
>> Cc: Daniel Baluta<dbaluta@ixiacom.com>
>>
>> ---
>>  Don't know if this is the right solution, but the bug happens for me in
>>  3.10-rc6 and 3.9.
>
> Hello Ghennadi,
>
> Could you please try the below patch to see if it is ok? The patch is based
> on today's linus' tree.

Hi Zhang,

I have applied your patch and the bug seems to be fixed.

Commit 89699605fe (mm: vmap area cache) suggests to use
"addr + size  < addr" instead of "addr + size - 1 < addr" so I guess
this is the correct fix.

thanks,
Daniel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
