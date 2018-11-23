Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD6A6B2D6B
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:31:02 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so5742667edd.2
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:31:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5-v6sor4075299ejs.35.2018.11.23.04.31.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 04:31:01 -0800 (PST)
Date: Fri, 23 Nov 2018 13:30:57 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 1/3] mm: Check if mmu notifier callbacks are allowed to
 fail
Message-ID: <20181123123057.GK4266@phenom.ffwll.local>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-2-daniel.vetter@ffwll.ch>
 <20181123111557.GG8625@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181123111557.GG8625@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

On Fri, Nov 23, 2018 at 12:15:57PM +0100, Michal Hocko wrote:
> On Thu 22-11-18 17:51:04, Daniel Vetter wrote:
> > Just a bit of paranoia, since if we start pushing this deep into
> > callchains it's hard to spot all places where an mmu notifier
> > implementation might fail when it's not allowed to.
> 
> What does WARN give you more than the existing pr_info? Is really
> backtrace that interesting?

Automated tools have to ignore everything at info level (there's too much
of that). I guess I could do something like

if (blockable)
	pr_warn(...)
else
	pr_info(...)

WARN() is simply my goto tool for getting something at warning level
dumped into dmesg. But I think the pr_warn with the callback function
should be enough indeed.

If you wonder where all the info level stuff happens that we have to
ignore: suspend/resume is a primary culprit (fairly important for
gfx/desktops), but there's a bunch of other places. Even if we ignore
everything at info and below we still need filters because some drivers
are a bit too trigger-happy (i915 definitely included I guess, so everyone
contributes to this problem).

Cheers, Daniel

> 
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: "Christian K�nig" <christian.koenig@amd.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> > Cc: "J�r�me Glisse" <jglisse@redhat.com>
> > Cc: linux-mm@kvack.org
> > Cc: Paolo Bonzini <pbonzini@redhat.com>
> > Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> > ---
> >  mm/mmu_notifier.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> > index 5119ff846769..59e102589a25 100644
> > --- a/mm/mmu_notifier.c
> > +++ b/mm/mmu_notifier.c
> > @@ -190,6 +190,8 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> >  				pr_info("%pS callback failed with %d in %sblockable context.\n",
> >  						mn->ops->invalidate_range_start, _ret,
> >  						!blockable ? "non-" : "");
> > +				WARN(blockable,"%pS callback failure not allowed\n",
> > +				     mn->ops->invalidate_range_start);
> >  				ret = _ret;
> >  			}
> >  		}
> > -- 
> > 2.19.1
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
