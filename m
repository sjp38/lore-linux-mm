Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CA41C04AA8
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFDCC2085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFDCC2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61E8B6B0005; Thu,  2 May 2019 02:09:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CF0F6B0006; Thu,  2 May 2019 02:09:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BF0A6B0007; Thu,  2 May 2019 02:09:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 124C86B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 02:09:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s19so730096plp.6
        for <linux-mm@kvack.org>; Wed, 01 May 2019 23:09:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=MwqWU+4hGbok5ssY59rht/KDrBfy+4irWdo1mz/1chg=;
        b=TqfLhdQ46GOV4pYCfsKh/tjR6YciRsNTjUvy25LIxghBjpxeYGHCXD7Tz7Iwz6qwkn
         rq66aN7gsx+4FHewpvymxwu25ocg28k+HFM6FLEHb/6hlrJOwA9vRLZW05yRkzcZtewK
         wvYaw+9okWPlHvzKtW83uj4UsDwM6s7Dwkoq1V45Q2djxr8e3ZChujy6/OIxYSmZOBE6
         pPWbm3G7Lp+Lrvhc58x2DCqZIcTB4WFKKD5CX40KOwWN1luP+52OLLgzD8BiIUbpBdDn
         H+K5dIZivaCJHXuGvPtFrneJtezAtdFiCy0hah2IXCpIC2BwILlV7pC0XeeZGr+bOGfq
         X2hg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWYwMexsRrGGHFBtZgjS9zALGTd8r0QL+qes9khqVBSFAZXAhA7
	kwx5sZATj2nEQmETlerF9tnI2y1jzrOK7mdKPw/DOAl727TxdD8MO3a2wJRWSMlGY5HbS4KZ+HG
	BfS8oYELoVZSWEZxGMItVIWCACmGJjlFev2/ejLY/xnSw/yhDY0DdjKTmNERXy4sBLA==
X-Received: by 2002:a63:2c4a:: with SMTP id s71mr2118182pgs.373.1556777350668;
        Wed, 01 May 2019 23:09:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEQrGDVmzdjbLwkcYIL4rFXyz4mLb5+GyHkIvIB98+7TwI7ZhHoDFp8a2GHXxpbWYoIUBG
X-Received: by 2002:a63:2c4a:: with SMTP id s71mr2118073pgs.373.1556777349628;
        Wed, 01 May 2019 23:09:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556777349; cv=none;
        d=google.com; s=arc-20160816;
        b=Qn3bvBTm2Cfa0dGPlBe6aL8Bbb4je/JGvzt2JQYUeJcTbklFzH9UzxZT6VzL7s+4n6
         Am0y+YCjJMgt/j0q3x3i42mI706tjRIj1n0M8vrdaR02Z3o5O7At+K2hIuet/9E6GLUD
         pFD/Vqnr+GINBRynT2st2og2a6gN9Qh3ZOUA85GqwPDdtBQHX6hVJ4kCTK4fUL4AbvhS
         W+d4Jg4A1U37jdpYVShzle8yZhE87pksqkb+Z3ZukrOrQfq8Pn541vLqOcp9CojF1iOK
         RpRR14uNPyyJar7OSXF0jpyyukFKqzUr31b+aaAlUbbmA802FgBg0doXVkDU7dK3DpDq
         TSKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=MwqWU+4hGbok5ssY59rht/KDrBfy+4irWdo1mz/1chg=;
        b=s/QB2djdNmJA84q9sqJmZcCj3LN0MJNP/6wx25+jKLZDvzTe41gSN7jqm6YzK0sJha
         /BPrxMVdkOwIPknlGZ5g9/vOXCCfe3FtY5Z9oerayY3SFi+T7k2SfexZY0Sp8OKJSl5E
         WIdcc+6KmKqh2gMC8Phh+uDNbi5AlpxItpQUpKI05nrKjWslwgqn9BnY7kWRLAQ1fcCW
         6Y1xEvMB1gN0QGzQtHKxow87jiPqM32/2f39mMIZga7CAch/B9hX79wtq0ER6IZELhw2
         6E7+SiLFasblB6xKUtKivZO+HpkH3GRVg17dc24NPXnUmQA63NF6e7oRa5zGDVyGysCF
         YunA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id k12si42045379plt.28.2019.05.01.23.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 23:09:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 23:09:09 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,420,1549958400"; 
   d="scan'208";a="320740307"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga005.jf.intel.com with ESMTP; 01 May 2019 23:09:08 -0700
Subject: [PATCH v7 00/12] mm: Sub-section memory hotplug support
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: David Hildenbrand <david@redhat.com>, Jane Chu <jane.chu@oracle.com>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>,
 Oscar Salvador <osalvador@suse.de>, Jeff Moyer <jmoyer@redhat.com>,
 Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 stable@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, osalvador@suse.de, mhocko@suse.com
Date: Wed, 01 May 2019 22:55:22 -0700
Message-ID: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since v6 [1]:

- Rebase on next-20190501, no related conflicts or updates

- Fix boot crash due to inaccurate setup of the initial section
  ->map_active bitmask caused by multiple activations of the same
  section. (Jane, Jeff)

- Fix pmem startup crash when devm_memremap_pages() needs to instantiate
  a new section. (Jeff)

- Drop mhp_restrictions for the __remove_pages() path in favor of
  find_memory_block() to detect cases where section-aligned remove is
  required (David)

- Add "[PATCH v7 06/12] mm/hotplug: Kill is_dev_zone() usage in
  __remove_pages()"

- Cleanup shrink_{zone,pgdat}_span to remove no longer necessary @ms
  section variables. (Oscar)

- Add subsection_check() to the __add_pages() path to prevent
  inadvertent sub-section misuse.

[1]: https://lore.kernel.org/lkml/155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com/

---
[merge logistics]

Hi Andrew,

I believe this is ready for another spin in -mm now that the boot
regression has been squashed. In a chat with Michal last night at LSF/MM
I submitted to his assertion that the boot regression validates the
general concern that there were/are subtle dependencies on sections
beyond what I found to date by code inspection. Of course I want to
relieve the pain that the section constraint inflicts on libnvdimm and
devm_memremap_pages() as soon as possible (i.e. v5.2), but deferment to
v5.3 to give Michal time to do an in-depth look is also acceptable.

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

Dan Williams (12):
      mm/sparsemem: Introduce struct mem_section_usage
      mm/sparsemem: Introduce common definitions for the size and mask of a section
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


 arch/x86/mm/init_64.c          |    4 
 drivers/nvdimm/dax_devs.c      |    2 
 drivers/nvdimm/pfn.h           |   12 -
 drivers/nvdimm/pfn_devs.c      |   93 +++-------
 include/linux/memory_hotplug.h |    7 -
 include/linux/mm.h             |    4 
 include/linux/mmzone.h         |   72 ++++++--
 kernel/memremap.c              |   63 +++----
 mm/hmm.c                       |    2 
 mm/memory_hotplug.c            |  172 ++++++++++---------
 mm/page_alloc.c                |    8 +
 mm/sparse-vmemmap.c            |   21 ++
 mm/sparse.c                    |  370 ++++++++++++++++++++++++++++------------
 13 files changed, 490 insertions(+), 340 deletions(-)

