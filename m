Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8435D6B01C4
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 07:08:27 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5EB8OOO007551
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 14 Jun 2010 20:08:24 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DAACD45DE51
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 20:08:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B8E3645DE4F
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 20:08:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 631AE1DB8038
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 20:08:23 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B281E1DB805B
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 20:08:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/18] oom: give current access to memory reserves if it has been killed
In-Reply-To: <alpine.DEB.2.00.1006081145560.18848@chino.kir.corp.google.com>
References: <20100608203216.765D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006081145560.18848@chino.kir.corp.google.com>
Message-Id: <20100614195055.9DAE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Mon, 14 Jun 2010 20:08:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > +	/*
> > > +	 * If current has a pending SIGKILL, then automatically select it.  The
> > > +	 * goal is to allow it to allocate so that it may quickly exit and free
> > > +	 * its memory.
> > > +	 */
> > > +	if (fatal_signal_pending(current)) {
> > > +		set_thread_flag(TIF_MEMDIE);
> > > +		return;
> > > +	}
> > > +
> > >  	if (sysctl_panic_on_oom == 2) {
> > >  		dump_header(NULL, gfp_mask, order, NULL);
> > >  		panic("out of memory. Compulsory panic_on_oom is selected.\n");
> > 
> > Sorry, I had found this patch works incorrect. I don't pulled.
> > 
> 
> You're taking back your ack?
> 
> Why does this not work?  It's not killing a potentially immune task, the 
> task is already dying.  We're simply giving it access to memory reserves 
> so that it may quickly exit and die.  OOM_DISABLE does not imply that a 
> task cannot exit on its own or be killed by another application or user, 
> we simply don't want to needlessly kill another task when current is dying 
> in the first place without being able to allocate memory.
> 
> Please reconsider your thought.

Oh, I didn't talk about OOM_DISABLE. probably my explanation was too
poor.

My point is, the above code assume SIGKILL is good sign of the task is
going exit soon. but It is not always true. Only if the task is regular
userland process, it's true. kernel module author freely makes very strange
kernel thread.

note: Linux is one of most popular generic purpose OS in the world and
we have million out of funny drivers.

Plus, If false positive occur, setting TIF_MEMDIE is very dangerous because
if there is TIF_MEMDIE task, our kernl don't send next OOM-Kill. It mean
the systam can reach dead lock. In the other hand, false negative is relatively
safe. It cause one innocent task kill. but the system doesn't cause lockup.

Then, we have strongly motivation to avoid false positive. I hope you add 
some conservative check.

I don't disagree your patch concept. I only worry about the dangerousness.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
