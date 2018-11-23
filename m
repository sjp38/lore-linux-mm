Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE5C6B310A
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:30:41 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b7so5774279eda.10
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:30:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n15si109311edb.101.2018.11.23.05.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:30:39 -0800 (PST)
Date: Fri, 23 Nov 2018 14:30:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: Check if mmu notifier callbacks are allowed to
 fail
Message-ID: <20181123133038.GQ8625@dhcp22.suse.cz>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-2-daniel.vetter@ffwll.ch>
 <20181123111557.GG8625@dhcp22.suse.cz>
 <20181123123057.GK4266@phenom.ffwll.local>
 <20181123124358.GJ8625@dhcp22.suse.cz>
 <CAKMK7uGViQT5HPEQzFsAT85gdCr-gw94EB5fMT9eXRBAXambWg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uGViQT5HPEQzFsAT85gdCr-gw94EB5fMT9eXRBAXambWg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, intel-gfx <intel-gfx@lists.freedesktop.org>, dri-devel <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

On Fri 23-11-18 14:15:11, Daniel Vetter wrote:
> On Fri, Nov 23, 2018 at 1:43 PM Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 23-11-18 13:30:57, Daniel Vetter wrote:
> > > On Fri, Nov 23, 2018 at 12:15:57PM +0100, Michal Hocko wrote:
> > > > On Thu 22-11-18 17:51:04, Daniel Vetter wrote:
> > > > > Just a bit of paranoia, since if we start pushing this deep into
> > > > > callchains it's hard to spot all places where an mmu notifier
> > > > > implementation might fail when it's not allowed to.
> > > >
> > > > What does WARN give you more than the existing pr_info? Is really
> > > > backtrace that interesting?
> > >
> > > Automated tools have to ignore everything at info level (there's too much
> > > of that). I guess I could do something like
> > >
> > > if (blockable)
> > >       pr_warn(...)
> > > else
> > >       pr_info(...)
> > >
> > > WARN() is simply my goto tool for getting something at warning level
> > > dumped into dmesg. But I think the pr_warn with the callback function
> > > should be enough indeed.
> >
> > I wouldn't mind s@pr_info@pr_warn@
> 
> Well that's too much, because then it would misfire in the oom
> testcase, where failing is ok (desireble even, we want to avoid
> blocking after all). So needs to be  a switch (or else we need to
> filter it in results, and that's a bit a maintenance headache from a
> CI pov).

I thought the failure should be rare enough that warning about them can
be actually useful. E.g. in the oom case we can live with the failure
because we want to release _some_ memory but know about a callback that
prevents us to go the full way might be interesting.

But I do not really feel strongly about this. I find WARN a bit abuse
because the trace is unlikely going to help us much. If you want to make
a verbosity depending on the blockable context then I will surely not
stand in the way.

-- 
Michal Hocko
SUSE Labs
