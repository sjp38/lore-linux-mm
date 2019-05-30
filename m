Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31E94C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C950A262F1
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C950A262F1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20CD56B0007; Thu, 30 May 2019 19:13:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 196DB6B0269; Thu, 30 May 2019 19:13:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 085EF6B0281; Thu, 30 May 2019 19:13:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C42E26B0007
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:13:12 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e6so3326192pgl.1
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:13:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=IaOxP7M2gWWOrHtZ6tbmNAEg4Iavg4mp95VPv2Pvelo=;
        b=PI1+EVCqhV2M+28bjUkdmaqI9TtPiswSpsCfMCx5iKTNlcyRd3zXAK1Zk+3VnSHOBw
         Lcig15kCSxPXyrssXCeMAkMcPNFCcWgiCgiF7g2BU6cBN6UdQ2P9ho5eUqA9FqyOdDKq
         XsI8n8eoYkoBn5tVwO76cesXlairC6i+pqliI48hpK5EKsfNa798tWo+0Uk4o1BjY7iH
         T5RClovnRYphUvClnRVcOv2r+Vv/NW0Yh065kYI+6RiG+oT29agSYSrpw2F+WSZv6BF6
         1YHtKJ0jop5j37UhiCpnRso1iunny3jQAv34L5phZ29zQBJPRUNz1aTIrB+jPpB1CKMM
         EwEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVpS3rmk4iNjv5WKt/RE9DIbgKbm4CWjPzD2to28XYEjV788J04
	WsJmyl/0Mu8IuXIKtdq2Iw787//79zrpe2jAiCjhrgoJ94jQeYi1mMGqHwdVlo8kHLlE0L1iBDi
	Fws/lo+zE33K+XNSKVu4YpxPSDX1sRfOiGxKt7sA+ycjLBvDZkyO5pGUn74yacO6nbQ==
X-Received: by 2002:a62:8c97:: with SMTP id m145mr6222914pfd.62.1559257992371;
        Thu, 30 May 2019 16:13:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDLFQC/H4XdBKxkTMbTJjtDq+iyU/Z/wblY1tSRwmfg3N4v8USBOpUBkM/2xXXy+FessKR
X-Received: by 2002:a62:8c97:: with SMTP id m145mr6222837pfd.62.1559257991341;
        Thu, 30 May 2019 16:13:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559257991; cv=none;
        d=google.com; s=arc-20160816;
        b=BdONLtVOcftd/P+sK+Y8IKReFUY+0MHXbkcSWDLwdktj8372fGGl3IpZJPaBo6v/mU
         KDotyMBBTDxEM7GQ0mJkQnUbpVIz90OIYZ+cg0ArHKmkniCe/jJWzL4das6XdaoKAT0H
         MGu1Z0KR8J6BqPrveX3KB0wI1AeyPeW/Wn1dPaMQM3ICc2QEAGixECClx85U7W5Cc0Oq
         po5EuepZlvufYNjI0vV0dn+VwjfgcV89Spg8M4l/ZiEUzQqljb2DYZGItguTRt8RdhX8
         sV4IywaJmC891AdbtKnLITOjdvGsOW67QH77tGyi3qh6VniJfA3jFmZrLJ4GPp6L1TnQ
         B1AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=IaOxP7M2gWWOrHtZ6tbmNAEg4Iavg4mp95VPv2Pvelo=;
        b=LZovB7+YBMJ3vZtIf6H+nfq5aGGlp7hZXE443NQ2/QGYr2heB9PcqpXbf8gM5qwHuI
         gXHl+QwIC8YcqJiZpU8Yo+45vRLQZjHVC/BDkTljqqYhDekTTkpmHVV3pc3CvqWEUUwe
         OSZnsX8k2LMfb8jAzcN1vsIHFjp/426oEkLhCVhamXSnK1Wq+huWXzp1Q4fJ+33P1k2F
         79VR28UDva7I5NxIb+aut2UZTaJvq9Y5v91IMWxQCZxZcoZm94ckEZgBUBr6L6icyuuQ
         I2HwhQqlMs4LBYgxJ8mbfiP64RXwSsBupa09wNh1eapOs88xH67fIuj5B6Srvkbdz+/3
         kUgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o188si4155684pgo.489.2019.05.30.16.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:13:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 16:13:10 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga001.jf.intel.com with ESMTP; 30 May 2019 16:13:10 -0700
Subject: [PATCH v2 0/8] EFI Specific Purpose Memory Support
From: Dan Williams <dan.j.williams@intel.com>
To: linux-efi@vger.kernel.org
Cc: Dave Jiang <dave.jiang@intel.com>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>,
 Keith Busch <keith.busch@intel.com>, Andy Shevchenko <andy@infradead.org>,
 Borislav Petkov <bp@alien8.de>, Vishal Verma <vishal.l.verma@intel.com>,
 "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
 Thomas Gleixner <tglx@linutronix.de>, kbuild test robot <lkp@intel.com>,
 Ingo Molnar <mingo@redhat.com>, Len Brown <lenb@kernel.org>,
 Matthew Wilcox <willy@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Darren Hart <dvhart@infradead.org>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org,
 linux-nvdimm@lists.01.org
Date: Thu, 30 May 2019 15:59:22 -0700
Message-ID: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since the initial RFC [1]
* Split the generic detection of the attribute from any policy /
  mechanism that leverages the EFI_MEMORY_SP designation (Ard).

* Various cleanups to the lib/memregion implementation (Willy)

* Rebase on v5.2-rc2

* Several fixes resulting from testing with efi_fake_mem and the
  work-in-progress patches that add HMAT support to qemu. Details in
  patch3 and patch8.

[1]: https://lore.kernel.org/lkml/155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com/

---

The EFI 2.8 Specification [2] introduces the EFI_MEMORY_SP ("specific
purpose") memory attribute. This attribute bit replaces the deprecated
ACPI HMAT "reservation hint" that was introduced in ACPI 6.2 and removed
in ACPI 6.3.

Given the increasing diversity of memory types that might be advertised
to the operating system, there is a need for platform firmware to hint
which memory ranges are free for the OS to use as general purpose memory
and which ranges are intended for application specific usage. For
example, an application with prior knowledge of the platform may expect
to be able to exclusively allocate a precious / limited pool of high
bandwidth memory. Alternatively, for the general purpose case, the
operating system may want to make the memory available on a best effort
basis as a unique numa-node with performance properties by the new
CONFIG_HMEM_REPORTING [3] facility.

In support of optionally allowing either application-exclusive and
core-kernel-mm managed access to differentiated memory, claim
EFI_MEMORY_SP ranges for exposure as device-dax instances by default.
Such instances can be directly owned / mapped by a
platform-topology-aware application. Alternatively, with the new kmem
facility [4], the administrator has the option to instead designate that
those memory ranges be hot-added to the core-kernel-mm as a unique
memory numa-node. In short, allow for the decision about what software
agent manages specific-purpose memory to be made at runtime.

The patches are based on the new HMAT+HMEM_REPORTING facilities merged
for v5.2-rc1. The implementation is tested with qemu emulation of HMAT
[5] plus the efi_fake_mem facility for applying the EFI_MEMORY_SP
attribute.

[2]: https://uefi.org/sites/default/files/resources/UEFI_Spec_2_8_final.pdf
[3]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e1cf33aafb84
[4]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308f
[5]: http://patchwork.ozlabs.org/cover/1096737/

---

Dan Williams (8):
      acpi: Drop drivers/acpi/hmat/ directory
      acpi/hmat: Skip publishing target info for nodes with no online memory
      efi: Enumerate EFI_MEMORY_SP
      x86, efi: Reserve UEFI 2.8 Specific Purpose Memory for dax
      lib/memregion: Uplevel the pmem "region" ida to a global allocator
      device-dax: Add a driver for "hmem" devices
      acpi/hmat: Register HMAT at device_initcall level
      acpi/hmat: Register "specific purpose" memory as an "hmem" device


 arch/x86/Kconfig                  |   20 +++++
 arch/x86/boot/compressed/eboot.c  |    5 +
 arch/x86/boot/compressed/kaslr.c  |    2
 arch/x86/include/asm/e820/types.h |    9 ++
 arch/x86/kernel/e820.c            |    9 ++
 arch/x86/kernel/setup.c           |    1
 arch/x86/platform/efi/efi.c       |   37 ++++++++-
 drivers/acpi/Kconfig              |   13 +++
 drivers/acpi/Makefile             |    2
 drivers/acpi/hmat.c               |  149 +++++++++++++++++++++++++++++++++----
 drivers/acpi/hmat/Kconfig         |   11 ---
 drivers/acpi/hmat/Makefile        |    2
 drivers/acpi/numa.c               |   15 +++-
 drivers/dax/Kconfig               |   27 +++++--
 drivers/dax/Makefile              |    2
 drivers/dax/hmem.c                |   58 ++++++++++++++
 drivers/firmware/efi/efi.c        |    5 +
 drivers/nvdimm/Kconfig            |    1
 drivers/nvdimm/core.c             |    1
 drivers/nvdimm/nd-core.h          |    1
 drivers/nvdimm/region_devs.c      |   13 +--
 include/linux/efi.h               |   15 ++++
 include/linux/ioport.h            |    1
 include/linux/memblock.h          |    7 ++
 include/linux/memregion.h         |   11 +++
 lib/Kconfig                       |    7 ++
 lib/Makefile                      |    1
 lib/memregion.c                   |   15 ++++
 mm/memblock.c                     |    4 +
 29 files changed, 387 insertions(+), 57 deletions(-)
 rename drivers/acpi/{hmat/hmat.c => hmat.c} (81%)
 delete mode 100644 drivers/acpi/hmat/Kconfig
 delete mode 100644 drivers/acpi/hmat/Makefile
 create mode 100644 drivers/dax/hmem.c
 create mode 100644 include/linux/memregion.h
 create mode 100644 lib/memregion.c

