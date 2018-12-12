Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 191808E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 19:12:11 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so11738343plp.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 16:12:11 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f18si13139318pgl.457.2018.12.11.16.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 16:12:09 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: =?UTF-8?q?=5BPATCH=20v2=200/4=5D=20Don=E2=80=99t=20leave=20executable=20TLB=20entries=20to=20freed=20pages?=
Date: Tue, 11 Dec 2018 16:03:50 -0800
Message-Id: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, luto@kernel.org, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, mhiramat@kernel.org, rostedt@goodmis.org, mingo@redhat.com, ast@kernel.org, daniel@iogearbox.net, jeyu@kernel.org, namit@vmware.com, netdev@vger.kernel.org, ard.biesheuvel@linaro.org, jannh@google.com
Cc: kristen@linux.intel.com, dave.hansen@intel.com, deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Sometimes when memory is freed via the module subsystem, an executable
permissioned TLB entry can remain to a freed page. If the page is re-used to
back an address that will receive data from userspace, it can result in user
data being mapped as executable in the kernel. The root of this behavior is
vfree lazily flushing the TLB, but not lazily freeing the underlying pages.

This v2 enables vfree to handle freeing memory with special permissions. So now
it can be done with no W^X window, centralizing the logic for this operation,
and also to do this with only one TLB flush on x86.

I'm not sure if the algorithm Andy Lutomirski suggested (to do the whole
teardown with one TLB flush) will work across other architectures or not, so it
is in an x86 arch breakout(arch_vunmap) in this version. The default arch_vunmap
implementation does what Nadav is proposing users of module_alloc do on tear
down so it should be unchanged in behavior, just centralized. The main
difference will be BPF teardown will now get an extra TLB flush on archs that
have set_memory_* defined from set_memory_nx in addition to set_memory_rw. On
x86, due to the more efficient arch version, it will be unchanged at one flush.

The logic enabling this behavior is plugged into kernel/module.c and bpf cross
arch pieces. So it should be enabled for all architectures for regular .ko
modules and bpf but the other module_alloc users will be unchanged for now.

I did find one small downside with this approach, and that is that there is
occasionally one extra directmap page split in modules tear down, since one of
the modules subsections is RW. The x86 arch_vunmap will set the RW directmap of
the pages not present, since it doesn't know the whole thing is not executable,
so sometimes this results in an splitting an extra large page because the paging
structure would have its first special permission. But on the plus side many TLB
flushes are reduced down to one (on x86 here, and likely others in the future).
The other usages of modules (bpf, etc) will not have RW subsections and so this
will not increase. So I am thinking its not a big downside for a few modules
compared to reducing TLB flushes, removing executable stale TLB entries and code
simplicity.

Todo:
 - Merge with Nadav Amit's patchset
 - Test on x86 32 bit with highmem
 - Plug into ftrace and kprobes implementations in Nadav's next version of his
   patchset

Changes since v1:
 - New efficient algorithm on x86 for tearing down executable RO memory and
   flag for this (Andy Lutomirski)
 - Have no W^X violating window on tear down (Nadav Amit)


Rick Edgecombe (4):
  vmalloc: New flags for safe vfree on special perms
  modules: Add new special vfree flags
  bpf: switch to new vmalloc vfree flags
  x86/vmalloc: Add TLB efficient x86 arch_vunmap

 arch/x86/include/asm/set_memory.h |  2 +
 arch/x86/mm/Makefile              |  3 +-
 arch/x86/mm/pageattr.c            | 11 +++--
 arch/x86/mm/vmalloc.c             | 71 ++++++++++++++++++++++++++++++
 include/linux/filter.h            | 26 +++++------
 include/linux/vmalloc.h           |  2 +
 kernel/bpf/core.c                 |  1 -
 kernel/module.c                   | 43 +++++-------------
 mm/vmalloc.c                      | 73 ++++++++++++++++++++++++++++---
 9 files changed, 173 insertions(+), 59 deletions(-)
 create mode 100644 arch/x86/mm/vmalloc.c

-- 
2.17.1
