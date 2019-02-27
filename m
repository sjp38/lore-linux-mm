Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A20C3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 627122133D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 627122133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D63078E0003; Wed, 27 Feb 2019 17:50:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D14438E0001; Wed, 27 Feb 2019 17:50:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C29138E0003; Wed, 27 Feb 2019 17:50:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 865D78E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 17:50:30 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 202so13328227pgb.6
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 14:50:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=OHDGhb0MZIqeC0ZuKOhSecYdcgZsyxoRgwNVBcSffNU=;
        b=j08LOZUcPwHoPZgeYq8wDCSwbM70CA99P9zAQV7hDXFpHdbOJwtEAD8bPD2xVD3tqF
         YtEdVwRZWfomqEnyPjcKocYy0x+F3hJh5bJMs3iXNP4lpJcAa2R94ICWNSvYFEeC8o2o
         a0T8MTXu9651WlhPLmINqELmZ8GnBkeIMN9H7glNsZTKgcxj7mEYWGgBF3e6PlttTGTu
         GTPLXSnD1psme0kXybmpVbC3j+PM4ltS3xHJ9lhLqrDpuJKkqnZinIAARr6CI/gZfRIe
         wIRqRHy6r39cSLIlTszdvZHFI4EBi1snEDyO9R8eEYRf5mAzKhogMQaa3KZA0oGxWHZa
         QbEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYx9M5i/T3wvQssMFe8GXJLMfyN/e49bk5jJuwh/DsLmFowXH4P
	i/966/AYLYdtYuRz6s3gyADylU4HIb3WAVBtOdhqJAt4il12w+62RLQ+xGzqnG2FVBs06Pa5jkG
	ahpwjEWFdEswfhw8MbP2D9L5hJDSb7dZ+cAbgnuzCd8syRKpP+YtHudaSPiWZr9BduA==
X-Received: by 2002:a65:63c1:: with SMTP id n1mr5260397pgv.339.1551307830107;
        Wed, 27 Feb 2019 14:50:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZac2d7D5gYGk6yXWNpohagc1RPmKafbgmSnd01tlTmp1GKIFGHYTIyMFjjVBxylaiO8KuD
X-Received: by 2002:a65:63c1:: with SMTP id n1mr5260324pgv.339.1551307828940;
        Wed, 27 Feb 2019 14:50:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551307828; cv=none;
        d=google.com; s=arc-20160816;
        b=uUATLzJ121qmEN/RDw9sO/FNnodd3KSyLUi3OSdchOqNoEydTJX4OtwzIF0kcBbq+E
         cZjyVJw1B4+HZK4LOvFR9qsH/wyWNAI6k/fHOyDPXEeQK9wVNFUeMU6QYEd/QCFtkBBb
         QdUtu2P53lqUfp2DEHJvvvJG+JjLRApL2Zz6Dup3v4bBMWVyAHaHm5qqEvRxafYqKdLF
         mlF3w6x2kqQSugp80dCR2yWkyVxbnXA+gBNd3C3bfkQVbIR5xIICZK61yLoaPZr7RkHx
         HUPohny9NWEPu2aHGv4zmJYeqJce5O2UdmxgcTEdwsNSFISMCsjPUZothO3cjskCLqx4
         3ukg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=OHDGhb0MZIqeC0ZuKOhSecYdcgZsyxoRgwNVBcSffNU=;
        b=I7zmDO3VEHbvxjKmx3EDkFpcVD2CXBB9SghDP1MyLOBd/xyDcm9dHlhozOZu04tPQd
         FG1mCdAXz2OXIx7eOKrulcK2wAIe2SPgbWBaJuyBJCa2UkscAjHT2CQASpLrfovCsRTe
         P+u9tx1xcsK/YqMOKquFAljvPdZC/wMf6w89p5mrbR1FaCVfKxvQvdENOwQ/79LcLBze
         AX4BwO7NbKenAv2EqAdtrxR5AY5PTn9kvll8J4xAWyJau9noNwDmiAitr0lXKsFyNiDs
         daJvgZB5CZFFLuKlGrSAHPuw0/AGi+gjM3lqcKPIjQpuViVTezG/3lrDXvO9qFvGnKyE
         LYBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z20si10836901pgf.324.2019.02.27.14.50.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 14:50:28 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Feb 2019 14:50:28 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,420,1544515200"; 
   d="scan'208";a="121349372"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga008.jf.intel.com with ESMTP; 27 Feb 2019 14:50:27 -0800
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv7 00/10] Heterogenous memory node attributes
Date: Wed, 27 Feb 2019 15:50:28 -0700
Message-Id: <20190227225038.20438-1-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

== Changes since v6 ==

  Updated to linux-next, which has a change to the HMAT structures to
  account for ACPI revision 6.3.

  Changed memory-side cache "associativity" attribute to "indexing"


Regarding the Kconfig, I am having the implementation specific as a user
selectable option, and the generic interface, HMEM_REPORTING, is not a
user prompt. I just wanted to clarify the point that there's only one.


== Background ==

Platforms may provide multiple types of cpu attached system memory. The
memory ranges for each type may have different characteristics that
applications may wish to know about when considering what node they want
their memory allocated from. 

It had previously been difficult to describe these setups as memory
rangers were generally lumped into the NUMA node of the CPUs. New
platform attributes have been created and in use today that describe
the more complex memory hierarchies that can be created.

This series' objective is to provide the attributes from such systems
that are useful for applications to know about, and readily usable with
existing tools and libraries. Those applications may query performance
attributes relative to a particular CPU they're running on in order to
make more informed choices for where they want to allocate hot and cold
data. This works with mbind() or the numactl library.

Keith Busch (10):
  acpi: Create subtable parsing infrastructure
  acpi: Add HMAT to generic parsing tables
  acpi/hmat: Parse and report heterogeneous memory
  node: Link memory nodes to their compute nodes
  node: Add heterogenous memory access attributes
  node: Add memory-side caching attributes
  acpi/hmat: Register processor domain to its memory
  acpi/hmat: Register performance attributes
  acpi/hmat: Register memory side cache attributes
  doc/mm: New documentation for memory performance

 Documentation/ABI/stable/sysfs-devices-node   |  87 +++-
 Documentation/admin-guide/mm/numaperf.rst     | 164 +++++++
 arch/arm64/kernel/acpi_numa.c                 |   2 +-
 arch/arm64/kernel/smp.c                       |   4 +-
 arch/ia64/kernel/acpi.c                       |  14 +-
 arch/x86/kernel/acpi/boot.c                   |  36 +-
 drivers/acpi/Kconfig                          |   1 +
 drivers/acpi/Makefile                         |   1 +
 drivers/acpi/hmat/Kconfig                     |  11 +
 drivers/acpi/hmat/Makefile                    |   1 +
 drivers/acpi/hmat/hmat.c                      | 670 ++++++++++++++++++++++++++
 drivers/acpi/numa.c                           |  16 +-
 drivers/acpi/scan.c                           |   4 +-
 drivers/acpi/tables.c                         |  76 ++-
 drivers/base/Kconfig                          |   8 +
 drivers/base/node.c                           | 352 +++++++++++++-
 drivers/irqchip/irq-gic-v2m.c                 |   2 +-
 drivers/irqchip/irq-gic-v3-its-pci-msi.c      |   2 +-
 drivers/irqchip/irq-gic-v3-its-platform-msi.c |   2 +-
 drivers/irqchip/irq-gic-v3-its.c              |   6 +-
 drivers/irqchip/irq-gic-v3.c                  |  10 +-
 drivers/irqchip/irq-gic.c                     |   4 +-
 drivers/mailbox/pcc.c                         |   2 +-
 include/linux/acpi.h                          |   6 +-
 include/linux/node.h                          |  72 ++-
 25 files changed, 1487 insertions(+), 66 deletions(-)
 create mode 100644 Documentation/admin-guide/mm/numaperf.rst
 create mode 100644 drivers/acpi/hmat/Kconfig
 create mode 100644 drivers/acpi/hmat/Makefile
 create mode 100644 drivers/acpi/hmat/hmat.c

-- 
2.14.4

