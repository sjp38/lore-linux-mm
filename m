Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 611806B0337
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 10:39:17 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x125so223413299pgb.5
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 07:39:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z5si2027724pgn.339.2017.03.22.07.39.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 07:39:16 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2MEd3o6136073
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 10:39:15 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29b9vp156r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 10:39:14 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 22 Mar 2017 08:39:09 -0600
Subject: Re: [PATCH v1] mm, hugetlb: use pte_present() instead of
 pmd_present() in follow_huge_pmd()
References: <1490149898-20231-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <bd770cf9-c01c-dd50-bf6c-a50872f726ec@de.ibm.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Wed, 22 Mar 2017 15:39:00 +0100
MIME-Version: 1.0
In-Reply-To: <bd770cf9-c01c-dd50-bf6c-a50872f726ec@de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <a3acee49-9ad4-ee94-2e19-55f56fc7151d@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, linux-s390 <linux-s390@vger.kernel.org>

On 03/22/2017 01:53 PM, Christian Borntraeger wrote:
> On 03/22/2017 03:31 AM, Naoya Horiguchi wrote:
>> I found the race condition which triggers the following bug when
>> move_pages() and soft offline are called on a single hugetlb page
>> concurrently.
>>
>>     [61163.578957] Soft offlining page 0x119400 at 0x700000000000
>>     [61163.580062] BUG: unable to handle kernel paging request at ffffea0011943820
>>     [61163.580791] IP: follow_huge_pmd+0x143/0x190
>>     [61163.581203] PGD 7ffd2067
>>     [61163.581204] PUD 7ffd1067
>>     [61163.581471] PMD 0
>>     [61163.581723]
>>     [61163.582052] Oops: 0000 [#1] SMP
>>     [61163.582349] Modules linked in: binfmt_misc ppdev virtio_balloon parport_pc pcspkr i2c_piix4 parport i2c_core acpi_cpufreq ip_tables xfs libcrc32c ata_generic pata_acpi virtio_blk 8139too crc32c_intel ata_piix serio_raw libata virtio_pci 8139cp virtio_ring virtio mii floppy dm_mirror dm_region_hash dm_log dm_mod [last unloaded: cap_check]
>>     [61163.585130] CPU: 0 PID: 22573 Comm: iterate_numa_mo Tainted: P           OE   4.11.0-rc2-mm1+ #2
>>     [61163.586055] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
>>     [61163.586627] task: ffff88007c951680 task.stack: ffffc90004bd8000
>>     [61163.587181] RIP: 0010:follow_huge_pmd+0x143/0x190
>>     [61163.587622] RSP: 0018:ffffc90004bdbcd0 EFLAGS: 00010202
>>     [61163.588096] RAX: 0000000465003e80 RBX: ffffea0004e34d30 RCX: 00003ffffffff000
>>     [61163.588818] RDX: 0000000011943800 RSI: 0000000000080001 RDI: 0000000465003e80
>>     [61163.589486] RBP: ffffc90004bdbd18 R08: 0000000000000000 R09: ffff880138d34000
>>     [61163.590097] R10: ffffea0004650000 R11: 0000000000c363b0 R12: ffffea0011943800
>>     [61163.590751] R13: ffff8801b8d34000 R14: ffffea0000000000 R15: 000077ff80000000
>>     [61163.591375] FS:  00007fc977710740(0000) GS:ffff88007dc00000(0000) knlGS:0000000000000000
>>     [61163.592068] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>     [61163.592627] CR2: ffffea0011943820 CR3: 000000007a746000 CR4: 00000000001406f0
>>     [61163.593330] Call Trace:
>>     [61163.593556]  follow_page_mask+0x270/0x550
>>     [61163.593908]  SYSC_move_pages+0x4ea/0x8f0
>>     [61163.594253]  ? lru_cache_add_active_or_unevictable+0x4b/0xd0
>>     [61163.594798]  SyS_move_pages+0xe/0x10
>>     [61163.595113]  do_syscall_64+0x67/0x180
>>     [61163.595434]  entry_SYSCALL64_slow_path+0x25/0x25
>>     [61163.595837] RIP: 0033:0x7fc976e03949
>>     [61163.596148] RSP: 002b:00007ffe72221d88 EFLAGS: 00000246 ORIG_RAX: 0000000000000117
>>     [61163.596940] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007fc976e03949
>>     [61163.597567] RDX: 0000000000c22390 RSI: 0000000000001400 RDI: 0000000000005827
>>     [61163.598177] RBP: 00007ffe72221e00 R08: 0000000000c2c3a0 R09: 0000000000000004
>>     [61163.598842] R10: 0000000000c363b0 R11: 0000000000000246 R12: 0000000000400650
>>     [61163.599456] R13: 00007ffe72221ee0 R14: 0000000000000000 R15: 0000000000000000
>>     [61163.600067] Code: 81 e4 ff ff 1f 00 48 21 c2 49 c1 ec 0c 48 c1 ea 0c 4c 01 e2 49 bc 00 00 00 00 00 ea ff ff 48 c1 e2 06 49 01 d4 f6 45 bc 04 74 90 <49> 8b 7c 24 20 40 f6 c7 01 75 2b 4c 89 e7 8b 47 1c 85 c0 7e 2a
>>     [61163.601845] RIP: follow_huge_pmd+0x143/0x190 RSP: ffffc90004bdbcd0
>>     [61163.602376] CR2: ffffea0011943820
>>     [61163.602767] ---[ end trace e4f81353a2d23232 ]---
>>     [61163.603236] Kernel panic - not syncing: Fatal exception
>>     [61163.603706] Kernel Offset: disabled
>>
>> This bug is triggered when pmd_present() returns true for non-present
>> hugetlb, so fixing the present check in follow_huge_pmd() prevents it.
>> Using pmd_present() to determine present/non-present for hugetlb is
>> not correct, because pmd_present() checks multiple bits (not only
>> _PAGE_PRESENT) for historical reason and it can misjudge hugetlb state.
>>
>> Fixes: e66f17ff7177 ("mm/hugetlb: take page table lock in follow_huge_pmd()")
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: <stable@vger.kernel.org>        [4.0+]
> 
> I think this is broken for s390. The page table entries look different from
> the segment table entries (pmds) on s390, e.g. they have the invalid bit at
> different places. Using pte functions on pmd does not work here.
> Gerald can you confirm.
> 


Hmmm, it looks like that the s390 variant of huge_ptep_get already
does the translation. So its probably fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
