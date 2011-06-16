Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BA0EB6B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 23:34:53 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5G3N1HI026345
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 21:23:01 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p5G3YhpP172696
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 21:34:43 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5FLYC8i006372
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 15:34:16 -0600
Date: Thu, 16 Jun 2011 08:56:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
Message-ID: <20110616032645.GF4952@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125931.28590.12362.sendpatchset@localhost6.localdomain6>
 <1308161486.2171.61.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1308161486.2171.61.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-15 20:11:26]:

> On Tue, 2011-06-07 at 18:29 +0530, Srikar Dronamraju wrote:
> > +       up_write(&mm->mmap_sem);
> > +       mutex_lock(&uprobes_mutex);
> > +       down_read(&mm->mmap_sem); 
> 
> egads, and all that without a comment explaining why you think that is
> even remotely sane.
> 
> I'm not at all convinced, it would expose the mmap() even though you
> could still decide to tear it down if this function were to fail, I bet
> there's some funnies there.

The problem is with lock ordering.  register/unregister operations
acquire uprobes_mutex (which serializes register unregister and the
mmap_hook) and then holds mmap_sem for read before they insert a
breakpoint.

But the mmap hook would be called with mmap_sem held for write. So
acquiring uprobes_mutex can result in deadlock. Hence we release the
mmap_sem, take the uprobes_mutex and then again hold the mmap_sem.

After we re-acquire the mmap_sem, we do check if the vma is valid.

Do we have better solutions?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
