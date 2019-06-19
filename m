Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8992FC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:05:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3139B20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:05:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3139B20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFE666B0003; Wed, 19 Jun 2019 02:05:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C875C8E0002; Wed, 19 Jun 2019 02:05:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B27AB8E0001; Wed, 19 Jun 2019 02:05:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75B036B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:05:52 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a21so11574962pgh.11
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:05:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=lTLuQI+roabvjKxff1eyWnIYOzFlo9taS6NKuUdXOSQ=;
        b=DMzQf1zmV8W/VzFsYaSrgM01APbqx0A3x2fM7DmNkRPc6qnl6Qh6/N7l3WsM6K9PEE
         DdlmY5M2Cq3zW8oQDGcbdwDUd1Wf0JQmHDWCTadGrdhqL3hHaU2wiU7VfHEd4AM8wl7C
         2wGmlWZmrkvMxEWLABh3Qr2u+RJhUDMMA2W5ua2RhzvHT26CsPPLr3S0+LWQvzIRIwOP
         mZO+WyElgHyoY18SX4cZnKMnATDvf3mvaUmUfdhoYoNKuWVTt6O4fewfR3oIfUVqTYUH
         GMwwaweTLW7bNvrcga2j7gesn1UISBKqej+GGBio9JhU9D3j9QXCBJZ7L1nEEZAWD1CM
         8Hzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUfxWmiijI+NFEBrWYrugRvySRJSEec3kByKYelGSGbQCcML4it
	4pMialazsrGDPrhpmdKXrodYOmgUVLIRp71G/CpSdj82ruVjVtg9kZlYW9RJlTFdWlbve73gGXZ
	MWYYui3cS4hhCkwVPRAb+wievE+31Mv8JTfqFeGLcou4RMmPeXZ2BfF0Cm/oVZW/IGw==
X-Received: by 2002:a17:90a:2648:: with SMTP id l66mr9166954pje.65.1560924352024;
        Tue, 18 Jun 2019 23:05:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsndneHA4N3GhvImWt3ixd5kbqqtTJRsLWbLNW86LO+tSlnNvyAhChbll0w5SOZcE3ATEu
X-Received: by 2002:a17:90a:2648:: with SMTP id l66mr9166884pje.65.1560924350904;
        Tue, 18 Jun 2019 23:05:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924350; cv=none;
        d=google.com; s=arc-20160816;
        b=fEq5bpNJ3pqh9ogfU4lk8dtxw2QEZx0XRi3ZC7UgBtmh38on21oHgyFRQxyV9RNZts
         RM5K2rwppfLXdLrckbLmKiFWYnz8Yl+BvONX3aZ4yAokYewZp3HSI4Yat4KMYSc9nejt
         5N2s4mXbALKgQ/ygFvpH53uw5ElL170oGI/I5fWEWAqcHG1qJTVbphr/JKVDQlq1HAwl
         RH3xf7zrn1PpapFdUQBsynqW75f6IvlDj+RS5EDELgNvCmECM85f2z0POeaIAljtOso1
         hwHbNGdQ9a8ZUvf3BnX9R0jG5dpqFCWA0z/UCQVRBAkthRiqMWSQK1R3EHIlR24LPb/j
         hpTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=lTLuQI+roabvjKxff1eyWnIYOzFlo9taS6NKuUdXOSQ=;
        b=HVCph6bOoQTseDICRfoTIuE5fjwSj0TrYjUzaQweQEom0rwXq+KWoFI32ngLKOcErz
         TfTbaq57zuTWL7vKbOlRjRIGImgyDi6pPNwDbU9QBWIjRwvR9qZxMhJzVvLE3bYdfG9B
         h6LdS0iBjvypBgnFTDMonQoDtrMl8O7Nhv/H4ycxcOnyHrKawKpb7InhOfwxVCmyAXL6
         p7TLO1LrwvBal24Pc47MMG1j1d29CZrw8PXa3iqnSrIcTASlisNLuYhnjBXkZbRFE9+5
         dlTzguwiYFiOlyZ514Ukj6A8HSwUmkMaAc4ub343GcBdZ0wnuIOPX7DgNg23dZAZlcuA
         EY6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c38si2234619pgc.65.2019.06.18.23.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:05:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:05:50 -0700
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="162111580"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga003-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:05:49 -0700
Subject: [PATCH v10 00/13] mm: Sub-section memory hotplug support
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: David Hildenbrand <david@redhat.com>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Jane Chu <jane.chu@oracle.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Jonathan Corbet <corbet@lwn.net>,
 Qian Cai <cai@lca.pw>, Logan Gunthorpe <logang@deltatee.com>,
 Toshi Kani <toshi.kani@hpe.com>, Oscar Salvador <osalvador@suse.de>,
 Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>,
 Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org,
 Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Tue, 18 Jun 2019 22:51:33 -0700
Message-ID: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since v9 [1]:
- Fix multiple issues related to the fact that pfn_valid() has
  traditionally returned true for any pfn in an 'early' (onlined at
  boot) section regardless of whether that pfn represented 'System RAM'.
  Teach pfn_valid() to maintain its traditional behavior in the presence
  of subsections. Specifically, subsection precision for pfn_valid() is
  only considered for non-early / hot-plugged sections. (Qian)

- Related to the first item introduce a SECTION_IS_EARLY
  (->section_mem_map flag) to remove the existing hacks for determining
  an early section by looking at whether the usemap was allocated from the
  slab.

- Kill off the EEXIST hackery in __add_pages(). It breaks
  (arch_add_memory() false-positive) the detection of subsection
  collisions reported by section_activate(). It is also obviated by
  David's recent reworks to move the 'System RAM' request_region() earlier
  in the add_memory() sequence().

- Switch to an arch-independent / static subsection-size of 2MB.
  Otherwise, a per-arch subsection-size is a roadblock on the path to
  persistent memory namespace compatibility across archs. (Jeff)

- Update the changelog for "libnvdimm/pfn: Fix fsdax-mode namespace
  info-block zero-fields" to clarify that the "Cc: stable" is only there
  as safety measure for a distro that decides to backport "libnvdimm/pfn:
  Stop padding pmem namespaces to section alignment", otherwise there is
  no known bug exposure in older kernels. (Andrew)
  
- Drop some redundant subsection checks (Oscar)

- Collect some reviewed-bys

[1]: https://lore.kernel.org/lkml/155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com/

---

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

These patches are exposed to the kbuild robot on a subsection-v10 branch
[4], and a preview of the unit test for this functionality is available
on the 'subsection-pending' branch of ndctl [5].

[2]: https://lore.kernel.org/r/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com
[3]: https://github.com/pmem/ndctl/issues/76
[4]: https://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git/log/?h=subsection-v10
[5]: https://github.com/pmem/ndctl/commit/7c59b4867e1c

---

Dan Williams (13):
      mm/sparsemem: Introduce struct mem_section_usage
      mm/sparsemem: Introduce a SECTION_IS_EARLY flag
      mm/sparsemem: Add helpers track active portions of a section at boot
      mm/hotplug: Prepare shrink_{zone,pgdat}_span for sub-section removal
      mm/sparsemem: Convert kmalloc_section_memmap() to populate_section_memmap()
      mm/hotplug: Kill is_dev_zone() usage in __remove_pages()
      mm: Kill is_dev_zone() helper
      mm/sparsemem: Prepare for sub-section ranges
      mm/sparsemem: Support sub-section hotplug
      mm: Document ZONE_DEVICE memory-model implications
      mm/devm_memremap_pages: Enable sub-section remap
      libnvdimm/pfn: Fix fsdax-mode namespace info-block zero-fields
      libnvdimm/pfn: Stop padding pmem namespaces to section alignment


 Documentation/vm/memory-model.rst |   39 ++++
 arch/x86/mm/init_64.c             |    4 
 drivers/nvdimm/dax_devs.c         |    2 
 drivers/nvdimm/pfn.h              |   15 --
 drivers/nvdimm/pfn_devs.c         |   95 +++-------
 include/linux/memory_hotplug.h    |    7 -
 include/linux/mm.h                |    4 
 include/linux/mmzone.h            |   84 +++++++--
 kernel/memremap.c                 |   61 +++----
 mm/memory_hotplug.c               |  173 +++++++++----------
 mm/page_alloc.c                   |   16 +-
 mm/sparse-vmemmap.c               |   21 ++
 mm/sparse.c                       |  335 ++++++++++++++++++++++++-------------
 13 files changed, 494 insertions(+), 362 deletions(-)

