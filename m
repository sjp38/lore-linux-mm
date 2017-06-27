Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2196B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:13:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id z5so3617797wmz.4
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 00:13:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v17si13551668wra.112.2017.06.27.00.13.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 00:13:33 -0700 (PDT)
Subject: Re: next-20170620 BUG in do_page_fault / do_huge_pmd_wp_page
References: <20815.1498188418@turing-police.cc.vt.edu>
 <CA+G9fYvpDRb2VLpXC1yiYZGbqO23dMAix4Ra2+8vhzFoc=MdZQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dde0cb3d-ffa2-f90d-fe21-26cf5dd9383c@suse.cz>
Date: Tue, 27 Jun 2017 09:13:31 +0200
MIME-Version: 1.0
In-Reply-To: <CA+G9fYvpDRb2VLpXC1yiYZGbqO23dMAix4Ra2+8vhzFoc=MdZQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naresh Kamboju <naresh.kamboju@linaro.org>, valdis.kletnieks@vt.edu
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

+CC Kirill, those 512 numbers smell like THP related.

On 06/23/2017 07:48 AM, Naresh Kamboju wrote:
> Hi Valdis,
> 
> On 23 June 2017 at 08:56,  <valdis.kletnieks@vt.edu> wrote:
>> Saw this at boot of next-20170620.  Not sure how I managed to hit 4 BUG in a row...
>>
>> Looked in 'git log -- mm/' but not seeing anything blatantly obvious.
>>
>> This ringing any bells?  I'm not in a position to recreate or bisect this until
>> the weekend.
>>
>> [  315.409076] BUG: Bad rss-counter state mm:ffff8a223deb4640 idx:0 val:-512
>> [  315.412889] BUG: Bad rss-counter state mm:ffff8a223deb4640 idx:1 val:512
>> [  315.416694] BUG: non-zero nr_ptes on freeing mm: 1
>> [  315.436098] BUG: Bad page state in process gdm  pfn:3e8400
>> [  315.439802] page:ffffe8af0fa10000 count:-1 mapcount:0 mapping:          (null) index:0x1
>> [  315.443264] flags: 0x4000000000000000()
>> [  315.446715] raw: 4000000000000000 0000000000000000 0000000000000001 ffffffffffffffff
>> [  315.450181] raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
>> [  315.453628] page dumped because: nonzero _count
>> [  315.457023] Modules linked in: ts_bm nf_log_ipv4 xt_string nf_log_ipv6 nf_log_common xt_LOG sunrpc vfat fat brcmsmac cordic brcmutil dell
>> _wmi x86_pkg_temp_thermal crct10dif_pclmul dell_laptop crc32_pclmul crc32c_intel dell_smbios ghash_clmulni_intel dell_smm_hwmon cryptd bcma
>> mei_wdt dell_smo8800 dell_rbtn sch_fq tcp_bbr
>> [  315.457116] CPU: 3 PID: 6684 Comm: gdm Not tainted 4.12.0-rc6-next-20170620 #506
>> [  315.457119] Hardware name: Dell Inc. Latitude E6530/07Y85M, BIOS A19 01/04/2017
>> [  315.457122] Call Trace:
>> [  315.457131]  dump_stack+0x83/0xd1
>> [  315.457141]  bad_page+0x10c/0x1b0
>> [  315.457151]  check_new_page_bad+0x12e/0x180
>> [  315.457159]  get_page_from_freelist+0x756/0x1840
>> [  315.457170]  ? native_sched_clock+0x80/0xf0
>> [  315.457184]  ? find_held_lock+0x38/0x160
>> [  315.457194]  __alloc_pages_nodemask+0x145/0x5a0
>> [  315.457211]  do_huge_pmd_wp_page+0x58d/0x1380
>> [  315.457217]  ? cyc2ns_read_begin+0x82/0xb0
>> [  315.457224]  ? cyc2ns_read_end+0x22/0x40
>> [  315.457229]  ? native_sched_clock+0x80/0xf0
>> [  315.457236]  ? native_sched_clock+0x80/0xf0
>> [  315.457247]  __handle_mm_fault+0x831/0x14e0
>> [  315.457253]  ? sched_clock_cpu+0x1b/0x1e0
>> [  315.457273]  handle_mm_fault+0x23c/0x6f0
>> [  315.457283]  __do_page_fault+0x460/0x950
>> [  315.457298]  do_page_fault+0xc/0x10
>> [  315.457305]  page_fault+0x22/0x30
>> [  315.457310] RIP: 0033:0x7fe15390e5c1
>> [  315.457314] RSP: 002b:00007ffd2acdca30 EFLAGS: 00010202
>> [  315.457320] RAX: 0000000000000000 RBX: 00007ffd2acdca50 RCX: 0000000000000000
>> [  315.457324] RDX: 0000000000801000 RSI: 00007fe14bfff9c0 RDI: 00007fe14b7fec10
>> [  315.457328] RBP: 00007ffd2acdcac0 R08: 00007fe14b7fed10 R09: 00007fe153b22030
>> [  315.457331] R10: 00007fe155346900 R11: 0000000000000202 R12: 0000000000000000
>> [  315.457335] R13: 0000000000000000 R14: 0000000000000001 R15: 00007fe155413000
>> [  315.457354] Disabling lock debugging due to kernel taint
>>
>>
>>
> 
> 
> This bug occurred on HiKey (arm64) while booting.
> Here is the boot log,
> 
> Linux version:
> -------------------
> Linux version 4.12.0-rc6-next-20170622 (buildslave@x86-64-08) (gcc
> version 6.2.1 20161016 (Linaro GCC 6.2-2016.11)) #1 SMP PREEMPT Thu
> Jun 22 15:54:05 UTC 2017
> 
> Error log:
> -------------
> [    8.759348] BUG: Bad page state in process dockerd  pfn:6f800
> [    8.765806] page:ffff7e0001be0000 count:-1 mapcount:0 mapping:
>     (null) index:0x1
> [    8.774115] flags: 0xfffc00000000000()
> [    8.777970] raw: 0fffc00000000000 0000000000000000 0000000000000001
> ffffffffffffffff
> [    8.785915] raw: dead000000000100 dead000000000200 0000000000000000
> 0000000000000000
> [    8.793857] page dumped because: nonzero _count
> [    8.798506] Modules linked in: asix usbnet adv7511 dw_drm_dsi
> kirin_drm drm_kms_helper drm fuse
> [    8.812369] CPU: 6 PID: 2419 Comm: dockerd Not tainted
> 4.12.0-rc6-next-20170622 #1
> [    8.825053] Hardware name: HiKey Development Board (DT)
> [    8.835330] Call trace:
> [    8.842735] [<ffff000008089b50>] dump_backtrace+0x0/0x230
> [    8.853141] [<ffff000008089e44>] show_stack+0x14/0x20
> [    8.863121] [<ffff000008afbb20>] dump_stack+0xb8/0xf0
> [    8.873018] [<ffff0000081ffa94>] bad_page+0xe4/0x148
> [    8.882766] [<ffff0000081ffc04>] check_new_page_bad+0x64/0xa0
> [    8.893262] [<ffff0000082044ec>] get_page_from_freelist+0xab4/0xca0
> [    8.904251] [<ffff000008204ca4>] __alloc_pages_nodemask+0x10c/0x1328
> [    8.915273] [<ffff000008262d30>] alloc_pages_current+0x80/0xe8
> [    8.925737] [<ffff0000081f91d0>] __page_cache_alloc+0xf8/0x128
> [    8.936138] [<ffff00000820cf48>] __do_page_cache_readahead+0x128/0x340
> [    8.947212] [<ffff0000081fba40>] filemap_fault+0x328/0x6c8
> [    8.957166] [<ffff0000083589c0>] ext4_filemap_fault+0x30/0x50
> [    8.967394] [<ffff00000823a2a0>] __do_fault+0x20/0x88
> [    8.976907] [<ffff00000824058c>] __handle_mm_fault+0x97c/0x10d0
> [    8.987311] [<ffff000008240e88>] handle_mm_fault+0x1a8/0x338
> [    8.997385] [<ffff000008b19980>] do_page_fault+0x2c0/0x3d0
> [    9.007222] [<ffff000008081388>] do_mem_abort+0x40/0x98
> [    9.016720] Exception stack(0xffff800073b63e20 to 0xffff800073b63f50)
> [    9.027469] 3e20: 0000000000000200 000080006ee78000
> ffffffffffffffff 0000000000426724
> [    9.039643] 3e40: 0000000000000200 000080006ee78000
> ffff800073b63ec0 000000000047ac20
> [    9.051783] 3e60: 0000000060000000 0000000000000015
> 0000000000000124 000000000047ac20
> [    9.063889] 3e80: 0000000000000000 ffff0000080837d8
> 0000000000000200 000080006ee78000
> [    9.075945] 3ea0: ffffffffffffffff 000000000047ac20
> 0000000060000000 0000000000000015
> [    9.087975] 3ec0: 0000000000000000 0000000000000000
> 000000481ffff9fd 0000000000000004
> [    9.099910] 3ee0: 0000000001a5e1e0 0000000000001808
> 0000000000000005 0000000000000010
> [    9.111772] 3f00: 0000000000000062 0000000000000030
> 0000000001faebb4 0000000000000000
> [    9.123614] 3f20: 0000000000000039 0000000000000000
> 0000000000000000 0000000000000040
> [    9.135437] 3f40: 0000004820051ed8 0000000001fb6a00
> [    9.144221] [<ffff0000080833b4>] el0_da+0x20/0x24
> [    9.152697] Disabling lock debugging due to kernel taint
> [    9.161887] BUG: Bad rss-counter state mm:ffff800073dec800 idx:0 val:-512
> [    9.172421] BUG: Bad rss-counter state mm:ffff800073dec800 idx:1 val:512
> [    9.182760] BUG: non-zero nr_ptes on freeing mm: 1
> 
> 
> Detailed boot log link,
> https://lkft.validation.linaro.org/scheduler/job/3855#L1090
> 
> - Naresh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
