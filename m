Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A5B686B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 09:36:25 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so6741027pde.10
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 06:36:25 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id ox2si12493598pdb.208.2014.08.12.06.36.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 06:36:25 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so6741017pde.10
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 06:36:24 -0700 (PDT)
From: Honggang Li <enjoymindful@gmail.com>
Subject: [linux-next PATCH] Free percpu allocation info for uniprocessor system
Date: Tue, 12 Aug 2014 21:36:14 +0800
Message-Id: <1407850575-18794-1-git-send-email-enjoymindful@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, user-mode-linux-devel@lists.sourceforge.net
Cc: linux-kernel@vger.kernel.org, Honggang Li <enjoymindful@gmail.com>

Uniprocessor system should free percpu allocation info after use as SMP system.

Following table is the bootmem allocation information of one x86 UML virtual
machine with 256MB memory. The virtual machine is running linux-3.12.6. 
Page (0x8c07000) is wasted.
|------------------------------------------------------------------------------
|0x8a02000 empty_zero_page                         size=4096,    align=4096
|0x8a03000 empty_bad_page                          size=4096,    align=4096
|0x8a04000 mem_map,contig_page_data->node_mem_map  size=2097152, align=32
|0x8c04000 contig_page_data->pageblock_flags       size=24,      align=32
|0x8c04020 contig_page_data->wait_table            size=2048,    align=32
|0x8c05000 pte_t*                                  size=4096,    align=4096
|0x8c06000 saved_command_line                      size=91,      align=32
|0x8c06060 static_command_line                     size=91,      align=32
|0x8c060c0 pcpu_alloc_info *ai                     size=4096,    align=32
|0x8c08000 pcpu_base_addr                          size=32768,   align=4096
|0x8c10000 pcpu_group_offsets                      size=4,       align=32
|0x8c10020 pcpu_group_sizes                        size=4,       align=32
|0x8c10040 pcpu_unit_map                           size=4,       align=32
|0x8c10060 pcpu_unit_offsets                       size=4,       align=32
|0x8c10080 pcpu_slot                               size=120,     align=32
|0x8c10100 pcpu_first_chunk                        size=44,      align=32
|0x8c10140 pid_hash                                size=4096,    align=32
|0x8c11140 dentry_hashtable                        size=131072,  align=32
|0x8c31140 inode_hashtable                         size=65536,   align=32
|------------------------------------------------------------------------------

Recent UML is broken because of the commit:
"resource: provide new functions to walk through resources"

As a result, the patch had been tested on x86 and x86_64 UML virtual 
machines based on linux-next-v3.16.

Honggang Li (1):
  Free percpu allocation info for uniprocessor system

 mm/percpu.c | 2 ++
 1 file changed, 2 insertions(+)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
