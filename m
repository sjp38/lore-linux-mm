From: jfm2@club-internet.fr
In-reply-to: <Pine.LNX.4.10.10010271832020.13084-100000@dax.joh.cam.ac.uk>
	(message from James Sutherland on Fri, 27 Oct 2000 18:36:13 +0100
	(BST))
Subject: Re: Discussion on my OOM killer API
References: <Pine.LNX.4.10.10010271832020.13084-100000@dax.joh.cam.ac.uk>
Message-Id: <20001027221259.C0ED4F42C@agnes.fremen.dune>
Date: Sat, 28 Oct 2000 00:12:59 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jas88@cam.ac.uk
Cc: ingo.oeser@informatik.tu-chemnitz.de, riel@conectiva.com.br, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Fri, 27 Oct 2000, Ingo Oeser wrote:
> 
> > On Fri, Oct 27, 2000 at 12:58:44AM +0100, James Sutherland wrote:
> > > Which begs the question, where did the userspace OOM policy daemon go? It,
> > > coupled with Rik's simple in-kernel last-ditch handler, should cover most
> > > eventualities without the need for nasty kernel kludges.
> > 
> > If I do the full blown variant of my patch: 
> > 
> > echo "my-kewl-oom-killer" >/proc/sys/vm/oom_handler
> > 
> > will try to load the module with this name for a new one and
> > uninstall the old one.
> 
> EBADIDEA. The kernel's OOM killer is a last ditch "something's going to
> die - who's first?" - adding extra bloat like this is BAD.
> 
> Policy should be decided user-side, and should prevent the kernel-side
> killer EVER triggering.
> 

Only problem is that your user side process will have been pushed out
of memory by netcape and that in this kind of situations it will take
a looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong
time to be recalled from swap and it being able to kill anything.
Well before it comes back netscape will have eaten all remaining
memory so kernel will have to decide by itself.

Only solution is to allow the OOM never to be swapped but you also
need all libraries to remain in memory or have the kernel check OOM is
statically linked.  However this user space OOM will then have a
sigificantly memory larger footprint than a kernel one and don't
forget it cannot be swapped.

> > The original idea was an simple "I install a module and lock it
> > into memory" approach[1] for kernel hackers, which is _really_
> > easy to to and flexibility for nothing[2].
> > 
> > If the Rik and Linus prefer the user-accessable variant via
> > /proc, I'll happily implement this.
> > 
> > I just intended to solve a "religious" discussion via code
> > instead of words ;-)
> 
> I was planning to implement a user-side OOM killer myself - perhaps we
> could split the work, you do kernel-side, I'll do the userspace bits?
> 

Hhere is an heuristic who tends to work well ;-)

if (short_on_memory == TRUE )  {
     kill_all_copies_of_netscape()
}

-- 
			Jean Francois Martinez


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
