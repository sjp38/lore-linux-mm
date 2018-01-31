Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 311D56B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 00:05:52 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id s90so9101774qki.0
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:05:52 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j7si882581qkd.95.2018.01.30.21.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 21:05:50 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0V4xFW4139249
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 00:05:49 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fu3raxspe-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 00:05:49 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 31 Jan 2018 05:05:47 -0000
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
References: <ef63c070-dcd7-3f26-f6ec-d95404007ae2@linux.vnet.ibm.com>
 <20180123160653.GU1526@dhcp22.suse.cz>
 <2a05eaf2-20fd-57a8-d4bd-5a1fbf57686c@linux.vnet.ibm.com>
 <20180124090539.GH1526@dhcp22.suse.cz>
 <5acba3c2-754d-e449-24ff-a72a0ad0d895@linux.vnet.ibm.com>
 <20180126140415.GD5027@dhcp22.suse.cz>
 <15da8c87-e6db-13aa-01c8-a913656bfdb6@linux.vnet.ibm.com>
 <6db9b33d-fd46-c529-b357-3397926f0733@linux.vnet.ibm.com>
 <20180129132235.GE21609@dhcp22.suse.cz>
 <87k1w081e7.fsf@concordia.ellerman.id.au>
 <20180130094205.GS21609@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 31 Jan 2018 10:35:38 +0530
MIME-Version: 1.0
In-Reply-To: <20180130094205.GS21609@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5eccdc1b-6a10-b48a-c63f-295f69473d97@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On 01/30/2018 03:12 PM, Michal Hocko wrote:
> On Tue 30-01-18 14:35:12, Michael Ellerman wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>>
>>> On Mon 29-01-18 11:02:09, Anshuman Khandual wrote:
>>>> On 01/29/2018 08:17 AM, Anshuman Khandual wrote:
>>>>> On 01/26/2018 07:34 PM, Michal Hocko wrote:
>>>>>> On Fri 26-01-18 18:04:27, Anshuman Khandual wrote:
>>>>>> [...]
>>>>>>> I tried to instrument mmap_region() for a single instance of 'sed'
>>>>>>> binary and traced all it's VMA creation. But there is no trace when
>>>>>>> that 'anon' VMA got created which suddenly shows up during subsequent
>>>>>>> elf_map() call eventually failing it. Please note that the following
>>>>>>> VMA was never created through call into map_region() in the process
>>>>>>> which is strange.
>> ...
>>>>
>>>> Okay, this colliding VMA seems to be getting loaded from load_elf_binary()
>>>> function as well.
>>>>
>>>> [    9.422410] vma c000001fceedbc40 start 0000000010030000 end 0000000010040000
>>>> next c000001fceedbe80 prev c000001fceedb700 mm c000001fceea8200
>>>> prot 8000000000000104 anon_vma           (null) vm_ops           (null)
>>>> pgoff 1003 file           (null) private_data           (null)
>>>> flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
>>>> [    9.422576] CPU: 46 PID: 7457 Comm: sed Not tainted 4.14.0-dirty #158
>>>> [    9.422610] Call Trace:
>>>> [    9.422623] [c000001fdc4f79b0] [c000000000b17ac0] dump_stack+0xb0/0xf0 (unreliable)
>>>> [    9.422670] [c000001fdc4f79f0] [c0000000002dafb8] do_brk_flags+0x2d8/0x440
>>>> [    9.422708] [c000001fdc4f7ac0] [c0000000002db3d0] vm_brk_flags+0x80/0x130
>>>> [    9.422747] [c000001fdc4f7b20] [c0000000003d23a4] set_brk+0x80/0xdc
>>>> [    9.422785] [c000001fdc4f7b60] [c0000000003d1f24] load_elf_binary+0x1304/0x158c
>>>> [    9.422830] [c000001fdc4f7c80] [c00000000035d3e0] search_binary_handler+0xd0/0x270
>>>> [    9.422881] [c000001fdc4f7d10] [c00000000035f338] do_execveat_common.isra.31+0x658/0x890
>>>> [    9.422926] [c000001fdc4f7df0] [c00000000035f980] SyS_execve+0x40/0x50
>>>> [    9.423588] [c000001fdc4f7e30] [c00000000000b220] system_call+0x58/0x6c
>>>>
>>>> which is getting hit after adding some more debug.
>>>
>>> Voila! So your binary simply overrides brk by elf segments. That sounds
>>> like the exactly the thing that the patch is supposed to protect from.
>>> Why this is the case I dunno. It is just clear that either brk or
>>> elf base are not put to the proper place. Something to get fixed. You
>>> are probably just lucky that brk allocations do not spil over to elf
>>> mappings.
>>
>> It is something to get fixed, but we can't retrospectively fix the
>> existing binaries sitting on peoples' systems.
> 
> Yeah. Can we identify those somehow? Are they something people can
> easily come across?
> 
>> Possibly powerpc arch code is doing something with the mmap layout or
>> something else that is confusing the ELF loader, in which case we should
>> fix that.
> 
> Yes this definitely should be fixed. How can elf loader completely
> overlap brk mapping?
> 
>> But if not then the only solution is for the ELF loader to be more
>> tolerant of this situation.
>>
>> So for 4.16 this patch either needs to be dropped, or reworked such that
>> powerpc can opt out of it.
> 
> Yeah, let's hold on merging this until we understand what the heck is
> going on here. If this turnes to be unfixable I will think of a way for
> ppc to opt out.
> 
> Anshuman, could you try to run
> sed 's@^@@' /proc/self/smaps
> on a system with MAP_FIXED_NOREPLACE reverted?
> 

After reverting the following commits from mmotm-2018-01-25-16-20 tag.

67caea694ba5965a52a61fdad495d847f03c4025 ("mm-introduce-map_fixed_safe-fix")
64da2e0c134ecf3936a4c36b949bcf2cdc98977e ("fs-elf-drop-map_fixed-usage-from-elf_map-fix-fix")
645983ab6ca7fd644f52b4c55462b91940012595 ("mm: don't use the same value for MAP_FIXED_NOREPLACE and MAP_SYNC")
d77bab291ac435aab91fa214b85efa74a26c9c22 ("fs-elf-drop-map_fixed-usage-from-elf_map-checkpatch-fixes")
a75c5f92d9ecb21d3299cc7db48e401cbf335c34 ("fs, elf: drop MAP_FIXED usage from elf_map")
00906d029ffe515221e3939b222c237026af2903 ("mm: introduce MAP_FIXED_NOREPLACE")

$sed 's@^@@' /proc/self/smaps
-------------------------------------------
10000000-10020000 r-xp 00000000 fd:00 10558                              /usr/bin/sed
Size:                128 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                 128 kB
Pss:                 128 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:       128 kB
Private_Dirty:         0 kB
Referenced:          128 kB
Anonymous:             0 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:              128 kB
VmFlags: rd ex mr mw me dw 
10020000-10030000 r--p 00010000 fd:00 10558                              /usr/bin/sed
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd mr mw me dw ac 
10030000-10040000 rw-p 00020000 fd:00 10558                              /usr/bin/sed
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd wr mr mw me dw ac 
2cbb0000-2cbe0000 rw-p 00000000 00:00 0                                  [heap]
Size:                192 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd wr mr mw me ac 
7fff7f9c0000-7fff7f9e0000 rw-p 00000000 00:00 0 
Size:                128 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                 128 kB
Pss:                 128 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:       128 kB
Referenced:          128 kB
Anonymous:           128 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:              128 kB
VmFlags: rd wr mr mw me ac 
7fff7f9e0000-7fff86280000 r--p 00000000 fd:00 33660156                   /usr/lib/locale/locale-archive
Size:             107136 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                 384 kB
Pss:                  37 kB
Shared_Clean:        384 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:         0 kB
Referenced:          384 kB
Anonymous:             0 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               37 kB
VmFlags: rd mr mw me 
7fff86280000-7fff86290000 r-xp 00000000 fd:00 33660115                   /usr/lib64/libdl-2.17.so
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                   2 kB
Shared_Clean:         64 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:         0 kB
Referenced:           64 kB
Anonymous:             0 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:                2 kB
VmFlags: rd ex mr mw me 
7fff86290000-7fff862a0000 r--p 00000000 fd:00 33660115                   /usr/lib64/libdl-2.17.so
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd mr mw me ac 
7fff862a0000-7fff862b0000 rw-p 00010000 fd:00 33660115                   /usr/lib64/libdl-2.17.so
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd wr mr mw me ac 
7fff862b0000-7fff86300000 r-xp 00000000 fd:00 33594504                   /usr/lib64/libpcre.so.1.2.0
Size:                320 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                   2 kB
Shared_Clean:         64 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:         0 kB
Referenced:           64 kB
Anonymous:             0 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:                2 kB
VmFlags: rd ex mr mw me 
7fff86300000-7fff86310000 r--p 00040000 fd:00 33594504                   /usr/lib64/libpcre.so.1.2.0
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd mr mw me ac 
7fff86310000-7fff86320000 rw-p 00050000 fd:00 33594504                   /usr/lib64/libpcre.so.1.2.0
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd wr mr mw me ac 
7fff86320000-7fff864f0000 r-xp 00000000 fd:00 33660109                   /usr/lib64/libc-2.17.so
Size:               1856 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                1280 kB
Pss:                  45 kB
Shared_Clean:       1280 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:         0 kB
Referenced:         1280 kB
Anonymous:             0 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               45 kB
VmFlags: rd ex mr mw me 
7fff864f0000-7fff86500000 r--p 001c0000 fd:00 33660109                   /usr/lib64/libc-2.17.so
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd mr mw me ac 
7fff86500000-7fff86510000 rw-p 001d0000 fd:00 33660109                   /usr/lib64/libc-2.17.so
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd wr mr mw me ac 
7fff86510000-7fff86540000 r-xp 00000000 fd:00 33594516                   /usr/lib64/libselinux.so.1
Size:                192 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                 192 kB
Pss:                   8 kB
Shared_Clean:        192 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:         0 kB
Referenced:          192 kB
Anonymous:             0 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:                8 kB
VmFlags: rd ex mr mw me 
7fff86540000-7fff86550000 r--p 00020000 fd:00 33594516                   /usr/lib64/libselinux.so.1
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd mr mw me ac 
7fff86550000-7fff86560000 rw-p 00030000 fd:00 33594516                   /usr/lib64/libselinux.so.1
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd wr mr mw me ac 
7fff86560000-7fff86570000 r--s 00000000 fd:00 67194934                   /usr/lib64/gconv/gconv-modules.cache
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  12 kB
Shared_Clean:         64 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:         0 kB
Referenced:           64 kB
Anonymous:             0 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               12 kB
VmFlags: rd mr me ms 
7fff86570000-7fff86590000 r-xp 00000000 00:00 0                          [vdso]
Size:                128 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                   1 kB
Shared_Clean:         64 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:         0 kB
Referenced:           64 kB
Anonymous:             0 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:                1 kB
VmFlags: rd ex mr mw me de 
7fff86590000-7fff865c0000 r-xp 00000000 fd:00 33660102                   /usr/lib64/ld-2.17.so
Size:                192 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                 192 kB
Pss:                   6 kB
Shared_Clean:        192 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:         0 kB
Referenced:          192 kB
Anonymous:             0 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:                6 kB
VmFlags: rd ex mr mw me dw 
7fff865c0000-7fff865d0000 r--p 00020000 fd:00 33660102                   /usr/lib64/ld-2.17.so
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd mr mw me dw ac 
7fff865d0000-7fff865e0000 rw-p 00030000 fd:00 33660102                   /usr/lib64/ld-2.17.so
Size:                 64 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd wr mr mw me dw ac 
7fffd27a0000-7fffd27d0000 rw-p 00000000 00:00 0                          [stack]
Size:                192 kB
KernelPageSize:       64 kB
MMUPageSize:          64 kB
Rss:                  64 kB
Pss:                  64 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:        64 kB
Referenced:           64 kB
Anonymous:            64 kB
LazyFree:              0 kB
AnonHugePages:         0 kB
ShmemPmdMapped:        0 kB
Shared_Hugetlb:        0 kB
Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
Locked:               64 kB
VmFlags: rd wr mr mw me gd ac 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
