Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45797C4321B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC6F9208C2
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P8lkxgGj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC6F9208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 776846B0003; Sat, 27 Apr 2019 02:43:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 723796B0005; Sat, 27 Apr 2019 02:43:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C7596B0006; Sat, 27 Apr 2019 02:43:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFD66B0003
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:05 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n10so2347444pgg.11
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=eB6k5meLI0PLOK3mYE/JAtGJf13kBE3594LdTnKJT/c=;
        b=fNGyf2KnXiAHnsSfBriojuirWppwLABAsZnO50C9/McP43ZDs/Oc08NpDbRXzKhwWm
         0VHXiT3ISyt7phI0Awl7iPnbtnHgHi5lJnUa5OBWv35XfdZN4il5vSttnjNj2T6e0tqm
         gSBBp+OcDCbTB1TvMe/fVsmEQtpRl74hAyTTyVddS48vpnDgSxKFES/NiPI+26xYTDBH
         pPnJYQfHskTguGKTz6N4dTqy399CYG2ytLRXbb5D04dA6w+ndILSvjwExuCq1I+Y+o9+
         3EXJ0QalPR1DfC7VdC6dW4eRHUJmKDH2CbAyxaaW4PVPnKkHSK0o3kUrW+eeHmrSehyX
         OLZw==
X-Gm-Message-State: APjAAAV3vOCRPds/ptUT0VQj0OnccyHDuaJoVvZ+I3lYS3LT7joXpfeZ
	EHnBak90W7RNNkVOWqGBM2kIF0/NJB7jVcMxtTHfn9dfAi2atQfcYmq1KgISxLmVqbC+WMPDmoM
	piR/ul4bbgWAgGcCzEGv+u70M6lxMHiI6Bop4hVgDkwr1qvzdoOnHGlbxXJprpN1KaA==
X-Received: by 2002:a65:6656:: with SMTP id z22mr30235358pgv.333.1556347384591;
        Fri, 26 Apr 2019 23:43:04 -0700 (PDT)
X-Received: by 2002:a65:6656:: with SMTP id z22mr30235309pgv.333.1556347383549;
        Fri, 26 Apr 2019 23:43:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347383; cv=none;
        d=google.com; s=arc-20160816;
        b=qac0ZkUetbDel8Bb22rAJErFz9cnHFic1a6E+I8LBClVcLUOK8+ooQUIDEXpUoCng7
         XAxv730WIpDHrg4WGPSkE/qnZ/Npq/jRwyyljiEpbcg3K8PhtEZWhKC75XcU4cCD01Ay
         K8dkTfM4DwpCYdpTGwAsH45iCn0RW1nnldH2pk0XzQ4yhWWQ5GQrRhwHP7ZF/Z24mcma
         JZUAqAjNLo+8GyvwfrxxVZv/xnf8cY4ndM+R6/BPWu0CFDSM2J1DeNMCkMo39iZmH6Vp
         8yi9qmvhW3jtpVVmmdy4I2aUAvi/XYnDVBwWLquZ8RO8ZY49iQG6tZrbfKGXZKXu/z6k
         8UJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=eB6k5meLI0PLOK3mYE/JAtGJf13kBE3594LdTnKJT/c=;
        b=G4GG/LKU8he+ZU10W9jDdEP4sX/phxSr62skvt/RSWqiWV2q97Oc+KCs8V5yxqXZmF
         l5rWa5/cgGbkASOniFkU9Q1ucfWR8hpVaHygvmQJpZbQQo7M8z5oLC7IXpAA1F+ZGMKM
         J7rNvj5zQ+wvxgOAmUc5+ZkSvAGBZ0d25bECFlqxlCqrksDWyYsUxY0J3xRa8GI1jTpk
         mzqQxmmx0ER4ROm/SMU/pG0nYZfpWsq0k9Il9ngWYior78upbUL3pr7LAYM+NGiUSxLP
         MPhyWcRfjEk7MmcMncWYZlQxpl7cwSkD2BqJGIPoH4FbFbC6Qic0Wd56wOtiZwprIy19
         Ni4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P8lkxgGj;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor2804598pgh.79.2019.04.26.23.43.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P8lkxgGj;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=eB6k5meLI0PLOK3mYE/JAtGJf13kBE3594LdTnKJT/c=;
        b=P8lkxgGjxqraib3dGi6LmdBMJFStrMGH5f7zRkLtPm0LyLdsCOatl1WplqSO6Vox5O
         QgceEyMkcGUHaPWov9uf5imUGYag+m6YfoDuve+tQrWc9Lnzck+ild+pJLBgqvAg+s4t
         tc2ZnLBudjA7+23D9apTsU8/5POeUm+9GGrBRc4Ff/HdRlJm0u0gfx3vlhknVKnRGfnO
         EiWhEn2/3fkfvOg0UEWNN2QVFDU+EZVBysGn0ITmKf0LFOg1DzCFALBMm4mesHSuLeC+
         J6TfDcCHfeBFtjn2od2kGVTzYa6WawY6jvV0lo/aa6bLxoGhvPKYoxlpD6UDLrUUf+Hb
         t5Qg==
X-Google-Smtp-Source: APXvYqyb+o0qcII6hqlSl8V9sdm+gHB13Znu6WUBjFKn+pUN45+xAXNqkdkIsB0zzQNru3DiagNjEA==
X-Received: by 2002:a65:430a:: with SMTP id j10mr48510698pgq.143.1556347382897;
        Fri, 26 Apr 2019 23:43:02 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:01 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 00/24] x86: text_poke() fixes and executable lockdowns
Date: Fri, 26 Apr 2019 16:22:39 -0700
Message-Id: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

*
* This version fixes failed boots on 32-bit that were reported by 0day.
* Patch 5 is added to initialize uprobes during fork initialization.
* Patch 7 (which was 6 in the previous version) is updated - the code is
* moved to common mm-init code with no further changes.
*

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

Changes v5 to v6:
- Move poking_mm initialization to common x86 mm init [0day]
- Initialize uprobes during fork initialization [0day]

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

Nadav Amit (16):
  Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
  x86/jump_label: Use text_poke_early() during early init
  x86/mm: Save debug registers when loading a temporary mm
  uprobes: Initialize uprobes earlier
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
 arch/x86/mm/init.c                   |  37 +++++
 arch/x86/mm/pageattr.c               |  16 ++-
 arch/x86/xen/mmu_pv.c                |   2 -
 include/asm-generic/tlb.h            |   9 ++
 include/linux/filter.h               |  18 +--
 include/linux/mm.h                   |  18 +--
 include/linux/sched/task.h           |   1 +
 include/linux/set_memory.h           |  11 ++
 include/linux/uprobes.h              |   5 +
 include/linux/vmalloc.h              |  15 ++
 init/main.c                          |   3 +
 kernel/bpf/core.c                    |   1 -
 kernel/events/uprobes.c              |   8 +-
 kernel/fork.c                        |  25 +++-
 kernel/module.c                      |  82 ++++++-----
 kernel/power/snapshot.c              |   5 +-
 kernel/trace/bpf_trace.c             |   8 ++
 mm/page_alloc.c                      |   7 +-
 mm/vmalloc.c                         | 113 ++++++++++++---
 33 files changed, 552 insertions(+), 200 deletions(-)

-- 
2.17.1

