Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id A15FF6B0006
	for <linux-mm@kvack.org>; Thu, 31 May 2018 17:46:23 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id t3-v6so2401025vkb.19
        for <linux-mm@kvack.org>; Thu, 31 May 2018 14:46:23 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id r185-v6si5552565vkb.123.2018.05.31.14.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 14:46:22 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs, elf: drop MAP_FIXED usage from elf_map
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144219.22867-3-mhocko@kernel.org>
 <93ce964b-e352-1905-c2b6-deedf2ea06f8@oracle.com>
 <c0e447b3-4ba7-239e-6550-64de7721ad28@oracle.com>
 <20180530080212.GA27180@dhcp22.suse.cz>
 <e7705544-04fe-c382-f6d0-48d0680b46f2@oracle.com>
 <20180530162501.GB15278@dhcp22.suse.cz>
 <1f6be96b-12ac-9a03-df90-386dab02369d@oracle.com>
 <20180531092425.GM15278@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <29bd73d1-ceed-0e4d-324a-b9ae87c4da4e@oracle.com>
Date: Thu, 31 May 2018 14:46:15 -0700
MIME-Version: 1.0
In-Reply-To: <20180531092425.GM15278@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, libhugetlbfs@googlegroups.com

On 05/31/2018 02:24 AM, Michal Hocko wrote:
> I am not an expert on the load linkers myself so I cannot really answer
> this question. Please note that ppc had something similar. See
> ad55eac74f20 ("elf: enforce MAP_FIXED on overlaying elf segments").
> Maybe we need to sprinkle more of those at other places?

I finally understand the issue, and it is NOT a problem with the kernel.
The issue is with old libhugetlbfs provided linker scripts, and yes,
starting with v4.17 people who run libhugetlbfs tests on x86 (at least)
will see additional failures.

I'll try to work this from the libhugetlbfs side.  In the unlikely event
that anyone knows about those linker scripts, assistance and/or feedback
would be appreciated.

Read on only if you want additional details about this failure.

The executable files which are now failing are created with the elf_i386.xB
linker script.  This script is provided for pre-2.17 versions of binutils.
binutils-2.17 came out aprox in 2007, and this script is disabled by default
if binutils-2.17 or later is used.  The only way to create executables with
this script today is by setting the HUGETLB_DEPRECATED_LINK env variable.
This is what libhugetlbfs tests do to simply continue testing the old scripts.

I previously was mistaken about which tests were causing the additional
failures.  The example I previously provided failed on v4.16 as well as
v4.17-rc kernels.  So, please ignore that information.

For an executable that runs on v4.16 and fails on v4.17-rc, here is a listing
of elf sections that the kernel will attempt to load.

Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
LOAD           0x000000 0x08048000 0x08048000 0x11c24 0x11c24 R E 0x1000
LOAD           0x011c24 0x08059c24 0x08059c24 0x10d04 0x10d04 RW  0x1000
LOAD           0x023000 0x09000000 0x09000000 0x00000 0x10048 RWE 0x1000

The first section is loaded without issue.  elf_map() will create a vma
based on the following:
map_addr ELF_PAGESTART(addr) 8048000 ELF_PAGEALIGN(size) 12000 
File_offset 0

We then attempt to load the following section with:
map_addr ELF_PAGESTART(addr) 8059000 ELF_PAGEALIGN(size) 12000
File_offset 11000

This results in,
Uhuuh, elf segment at 8059000 requested but the memory is mapped already

Note that the last page of the first section overlaps with the first page
of the second section.  Unlike the case in ad55eac74f20, the access
permissions on section 1 (RE) are different than section 2 (RW).  If we
allowed the previous MAP_FIXED behavior, we would be changing part of a
read only section to read write.  This is exactly what MAP_FIXED_NOREPLACE
was designed to prevent.
-- 
Mike Kravetz
