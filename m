Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7BEE56B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 14:11:44 -0500 (EST)
Date: Mon, 28 Nov 2011 20:06:14 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH RFC 0/5] uprobes: kill xol vma
Message-ID: <20111128190614.GA4602@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

Hello.

On top of this series, not for inclusion yet, just to explain what
I mean. May be someone can test it ;)

This series kills xol_vma. Instead we use the per_cpu-like xol slots.

This is much more simple and efficient. And this of course solves
many problems we currently have with xol_vma.

For example, we simply can not trust it. We do not know what actually
we are going to execute in UTASK_SSTEP mode. An application can unmap
this area and then do mmap(PROT_EXEC|PROT_WRITE, MAP_FIXED) to fool
uprobes.

The only disadvantage is that this adds a bit more arch-dependant
code.

The main question, can this work? I know very little in this area.
And I am not sure if this can be ported to other architectures.

Please comment.

Oleg.

 arch/x86/include/asm/fixmap.h      |    9 +
 arch/x86/include/asm/thread_info.h |    4 
 arch/x86/kernel/process.c          |    6 
 arch/x86/kernel/uprobes.c          |   26 +++-
 include/linux/mm_types.h           |    1 
 include/linux/uprobes.h            |   27 ----
 kernel/fork.c                      |    2 
 kernel/uprobes.c                   |  239 +++----------------------------------
 8 files changed, 71 insertions(+), 243 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
