Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA31969
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 02:35:21 -0500
Date: Thu, 26 Nov 1998 08:16:04 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <19981125200140.1226.qmail@sidney.remcomp.fr>
Message-ID: <Pine.LNX.3.96.981126080204.24048J-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: jfm2@club-internet.fr
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 25 Nov 1998 jfm2@club-internet.fr wrote:

> > I sounds remarkably like you want my Out Of Memory killer
> > patch. This patch tries to remove the randomness in killing
> > a process when you're OOM by carefully selecting a process
> > based on a lot of different factors (size, age, CPU used,
> > suid, root, IOPL, etc).
> 
> Your scheme is (IMHO) far too complicated and (IMHO) falls short. 
> The problem is that the kernel has no way to know what is the really
> important process in the box. 

In my (and other people's) experience, an educated guess is
better than a random kill. Furthermore it is not possible to
get out of the OOM situation without killing one or more
processes, so we want to limit:
- the number of processes we kill (reducing the chance of
  killing something important)
- the CPU time 'lost' when we kill something (so we don't
  have to run that simulation for two weeks again)
- the risk of killing something important and stable, we
  try to avoid this by giving less hitpoints to older
  processes (which presumably are stable and take a long
  time to 'recreate' the state in which they are now)
- the amount of work lost -- killing new processes that
  haven't used much CPU is a way of doing this
- the probability of the machine hanging -- don't kill
  IOPL programs and limit the points for old daemons
  and root/suid stuff

Granted, we can never make a perfect guess. It will be a
lot better than a more or less random kill, however.

The large simulation that's taking 70% of your RAM and
has run for 2 weeks is the most likely victim under our
current scheme, but with my killer code it's priority
will be far less that that of a newly-started and exploded
GIMP or Netscape...

> Why not simply allow a root-owned process declare itself (and the
> program it will exec into) as "guaranteed"? 

If the guaranteed program explodes it will kill the machine.
Even for single-purpose machines this will be bad since it
will increase the downtime with a reboot&fsck cycle instead
of just a program restart.

> Or a box used as a mail server using qmail: qmail starts sub-servers
> each one for a different task. 

The children are younger and will be killed first. Starting
the master server from init will make sure that it is
restarted in the case of a real emergency or fluke.

> Of course this is only a suugestion for a mechanism but the important
> is allowing a human to have the final word.

What? You have a person sitting around keeping an eye on
your mailserver 24x7? Usually the most important servers
are tucked away in a closet and crash at 03:40 AM when
the sysadmin is in bed 20 miles away...

The kernel is there to prevent Murphy from taking over :)

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
