Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C31FC04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BB3520883
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BB3520883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA29B6B0273; Mon, 27 May 2019 07:12:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B79966B0274; Mon, 27 May 2019 07:12:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A67D16B0275; Mon, 27 May 2019 07:12:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDF86B0273
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:12:13 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id l63so5309642oia.7
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:12:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=VgBcPqadfULIhJTxRz7nlUgkvxKbDxlVi28M/NCXNAQ=;
        b=C1H3mRItcUDUkJvUEw1nezk7NiA2euo5+00D6wBnSz0mnC+6sAMnV8Xds7cXYIaqX2
         E+1knvZkDEk3oRqrpnyj97Y1qd9QU6mW1tzXmrtBiQb7I5XEtLkn65fL8rdIF8E9HF3J
         F17ii/I0EpekTg4SQt//rXX2LMA1HVO1fXuRMYa3Q0OzTGU6OZcgwpaj/m0gO4U5tqkJ
         6F2cnrQBlyslcjfwGTgYIINkXkKYu2dMQyy+3NUgUF+w8OuzXpEHzzAken0ARVocym+k
         Y8qdu/xWT2OBvB8hxvRvgOShAqTDwtenM6xc8zjYx30xQEcwXNc1q8ZuzAsRqVI7gEqP
         VoOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWdYGuaY6fl9c94KKwzeH+zXiF7qnWmeI1QnLB7PMjhJZ046q8w
	JgtZwFOJljyexVzvwmQTAoLUAZ20A+MG3882GIHwNtKAbxSq9fGMvARgXt19+AwEJg+Z9yl297K
	4qkidb/hZT9BDFdcLlNZxCgR+oZEV53fDO8bWYO3YhMcFpFB+GhyMMQ/3lb6atX+TLQ==
X-Received: by 2002:aca:4457:: with SMTP id r84mr100934oia.42.1558955533130;
        Mon, 27 May 2019 04:12:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6JX1bNFjDZw4bR5eInJ3YtG/7UwgT1Plsngx8luAWvh6tQaEZqb+cE87SKtJ+DTS7kyFF
X-Received: by 2002:aca:4457:: with SMTP id r84mr100884oia.42.1558955532210;
        Mon, 27 May 2019 04:12:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955532; cv=none;
        d=google.com; s=arc-20160816;
        b=PJFJRSnBtMzof0ZsIHoVkGJoJNtw4rs8KZ1+RB511DsjWGeqQjNrasUATeatZqQ8o2
         Rh1aeMIfkyAZBYnPe4ct/aErkhhRrjcOaRdE4LevwxOZ8CTMBxx7DzONVqfPKhQXfMgI
         RM6SgtQcj4ZVKzMNVP5xloaepm49rf2rdEXrYWTVxlb/ZEqQj72fiz6IKVVr4yINCV1A
         9pgFfXSixIO1hDDn2ZsnadMUZC5801r3YEL5i6zB5P7L0jgmrRXWzCzWXBcuKLeS+LYK
         cBtVoKd+EalW0++KtzJf6hwCvF43o5TJ9Kgh3KxDwY5m3eh7hshmxDoMnVkkGHTjWfzX
         WadA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=VgBcPqadfULIhJTxRz7nlUgkvxKbDxlVi28M/NCXNAQ=;
        b=RjYbWblU94Ji+zlmihUz57pgRWJUkadnn8mNP1cjUUO/Uu7ZLk+LOVY0BdnSE+Po1a
         OWBIOR5kBkA8+GGHMVNeKzKR5xoIroa376CSCSidowH/aPum7oHInV8QnXErowWx/4Na
         9kMXN8cDPb9SO4Yx10zu3z6M2HWksa94EP4XaIWQsS01UDOna4LU3ywijX3pJIUXE5a4
         47ZgXD/5JH/qcr+gUoNfZ656fDB8XAqef9YKbqtSRWaqEJsNLgWe8MV9Ts/qQVEnaTSl
         6mPg+alEA54ujrYBAK+ngIEIC/GO6cg+RJwLXiKIQe0uMTER2F6mMV5fBi42USfu4LSx
         /FtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n204si5702809oih.75.2019.05.27.04.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:12:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F158C88317;
	Mon, 27 May 2019 11:12:09 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9B2952AA81;
	Mon, 27 May 2019 11:11:53 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	David Hildenbrand <david@redhat.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Andy Lutomirski <luto@kernel.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arun KS <arunks@codeaurora.org>,
	Baoquan He <bhe@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Mark Brown <broonie@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Mathieu Malaterre <malat@debian.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	Oscar Salvador <osalvador@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Qian Cai <cai@lca.pw>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Rich Felker <dalias@libc.org>,
	Rob Herring <robh@kernel.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tony Luck <tony.luck@intel.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Yu Zhao <yuzhao@google.com>
Subject: [PATCH v3 00/11] mm/memory_hotplug: Factor out memory block devicehandling
Date: Mon, 27 May 2019 13:11:41 +0200
Message-Id: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 27 May 2019 11:12:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We only want memory block devices for memory to be onlined/offlined
(add/remove from the buddy). This is required so user space can
online/offline memory and kdump gets notified about newly onlined memory.

Let's factor out creation/removal of memory block devices. This helps
to further cleanup arch_add_memory/arch_remove_memory() and to make
implementation of new features easier - especially sub-section
memory hot add from Dan.

Anshuman Khandual is currently working on arch_remove_memory(). I added
a temporary solution via "arm64/mm: Add temporary arch_remove_memory()
implementation", that is sufficient as a firsts tep in the context of
this series. (we don't cleanup page tables in case anything goes
wrong already)

Did a quick sanity test with DIMM plug/unplug, making sure all devices
and sysfs links properly get added/removed. Compile tested on s390x and
x86-64.

Based on next/master.

Next refactoring on my list will be making sure that remove_memory()
will never deal with zones / access "struct pages". Any kind of zone
handling will have to be done when offlining system memory / before
removing device memory. I am thinking about remove_pfn_range_from_zone()",
du undo everything "move_pfn_range_to_zone()" did.

v2 -> v3:
- Add "s390x/mm: Fail when an altmap is used for arch_add_memory()"
- Add "arm64/mm: Add temporary arch_remove_memory() implementation"
- Add "drivers/base/memory: Pass a block_id to init_memory_block()"
- Various changes to "mm/memory_hotplug: Create memory block devices
  after arch_add_memory()" and "mm/memory_hotplug: Create memory block
  devices after arch_add_memory()" due to switching from sections to
  block_id's.

v1 -> v2:
- s390x/mm: Implement arch_remove_memory()
-- remove mapping after "__remove_pages"

David Hildenbrand (11):
  mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
  s390x/mm: Fail when an altmap is used for arch_add_memory()
  s390x/mm: Implement arch_remove_memory()
  arm64/mm: Add temporary arch_remove_memory() implementation
  drivers/base/memory: Pass a block_id to init_memory_block()
  mm/memory_hotplug: Allow arch_remove_pages() without
    CONFIG_MEMORY_HOTREMOVE
  mm/memory_hotplug: Create memory block devices after arch_add_memory()
  mm/memory_hotplug: Drop MHP_MEMBLOCK_API
  mm/memory_hotplug: Remove memory block devices before
    arch_remove_memory()
  mm/memory_hotplug: Make unregister_memory_block_under_nodes() never
    fail
  mm/memory_hotplug: Remove "zone" parameter from
    sparse_remove_one_section

 arch/arm64/mm/mmu.c            |  17 +++++
 arch/ia64/mm/init.c            |   2 -
 arch/powerpc/mm/mem.c          |   2 -
 arch/s390/mm/init.c            |  18 +++--
 arch/sh/mm/init.c              |   2 -
 arch/x86/mm/init_32.c          |   2 -
 arch/x86/mm/init_64.c          |   2 -
 drivers/base/memory.c          | 134 +++++++++++++++++++--------------
 drivers/base/node.c            |  27 +++----
 include/linux/memory.h         |   6 +-
 include/linux/memory_hotplug.h |  12 +--
 include/linux/node.h           |   7 +-
 mm/memory_hotplug.c            |  44 +++++------
 mm/sparse.c                    |  10 +--
 14 files changed, 140 insertions(+), 145 deletions(-)

-- 
2.20.1

