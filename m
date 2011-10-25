Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 084A06B002D
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 02:03:19 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ananth@in.ibm.com>;
	Tue, 25 Oct 2011 02:03:08 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9P61Q9C225214
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 02:01:26 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9P61Lsx020156
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 00:01:22 -0600
Date: Tue, 25 Oct 2011 11:31:00 +0530
From: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Subject: Re: [PATCH 13/X] uprobes: introduce UTASK_SSTEP_TRAPPED logic
Message-ID: <20111025060059.GA8247@in.ibm.com>
Reply-To: ananth@in.ibm.com
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com> <20111019215344.GG16395@redhat.com> <20111022072030.GB24475@in.ibm.com> <20111024144127.GA14975@redhat.com> <20111024151614.GA6034@in.ibm.com> <20111024161306.GB19659@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111024161306.GB19659@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 24, 2011 at 06:13:06PM +0200, Oleg Nesterov wrote:
> On 10/24, Ananth N Mavinakayanahalli wrote:
> >
> > Thinking further on this, in the normal 'running gdb on a core' case, we
> > won't have this problem, as the binary that we point gdb to, will be a
> > pristine one, without the uprobe int3s, right?
> 
> Not sure I understand.
> 
> I meant, if we have a binary with uprobes (iow, register_uprobe() installed
> uprobes into that file), then gdb will see int3's with or without the core.
> Or you can add uprobe into glibc, say you can probe getpid(). Now (again,
> with or without the core) disassemble shows that getpid() starts with int3.
> 
> But I guess you meant something else...

No, you are right... my inference was wrong. On a core with a uprobe
with an explicit raise(SIGABRT) does show the breakpoint.

(gdb) disassemble start_thread2
Dump of assembler code for function start_thread2:
   0x0000000000400831 <+0>:	int3   
   0x0000000000400832 <+1>:	mov    %rsp,%rbp
   0x0000000000400835 <+4>:	sub    $0x10,%rsp
   0x0000000000400839 <+8>:	mov    %rdi,-0x8(%rbp)
   0x000000000040083d <+12>:	callq  0x400650 <getpid@plt>

Now, I guess we need to agree on what is the acceptable behavior in the
uprobes case. What's your suggestion?

Ananth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
