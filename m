Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id BDA538D0008
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 18:04:28 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so1108996qcq.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 15:04:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1211011448490.19373@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
	<CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
	<alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
	<CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
	<20121030001809.GL15767@bbox>
	<CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
	<alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
	<CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com>
	<20121031005738.GM15767@bbox>
	<alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com>
	<20121101024316.GB24883@bbox>
	<alpine.DEB.2.00.1210312140090.17607@chino.kir.corp.google.com>
	<CAA25o9SdQ7e5w8=W0faz82nZ7_3N7xbbExKQe0-HsU87hs2MPA@mail.gmail.com>
	<alpine.DEB.2.00.1211011448490.19373@chino.kir.corp.google.com>
Date: Thu, 1 Nov 2012 15:04:27 -0700
Message-ID: <CAA25o9TvZxoLgnt0YEFtAP8D-mTyL6QupiLTR65uFByTkt3TxA@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Thu, Nov 1, 2012 at 2:50 PM, David Rientjes <rientjes@google.com> wrote:
> On Thu, 1 Nov 2012, Luigi Semenzato wrote:
>
>> > @@ -706,11 +693,11 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>> >                 return;
>> >
>> >         /*
>> > -        * If current has a pending SIGKILL, then automatically select it.  The
>> > -        * goal is to allow it to allocate so that it may quickly exit and free
>> > -        * its memory.
>> > +        * If current has a pending SIGKILL or is exiting, then automatically
>> > +        * select it.  The goal is to allow it to allocate so that it may
>> > +        * quickly exit and free its memory.
>> >          */
>> > -       if (fatal_signal_pending(current)) {
>> > +       if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
>> >                 set_thread_flag(TIF_MEMDIE);
>> >                 return;
>> >         }
>>
>> I tested this change with my load and it appears to also prevent the deadlocks.
>>
>> I have a question though.  I thought only one process was allowed to
>> be in TIF_MEMDIE state, but I don't see anything that prevents this
>> code (before or after the change) from setting the flag in multiple
>> processes.  Is this a problem?
>>
>
> The code you've quoted above, prior to being changed by the patch, allows
> any thread with a fatal signal to have access to memory reserves, so it's
> certainly not only one thread with TIF_MEMDIE set at a time (the oom
> killer is not the only thing that can kill a thread).  The goal of that
> code is to ensure anything that has been killed can allocate successfully
> wherever it happens to be running so that it can handle the signal, exit,
> and free its memory.  My patch is extending that for all threads that are
> in the exit path that happen to require memory to exit to prevent a
> livelock.

I see.  But then I am wondering: if there is no limit to the number of
threads that can access the reserved memory, then is it possible that
that memory will be exhausted?  Is the size of the reserved memory
based on heuristics then?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
