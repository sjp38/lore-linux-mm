Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C6BFC3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D596120874
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:44:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D596120874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72CF46B05A6; Mon, 26 Aug 2019 11:44:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 705466B05A7; Mon, 26 Aug 2019 11:44:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A5E06B05A8; Mon, 26 Aug 2019 11:44:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0234.hostedemail.com [216.40.44.234])
	by kanga.kvack.org (Postfix) with ESMTP id 3999D6B05A6
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:44:05 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C9B7152C3
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:44:04 +0000 (UTC)
X-FDA: 75865000008.22.sign38_237af26c32400
X-HE-Tag: sign38_237af26c32400
X-Filterd-Recvd-Size: 12407
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:44:03 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8590781127;
	Mon, 26 Aug 2019 15:44:01 +0000 (UTC)
Received: from [10.36.116.129] (ovpn-116-129.ams2.redhat.com [10.36.116.129])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5F3AC5C1B2;
	Mon, 26 Aug 2019 15:43:48 +0000 (UTC)
Subject: Re: [PATCH v2 0/6] mm/memory_hotplug: Consider all zones when
 removing memory
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski
 <luto@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>,
 Arun KS <arunks@codeaurora.org>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Christian Borntraeger <borntraeger@de.ibm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Dan Williams <dan.j.williams@intel.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Fenghua Yu
 <fenghua.yu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Halil Pasic <pasic@linux.ibm.com>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Johannes Weiner <hannes@cmpxchg.org>,
 Jun Yao <yaojun8558363@gmail.com>, Logan Gunthorpe <logang@deltatee.com>,
 Mark Rutland <mark.rutland@arm.com>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 Mel Gorman <mgorman@techsingularity.net>,
 Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Oscar Salvador <osalvador@suse.de>,
 Paul Mackerras <paulus@samba.org>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
 Rich Felker <dalias@libc.org>, Robin Murphy <robin.murphy@arm.com>,
 Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Tom Lendacky <thomas.lendacky@amd.com>, Tony Luck <tony.luck@intel.com>,
 Vasily Gorbik <gor@linux.ibm.com>, Vlastimil Babka <vbabka@suse.cz>,
 Wei Yang <richard.weiyang@gmail.com>,
 Wei Yang <richardw.yang@linux.intel.com>, Will Deacon <will@kernel.org>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Yu Zhao <yuzhao@google.com>
References: <20190826101012.10575-1-david@redhat.com>
 <87pnksm0zx.fsf@linux.ibm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <194da076-364e-267d-0d51-64940925e2e4@redhat.com>
Date: Mon, 26 Aug 2019 17:43:47 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <87pnksm0zx.fsf@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 26 Aug 2019 15:44:02 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.08.19 16:53, Aneesh Kumar K.V wrote:
> David Hildenbrand <david@redhat.com> writes:
>=20
>> Working on virtio-mem, I was able to trigger a kernel BUG (with debug
>> options enabled) when removing memory that was never onlined. I was ab=
le
>> to reproduce with DIMMs. As far as I can see the same can also happen
>> without debug configs enabled, if we're unlucky and the uninitialized
>> memmap contains selected garbage .
>>
>> The root problem is that we should not try to derive the zone of memor=
y we
>> are removing from the first PFN. The individual memory blocks of a DIM=
M
>> could be spanned by different ZONEs, multiple ZONES (after being offli=
ne and
>> re-onlined) or no ZONE at all (never onlined).
>>
>> Let's process all applicable zones when removing memory so we're on th=
e
>> safe side. In the long term, we want to resize the zones when offlinin=
g
>> memory (and before removing ZONE_DEVICE memory), however, that will re=
quire
>> more thought (and most probably a new SECTION_ACTIVE / pfn_active()
>> thingy). More details about that in patch #3.
>>
>> Along with the fix, some related cleanups.
>>
>> v1 -> v2:
>> - Include "mm: Introduce for_each_zone_nid()"
>> - "mm/memory_hotplug: Pass nid instead of zone to __remove_pages()"
>> -- Pass the nid instead of the zone and use it to reduce the number of
>>    zones to process
>>
>> --- snip ---
>>
>> I gave this a quick test with a DIMM on x86-64:
>>
>> Start with a NUMA-less node 1. Hotplug a DIMM (512MB) to Node 1.
>> 1st memory block is not onlined. 2nd and 4th is onlined MOVABLE.
>> 3rd is onlined NORMAL.
>>
>> :/# echo "online_movable" > /sys/devices/system/memory/memory41/state
>> [...]
>> :/# echo "online_movable" > /sys/devices/system/memory/memory43/state
>> :/# echo "online_kernel" > /sys/devices/system/memory/memory42/state
>> :/# cat /sys/devices/system/memory/memory40/state
>> offline
>>
>> :/# cat /proc/zoneinfo
>> Node 1, zone   Normal
>>  [...]
>>         spanned  32768
>>         present  32768
>>         managed  32768
>>  [...]
>> Node 1, zone  Movable
>>  [...]
>>         spanned  98304
>>         present  65536
>>         managed  65536
>>  [...]
>>
>> Trigger hotunplug. If it succeeds (block 42 can be offlined):
>>
>> :/# cat /proc/zoneinfo
>>
>> Node 1, zone   Normal
>>   pages free     0
>>         min      0
>>         low      0
>>         high     0
>>         spanned  0
>>         present  0
>>         managed  0
>>         protection: (0, 0, 0, 0, 0)
>> Node 1, zone  Movable
>>   pages free     0
>>         min      0
>>         low      0
>>         high     0
>>         spanned  0
>>         present  0
>>         managed  0
>>         protection: (0, 0, 0, 0, 0)
>>
>> So all zones were properly fixed up and we don't access the memmap of =
the
>> first, never-onlined memory block (garbage). I am no longer able to tr=
igger
>> the BUG. I did a similar test with an already populated node.
>>
>=20
> I did report a variant of the issue at
>=20
> https://lore.kernel.org/linux-mm/20190514025354.9108-1-aneesh.kumar@lin=
ux.ibm.com/
>=20
> This patch series still doesn't handle the fact that struct page backin=
g
> the start_pfn might not be initialized. ie, it results in crash like
> below

Okay, that's a related but different issue I think.

I can see that current shrink_zone_span() might read-access the
uninitialized struct page of a PFN if

1. The zone has holes and we check for "zone all holes". If we get
pfn_valid(pfn), we check if "page_zone(pfn_to_page(pfn)) !=3D zone".

2. Via find_smallest_section_pfn() / find_biggest_section_pfn() find a
spanned pfn_valid(). We check
- pfn_to_nid(start_pfn) !=3D nid
- zone !=3D page_zone(pfn_to_page(start_pfn)

So we don't actually use the zone/nid, only use it to sanity check. That
might result in false-positives (not that bad).

It all boils down to shrink_zone_span() not working only on active
memory, for which the PFN is not only valid but also initialized
(something for which we need a new section flag I assume).

Which access triggers the issue you describe? pfn_to_nid()?

>=20
>     pc: c0000000004bc1ec: shrink_zone_span+0x1bc/0x290
>     lr: c0000000004bc1e8: shrink_zone_span+0x1b8/0x290
>     sp: c0000000dac7f910
>    msr: 800000000282b033
>   current =3D 0xc0000000da2fa000
>   paca    =3D 0xc00000000fffb300   irqmask: 0x03   irq_happened: 0x01
>     pid   =3D 1224, comm =3D ndctl
> kernel BUG at /home/kvaneesh/src/linux/include/linux/mm.h:1088!
> Linux version 5.3.0-rc6-17495-gc7727d815970-dirty (kvaneesh@ltc-boston1=
23) (gcc version 7.4.0 (Ubuntu 7.4.0-1ubuntu1~18.04.1)) #183 SMP Mon Aug =
26 09:37:32 CDT 2019
> enter ? for help

Which exact kernel BUG are you hitting here? (my tree doesn't seem t
have any BUG statement around  include/linux/mm.h:1088)

> [c0000000dac7f980] c0000000004bc574 __remove_zone+0x84/0xd0
> [c0000000dac7f9d0] c0000000004bc920 __remove_section+0x100/0x170
> [c0000000dac7fa30] c0000000004bec98 __remove_pages+0x168/0x220
> [c0000000dac7fa90] c00000000007dff8 arch_remove_memory+0x38/0x110
> [c0000000dac7fb00] c00000000050cb0c devm_memremap_pages_release+0x24c/0=
x2f0
> [c0000000dac7fb90] c000000000cfec00 devm_action_release+0x30/0x50
> [c0000000dac7fbb0] c000000000cffe7c release_nodes+0x24c/0x2c0
> [c0000000dac7fc20] c000000000cf8988 device_release_driver_internal+0x16=
8/0x230
> [c0000000dac7fc60] c000000000cf5624 unbind_store+0x74/0x190
> [c0000000dac7fcb0] c000000000cf42a4 drv_attr_store+0x44/0x60
> [c0000000dac7fcd0] c000000000617d44 sysfs_kf_write+0x74/0xa0


--=20

Thanks,

David / dhildenb

