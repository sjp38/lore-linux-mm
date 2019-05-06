Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 533D6C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03DFB20830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03DFB20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86C736B0005; Mon,  6 May 2019 19:53:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81E226B0006; Mon,  6 May 2019 19:53:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70CC76B0007; Mon,  6 May 2019 19:53:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 387BA6B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:53:16 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i8so6523229pfo.21
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:53:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=l36xHkXiRU9ZvmTp32NiBfmj8Y5fWw+bI63e4zI1fX0=;
        b=P/0t8zxLxwIII+IUZbWp8pxywQcTZfN4DzuTPk4wiVhUcj7Z9D0m9Z2aVz1fPgK6aK
         C6tmo0rmpBDOaY/UZvGzQrWEVQF8qsWxNBVecbYYZptoa+NYhsg8YQZzPVStYekN5Hhc
         nglp20PGe72+io952+SEmKu6FJgeII2iflsqiYcgoPwsW9JDvjWVBAGKjf6qEXyvts9+
         qg8/eQ2zP6Ft+HC4WCYpj1Vspsql+A+FStARcDCG39PJ6kkAfpvuYbfJnT9mBubUsh+k
         VVP5AoyDyi3Ll3ULSjSm7aCHSR7tQkBUF++jYDT3T/rps8VAvveS1w7XBWczd5jYwn3j
         56Ew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVL3kn/bfAvYPDMG3ELSYHRLn/9wK1M2m18enNVwsy8u10AkQY9
	o9ptb9mBQPcY/OIkxuWuQukdZ+CbeZ8zIzMETcQ0nPe/j3PiNJ/y9tFIDCQ9viwEh7Xc5Aiv+GO
	rTyNYGBdYBdoez6vD1g1QZ4GddT/Wu1VIQZs/hyzzeYzSXqB/+aQO7+lAnZ5VBvNKVw==
X-Received: by 2002:a17:902:3324:: with SMTP id a33mr4715135plc.1.1557186795830;
        Mon, 06 May 2019 16:53:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5nMm9KHi5vgtGbN9bbGESdFgZb4UB+qZD6U9PkSCEtGni/qOcbFgf9/iMzGfMJxQToDHB
X-Received: by 2002:a17:902:3324:: with SMTP id a33mr4714927plc.1.1557186794148;
        Mon, 06 May 2019 16:53:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557186794; cv=none;
        d=google.com; s=arc-20160816;
        b=hRcIrhun9lPjC/DDGofo64Na45x04oTONJjKG4JsiFCYjZAVVQp+MTBc1xDRwXbIeK
         Lo56Gib3CnZBEZaNyIhTVc6bSETGcJRH+LAi54c+aCqqhnaFgDEY3A5o1q+DjaAXkvrF
         aPqZNaUf52i+pwL+CWgXnNs0OhWfNl82XFU3UCfYDi5lkds/ZfAJC/9qrbUTsLBwq18W
         ZAcA2t4NO6ryJivROt7mZ3w57L4KaH3QMbVI+p3wOxDuaYYifqh9K5VNLrMcxPGLn12J
         wzjsynKwsxpbApjaZFy+5e1UX9qKrVwOZQFlDoYkrU49di6LknpgODWJoy7hcJjTNeNL
         jKsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=l36xHkXiRU9ZvmTp32NiBfmj8Y5fWw+bI63e4zI1fX0=;
        b=xMnnkLlxIMYGTeyWXHm485efF7ALO9rwhgcfCSaB3n4YVkgKVk4wylnajpHJwFbKZ1
         OmfOFwDueU0S7L/xarnK1IZV1RKltQNgAG8FpGYEyCDDj5SzK/txh+6JvwTGG+mIZlUb
         z+wUXliKqt7oKUg64qPExHsoUQmeOoZMSnndVv4G+Iw0VeLtvLXyzwT0H6pPxTrzkazE
         FzYCwUHxoOqVPI/t1dZWeeIyDzSM3FOgR2rZAitU58wF9R0JpGYS3Abf1tcjFK1snK0O
         ZGuBj2bJAYELi1CLDPbTc0H5CBlovi4gTW0Bs5f1xWFqzVOsNv8SivuJSAewhA1CQm4E
         VWnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e19si16036751pgv.63.2019.05.06.16.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:53:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 May 2019 16:53:13 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,439,1549958400"; 
   d="scan'208";a="140720507"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga008.jf.intel.com with ESMTP; 06 May 2019 16:53:13 -0700
Subject: [PATCH v8 00/12] mm: Sub-section memory hotplug support
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: David Hildenbrand <david@redhat.com>, Jane Chu <jane.chu@oracle.com>,
 Michael Ellerman <mpe@ellerman.id.au>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Robin Murphy <robin.murphy@arm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Logan Gunthorpe <logang@deltatee.com>, Paul Mackerras <paulus@samba.org>,
 Toshi Kani <toshi.kani@hpe.com>, Oscar Salvador <osalvador@suse.de>,
 Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>,
 Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Mon, 06 May 2019 16:39:26 -0700
Message-ID: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since v7 [1]:

- Make subsection helpers pfn based rather than physical-address based
  (Oscar and Pavel)

- Make subsection bitmap definition scalable for different section and
  sub-section sizes across architectures. As a result:

      unsigned long map_active

  ...is converted to:

      DECLARE_BITMAP(subsection_map, SUBSECTIONS_PER_SECTION)

  ...and the helpers are renamed with a 'subsection' prefix. (Pavel)

- New in this version is a touch of arch/powerpc/include/asm/sparsemem.h
  in "[PATCH v8 01/12] mm/sparsemem: Introduce struct mem_section_usage"
  to define ARCH_SUBSECTION_SHIFT.

- Drop "mm/sparsemem: Introduce common definitions for the size and mask
  of a section" in favor of Robin's "mm/memremap: Rename and consolidate
  SECTION_SIZE" (Pavel)

- Collect some more Reviewed-by tags. Patches that still lack review
  tags: 1, 3, 9 - 12

[1]: https://lore.kernel.org/lkml/155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com/

---
[merge logistics]

Hi Andrew,

These are too late for v5.2, I'm posting this v8 during the merge window
to maintain the review momentum. 

---
[cover letter]

The memory hotplug section is an arbitrary / convenient unit for memory
hotplug. 'Section-size' units have bled into the user interface
('memblock' sysfs) and can not be changed without breaking existing
userspace. The section-size constraint, while mostly benign for typical
memory hotplug, has and continues to wreak havoc with 'device-memory'
use cases, persistent memory (pmem) in particular. Recall that pmem uses
devm_memremap_pages(), and subsequently arch_add_memory(), to allocate a
'struct page' memmap for pmem. However, it does not use the 'bottom
half' of memory hotplug, i.e. never marks pmem pages online and never
exposes the userspace memblock interface for pmem. This leaves an
opening to redress the section-size constraint.

To date, the libnvdimm subsystem has attempted to inject padding to
satisfy the internal constraints of arch_add_memory(). Beyond
complicating the code, leading to bugs [2], wasting memory, and limiting
configuration flexibility, the padding hack is broken when the platform
changes this physical memory alignment of pmem from one boot to the
next. Device failure (intermittent or permanent) and physical
reconfiguration are events that can cause the platform firmware to
change the physical placement of pmem on a subsequent boot, and device
failure is an everyday event in a data-center.

It turns out that sections are only a hard requirement of the
user-facing interface for memory hotplug and with a bit more
infrastructure sub-section arch_add_memory() support can be added for
kernel internal usages like devm_memremap_pages(). Here is an analysis
of the current design assumptions in the current code and how they are
addressed in the new implementation:

Current design assumptions:

- Sections that describe boot memory (early sections) are never
  unplugged / removed.

- pfn_valid(), in the CONFIG_SPARSEMEM_VMEMMAP=y, case devolves to a
  valid_section() check

- __add_pages() and helper routines assume all operations occur in
  PAGES_PER_SECTION units.

- The memblock sysfs interface only comprehends full sections

New design assumptions:

- Sections are instrumented with a sub-section bitmask to track (on x86)
  individual 2MB sub-divisions of a 128MB section.

- Partially populated early sections can be extended with additional
  sub-sections, and those sub-sections can be removed with
  arch_remove_memory(). With this in place we no longer lose usable memory
  capacity to padding.

- pfn_valid() is updated to look deeper than valid_section() to also check the
  active-sub-section mask. This indication is in the same cacheline as
  the valid_section() so the performance impact is expected to be
  negligible. So far the lkp robot has not reported any regressions.

- Outside of the core vmemmap population routines which are replaced,
  other helper routines like shrink_{zone,pgdat}_span() are updated to
  handle the smaller granularity. Core memory hotplug routines that deal
  with online memory are not touched.

- The existing memblock sysfs user api guarantees / assumptions are
  not touched since this capability is limited to !online
  !memblock-sysfs-accessible sections.

Meanwhile the issue reports continue to roll in from users that do not
understand when and how the 128MB constraint will bite them. The current
implementation relied on being able to support at least one misaligned
namespace, but that immediately falls over on any moderately complex
namespace creation attempt. Beyond the initial problem of 'System RAM'
colliding with pmem, and the unsolvable problem of physical alignment
changes, Linux is now being exposed to platforms that collide pmem
ranges with other pmem ranges by default [3]. In short,
devm_memremap_pages() has pushed the venerable section-size constraint
past the breaking point, and the simplicity of section-aligned
arch_add_memory() is no longer tenable.

These patches are exposed to the kbuild robot on my libnvdimm-pending
branch [4], and a preview of the unit test for this functionality is
available on the 'subsection-pending' branch of ndctl [5].

[2]: https://lore.kernel.org/r/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com
[3]: https://github.com/pmem/ndctl/issues/76
[4]: https://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git/log/?h=libnvdimm-pending
[5]: https://github.com/pmem/ndctl/commit/7c59b4867e1c

---

Dan Williams (11):
      mm/sparsemem: Introduce struct mem_section_usage
      mm/sparsemem: Add helpers track active portions of a section at boot
      mm/hotplug: Prepare shrink_{zone,pgdat}_span for sub-section removal
      mm/sparsemem: Convert kmalloc_section_memmap() to populate_section_memmap()
      mm/hotplug: Kill is_dev_zone() usage in __remove_pages()
      mm: Kill is_dev_zone() helper
      mm/sparsemem: Prepare for sub-section ranges
      mm/sparsemem: Support sub-section hotplug
      mm/devm_memremap_pages: Enable sub-section remap
      libnvdimm/pfn: Fix fsdax-mode namespace info-block zero-fields
      libnvdimm/pfn: Stop padding pmem namespaces to section alignment

Robin Murphy (1):
      mm/memremap: Rename and consolidate SECTION_SIZE


 arch/powerpc/include/asm/sparsemem.h |    3 
 arch/x86/mm/init_64.c                |    4 
 drivers/nvdimm/dax_devs.c            |    2 
 drivers/nvdimm/pfn.h                 |   15 -
 drivers/nvdimm/pfn_devs.c            |   95 +++------
 include/linux/memory_hotplug.h       |    7 -
 include/linux/mm.h                   |    4 
 include/linux/mmzone.h               |   93 +++++++--
 kernel/memremap.c                    |   63 ++----
 mm/hmm.c                             |    2 
 mm/memory_hotplug.c                  |  172 +++++++++-------
 mm/page_alloc.c                      |    8 -
 mm/sparse-vmemmap.c                  |   21 +-
 mm/sparse.c                          |  369 +++++++++++++++++++++++-----------
 14 files changed, 511 insertions(+), 347 deletions(-)

