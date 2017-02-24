Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 765466B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 04:38:15 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r141so6579073wmg.4
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 01:38:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z20si1681973wmz.148.2017.02.24.01.38.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Feb 2017 01:38:14 -0800 (PST)
Date: Fri, 24 Feb 2017 10:38:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
Message-ID: <20170224093811.GE19161@dhcp22.suse.cz>
References: <20170222120121.12601-1-mhocko@kernel.org>
 <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Todd Kjos <tkjos@google.com>, Android Kernel Team <kernel-team@android.com>, Martijn Coenen <maco@google.com>, Rom Lemarchand <romlem@google.com>

On Thu 23-02-17 12:24:57, John Stultz wrote:
> On Wed, Feb 22, 2017 at 4:01 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > From: Michal Hocko <mhocko@suse.com>
> >
> > Lowmemory killer is sitting in the staging tree since 2008 without any
> > serious interest for fixing issues brought up by the MM folks. The main
> > objection is that the implementation is basically broken by design:
> >         - it hooks into slab shrinker API which is not suitable for this
> >           purpose. lowmem_count implementation just shows this nicely.
> >           There is no scaling based on the memory pressure and no
> >           feedback to the generic shrinker infrastructure.
> >           Moreover lowmem_scan is called way too often for the heavy
> >           work it performs.
> >         - it is not reclaim context aware - no NUMA and/or memcg
> >           awareness.
> >
> > As the code stands right now it just adds a maintenance overhead when
> > core MM changes have to update lowmemorykiller.c as well. It also seems
> > that the alternative LMK implementation will be solely in the userspace
> > so this code has no perspective it seems. The staging tree is supposed
> > to be for a code which needs to be put in shape before it can be merged
> > which is not the case here obviously.
> 
> So, just for context, Android does have a userland LMK daemon (using
> the mempressure notifiers) as you mentioned, but unfortunately I'm
> unaware of any devices that ship with that implementation.
> 
> This is reportedly because while the mempressure notifiers provide a
> the signal to userspace, the work the deamon then has to do to look up
> per process memory usage, in order to figure out who is best to kill
> at that point was too costly and resulted in poor device performance.

What was the expensive part?

> So for shipping Android devices, the LMK is still needed. However, its
> not critical for basic android development, as the system will
> function without it. Additionally I believe most vendors heavily
> customize the LMK in their vendor tree, so the value of having it in
> staging might be relatively low.

This is even a stronger reason to drop it from the tree. We do not want
to maintain the code which is not used in fact.
 
> It would be great however to get a discussion going here on what the
> ulmkd needs from the kernel in order to efficiently determine who best
> to kill, and how we might best implement that.

I would really like to see this happen and, to be honest, it should have
happened quite some time ago (around the time when the lmk was merged to
the staging tree).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
