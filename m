Received: from front2.grolier.fr (front2.grolier.fr [194.158.96.52])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA02836
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 15:24:53 -0500
Received: from sidney.remcomp.fr (ppp-105-3.villette.club-internet.fr [194.158.105.3])
	by front2.grolier.fr (8.9.0/MGC-980407-Frontal-No_Relay) with SMTP id VAA13016
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 21:24:49 +0100 (MET)
Date: 26 Nov 1998 19:59:42 -0000
Message-ID: <19981126195942.1431.qmail@sidney.remcomp.fr>
From: jfm2@club-internet.fr
In-reply-to: <Pine.LNX.3.96.981126080204.24048J-100000@mirkwood.dummy.home>
	(message from Rik van Riel on Thu, 26 Nov 1998 08:16:04 +0100 (CET))
Subject: Re: Two naive questions and a suggestion
References: <Pine.LNX.3.96.981126080204.24048J-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@phys.uu.nl
Cc: jfm2@club-internet.fr, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> On 25 Nov 1998 jfm2@club-internet.fr wrote:
> 
> > > I sounds remarkably like you want my Out Of Memory killer
> > > patch. This patch tries to remove the randomness in killing
> > > a process when you're OOM by carefully selecting a process
> > > based on a lot of different factors (size, age, CPU used,
> > > suid, root, IOPL, etc).
> > 
> > Your scheme is (IMHO) far too complicated and (IMHO) falls short. 
> > The problem is that the kernel has no way to know what is the really
> > important process in the box. 
> 
> In my (and other people's) experience, an educated guess is
> better than a random kill. Furthermore it is not possible to
> get out of the OOM situation without killing one or more
> processes, so we want to limit:
> - the number of processes we kill (reducing the chance of
>   killing something important)
> - the CPU time 'lost' when we kill something (so we don't
>   have to run that simulation for two weeks again)
> - the risk of killing something important and stable, we
>   try to avoid this by giving less hitpoints to older
>   processes (which presumably are stable and take a long
>   time to 'recreate' the state in which they are now)
> - the amount of work lost -- killing new processes that
>   haven't used much CPU is a way of doing this
> - the probability of the machine hanging -- don't kill
>   IOPL programs and limit the points for old daemons
>   and root/suid stuff
> 
> Granted, we can never make a perfect guess. It will be a
> lot better than a more or less random kill, however.
> 
> The large simulation that's taking 70% of your RAM and
> has run for 2 weeks is the most likely victim under our
> current scheme, but with my killer code it's priority
> will be far less that that of a newly-started and exploded
> GIMP or Netscape...
> 

My idea was:

-VM exhausted and process allocating is a normal process then kill
 process.

 -VM exhausted and process is a guaranteed one then kill a non
 guaranteed process.

-VM exhausted, process is guaranteed but only remaining processes are
 guaranteed ones.  Kill allocated process.

Of course INIT is guaranteed.

> > Why not simply allow a root-owned process declare itself (and the
> > program it will exec into) as "guaranteed"? 
> 
> If the guaranteed program explodes it will kill the machine.
> Even for single-purpose machines this will be bad since it
> will increase the downtime with a reboot&fsck cycle instead
> of just a program restart.
> 

Nope see higher.  The guaranteed program would be killed once
"unimportant" processes have been killed.  The goal is not to allow
impunity to guaranteed programs but to protect an important program
against possible misbehaviour of other programs: a misbehaving process
who has allocated all the VM except 1 page and then our database
server tries to allocate two more pages.

> > Or a box used as a mail server using qmail: qmail starts sub-servers
> > each one for a different task. 
> 
> The children are younger and will be killed first. Starting
> the master server from init will make sure that it is
> restarted in the case of a real emergency or fluke.
> 
> > Of course this is only a suugestion for a mechanism but the important
> > is allowing a human to have the final word.
> 
> What? You have a person sitting around keeping an eye on
> your mailserver 24x7? Usually the most important servers
> are tucked away in a closet and crash at 03:40 AM when
> the sysadmin is in bed 20 miles away...
> 

No.  The sysadmin uses emacs at normal hours to edit a file telling
what are the important processes.  Now it is to you to find a scheme
in order the sysadmin's wishes are communicated to the kernel.  :-)

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
