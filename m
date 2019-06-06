Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68695C28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0934A2146E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0934A2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 896796B02AD; Thu,  6 Jun 2019 16:17:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 846D06B02C1; Thu,  6 Jun 2019 16:17:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70E126B02C3; Thu,  6 Jun 2019 16:17:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 340256B02AD
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so2616244pfj.4
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=zYlPKLe1to4GruJbhRGlPHN09HJAMjYONwWbbVDe+So=;
        b=QV6358mbx5LHWZqyWSUYEHja74Z9qURZ5gwVNEvABcVoRYnlvP4RnPbSEkJB15VT/D
         303N4p2gd2MsRJvtxwW/0sIpHukCIHHNf7thhNM7HHRXR9h57iNsRJgsra1C/hGzy92O
         1KiYoTd54AF9np2qsvE6/z9fHq7ZrCVmEZERE1Xn31Iy1w8RvODpORwvM+nHRJX5/l9A
         irRmpvi2uiv+OAZt5ZkisOAxFf9dA+bg2N9I/fz4MKXbDfsUcGNVou9spFvb85q1hyyz
         cAjHO5fMZuwa4qQ7kb7Wji0PTqp51eRibDwHH/vwkU5d5BRWkfEdEDurwuLj+TjWUfjT
         gCQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUNduDn8bq57X+TYemOaIt5I1qM1FL1pc6PI221UvLAL5lhulZw
	pHmhbMnL8XDC0k0A6gizrAvlCxj/ePR7A3sabtmhp2vZoVJRkQHlfmETkwzU+k/e0D2rXBF+Axp
	WCxqrg+mv19zByxZ6bh+TP1oEFWZGtm9FfMwAxt31+RGictz2AkAIwW+sOIccSSep9w==
X-Received: by 2002:a17:90a:8902:: with SMTP id u2mr1638166pjn.96.1559852251856;
        Thu, 06 Jun 2019 13:17:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCnJnnnvdm6NKj0YT5c8nS8M0y5aFVTD8JtDXqQcXT22sdyvzPTwnjk84LuqYqnup7C3+Y
X-Received: by 2002:a17:90a:8902:: with SMTP id u2mr1638108pjn.96.1559852251068;
        Thu, 06 Jun 2019 13:17:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852251; cv=none;
        d=google.com; s=arc-20160816;
        b=wvgbUZJe7dJm2eyuBAsmWW65XYR0/fYdNSP6DsiMvn6R/s4HwMYjDxx08kpbod5gB7
         zfy0Lyvadh84Q9SnIF7QB1uj9HHQNVqaIdVTMujS2Y0ru8e3zw6rJ5RZemM24CXIlju4
         RWJfooRLNfylJZoeSqzNyaZ3lZwl7De/yg+Hvsba9ezN4BvTF2kTB7k2Jj8AMafFyFtU
         pvpWBqn1axEng07B1IBTw+a+YP2BzqHCGbbxHOga8pGul9nghK4YMThTo0S6Uu+OOw+v
         ZBkdjbC0P4mE/2oJNNuyiDk29ZOVcRGLf+iUN40+oXnNEb1sZPRRViL61wDQEuw0c+Er
         SU6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=zYlPKLe1to4GruJbhRGlPHN09HJAMjYONwWbbVDe+So=;
        b=vv0J05MYHU++TzYyuoNTbrPy9jcYXMMVVP7hYLRxNx0XFYP2NMDxnfjW+rJjDrL4AL
         HYweFVNVoUX0+4QLj/7w1kJUEE1TdwLGTQzAg8aaJntjUBBQTMdpWecvkVkzmYpRGFC2
         RJo/5wfAE5MqiRfMFOauAmujp/bq2TmxP4QrdHvnGxIg4PSBUe+9Fh3W+yQA0Uk3R7O6
         /aG7VV1agMAuIOY8jXYZXuhaMUDzGYWEx4GWlKXqJkpuOImH+QkZiGWmtqGDV+7+01ZQ
         ekHr5bFG39KGFfWuc4YvgiKzym1GrHqha8se9umjGhtnVzbYZqIsfIRkhfwEjEY3Z7Ly
         PTeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t11si66755plr.23.2019.06.06.13.17.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:17:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:30 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga001.fm.intel.com with ESMTP; 06 Jun 2019 13:17:29 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 00/14] Control-flow Enforcement: Branch Tracking, PTRACE
Date: Thu,  6 Jun 2019 13:09:12 -0700
Message-Id: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The previous version of CET Branch Tracking/PTRACE patches is here:

  https://lkml.org/lkml/2018/11/20/203

Summary of changes from v6:

  Rebase to v5.2-rc3.

  Add Branch Tracking in the signal handling routines.

  Fix Branch Tracking (and Shadow Stack) for vsyscall (patch #12):
    This patch can be dropped if we expect CET blocking vsyscall.

  Include H.J. Lu's patch to discard .note.gnu.property in the kernel.

H.J. Lu (4):
  x86/vdso: Insert endbr32/endbr64 to vDSO
  x86/vdso/32: Add ENDBR32 to __kernel_vsyscall entry point
  x86/vsyscall/64: Add ENDBR64 to vsyscall entry points
  x86: Discard .note.gnu.property sections

Yu-cheng Yu (10):
  x86/cet/ibt: Add Kconfig option for user-mode Indirect Branch Tracking
  x86/cet/ibt: User-mode indirect branch tracking support
  x86/cet/ibt: Add IBT legacy code bitmap setup function
  x86/cet/ibt: Handle signals for IBT
  mm/mmap: Add IBT bitmap size to address space limit check
  x86/cet/ibt: ELF header parsing for IBT
  x86/cet/ibt: Add arch_prctl functions for IBT
  x86/cet/ibt: Add ENDBR to op-code-map
  x86/vsyscall/64: Fixup shadow stack and branch tracking for vsyscall
  x86/cet: Add PTRACE interface for CET

 arch/x86/Kconfig                              | 16 ++++
 arch/x86/Makefile                             |  7 ++
 arch/x86/entry/vdso/Makefile                  | 12 ++-
 arch/x86/entry/vdso/vdso-layout.lds.S         |  1 +
 arch/x86/entry/vdso/vdso32/system_call.S      |  3 +
 arch/x86/entry/vsyscall/vsyscall_64.c         | 28 +++++++
 arch/x86/entry/vsyscall/vsyscall_emu_64.S     |  9 +++
 arch/x86/include/asm/cet.h                    |  8 ++
 arch/x86/include/asm/disabled-features.h      |  8 +-
 arch/x86/include/asm/fpu/regset.h             |  7 +-
 arch/x86/include/asm/mmu_context.h            | 10 +++
 arch/x86/include/uapi/asm/prctl.h             |  2 +
 arch/x86/kernel/cet.c                         | 80 +++++++++++++++++++
 arch/x86/kernel/cet_prctl.c                   | 21 +++++
 arch/x86/kernel/cpu/common.c                  | 17 ++++
 arch/x86/kernel/fpu/regset.c                  | 41 ++++++++++
 arch/x86/kernel/process_64.c                  |  6 ++
 arch/x86/kernel/ptrace.c                      | 16 ++++
 arch/x86/kernel/vmlinux.lds.S                 | 11 ++-
 arch/x86/lib/x86-opcode-map.txt               | 13 ++-
 include/uapi/linux/elf.h                      |  1 +
 mm/mmap.c                                     | 19 ++++-
 .../arch/x86/include/asm/disabled-features.h  |  8 +-
 tools/objtool/arch/x86/lib/x86-opcode-map.txt | 13 ++-
 24 files changed, 345 insertions(+), 12 deletions(-)

-- 
2.17.1

