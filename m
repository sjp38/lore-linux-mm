Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D857B6B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 23:21:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w14-v6so11245797wrk.22
        for <linux-mm@kvack.org>; Wed, 02 May 2018 20:21:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j28-v6sor5666231wrd.78.2018.05.02.20.21.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 May 2018 20:21:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <17463682-dc08-358d-8b44-02821352604c@intel.com>
References: <20180419054047.xxiljmzaf2u7odc6@wfg-t540p.sh.intel.com> <17463682-dc08-358d-8b44-02821352604c@intel.com>
From: Huaitong Han <oenhan@gmail.com>
Date: Thu, 3 May 2018 11:20:51 +0800
Message-ID: <CAAuJbeKT1eBxT4Y8FgQBrQcFDU_3R8ad=s_8zsyj+GPiZT7VhQ@mail.gmail.com>
Subject: Re: BUG: Bad page map in process python2 pte:10000000000 pmd:17e8be067
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Huang Ying <ying.huang@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org

Hi, Dave

I have met the same issue now but in 3.10.0-514.16.1.el7.x86_64, the
issue also accurred in last November.

I read 3.10.0-514.16.1.el7.x86_64,  the bit9~13 is the swap type,
because  the swap has been swapoff on my machine,
for the "Bad swap file entry" error, the bit9~13 should be zero, but
"Unused swap file entry" error is exist although the
bit9~13 is zero.

The lower 12 bits of pte is zero, and all abnormal ptes are serial in
a mmu page, so I guess the mmu page has been overwritten by someone.


The message details:

kernel: swap_free: Bad swap file entry 1000000000103256
kernel: BUG: Bad page map in process in:imjournal  pte:8192b1000 pmd:3ff9324067
kernel: addr:00007f920adc5000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:3f8
kernel: vma->vm_ops->fault: shmem_fault+0x0/0x1d0
kernel: vma->vm_file->f_op->mmap: shmem_mmap+0x0/0x30
kernel: CPU: 5 PID: 9166 Comm: in:imjournal Tainted: G        W  OE
K------------   3.10.0-514.16.1.el7.x86_64 #1
kernel: Hardware name: HP ProLiant DL380 Gen9/ProLiant DL380 Gen9,
BIOS P89 04/25/2017
kernel: 00007f920adc5000 0000000023409e11 ffff881fc769fc78 ffffffff81686ac3
kernel: ffff881fc769fcc0 ffffffff811acacf 00000008192b1000 00000000000003f8
kernel: ffff883ff9324e28 00000008192b1000 00007f920ae00000 00007f920adc5000
kernel: Call Trace:
kernel: [<ffffffff81686ac3>] dump_stack+0x19/0x1b
kernel: [<ffffffff811acacf>] print_bad_pte+0x1af/0x250
kernel: [<ffffffff811aea7b>] unmap_page_range+0x62b/0x8a0
kernel: [<ffffffff811aed71>] unmap_single_vma+0x81/0xf0
kernel: [<ffffffff811afc49>] unmap_vmas+0x49/0x90
kernel: [<ffffffff811b488e>] unmap_region+0xbe/0x140
kernel: [<ffffffff811b6c75>] do_munmap+0x245/0x420
kernel: [<ffffffff811b6e91>] vm_munmap+0x41/0x60
kernel: [<ffffffff811b7e22>] SyS_munmap+0x22/0x30
kernel: [<ffffffff81697189>] system_call_fastpath+0x16/0x1b
kernel: Disabling lock debugging due to kernel taint
kernel: swap_free: Bad swap file entry 3000000000006986
kernel: BUG: Bad page map in process in:imjournal  pte:34c33000 pmd:3ff9324067
kernel: addr:00007f920adc6000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:3f9
kernel: vma->vm_ops->fault: shmem_fault+0x0/0x1d0
kernel: vma->vm_file->f_op->mmap: shmem_mmap+0x0/0x30

 $ cat messages | grep  swap_free
 kernel: swap_free: Bad swap file entry 1000000000103256
 kernel: swap_free: Bad swap file entry 3000000000006986
 kernel: swap_free: Bad swap file entry 2000000000006986
 kernel: swap_free: Unused swap file entry 00102e07
 kernel: swap_free: Bad swap file entry 1000000000102e00
 kernel: swap_free: Bad swap file entry 2000000000107fd0
 kernel: swap_free: Bad swap file entry 2000000000006a88
 kernel: swap_free: Bad swap file entry 3000000000103e67
 kernel: swap_free: Bad swap file entry 300000000010324c
 kernel: swap_free: Bad swap file entry 3000000000102e00
 kernel: swap_free: Unused swap file entry 00102a56
 kernel: swap_free: Unused swap file entry 00102ef5
 kernel: swap_free: Bad swap file entry 3000000000102ef5
 kernel: swap_free: Bad swap file entry 1000000000102a4f
 kernel: swap_free: Bad swap file entry 3000000000103262
 kernel: swap_free: Bad swap file entry 10000000001031c4
 kernel: swap_free: Unused swap file entry 00006981
 kernel: swap_free: Unused swap file entry 00006a88
 kernel: swap_free: Bad swap file entry 3000000000102e00
 kernel: swap_free: Bad swap file entry 3000000000102e08
 kernel: swap_free: Unused swap file entry 000069d3
 kernel: swap_free: Bad swap file entry 300000000010313a
 kernel: swap_free: Unused swap file entry 0000699d
 kernel: swap_free: Unused swap file entry 00006998
 kernel: swap_free: Bad swap file entry 3000000000102e07
 kernel: swap_free: Bad swap file entry 3000000000102e09
 kernel: swap_free: Bad swap file entry 1000000000103174
 kernel: swap_free: Bad swap file entry 2000000000102e76
 kernel: swap_free: Bad swap file entry 1000000000102651
 kernel: swap_free: Bad swap file entry 3000000000102efa
 kernel: swap_free: Bad swap file entry 3000000000102d40
 kernel: swap_free: Bad swap file entry 3000000000101cf5
 kernel: swap_free: Bad swap file entry 10000000000069b5
 kernel: swap_free: Bad swap file entry 100000000010264e
 kernel: swap_free: Unused swap file entry 000069e8
 kernel: swap_free: Bad swap file entry 20000000000069e8
 kernel: swap_free: Bad swap file entry 20000000001021d2
 kernel: swap_free: Unused swap file entry 0002e892
 kernel: swap_free: Bad swap file entry 2000000000102a48
 kernel: swap_free: Bad swap file entry 3000000000102dde
 kernel: swap_free: Unused swap file entry 001027f2
 kernel: swap_free: Bad swap file entry 200000000000ddf5
 kernel: swap_free: Bad swap file entry 10000000000fd7e1
 kernel: swap_free: Bad swap file entry 1000000000003215
 kernel: swap_free: Bad swap file entry 10000000000f3555
 kernel: swap_free: Bad swap file entry 20000000000f3555
 kernel: swap_free: Bad swap file entry 20000000000fd494
 kernel: swap_free: Bad swap file entry 30000000000fd494
 kernel: swap_free: Bad swap file entry 10000000001027ec
 kernel: swap_free: Bad swap file entry 1000000000103172
 kernel: swap_free: Unused swap file entry 001039b2
 kernel: swap_free: Unused swap file entry 001014da
 kernel: swap_free: Bad swap file entry 20000000000fd8ea
 kernel: swap_free: Bad swap file entry 100000000010036e
 kernel: swap_free: Bad swap file entry 200000000010036e
 kernel: swap_free: Bad swap file entry 30000000000f6ced
 kernel: swap_free: Bad swap file entry 3000000000006a8f
 kernel: swap_free: Bad swap file entry 2000000000102e2a
 kernel: swap_free: Bad swap file entry 1000000000107bc5

$ cat messages | grep  pmd
 kernel: BUG: Bad page map in process in:imjournal  pte:8192b1000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:34c33000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:34c32000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:81703c000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:817001000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:83fe82000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:35442000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:81f33b000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:819263000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:817007000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:8152b0000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:8177a8000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:8177ab000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:815279000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:819317000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:818e25000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:34c0c000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:35440000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:817003000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:817047000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:34e98000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:8189d3000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:34cec000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:34cc0000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:81703f000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:81704b000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:818ba5000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:8173b6000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:81328d000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:8177d3000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:816a03000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:80e7af000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:34da9000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:813271000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:34f40000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:34f42000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:810e92000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:174494000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:815242000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:816ef7000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:813f90000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:6efae000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:7ebf0d000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:190ad000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:79aaa9000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:79aaaa000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:7ea4a6000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:7ea4a7000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:813f61000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:818b91000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:81cd94000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:80a6d4000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:7ec752000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:801b75000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:801b76000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:7b676f000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:3547b000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:817152000 pmd:3ff9324067
 kernel: BUG: Bad page map in process in:imjournal  pte:83de29000 pmd:3ff9324067

 $ cat messages | grep  addr
 kernel: addr:00007f920adc5000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:3f8
 kernel: addr:00007f920adc6000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:3f9
 kernel: addr:00007f920adc7000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:3fa
 kernel: addr:00007f920adc8000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:3fb
 kernel: addr:00007f920adc9000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:3fc
 kernel: addr:00007f920adca000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:3fd
 kernel: addr:00007f920adcb000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:3fe
 kernel: addr:00007f920adcc000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:3ff
 kernel: addr:00007f920adcd000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:400
 kernel: addr:00007f920adce000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:401
 kernel: addr:00007f920adcf000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:402
 kernel: addr:00007f920add0000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:403
 kernel: addr:00007f920add1000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:404
 kernel: addr:00007f920add2000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:405
 kernel: addr:00007f920add3000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:406
 kernel: addr:00007f920add4000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:407
 kernel: addr:00007f920add5000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:408
 kernel: addr:00007f920add6000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:409
 kernel: addr:00007f920add7000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:40a
 kernel: addr:00007f920add8000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:40b
 kernel: addr:00007f920add9000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:40c
 kernel: addr:00007f920adda000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:40d
 kernel: addr:00007f920addb000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:40e
 kernel: addr:00007f920addc000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:40f
 kernel: addr:00007f920addd000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:410
 kernel: addr:00007f920adde000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:411
 kernel: addr:00007f920addf000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:412
 kernel: addr:00007f920ade0000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:413
 kernel: addr:00007f920ade1000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:414
 kernel: addr:00007f920ade2000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:415
 kernel: addr:00007f920ade3000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:416
 kernel: addr:00007f920ade4000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:417
 kernel: addr:00007f920ade5000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:418
 kernel: addr:00007f920ade6000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:419
 kernel: addr:00007f920ade7000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:41a
 kernel: addr:00007f920ade8000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:41b
 kernel: addr:00007f920ade9000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:41c
 kernel: addr:00007f920adea000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:41d
 kernel: addr:00007f920adeb000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:41e
 kernel: addr:00007f920adec000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:41f
 kernel: addr:00007f920aded000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:420
 kernel: addr:00007f920adee000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:421
 kernel: addr:00007f920adef000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:422
 kernel: addr:00007f920adf0000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:423
 kernel: addr:00007f920adf1000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:424
 kernel: addr:00007f920adf2000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:425
 kernel: addr:00007f920adf3000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:426
 kernel: addr:00007f920adf4000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:427
 kernel: addr:00007f920adf5000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:428
 kernel: addr:00007f920adf6000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:429
 kernel: addr:00007f920adf7000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:42a
 kernel: addr:00007f920adf8000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:42b
 kernel: addr:00007f920adf9000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:42c
 kernel: addr:00007f920adfa000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:42d
 kernel: addr:00007f920adfb000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:42e
 kernel: addr:00007f920adfc000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:42f
 kernel: addr:00007f920adfd000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:430
 kernel: addr:00007f920adfe000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:431
 kernel: addr:00007f920adff000 vm_flags:080000d1 anon_vma:
(null) mapping:ffff883fe5284960 index:432


Thanks.

Huaitong Han


2018-04-20 2:53 GMT+08:00 Dave Hansen <dave.hansen@intel.com>:
> On 04/18/2018 10:40 PM, Fengguang Wu wrote:
>> [  716.494065] PASS concurrent_autogo_5ghz_ht40 4.803608 2018-03-23 09:57:21.586794
>> [  716.494069]
>> [  716.496923] passed all 1 test case(s)
>> [  716.496926]
>> [  716.511702] swap_info_get: Bad swap file entry 04000000
>> [  716.512731] BUG: Bad page map in process python2  pte:100_0000_0000 pmd:17e8be067
>> [  716.513844] addr:00000000860ba23b vm_flags:00000070 anon_vma:          (null) mapping:000000004c76fece index:1e2
>> [  716.515160] file:libpcre.so.3.13.3 fault:filemap_fault mmap:generic_file_mmap readpage:simple_readpage
>> [  716.516418] CPU: 2 PID: 8907 Comm: python2 Not tainted 4.16.0-rc5 #1
>> [  716.517533] Hardware name:  /DH67GD, BIOS BLH6710H.86A.0132.2011.1007.1505 10/07/2011
>
> Did you say that you have a few more examples of this?
>
> I would be really interested if it's always python or always the same
> shared library, or always file-backed memory, always the same bit,
> etc...  From the vm_flags, I'd guess that this is the "rw-p" part of the
> file mapping.
>
> The bit that gets set is really weird.  It's bit 40.  I could definitely
> see scenarios where we might set the dirty bit, or even NX for that
> matter, or some *bit* that we mess with in software.  It's not even
> close to the boundary where it could represent a swapoffset=1 or swapfile=1.
>
> It's also unlikely to be _PAGE_PSE having gone missing from the PMD
> since it's in the middle of a file-backed mapping and the PMD is
> obviously pointing to a 4k page.
>
> If I had to put money on it, I'd guess it's a hardware bit flip, or less
> likely, a rogue software bit flip.  But, more examples will hopefully
> shed some more light.
>
