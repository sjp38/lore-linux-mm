Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 28F998D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:45:49 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LA02BL027639
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 04:00:02 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LHjYE7139002
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 11:45:35 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LHjVk8014791
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 11:45:32 -0600
Date: Thu, 21 Apr 2011 23:01:20 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 7/26]  7: x86: analyze instruction
 and determine fixups.
Message-ID: <20110421173120.GJ10698@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
 <20110401143348.15455.68644.sendpatchset@localhost6.localdomain6>
 <1303219751.7181.101.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1303219751.7181.101.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Steven Rostedt <rostedt@goodmis.org> [2011-04-19 09:29:11]:

> On Fri, 2011-04-01 at 20:03 +0530, Srikar Dronamraju wrote:
> 
> > +
> > +static void report_bad_prefix(void)
> > +{
> > +	printk(KERN_ERR "uprobes does not currently support probing "
> > +		"instructions with any of the following prefixes: "
> > +		"cs:, ds:, es:, ss:, lock:\n");
> > +}
> > +
> > +static void report_bad_1byte_opcode(int mode, uprobe_opcode_t op)
> > +{
> > +	printk(KERN_ERR "In %d-bit apps, "
> > +		"uprobes does not currently support probing "
> > +		"instructions whose first byte is 0x%2.2x\n", mode, op);
> > +}
> > +
> > +static void report_bad_2byte_opcode(uprobe_opcode_t op)
> > +{
> > +	printk(KERN_ERR "uprobes does not currently support probing "
> > +		"instructions with the 2-byte opcode 0x0f 0x%2.2x\n", op);
> > +}
> 
> Should these really be KERN_ERR, or is KERN_WARNING a better fit?
> 
> Also, can a non-privileged user cause these printks to spam the console
> and cause a DoS to the system?
> 

Sometimes, the user might try registering a probe at a valid file +
valid offset + valid consumer; but an instruction that we cant probe.
Then trying to figure why its failing would be very hard.

how about pr_warn_ratelimited()?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
