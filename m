Date: Fri, 27 Oct 2000 23:11:11 +0100 (BST)
From: James Sutherland <jas88@cam.ac.uk>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <20001027221259.C0ED4F42C@agnes.fremen.dune>
Message-ID: <Pine.LNX.4.10.10010272309040.17292-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jfm2@club-internet.fr
Cc: ingo.oeser@informatik.tu-chemnitz.de, riel@conectiva.com.br, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 28 Oct 2000 jfm2@club-internet.fr wrote:

> > 
> > On Fri, 27 Oct 2000, Ingo Oeser wrote:
> > 
> > > On Fri, Oct 27, 2000 at 12:58:44AM +0100, James Sutherland wrote:
> > > > Which begs the question, where did the userspace OOM policy daemon go? It,
> > > > coupled with Rik's simple in-kernel last-ditch handler, should cover most
> > > > eventualities without the need for nasty kernel kludges.
> > > 
> > > If I do the full blown variant of my patch: 
> > > 
> > > echo "my-kewl-oom-killer" >/proc/sys/vm/oom_handler
> > > 
> > > will try to load the module with this name for a new one and
> > > uninstall the old one.
> > 
> > EBADIDEA. The kernel's OOM killer is a last ditch "something's going to
> > die - who's first?" - adding extra bloat like this is BAD.
> > 
> > Policy should be decided user-side, and should prevent the kernel-side
> > killer EVER triggering.
> > 
> 
> Only problem is that your user side process will have been pushed out
> of memory by netcape and that in this kind of situations it will take
> a looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong
> time to be recalled from swap and it being able to kill anything.

Ehm... nope. mlockall().

> Well before it comes back netscape will have eaten all remaining
> memory so kernel will have to decide by itself.

Ehm... nope. My process is locked in physical memory, and has realtime
priority: once my daemon decides to go into action, Netscape doesn't get
any more memory, CPU time or anything else, just a quick SIGKILL.

> Only solution is to allow the OOM never to be swapped but you also
> need all libraries to remain in memory or have the kernel check OOM is
> statically linked.  However this user space OOM will then have a
> sigificantly memory larger footprint than a kernel one and don't
> forget it cannot be swapped.

Not necessarily "significantly larger"; it can be small and simple without
using any libraries.

> > > The original idea was an simple "I install a module and lock it
> > > into memory" approach[1] for kernel hackers, which is _really_
> > > easy to to and flexibility for nothing[2].
> > > 
> > > If the Rik and Linus prefer the user-accessable variant via
> > > /proc, I'll happily implement this.
> > > 
> > > I just intended to solve a "religious" discussion via code
> > > instead of words ;-)
> > 
> > I was planning to implement a user-side OOM killer myself - perhaps we
> > could split the work, you do kernel-side, I'll do the userspace bits?
> > 
> 
> Hhere is an heuristic who tends to work well ;-)
> 
> if (short_on_memory == TRUE )  {
>      kill_all_copies_of_netscape()
> }

Yes, that's a good start. Now we've done that, but we're still OOM, what
do you kill next?


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
