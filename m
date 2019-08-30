Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D1ABC3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:14:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1854223427
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:14:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1854223427
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5C4F6B0006; Fri, 30 Aug 2019 05:14:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0D636B0008; Fri, 30 Aug 2019 05:14:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FB336B000A; Fri, 30 Aug 2019 05:14:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0037.hostedemail.com [216.40.44.37])
	by kanga.kvack.org (Postfix) with ESMTP id 682636B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:14:46 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1AE0D180AD7C3
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:14:46 +0000 (UTC)
X-FDA: 75878534172.11.work48_4694de8f96c2d
X-HE-Tag: work48_4694de8f96c2d
X-Filterd-Recvd-Size: 7047
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:14:44 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4B1A110F23E0;
	Fri, 30 Aug 2019 09:14:43 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-243.ams2.redhat.com [10.36.117.243])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6F047600F8;
	Fri, 30 Aug 2019 09:14:29 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Andy Lutomirski <luto@kernel.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Halil Pasic <pasic@linux.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jun Yao <yaojun8558363@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Qian Cai <cai@lca.pw>,
	Rich Felker <dalias@libc.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Steve Capper <steve.capper@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Tony Luck <tony.luck@intel.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Will Deacon <will@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Yu Zhao <yuzhao@google.com>
Subject: [PATCH v4 0/8] mm/memory_hotplug: Shrink zones before removing memory
Date: Fri, 30 Aug 2019 11:14:20 +0200
Message-Id: <20190830091428.18399-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.66]); Fri, 30 Aug 2019 09:14:43 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series fixes the access of uninitialized memmaps when shrinking
zones/nodes and when removing memory.

We stop trying to shrink ZONE_DEVICE, as it's buggy, fixing it would be
more involved (we don't have SECTION_IS_ONLINE as an indicator), and
shrinking is only of limited use (set_zone_contiguous() cannot detect
the ZONE_DEVICE as contiguous). As far as I can tell, this should be fine
for ZONE_DEVICE.

We continue shrinking zones, but I reduced the amount of code to a
minimum. Shrinking is especially necessary to keep zone->contiguous set
where possible, especially on memory unplug of DIMMs at zone boundaries.

-------------------------------------------------------------------------=
-

Zones are now properly shrunk when offlining memory blocks or when
onlining failed. This allows to properly shrink zones on memory unplug
even if the separate memory blocks of a DIMM were onlined to different
zones or re-onlined to a different zone after offlining.

Example:

:/# cat /proc/zoneinfo
Node 1, zone  Movable
        spanned  0
        present  0
        managed  0
:/# echo "online_movable" > /sys/devices/system/memory/memory41/state
:/# echo "online_movable" > /sys/devices/system/memory/memory43/state
:/# cat /proc/zoneinfo
Node 1, zone  Movable
        spanned  98304
        present  65536
        managed  65536
:/# echo 0 > /sys/devices/system/memory/memory43/online
:/# cat /proc/zoneinfo
Node 1, zone  Movable
        spanned  32768
        present  32768
        managed  32768
:/# echo 0 > /sys/devices/system/memory/memory41/online
:/# cat /proc/zoneinfo
Node 1, zone  Movable
        spanned  0
        present  0
        managed  0

-------------------------------------------------------------------------=
-

I tested this with DIMMs on x86, but didn't test the ZONE_DEVICE part yet=
.


v3 -> v4:
- Drop "mm/memremap: Get rid of memmap_init_zone_device()"
-- As Alexander noticed, it was messy either way :)
- Drop "mm/memory_hotplug: Exit early in __remove_pages() on BUGs"
- Drop "mm: Exit early in set_zone_contiguous() if already contiguous"
- Drop "mm/memory_hotplug: Optimize zone shrinking code when checking for
  holes"
- Merged "mm/memory_hotplug: Remove pages from a zone before removing
  memory" and "mm/memory_hotplug: Remove zone parameter from
  __remove_pages()" into "mm/memory_hotplug: Shrink zones when offlining
  memory"
- Added "mm/memory_hotplug: Poison memmap in remove_pfn_range_from_zone()=
"
- Stop shrinking ZONE_DEVICE
- Reshuffle patches, moving all fixes to the front. Add Fixes: tags.
- Change subject/description of various patches
- Minor changes (too many to mention)


Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>


David Hildenbrand (8):
  mm/memory_hotplug: Don't access uninitialized memmaps in
    shrink_pgdat_span()
  mm/memory_hotplug: Don't access uninitialized memmaps in
    shrink_zone_span()
  mm/memory_hotplug: Shrink zones when offlining memory
  mm/memory_hotplug: Poison memmap in remove_pfn_range_from_zone()
  mm/memory_hotplug: We always have a zone in
    find_(smallest|biggest)_section_pfn
  mm/memory_hotplug: Don't check for "all holes" in shrink_zone_span()
  mm/memory_hotplug: Drop local variables in shrink_zone_span()
  mm/memory_hotplug: Cleanup __remove_pages()

 arch/arm64/mm/mmu.c            |   4 +-
 arch/ia64/mm/init.c            |   4 +-
 arch/powerpc/mm/mem.c          |   3 +-
 arch/s390/mm/init.c            |   4 +-
 arch/sh/mm/init.c              |   4 +-
 arch/x86/mm/init_32.c          |   4 +-
 arch/x86/mm/init_64.c          |   4 +-
 include/linux/memory_hotplug.h |   7 +-
 mm/memory_hotplug.c            | 184 +++++++++++----------------------
 mm/memremap.c                  |  10 +-
 10 files changed, 80 insertions(+), 148 deletions(-)

--=20
2.21.0


