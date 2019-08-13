Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DB78C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:03:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 094B120842
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:03:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 094B120842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D3776B0006; Tue, 13 Aug 2019 17:03:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7831C6B0296; Tue, 13 Aug 2019 17:03:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D6D36B0297; Tue, 13 Aug 2019 17:03:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0077.hostedemail.com [216.40.44.77])
	by kanga.kvack.org (Postfix) with ESMTP id 328FF6B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:03:41 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CF5F02C34
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:03:40 +0000 (UTC)
X-FDA: 75818631000.30.fruit85_200ac0d4fd817
X-HE-Tag: fruit85_200ac0d4fd817
X-Filterd-Recvd-Size: 4856
Received: from mga06.intel.com (mga06.intel.com [134.134.136.31])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:03:39 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 14:03:38 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="194275959"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga001.fm.intel.com with ESMTP; 13 Aug 2019 14:03:38 -0700
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
Subject: [PATCH v8 00/14] Control-flow Enforcement: Branch Tracking, PTRACE
Date: Tue, 13 Aug 2019 13:53:45 -0700
Message-Id: <20190813205359.12196-1-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The previous version of CET Branch Tracking/PTRACE patches is here:

  https://lkml.org/lkml/2019/6/6/1030

Summary of changes from v7:

  Change legacy bitmap to a special mapping (patch #14).
  Rebase to v5.3-rc4.
  Small fixes in response to comments.

H.J. Lu (5):
  x86/cet/ibt: Add arch_prctl functions for IBT
  x86/vdso: Insert endbr32/endbr64 to vDSO
  x86/vdso/32: Add ENDBR32 to __kernel_vsyscall entry point
  x86/vsyscall/64: Add ENDBR64 to vsyscall entry points
  x86: Discard .note.gnu.property sections

Yu-cheng Yu (9):
  x86/cet/ibt: Add Kconfig option for user-mode Indirect Branch Tracking
  x86/cet/ibt: User-mode indirect branch tracking support
  x86/cet/ibt: Handle signals for end branch
  mm/mmap: Add IBT bitmap size to address space limit check
  x86/cet/ibt: ELF header parsing for IBT
  x86/cet/ibt: Add ENDBR to op-code-map
  x86/vsyscall/64: Fixup shadow stack and branch tracking for vsyscall
  x86/cet: Add PTRACE interface for CET
  Introduce arch_prctl(ARCH_X86_CET_MARK_LEGACY_CODE)

 arch/x86/Kconfig                              |  17 ++
 arch/x86/Makefile                             |   7 +
 arch/x86/entry/vdso/Makefile                  |  12 +-
 arch/x86/entry/vdso/vdso-layout.lds.S         |   1 +
 arch/x86/entry/vdso/vdso32/system_call.S      |   3 +
 arch/x86/entry/vsyscall/vsyscall_64.c         |  29 +++
 arch/x86/entry/vsyscall/vsyscall_emu_64.S     |   9 +
 arch/x86/entry/vsyscall/vsyscall_trace.h      |   1 +
 arch/x86/include/asm/cet.h                    |   9 +
 arch/x86/include/asm/disabled-features.h      |   8 +-
 arch/x86/include/asm/fpu/regset.h             |   7 +-
 arch/x86/include/asm/mmu_context.h            |  10 +
 arch/x86/include/asm/processor.h              |  13 +-
 arch/x86/include/uapi/asm/prctl.h             |   3 +
 arch/x86/kernel/Makefile                      |   2 +-
 arch/x86/kernel/cet.c                         |  54 +++++
 arch/x86/kernel/cet_bitmap.c                  | 210 ++++++++++++++++++
 arch/x86/kernel/cet_prctl.c                   |  19 ++
 arch/x86/kernel/cpu/common.c                  |  17 ++
 arch/x86/kernel/fpu/regset.c                  |  41 ++++
 arch/x86/kernel/process_64.c                  |   5 +
 arch/x86/kernel/ptrace.c                      |  16 ++
 arch/x86/kernel/vmlinux.lds.S                 |  10 +
 arch/x86/lib/x86-opcode-map.txt               |  13 +-
 include/uapi/linux/elf.h                      |   1 +
 mm/memory.c                                   |   8 +
 mm/mmap.c                                     |  19 +-
 .../arch/x86/include/asm/disabled-features.h  |   8 +-
 tools/objtool/arch/x86/lib/x86-opcode-map.txt |  13 +-
 29 files changed, 552 insertions(+), 13 deletions(-)
 create mode 100644 arch/x86/kernel/cet_bitmap.c

-- 
2.17.1


