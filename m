From: Daniel Hazelton <dhazelton@enter.net>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Date: Fri, 27 Jul 2007 16:28:46 -0400
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com>
In-Reply-To: <46AA3680.4010508@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707271628.46804.dhazelton@enter.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 27 July 2007 14:16:32 Rene Herman wrote:
> On 07/27/2007 07:45 PM, Daniel Hazelton wrote:
> > Updatedb or another process that uses the FS heavily runs on a users
> > 256MB P3-800 (when it is idle) and the VFS caches grow, causing memory
> > pressure that causes other applications to be swapped to disk. In the
> > morning the user has to wait for the system to swap those applications
> > back in.
> >
> > Questions about it:
> > Q) Does swap-prefetch help with this?
> > A) [From all reports I've seen (*)] Yes, it does.
>
> No it does not. If updatedb filled memory to the point of causing swapping
> (which noone is reproducing anyway) it HAS FILLED MEMORY and swap-prefetch
> hasn't any memory to prefetch into -- updatedb itself doesn't use any
> significant memory.

Check the attitude at the door then re-read what I actually said:
> > Updatedb or another process that uses the FS heavily runs on a users
> > 256MB P3-800 (when it is idle) and the VFS caches grow, causing memory
> > pressure that causes other applications to be swapped to disk. In the
> > morning the user has to wait for the system to swap those applications
> > back in.

I never said that it was the *program* itself - or *any* specific program (I 
used "Updatedb" because it has been the big name in the discussion) - doing 
the filling of memory. I actually said that the problem is that the kernel's 
caches - VFS and others - will grow *WITHOUT* *LIMIT*, filling all available 
memory. 

Swap prefetch on its own will not alleviate *all* of the problem, but it 
appears to fix enough of it that the problem doesn't seem to bother people 
anymore. (As I noted later on there are things that can be changes that would 
also fix things. Those changes, however, are quite tricky and involve changes 
to the page faulting mechanism, the way the various caches work and a number 
of other things)

In light of the fact that swap prefetch appears to solve the problem for the 
people that have been vocal about it, and because it is a less intrusive 
change than the other potential solutions, I'd like to know why all the 
complaints and arguments against it come down to "Its treating the symptom".

I mean it - because I fail to see how it isn't getting at the root of the 
problem - which is, pretty much, that Swap has classically been and, in the 
case of most modern systems, still is damned slow. By prefetching those pages 
that have most recently been evicted the problem of "slow swap" is being 
directly addressed.

You want to know what causes the problem? The current design of the caches. 
They will extend without much limit, to the point of actually pushing pages 
to disk so they can grow even more. 

> Here's swap-prefetch's author saying the same:
>
> http://lkml.org/lkml/2007/2/9/112
>
> | It can't help the updatedb scenario. Updatedb leaves the ram full and
> | swap prefetch wants to cost as little as possible so it will never
> | move anything out of ram in preference for the pages it wants to swap
> | back in.
>
> Now please finally either understand this, or tell us how we're wrong.
>
> Rene.

I already did. You completely ignored it because I happened to use the magic 
words "updatedb" and "swap prefetch". 

Did I ever say it was about "updatedb" in particular? You've got the statement 
in the part of my post that you quoted. Nope, appears that I used the name as 
a specific example - and one that has been used previously in the thread. Now 
drop the damned attitude and start using your brain. Okay?

DRH

-- 
Dialup is like pissing through a pipette. Slow and excruciatingly painful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
