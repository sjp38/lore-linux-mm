Date: Tue, 10 Oct 2000 15:17:49 +0200 (CEST)
From: Marco Colombo <marco@esi.it>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.10.10010091443020.1438-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010101450030.970-100000@Megathlon.ESI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Linus Torvalds wrote:

> On Mon, 9 Oct 2000, Rik van Riel wrote:
> >
> > > I'd prefer just X having a higher "mm nice level" or something.
> > 
> > Which it has, because:
> > 
> > 1) CAP_RAW_IO
> > 2) p->euid == 0
> 
> Oh, I agree, but we might want to generalize this a bit so that root could
> say "this process is important" and then drop root privileges and still
> get "credited" for the fact that it's important.
> 
> It's not a big deal. It works for X right now.

How about using

	p->rlim[RLIMIT_AS].rlim_cur

to weight the badness point for a process?
On my system, a 128MB RAM + 256MB swap, it defaults to some (insane?) value:

bash$ ulimit -vH -vS
virtual memory (kbytes)  4194302
virtual memory (kbytes)  2105343

for every process, which just means it is unused.

The idea is:
1) set default for rlim[RLIMIT_AS].rlim_max to a saner value;
2) processes with higher rlim[RLIMIT_AS].rlim_cur get lower badness.

This way, the badness of a process is not proportional to its absolute
size, but to the fraction of allowed AS it is using. Processes
that are capable(CAP_SYS_RESOURCE) can set RLIMIT_AS to a very high value,
so they get less badness point. X is a perfect candidate.

User's runaway processes (netscape) will have lower rlim[RLIMIT_AS].rlim_cur,
thus will get higher badness.

Something like:

-	points = p->mm->total_vm;
+	points = p->mm->total_vm / (p->rlim[RLIMIT_AS].rlim_cur << AS_FACTOR);

with

#define AS_FACTOR 30

maybe? (this is Rik's call, he knows better than me how to balance it...)

It's simple, it's configurable. 1) may be enforced by the kernel, or
completely left to user space.
On my system, in its default configuration (no use of RLIMIT_AS),
it has no impact at all (all processes have the same limit).

Sounds good or am I missing something?

> 
> 		Linus
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> Please read the FAQ at http://www.tux.org/lkml/
> 

.TM.
-- 
      ____/  ____/   /
     /      /       /			Marco Colombo
    ___/  ___  /   /		      Technical Manager
   /          /   /			 ESI s.r.l.
 _____/ _____/  _/		       Colombo@ESI.it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
