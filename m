Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 243248E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 16:34:07 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id g92-v6so5808880ljg.23
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 13:34:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c82sor5419714lfg.7.2018.12.19.13.34.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 13:34:04 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [RFC v2 PATCH 0/12] hardening: statically allocated protected memory
Date: Wed, 19 Dec 2018 23:33:26 +0200
Message-Id: <20181219213338.26619-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Patch-set implementing write-rare memory protection for statically
allocated data.
Its purpose it to keep data write protected kernel data which is seldom
modified.
There is no read overhead, however writing requires special operations that
are probably unsitable for often-changing data.
The use is opt-in, by applying the modifier __wr_after_init to a variable
declaration.

As the name implies, the write protection kicks in only after init() is
completed; before that moment, the data is modifiable in the usual way.

Current Limitations:
* supports only data which is allocated statically, at build time.
* supports only x86_64, other earchitectures need to provide own backend

Some notes:
- there is a part of generic code which is basically a NOP, but should
  allow using unconditionally the write protection. It will automatically
  default to non-protected functionality, if the specific architecture
  doesn't support write-rare
- to avoid the risk of weakening __ro_after_init, __wr_after_init data is
  in a separate set of pages, and any invocation will confirm that the
  memory affected falls within this range.
  rodata_test is modified accordingly, to check also this case.
- for now, the patchset addresses only x86_64, as each architecture seems
  to have own way of dealing with user space. Once a few are implemented,
  it should be more obvious what code can be refactored as common.
- the memset_user() assembly function seems to work, but I'm not too sure
  it's really ok
- I've added a simple example: the protection of ima_policy_flags
- the last patch is optional, but it seemed worth to do the refactoring

Changelog:

v1->v2

* introduce cleaner split between generic and arch code
* add x86_64 specific memset_user()
* replace kernel-space memset() memcopy() with userspace counterpart
* randomize the base address for the alternate map across the entire
  available address range from user space (128TB - 64TB)
* convert BUG() to WARN()
* turn verification of written data into debugging option
* wr_rcu_assign_pointer() as special case of wr_assign()
* example with protection of ima_policy_flags
* documentation

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org

Igor Stoppa (12):
	[PATCH 01/12] x86_64: memset_user()
	[PATCH 02/12] __wr_after_init: linker section and label
	[PATCH 03/12] __wr_after_init: generic header
	[PATCH 04/12] __wr_after_init: x86_64: __wr_op
	[PATCH 05/12] __wr_after_init: x86_64: debug writes
	[PATCH 06/12] __wr_after_init: Documentation: self-protection
	[PATCH 07/12] __wr_after_init: lkdtm test
	[PATCH 08/12] rodata_test: refactor tests
	[PATCH 09/12] rodata_test: add verification for __wr_after_init
	[PATCH 10/12] __wr_after_init: test write rare functionality
	[PATCH 11/12] IMA: turn ima_policy_flags into __wr_after_init
	[PATCH 12/12] x86_64: __clear_user as case of __memset_user


Documentation/security/self-protection.rst |  14 ++-
arch/Kconfig                               |  15 +++
arch/x86/Kconfig                           |   1 +
arch/x86/include/asm/uaccess_64.h          |   6 +
arch/x86/lib/usercopy_64.c                 |  41 +++++--
arch/x86/mm/Makefile                       |   2 +
arch/x86/mm/prmem.c                        | 127 +++++++++++++++++++++
drivers/misc/lkdtm/core.c                  |   3 +
drivers/misc/lkdtm/lkdtm.h                 |   3 +
drivers/misc/lkdtm/perms.c                 |  29 +++++
include/asm-generic/vmlinux.lds.h          |  25 +++++
include/linux/cache.h                      |  21 ++++
include/linux/prmem.h                      | 142 ++++++++++++++++++++++++
init/main.c                                |   2 +
mm/Kconfig.debug                           |  16 +++
mm/Makefile                                |   1 +
mm/rodata_test.c                           |  69 ++++++++----
mm/test_write_rare.c                       | 135 ++++++++++++++++++++++
security/integrity/ima/ima.h               |   3 +-
security/integrity/ima/ima_init.c          |   5 +-
security/integrity/ima/ima_policy.c        |   9 +-
21 files changed, 629 insertions(+), 40 deletions(-)
