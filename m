Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C87F6C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85B84218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85B84218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B11C88E000B; Wed, 26 Dec 2018 08:37:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29C478E0006; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CA868E0006; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4060C8E0011
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so15212800pgt.11
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc
         :subject;
        bh=Mw9KZQ4orLVUVMOyOnjvBYlMWV4ZhCODP6p3UHosjp4=;
        b=mleKbkC4d+uZSLKqvqZ3N36dbxVZ+TXF7aoktwpXPjmxlmIbcFQ0Ejh+1YkwoGZh0Z
         4hf5MeO7I4GbGDafbgpRcdLUWkXIOaZnath0xnv83z4QfGvDAFdoIGFaq3h5cK6BVTiW
         qsrykUhydZc+OHkJocdO1MqezvyIdyfsennvVWXc36+E57MeDAHGtGSolvqndf4wNssG
         ONqyqAGWjmjeOAKj6OwPutrZg8BQiZt2DvvBZ6VTPogbp0i2gNi2u9Ax8uYhMEaLDyFN
         fVjiP6oj9kHRgiLMZvEedituD+j8LFoWlNTao9haD4b941n3PdlxJSRd2cndJvzuY3Xw
         hu1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcGAAHVcySh60J1QUadV5HaP1eknyH9AnkmARdaIAvQYUATQoVo
	OMSoqv+uvEwrcQyCKge5cyjI5DLhkyNqPmUVQIo8erhnavX0jBOeYk+P6MdkZKwwHcpxR8gmdiY
	yV7IK6Qg8D4euhKlz7jvcrKMGwcIt87lisicUWTsFW/h1Yosuvr8oyvm9AXL2neowaQ==
X-Received: by 2002:a17:902:64c1:: with SMTP id y1mr19650784pli.64.1545831427930;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4l5tWFl0aBQvBzGKPmrlbdtgrOR/rA6ZTDLdsI9588i8TqJxiIbbU2AF+jllhBwdcvGM1s
X-Received: by 2002:a17:902:64c1:: with SMTP id y1mr19650742pli.64.1545831427072;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831427; cv=none;
        d=google.com; s=arc-20160816;
        b=VQHNVIvWISEWSwUdlEibvrM/Z5MPWLRoCO4Vs4DTl/40M8ZPHYyDaKMp4k9hehLEo8
         WByTfRboBMk0RKSsNKM4eOoWWivxBZWwpFrdOdNsmIp9+MdRCB12p15FfX3tOoA153Pi
         2T5qtAavTS9yh4T97+jD+OrQoyhmq9AuDG+og3ZoDM861vn71yl8luLNkL9Hh3yuQhVl
         QyK4CT/s1/e1mmkYxIacCjVxTgipQKOW3wND3ZtVW15DU4WB5tmSJ4e3oOieNEqYD0ht
         FBc26keei4xnZzF+gs7yWNMvegKzVwfPk/SaUrE+p43r7dft4YHCDB7dLV11K0LLL8B0
         D4Wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:to:from:date
         :user-agent:message-id;
        bh=Mw9KZQ4orLVUVMOyOnjvBYlMWV4ZhCODP6p3UHosjp4=;
        b=ZPoH4K73bco6rHrkUEa4tE9lADJCtTF+lso/N4xYYRISYiEwNSKapYUJ8xIf3X0Zr2
         jI78C7IkDx7JFbsW63a2VYmh/VS1owdlRPTx1huhEbRVmuykAj/pG+QnWV4bmgDlPcm/
         T9Q6bjZ7zdWs4eNZU/kyzsjgkCrTchK7Gqkzuqk/lUxETScY/jQ1VdlK0X2R7Ktqjs+H
         PuT8IN/fmmaCGBFLDx4bHqk7DEy0N+JZpPOXTNozds791pYObJTzLGl7OvMQiGdu9bqe
         2khJkH2KcKd6PRstrWP5+s4npROLWeku1sqNt5tvu7USXti2Py0mNUMEmbKY4lPUvhcD
         JIkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p11si31508288plk.191.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="113358939"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:01 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005Ns-5X; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226131446.330864849@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:46 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Fan Du <fan.du@intel.com>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
cc: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness accounting/migration
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20181226131446.NT67mnFig3zoMmDvba2K5tCZ5IeQl3rfDCvFmg00inA@z>

This is an attempt to use NVDIMM/PMEM as volatile NUMA memory that's
transparent to normal applications and virtual machines.

The code is still in active development. It's provided for early design review.

Key functionalities:

1) create and describe PMEM NUMA node for NVDIMM memory
2) dumb /proc/PID/idle_pages interface, for user space driven hot page accounting
3) passive kernel cold page migration in page reclaim path
4) improved move_pages() for active user space hot/cold page migration

(1) is foundation for transparent usage of NVDIMM for normal apps and virtual
machines. (2-4) enable auto placing hot pages in DRAM for better performance.
A user space migration daemon is being built based on this kernel patchset to
make the full vertical solution.

Base kernel is v4.20 . The patches are not suitable for upstreaming in near
future -- some are quick hacks, some others need more works. However they are
complete enough to demo the necessary kernel changes for the proposed app&VM
transparent NVDIMM volatile use model.

The interfaces are far from finalized. They kind of illustrate what would be
necessary for creating a user space driven solution. The exact forms will ask
for more thoughts and inputs. We may adopt HMAT based solution for NUMA node
related interface when they are ready. The /proc/PID/idle_pages interface is
standalone but non-trivial. Before upstreaming some day, it's expected to take
long time to collect various real use cases and feedbacks, so as to refine and
stabilize the format.

Create PMEM numa node

	[PATCH 01/21] e820: cheat PMEM as DRAM

Mark numa node as DRAM/PMEM

	[PATCH 02/21] acpi/numa: memorize NUMA node type from SRAT table
	[PATCH 03/21] x86/numa_emulation: fix fake NUMA in uniform case
	[PATCH 04/21] x86/numa_emulation: pass numa node type to fake nodes
	[PATCH 05/21] mmzone: new pgdat flags for DRAM and PMEM
	[PATCH 06/21] x86,numa: update numa node type
	[PATCH 07/21] mm: export node type {pmem|dram} under /sys/bus/node

Point neighbor DRAM/PMEM to each other

	[PATCH 08/21] mm: introduce and export pgdat peer_node
	[PATCH 09/21] mm: avoid duplicate peer target node

Standalone zonelist for DRAM and PMEM nodes

	[PATCH 10/21] mm: build separate zonelist for PMEM and DRAM node

Keep page table pages in DRAM

	[PATCH 11/21] kvm: allocate page table pages from DRAM
	[PATCH 12/21] x86/pgtable: allocate page table pages from DRAM

/proc/PID/idle_pages interface for virtual machine and normal tasks

	[PATCH 13/21] x86/pgtable: dont check PMD accessed bit
	[PATCH 14/21] kvm: register in mm_struct
	[PATCH 15/21] ept-idle: EPT walk for virtual machine
	[PATCH 16/21] mm-idle: mm_walk for normal task
	[PATCH 17/21] proc: introduce /proc/PID/idle_pages
	[PATCH 18/21] kvm-ept-idle: enable module

Mark hot pages

	[PATCH 19/21] mm/migrate.c: add move_pages(MPOL_MF_SW_YOUNG) flag

Kernel DRAM=>PMEM migration

	[PATCH 20/21] mm/vmscan.c: migrate anon DRAM pages to PMEM node
	[PATCH 21/21] mm/vmscan.c: shrink anon list if can migrate to PMEM

 arch/x86/include/asm/numa.h    |    2 
 arch/x86/include/asm/pgalloc.h |   10 
 arch/x86/include/asm/pgtable.h |    3 
 arch/x86/kernel/e820.c         |    3 
 arch/x86/kvm/Kconfig           |   11 
 arch/x86/kvm/Makefile          |    4 
 arch/x86/kvm/ept_idle.c        |  841 +++++++++++++++++++++++++++++++
 arch/x86/kvm/ept_idle.h        |  116 ++++
 arch/x86/kvm/mmu.c             |   12 
 arch/x86/mm/numa.c             |    3 
 arch/x86/mm/numa_emulation.c   |   30 +
 arch/x86/mm/pgtable.c          |   22 
 drivers/acpi/numa.c            |    5 
 drivers/base/node.c            |   21 
 fs/proc/base.c                 |    2 
 fs/proc/internal.h             |    1 
 fs/proc/task_mmu.c             |   54 +
 include/linux/mm_types.h       |   11 
 include/linux/mmzone.h         |   38 +
 mm/mempolicy.c                 |   14 
 mm/migrate.c                   |   13 
 mm/page_alloc.c                |   77 ++
 mm/pagewalk.c                  |    1 
 mm/vmscan.c                    |   38 +
 virt/kvm/kvm_main.c            |    3 
 25 files changed, 1306 insertions(+), 29 deletions(-)

V1 patches: https://lkml.org/lkml/2018/9/2/13

Regards,
Fengguang

