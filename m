Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A15BB6B038B
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 13:40:22 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id y136so12628398iof.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 10:40:22 -0800 (PST)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id l186si15020923itd.93.2017.03.07.10.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 10:40:21 -0800 (PST)
Received: by mail-it0-x244.google.com with SMTP id g138so1501394itb.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 10:40:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161216120009.20064-2-vbabka@suse.cz>
References: <20161216120009.20064-1-vbabka@suse.cz> <20161216120009.20064-2-vbabka@suse.cz>
From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 7 Mar 2017 10:40:20 -0800
Message-ID: <CA+8MBbJpbD=dLwAWCuu+o-1phEA1eVNLOJb62fj-RvkJPR0+fA@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] mm, page_alloc: avoid page_to_pfn() when merging buddies
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Dec 16, 2016 at 4:00 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On architectures that allow memory holes, page_is_buddy() has to perform
> page_to_pfn() to check for the memory hole. After the previous patch, we have
> the pfn already available in __free_one_page(), which is the only caller of
> page_is_buddy(), so move the check there and avoid page_to_pfn().
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

git bisect says this patch is the cause of an ia64 crash early in boot.

Reverting 13ad59df67f19788f6c22985b1a33e466eceb643
from v4.11-rc1 makes it boot again.

The commit messages talks about the "only caller" of page_is_buddy().
But grep shows two call sites:

mm/page_alloc.c:816:            if (!page_is_buddy(page, buddy, order))
mm/page_alloc.c:876:            if (page_is_buddy(higher_page,
higher_buddy, order + 1)) {


The crash happens due to a bad pointer in free_one_page()

Initmem setup node 0 [mem 0x0000000001000000-0x00000004fbffffff]
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 260199
Policy zone: Normal
Kernel command line: BOOT_IMAGE=scsi0:\efi\SuSE\l-bisect.gz
console=tty1 console=uart,io,0x3f8 intel_iommu=off root=/dev/sda3
DMAR: IOMMU disabled
PID hash table entries: 4096 (order: -1, 32768 bytes)
Sorting __ex_table...
software IO TLB [mem 0x060b0000-0x0a0b0000] (64MB) mapped at
[e0000000060b0000-e00000000a0affff]
Unable to handle kernel paging request at virtual address a07fffffffc80018
swapper[0]: Oops 11012296146944 [1]
Modules linked in:

CPU: 0 PID: 0 Comm: swapper Not tainted 4.10.0-bisect-06032-g13ad59d #12
task: a000000101300000 task.stack: a000000101300000
psr : 00001210084a2010 ifs : 8000000000000a98 ip  :
[<a0000001001cc1e1>]    Not tainted (4.10.0-bisect-06032-g13ad59d)
ip is at free_one_page+0x561/0x740
unat: 0000000000000000 pfs : 0000000000000a98 rsc : 0000000000000003
rnat: 20c49ba5e353f7cf bsps: 04ba52743edc9494 pr  : 966696816682aa69
ldrs: 0000000000000000 ccv : 00000000000355b9 fpsr: 0009804c8a70433f
csd : 0930ffff00063000 ssd : 0930ffff00063000
b0  : a0000001001cc170 b6  : a0000001011a43c0 b7  : a000000100721ba0
f6  : 000000000000000000000 f7  : 1003e0044b82fa09b5a53
f8  : 1003e0000000000000000 f9  : 1003e00000000000016e8
f10 : 1003e0000000000000008 f11 : 1003e20c49ba5e353f7cf
r1  : a000000101a8ef60 r2  : 000000000000000e r3  : 0000000000000000
r8  : 0000000000000001 r9  : 0000000000000000 r10 : 0000000000230000
r11 : 000000000004fc00 r12 : a00000010130fdb0 r13 : a000000101300000
r14 : 0000000000000000 r15 : a07fffffffc80000 r16 : ffffffffffff0000
r17 : 0000000000000001 r18 : a07fffffffdd0037 r19 : 000000000000000c
r20 : 0000000000000001 r21 : a00000010130fdcc r22 : 0000000000044000
r23 : ffffffffffffff80 r24 : a07fffffffd60018 r25 : 0010000000000000
r26 : 0010000000000000 r27 : a07fffffffd60030 r28 : 0000000000000100
r29 : a0000001018b99c8 r30 : a0000001018b99c8 r31 : 000000000004fc00
unwind: cannot stack reg state!
unwind.desc_label_state(): out of memory
unwind: stack underflow!
unwind: failed to find state labeled 0x1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
