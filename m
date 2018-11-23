Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB81A6B30EA
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:15:24 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id d63so11233455iog.4
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:15:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b8sor11123928itb.16.2018.11.23.05.15.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 05:15:23 -0800 (PST)
MIME-Version: 1.0
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-2-daniel.vetter@ffwll.ch> <20181123111557.GG8625@dhcp22.suse.cz>
 <20181123123057.GK4266@phenom.ffwll.local> <20181123124358.GJ8625@dhcp22.suse.cz>
In-Reply-To: <20181123124358.GJ8625@dhcp22.suse.cz>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Fri, 23 Nov 2018 14:15:11 +0100
Message-ID: <CAKMK7uGViQT5HPEQzFsAT85gdCr-gw94EB5fMT9eXRBAXambWg@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: Check if mmu notifier callbacks are allowed to fail
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, intel-gfx <intel-gfx@lists.freedesktop.org>, dri-devel <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

On Fri, Nov 23, 2018 at 1:43 PM Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 23-11-18 13:30:57, Daniel Vetter wrote:
> > On Fri, Nov 23, 2018 at 12:15:57PM +0100, Michal Hocko wrote:
> > > On Thu 22-11-18 17:51:04, Daniel Vetter wrote:
> > > > Just a bit of paranoia, since if we start pushing this deep into
> > > > callchains it's hard to spot all places where an mmu notifier
> > > > implementation might fail when it's not allowed to.
> > >
> > > What does WARN give you more than the existing pr_info? Is really
> > > backtrace that interesting?
> >
> > Automated tools have to ignore everything at info level (there's too much
> > of that). I guess I could do something like
> >
> > if (blockable)
> >       pr_warn(...)
> > else
> >       pr_info(...)
> >
> > WARN() is simply my goto tool for getting something at warning level
> > dumped into dmesg. But I think the pr_warn with the callback function
> > should be enough indeed.
>
> I wouldn't mind s@pr_info@pr_warn@

Well that's too much, because then it would misfire in the oom
testcase, where failing is ok (desireble even, we want to avoid
blocking after all). So needs to be  a switch (or else we need to
filter it in results, and that's a bit a maintenance headache from a
CI pov).
-Danile

> > If you wonder where all the info level stuff happens that we have to
> > ignore: suspend/resume is a primary culprit (fairly important for
> > gfx/desktops), but there's a bunch of other places. Even if we ignore
> > everything at info and below we still need filters because some drivers
> > are a bit too trigger-happy (i915 definitely included I guess, so everyone
> > contributes to this problem).
>
> Thanks for the clarification.
> --
> Michal Hocko
> SUSE Labs



-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch
