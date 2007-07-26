Received: by ug-out-1314.google.com with SMTP id c2so572165ugf
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 23:33:24 -0700 (PDT)
Message-ID: <2c0942db0707252333uc7631fduadb080193f6ad323@mail.gmail.com>
Date: Wed, 25 Jul 2007 23:33:24 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <20070725215717.df1d2eea.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au>
	 <2c0942db0707250909r435fef75sa5cbf8b1c766000b@mail.gmail.com>
	 <20070725215717.df1d2eea.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Eric St-Laurent <ericstl34@sympatico.ca>, Rene Herman <rene.herman@gmail.com>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/25/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 25 Jul 2007 09:09:01 -0700
> "Ray Lee" <ray-lk@madrabbit.org> wrote:
>
> > No, there's a third case which I find the most annoying. I have
> > multiple working sets, the sum of which won't fit into RAM. When I
> > finish one, the kernel had time to preemptively swap back in the
> > other, and yet it didn't. So, I sit around, twiddling my thumbs,
> > waiting for my music player to come back to life, or thunderbird,
> > or...
>
> Yes, I'm thinking that's a good problem statement and it isn't something
> which the kernel even vaguely attempts to address, apart from normal
> demand paging.
>
> We could perhaps improve things with larger and smarter fault readaround,
> perhaps guided by refault-rate measurement.  But that's still demand-paged
> rather than being proactive/predictive/whatever.
>
> None of this is swap-specific though: exactly the same problem would need
> to be solved for mmapped files and even plain old pagecache.

<nod> Could be what I'm noticing, but it's important to note that as
others have shown improvement with Con's swap prefetch, it's easily
arguable that targeting just swap is good enough for a first
approximation.

> In fact I'd restate the problem as "system is in steady state A, then there
> is a workload shift causing transition to state B, then the system goes
> idle.  We now wish to reinstate state A in anticipation of a resumption of
> the original workload".

Yes, that's a fair transformation / generalization. It's always nice
talking to someone with more clarity than one's self.

> swap-prefetch solves a part of that.
>
> A complete solution for anon and file-backed memory could be implemented
> (ta-da) in userspace using the kernel inspection tools in -mm's maps2-*
> patches.
> We would need to add a means by which userspace can repopulate
> swapcache,

Okay, let's run with that for argument's sake.

> but that doesn't sound too hard (especially when you haven't
> thought about it).

I've always thought your sense of humor was underappreciated.

> And userspace can right now work out which pages from which files are in
> pagecache so this application can handle pagecache, swap and file-backed
> memory.  (file-backed memory might not even need special treatment, given
> that it's pagecache anyway).

So in your proposed scheme, would userspace be polling, er, <goes and
looks through email for maps2 stuff, only finds Rusty's patches to
it>, well, /proc/<pids>/something_or_another?

A userspace daemon that wakes up regularly to poll a bunch of proc
files fills me with glee. Wait, is that glee? I think, no... wait...
horror, yes, horror is what I'm feeling.

I'm wrong, right? I love being wrong about this kind of stuff.

> And userspace can do a much better implementation of this
> how-to-handle-large-load-shifts problem, because it is really quite
> complex.  The system needs to be monitored to determine what is the "usual"
> state (ie: the thing we wish to reestablish when the transient workload
> subsides).  The system then needs to be monitored to determine when the
> exceptional workload has started, and when it has subsided, and userspace
> then needs to decide when to start reestablishing the old working set, at
> what rate, when to abort doing that, etc.

Oy. I mean this in the most respectful way possible, but you're too
smart for your own good.

I mean, sure, it's possible one could have multiply-chained transient
workloads each of which have their optimum workingset, of which
there's little overlap with the previous. Mainframes made their names
on such loads. Workingset A starts, generates data, finishes and
invokes workingset B, of which the only thing they share in common is
said data. B finishes and invokes C, etc.

So, yeah, that's way too complex to stuff into the kernel. Even if it
were possible to do so, I cringe at the thought. And I can't believe
that would be a common enough pattern nowadays to justify any
hueristics on anyone's part. It's certainly complex enough that I'd
like to punt that scenario out of the conversation entirely -- I think
it has the potential to give a false impression as to how involved of
a process we're talking about here.

Let's go back to your restatement:

> In fact I'd restate the problem as "system is in steady state A, then there
> is a workload shift causing transition to state B, then the system goes
> idle.  We now wish to reinstate state A in anticipation of a resumption of
> the original workload".

I'll take an 80% solution for that one problem, and happily declare
that the kernel's job is done. In particular, when a resource hog
exits (or whatever hueristics prefetch is currently hooking in to),
the kernel (or userspace, if that interface could be made sane) could
exercise a completely workload agnostic refetch of the last n things
evicted, where n is determined by what's suddenly become free (or
whatever Con came up with).

Just, y'know, MRU style.

> All this would end up needing runtime configurability and tweakability and
> customisability.  All standard fare for userspace stuff - much easier than
> patching the kernel.

We're talking about patching the kernel for whatever API you're coming
up with to repopulate pagecache, swap, and inodes, aren't we? If we
are, it doesn't seem like we're saving any work here. Also we're
talking about a creating a new user-visible API instead of augmenting
a pre-existing hueristic -- page replacement -- that the kernel
doesn't export and so can change at a moment's notice. Augmenting an
opaque hueristic seems a lot more friendly to long-term maintenance.

> So.  We can
>
> a) provide a way for userspace to reload pagecache and
>
> b) merge maps2 (once it's finished) (pokes mpm)
>
> and we're done?

Eh, dunno. Maybe?

We're assuming we come up with an API for userspace to get
notifications of evictions (without polling, though poll() would be
fine -- you know what I mean), and an API for re-victing those things
on demand. If you think that adding that API and maintaining it is
simpler/better than including a variation on the above hueristic I
offered, then yeah, I guess we are. It'll all have that vague
userspace s2ram odor about it, but I'm sure it could be made to work.

As I think I've successfully Peter Principled my way through this
conversation to my level of incompetence, I'll shut up now.

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
