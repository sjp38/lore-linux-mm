Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C572F6B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:52:56 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 24 Nov 2011 07:52:55 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAOEqi4o092416
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 07:52:44 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAOEqeZL011471
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 07:52:44 -0700
Date: Thu, 24 Nov 2011 20:21:39 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: Fwd: uprobes: register/unregister probes.
Message-ID: <20111124145139.GK28065@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <hYuXv-26J-3@gated-at.bofh.it>
 <hYuXw-26J-5@gated-at.bofh.it>
 <i0nRU-7eK-11@gated-at.bofh.it>
 <603b0079-5f54-4299-9a9a-a5e237ccca73@l23g2000pro.googlegroups.com>
 <20111124070303.GB28065@linux.vnet.ibm.com>
 <1322128199.2921.3.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322128199.2921.3.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, tulasidhard@gmail.com

* Peter Zijlstra <peterz@infradead.org> [2011-11-24 10:49:59]:

> On Thu, 2011-11-24 at 12:33 +0530, Srikar Dronamraju wrote:
> > > On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> > > > +int register_uprobe(struct inode *inode, loff_t offset,
> > > > +                               struct uprobe_consumer *consumer)
> > > > +{
> > > > +       struct uprobe *uprobe;
> > > > +       int ret = -EINVAL;
> > > > +
> > > > +       if (!consumer || consumer->next)
> > > > +               return ret;
> > > > +
> > > > +       inode = igrab(inode);
> > > 
> > > So why are you dealing with !consumer but not with !inode? and why
> > > does
> > > it make sense to allow !consumer at all?
> > > 
> > 
> > 
> > I am not sure if I got your comment correctly.
> > 
> > I do check for inode just after the igrab.
> 
> No you don't, you check the return value of igrab(), but you crash hard
> when someone calls register_uprobe(.inode=NULL).
> 

Okay. will add a check for inode before we do the igrab.

> > I am actually not dealing with !consumer.
> > If the consumer is NULL, then we dont have any handler to run so why
> > would we want to register such a probe?
> 
> Why allow someone calling register_uprobe(.consumer=NULL) to begin with?
> That doesn't make any sense.
> 
> > Also if consumer->next is Non-NULL, that means that this consumer was
> > already used.  Reusing the consumer, can result in consumers list getting
> > broken into two.
> 
> Yeah, although at that point why be nice about it? Just but a WARN_ON()
> in or so.
> 

I thought you werent happy with prints and WARN_ON/BUG_ON unless it was
really really necessary. If we were to have a WARN_ON for a wrong
consumer passed, then we would need a warn_On for NULL inode too.

So I think we should leave this as is.

Unless I have commented, I agree to your comments sent in other threads
and will resolve them accordingly.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
