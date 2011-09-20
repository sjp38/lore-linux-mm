Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3558C9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 16:53:32 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate3.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p8KKrK7V001646
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 20:53:20 GMT
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KKrKVE2232530
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 21:53:20 +0100
Received: from d06av12.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KKrIdP006836
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 14:53:20 -0600
Date: Tue, 20 Sep 2011 21:53:17 +0100
From: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 8/26]   x86: analyze instruction and
 determine fixups.
Message-ID: <20110920205317.GA1508@stefanha-thinkpad.localdomain>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120127.25326.71509.sendpatchset@srdronam.in.ibm.com>
 <20110920171310.GC27959@stefanha-thinkpad.localdomain>
 <20110920181225.GA5149@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920181225.GA5149@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 20, 2011 at 02:12:25PM -0400, Christoph Hellwig wrote:
> On Tue, Sep 20, 2011 at 06:13:10PM +0100, Stefan Hajnoczi wrote:
> > You've probably thought of this but it would be nice to skip XOL for
> > nops.  This would be a common case with static probes (e.g. sdt.h) where
> > the probe template includes a nop where we can easily plant int $0x3.
> 
> Do we now have sdt.h support for uprobes?  That's one of the killer
> features that always seemed to get postponed.

Not yet but it's a question of doing roughly what SystemTap does to
parse the appropriate ELF sections and then putting those probes into
uprobes.

Masami looked at this and found that SystemTap sdt.h currently requires
an extra userspace memory store in order to activate probes.  Each probe
has a "semaphore" 16-bit counter which applications may test before
hitting the probe itself.  This is used to avoid overhead in
applications that do expensive argument processing (e.g. creating
strings) for probes.

But this should be solvable so it would be possible to use perf-probe(1)
on a std.h-enabled binary.  Some distros already ship such binaries!

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
