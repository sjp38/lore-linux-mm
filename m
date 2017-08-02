Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4F26B05B1
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 04:52:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w63so5222256wrc.5
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 01:52:50 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id k5si2863219wmg.248.2017.08.02.01.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 01:52:48 -0700 (PDT)
Subject: Re: [PATCH v4 2/3] powerpc/mm/hugetlb: Add support for reserving
 gigantic huge pages via kernel command line
References: <20170728050127.28338-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170728050127.28338-2-aneesh.kumar@linux.vnet.ibm.com>
 <64014b48-a04f-92a7-f561-7ffd386fabc6@c-s.fr>
 <877eym1l4m.fsf@linux.vnet.ibm.com>
 <4d4e90d3-2d5b-7a38-0575-f03e5f225af5@c-s.fr>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <3ff14850-f5c1-7e08-53b9-53b122f4c685@c-s.fr>
Date: Wed, 2 Aug 2017 10:52:44 +0200
MIME-Version: 1.0
In-Reply-To: <4d4e90d3-2d5b-7a38-0575-f03e5f225af5@c-s.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Scott Wood <oss@buserror.net>



Le 02/08/2017 A  10:10, Christophe LEROY a A(C)crit :
> 
> 
> Le 02/08/2017 A  09:31, Aneesh Kumar K.V a A(C)crit :
>> Christophe LEROY <christophe.leroy@c-s.fr> writes:
>>
>>> Hi,
>>>
>>> Le 28/07/2017 A  07:01, Aneesh Kumar K.V a A(C)crit :
>>>> With commit aa888a74977a8 ("hugetlb: support larger than MAX_ORDER") 
>>>> we added
>>>> support for allocating gigantic hugepages via kernel command line. 
>>>> Switch
>>>> ppc64 arch specific code to use that.
>>>>
>>>> W.r.t FSL support, we now limit our allocation range using 
>>>> BOOTMEM_ALLOC_ACCESSIBLE.
>>>>
>>>> We use the kernel command line to do reservation of hugetlb pages on 
>>>> powernv
>>>> platforms. On pseries hash mmu mode the supported gigantic huge page 
>>>> size is
>>>> 16GB and that can only be allocated with hypervisor assist. For 
>>>> pseries the
>>>> command line option doesn't do the allocation. Instead pseries does 
>>>> gigantic
>>>> hugepage allocation based on hypervisor hint that is specified via
>>>> "ibm,expected#pages" property of the memory node.
>>>
>>> It looks like it doesn't work on the 8xx:
>>>
>>> root@vgoip:~# dmesg | grep -i huge
>>> [    0.000000] Kernel command line: console=ttyCPM0,115200N8
>>> ip=172.25.231.25:172.25.231.1::255.0.0.0:vgoip:eth0:off hugepagesz=8M
>>> hugepages=4
>>> [    0.416722] HugeTLB registered 8.00 MiB page size, pre-allocated 4 
>>> pages
>>> [    0.423184] HugeTLB registered 512 KiB page size, pre-allocated 0 
>>> pages
>>> root@vgoip:~# cat /proc/meminfo
>>> MemTotal:         123388 kB
>>> MemFree:           77900 kB
>>> MemAvailable:      78412 kB
>>> Buffers:               0 kB
>>> Cached:             3964 kB
>>> SwapCached:            0 kB
>>> Active:             3788 kB
>>> Inactive:           1680 kB
>>> Active(anon):       1636 kB
>>> Inactive(anon):       20 kB
>>> Active(file):       2152 kB
>>> Inactive(file):     1660 kB
>>> Unevictable:           0 kB
>>> Mlocked:               0 kB
>>> SwapTotal:             0 kB
>>> SwapFree:              0 kB
>>> Dirty:                 0 kB
>>> Writeback:             0 kB
>>> AnonPages:          1552 kB
>>> Mapped:             2404 kB
>>> Shmem:               152 kB
>>> Slab:                  0 kB
>>> SReclaimable:          0 kB
>>> SUnreclaim:            0 kB
>>> KernelStack:         304 kB
>>> PageTables:          208 kB
>>> NFS_Unstable:          0 kB
>>> Bounce:                0 kB
>>> WritebackTmp:          0 kB
>>> CommitLimit:       45308 kB
>>> Committed_AS:      16664 kB
>>> VmallocTotal:     866304 kB
>>> VmallocUsed:           0 kB
>>> VmallocChunk:          0 kB
>>> HugePages_Total:       0
>>> HugePages_Free:        0
>>> HugePages_Rsvd:        0
>>> HugePages_Surp:        0
>>> Hugepagesize:        512 kB
>>
>> But you are printing above the default hugepaeg details. You haven't
>> changed that in kernel command line. What does
>> /sys/kernel/mm/hugepages/<hugepages-size>/nr_hugepages show ?
> 
> It says 4, so indeed it seems to work.
> 
>>
>> To change the default hugepage size you may want to use
>> default_hugepagesz=8M
>>
> 
> Ah ? Documentation/admin-guide/kernel-parameters.txt says it is the same 
> as hugepagesz:
> 
>      default_hugepagesz=
>          [same as hugepagesz=] The size of the default
>          HugeTLB page size. This is the size represented by
>          the legacy /proc/ hugepages APIs, used for SHM, and
>          default size when mounting hugetlbfs filesystems.
>          Defaults to the default architecture's huge page size
>          if not specified.
> 
> 
> You are right, with default_hugepagesz instead of hugepagesz I get the 
> following in 16k page sizes mode (ie 8M is < MAX_ORDER)
> 
> root@vgoip:~# dmesg | grep -i huge
> [    0.000000] Kernel command line: console=ttyCPM0,115200N8 
> ip=172.25.231.25:172.25.231.1::255.0.0.0:vgoip:eth0:off 
> default_hugepagesz=8M hugepages=4
> [    0.410451] HugeTLB registered 512 KiB page size, pre-allocated 0 pages
> [    0.417091] HugeTLB registered 8.00 MiB page size, pre-allocated 4 pages
> root@vgoip:~# cat /proc/meminfo
> MemTotal:         123968 kB
> MemFree:           73248 kB
> MemAvailable:      75120 kB
> Buffers:               0 kB
> Cached:             5936 kB
> SwapCached:            0 kB
> Active:             6912 kB
> Inactive:           2496 kB
> Active(anon):       3664 kB
> Inactive(anon):       80 kB
> Active(file):       3248 kB
> Inactive(file):     2416 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:             0 kB
> SwapFree:              0 kB
> Dirty:                 0 kB
> Writeback:             0 kB
> AnonPages:          3536 kB
> Mapped:             3216 kB
> Shmem:               272 kB
> Slab:                  0 kB
> SReclaimable:          0 kB
> SUnreclaim:            0 kB
> KernelStack:         304 kB
> PageTables:          672 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:       45600 kB
> Committed_AS:      18528 kB
> VmallocTotal:     866304 kB
> VmallocUsed:           0 kB
> VmallocChunk:          0 kB
> HugePages_Total:       4
> HugePages_Free:        4
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       8192 kB
> 
> However, in 4K pages mode, ie (8M > MAX_ORDER), I get
> 
> root@vgoip:~# dmesg | grep -i huge
> [    0.000000] Kernel command line: console=ttyCPM0,115200N8 
> ip=172.25.231.25:172.25.231.1::255.0.0.0:vgoip:eth0:off 
> default_hugepagesz=8M hugepages=4
> [    0.413274] HugeTLB registered 512 KiB page size, pre-allocated 0 pages
> [    0.419844] HugeTLB registered 8.00 MiB page size, pre-allocated 0 pages
> 
> root@vgoip:~# cat /proc/meminfo
> ...
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       8192 kB
> 
> Looks like for gigantic pages, we have to specify both 
> default_hugepagesz=8M and hugepagesz=8M. When we do it it works back:
> 
> [    0.000000] Kernel command line: console=ttyCPM0,115200N8 
> ip=172.25.231.25:172.25.231.1::255.0.0.0:vgoip:eth0:off 
> default_hugepagesz=8M hugepagesz=8M hugepages=4
> [    0.420093] HugeTLB registered 8.00 MiB page size, pre-allocated 4 pages
> [    0.426538] HugeTLB registered 512 KiB page size, pre-allocated 0 pages
> 


Indeed it works even without your patch.

Christophe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
