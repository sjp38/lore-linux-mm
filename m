From: Daniel Hazelton <dhazelton@enter.net>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Date: Fri, 27 Jul 2007 13:45:54 -0400
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net>
In-Reply-To: <1185531918.8799.17.camel@Homer.simpson.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707271345.55187.dhazelton@enter.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 27 July 2007 06:25:18 Mike Galbraith wrote:
> On Fri, 2007-07-27 at 03:00 -0700, Andrew Morton wrote:
> > On Fri, 27 Jul 2007 01:47:49 -0700 Andrew Morton 
<akpm@linux-foundation.org> wrote:
> > > More sophisticated testing is needed - there's something in
> > > ext3-tools which will mmap, page in and hold a file for you.
> >
> > So much for that theory.  afaict mmapped, active pagecache is immune to
> > updatedb activity.  It just sits there while updatedb continues munching
> > away at the slab and blockdev pagecache which it instantiated.  I assume
> > we're never getting the VM into enough trouble to tip it over the
> > start-reclaiming-mapped-pages threshold (ie: /proc/sys/vm/swappiness).
> >
> > Start the updatedb on this 128MB machine with 80MB of mapped pagecache,
> > it falls to 55MB fairly soon and then never changes.
> >
> > So hrm.  Are we sure that updatedb is the problem?  There are quite a few
> > heavyweight things which happen in the wee small hours.
>
> The balance in _my_ world seems just fine.  I don't let any of those
> system maintenance things run while I'm using the system, and it doesn't
> bother me if my working set has to be reconstructed after heavy-weight
> maintenance things are allowed to run.  I'm not seeing anything I
> wouldn't expect to see when running a job the size of updatedb.
>
> 	-Mike

Do you realize you've totally missed the point?

It isn't about what is fine in the Kernel Developers world, but what is fine 
in the *USERS* world. 

There are dozens of big businesses pushing Linux for Enterprise performance. 
Rather than discussing the merit of those patches - some of which just 
improve the performance of a specific application by 1 or 2  percent - they 
get a nod and go into the kernel. But when a group of users that don't 
represent one of those businesses says "Hey, this helps with problems I see 
on my system" there is a big discussion and ultimately those patches get 
rejected. Why? Because they'll give an example using a program that they see 
causing part of the problem and be told "Use program X - it does things 
differently and shouldn't cause the problem" or "But what causes the problem 
to happen? The patch treats a symptom of a larger problem".

The fucked up part of that is that the (mass of) kernel developers will see a 
similar report saying "mySQL has a performance problem because of X, this 
fixes it" and not blink twice - even if it is "treating the symptom and not 
the cause". It's this attitude more than anything that caused Con 
to "retire" - at least that is the impression I got from the interviews he's 
given. (The exact impression was "I'm sick of the kernel developers doing 
everything they can to help enterprise users and ignoring the home users")

So...
The problem:
Updatedb or another process that uses the FS heavily runs on a users 256MB 
P3-800 (when it is idle) and the VFS caches grow, causing memory pressure 
that causes other applications to be swapped to disk. In the morning the user 
has to wait for the system to swap those applications back in.

Questions about it:
Q) Does swap-prefetch help with this? 
A) [From all reports I've seen (*)] Yes, it does. 

Q) Why does it help? 
A) Because it pro-actively swaps stuff back-in when the memory pressure that 
caused it to be swapped out is gone. 

Q) What causes the problem? 
A) The VFS layer not keeping a limited cache. Instead the VFS will chew 
through available memory in the name of "increasing performance".

Solution(s) to the problem:
1) Limit the amount of memory the pagecache and other VFS caches can consume
2) Implement swap prefetch

If I had a (more) complete understanding of how the VFS cache(s) work I'd try 
to code a patch to do #1 myself. Patches to do #2 already exist and have been 
shown to work for the users that have tried it. My question is thus, simply: 
What is the reason that it is argued against?(**)

DRH
PS: Yes, I realize I've repeated some people from earlier in this thread, but 
it seems that people have been forgetting the point.

(*) I've followed this thread and all of its splinters. The reports that are 
in them, where the person making the report has a system that has the limited 
memory needed for the problem to exhibit itself, all show that swap-prefetch 
helps.

(**) No, I won't settle for "Its treating a symptom". The fact is that this 
isn't a *SYMPTOM* of anything. It treats the cause of the lag the users that 
have less than (for the sake of argument) 1G of memory are seeing. And no, 
changing userspace isn't a solution - updatedb may be the program that has 
been used as an example, but there are others. The proper fix is to change 
the kernel to either make the situation impossible (limit the VFS and other 
kernel caches) or make the situation as painless as possible (implement swap 
prefetch to alleviate the lag of swapping data back in).

-- 
Dialup is like pissing through a pipette. Slow and excruciatingly painful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
