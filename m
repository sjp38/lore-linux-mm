Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 456966B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 10:04:00 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v30so12447208wrc.4
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 07:04:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x78si3246064wrb.74.2017.02.24.07.03.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Feb 2017 07:03:59 -0800 (PST)
Date: Fri, 24 Feb 2017 16:03:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
Message-ID: <20170224150357.GK19161@dhcp22.suse.cz>
References: <20170222120121.12601-1-mhocko@kernel.org>
 <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
 <CA+_MTtzj9z3JEH528iTjAuNivKo9tNzAx9dwpAJo6U5kgf636g@mail.gmail.com>
 <855e929a-a891-a435-8f75-3674d8a3e96d@sonymobile.com>
 <20170224122830.GG19161@dhcp22.suse.cz>
 <9ffdcc79-12d4-00c5-182c-498b8ca951cc@sonymobile.com>
 <20170224141144.GI19161@dhcp22.suse.cz>
 <3336a503-c73f-9fe4-a17a-36629a54a97b@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3336a503-c73f-9fe4-a17a-36629a54a97b@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: Martijn Coenen <maco@google.com>, John Stultz <john.stultz@linaro.org>, Greg KH <gregkh@linuxfoundation.org>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Todd Kjos <tkjos@google.com>, Android Kernel Team <kernel-team@android.com>, Rom Lemarchand <romlem@google.com>, Tim Murray <timmurray@google.com>

On Fri 24-02-17 15:42:49, peter enderborg wrote:
> On 02/24/2017 03:11 PM, Michal Hocko wrote:
> > On Fri 24-02-17 14:16:34, peter enderborg wrote:
> >> On 02/24/2017 01:28 PM, Michal Hocko wrote:
> > [...]
> >>> Yeah, I strongly believe that the chosen approach is completely wrong.
> >>> Both in abusing the shrinker interface and abusing oom_score_adj as the
> >>> only criterion for the oom victim selection.
> >> No one is arguing that shrinker is not problematic. And would be great
> >> if it is removed from lmk.  The oom_score_adj is the way user-space
> >> tells the kernel what the user-space has as prio. And android is using
> >> that very much. It's a core part.
> > Is there any documentation which describes how this is done?
> >
> >> I have never seen it be used on
> >> other linux system so what is the intended usage of oom_score_adj? Is
> >> this really abusing?
> > oom_score_adj is used to _adjust_ the calculated oom score. It is not a
> > criterion on its own, well, except for the extreme sides of the range
> > which are defined to enforce resp. disallow selecting the task. The
> > global oom killer calculates the oom score as a function of the memory
> > consumption. Your patch simply ignores the memory consumption (and uses
> > pids to sort tasks with the same oom score which is just mind boggling)
>
> How much it uses is of very little importance for android.

But it is relevant for the global oom killer which is the main consumer of
the oom_score_adj.

> The score
> used are only for apps and their services. System related are not
> touched by android lmk. The pid is only to have a unique key to be
> able to have it fast within a rbtree.  One idea was to use task_pid to
> get a strict age of process to get a round robin but since it does not
> matter i skipped that idea since it does not matter.

Pid will not tell you anything about the age. Pids do wrap around.

> > and that is what I call the abuse. The oom score calculation might
> > change in future, of course, but all consumers of the oom_score_adj
> > really have to agree on the base which is adjusted by this tunable
> > otherwise you can see a lot of unexpected behavior.
>
> Then can we just define a range that is strictly for user-space?

This is already well defined. The whole range OOM_SCORE_ADJ_{MIN,MAX}
is usable.

> > I would even argue that nobody outside of mm/oom_kill.c should really
> > have any business with this tunable.  You can of course tweak the value
> > from the userspace and help to chose a better oom victim this way but
> > that is it.
>
> Why only help? If userspace can give an exact order to kernel that
> must be a good thing; other wise kernel have to guess and when
> can that be better? 

Because userspace doesn't know who is the best victim in 99% cases.
Android might be different, although, I am a bit skeptical - especially
after hearing quite some complains about random application being
killed... If you do believe that you know better then, by all means,
implement your custom user space LMK and chose the oom victim on a
different basis but try to understand that the global OOM killer is the
last resort measure to make the system usable again. There is a good
reason why the kernel uses the current badness calculation. The previous
implementation which considered the process age ad other things was just
too random to have a understandable behavior.

In any case playing nasty games with the oom killer tunables might and
will lead, well, to unexpected behavior.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
