Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id E536C6B00EC
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 03:33:48 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 23 Apr 2012 01:33:48 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 4001919D804A
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 01:33:35 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3N7XiHc175382
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 01:33:44 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3N7Xh0e028567
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 01:33:44 -0600
Date: Mon, 23 Apr 2012 12:54:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
Message-ID: <20120423072445.GC8357@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120414205200.GA9083@redhat.com>
 <1334487062.2528.113.camel@twins>
 <20120415195351.GA22095@redhat.com>
 <1334526513.28150.23.camel@twins>
 <20120415234401.GA32662@redhat.com>
 <1334571419.28150.30.camel@twins>
 <20120416214707.GA27639@redhat.com>
 <1334916861.2463.50.camel@laptop>
 <20120420183718.GA2236@redhat.com>
 <1335165240.28150.89.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1335165240.28150.89.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

* Peter Zijlstra <peterz@infradead.org> [2012-04-23 09:14:00]:

> On Fri, 2012-04-20 at 20:37 +0200, Oleg Nesterov wrote:
> > Say, a user wants to probe /sbin/init only. What if init forks?
> > We should remove breakpoints from child->mm somehow. 
> 
> How is that hard? dup_mmap() only copies the VMAs, this doesn't actually
> copy the breakpoint. So the child doesn't have a breakpoint to be
> removed.
> 

Because the pages are COWED, the breakpoint gets copied over to the
child. If we dont want the breakpoints to be not visible to the child,
then we would have to remove them explicitly based on the filter (i.e if
and if we had inserted breakpoints conditionally based on filter). 

Once we add the conditional breakpoint insertion (which is tricky), we have
to support conditional breakpoint removal in the dup_mmap() thro the
uprobe_mmap hook (which I think is not that hard).  Conditional removal
of breakpoints in fork path would just be an extension of the
conditional breakpoint insertion.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
