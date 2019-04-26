Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2884DC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:31:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF6C2206E0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:31:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF6C2206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D5CF6B0006; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AFF56B0007; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 398936B000D; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DEDC56B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:47 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 63so1432104plf.19
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=oQvPegDLlhipgVtxW/7nHl/g55rrwjvZDrS+k+NNvio=;
        b=pMAl74ujW17fkuis1NdJj3MS/w/VfCC009KXzhXvj0lJM4DJ2ywGUKrjNNSqimyK7d
         LEx/FHkipGyFyvfHy03tI/+p9blYAMeOzg1AsiM39apg/MdlM3I92LGJ+SvPvJChPPV3
         qDBVbcfKwi0fnSDuS01tAfHriy/c52A+lJMWfJZfKL5aUmwYGIPjRiqeXSa0uI6ThYqA
         3SQW4vHAW0Q04TUWRAaF9cwiWn6VFR3X7r5oqdqnPpPKlRbmqmH0rFuKxPFS6/XSr7lG
         8vYb4Chor8LWi737Vp8PgJOsv8GI/jnlBRbVkisWcSurKBgv9KW/K90uuzwjGKrl1vu2
         gQ+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAW9GYxvhFFU8J6SwIHPxN2VkGMHixoDz1EICmaXukiKlqVmq9zR
	oyMd7zpo7EPAqhvCtAkv/Y/H4Vfuee87ktmgFB/X6hXQ+Qadh66MDkkArEKaKWvj0/7cH0ApOgQ
	WodLWyoyXJ0CgZKz/hRNDsLrO3+s/TGAE5TbYovUHgQwxzcFszrJ8TxLCWcu0YX1ldw==
X-Received: by 2002:a63:170d:: with SMTP id x13mr41703807pgl.169.1556263907523;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypO5VR5Ftb1e1QgY8gaeIdFgc6mLtDCXGP5wTQ98wFIizOR99ypIQnwziMByE0catZw4y+
X-Received: by 2002:a63:170d:: with SMTP id x13mr41703724pgl.169.1556263906418;
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263906; cv=none;
        d=google.com; s=arc-20160816;
        b=xFB4N3j6K4YkOVxfLPA+3sbYlniHkDgBQTXeJ/beJ6kuDLbhUmRj/+I8B5tSjDy6IJ
         MlD/BxXQCy3n3/PcEGxSSHOZQAXqbWXi5fzWyurATYUd7HL3Cy6eV4dKpy3OQ++YowDB
         dXVudLcorIoon44Ngk57/QM1C6PE3gW2KfwyP/ZSPKqstakE4QenS4ubkcRFX3tjCWpE
         TPoznRmt+bcwCns5+5cUoiSJn9UKvdRtLeBUnfoZ3I10AVjy9unBLtKlETHpwHw15QUh
         nH9GNo+4NdeOHBsTHMwXObUcz+qF8XV3X9HGLJ0FC/t4QT54wZcdpm5n8XZeBGiyhilN
         3sSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=oQvPegDLlhipgVtxW/7nHl/g55rrwjvZDrS+k+NNvio=;
        b=o/9h6896RBgtAKs3GQQlXXVOSjEjd2u8qdmESZ9K3rneqIbFcVl405x0T1/EhJSnwr
         mrxFlmQZcpx5EXmtqhxJAAuT9ZdQk1wcBUfgKFAweoyK1h94DsJIMiB6MTNOOVLG0iss
         cuPfu18AfnqhBEkzYIYblgg36EVHzxZb8BNcvFEKo6W3uT6Dq2uSMZgmgJOzILI2WLiU
         hYDB53ygzeMvl5JV3c4vt5i0V0B13Eyhw+ROmetJaOYnVjREJnK8CwnMm5EvRTZInhUG
         2Cq5aEovG6TJPXVetJcs9dnzMjVkOLTR8e4p1PzRdjJzn39bTkbj1/831vLZerTdD4QA
         PB3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id v82si25417769pfa.42.2019.04.26.00.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:40 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 593CC41298;
	Fri, 26 Apr 2019 00:31:45 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <x86@kernel.org>, <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, <linux_dti@icloud.com>,
	<linux-integrity@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<akpm@linux-foundation.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, <will.deacon@arm.com>, <ard.biesheuvel@linaro.org>,
	<kristen@linux.intel.com>, <deneen.t.dock@intel.com>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v5 00/23] x86: text_poke() fixes and executable lockdowns
Date: Thu, 25 Apr 2019 17:11:20 -0700
Message-ID: <20190426001143.4983-1-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yet another version, per PeterZ request, addressing the latest feedback.

This patchset improves several overlapping issues around stale TLB
entries and W^X violations. It is combined from "x86/alternative:
text_poke() enhancements v7" [1] and "Don't leave executable TLB entries
to freed pages v2" [2] patchsets that were conflicting.

The related issues that this fixes:
1. Fixmap PTEs that are used for patching are available for access from
  other cores and might be exploited. They are not even flushed from
  the TLB in remote cores, so the risk is even higher. Address this
  issue by introducing a temporary mm that is only used during
  patching. Unfortunately, due to init ordering, fixmap is still used
  during boot-time patching. Future patches can eliminate the need for
  it.
2. Missing lockdep assertion to ensure text_mutex is taken. It is
  actually not always taken, so fix the instances that were found not
  to take the lock (although they should be safe even without taking
  the lock).
3. Module_alloc returning memory that is RWX until a module is finished
  loading.
4. Sometimes when memory is freed via the module subsystem, an
  executable permissioned TLB entry can remain to a freed page. If the
  page is re-used to back an address that will receive data from
  userspace, it can result in user data being mapped as executable in
  the kernel. The root of this behavior is vfree lazily flushing the
  TLB, but not lazily freeing the underlying pages.


Changes v4 to v5:
- Change temporary state variable name [Borislav]
- Commit log and comment fixes [Borislav]

Changes v3 to v4:
- Remove the size parameter from tramp_free() [Steven]
- Remove caching of hw_breakpoint_active() [Sean]
- Prevent the use of bpf_probe_write_user() while using temporary mm [Jann]
- Fix build issues on other archs

Changes v2 to v3:
- Fix commit messages and comments [Boris]
- Rename VM_HAS_SPECIAL_PERMS [Boris]
- Remove unnecessary local variables [Boris]
- Rename set_alias_*() functions [Boris, Andy]
- Save/restore DR registers when using temporary mm
- Move line deletion from patch 10 to patch 17

Changes v1 to v2:
- Adding "Reviewed-by tag" [Masami]
- Comment instead of code to warn against module removal while
  patching [Masami]
- Avoiding open-coded TLB flush [Andy]
- Remove "This patch" [Borislav Petkov]
- Not set global bit during text poking [Andy, hpa]
- Add Ack from [Pavel Machek]
- Split patch 16 "Plug in new special vfree flag" into 4 patches (16-19)
  to make it easier to review. There were no code changes.

The changes from "Don't leave executable TLB entries to freed pages
v2" to v1:
- Add support for case of hibernate trying to save an unmapped page
  on the directmap. (Ard Biesheuvel)
- No week arch breakout for vfree-ing special memory (Andy Lutomirski)
- Avoid changing deferred free code by moving modules init free to work
  queue (Andy Lutomirski)
- Plug in new flag for kprobes and ftrace
- More arch generic names for set_pages functions (Ard Biesheuvel)
- Fix for TLB not always flushing the directmap (Nadav Amit)

Changes from "x86/alternative: text_poke() enhancements v7" to v1
- Fix build failure on CONFIG_RANDOMIZE_BASE=n (Rick)
- Remove text_poke usage from ftrace (Nadav)

[1] https://lkml.org/lkml/2018/12/5/200
[2] https://lkml.org/lkml/2018/12/11/1571


Andy Lutomirski (1):
  x86/mm: Introduce temporary mm structs

Nadav Amit (15):
  Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
  x86/jump_label: Use text_poke_early() during early init
  x86/mm: Save debug registers when loading a temporary mm
  fork: Provide a function for copying init_mm
  x86/alternative: Initialize temporary mm for patching
  x86/alternative: Use temporary mm for text poking
  x86/kgdb: Avoid redundant comparison of patched code
  x86/ftrace: Set trampoline pages as executable
  x86/kprobes: Set instruction page as executable
  x86/module: Avoid breaking W^X while loading modules
  x86/jump-label: Remove support for custom poker
  x86/alternative: Remove the return value of text_poke_*()
  x86/alternative: Comment about module removal races
  mm/tlb: Provide default nmi_uaccess_okay()
  bpf: Fail bpf_probe_write_user() while mm is switched

Rick Edgecombe (7):
  x86/mm/cpa: Add set_direct_map_ functions
  mm: Make hibernate handle unmapped pages
  vmalloc: Add flag for free of special permsissions
  modules: Use vmalloc special flag
  bpf: Use vmalloc special flag
  x86/ftrace: Use vmalloc special flag
  x86/kprobes: Use vmalloc special flag

 arch/Kconfig                         |   4 +
 arch/x86/Kconfig                     |   1 +
 arch/x86/include/asm/fixmap.h        |   2 -
 arch/x86/include/asm/mmu_context.h   |  56 ++++++++
 arch/x86/include/asm/pgtable.h       |   3 +
 arch/x86/include/asm/set_memory.h    |   3 +
 arch/x86/include/asm/text-patching.h |   7 +-
 arch/x86/include/asm/tlbflush.h      |   2 +
 arch/x86/kernel/alternative.c        | 201 ++++++++++++++++++++-------
 arch/x86/kernel/ftrace.c             |  22 +--
 arch/x86/kernel/jump_label.c         |  21 ++-
 arch/x86/kernel/kgdb.c               |  25 +---
 arch/x86/kernel/kprobes/core.c       |  19 ++-
 arch/x86/kernel/module.c             |   2 +-
 arch/x86/mm/init_64.c                |  36 +++++
 arch/x86/mm/pageattr.c               |  16 ++-
 arch/x86/xen/mmu_pv.c                |   2 -
 include/asm-generic/tlb.h            |   9 ++
 include/linux/filter.h               |  18 +--
 include/linux/mm.h                   |  18 +--
 include/linux/sched/task.h           |   1 +
 include/linux/set_memory.h           |  11 ++
 include/linux/vmalloc.h              |  15 ++
 init/main.c                          |   3 +
 kernel/bpf/core.c                    |   1 -
 kernel/fork.c                        |  24 +++-
 kernel/module.c                      |  82 ++++++-----
 kernel/power/snapshot.c              |   5 +-
 kernel/trace/bpf_trace.c             |   8 ++
 mm/page_alloc.c                      |   7 +-
 mm/vmalloc.c                         | 113 ++++++++++++---
 31 files changed, 542 insertions(+), 195 deletions(-)

-- 
2.17.1

