Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7529C6B003D
	for <linux-mm@kvack.org>; Sun,  5 Apr 2009 13:23:44 -0400 (EDT)
Date: Sun, 5 Apr 2009 18:24:22 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
In-Reply-To: <20090405084902.GA4411@psychotron.englab.brq.redhat.com>
Message-ID: <Pine.LNX.4.64.0904051736210.23536@blonde.anvils>
References: <20081230201052.128B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
 <20081231110816.5f80e265@psychotron.englab.brq.redhat.com>
 <20081231213705.1293.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090103175913.GA21180@redhat.com>
 <2f11576a0901031313u791d7dcex94b927cc56026e40@mail.gmail.com>
 <20090105163204.3ec9ff10@psychotron.englab.brq.redhat.com>
 <20090105141313.a4abd475.akpm@linux-foundation.org>
 <20090106104839.78eb07d1@psychotron.englab.brq.redhat.com>
 <20090402134738.43d87cb7.akpm@linux-foundation.org> <20090402211336.GB4076@elte.hu>
 <20090405084902.GA4411@psychotron.englab.brq.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jiri Pirko <jpirko@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, oleg@redhat.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Sun, 5 Apr 2009, Jiri Pirko wrote:
> (resend, repetitive patterns put into an inline function - not using max macro
>  because it's was decided not to use it in previous conversation)
> 
> From: Jiri Pirko <jpirko@redhat.com>
> 
> Make ->ru_maxrss value in struct rusage filled accordingly to rss hiwater
> mark.  This struct is filled as a parameter to getrusage syscall. 
> ->ru_maxrss value is set to KBs which is the way it is done in BSD
> systems.  /usr/bin/time (gnu time) application converts ->ru_maxrss to KBs
> which seems to be incorrect behavior.  Maintainer of this util was
> notified by me with the patch which corrects it and cc'ed.
> 
> To make this happen we extend struct signal_struct by two fields.  The
> first one is ->maxrss which we use to store rss hiwater of the task.  The
> second one is ->cmaxrss which we use to store highest rss hiwater of all
> task childs.  These values are used in k_getrusage() to actually fill
> ->ru_maxrss.  k_getrusage() uses current rss hiwater value directly if mm
> struct exists.
> 
> Note:
> exec() clear mm->hiwater_rss, but doesn't clear sig->maxrss.
> it is intetionally behavior. *BSD getrusage have exec() inheriting.

Sorry, I'm finding myself quite unable to Ack this: that may well
be a measure of my density, rather than a criticism of your patch.

On the nitpicking level: I wish you'd put the args the other way
round in your setmax_mm_hiwater_rss(maxrss, mm): (mm, maxrss) would
be more conventional.  Though we're gathering so many helpers for
these things, hard-to-distinguish without looking up in the header
file each time, that I wonder if they could all be refactored better.

But on the more serious level: I find I don't really understand what
this ru_maxrss number is supposed to be, so have a hard job telling
whether you've implemented it right (as to whether things are
updated in the right places, I'd rather rely on Oleg for that).

You convey the impression that it's supposed to be similar to
whatever it is in BSD, but little meaning beyond that.  We agreed
before that it should be derived from hiwater_rss - though now I
google for "BSD getrusage" I find ru_maxrss described as "maximum
shared memory or current resident set", which leaves me thoroughly
confused.

I'm worrying particularly about the fork/exec issue you highlight.
You're exemplary in providing your test programs, but there's a big
omission: you don't mention that the first test, "./getrusage -lc",
gives a very different result on Linux than you say it does on BSD -
you say the BSD fork line is "fork: self 0 children 0", whereas
I find my Linux fork line is "fork: self 102636 children 0".

So after that discrepancy, I can't tell what to expect.  Not that
I can make any sense of BSD's "self 0" there - I don't know how
you could present 0 there if this is related to hiwater_rss.

Now I'm seriously wondering if the ru_maxrss reported will generate
more bugreports from people puzzled as to how it should behave,
than help anyone in studying their process behaviour.

Sorry to be so negative after all this time: I genuinely hope others
will spring up to defend your patch and illustrate my stupidity.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
