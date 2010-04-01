Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA89D6B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 04:32:33 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o318WSqh027104
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 10:32:29 +0200
Received: from pzk10 (pzk10.prod.google.com [10.243.19.138])
	by wpaz33.hot.corp.google.com with ESMTP id o318W1vq010549
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 01:32:27 -0700
Received: by pzk10 with SMTP id 10so921195pzk.28
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 01:32:27 -0700 (PDT)
Date: Thu, 1 Apr 2010 01:32:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] proc: don't take ->siglock for /proc/pid/oom_adj
In-Reply-To: <20100331230032.GB4025@redhat.com>
Message-ID: <alpine.DEB.2.00.1004010128050.6285@chino.kir.corp.google.com>
References: <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com>
 <20100330163909.GA16884@redhat.com> <20100330174337.GA21663@redhat.com> <alpine.DEB.2.00.1003301329420.5234@chino.kir.corp.google.com> <20100331185950.GB11635@redhat.com> <alpine.DEB.2.00.1003311408520.31252@chino.kir.corp.google.com>
 <20100331230032.GB4025@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010, Oleg Nesterov wrote:

> > That doesn't work for depraceted_mode (sic), you'd need to test for
> > OOM_ADJUST_MIN and OOM_ADJUST_MAX in that case.
> 
> Yes, probably "if (depraceted_mode)" should do more checks, I didn't try
> to verify that MIN/MAX are correctly converted. I showed this code to explain
> what I mean.
> 

Ok, please cc me on the patch, it will be good to get rid of the duplicate 
code and remove oom_adj from struct signal_struct.

> > There have been efforts to reuse as much of this code as possible for
> > other sysctl handlers as well, you might be better off looking for
> 
> David, sorry ;) Right now I'd better try to stop the overloading of
> ->siglock. And, I'd like to shrink struct_signal if possible, but this
> is minor.
> 

Do we need ->siglock?  Why can't we just do

	struct sighand_struct *sighand;
	struct signal_struct *sig;

	rcu_read_lock();
	sighand = rcu_dereference(task->sighand);
	if (!sighand) {
		rcu_read_unlock();
		return;
	}
	sig = task->signal;

	... load/store to sig ...

	rcu_read_unlock();

instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
