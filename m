Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB5A6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 21:01:30 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so125623312pdb.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 18:01:30 -0700 (PDT)
Received: from mgwkm01.jp.fujitsu.com (mgwkm01.jp.fujitsu.com. [202.219.69.168])
        by mx.google.com with ESMTPS id ff2si67116214pab.12.2015.06.29.18.01.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 18:01:29 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 8AF0DAC04B2
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 10:01:24 +0900 (JST)
Message-ID: <5591EA50.1000000@jp.fujitsu.com>
Date: Tue, 30 Jun 2015 10:01:04 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 7/8] mm: add the buddy system interface
References: <558E084A.60900@huawei.com> <558E0A28.6060607@huawei.com> <3908561D78D1C84285E8C5FCA982C28F32AA124A@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32AA124A@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, "leon@leon.nu" <leon@leon.nu>, "Hansen, Dave" <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/30 8:11, Luck, Tony wrote:
>> @@ -814,7 +814,7 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
>>    */
>>   int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
>>   {
>> -	system_has_some_mirror = true;
>> +	static_key_slow_inc(&system_has_mirror);
>>
>>   	return memblock_setclr_flag(base, size, 1, MEMBLOCK_MIRROR);
>>   }
>
> This generates some WARN_ON noise when called from efi_find_mirror():
>

It seems jump_label_init() is called after memory initialization. (init/main.c::start_kernel())
So, it may be difficut to use static_key function for our purpose because
kernel memory allocation may occur before jump_label is ready.

Thanks,
-Kame

> [    0.000000] e820: last_pfn = 0x7b800 max_arch_pfn = 0x400000000
> [    0.000000] ------------[ cut here ]------------
> [    0.000000] WARNING: CPU: 0 PID: 0 at kernel/jump_label.c:61 static_key_slow_inc+0x57/0xc0()
> [    0.000000] static_key_slow_inc used before call to jump_label_init
> [    0.000000] Modules linked in:
>
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.1.0 #4
> [    0.000000] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS BRHSXSD1.86B.0065.R01.1505011640 05/01/2015
> [    0.000000]  0000000000000000 ee366a8dff38f745 ffffffff81997d68 ffffffff816683b4
> [    0.000000]  0000000000000000 ffffffff81997dc0 ffffffff81997da8 ffffffff8107b0aa
> [    0.000000]  ffffffff81d48822 ffffffff81f281a0 0000000040000000 0000001fcb7a4000
> [    0.000000] Call Trace:
> [    0.000000]  [<ffffffff816683b4>] dump_stack+0x45/0x57
> [    0.000000]  [<ffffffff8107b0aa>] warn_slowpath_common+0x8a/0xc0
> [    0.000000]  [<ffffffff8107b135>] warn_slowpath_fmt+0x55/0x70
> [    0.000000]  [<ffffffff81660273>] ? memblock_add_range+0x175/0x19e
> [    0.000000]  [<ffffffff81176c57>] static_key_slow_inc+0x57/0xc0
> [    0.000000]  [<ffffffff81660655>] memblock_mark_mirror+0x19/0x33
> [    0.000000]  [<ffffffff81b12c18>] efi_find_mirror+0x59/0xdd
> [    0.000000]  [<ffffffff81afb8a6>] setup_arch+0x642/0xccf
> [    0.000000]  [<ffffffff81af3120>] ? early_idt_handler_array+0x120/0x120
> [    0.000000]  [<ffffffff81663480>] ? printk+0x55/0x6b
> [    0.000000]  [<ffffffff81af3120>] ? early_idt_handler_array+0x120/0x120
> [    0.000000]  [<ffffffff81af3d93>] start_kernel+0xe8/0x4eb
> [    0.000000]  [<ffffffff81af3120>] ? early_idt_handler_array+0x120/0x120
> [    0.000000]  [<ffffffff81af3120>] ? early_idt_handler_array+0x120/0x120
> [    0.000000]  [<ffffffff81af35ee>] x86_64_start_reservations+0x2a/0x2c
> [    0.000000]  [<ffffffff81af373c>] x86_64_start_kernel+0x14c/0x16f
> [    0.000000] ---[ end trace baa7fa0514e3bc58 ]---
> [    0.000000] ------------[ cut here ]------------
>
>
>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
