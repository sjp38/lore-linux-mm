Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 0B54D8D0004
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:51:01 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so2223717pbb.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 14:51:01 -0700 (PDT)
Date: Thu, 1 Nov 2012 14:50:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <CAA25o9SdQ7e5w8=W0faz82nZ7_3N7xbbExKQe0-HsU87hs2MPA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1211011448490.19373@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com> <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com> <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com> <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
 <20121030001809.GL15767@bbox> <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com> <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com> <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com> <20121031005738.GM15767@bbox>
 <alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com> <20121101024316.GB24883@bbox> <alpine.DEB.2.00.1210312140090.17607@chino.kir.corp.google.com> <CAA25o9SdQ7e5w8=W0faz82nZ7_3N7xbbExKQe0-HsU87hs2MPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Thu, 1 Nov 2012, Luigi Semenzato wrote:

> > @@ -706,11 +693,11 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >                 return;
> >
> >         /*
> > -        * If current has a pending SIGKILL, then automatically select it.  The
> > -        * goal is to allow it to allocate so that it may quickly exit and free
> > -        * its memory.
> > +        * If current has a pending SIGKILL or is exiting, then automatically
> > +        * select it.  The goal is to allow it to allocate so that it may
> > +        * quickly exit and free its memory.
> >          */
> > -       if (fatal_signal_pending(current)) {
> > +       if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
> >                 set_thread_flag(TIF_MEMDIE);
> >                 return;
> >         }
> 
> I tested this change with my load and it appears to also prevent the deadlocks.
> 
> I have a question though.  I thought only one process was allowed to
> be in TIF_MEMDIE state, but I don't see anything that prevents this
> code (before or after the change) from setting the flag in multiple
> processes.  Is this a problem?
> 

The code you've quoted above, prior to being changed by the patch, allows 
any thread with a fatal signal to have access to memory reserves, so it's 
certainly not only one thread with TIF_MEMDIE set at a time (the oom 
killer is not the only thing that can kill a thread).  The goal of that 
code is to ensure anything that has been killed can allocate successfully 
wherever it happens to be running so that it can handle the signal, exit, 
and free its memory.  My patch is extending that for all threads that are 
in the exit path that happen to require memory to exit to prevent a 
livelock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
