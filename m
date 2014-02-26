Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7AF6B0073
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 03:14:37 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id hm4so1796678wib.1
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 00:14:36 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id fq5si9677083wic.50.2014.02.26.00.14.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 00:14:36 -0800 (PST)
Message-ID: <530DA208.2080109@huawei.com>
Date: Wed, 26 Feb 2014 16:12:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mm: OS boot failed when set command-line kmemcheck=1
References: <5304558F.9050605@huawei.com> <alpine.DEB.2.02.1402182344001.3551@chino.kir.corp.google.com> <53047AE6.4060403@huawei.com> <alpine.DEB.2.02.1402191422240.31921@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402191422240.31921@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Robert Richter <rric@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Stephane Eranian <eranian@google.com>, Pekka Enberg <penberg@kernel.org>, Vegard Nossum <vegard.nossum@gmail.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2014/2/20 6:24, David Rientjes wrote:

> On Wed, 19 Feb 2014, Xishi Qiu wrote:
> 
>> Here is a warning, I don't whether it is relative to my hardware.
>> If set "kmemcheck=1 nowatchdog", it can boot.
>>
>> code:
>> 	...
>> 	pte = kmemcheck_pte_lookup(address);
>> 	if (!pte)
>> 		return false;
>>
>> 	WARN_ON_ONCE(in_nmi());
>>
>> 	if (error_code & 2)
>> 	...
>>
>> log:
>> [   10.920683] WARNING: CPU: 0 PID: 1 at arch/x86/mm/kmemcheck/kmemcheck.c:640 k
>> memcheck_fault+0xb1/0xc0()
>> [   10.920684] Modules linked in:
>> [   10.920686] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc3-0.1-default+
>>  #3
>> [   10.920687] Hardware name: Huawei Technologies Co., Ltd. Tecal RH2285 V2-24S/
>> BC11SRSC1, BIOS RMISV055 02/02/2013
>> [   10.920690]  0000000000000280 ffff88085f807678 ffffffff814ca491 ffff88085f807
>> 6b8
>> [   10.920693]  ffffffff8104ce97 0000000000000000 ffff88085f807838 ffff88085f420
>> 5d4
>> [   10.920695]  0000000000000000 0000000000000000 ffff88085f4205d4 ffff88085f807
>> 6c8
>> [   10.920695] Call Trace:
>> [   10.920701]  <NMI>  [<ffffffff814ca491>] dump_stack+0x6a/0x79
>> [   10.920705]  [<ffffffff8104ce97>] warn_slowpath_common+0x87/0xb0
>> [   10.920707]  [<ffffffff8104ced5>] warn_slowpath_null+0x15/0x20
>> [   10.920710]  [<ffffffff810452c1>] kmemcheck_fault+0xb1/0xc0
>> [   10.920714]  [<ffffffff814d262b>] __do_page_fault+0x39b/0x4c0
>> [   10.920718]  [<ffffffff81272cd2>] ? put_dec+0x72/0x90
>> [   10.920720]  [<ffffffff812730ba>] ? number+0x33a/0x360
>> [   10.920723]  [<ffffffff814d2829>] do_page_fault+0x9/0x10
>> [   10.920726]  [<ffffffff814cf222>] page_fault+0x22/0x30
>> [   10.920731]  [<ffffffff81348b4c>] ? vt_console_print+0x8c/0x400
>> [   10.920733]  [<ffffffff81348b2c>] ? vt_console_print+0x6c/0x400
>> [   10.920737]  [<ffffffff8109cd9b>] ? msg_print_text+0x18b/0x1f0
>> [   10.920739]  [<ffffffff8109bed1>] call_console_drivers+0xc1/0xe0
>> [   10.920741]  [<ffffffff8109d746>] console_unlock+0x236/0x280
>> [   10.920744]  [<ffffffff8109e095>] vprintk_emit+0x2b5/0x450
>> [   10.920746]  [<ffffffff810452c1>] ? kmemcheck_fault+0xb1/0xc0
>> [   10.920748]  [<ffffffff814ca3f7>] printk+0x4a/0x4c
>> [   10.920750]  [<ffffffff810452c1>] ? kmemcheck_fault+0xb1/0xc0
>> [   10.920753]  [<ffffffff8104ce4e>] warn_slowpath_common+0x3e/0xb0
>> [   10.920755]  [<ffffffff8104ced5>] warn_slowpath_null+0x15/0x20
>> [   10.920757]  [<ffffffff810452c1>] kmemcheck_fault+0xb1/0xc0
>> [   10.920760]  [<ffffffff814d262b>] __do_page_fault+0x39b/0x4c0
>> [   10.920763]  [<ffffffff814d2829>] do_page_fault+0x9/0x10
>> [   10.920765]  [<ffffffff814cf222>] page_fault+0x22/0x30
>> [   10.920769]  [<ffffffff81015b52>] ? x86_perf_event_update+0x2/0x70
>> [   10.920772]  [<ffffffff8101de21>] ? intel_pmu_save_and_restart+0x11/0x50
>> [   10.920774]  [<ffffffff8101eb02>] intel_pmu_handle_irq+0x142/0x3a0
>> [   10.920777]  [<ffffffff814d0655>] perf_event_nmi_handler+0x35/0x60
>> [   10.920779]  [<ffffffff814cfe83>] nmi_handle+0x63/0x150
>> [   10.920782]  [<ffffffff814cffd3>] default_do_nmi+0x63/0x290
>> [   10.920784]  [<ffffffff814d02a8>] do_nmi+0xa8/0xe0
>> [   10.920786]  [<ffffffff814cf527>] end_repeat_nmi+0x1e/0x2e
>> [   10.920789]  [<ffffffff814cf0f0>] ? retint_signal+0x78/0x78
>> [   10.920791]  [<ffffffff814cf0f0>] ? retint_signal+0x78/0x78
>> [   10.920793]  [<ffffffff814cf0f0>] ? retint_signal+0x78/0x78
>> [   10.920799]  <<EOE>>  <#DB>  [<ffffffff81306b53>] ? acpi_ns_walk_namespace+0x
>> 98/0x251
>>
> 
> I added some perf events and kmemcheck people to the cc list.  This 
> appears to happen during an NMI when faulting in struct perf_sample_data 
> data.
> 

Hi David,

Can you try our config or if you can send us your config?

Thanks,
Xishi Qiu

...
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_KMEMCHECK=y
# CONFIG_KMEMCHECK_DISABLED_BY_DEFAULT is not set
# CONFIG_KMEMCHECK_ENABLED_BY_DEFAULT is not set
CONFIG_KMEMCHECK_ONESHOT_BY_DEFAULT=y
CONFIG_KMEMCHECK_QUEUE_SIZE=64
CONFIG_KMEMCHECK_SHADOW_COPY_SHIFT=5
CONFIG_KMEMCHECK_PARTIAL_OK=y
# CONFIG_KMEMCHECK_BITOPS_OK is not set
...

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
