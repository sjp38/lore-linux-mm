Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF4186B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 04:34:09 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 89so8860509wrr.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 01:34:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 198si1709835wmy.16.2017.02.24.01.34.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Feb 2017 01:34:08 -0800 (PST)
Date: Fri, 24 Feb 2017 10:34:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
Message-ID: <20170224093405.GD19161@dhcp22.suse.cz>
References: <20170222120121.12601-1-mhocko@kernel.org>
 <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
 <CA+_MTtzj9z3JEH528iTjAuNivKo9tNzAx9dwpAJo6U5kgf636g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+_MTtzj9z3JEH528iTjAuNivKo9tNzAx9dwpAJo6U5kgf636g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martijn Coenen <maco@google.com>
Cc: John Stultz <john.stultz@linaro.org>, Greg KH <gregkh@linuxfoundation.org>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Todd Kjos <tkjos@google.com>, Android Kernel Team <kernel-team@android.com>, Rom Lemarchand <romlem@google.com>, Tim Murray <timmurray@google.com>

On Thu 23-02-17 21:36:00, Martijn Coenen wrote:
> On Thu, Feb 23, 2017 at 9:24 PM, John Stultz <john.stultz@linaro.org> wrote:
[...]
> > This is reportedly because while the mempressure notifiers provide a
> > the signal to userspace, the work the deamon then has to do to look up
> > per process memory usage, in order to figure out who is best to kill
> > at that point was too costly and resulted in poor device performance.
> 
> In particular, mempressure requires memory cgroups to function, and we
> saw performance regressions due to the accounting done in mem cgroups.
> At the time we didn't have enough time left to solve this before the
> release, and we reverted back to kernel lmkd.

I would be more than interested to hear details. We used to have some
visible charge path performance footprint but this should be gone now.

[...]
> > It would be great however to get a discussion going here on what the
> > ulmkd needs from the kernel in order to efficiently determine who best
> > to kill, and how we might best implement that.
> 
> The two main issues I think we need to address are:
> 1) Getting the right granularity of events from the kernel; I once
> tried to submit a patch upstream to address this:
> https://lkml.org/lkml/2016/2/24/582

Not only that, the implementation of tht vmpressure needs some serious
rethinking as well. The current one can hit critical events
unexpectedly. The calculation also doesn't consider slab reclaim
sensibly.

> 2) Find out where exactly the memory cgroup overhead is coming from,
> and how to reduce it or work around it to acceptable levels for
> Android. This was also on 3.10, and maybe this has long been fixed or
> improved in more recent kernel versions.

3e32cb2e0a12 ("mm: memcontrol: lockless page counters") has improved
situation a lot as all the charging is lockless since then (3.19).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
