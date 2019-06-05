Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EB36C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 337702070B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 337702070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2E4A6B026E; Wed,  5 Jun 2019 18:12:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DF3B6B026F; Wed,  5 Jun 2019 18:12:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CDE86B0270; Wed,  5 Jun 2019 18:12:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54BE96B026E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:12:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d125so290221pfd.3
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:12:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=JCsM1h5yQXD7SUajnOU5P284s+Joo0zf1R6NxeH8Gd8=;
        b=G7BgUXHdQ/dUSusyF8gzXa8LVa4x1+6NV64ebTe14uJVSldjuNjb8KxBkzZ39wh0mb
         t7SoCiVeg6TX0F5SBCw/Ow6B1lozj+RVnZK4uxezhIKdCYELZ7QPi64pLotvUFBZU+Uz
         v+a5azCdRj3AbKe30k5Y0A779Seu6GuA54oNHFIF1BjXRrRSdxq2QbSStTydFO7sTTZD
         X6d09Uj9zue43q06gzLFWzSdawxuXD/v1Mpp4yDgloY8abO8h2g9I0wPFNVzxrnktFW1
         EYUnLpaqeqgcj7HfPDQTc4/ar40nReyqSCL5AKDhgl1hHPOq5np9yfN88DDoCO5hM7Yx
         J9tQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW1wQsYhfbpXUldUti/Me16wCeLVxIrfOPW6SoL5wjYfVMBK1Bv
	ZgaVJ9rXzHnP78YTkdWYhmDVpPFPKtbEXK0FPtPoq87DfQ2lVjntNGJQPc1zvqWomr+Gka5heAl
	sbA+sffbwt/PCUeUMKKi2iHdX59oubQs10wB89eR65nAipzoL1xtxmfUDXWjtYCD5+w==
X-Received: by 2002:a62:e403:: with SMTP id r3mr19330865pfh.37.1559772727727;
        Wed, 05 Jun 2019 15:12:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydBzhvq5ofD1nfEMq6C3iiry5Uo/4B+WDRF6p+h1kDfOhSF5ntASfeu0hh62Vc8MDxVB1e
X-Received: by 2002:a62:e403:: with SMTP id r3mr19330680pfh.37.1559772726172;
        Wed, 05 Jun 2019 15:12:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772726; cv=none;
        d=google.com; s=arc-20160816;
        b=MdvWkRNyeL7+xwPXvUpIsYkyT9Nh8U8LnMN3q/fucMqu5YbNXsVTjBfmrknbk+tM8t
         0JHErIHfZjkm+HPp4358afuNlV1szn7QFjo/h9woraOIFxsO4emG8n5nmkoQqs8j9zKO
         Qihi4QN8sFq7/omvYMLJ8T9csbm7rMOkSs89V1/4ef28d4185LRMqpjf0aR43K98cE1C
         egbqkM5Zyh76cmRDaTqLx4PLHScNzwWRwWC/D5lnnppmI0q1EiUyg71TcN5CMHKKkSr/
         wy9/TKadq59LQXsm+f0qfmXVbqofIFZwuCmiBOPXVMO91Sg7zvfZU/L5JPnc+BSC8pV2
         NgLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=JCsM1h5yQXD7SUajnOU5P284s+Joo0zf1R6NxeH8Gd8=;
        b=bW+a/E3bx0nkR41XWVfNRzAeks6r9cYkj+U58krUaVjJmz5JLSXRn/F2cYA7WMkm7U
         Vz5Vqoya5zvawtnm8E5vC0k5GpBEZsUZAiWuzj31h1Li0d1TWNDB+MD0c2dTi1y3QlnN
         tCC6OrUwisvbV9X5CcTHizoD5QRmGL99iNhNMov+KdhXM6xHZWa3XhLq8ExP/jmS6oZH
         jZd0XpJwa1iRYf5fQYiCWPUmComQDFUpp/kpNmkPVfwxjTzWaCBs87sZXp4odjMepNdy
         HLtkAjAj+UJZI2APPtc1d9tctkYKlW29e56cCDZrutM/E+5C/XBk3/Yzh+ZC/MrNpMnn
         dJXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h5si35993pjs.96.2019.06.05.15.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:12:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:12:05 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga005.jf.intel.com with ESMTP; 05 Jun 2019 15:12:05 -0700
Subject: [PATCH v9 00/12] mm: Sub-section memory hotplug support
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: David Hildenbrand <david@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
 Jane Chu <jane.chu@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Jonathan Corbet <corbet@lwn.net>, Logan Gunthorpe <logang@deltatee.com>,
 Paul Mackerras <paulus@samba.org>, Toshi Kani <toshi.kani@hpe.com>,
 Oscar Salvador <osalvador@suse.de>, Jeff Moyer <jmoyer@redhat.com>,
 Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 stable@vger.kernel.org, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Wed, 05 Jun 2019 14:57:49 -0700
Message-ID: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since v8 [1]:
- Rebase on next-20190604 to incorporate the removal of the
  MHP_MEMBLOCK_API flag and other cleanups from David.

- Move definition of subsection_mask_set() earlier into "mm/sparsemem:
  Add helpers track active portions of a section at boot" (Oscar)

- Cleanup unnecessary IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP) in
  section_deactivate() in response to a request (declined) to split the
  pure CONFIG_SPARSEMEM bits from section_{de,}activate(). I submit that
  the maintenance is less error prone, especially when modifying common
  logic, if the implementations remain unified. (Oscar)

- Cleanup sparse_add_section() vs sparse_index_init() return code.
  (Oscar)

- Document ZONE_DEVICE and subsection semantics relative to
  CONFIG_SPARSEMEM_VMEMMAP in Documentation/vm/memory-model.rst. (Mike)

[1]: https://lore.kernel.org/lkml/155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com/

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

These patches are exposed to the kbuild robot on my libnvdimm-pending
branch [4], and a preview of the unit test for this functionality is
available on the 'subsection-pending' branch of ndctl [5].

[2]: https://lore.kernel.org/r/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com
[3]: https://github.com/pmem/ndctl/issues/76
[4]: https://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git/log/?h=libnvdimm-pending
[5]: https://github.com/pmem/ndctl/commit/7c59b4867e1c


---

Dan Williams (12):
      mm/sparsemem: Introduce struct mem_section_usage
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


 Documentation/vm/memory-model.rst    |   39 ++++
 arch/powerpc/include/asm/sparsemem.h |    3 
 arch/x86/mm/init_64.c                |    4 
 drivers/nvdimm/dax_devs.c            |    2 
 drivers/nvdimm/pfn.h                 |   15 -
 drivers/nvdimm/pfn_devs.c            |   95 +++------
 include/linux/memory_hotplug.h       |    7 -
 include/linux/mm.h                   |    4 
 include/linux/mmzone.h               |   92 +++++++--
 kernel/memremap.c                    |   61 ++----
 mm/memory_hotplug.c                  |  171 +++++++++-------
 mm/page_alloc.c                      |   10 +
 mm/sparse-vmemmap.c                  |   21 +-
 mm/sparse.c                          |  359 +++++++++++++++++++++++-----------
 14 files changed, 534 insertions(+), 349 deletions(-)

