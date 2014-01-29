Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id A537A6B0036
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 10:58:07 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id w8so2608302qac.22
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 07:58:07 -0800 (PST)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id a8si2011703qak.176.2014.01.29.07.58.06
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 07:58:07 -0800 (PST)
Date: Wed, 29 Jan 2014 09:58:04 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] kthread: ensure locality of task_struct allocations
In-Reply-To: <alpine.DEB.2.02.1401290012460.10268@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1401290957350.23856@nuc>
References: <20140128183808.GB9315@linux.vnet.ibm.com> <alpine.DEB.2.02.1401290012460.10268@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Anton Blanchard <anton@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Jan Kara <jack@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>

On Wed, 29 Jan 2014, David Rientjes wrote:

> > diff --git a/kernel/kthread.c b/kernel/kthread.c
> > index b5ae3ee..8573e4e 100644
> > --- a/kernel/kthread.c
> > +++ b/kernel/kthread.c
> > @@ -217,7 +217,7 @@ int tsk_fork_get_node(struct task_struct *tsk)
> >  	if (tsk == kthreadd_task)
> >  		return tsk->pref_node_fork;
> >  #endif
> > -	return numa_node_id();
> > +	return numa_mem_id();
>
> I'm wondering why return NUMA_NO_NODE wouldn't have the same effect and
> prefer the local node?
>

The idea here seems to be that the allocation may occur from a cpu that is
different from where the process will run later on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
