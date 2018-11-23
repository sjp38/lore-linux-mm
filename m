Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 11B2E6B30CF
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:12:58 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id x82so13910679ita.9
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:12:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w19sor1915256ior.130.2018.11.23.05.12.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 05:12:56 -0800 (PST)
MIME-Version: 1.0
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-3-daniel.vetter@ffwll.ch> <20181123111237.GE8625@dhcp22.suse.cz>
 <20181123123838.GL4266@phenom.ffwll.local> <20181123124643.GK8625@dhcp22.suse.cz>
In-Reply-To: <20181123124643.GK8625@dhcp22.suse.cz>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Fri, 23 Nov 2018 14:12:45 +0100
Message-ID: <CAKMK7uGv7dHqE4_Gmsum=uhfbVo=ymq-QhsR5cHLOC4ZTq4MxA@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm, notifier: Catch sleeping/blocking for !blockable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, intel-gfx <intel-gfx@lists.freedesktop.org>, dri-devel <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, Jerome Glisse <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

On Fri, Nov 23, 2018 at 1:46 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 23-11-18 13:38:38, Daniel Vetter wrote:
> > On Fri, Nov 23, 2018 at 12:12:37PM +0100, Michal Hocko wrote:
> > > On Thu 22-11-18 17:51:05, Daniel Vetter wrote:
> > > > We need to make sure implementations don't cheat and don't have a
> > > > possible schedule/blocking point deeply burried where review can't
> > > > catch it.
> > > >
> > > > I'm not sure whether this is the best way to make sure all the
> > > > might_sleep() callsites trigger, and it's a bit ugly in the code flow.
> > > > But it gets the job done.
> > >
> > > Yeah, it is quite ugly. Especially because it makes DEBUG config
> > > bahavior much different. So is this really worth it? Has this already
> > > discovered any existing bug?
> >
> > Given that we need an oom trigger to hit this we're not hitting this in CI
> > (oom is just way to unpredictable to even try). I'd kinda like to also add
> > some debug interface so I can provoke an oom kill of a specially prepared
> > process, to make sure we can reliably exercise this path without killing
> > the kernel accidentally. We do similar tricks for our shrinker already.
>
> Create a task with oom_score_adj = 1000 and trigger the oom killer via
> sysrq and you should get a predictable oom invocation and execution.

Ah right. We kinda do that already in an attempt to get the tests
killed without the runner, for accidental oom. Just didn't think about
this in the context of intentionally firing the oom. I'll try whether
I can bake up some new subtest in our userptr/mmu-notifier testcases.

> [...]
> > Wrt the behavior difference: I guess we could put another counter into the
> > task struct, and change might_sleep() to check it. All under
> > CONFIG_DEBUG_ATOMIC_SLEEP only ofc. That would avoid the preempt-disable
> > sideeffect. My worry with that is that people will spot it, and abuse it
> > in creative ways that do affect semantics. See horrors like
> > drm_can_sleep() (and I'm sure gfx folks are not the only ones who
> > seriously lacked taste here).
> >
> > Up to the experts really how to best paint this shed I think.
>
> Actually I like a way to say non_block_{begin,end} and might_sleep
> firing inside that context.

Ok, I'll respin with these (introduced in a separate patch).
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch
