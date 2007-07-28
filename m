From: Daniel Hazelton <dhazelton@enter.net>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Date: Fri, 27 Jul 2007 21:10:46 -0400
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <20070727231545.GA14457@atjola.homenet> <20070727232919.GA8960@one.firstfloor.org>
In-Reply-To: <20070727232919.GA8960@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200707272110.46860.dhazelton@enter.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: =?iso-8859-1?q?Bj=F6rn_Steinbrink?= <B.Steinbrink@gmx.de>, Rene Herman <rene.herman@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 27 July 2007 19:29:19 Andi Kleen wrote:
> > Any faults in that reasoning?
>
> GNU sort uses a merge sort with temporary files on disk. Not sure
> how much it keeps in memory during that, but it's probably less
> than 150MB. At some point the dirty limit should kick in and write back the
> data of the temporary files; so it's not quite the same as anonymous
> memory. But it's not that different given.

Yes, this should occur. But how many programs use temporary files like that? 
>From what I can tell FireFox and OpenOffice both keep all their data in 
memory, only using a single file for some buffering purposes. When they get 
pushed out by a memory hog (either short term or long term) it takes several 
seconds for them to be swapped back in. (I'm on a P4-1.3GHz machine with 1G 
of ram and rarely run more than four programs (Mail Client, XChat, FireFox 
and a console window) and I've seen this lag in FireFox when switching to it 
after starting OOo. I've also seen the same sort of lag when exiting OOo. 
I'll see about getting some numbers about this)

> It would be better to measure than to guess. At least Andrew's measurements
> on 128MB actually didn't show updatedb being really that big a problem.

I agree. As I've said previously, it isn't updatedb itself which causes the 
problem. It's the way the VFS cache seems to just expand and expand - to the 
point of evicting pages to make room for itself. However, I may be wrong 
about that - I haven't actually tested it for myself, just looked at the 
numbers and other information that has been posted in this thread.

> Perhaps some people have much more files or simply a less efficient
> updatedb implementation?

Yes, it could be the proliferation of files. It could also be some other sort 
of problem that is exposing a corner-case in the VFS cache or the MM. I, 
personally, am of the opinion that it is likely the aforementioned corner 
case for people reporting the "updatedb" problem. If it is, then 
swap-prefetch is just papering over the problem. However I do not have the 
knowledge and understanding of the subsystems involved to be able to do much 
more than make a (probably wrong) guess.

> I guess the people who complain here that loudly really need to supply
> some real numbers.

I've seen numerous "real numbers" posted about this. As was said earlier in 
the thread "every time numbers are posted they are claimed to be no good". 
But hey, nobodies perfect :)

Anyway, the discussion seems to be turning to the technical merits of 
swap-prefetch...

Now, a completely different question:
During the research (and lots of thinking) I've been doing while this thread 
has been going on I've often wondered why swap prefetch wasn't already in the 
kernel. The problem of slow swap-in has long been known, and, given current 
hardware, the optimal solution would be some sort of data prefetch - similar 
to what is done to speed up normal disk reads. Swap prefetch looks like it 
does exactly that. The algo could be argued over and/or improved (to suggest 
ways to do that I'd have to give it more than a 10 minute look) but it does 
provide a speed-up.

This speed increase will probably be enjoyed more by the home users, but the 
performance increase could also help on enterprise systems.

Now I'll be the first one to admit that there is a trade-off there - it will 
cause more power to be used because the disk's don't get a chance to spin 
down (or go through a cycle every time the prefetch system starts) but that 
could, potentially, be alleviated by having "laptop mode" switch it off.

(And no, I'm not claiming that it is perfect - but then, what is when its 
first merged into the kernel?)

DRH

-- 
Dialup is like pissing through a pipette. Slow and excruciatingly painful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
