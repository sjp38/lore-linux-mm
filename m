Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC856B006C
	for <linux-mm@kvack.org>; Sun, 31 May 2015 20:57:15 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so95131130pdb.0
        for <linux-mm@kvack.org>; Sun, 31 May 2015 17:57:15 -0700 (PDT)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id fe7si18992014pab.94.2015.05.31.17.57.14
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 31 May 2015 17:57:14 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 00/11] Replace module_init with an alternate initcall in non modules
Date: Sun, 31 May 2015 20:54:01 -0400
Message-ID: <1433120052-18281-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Eric Paris <eparis@parisplace.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, John McCutchan <john@johnmccutchan.com>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Robert Love <rlove@rlove.org>, Russell King <linux@arm.linux.org.uk>, Scott Wood <scottwood@freescale.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, x86@kernel.org

This series of commits converts non-modular code that is using the
module_init() call to hook itself into the system to instead use one of
the alternate priority initcalls.

Unlike the earlier series[1] that used device_initcall and hence was a
runtime no-op, these commits change to one of the alternate initcalls,
because (a) we have them and (b) it seems like the right thing to do.
For example, it would seem logical to use arch_initcall for arch
specific setup code and fs_initcall for filesystem setup code.

This does mean however, that changes in the init ordering will be taking
place, and so there is a small risk that some kind of implicit init
ordering issue may lie uncovered.  But I think it is still better to
give these ones sensible priorities than to just assign them all to
device_initcall in order to exactly preserve the old ordering.

Thad said, we have already made similar changes in core kernel code
in commit c96d6660dc65b0a90aea9834bfd8be1d5656da18 ("kernel: audit/fix
non-modular users of module_init in core code") without any regressions
reported, so this type of change isn't without precedent.

This work is factored out from what was a previously larger series[2] so
that there is a common theme and lower patch count to ease review.

Paul.

[1] https://lkml.org/lkml/2015/5/28/809
[2] https://marc.info/?l=linux-kernel&m=139033951228828

---

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Paris <eparis@parisplace.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: John McCutchan <john@johnmccutchan.com>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Robert Love <rlove@rlove.org>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Scott Wood <scottwood@freescale.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: netdev@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org
Cc: x86@kernel.org


Paul Gortmaker (11):
  mm: replace module_init usages with subsys_initcall in nommu.c
  fs/notify: don't use module_init for non-modular inotify_user code
  netfilter: don't use module_init/exit in core IPV4 code
  x86: don't use module_init for non-modular core bootflag code
  powerpc: use subsys_initcall for Freescale Local Bus
  powerpc: don't use module_init for non-modular core hugetlb code
  arm: use subsys_initcall in non-modular pl320 IPC code
  lib/list_sort: use late_initcall to hook in self tests
  mm/page_owner.c: use late_initcall to hook in enabling
  x86: perf_event_intel_bts.c: use arch_initcall to hook in enabling
  x86: perf_event_intel_pt.c: use arch_initcall to hook in enabling

 arch/powerpc/mm/hugetlbpage.c              | 2 +-
 arch/powerpc/sysdev/fsl_lbc.c              | 2 +-
 arch/x86/kernel/bootflag.c                 | 2 +-
 arch/x86/kernel/cpu/perf_event_intel_bts.c | 3 +--
 arch/x86/kernel/cpu/perf_event_intel_pt.c  | 3 +--
 drivers/mailbox/pl320-ipc.c                | 2 +-
 fs/notify/inotify/inotify_user.c           | 4 ++--
 lib/list_sort.c                            | 2 +-
 mm/nommu.c                                 | 4 ++--
 mm/page_owner.c                            | 2 +-
 net/ipv4/netfilter.c                       | 9 +--------
 11 files changed, 13 insertions(+), 22 deletions(-)

-- 
2.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
