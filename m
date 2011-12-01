Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 11EB86B0080
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 08:44:04 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 1 Dec 2011 06:44:04 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB1Dhj3C117942
	for <linux-mm@kvack.org>; Thu, 1 Dec 2011 06:43:45 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB1DhdNr020336
	for <linux-mm@kvack.org>; Thu, 1 Dec 2011 06:43:41 -0700
Date: Thu, 1 Dec 2011 19:11:36 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 3/30] uprobes: register/unregister probes.
Message-ID: <20111201134136.GJ18380@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110713.10512.9461.sendpatchset@srdronam.in.ibm.com>
 <1322494194.2921.147.camel@twins>
 <20111129074807.GA13445@linux.vnet.ibm.com>
 <1322563948.2921.199.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322563948.2921.199.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

> 
> You could use the stuff from patch 29 to effectively disable the uprobe
> and return -ENOMEM to whoemever is unregistering. Basically failing the
> unreg.
> 
> That way you can leave the uprobe in existance and half installed but
> functionally fully disabled. Userspace (assuming we go back that far)
> can then either re-try the removal later, or even reinstate it by doing
> a register again or so.
> 
> Its still not pretty, but its better than pretending the unreg
> completed.
> 

This approach has its own disadvantages. perf record which does the
unregister_uprobe() might be get stuck under low memory conditions while
it tries to complete unregistration. Also the user would be confused if
the tracer is still collecting information, once the unregister_uprobe
has returned an error.

So I would still think using a kworker thread to complete unregistration
on a low memory condition might be a better solution.

While I work on getting the kworker thread implementation ready, we
could use delay deleting the probe, set the not_run_handler flag and
also see if we can remove the breakpoint while the breakpoint is hit.

This way the only worse thing that can happen is the probed processes
still take a hit.

If the kworker thread were to face a low memory situation, then it will
try to schedule another kworker thread or itself again (at a later point
in time).  I still need to investigate some more on this. 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
