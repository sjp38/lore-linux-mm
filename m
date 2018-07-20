Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06AA26B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:22:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c2-v6so4931311edi.20
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 09:22:40 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id m30-v6si1589374ede.102.2018.07.20.09.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 09:22:39 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 0/3] PTI for x86-32 Fixes and Updates
Date: Fri, 20 Jul 2018 18:22:21 +0200
Message-Id: <1532103744-31902-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, joro@8bytes.org

Hi,

here are 3 patches which update the PTI-x86-32 patches recently merged
into the tip-tree. The patches are ordered by importance:

	Patch 1: Very important, it fixes a vmalloc-fault in NMI context
		 when PTI is enabled. This is pretty unlikely to hit
		 when starting perf on an idle machine, which is why I
		 didn't find it earlier in my testing. I always started
		 'perf top' first :/ But when I start 'perf top' last
		 when the kernel-compile already runs, it hits almost
		 immediatly.

	Patch 2: Fix the 'from-kernel-check' in SWITCH_TO_KERNEL_STACK
	         to also take VM86 into account. This is not strictly
		 necessary because the slow-path also works for VM86
		 mode but it is not how the code was intended to work.
		 And it breaks when Patch 3 is applied on-top.

	Patch 3: Implement the reduced copying in the paranoid
		 entry/exit path as suggested by Andy Lutomirski while
		 reviewing version 7 of the original patches.

I have the x86/tip branch with these patches on-top running my test for
6h now, with no issues so far. So for now it looks like there are no
scheduling points or irq-enabled sections reached from the paranoid
entry/exit paths and we always return to the entry-stack we came from.

I keep the test running over the weekend at least.

Please review.

[ If Patch 1 looks good to the maintainers I suggest applying it soon,
  before too many linux-next testers run into this issue. It is actually
  the reason why I send out the patches _now_ and didn't wait until next
  week when the other two patches got more testing from my side. ]

Thanks,

	Joerg

Joerg Roedel (3):
  perf/core: Make sure the ring-buffer is mapped in all page-tables
  x86/entry/32: Check for VM86 mode in slow-path check
  x86/entry/32: Copy only ptregs on paranoid entry/exit path

 arch/x86/entry/entry_32.S   | 82 ++++++++++++++++++++++++++-------------------
 kernel/events/ring_buffer.c | 10 ++++++
 2 files changed, 58 insertions(+), 34 deletions(-)

-- 
2.7.4
