Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1829C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 14:54:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C38020679
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 14:54:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C38020679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E57BF6B0598; Mon, 26 Aug 2019 10:54:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE1416B0599; Mon, 26 Aug 2019 10:54:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C81236B059A; Mon, 26 Aug 2019 10:54:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id A09FF6B0598
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:54:09 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4A2BB180AD7C1
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:54:09 +0000 (UTC)
X-FDA: 75864874218.13.heart09_242be1789c660
X-HE-Tag: heart09_242be1789c660
X-Filterd-Recvd-Size: 10460
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:54:08 +0000 (UTC)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7QErjvD060668
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:54:07 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2umfqpw6p4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:54:07 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 26 Aug 2019 15:54:04 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 26 Aug 2019 15:53:52 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7QEro3t54460520
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 26 Aug 2019 14:53:50 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 503DD4C062;
	Mon, 26 Aug 2019 14:53:50 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BCE2F4C044;
	Mon, 26 Aug 2019 14:53:40 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.38.251])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 26 Aug 2019 14:53:40 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, David Hildenbrand <david@redhat.com>,
        Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski <luto@kernel.org>,
        Anshuman Khandual <anshuman.khandual@arm.com>,
        Arun KS <arunks@codeaurora.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Borislav Petkov <bp@alien8.de>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>,
        Dan Williams <dan.j.williams@intel.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Fenghua Yu <fenghua.yu@intel.com>,
        Gerald Schaefer <gerald.schaefer@de.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Halil Pasic <pasic@linux.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
        Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Jun Yao <yaojun8558363@gmail.com>,
        Logan Gunthorpe <logang@deltatee.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        "Matthew Wilcox \(Oracle\)" <willy@infradead.org>,
        Mel Gorman <mgorman@techsingularity.net>,
        Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Oscar Salvador <osalvador@suse.de>,
        Paul Mackerras <paulus@samba.org>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Pavel Tatashin <pavel.tatashin@microsoft.com>,
        Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
        Rich Felker <dalias@libc.org>, Robin Murphy <robin.murphy@arm.com>,
        Steve Capper <steve.capper@arm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>,
        Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>,
        Wei Yang <richardw.yang@linux.intel.com>,
        Will Deacon <will@kernel.org>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH v2 0/6] mm/memory_hotplug: Consider all zones when removing memory
In-Reply-To: <20190826101012.10575-1-david@redhat.com>
References: <20190826101012.10575-1-david@redhat.com>
Date: Mon, 26 Aug 2019 20:23:38 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19082614-0020-0000-0000-000003642609
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082614-0021-0000-0000-000021B96EB4
Message-Id: <87pnksm0zx.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-26_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908260157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

David Hildenbrand <david@redhat.com> writes:

> Working on virtio-mem, I was able to trigger a kernel BUG (with debug
> options enabled) when removing memory that was never onlined. I was able
> to reproduce with DIMMs. As far as I can see the same can also happen
> without debug configs enabled, if we're unlucky and the uninitialized
> memmap contains selected garbage .
>
> The root problem is that we should not try to derive the zone of memory we
> are removing from the first PFN. The individual memory blocks of a DIMM
> could be spanned by different ZONEs, multiple ZONES (after being offline and
> re-onlined) or no ZONE at all (never onlined).
>
> Let's process all applicable zones when removing memory so we're on the
> safe side. In the long term, we want to resize the zones when offlining
> memory (and before removing ZONE_DEVICE memory), however, that will require
> more thought (and most probably a new SECTION_ACTIVE / pfn_active()
> thingy). More details about that in patch #3.
>
> Along with the fix, some related cleanups.
>
> v1 -> v2:
> - Include "mm: Introduce for_each_zone_nid()"
> - "mm/memory_hotplug: Pass nid instead of zone to __remove_pages()"
> -- Pass the nid instead of the zone and use it to reduce the number of
>    zones to process
>
> --- snip ---
>
> I gave this a quick test with a DIMM on x86-64:
>
> Start with a NUMA-less node 1. Hotplug a DIMM (512MB) to Node 1.
> 1st memory block is not onlined. 2nd and 4th is onlined MOVABLE.
> 3rd is onlined NORMAL.
>
> :/# echo "online_movable" > /sys/devices/system/memory/memory41/state
> [...]
> :/# echo "online_movable" > /sys/devices/system/memory/memory43/state
> :/# echo "online_kernel" > /sys/devices/system/memory/memory42/state
> :/# cat /sys/devices/system/memory/memory40/state
> offline
>
> :/# cat /proc/zoneinfo
> Node 1, zone   Normal
>  [...]
>         spanned  32768
>         present  32768
>         managed  32768
>  [...]
> Node 1, zone  Movable
>  [...]
>         spanned  98304
>         present  65536
>         managed  65536
>  [...]
>
> Trigger hotunplug. If it succeeds (block 42 can be offlined):
>
> :/# cat /proc/zoneinfo
>
> Node 1, zone   Normal
>   pages free     0
>         min      0
>         low      0
>         high     0
>         spanned  0
>         present  0
>         managed  0
>         protection: (0, 0, 0, 0, 0)
> Node 1, zone  Movable
>   pages free     0
>         min      0
>         low      0
>         high     0
>         spanned  0
>         present  0
>         managed  0
>         protection: (0, 0, 0, 0, 0)
>
> So all zones were properly fixed up and we don't access the memmap of the
> first, never-onlined memory block (garbage). I am no longer able to trigger
> the BUG. I did a similar test with an already populated node.
>

I did report a variant of the issue at

https://lore.kernel.org/linux-mm/20190514025354.9108-1-aneesh.kumar@linux.ibm.com/

This patch series still doesn't handle the fact that struct page backing
the start_pfn might not be initialized. ie, it results in crash like
below

    pc: c0000000004bc1ec: shrink_zone_span+0x1bc/0x290
    lr: c0000000004bc1e8: shrink_zone_span+0x1b8/0x290
    sp: c0000000dac7f910
   msr: 800000000282b033
  current = 0xc0000000da2fa000
  paca    = 0xc00000000fffb300   irqmask: 0x03   irq_happened: 0x01
    pid   = 1224, comm = ndctl
kernel BUG at /home/kvaneesh/src/linux/include/linux/mm.h:1088!
Linux version 5.3.0-rc6-17495-gc7727d815970-dirty (kvaneesh@ltc-boston123) (gcc version 7.4.0 (Ubuntu 7.4.0-1ubuntu1~18.04.1)) #183 SMP Mon Aug 26 09:37:32 CDT 2019
enter ? for help
[c0000000dac7f980] c0000000004bc574 __remove_zone+0x84/0xd0
[c0000000dac7f9d0] c0000000004bc920 __remove_section+0x100/0x170
[c0000000dac7fa30] c0000000004bec98 __remove_pages+0x168/0x220
[c0000000dac7fa90] c00000000007dff8 arch_remove_memory+0x38/0x110
[c0000000dac7fb00] c00000000050cb0c devm_memremap_pages_release+0x24c/0x2f0
[c0000000dac7fb90] c000000000cfec00 devm_action_release+0x30/0x50
[c0000000dac7fbb0] c000000000cffe7c release_nodes+0x24c/0x2c0
[c0000000dac7fc20] c000000000cf8988 device_release_driver_internal+0x168/0x230
[c0000000dac7fc60] c000000000cf5624 unbind_store+0x74/0x190
[c0000000dac7fcb0] c000000000cf42a4 drv_attr_store+0x44/0x60
[c0000000dac7fcd0] c000000000617d44 sysfs_kf_write+0x74/0xa0

I do have a few patches to handle the crashes eralier in
devm_memremap_pages_release() 

--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -121,7 +121,7 @@ static void devm_memremap_pages_release(void *data)
        dev_pagemap_cleanup(pgmap);
 
        /* pages are dead and unused, undo the arch mapping */
-       nid = page_to_nid(pfn_to_page(PHYS_PFN(res->start)));
+       nid = page_to_nid(pfn_to_page(pfn_first(pgmap)));
 

and also for pfn_first

https://www.mail-archive.com/linux-nvdimm@lists.01.org/msg16205.html

-aneesh


