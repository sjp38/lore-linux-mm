Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7DA6B6EA2
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 07:18:43 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id e8-v6so4511513ljg.22
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 04:18:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a16sor4252617lfi.3.2018.12.04.04.18.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 04:18:40 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [RFC v1 PATCH 0/6] hardening: statically allocated protected memory
Date: Tue,  4 Dec 2018 14:17:59 +0200
Message-Id: <20181204121805.4621-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch-set is the first-cut implementation of write-rare memory
protection, as previously agreed [1]
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
* supports only x86_64
* might not work for very large amount of data, since it relies on the
  assumption that said data can be entirely remapped, at init.


Some notes:
- even if the code is only for x86_64, it is placed in the generic
  locations, with the intention of extending it also to arm64
- the current section used for collecting wr-after-init data might need to
  be moved, to work with arm64 MMU
- the functionality is in its own c and h files, for now, to ease the
  introduction (and refactoring) of code dealing with dynamic allocation
- recently some updated patches were posted for live-patch on arm64 [2],
  they might help with adding arm64 support here
- to avoid the risk of weakening __ro_after_init, __wr_after_init data is
  in a separate set of pages, and any invocation will confirm that the
  memory affected falls within this range.
  I have modified rodata_test accordingly, to check als othis case.
- to avoid replicating the code which does the change of mapping, there is
  only one function performing multiple, selectable, operations, such as
  memcpy(), memset(). I have added also rcu_assign_pointer() as further
  example. But I'm not too fond of this implementation either. I just
  couldn't think of any that I would like significantly better.
- I have left out the patchset from Nadav that these patches depend on,
  but it can be found here [3] (Should have I resubmitted it?)
- I am not sure what is the correct form for giving proper credit wrt the
  authoring of the wr_after_init mechanism, guidance would be appreciated
- In an attempt to spam less people, I have curbed the list of recipients.
  If I have omitted someone who should have been kept/added, please
  add them to the thread.


[1] https://www.openwall.com/lists/kernel-hardening/2018/11/22/8
[2] https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1793199.html
[3] https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1810245.html

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org



Igor Stoppa (6):
	[PATCH 1/6] __wr_after_init: linker section and label
	[PATCH 2/6] __wr_after_init: write rare for static allocation
	[PATCH 3/6] rodata_test: refactor tests
	[PATCH 4/6] rodata_test: add verification for __wr_after_init
	[PATCH 5/6] __wr_after_init: test write rare functionality
	[PATCH 6/6] __wr_after_init: lkdtm test

drivers/misc/lkdtm/core.c         |   3 +
drivers/misc/lkdtm/lkdtm.h        |   3 +
drivers/misc/lkdtm/perms.c        |  29 ++++++++
include/asm-generic/vmlinux.lds.h |  20 ++++++
include/linux/cache.h             |  17 +++++
include/linux/prmem.h             | 134 +++++++++++++++++++++++++++++++++++++
init/main.c                       |   2 +
mm/Kconfig                        |   4 ++
mm/Kconfig.debug                  |   9 +++
mm/Makefile                       |   2 +
mm/prmem.c                        | 124 ++++++++++++++++++++++++++++++++++
mm/rodata_test.c                  |  63 ++++++++++++------
mm/test_write_rare.c              | 135 ++++++++++++++++++++++++++++++++++++++
13 files changed, 525 insertions(+), 20 deletions(-)
