Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0064C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D7A4222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="lJhJmIht";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="iLtaEl2d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D7A4222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F24168E0003; Fri, 15 Feb 2019 17:09:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED4198E0001; Fri, 15 Feb 2019 17:09:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC34B8E0003; Fri, 15 Feb 2019 17:09:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B287D8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:06 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k5so10435961qte.0
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:reply-to:mime-version:content-transfer-encoding;
        bh=nLJfuZTbeeI/jMZqph7TlMT1OBBbnm2vTZXn8g4L1p8=;
        b=q5bNxSH7mqqLk26P0d2LlW6Qs/Jn6dvKoQW//ieb0gD6U3E3V5xfrtb7gpshQ6imfe
         +qQflhGfQ20jv9HozN4ALUtqQBYnfMiU2HZW+e/fRXj66kEII8ECHYomPij/34vhIKju
         51eMbDff7qif2SZ0PbNlcJNrmfQ8mvP5W/0orlGtiKPIzPkN8vuGDJUc5HqmtBt1ZLAA
         dspbzdcJ1weMEX8qqaFvPWu4jLoYEc9Ma/nKC+im6yIzLEAX+SjiiR+aD/xToTzZNNmx
         6T40EugAQFF+l3pGzSJeOPeE8BDl8c1JAmaOScCMVCAztHZEFsgLk1lLge2WyYGR3HWj
         dhVA==
X-Gm-Message-State: AHQUAuZqiZuIo1ZCogr7vHqcn1ULi9zVcTY2CabNu2fo+twLCk+/bDlC
	zeILp3//9Zbsv0A/x90myLRCp/8tXZ3PQCP37Hv4qA4q5dnaEckh6zWRBV95vRCpMv8XOEqlF8B
	lu9Yt/M7Iio4MNo7mnZQpIGySqH050gwhNIj4g2CvS36KhkleI4rN/XlTjc286BxDxQ==
X-Received: by 2002:aed:37e7:: with SMTP id j94mr9475411qtb.282.1550268546439;
        Fri, 15 Feb 2019 14:09:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZMf6lTpmiSww4BsaNM0tfNlcTxXyFib2zKdB4ASXGZhptv6DATJX3iGxtIQOrf/csbE4bm
X-Received: by 2002:aed:37e7:: with SMTP id j94mr9475343qtb.282.1550268545380;
        Fri, 15 Feb 2019 14:09:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268545; cv=none;
        d=google.com; s=arc-20160816;
        b=LXNIWUePo/4moP19rAXvGGhrRG6dEV1Xm9tCf8b+/0vPxfLtxKUWsYnuvH7LoF4zrq
         /7SjqNQJLbit5GXqeMK7zurPWunW0Pmst8DwbRSLhSSuVyYnwjr7spWo5wgk5g8XYavf
         q5oBlKjATQYJO3HVYrP6FjDossAO7qjQmSz8wltctam8pqtz4QbNN9NxfsK0nj2EnwWq
         BVjz941+fQ5ptU24xQ9fduWCncxcyQPF/WglNkdsryKY6tRIB5NEzzNrcGz1QmhKA8xg
         PkFY/m4VWY4mGlgpBKuLY6ZAdpXN/oVtqjlBezncjk94CegtJYItG+blTxVqOp5ORAZJ
         UdGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:message-id:date
         :subject:cc:to:from:dkim-signature:dkim-signature;
        bh=nLJfuZTbeeI/jMZqph7TlMT1OBBbnm2vTZXn8g4L1p8=;
        b=VDqF/iGlQRckNVy4Q4CXwuTwkrtIzKA6ZK9vpWUr2p1nDjjSTr2aSr8Fza66aw9Cqf
         0umqd53ZrKn08Vx00Gy/gCevXOqF7M2/dRUw+yDcBHGQ0mQWuVzGxcd+EcT7IOVoV/V+
         VyblqX13UDlnLretMjcip87czWxCVgsYNd7FQ3r8/W0VeiRo6g57letUSNrSCqSidvmr
         wJV1jeq11g7GyzT5c2OLnpO94Jd/USNIBkdzhQji1xxMfFE4rzT6l4qzUYaGxiHyPxdv
         IgN4mTclBPZjKYPJi6WhGki6NseKK8pr74e26XAwMN1JwqvvC59DaB0pY/xNPZ3tNA3i
         57fg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=lJhJmIht;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=iLtaEl2d;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id q90si4274131qvq.51.2019.02.15.14.09.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:05 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=lJhJmIht;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=iLtaEl2d;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 68367310A;
	Fri, 15 Feb 2019 17:09:03 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:04 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:reply-to:mime-version
	:content-type:content-transfer-encoding; s=fm2; bh=nLJfuZTbeeI/j
	MZqph7TlMT1OBBbnm2vTZXn8g4L1p8=; b=lJhJmIhtXKxj2OBuYbhBiTyteW+N9
	KRW/qhZXBI1GR97eDddUzS1dr6tFFc1El4qrqqEfyll37L3E8jTmPes1HG+jyqir
	DD/+UW1G7IFI7mLoGmm5HFW9bPZHis3FqQKsGfI2dQKIfe2srnNinRYVQqdlY49n
	QMHBW0m+/3Ha4f0BU9wB+bDnA/Wy6ScdAup+GO2KOiXFVLPpWTrhRd4linbl3P8I
	2NQpGnwGLUcZ4Ri/Tdn7hS1h+DCoGP6gxDAah5WInYqflx3mCW21Tt0Q7qcdiUSb
	dEt2i191IfzCljTukXx9FpDz7xJfICVw0cIDTjOM1yucDrkXcCFk/TuFQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:message-id:mime-version:reply-to:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=nLJfuZTbeeI/jMZqph7TlMT1OBBbnm2vTZXn8g4L1p8=; b=iLtaEl2d
	nHri1/AUiqqPILSRtY9+NFSN/qf0sWFNnIZUCUEuGFJ6jw9Fh2MoFCeAkrYYzF+D
	dmotJSb4w3QTkfifrA6Boilbm5sfEvS2Aoo/d2JBqZI2+opXUr4+5p6KYmzSQBSB
	J99RTGL9fCTsrUhfC2qLOscjEP23jW9ZCuuXwETHP8afWNJctTqIjoHef7xkDXif
	YmV2ASUW4l438w7e2xB5FGqi1eWb1OLxJknX9ArbgipGS03hSxxmsCoCVkxNtAfk
	N/8EboMUggxSkaOuBu752xmoRAMjEQUhPaSWR1mReLRPSPo1qbo+QUUqivwfKj8o
	V6G/LT5l71nADg==
X-ME-Sender: <xms:fThnXDzfKQbdTyKydaU9obQvU4uc81rXE5qc6kB82ztEurcF5LXlMA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    forhggtgfgsehtkeertdertdejnecuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhes
    shgvnhhtrdgtohhmqeenucffohhmrghinhepnhhvihguihgrrdgtohhmpdhlfihnrdhnvg
    htnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrghmpehmrghilhhfrhho
    mhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:fThnXPjp2LL14gqp36MJaugX9hSh0xfQHU6JjKOzCr_FLsF4jOx4dg>
    <xmx:fThnXIVb24qmfrjSMP9MSjomclCUDJdztYeq4EI5x57wvlu4VAILTQ>
    <xmx:fThnXB1_Ovd_cChVm0T4JfiPobIis7TCX4xF6uqR-CJe6U04PnC-Qg>
    <xmx:fjhnXJ_skfITWrDlrwIrrhAYMzo2NaEJnJ9GDqg4XBopGxA36Y_m-Q>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 0F667E4597;
	Fri, 15 Feb 2019 17:08:59 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 00/31] Generating physically contiguous memory after page allocation
Date: Fri, 15 Feb 2019 14:08:25 -0800
Message-Id: <20190215220856.29749-1-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

Hi all,

This patchset produces physically contiguous memory by moving in-use pages
without allocating any new pages. It targets two scenarios that complements
khugepaged use cases: 1) avoiding page reclaim and memory compaction when the
system is under memory pressure because this patchset does not allocate any new
pages, 2) generating pages larger than 2^MAX_ORDER without changing the buddy
allocator.

To demonstrate its use, I add very basic 1GB THP support and enable promoting
512 2MB THPs to a 1GB THP in my patchset. Promoting 512 4KB pages to a 2MB
THP is also implemented.

The patches are on top of v5.0-rc5. They are posted as part of my upcoming
LSF/MM proposal.

Motivation 
---- 

The goal of this patchset is to provide alternative way of generating physically
contiguous memory and making it available as arbitrary sized large pages. This
patchset generates physically contiguous memory/arbitrary size pages after pages
are allocated by moving virtually-contiguous pages to become physically
contiguous at any size, thus it does not require changes to memory allocators.
On the other hand, it works only for moveable pages, so it also faces the same
fragmentation issues as memory compaction, i.e., if non-moveable pages spread
across the entire memory, this patchset can only generate contiguity between
any two non-moveable pages. 

Large pages and physically contiguous memory are important to devices, such as
GPUs, FPGAs, NICs and RDMA controllers, because they can often achieve better
performance when operating on large pages. The same can be said of CPU
performance, of course, but there is an important difference: GPUs and
high-throughput devices often take a more severe performance hit, in the event
of a TLB miss and subsequent page table walks, as compared to a CPU. The effect
is sufficiently large that such devices *really* want a highly reliable way to
allocate large pages to minimize the number of potential TLB misses and the time
spent on the induced page table walks. 

Vendors (like Oracle, Mellanox, IBM, NVIDIA) are interested in generating
physically contiguous memory beyond THP sizes and looking for solutions [1],[2],[3].
This patchset provides an alternative approach, compared to allocating
physically contiguous memory at page allocation time, to generating physically
contiguous memory after pages are allocated. This approach can avoid page
reclaim and memory compaction, which happen during the process of page
allocation, but still produces comparable physically contiguous memory. 

In terms of THPs, it helps, but we are interested in even larger contiguous
ranges (or page size support) to further reduce the address translation overheads.
With this patchset, we can generate pages larger than PMD-level THPs without
requiring MAX_ORDER changes in the buddy allocators. 


Patch structure 
---- 

The patchset I developed to generate physically contiguous memory/arbitrary
sized pages merely moves pages around. There are three components in this
patchset:

1) a new page migration mechanism, called exchange pages, that exchanges the
content of two in-use pages instead of performing two back-to-back page
migration. It saves on overheads and avoids page reclaim and memory compaction
in the page allocation path, although it is not strictly required if enough
free memory is available in the system.

2) a new mechanism that utilizes both page migration and exchange pages to
produce physically contiguous memory/arbitrary sized pages without allocating
any new pages, unlike what khugepaged does. It works on per-VMA basis, creating
physically contiguous memory out of each VMA, which is virtually contiguous.
A simple range tree is used to ensure no two VMAs are overlapping with each
other in the physical address space.

3) a use case of the new physically contiguous memory producing mechanism that
generates 1GB THPs by migrating and exchanging pages and promoting 512
contiguous 2MB THPs to a 1GB THP, although even larger physically contiguous
memory ranges can be generated. The 1GB THP implement is very basic, which can
handle 1GB THP faults when buddy allocator is modified to allocate 1GB pages,
support 1GB THP split to 2MB THP and in-place promotion from 2MB THP to 1GB THP,
and PMD/PTE-mapped 1GB THP. These are not fully tested.


[1] https://lwn.net/Articles/736170/ 
[2] https://lwn.net/Articles/753167/ 
[3] https://blogs.nvidia.com/blog/2018/06/08/worlds-fastest-exascale-ai-supercomputer-summit/ 

Zi Yan (31):
  mm: migrate: Add exchange_pages to exchange two lists of pages.
  mm: migrate: Add THP exchange support.
  mm: migrate: Add tmpfs exchange support.
  mm: add mem_defrag functionality.
  mem_defrag: split a THP if either src or dst is THP only.
  mm: Make MAX_ORDER configurable in Kconfig for buddy allocator.
  mm: deallocate pages with order > MAX_ORDER.
  mm: add pagechain container for storing multiple pages.
  mm: thp: 1GB anonymous page implementation.
  mm: proc: add 1GB THP kpageflag.
  mm: debug: print compound page order in dump_page().
  mm: stats: Separate PMD THP and PUD THP stats.
  mm: thp: 1GB THP copy on write implementation.
  mm: thp: handling 1GB THP reference bit.
  mm: thp: add 1GB THP split_huge_pud_page() function.
  mm: thp: check compound_mapcount of PMD-mapped PUD THPs at free time.
  mm: thp: split properly PMD-mapped PUD THP to PTE-mapped PUD THP.
  mm: page_vma_walk: teach it about PMD-mapped PUD THP.
  mm: thp: 1GB THP support in try_to_unmap().
  mm: thp: split 1GB THPs at page reclaim.
  mm: thp: 1GB zero page shrinker.
  mm: thp: 1GB THP follow_p*d_page() support.
  mm: support 1GB THP pagemap support.
  sysctl: add an option to only print the head page virtual address.
  mm: thp: add a knob to enable/disable 1GB THPs.
  mm: thp: promote PTE-mapped THP to PMD-mapped THP.
  mm: thp: promote PMD-mapped PUD pages to PUD-mapped PUD pages.
  mm: vmstats: add page promotion stats.
  mm: madvise: add madvise options to split PMD and PUD THPs.
  mm: mem_defrag: thp: PMD THP and PUD THP in-place promotion support.
  sysctl: toggle to promote PUD-mapped 1GB THP or not.

 arch/x86/Kconfig                       |   15 +
 arch/x86/entry/syscalls/syscall_64.tbl |    1 +
 arch/x86/include/asm/pgalloc.h         |   69 +
 arch/x86/include/asm/pgtable.h         |   20 +
 arch/x86/include/asm/sparsemem.h       |    4 +-
 arch/x86/mm/pgtable.c                  |   38 +
 drivers/base/node.c                    |    3 +
 fs/exec.c                              |    4 +
 fs/proc/meminfo.c                      |    2 +
 fs/proc/page.c                         |    2 +
 fs/proc/task_mmu.c                     |   47 +-
 include/asm-generic/pgtable.h          |  110 +
 include/linux/huge_mm.h                |   78 +-
 include/linux/khugepaged.h             |    1 +
 include/linux/ksm.h                    |    5 +
 include/linux/mem_defrag.h             |   60 +
 include/linux/memcontrol.h             |    5 +
 include/linux/mm.h                     |   34 +
 include/linux/mm_types.h               |    5 +
 include/linux/mmu_notifier.h           |   13 +
 include/linux/mmzone.h                 |    1 +
 include/linux/page-flags.h             |   79 +-
 include/linux/pagechain.h              |   73 +
 include/linux/rmap.h                   |   10 +-
 include/linux/sched/coredump.h         |    4 +
 include/linux/swap.h                   |    2 +
 include/linux/syscalls.h               |    3 +
 include/linux/vm_event_item.h          |   33 +
 include/uapi/asm-generic/mman-common.h |   15 +
 include/uapi/linux/kernel-page-flags.h |    2 +
 kernel/events/uprobes.c                |    4 +-
 kernel/fork.c                          |   14 +
 kernel/sysctl.c                        |  101 +-
 mm/Makefile                            |    2 +
 mm/compaction.c                        |   17 +-
 mm/debug.c                             |    8 +-
 mm/exchange.c                          |  878 +++++++
 mm/filemap.c                           |    8 +
 mm/gup.c                               |   60 +-
 mm/huge_memory.c                       | 3360 ++++++++++++++++++++----
 mm/hugetlb.c                           |    4 +-
 mm/internal.h                          |   46 +
 mm/khugepaged.c                        |    7 +-
 mm/ksm.c                               |   39 +-
 mm/madvise.c                           |  121 +
 mm/mem_defrag.c                        | 1941 ++++++++++++++
 mm/memcontrol.c                        |   13 +
 mm/memory.c                            |   55 +-
 mm/migrate.c                           |   14 +-
 mm/mmap.c                              |   29 +
 mm/page_alloc.c                        |  108 +-
 mm/page_vma_mapped.c                   |  129 +-
 mm/pgtable-generic.c                   |   78 +-
 mm/rmap.c                              |  283 +-
 mm/swap.c                              |   38 +
 mm/swap_slots.c                        |    2 +
 mm/swapfile.c                          |    4 +-
 mm/userfaultfd.c                       |    2 +-
 mm/util.c                              |    7 +
 mm/vmscan.c                            |   55 +-
 mm/vmstat.c                            |   32 +
 61 files changed, 7452 insertions(+), 745 deletions(-)
 create mode 100644 include/linux/mem_defrag.h
 create mode 100644 include/linux/pagechain.h
 create mode 100644 mm/exchange.c
 create mode 100644 mm/mem_defrag.c

--
2.20.1

