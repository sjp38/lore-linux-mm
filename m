Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 528B46B02F2
	for <linux-mm@kvack.org>; Mon,  1 May 2017 21:52:39 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id h41so67290959ioi.1
        for <linux-mm@kvack.org>; Mon, 01 May 2017 18:52:39 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id 198si14514540ioc.80.2017.05.01.18.52.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 May 2017 18:52:38 -0700 (PDT)
Message-ID: <5907E524.2030003@huawei.com>
Date: Tue, 2 May 2017 09:47:16 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [RESENT PATCH] x86/mem: fix the offset overflow when read/write
 mem
References: <1493293775-57176-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1493293775-57176-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: arnd@arndb.de, hannes@cmpxchg.org, kirill@shutemov.name, rientjes@google.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

ping ....

anyone has any objections.
On 2017/4/27 19:49, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> Recently, I found the following issue, it will result in the panic.
>
> [  168.739152] mmap1: Corrupted page table at address 7f3e6275a002
> [  168.745039] PGD 61f4a1067
> [  168.745040] PUD 61ab19067
> [  168.747730] PMD 61fb8b067
> [  168.750418] PTE 8000100000000225
> [  168.753109]
> [  168.757795] Bad pagetable: 000d [#1] SMP
> [  168.761696] Modules linked in: intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pcbc aesni_intel crypto_simd iTCO_wdt glue_helper cryptd sg iTCO_vendor_support i7core_edac edac_core shpchp lpc_ich i2c_i801 pcspkr mfd_core acpi_cpufreq ip_tables xfs libcrc32c sd_mod igb ata_generic ptp pata_acpi pps_core mptsas ata_piix scsi_transport_sas i2c_algo_bit libata mptscsih i2c_core serio_raw crc32c_intel bnx2 mptbase dca dm_mirror dm_region_hash dm_log dm_mod
> [  168.805983] CPU: 15 PID: 10369 Comm: mmap1 Not tainted 4.11.0-rc2-327.28.3.53.x86_64+ #345
> [  168.814202] Hardware name: Huawei Technologies Co., Ltd. Tecal RH2285          /BC11BTSA              , BIOS CTSAV036 04/27/2011
> [  168.825704] task: ffff8806207d5200 task.stack: ffffc9000c340000
> [  168.831592] RIP: 0033:0x7f3e622c5360
> [  168.835147] RSP: 002b:00007ffe2bb7a098 EFLAGS: 00010203
> [  168.840344] RAX: 00007ffe2bb7a0c0 RBX: 0000000000000000 RCX: 00007f3e6275a000
> [  168.847439] RDX: 00007f3e622c5360 RSI: 00007f3e6275a000 RDI: 00007ffe2bb7a0c0
> [  168.854535] RBP: 00007ffe2bb7a4e0 R08: 00007f3e621c3d58 R09: 000000000000002d
> [  168.861632] R10: 00007ffe2bb79e20 R11: 00007f3e622fbcb0 R12: 00000000004005d0
> [  168.868728] R13: 00007ffe2bb7a5c0 R14: 0000000000000000 R15: 0000000000000000
> [  168.875825] FS:  00007f3e62752740(0000) GS:ffff880627bc0000(0000) knlGS:0000000000000000
> [  168.883870] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  168.889583] CR2: 00007f3e6275a002 CR3: 0000000622845000 CR4: 00000000000006e0
> [  168.896680] RIP: 0x7f3e622c5360 RSP: 00007ffe2bb7a098
> [  168.901713] ---[ end trace ef98fa9f2a01cbc6 ]---
> [  168.90630 arch/x86/kernel/smp.c:127 native_smp_send_reschedule+0x3f/0x50
> [  168.935410] Modules linked in: intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pcbc aesni_intel crypto_simd iTCO_wdt glue_helper cryptd sg iTCO_vendor_support i7core_edac edac_core shpchp lpc_ich i2c_i801 pcspkr mfd_core acpi_cpufreq ip_tables xfs libcrc32c sd_mod igb ata_generic ptp pata_acpi pps_core mptsas ata_piix scsi_transport_sas i2c_algo_bit libata mptscsih i2c_core serio_raw crc32c_intel bnx2 mptbase dca dm_mirror dm_region_hash dm_log dm_mod
> [  168.979686] CPU: 15 PID: 10369 Comm: mmap1 Tainted: G      D         4.11.0-rc2-327.28.3.53.x86_64+ #345
> [  168.989114] Hardware name: Huawei Technologies Co., Ltd. Tecal RH2285          /BC11BTSA              , BIOS CTSAV036 04/27/2011
> [  169.000616] Call Trace:
> [  169.003049]  <IRQ>
> [  169.005050]  dump_stack+0x63/0x84
> [  169.008348]  __warn+0xd1/0xf0
> [  169.011297]  warn_slowpath_null+0x1d/0x20
> [  169.015282]  native_smp_send_reschedule+0x3f/0x50
> [  169.019961]  resched_curr+0xa1/0xc0
> [  169.023428]  check_preempt_curr+0x70/0x90
> [  169.027415]  ttwu_do_wakeup+0x1e/0x160
> [  169.031142]  ttwu_do_activate+0x77/0x80
> [  169.034956]  try_to_wake_up+0x1c3/0x430
> [  169.038771]  default_wake_function+0x12/0x20
> [  169.043019]  __wake_up_common+0x55/0x90
> [  169.046833]  __wake_up_locked+0x13/0x20
> [  169.050649]  ep_poll_callback+0xbb/0x240
> [  169.054550]  __wake_up_common+0x55/0x90
> [  169.058363]  __wake_up+0x39/0x50
> [  169.061574]  wake_up_klogd_work_func+0x40/0x60
> [  169.065994]  irq_work_run_list+0x4d/0x70
> [  169.069895]  irq_work_tick+0x40/0x50
> [  169.073452]  update_process_times+0x42/0x60
> [  169.077612]  tick_periodic+0x2b/0x80
> [  169.081166]  tick_handle_periodic+0x25/0x70
> [  169.085326]  local_apic_timer_interrupt+0x35/0x60
> [  169.090004]  smp_apic_timer_interrupt+0x38/0x50
> [  169.094507]  apic_timer_interrupt+0x93/0xa0
> [  169.098667] RIP: 0010:panic+0x1f5/0x239
> [  169.102480] RSP: 0000:ffffc9000c343dd8 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff10
> [  169.110010] RAX: 0000000000000034 RBX: 0000000000000000 RCX: 0000000000000006
> [  169.117106] RDX: 0000000000000000 RSI: 0000000000000086 RDI: ffff880627bcdfe0
> [  169.124201] RBP: ffffc9000c343e48 R08: 00000000fffffffe R09: 0000000000000395
> [  169.131298] R10: 0000000000000005 R11: 0000000000000394 R12: ffffffff81a0c475
> [  169.138395] R13: 0000000000000000 R14: 0000000000000000 R15: 000000000000000d
> [  169.145491]  </IRQ>
> [  169.147578]  ? panic+0x1f1/0x239
> [  169.150789]  oops_end+0xb8/0xd0
> [  169.153910]  pgtable_bad+0x8a/0x95
> [  169.157294]  __do_page_fault+0x3aa/0x4a0
> [  169.161194]  do_page_fault+0x30/0x80
> [  169.164750]  ? do_syscall_64+0x175/0x180
> [  169.168649]  page_fault+0x28/0x30
>
> the following case can reproduce the issue.
>
> 	int  mem_fd = 0;
> 	char rw_buf[1024];
> 	unsigned char * map_base_s;
> 	unsigned long show_addr = 0x100000000000;
> 	unsigned long show_len  = 0x10;
>
> 	if(argc !=2 )
> 	{
> 		printf( "%s show_addr\n", argv[0] );
> 		return 0;
> 	}
> 	else
> 	{
> 		char *stop;
> 		show_addr = strtoul( argv[1], &stop, 0 );
> 		printf("show_addr= 0x%lu\n", show_addr );
> 	}
>
> 	mem_fd = open(DEV_NAME, O_RDONLY);
>     if (mem_fd == -1)
>     {
>         printf("open %s failed.", DEV_NAME);
>         return 0;
>     }
>
> 	map_base_s = mmap(NULL, show_len, PROT_READ, MAP_SHARED, mem_fd, show_addr);
> 	if ((long)map_base_s == -1)
> 	{
> 		printf("input address map to user space fail!\n");
> 		return 0;
> 	}
> 	else
>     {
>         printf("mmap successfull!\n");
>     }
>
> 	memcpy( rw_buf,  map_base_s, show_len );
>
> The pgoff is enough large, it exceed the size of the real memory.
> and the mmap can return the success.
>
> I fix it by checking the conditions. it can make it suitable for
> the mapped and use.
>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  drivers/char/mem.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/char/mem.c b/drivers/char/mem.c
> index 7e4a9d1..3a765e02 100644
> --- a/drivers/char/mem.c
> +++ b/drivers/char/mem.c
> @@ -55,7 +55,7 @@ static inline int valid_phys_addr_range(phys_addr_t addr, size_t count)
>  
>  static inline int valid_mmap_phys_addr_range(unsigned long pfn, size_t size)
>  {
> -	return 1;
> +	return (pfn << PAGE_SHIFT) + size <= __pa(high_memory);
>  }
>  #endif
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
