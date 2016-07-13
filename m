Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7956B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:34:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so32620752wma.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:34:26 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id s9si154502wjp.219.2016.07.13.03.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 03:34:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 808231C1941
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:34:23 +0100 (IST)
Date: Wed, 13 Jul 2016 11:34:21 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/3] mm, meminit: Always return a valid node from
 early_pfn_to_nid
Message-ID: <20160713103421.GJ9806@techsingularity.net>
References: <1468008031-3848-1-git-send-email-mgorman@techsingularity.net>
 <1468008031-3848-3-git-send-email-mgorman@techsingularity.net>
 <alpine.DEB.2.10.1607121624450.118757@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1607121624450.118757@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 04:26:02PM -0700, David Rientjes wrote:
> On Fri, 8 Jul 2016, Mel Gorman wrote:
> 
> > early_pfn_to_nid can return node 0 if a PFN is invalid on machines
> > that has no node 0. A machine with only node 1 was observed to crash
> > with the following message
> > 
> >  BUG: unable to handle kernel paging request at 000000000002a3c8
> >  PGD 0
> >  Modules linked in:
> >  Hardware name: Supermicro H8DSP-8/H8DSP-8, BIOS 080011  06/30/2006
> >  task: ffffffff81c0d500 ti: ffffffff81c00000 task.ti: ffffffff81c00000
> >  RIP: 0010:[<ffffffff816dbd63>]  [<ffffffff816dbd63>] reserve_bootmem_region+0x6a/0xef
> >  RSP: 0000:ffffffff81c03eb0  EFLAGS: 00010086
> >  RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
> >  RDX: ffffffff81c03ec0 RSI: ffffffff81d205c0 RDI: ffffffff8213ee60
> >  R13: ffffea0000000000 R14: ffffea0000000020 R15: ffffea0000000020
> >  FS:  0000000000000000(0000) GS:ffff8800fba00000(0000) knlGS:0000000000000000
> >  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >  CR2: 000000000002a3c8 CR3: 0000000001c06000 CR4: 00000000000006b0
> >  Stack:
> >   ffffffff81c03f00 0000000000000400 ffff8800fbfc3200 ffffffff81e2a2c0
> >   ffffffff81c03fb0 ffffffff81c03f20 ffffffff81dadf7d ffffea0002000040
> >   ffffea0000000000 0000000000000000 000000000000ffff 0000000000000001
> >  Call Trace:
> >   [<ffffffff81dadf7d>] free_all_bootmem+0x4b/0x12a
> >   [<ffffffff81d97122>] mem_init+0x70/0xa3
> >   [<ffffffff81d78f21>] start_kernel+0x25b/0x49b
> > 
> > The problem is that early_page_uninitialised uses the early_pfn_to_nid
> > helper which returns node 0 for invalid PFNs. No caller of early_pfn_to_nid
> > cares except early_page_uninitialised. This patch has early_pfn_to_nid
> > always return a valid node.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Cc: <stable@vger.kernel.org> # 4.2+
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> This makes me wonder about meminit_pfn_in_nid(), however, since if 
> __early_pfn_to_nid() returns -1, which is the case in this bug, 
> meminit_pfn_in_nid() will return true for any passed node.

I felt it was ok because it's checking for overlapping nodes primarily.
If there is a hole, the pfn_valid check should fail for sparsemem. For
flatmem, there is no concern with overlapping nodes. Technically the
meminit_pfn_in_nid() call can return true for a hole but for sparsemem,
that is checked for by pfn_valid and for flatmem, it doesn't matter.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
