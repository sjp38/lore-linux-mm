Received: from front2.grolier.fr (front2.grolier.fr [194.158.96.52])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA23051
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 17:58:14 -0500
Received: from sidney.remcomp.fr (ppp-106-121.villette.club-internet.fr [194.158.106.121])
	by front2.grolier.fr (8.9.0/MGC-980407-Frontal-No_Relay) with SMTP id XAA18611
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 23:57:58 +0100 (MET)
Date: 24 Nov 1998 21:44:32 -0000
Message-ID: <19981124214432.2922.qmail@sidney.remcomp.fr>
From: jfm2@club-internet.fr
In-reply-to: <199811241117.LAA06562@dax.scot.redhat.com> (sct@redhat.com)
Subject: Re: Two naive questions and a suggestion
References: <19981119002037.1785.qmail@sidney.remcomp.fr>
	<199811231808.SAA21383@dax.scot.redhat.com>
	<19981123215933.2401.qmail@sidney.remcomp.fr> <199811241117.LAA06562@dax.scot.redhat.com>
Sender: owner-linux-mm@kvack.org
To: sct@redhat.com
Cc: jfm2@club-internet.fr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> > The problem is: will you be able to manage the following situation?
> 
> > Two processes running in an 8 Meg box.  Both will page fault every ms
> > if you give them 4 Megs (they are scanning large arrays so no
> > locality), a page fault will take 20 ms to handle.  That means only 5%
> > of the CPU time is used, remainder is spent waiting for page being
> > brought from disk or pushing a page of the other process out of
> > memory.  And both of these processes would run like hell (no page
> > fault) given 6 Megs of memory.
> 
> These days, most people agree that in this situation your box is simply
> misconfigured for the load. :)  Seriously, requirements have changed
> enormously since swapping was first implemented.
> 
> > Only solution I see is stop one of them (short of adding memory :) and
> > let the other one make some progress.  That is swapping.  
> 
> No it is not.  That is scheduling.  Swapping is a very precise term used
> to define a mechanism by which we suspend a process and stream all of
> its internal state to disk, including page tables and so on.  There's no
> reason why we can't do a temporary schedule trick to deal with this in
> Linux: it's still not true swapping.
> 

Agreed, the important feature is the stopping one of the processes
when critically short of memory.  Swapping is only a trick for getting
more bandwidth at the expenses of pushing in an out of memory a
greater amount of process space so there is no proof it is faster than
letting other processes steal memory page by page from the now stopped
process.

> > In 96 I asked for that same feature, gave the same example (same
> > numbers :-) and Alan Cox agreed but told Linux was not used under
> > heavy loads. That means we are in a catch 22 situation: Linux not used
> > for heavy loads because it does not handle them well and the necessary
> > feaatures not implemented because it is not used in such situations.
> 
> Linux is used under very heavy load, actually.
> 

BSD and Solaris partisans are still boasting about how much better
those systems are at heavy loads.  I agree boasting tends to survive
to the situation who originated it.

> > And now we are at it: in 2.0 I found a deamon can be killed by the
> > system if it runs out of VM.  
> 
> Same on any BSD.  Once virtual memory is full, any new memory
> allocations must fail.  It doesn't matter whether that allocation comes
> from a user process or a daemon: if there is no more virtual memory then
> the process will get a NULL back from malloc.  If a daemon dies as a
> result of that, the death will happen on any Unix system.  
> 

Say the Web or database server can be deemed important enough for it
not being killed just because some dim witt is playing with the GIMP
at the console and the GIMP has allocated 80 Megs.

More reallistically, it can happen that the X server is killed
(-9) due to the misbeahviour of a user program and you get
trapped with a useless console.  Very diificult to recover.  Specially
if you consider inetd could have been killed too, so no telnetting.

You can also find half of your daemons, are gone.  That is no mail, no
printing, no nothing.

> > Problem is: it was a normal user process who had allocatedc most of it
> > and in addition that daemon could be important enough it is better to
> > kill anything else, so it would be useful to give some privilege to
> > root processes here.
> 
> No.  It's not an issue of the operating system killing processes.  It is
> an issue of the O/S failing a request for new memory, and a process
> exit()ing as a result of that failed malloc.  The process is voluntarily
> exiting, as far as the kernel is concerned.
> 

In situation like those above I would like Linux supported a concept
like guaranteed processses: if VM is exhausted by one of them then try
to get memory by killing non guaranteed processes and only kill the
original one if all reamining survivors are guaranteed ones.
It would be better for mission critical tasks.

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
