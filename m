Date: Wed, 30 Aug 2000 13:53:09 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Question: memory management and QoS
In-Reply-To: <39ACB9E6.4914CB89@tuke.sk>
Message-ID: <Pine.LNX.4.21.0008301237171.8164-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Astalos <astalos@tuke.sk>
Cc: Andrey Savochkin <saw@saw.sw.com.sg>, Yuri Pudgorodsky <yur@asplinux.ru>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Aug 2000, Jan Astalos wrote:
> Rik van Riel wrote:

> > I think we can achieve the same thing, with higher over-all
> > system performance, if we simply give each user a VM quota
> > and do the bookkeeping on a central swap area.
> 
> Sorry, As a user I wouldn't care a bit about overall system 
> performance... I would care only if I can get the service I 
> has paid for.

*sigh*

It's not always /you/ who is out drinking coffee. The other
users will be drinking coffee too some of the time, and when
they are out drinking coffee you'll have the extra performance
they're not using at that moment.

Oh wait ... you didn't pay for it so you don't want it. ;)

> > The reasons for this are multiple:
> > 1) having one swap partition will reduce disk seeks
> >    (no matter how you put it, disk seeks are a _system_
> >    thing, not a per user thing)
> 
> I would be happy if you said that "we can guarantee that pages
> of one process will be swapped to compact swap area". Reading
> the code I didn't get that impression...

That's because it's not implemented yet. But I definately plan
to have better swap clustering for Linux 2.5.

> I didn't tested it (I always thought it's obvious) that
> storing a bunch of pages to and get another bunch from the
> same cylinder is _much_ faster than getting pages scattered
> over large disk space (maybe in different order) forcing
> disk heads to jump like mad.

It is. Unfortunately you won't be able to swap one thing in
without swapping OUT something else. This is why you really
really want to have the swap for all users in the same place
on disk.

> > 2) not all users are logged in at the same time, so you
> >    can do a minimal form of overcomitting here (if you want)
> 
> Overcommitting of what ? Virtual memory ? 

Yes. If you sell resources to 10.000 users, there's usually no
need to have 10.000 times the maximum per-user quota for every
system resource.

Instead, you sell each user a guaranteed resource with the
possibility to go up to a certain maximum. That way you can give
your users a higher quality of service for much lower pricing,
only with 99.999% guarantee instead of 100%.

> > 3) you can easily give users _2_ VM quotas, a guaranteed one
> >    and a maximum one ... if a user goes over the guaranteed
> >    quota, processes can be killed in OOM situations
> >    (this allows each user to make their own choices wrt.
> >    overcommitment)
> 
> What if user "suddenly" realizes that his guaranteed quota 
> is not sufficient. Checkpoint ? Immediately contact sysadmin ?

That's up to the user. In general the system resources between
the guaranteed and the maximum quota should be fairly reliable
(say, 99.99%). If the user really needs better than that, (s)he
should buy more guaranteed quota...

> Killing is bad (in general). By killing a process just to step
> outside of guaranteed quota may waste all resources consumed
> by killed process (including CPU time). Not saying that it's
> quite inconvenient for users.

Of course it's inconvenient, but it should be far less inconvenient
than paying 10 times more for their quota on the system because they
want everything to be guaranteed.

The difference between 99.99% and 99.999% usually isn't worth a
10-fold increase in price for most things.

> What I'd like to have are per user guarantees for:
>  - performance: no one will use physical memory allocated to me.

So for /your/ system, you set the guaranteed and the maximum quota
to the same value and have your users pay the 10-fold extra in
price. If you can get any customers with that pricing, of course...

>                 Waiting for system to swap-in/out pages that I have
>                 paid for is absolutely unacceptable performance
>                 drop. (I may not be drinking coffee, my app
>                 may be just waiting for input from its other
>                 part located anywhere else).

"Its other part" may benefit a lot from being able to use some
extra physical memory by having something idle swapped out.

>  - reliability: system would prevent me from consuming more resources
>                 than I have. Especially the amount of requested
>                 VM can change over time.

That's an administrative decision. IMHO it would be a big mistake
to hardcode this in the OS.

Also, you should remember that the overall system performance is
an upper limit on the sum of per-user performance. Without good
overall performance, you cannot support either a lot of users or
good performance per user. This should most likely make it worth
it to keep overall system performance in mind even when you're
doing QoS things...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
