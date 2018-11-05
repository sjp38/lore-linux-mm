Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9DFA6B000D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 10:06:34 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 18-v6so8699954pgn.4
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 07:06:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e129-v6si9184815pfg.205.2018.11.05.07.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 07:06:33 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA5F64iO002181
	for <linux-mm@kvack.org>; Mon, 5 Nov 2018 10:06:32 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2njpy841cf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Nov 2018 10:06:27 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.ibm.com>;
	Mon, 5 Nov 2018 15:04:06 -0000
From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Subject: [PATCH v2 0/1] memory_hotplug: fix the panic when memory end is not
Date: Mon,  5 Nov 2018 16:04:00 +0100
Message-Id: <20181105150401.97287-1-zaslonko@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com, zaslonko@linux.ibm.com

This patch refers to the older thread:
https://marc.info/?t=153658306400001&r=1&w=2

I have tried to take the approaches suggested in the discussion like
simply ignoring unaligned memory to section memory much earlier or
initializing struct pages beyond the "end" but both had issues.

First I tried to ignore unaligned memory early by adjusting memory_end
value. But the thing is that kernel mem parameter parsing and memory_end
calculation take place in the architecture code and adjusting it afterwards
in common code might be too late in my view. Also with this approach we
might lose the memory up to the entire section(256Mb on s390) just because
of unfortunate alignment.

Another approach was to fix memmap_init() and initialize struct pages
beyond the end. Since struct pages are allocated section-wise we can try to
round the size parameter passed to the memmap_init() function up to the
section boundary thus forcing the mapping initialization for the entire
section. But then it leads to another VM_BUG_ON panic due to
zone_spans_pfn() sanity check triggered for the first page of each page
block from set_pageblock_migratetype() function:
 page dumped because: VM_BUG_ON_PAGE(!zone_spans_pfn(page_zone(page), pfn))
      Call Trace:
      ([<00000000003013f8>] set_pfnblock_flags_mask+0xe8/0x140)
       [<00000000003014aa>] set_pageblock_migratetype+0x5a/0x70
       [<0000000000bef706>] memmap_init_zone+0x25e/0x2e0
       [<00000000010fc3d8>] free_area_init_node+0x530/0x558
       [<00000000010fcf02>] free_area_init_nodes+0x81a/0x8f0
       [<00000000010e7fdc>] paging_init+0x124/0x130
       [<00000000010e4dfa>] setup_arch+0xbf2/0xcc8
       [<00000000010de9e6>] start_kernel+0x7e/0x588
       [<000000000010007c>] startup_continue+0x7c/0x300
      Last Breaking-Event-Address:
       [<00000000003013f8>] set_pfnblock_flags_mask+0xe8/0x1401
We might ignore this check for the struct pages beyond the "end" but I'm not
sure about further implications.
For now I suggest to stay with my original proposal fixing specific
functions for memory hotplug sysfs handlers.

Changes v1 -> v2:
* Expanded commit message to show both failing scenarious.
* Use 'pfn + i' instead of 'pfn' for zone_spans_pfn() check within
test_pages_in_a_zone() function thus taking CONFIG_HOLES_IN_ZONE into
consideration.

Mikhail Zaslonko (1):
  memory_hotplug: fix the panic when memory end is not on the section
    boundary

 mm/memory_hotplug.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

-- 
2.16.4
