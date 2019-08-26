Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EEC0C3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 10:10:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B52321872
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 10:10:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B52321872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 716B96B054E; Mon, 26 Aug 2019 06:10:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C8896B054F; Mon, 26 Aug 2019 06:10:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B5AD6B0550; Mon, 26 Aug 2019 06:10:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0138.hostedemail.com [216.40.44.138])
	by kanga.kvack.org (Postfix) with ESMTP id 395DD6B054E
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 06:10:31 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id CC9A9824CA3D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:10:30 +0000 (UTC)
X-FDA: 75864159420.05.nerve01_2185165648e1f
X-HE-Tag: nerve01_2185165648e1f
X-Filterd-Recvd-Size: 6951
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:10:30 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1F326308FC22;
	Mon, 26 Aug 2019 10:10:28 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-227.ams2.redhat.com [10.36.116.227])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9CC776060D;
	Mon, 26 Aug 2019 10:10:13 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@kernel.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
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
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Qian Cai <cai@lca.pw>,
	Rich Felker <dalias@libc.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Steve Capper <steve.capper@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Tony Luck <tony.luck@intel.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Wei Yang <richard.weiyang@gmail.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Will Deacon <will@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Yu Zhao <yuzhao@google.com>
Subject: [PATCH v2 0/6] mm/memory_hotplug: Consider all zones when removing memory
Date: Mon, 26 Aug 2019 12:10:06 +0200
Message-Id: <20190826101012.10575-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 26 Aug 2019 10:10:29 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Working on virtio-mem, I was able to trigger a kernel BUG (with debug
options enabled) when removing memory that was never onlined. I was able
to reproduce with DIMMs. As far as I can see the same can also happen
without debug configs enabled, if we're unlucky and the uninitialized
memmap contains selected garbage .

The root problem is that we should not try to derive the zone of memory w=
e
are removing from the first PFN. The individual memory blocks of a DIMM
could be spanned by different ZONEs, multiple ZONES (after being offline =
and
re-onlined) or no ZONE at all (never onlined).

Let's process all applicable zones when removing memory so we're on the
safe side. In the long term, we want to resize the zones when offlining
memory (and before removing ZONE_DEVICE memory), however, that will requi=
re
more thought (and most probably a new SECTION_ACTIVE / pfn_active()
thingy). More details about that in patch #3.

Along with the fix, some related cleanups.

v1 -> v2:
- Include "mm: Introduce for_each_zone_nid()"
- "mm/memory_hotplug: Pass nid instead of zone to __remove_pages()"
-- Pass the nid instead of the zone and use it to reduce the number of
   zones to process

--- snip ---

I gave this a quick test with a DIMM on x86-64:

Start with a NUMA-less node 1. Hotplug a DIMM (512MB) to Node 1.
1st memory block is not onlined. 2nd and 4th is onlined MOVABLE.
3rd is onlined NORMAL.

:/# echo "online_movable" > /sys/devices/system/memory/memory41/state
[...]
:/# echo "online_movable" > /sys/devices/system/memory/memory43/state
:/# echo "online_kernel" > /sys/devices/system/memory/memory42/state
:/# cat /sys/devices/system/memory/memory40/state
offline

:/# cat /proc/zoneinfo
Node 1, zone   Normal
 [...]
        spanned  32768
        present  32768
        managed  32768
 [...]
Node 1, zone  Movable
 [...]
        spanned  98304
        present  65536
        managed  65536
 [...]

Trigger hotunplug. If it succeeds (block 42 can be offlined):

:/# cat /proc/zoneinfo

Node 1, zone   Normal
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 0, 0)
Node 1, zone  Movable
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 0, 0)

So all zones were properly fixed up and we don't access the memmap of the
first, never-onlined memory block (garbage). I am no longer able to trigg=
er
the BUG. I did a similar test with an already populated node.

David Hildenbrand (6):
  mm/memory_hotplug: Exit early in __remove_pages() on BUGs
  mm: Exit early in set_zone_contiguous() if already contiguous
  mm/memory_hotplug: Process all zones when removing memory
  mm/memory_hotplug: Cleanup __remove_pages()
  mm: Introduce for_each_zone_nid()
  mm/memory_hotplug: Pass nid instead of zone to __remove_pages()

 arch/arm64/mm/mmu.c            |  4 +--
 arch/ia64/mm/init.c            |  4 +--
 arch/powerpc/mm/mem.c          |  3 +-
 arch/s390/mm/init.c            |  4 +--
 arch/sh/mm/init.c              |  4 +--
 arch/x86/mm/init_32.c          |  4 +--
 arch/x86/mm/init_64.c          |  4 +--
 include/linux/memory_hotplug.h |  2 +-
 include/linux/mmzone.h         |  5 ++++
 mm/memory_hotplug.c            | 51 +++++++++++++++++++---------------
 mm/memremap.c                  |  3 +-
 mm/page_alloc.c                |  3 ++
 12 files changed, 46 insertions(+), 45 deletions(-)

--=20
2.21.0


