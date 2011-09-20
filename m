Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 55F099000C5
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 13:57:25 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p8KHvNKH008771
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:57:23 GMT
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KHvNWV2486398
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 18:57:23 +0100
Received: from d06av10.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KHvL4i013633
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 11:57:22 -0600
Date: Tue, 20 Sep 2011 18:13:10 +0100
From: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 8/26]   x86: analyze instruction and
 determine fixups.
Message-ID: <20110920171310.GC27959@stefanha-thinkpad.localdomain>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120127.25326.71509.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920120127.25326.71509.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 20, 2011 at 05:31:27PM +0530, Srikar Dronamraju wrote:
> 
> The instruction analysis is based on x86 instruction decoder and
> determines if an instruction can be probed and determines the necessary
> fixups after singlestep.  Instruction analysis is done at probe
> insertion time so that we avoid having to repeat the same analysis every
> time a probe is hit.
> 
> Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> ---
>  arch/x86/Kconfig               |    3 
>  arch/x86/include/asm/uprobes.h |   42 ++++
>  arch/x86/kernel/Makefile       |    1 
>  arch/x86/kernel/uprobes.c      |  385 ++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 431 insertions(+), 0 deletions(-)
>  create mode 100644 arch/x86/include/asm/uprobes.h
>  create mode 100644 arch/x86/kernel/uprobes.c

You've probably thought of this but it would be nice to skip XOL for
nops.  This would be a common case with static probes (e.g. sdt.h) where
the probe template includes a nop where we can easily plant int $0x3.

Perhaps a check can be added to the analysis so that after calling the
filter/handler we can immediately continue the process instead of
executing the (useless) nop out-of-line.

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
