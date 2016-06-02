Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB2E16B0253
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 09:27:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a136so27497799wme.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 06:27:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vx5si758418wjc.33.2016.06.02.06.27.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 06:27:45 -0700 (PDT)
Subject: Re: [linux-next-20160602] kernel BUG at mm/rmap.c:1253!
References: <201606022014.GFF87050.FJOLVOMQHFOtSF@I-love.SAKURA.ne.jp>
 <20160602115046.GA2001@dhcp22.suse.cz> <20160602115949.GL1995@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0fae9e1d-dde8-90fe-ecc4-386307c6d623@suse.cz>
Date: Thu, 2 Jun 2016 15:27:43 +0200
MIME-Version: 1.0
In-Reply-To: <20160602115949.GL1995@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>

On 06/02/2016 01:59 PM, Michal Hocko wrote:
> [CCing Ebru]
>
> On Thu 02-06-16 13:50:46, Michal Hocko wrote:
>> [CCing Andrea and Kirill]
>
> Hmm, thinking about it little bit more it might be related to "mm, thp:
> make swapin readahead under down_read of mmap_sem". I didn't get to look
> closer at the patch but maybe revalidate after mmap sem is dropped is
> not sufficient.

I've noticed locking imbalance in the patch as pointed out in the 
Sergey's thread about deadlock [1]

I imagine it's possible that the wrong mmap_sem handling can also 
violate critical section protections and result in this report?

[1] http://marc.info/?i=0c47a3a0-5530-b257-1c1f-28ed44ba97e6%40suse.cz%3E

>> On Thu 02-06-16 20:14:38, Tetsuo Handa wrote:
>>> FYI, I hit this bug while compiling kernel. Is this known issue?
>>>
>>> ----------------------------------------
>>> [ 2893.482222] vma ffff880014150428 start 00002afed7db3000 end 00002afed89bc000
>>> next ffff8800106b7de8 prev ffff880014150a58 mm ffff88007a9e8d40
>>> prot 8000000000000025 anon_vma ffff880016c19d18 vm_ops           (null)
>>> pgoff 2afed7db3 file           (null) private_data           (null)
>>> flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
>>> [ 2893.490801] ------------[ cut here ]------------
>>> [ 2893.492087] kernel BUG at mm/rmap.c:1253!
>>> [ 2893.493240] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>> [ 2893.494789] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter coretemp pcspkr sg vmw_vmci i2c_piix4 ip_tables sd_mod ata_generic pata_acpi serio_raw ata_piix vmwgfx mptspi ahci drm_kms_helper syscopyarea libahci scsi_transport_spi sysfillrect sysimgblt mptscsih fb_sys_fops libata e1000 ttm mptbase drm i2c_core
>>> [ 2893.509843] CPU: 0 PID: 50 Comm: khugepaged Not tainted 4.7.0-rc1-next-20160602 #431
>>> [ 2893.512105] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
>>> [ 2893.515024] task: ffff88007c036440 ti: ffff88007c040000 task.ti: ffff88007c040000
>>> [ 2893.517340] RIP: 0010:[<ffffffff811ca46c>]  [<ffffffff811ca46c>] page_add_new_anon_rmap+0x13c/0x180
>>> [ 2893.519977] RSP: 0018:ffff88007c043ce8  EFLAGS: 00010246
>>> [ 2893.521917] RAX: 0000000000000149 RBX: ffffea00001b0000 RCX: 0000000000000000
>>> [ 2893.524218] RDX: 0000000000000000 RSI: ffffffff819e92ea RDI: 00000000ffffffff
>>> [ 2893.526451] RBP: ffff88007c043d08 R08: 0000000000000001 R09: 0000000000000001
>>> [ 2893.528822] R10: 0000000000000001 R11: 000000000000058e R12: ffff880014150428
>>> [ 2893.531306] R13: 00002afed8a00000 R14: 0000000000000200 R15: ffff880014150428
>>> [ 2893.533699] FS:  0000000000000000(0000) GS:ffff88007f800000(0000) knlGS:0000000000000000
>>> [ 2893.536250] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> [ 2893.538309] CR2: 00002acb71513220 CR3: 0000000001c06000 CR4: 00000000001406f0
>>> [ 2893.540777] Stack:
>>> [ 2893.542230]  8000000006c000e7 ffffea0001e55000 0000000000000001 ffffea00001b0000
>>> [ 2893.544867]  ffff88007c043e60 ffffffff811fb292 0000000000000000 0000000000000000
>>> [ 2893.547490]  ffff88007c036440 ffff88007c036440 ffff88007c036440 ffff88007c036440
>>> [ 2893.550048] Call Trace:
>>> [ 2893.551498]  [<ffffffff811fb292>] khugepaged+0x1552/0x25c0
>>> [ 2893.553487]  [<ffffffff810bfda0>] ? prepare_to_wait_event+0xf0/0xf0
>>> [ 2893.555705]  [<ffffffff811f9d40>] ? vmf_insert_pfn_pmd+0x170/0x170
>>> [ 2893.557981]  [<ffffffff81093b0e>] kthread+0xee/0x110
>>> [ 2893.560040]  [<ffffffff8172a17f>] ret_from_fork+0x1f/0x40
>>> [ 2893.562302]  [<ffffffff81093a20>] ? kthread_create_on_node+0x220/0x220
>>> [ 2893.564690] Code: e8 2a e9 ff ff 5b 41 5c 41 5d 41 5e 5d c3 48 8b 43 20 a8 01 0f 85 37 ff ff ff c7 43 18 00 00 00 00 eb 9b 4c 89 e7 e8 f4 d1 fe ff <0f> 0b 48 83 e8 01 e9 07 ff ff ff 48 c7 c6 40 6b 9b 81 48 89 df
>>> [ 2893.572649] RIP  [<ffffffff811ca46c>] page_add_new_anon_rmap+0x13c/0x180
>>> [ 2893.574980]  RSP <ffff88007c043ce8>
>>> [ 2893.583817] ---[ end trace 994b25e4ac8d495c ]---
>>> [ 2893.585665] note: khugepaged[50] exited with preempt_count 1
>>> ----------------------------------------
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>> --
>> Michal Hocko
>> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
