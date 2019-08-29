Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BAFCC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26EBF233FF
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26EBF233FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A17F26B000E; Thu, 29 Aug 2019 03:00:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C8F16B0010; Thu, 29 Aug 2019 03:00:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DF6D6B0266; Thu, 29 Aug 2019 03:00:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0055.hostedemail.com [216.40.44.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6F44B6B000E
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:00:39 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 16F96AF98
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:39 +0000 (UTC)
X-FDA: 75874567398.27.love09_58b7350b9836
X-HE-Tag: love09_58b7350b9836
X-Filterd-Recvd-Size: 8967
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:37 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3EB138980F3;
	Thu, 29 Aug 2019 07:00:35 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-166.ams2.redhat.com [10.36.117.166])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8AA3A1001B08;
	Thu, 29 Aug 2019 07:00:20 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Andy Lutomirski <luto@kernel.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Arun KS <arunks@codeaurora.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Dave Airlie <airlied@redhat.com>,
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
	John Hubbard <jhubbard@nvidia.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Oscar Salvador <osalvador@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Qian Cai <cai@lca.pw>,
	Rich Felker <dalias@libc.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Steve Capper <steve.capper@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Tony Luck <tony.luck@intel.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Wei Yang <richard.weiyang@gmail.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Will Deacon <will@kernel.org>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Yu Zhao <yuzhao@google.com>
Subject: [PATCH v3 00/11] mm/memory_hotplug: Shrink zones before removing memory
Date: Thu, 29 Aug 2019 09:00:08 +0200
Message-Id: <20190829070019.12714-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.67]); Thu, 29 Aug 2019 07:00:36 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is the successor of "[PATCH v2 0/6] mm/memory_hotplug: Consider all
zones when removing memory". I decided to go one step further and finally
factor out the shrinking of zones from memory removal code. Zones are now
fixed up when offlining memory/onlining of memory fails/before removing
ZONE_DEVICE memory.

I guess only patch #1 is debatable - it is certainly not a blocker for
the other stuff in this series, it just doesn't seem to be 100% safe. I
am not quite sure if we have a real performance issue here, let's hear
what people think.

-------------------------------------------------------------------------=
-

Example:

:/# cat /proc/zoneinfo
Node 1, zone  Movable
        spanned  0
        present  0
        managed  0
:/# echo "online_movable" > /sys/devices/system/memory/memory41/state=20
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

This series fixes various issues:
1. Memory removal can currently crash the system in case the first
memory block was never onlined.

2. Zone shrinking code can crash the system when trying to look at
uninitialized memmaps.

3. Removing memory with different/multiple/no zones for affected memory
blocks does not properly shring zones. It really only works correcty in t=
he
case all memory blocks were onlined to the same zone.

4. In case memory onlining fails, the zones are not fixed up again.

-------------------------------------------------------------------------=
-

For !ZONE_DEVICE memory, zones are now fixed up when offlining memory. Th=
is
now works very reliable.

For ZONE_DEVICE memory, the zone is fixed up before removing memory. I
haven't tested it, but we should no longer be able to crash the system
BUT there is a fundamental issue remaining that has to be sorted out next=
:
How to detect which memmaps of ZONE_DEVICE memory is valid. The current
fix I implemented is ugly and has to go.

For !ZONE_DEVICE memory we can look at the SECTION_IS_ONLINE flag to
decide whether the memmap was initialized. We can't easily use the same f=
or
ZONE_DEVICE memory, especially, because we have subsection hotplug there.
While we have "present" masks for subsections ("memory was added") we don=
't
have something similar for "online/active". This could probably be one
thing to look into in the future: Use SECTION_IS_ONLINE also for
ZONE_DEVICE memory and remember in a subsection bitmap which subsections
are actually online/active.

I'll leave that exercise to the ZONE_DEVICE folks. From a memory block
onlining/offlining point of view things should be clean now.

While we could still have false positives for ZONE_DEVICE memory when
trying to shrink zones, we should no longer crash - which improves
the situation heavily.

Fact: set_zone_contiguous() is even more broken (false positives) for
ZONE_DEVICE memory: it will never set a zone contiguous because we are
missing the exact same functionality: How to detect whether a memmap was
initialized, so we can trust the zone values.

-------------------------------------------------------------------------=
-

A bunch of prepararions and cleanups included. I only tested on x86
with DIMMs so far.

Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>

David Hildenbrand (11):
  mm/memremap: Get rid of memmap_init_zone_device()
  mm/memory_hotplug: Simplify shrink_pgdat_span()
  mm/memory_hotplug: We always have a zone in
    find_(smallest|biggest)_section_pfn
  mm/memory_hotplug: Drop local variables in shrink_zone_span()
  mm/memory_hotplug: Optimize zone shrinking code when checking for
    holes
  mm/memory_hotplug: Fix crashes in shrink_zone_span()
  mm/memory_hotplug: Exit early in __remove_pages() on BUGs
  mm: Exit early in set_zone_contiguous() if already contiguous
  mm/memory_hotplug: Remove pages from a zone before removing memory
  mm/memory_hotplug: Remove zone parameter from __remove_pages()
  mm/memory_hotplug: Cleanup __remove_pages()

 arch/arm64/mm/mmu.c            |   4 +-
 arch/ia64/mm/init.c            |   4 +-
 arch/powerpc/mm/mem.c          |   3 +-
 arch/s390/mm/init.c            |   4 +-
 arch/sh/mm/init.c              |   4 +-
 arch/x86/mm/init_32.c          |   4 +-
 arch/x86/mm/init_64.c          |   4 +-
 include/linux/memory_hotplug.h |   9 +-
 include/linux/mm.h             |   4 +-
 mm/memory_hotplug.c            | 215 +++++++++++++++------------------
 mm/memremap.c                  |  19 +--
 mm/page_alloc.c                |  45 +++----
 12 files changed, 136 insertions(+), 183 deletions(-)

--=20
2.21.0


