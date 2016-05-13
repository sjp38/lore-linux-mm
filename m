Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id A687C6B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 08:00:45 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ga2so27526362lbc.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:00:45 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id a10si21885366wjm.124.2016.05.13.05.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 05:00:44 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so3269408wme.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:00:44 -0700 (PDT)
Date: Fri, 13 May 2016 14:00:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513120042.GK20141@dhcp22.suse.cz>
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz>
 <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5735A3DE.9030100@laposte.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 13-05-16 11:52:30, Sebastian Frias wrote:
> Hi,
> 
> On 05/13/2016 10:44 AM, Mason wrote:
> > On 13/05/2016 10:04, Michal Hocko wrote:
> > 
> >> On Tue 10-05-16 13:56:30, Sebastian Frias wrote:
> >> [...]
> >>> NOTE: I understand that the overcommit mode can be changed dynamically thru
> >>> sysctl, but on embedded systems, where we know in advance that overcommit
> >>> will be disabled, there's no reason to postpone such setting.
> >>
> >> To be honest I am not particularly happy about yet another config
> >> option. At least not without a strong reason (the one above doesn't
> >> sound that way). The config space is really large already.
> >> So why a later initialization matters at all? Early userspace shouldn't
> >> consume too much address space to blow up later, no?
> 
> By the way, do you know what's the rationale to allow this setting to
> be controlled by the userspace dynamically?  Was it for testing only?

Dunno, but I guess the default might be just too benevolent for some
specific workloads which are not so wasteful to their address space
and the strict overcommit is really helpful for them.

OVERCOMMIT_ALWAYS is certainly useful for testing.

> > One thing I'm not quite clear on is: why was the default set
> > to over-commit on?
> 
> Indeed, I was hoping we could throw some light into that.
> My patch had another note:

I cannot really tell because this was way before my time but I guess the
reason was that userspace is usually very address space hungry while the
actual memory consumption is not that bad. See my other email.

>    "NOTE2: I tried to track down the history of overcommit but back then there
> were no single patches apparently and the patch that appears to have
> introduced the first overcommit mode (OVERCOMMIT_ALWAYS) is commit
> 9334eab8a36f ("Import 2.1.27"). OVERCOMMIT_NEVER was introduced with commit
> 502bff0685b2 ("[PATCH] strict overcommit").
> My understanding is that prior to commit 9334eab8a36f ("Import 2.1.27")
> there was no overcommit, is that correct?"
> 
> It'd be nice to know more about why was overcommit introduced.
> Furthermore, it looks like allowing overcommit and the introduction of the OOM-killer has given rise to lots of other options to try to tame the OOM-killer.
> Without context, that may seem like a form of "feature creep" around it.
> Moreover, it makes Linux behave differently from let's say Solaris.
> 
>    https://www.win.tue.nl/~aeb/linux/lk/lk-9.html#ss9.6

Well, those are some really strong statements which do not really
reflect the reality of the linux userspace. I am not going to argue with
those points because it doesn't make much sense. Yes in an ideal world
everybody consumes only so much he needs. Well the real life is a bit
different...

> Hopefully this discussion could clear some of this up and maybe result
> in more documentation around this subject.

What kind of documentation would help?
Documentation/vm/overcommit-accounting seems to be pretty much extensive
about all available modes including things to be aware of.
 
> > I suppose the biggest use-case is when a "large" process forks
> > only to exec microseconds later into a "small" process, it would
> > be silly to refuse that fork. But isn't that what the COW
> > optimization addresses, without the need for over-commit?
> > 
> > Another issue with overcommit=on is that some programmers seem
> > to take for granted that "allocations will never fail" and so
> > neglect to handle malloc == NULL conditions gracefully.
> > 
> > I tried to run LTP with overcommit off, and I vaguely recall that
> > I had more failures than with overcommit on. (Perhaps only those
> > tests that tickle the dreaded OOM assassin.)
> 
> From what I remember, one of the LTP maintainers said that it is
> highly unlikely people test (or run LTP for that matter) with
> different settings for overcommit.

Yes this is sad and the result of a excessive configuration space.
That's why I was pushing back to adding yet another one without having
really good reasons...

> Years ago, while using MacOS X, a long running process apparently took
> all the memory over night.  The next day when I checked the computer
> I saw a dialog that said something like (I don't remember the exact
> wording) "process X has been paused due to lack of memory (or is
> requesting too much memory, I don't remember). If you think this is
> not normal you can terminate process X, otherwise you can terminate
> other processes to free memory and unpause process X to continue" and
> then some options to proceed.
>
> If left unattended (thus the dialog unanswered), the computer would
> still work, all other processes were left intact and only the
> "offending" process was paused.  Arguably, if the "offending" process
> is just left paused, it takes the memory away from other processes,
> and if it was a server, maybe it wouldn't have enough memory to reply
> to requests.  On the server world I can thus understand that some
> setting could indicate that when the situation arises, the "dialog" is
> automatically dismissed with some default action, like "terminate the
> offending process".

Not sure what you are trying to tell here but it seems like killing such
a leaking task is a better option as the memory can be reused for others
rather than keep it blocked for an unbounded amount of time.

> To me it seems really strange for the "OOM-killer" to exist.  It has
> happened to me that it kills my terminals or editors, how can people
> deal with random processes being killed?  Doesn't it bother anybody?

Killing random tasks is definitely a misbehavior and it happened a lot
in the past when heuristics were based on multiple metrics (including
the run time etc.). Things have changed considerably since then and
seeing random tasks being selected shouldn't happen all that often and
if it happens it should be reported, understood and fixed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
