Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50A856B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 10:51:04 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id u5so36415554igk.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:51:04 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id r15si4327975wme.0.2016.05.13.07.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 07:51:03 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id e201so4194576wme.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:51:03 -0700 (PDT)
Date: Fri, 13 May 2016 16:51:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513145101.GS20141@dhcp22.suse.cz>
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz>
 <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net>
 <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5735CAE5.5010104@laposte.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 13-05-16 14:39:01, Sebastian Frias wrote:
> Hi Michal,
> 
> On 05/13/2016 02:00 PM, Michal Hocko wrote:
> > On Fri 13-05-16 11:52:30, Sebastian Frias wrote:
[...]
> >> Indeed, I was hoping we could throw some light into that.
> >> My patch had another note:
> > 
> > I cannot really tell because this was way before my time but I guess the
> > reason was that userspace is usually very address space hungry while the
> > actual memory consumption is not that bad. See my other email.
> 
> Yes, I saw that, thanks for the example.
> It's just that it feels like the default value is there to deal with
> (what it should be?) very specific cases, right?

The default should cover the most use cases. If you can prove that the
vast majority of embeded systems are different and would _benefit_ from
a different default I wouldn't be opposed to change the default there.

> >> It'd be nice to know more about why was overcommit introduced.
> >> Furthermore, it looks like allowing overcommit and the introduction
> >> of the OOM-killer has given rise to lots of other options to try to
> >> tame the OOM-killer.
> >> Without context, that may seem like a form of "feature creep" around it.
> >> Moreover, it makes Linux behave differently from let's say Solaris.
> >>
> >>    https://www.win.tue.nl/~aeb/linux/lk/lk-9.html#ss9.6
> > 
> > Well, those are some really strong statements which do not really
> > reflect the reality of the linux userspace. I am not going to argue with
> > those points because it doesn't make much sense. Yes in an ideal world
> > everybody consumes only so much he needs. Well the real life is a bit
> > different...
> 
> :-)
> I see, so basically it is a sort of workaround.

No it is not a workaround. It is just serving the purpose of the
operating system. The allow using the HW as much as possible to the
existing userspace. You cannot expect userspace will change just because
we do not like the overcommiting the memory with all the fallouts.

> Anyway, in the embedded world the memory and system requirements are
> usually controlled.

OK, but even when it is controlled does it suffer in any way just
because of the default setting? Do you see OOM killer invocation
when the overcommit would prevent from that?

> Would you agree to the option if it was dependent on
> CONFIG_EMBEDDED? Or if it was a hidden option?
> (I understand though that it wouldn't affect the size of config space)

It could be done in the code and make the default depending on the
existing config. But first try to think about what would be an advantage
of such a change.
 
> >> Hopefully this discussion could clear some of this up and maybe result
> >> in more documentation around this subject.
> > 
> > What kind of documentation would help?
> 
> Well, mostly the history of this setting, why it was introduced, etc.
> more or less what we are discussing here.  Because honestly, killing
> random processes does not seems like a straightforward idea, ie: it is
> not obvious.  Like I was saying, without context, such behaviour looks
> a bit crazy.

But we are not killing a random process. The semantic is quite clear. We
are trying to kill the biggest memory hog and if it has some children
try to sacrifice them to save as much work as possible.

> >> From what I remember, one of the LTP maintainers said that it is
> >> highly unlikely people test (or run LTP for that matter) with
> >> different settings for overcommit.
> > 
> > Yes this is sad and the result of a excessive configuration space.
> > That's why I was pushing back to adding yet another one without having
> > really good reasons...
> 
> Well, a more urgent problem would be that in that case
> overcommit=never is not really well tested.

This is a problem of the userspace and am really skeptical that a change
in default would make any existing bugs going away. It is more likely we
will see reports that ENOMEM has been returned even though there is
pletny of memory available.

[...]

> > Killing random tasks is definitely a misbehavior and it happened a lot
> > in the past when heuristics were based on multiple metrics (including
> > the run time etc.). Things have changed considerably since then and
> > seeing random tasks being selected shouldn't happen all that often and
> > if it happens it should be reported, understood and fixed.
> > 
> 
> Well, it's hard to report, since it is essentially the result of a
> dynamic system.

Each oom killer invocation will provide a detailed report which will
help MM developers to debug what went wrong and why.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
