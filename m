Received: by hu-out-0506.google.com with SMTP id 32so40746huf
        for <linux-mm@kvack.org>; Thu, 26 Jul 2007 00:43:05 -0700 (PDT)
Message-ID: <2c0942db0707260043h18d878baq9b3be72c01e2680a@mail.gmail.com>
Date: Thu, 26 Jul 2007 00:43:05 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <20070725235037.e59f30fc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au>
	 <2c0942db0707250909r435fef75sa5cbf8b1c766000b@mail.gmail.com>
	 <20070725215717.df1d2eea.akpm@linux-foundation.org>
	 <2c0942db0707252333uc7631fduadb080193f6ad323@mail.gmail.com>
	 <20070725235037.e59f30fc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Eric St-Laurent <ericstl34@sympatico.ca>, Rene Herman <rene.herman@gmail.com>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/25/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 25 Jul 2007 23:33:24 -0700 "Ray Lee" <ray-lk@madrabbit.org> wrote:
> > If you think that adding that API and maintaining it is
> > simpler/better than including a variation on the above hueristic I
> > offered, then yeah, I guess we are. It'll all have that vague
> > userspace s2ram odor about it, but I'm sure it could be made to work.
>
> Actually, I overdesigned the API, I suspect.  What we _could_ do is to
> provide a way of allowing userspace to say "pretend process A touched page
> B": adopt its mm and go touch the page.  We in fact already have that:
> PTRACE_PEEKTEXT.

Huh. All right.

> So I suspect this could all be done by polling maps2 and using PEEKTEXT.
> The tricky part would be working out when to poll, and when to reestablish.

Welllllll.... there is the taskstats interface. It's not required
right now, though, and lacks most of what userspace would need, I
think. It does at least currently provide a notification of process
exit, which is a clue for when to start reestablishment. Gotta be
another way we can get at that...

Oh, stat on /proc, does that work? Huh, it does, sort of. It seems to
be off by 12 or 13, but hey, that's something.

Wish I had the time to look at the maps2 stuff, but regardless, it
probably currently provides too much detail for continual polling? I
suspect what we'd want to do is to take a detailed snapshot a little
after the beginning of a process's lifetime (once the block-in counts
subside), then poll aggregate residency or evicition counts to know
which processes are suffering the burden of the transient workload.

Eh, wait, that doesn't help with inodes. No matter, I guess; I'm the
one who said targetting swap-in would be good enough for a first pass.

On process exit, if userspace can get a hold of an estimate of the
size of what just freed up, it could then spend
min(that,evicted_count) on repopulation. That's probably already
available by polling whatever `free` calls.

> A neater implementation than PEEKTEXT would be to make the maps2 files
> writeable(!) so as a party trick you could tar 'em up and then, when you
> want to reestablish firefox's previous working set, do a untar in
> /proc/$(pidof firefox)/

I'm going to get into trouble if I wake up the other person in the
house with my laughter. That's laughter in a positive sense, not a
"you're daft" kind of way.

Huh. <thinks> So, to go back a little bit, I guess one of my problems
with polling is that it means that userspace can only approximate an
MRU of what's been evicted. Perhaps an approximation is good enough, I
don't know, but that's something to keep in mind. (Hmm, how many pages
can an average desktop evict per second? If we poll everything once
per second, that's how off we could be.)

Another is a more philosophical hangup -- running a process that polls
periodically to improve system performance seems backward. Okay, so
that's my problem to get over, not yours.

Another problem is what poor sod would be willing to write and test
this, given that there's already a written and tested kernel patch to
do much the same thing? Yeah, that's sorta rhetorical, but it's sorta
not. Given that swap prefetch could be ripped out of 2.6.n+1 if it's
introduced in 2.6.n, and nothing in userspace would be the wiser,
where's the burden?  There is some, just as any kernel code has some,
and as it's core code (versus, say, a driver), the burden is
correspondingly greater per line, but given the massive changesets
flowing through each release now, I have to think that the burden this
introduces is marginal compared to the rest of the bulk sweeping
through the kernel weekly.

This is obviously where I'm totally conjecturing, and you'll know far,
far better than I.

Offline for about 20 hours or so, not that anyone would probably notice :-).

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
