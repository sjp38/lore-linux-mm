Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C774B6B01C4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:27:02 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o58IQt2J023934
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:26:58 -0700
Received: from pxi8 (pxi8.prod.google.com [10.243.27.8])
	by kpbe16.cbf.corp.google.com with ESMTP id o58IQs7i021511
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:26:54 -0700
Received: by pxi8 with SMTP id 8so2124449pxi.33
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:26:54 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:26:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 12/12] oom: give current access to memory reserves if it
 has been killed
In-Reply-To: <20100607083650.8736.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081125340.18848@chino.kir.corp.google.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com> <20100603152653.726B.A69D9226@jp.fujitsu.com> <20100607083650.8736.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 67b5fa5..ad85e1b 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -638,6 +638,16 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >  	}
> >  
> >  	/*
> > +	 * If current has a pending SIGKILL, then automatically select it.  The
> > +	 * goal is to allow it to allocate so that it may quickly exit and free
> > +	 * its memory.
> > +	 */
> > +	if (fatal_signal_pending(current)) {
> > +		set_tsk_thread_flag(current, TIF_MEMDIE);
> > +		return;
> > +	}
> 
> Self NAK this.
> We have no gurantee that current is oom killable. Oh, here is
> out_of_memory(), sigh.
> 

We're not killing it, it's already dying.  We're simply giving it access 
to memory reserves so it may allocate and quickly exit to free its memory.  
Being OOM_DISABLE does not imply the task cannot exit or use memory 
reserves in the exit path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
