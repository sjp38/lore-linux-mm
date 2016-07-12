Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 894A76B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 19:26:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so60156081pfa.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 16:26:10 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id re12si5357379pab.74.2016.07.12.16.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 16:26:09 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id pp5so4439167pac.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 16:26:09 -0700 (PDT)
Date: Tue, 12 Jul 2016 16:26:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm, meminit: Always return a valid node from
 early_pfn_to_nid
In-Reply-To: <1468008031-3848-3-git-send-email-mgorman@techsingularity.net>
Message-ID: <alpine.DEB.2.10.1607121624450.118757@chino.kir.corp.google.com>
References: <1468008031-3848-1-git-send-email-mgorman@techsingularity.net> <1468008031-3848-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 8 Jul 2016, Mel Gorman wrote:

> early_pfn_to_nid can return node 0 if a PFN is invalid on machines
> that has no node 0. A machine with only node 1 was observed to crash
> with the following message
> 
>  BUG: unable to handle kernel paging request at 000000000002a3c8
>  PGD 0
>  Modules linked in:
>  Hardware name: Supermicro H8DSP-8/H8DSP-8, BIOS 080011  06/30/2006
>  task: ffffffff81c0d500 ti: ffffffff81c00000 task.ti: ffffffff81c00000
>  RIP: 0010:[<ffffffff816dbd63>]  [<ffffffff816dbd63>] reserve_bootmem_region+0x6a/0xef
>  RSP: 0000:ffffffff81c03eb0  EFLAGS: 00010086
>  RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
>  RDX: ffffffff81c03ec0 RSI: ffffffff81d205c0 RDI: ffffffff8213ee60
>  R13: ffffea0000000000 R14: ffffea0000000020 R15: ffffea0000000020
>  FS:  0000000000000000(0000) GS:ffff8800fba00000(0000) knlGS:0000000000000000
>  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>  CR2: 000000000002a3c8 CR3: 0000000001c06000 CR4: 00000000000006b0
>  Stack:
>   ffffffff81c03f00 0000000000000400 ffff8800fbfc3200 ffffffff81e2a2c0
>   ffffffff81c03fb0 ffffffff81c03f20 ffffffff81dadf7d ffffea0002000040
>   ffffea0000000000 0000000000000000 000000000000ffff 0000000000000001
>  Call Trace:
>   [<ffffffff81dadf7d>] free_all_bootmem+0x4b/0x12a
>   [<ffffffff81d97122>] mem_init+0x70/0xa3
>   [<ffffffff81d78f21>] start_kernel+0x25b/0x49b
> 
> The problem is that early_page_uninitialised uses the early_pfn_to_nid
> helper which returns node 0 for invalid PFNs. No caller of early_pfn_to_nid
> cares except early_page_uninitialised. This patch has early_pfn_to_nid
> always return a valid node.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Cc: <stable@vger.kernel.org> # 4.2+

Acked-by: David Rientjes <rientjes@google.com>

This makes me wonder about meminit_pfn_in_nid(), however, since if 
__early_pfn_to_nid() returns -1, which is the case in this bug, 
meminit_pfn_in_nid() will return true for any passed node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
