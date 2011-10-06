Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A6A506B0259
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 02:05:19 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 6 Oct 2011 02:05:18 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9664aYt230106
	for <linux-mm@kvack.org>; Thu, 6 Oct 2011 02:04:38 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9664Xws001891
	for <linux-mm@kvack.org>; Thu, 6 Oct 2011 03:04:35 -0300
Date: Thu, 6 Oct 2011 11:17:10 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 26/26]   uprobes: queue signals while
 thread is singlestepping.
Message-ID: <20111006054710.GB17591@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120517.25326.57657.sendpatchset@srdronam.in.ibm.com>
 <1317128626.15383.61.camel@twins>
 <20110927131213.GE3685@linux.vnet.ibm.com>
 <20111005180139.GA5704@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111005180139.GA5704@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

* Oleg Nesterov <oleg@redhat.com> [2011-10-05 20:01:39]:

> Srikar, I am still reading this series, need more time to read this
> patch, but:

Okay, 

> 
> On 09/27, Srikar Dronamraju wrote:
> >
> > I did a rethink and implemented this patch a little differently using
> > block_all_signals, unblock_all_signals. This wouldnt need the
> > #ifdeffery + no changes in kernel/signal.c
> 
> No, Please don't. block_all_signals() must be killed. This interface
> simply do not work. At all. It is buggy as hell. I guess I should ping
> David Airlie again.
> 

I could use sigprocmask instead of block_all_signals.

The patch (that I sent out as part of v5 patchset) uses per task
pending sigqueue and start queueing the signals when the task
singlesteps. After completion of singlestep, walks thro the pending
signals.

But I was thinking if I should block signals instead of queueing them in
a different sigqueue. So Idea is to block signals just before the task
enables singlestep and unblock after task disables singlestep.

Instead of using block_all_signals, I could use sigprocmask to achieve
the same.

Which approach do you suggest or do you have any other approach to look
at?

-- 
Thanks and Regards
Srikar


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
