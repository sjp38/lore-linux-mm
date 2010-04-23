Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB356B0210
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 17:19:15 -0400 (EDT)
Received: from f199130.upc-f.chello.nl ([80.56.199.130] helo=dyad.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1O5QHI-0003iK-Sq
	for linux-mm@kvack.org; Fri, 23 Apr 2010 21:19:13 +0000
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <xr93k4rxx6sd.fsf@ninji.mtv.corp.google.com>
References: <1268609202-15581-2-git-send-email-arighi@develer.com>
	 <20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100318162855.GG18054@balbir.in.ibm.com>
	 <20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100319024039.GH18054@balbir.in.ibm.com>
	 <20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	 <xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	 <20100414140523.GC13535@redhat.com>
	 <xr9339yxyepc.fsf@ninji.mtv.corp.google.com>
	 <20100415114022.ef01b704.nishimura@mxp.nes.nec.co.jp>
	 <g2u49b004811004142148i3db9fefaje1f20760426e0c7e@mail.gmail.com>
	 <20100415152104.62593f37.nishimura@mxp.nes.nec.co.jp>
	 <20100415155432.cf1861d9.kamezawa.hiroyu@jp.fujitsu.com>
	 <xr93k4rxx6sd.fsf@ninji.mtv.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 23 Apr 2010 23:19:09 +0200
Message-ID: <1272057549.1821.44.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-04-23 at 13:17 -0700, Greg Thelen wrote:
> 
> This is an interesting idea.  If this applies to memcg dirty accounting,
> then would it also apply to system-wide dirty accounting?  I don't think
> so, but I wanted to float the idea.  It looks like this proportions.c
> code is good is at comparing the rates of events (for example: per-task
> dirty page events).  However, in the case of system-wide dirty
> accounting we also want to consider the amount of dirty memory, not just
> the rate at which it is being dirtied.

Correct, the whole proportion thing is purely about comparing rates of
events.

> The performance of simple irqsave locking or more advanced RCU locking
> is similar to current locking (non-irqsave/non-rcu) for several
> workloads (kernel build, dd).  Using a micro-benchmark some differences
> are seen:
> * irqsave is 1% slower than mmotm non-irqsave/non-rcu locking.
> * RCU locking is 4% faster than mmotm non-irqsave/non-rcu locking.
> * RCU locking is 5% faster than irqsave locking.

Depending on what architecture you care about local_t might also be an
option, it uses per-cpu irq/nmi safe instructions (and falls back to
local_irq_save/restore for architectures lacking this support).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
