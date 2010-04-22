Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5C67A6B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 17:09:42 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [10.3.21.2])
	by smtp-out.google.com with ESMTP id o3ML9VHp003598
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 14:09:32 -0700
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by hpaq2.eem.corp.google.com with ESMTP id o3ML9S8U004425
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:09:29 +0200
Received: by pvg3 with SMTP id 3so1538878pvg.12
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 14:09:27 -0700 (PDT)
Date: Thu, 22 Apr 2010 14:09:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100422153956.GY5683@laptop>
Message-ID: <alpine.DEB.2.00.1004221403190.25350@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com> <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com> <20100407205418.FB90.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
 <20100421121758.af52f6e0.akpm@linux-foundation.org> <20100422072319.GW5683@laptop> <20100422162536.b904203e.kamezawa.hiroyu@jp.fujitsu.com> <20100422100944.GX5683@laptop> <alpine.DEB.2.00.1004220326130.19785@chino.kir.corp.google.com>
 <20100422153956.GY5683@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010, Nick Piggin wrote:

> > The oom killer rewrite attempts to kill current first, if possible, and 
> > then will panic if panic_on_oom is set before falling back to selecting a 
> > victim.
> 
> See, this is what we want to avoid. If the user sets panic_on_oom,
> it is because they want the system to panic on oom. Not to kill
> tasks and try to continue. The user does not know or care in the
> slightest about "page fault oom". So I don't know why you think this
> is a good idea.
> 

Unless we unify the behavior of panic_on_oom, it would be possible for the 
architectures that are not converted to using pagefault_out_of_memory() 
yet using your patch series to kill tasks even if they have OOM_DISABLE 
set.  So, as it sits this second in -mm, the system will still try to kill 
current first so that all architectures are consistent.  Once all 
architectures use pagefault_out_of_memory(), we can simply add

	if (sysctl_panic_on_oom) {
		read_lock(&tasklist_lock);
		dump_header(NULL, 0, 0, NULL);
		read_unlock(&tasklist_lock);
		panic("Out of memory: panic_on_oom is enabled\n");
	}

to pagefault_out_of_memory().  I simply opted for consistency across all 
architectures before that was done.

> >  This is consistent with all other architectures such as powerpc 
> > that currently do not use pagefault_out_of_memory().  If all architectures 
> > are eventually going to be converted to using pagefault_out_of_memory() 
> 
> Yes, architectures are going to be converted, it has already been
> agreed, I dropped the ball and lazily hoped the arch people would do it.
> But further work done should be to make it consistent in the right way,
> not the wrong way.
> 

Thanks for doing the work and proposing the patchset, there were a couple 
of patches that looked like it needed a v2, but overall it looked very 
good.  Once they're merged in upstream, I think we can add the panic to 
pagefault_out_of_memory() in -mm since they'll probably make it to Linus 
before the oom killer rewrite at the speed we're going here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
