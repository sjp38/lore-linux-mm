Message-ID: <39ACB9E6.4914CB89@tuke.sk>
Date: Wed, 30 Aug 2000 09:38:14 +0200
From: Jan Astalos <astalos@tuke.sk>
MIME-Version: 1.0
Subject: Re: Question: memory management and QoS
References: <Pine.LNX.4.21.0008281421180.18553-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Andrey Savochkin <saw@saw.sw.com.sg>, Yuri Pudgorodsky <yur@asplinux.ru>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Mon, 28 Aug 2000, Jan Astalos wrote:
> 
> > I still claim that per user swapfiles will:
> > - be _much_ more efficient in the sense of wasting disk space (saving money)
> >   because it will teach users efficiently use their memory resources (if
> >   user will waste the space inside it's own disk quota it will be his own
> >   problem)
> > - provide QoS on VM memory allocation to users (will guarantee amount of
> >   available VM for user)
> > - be able to improve _per_user_ performance of system (localizing performance
> >   problems to users that caused them and reducing disk seek times)
> > - shift the problem with OOM from system to user.
> 
> Do you have any reasons for this, or are you just asserting
> them as if they were fact? ;)
> 
> I think we can achieve the same thing, with higher over-all
> system performance, if we simply give each user a VM quota
> and do the bookkeeping on a central swap area.

Sorry, As a user I wouldn't care a bit about overall system 
performance... I would care only if I can get the service I 
has paid for.

> 
> The reasons for this are multiple:
> 1) having one swap partition will reduce disk seeks
>    (no matter how you put it, disk seeks are a _system_
>    thing, not a per user thing)

I would be happy if you said that "we can guarantee that pages
of one process will be swapped to compact swap area". Reading
the code I didn't get that impression...

I didn't tested it (I always thought it's obvious) that
storing a bunch of pages to and get another bunch from the
same cylinder is _much_ faster than getting pages scattered
over large disk space (maybe in different order) forcing
disk heads to jump like mad. If you have tested it and can send
me your results, please, do it. I may be wrong, nobody's perfect. :-)
Technology changes, maybe disks have changed too...

> 2) not all users are logged in at the same time, so you
>    can do a minimal form of overcomitting here (if you want)

Overcommitting of what ? Virtual memory ? 

> 3) you can easily give users _2_ VM quotas, a guaranteed one
>    and a maximum one ... if a user goes over the guaranteed
>    quota, processes can be killed in OOM situations
>    (this allows each user to make their own choices wrt.
>    overcommitment)

What if user "suddenly" realizes that his guaranteed quota 
is not sufficient. Checkpoint ? Immediately contact sysadmin ?

Killing is bad (in general). By killing a process just to step
outside of guaranteed quota may waste all resources consumed
by killed process (including CPU time). Not saying that it's
quite inconvenient for users. (thrashing, stealing, killing
I wonder what's the most appropriate name for MM ;)

What I'd like to have are per user guarantees for:
 - performance: no one will use physical memory allocated to me.
                No matter whether I'm drinking coffee or not.
                Waiting for system to swap-in/out pages that I have
                paid for is absolutely unacceptable performance
                drop. (I may not be drinking coffee, my app
                may be just waiting for input from its other
                part located anywhere else).
 - reliability: system would prevent me from consuming more resources
                than I have. Especially the amount of requested
                VM can change over time.

Only if I ask, system will overcommit my VM memory. Then I should do
checkpointing (if I'm able to do it and accept performance drop). 
Overcommitting of physical memory up to VM guarantee is obviously desired.
Only if I allow others to use my unused memory, they would be allowed
to. This can be motivated by different charging policies.
No page stealing (just lending and reclaiming).

Yes. This can be done with one big swapfile. But I tried to imagine
how such system would be administered. And what would be the scalability
of that administration. I got a sysadmin nightmare...
- users should be charged for guarantied amount of VM.
  Otherwise they would have maximal requirements -> wasted resources
- the requirements could vary quite deeply (user to user and also by time)
- sysadmin (or more likely his MM agent) will have to schedule users
  to resources by their (changing) requirements and should take care
  about not to guarantee more than he actually can. As I said, user may
  know his VM needs only when he decides to run his app with
  desired arguments.

Consider the maintenance costs in the case of per user swapfiles.
Maybe they waste disk space when user is not logged in, but that's
user's own disk space. He can do anything he like with it, right ? (QoS).
(It could be used for storing of some persistent IPC objects...)

Maybe I'm only one with this view about memory QoS, but this can be solved only
putting both solutions to users/sysadmins/managers and see what will happen...
I'm far from claiming that per user swapfiles will be appropriate for
all situations. So don't look at it as I would claim that anyone with different
opinion is stupid. Everyone tends to bound his solution to concrete problem
he has to solve. And seeing how my solution will fit to the requirements of other
people is always helpful. I'm always willing to learn new things...

I certainly will implement my approach (in fact the most important
part is more or less done by Andrey (thanks). If for nothing else, then just for
seeing how it will perform. Look at it as at different approach to swap clustering.
My main intention is to get the list of potential implementation pitfalls that can 
arise. Thanks.

Regards,

Jan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
