Message-ID: <39AE4647.8A7AAADC@tuke.sk>
Date: Thu, 31 Aug 2000 13:49:27 +0200
From: Jan Astalos <astalos@tuke.sk>
MIME-Version: 1.0
Subject: Re: Question: memory management and QoS
References: <Pine.LNX.4.21.0008301237171.8164-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Yuri Pudgorodsky <yur@asplinux.ru>, Andrey Savochkin <saw@saw.sw.com.sg>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Wed, 30 Aug 2000, Jan Astalos wrote:
> > Rik van Riel wrote:
> 
> > > I think we can achieve the same thing, with higher over-all
> > > system performance, if we simply give each user a VM quota
> > > and do the bookkeeping on a central swap area.
> >
> > Sorry, As a user I wouldn't care a bit about overall system
> > performance... I would care only if I can get the service I
> > has paid for.
> 
> *sigh*
> 
> It's not always /you/ who is out drinking coffee. The other
> users will be drinking coffee too some of the time, and when
> they are out drinking coffee you'll have the extra performance
> they're not using at that moment.
> 
> Oh wait ... you didn't pay for it so you don't want it. ;)

If the extra performance means loss of reliability then the answer
is no. Also, if I have to schedule 1000+ pieces of distributed
app and cannot count with the extra performance the answer is
no as well.

But back to your coffee drinking example. I think, that swapping
out of idle programs could lead to serious problems with interactive 
performance. Ok, not every program needs it, but IMO it would be
much more convenient for user to have some screensaver (or better
- moneysaver) which would suspend all his processes and return
physical memory (temporarily) back to the system. Or to allow
user to switch (use my free/all memory/don't use my memory).

> 
> > > The reasons for this are multiple:
> > > 1) having one swap partition will reduce disk seeks
> > >    (no matter how you put it, disk seeks are a _system_
> > >    thing, not a per user thing)
> >
> > I would be happy if you said that "we can guarantee that pages
> > of one process will be swapped to compact swap area". Reading
> > the code I didn't get that impression...
> 
> That's because it's not implemented yet. But I definately plan
> to have better swap clustering for Linux 2.5.

Can you share some ideas how it will look like ? 

> 
> > I didn't tested it (I always thought it's obvious) that
> > storing a bunch of pages to and get another bunch from the
> > same cylinder is _much_ faster than getting pages scattered
> > over large disk space (maybe in different order) forcing
> > disk heads to jump like mad.
> 
> It is. Unfortunately you won't be able to swap one thing in
> without swapping OUT something else. This is why you really
> really want to have the swap for all users in the same place
> on disk.

Why user that needs to swap something in should swap out
the pages from another user ? Why not to get the LRU pages of
that user and get the bunch of readahead pages from the (relatively)
small swap area ? As Yuri has pointed out it's not that new idea...

> 
> > > 2) not all users are logged in at the same time, so you
> > >    can do a minimal form of overcomitting here (if you want)
> >
> > Overcommitting of what ? Virtual memory ?
> 
> Yes. If you sell resources to 10.000 users, there's usually no
> need to have 10.000 times the maximum per-user quota for every
> system resource.
> 
> Instead, you sell each user a guaranteed resource with the
> possibility to go up to a certain maximum. That way you can give
> your users a higher quality of service for much lower pricing,
> only with 99.999% guarantee instead of 100%.

You're right, I was shortsighted... ;).
 
> > Killing is bad (in general). By killing a process just to step
> > outside of guaranteed quota may waste all resources consumed
> > by killed process (including CPU time). Not saying that it's
> > quite inconvenient for users.
> 
> Of course it's inconvenient, but it should be far less inconvenient
> than paying 10 times more for their quota on the system because they
> want everything to be guaranteed.
> 
> The difference between 99.99% and 99.999% usually isn't worth a
> 10-fold increase in price for most things.

Sometimes is. If you would have 1000 pieces, the probability that whole
app would fail is 1% which is still quite high if you consider consumed 
resources and money spent. And if just putting of some additional
swap area (inside otherwise unused disk quota) would make the 
guarantee rock solid it is certainly worth it. 
(Welcome to grid computing ;).

> 
> >  - reliability: system would prevent me from consuming more resources
> >                 than I have. Especially the amount of requested
> >                 VM can change over time.
> 
> That's an administrative decision. IMHO it would be a big mistake
> to hardcode this in the OS.

How about to allow user to switch whether he needs to be limited by 
VM guarantee or not...

If you will add some per_user_clustering into swap, it will certainly 
perform better than per user swap files. But administration costs 
would be still equally high. Not saying that if user needs reliable 
service and system is not able to increase his guarantee (lack of 
resources), user has to wait -> lower interactive performance. 
Which will lead to batch queuing system.

Even with per user clustered swapfile, personal swapfiles still could
get rid of low variations in user VM needs. Argument that they will waste
disk space I can't accept. User can still mmap file for extending his
VM memory. From this angle, personal swapfiles would be just an extra
feature provided by system for non-developpers...

Regards,

Jan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
