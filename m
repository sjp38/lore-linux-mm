Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id A83ED8E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 04:38:14 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id 129so4735430wmy.7
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 01:38:14 -0800 (PST)
Received: from mail.osadl.at (178.115.242.59.static.drei.at. [178.115.242.59])
        by mx.google.com with ESMTP id s18si4657136wro.429.2018.12.24.01.38.12
        for <linux-mm@kvack.org>;
        Mon, 24 Dec 2018 01:38:12 -0800 (PST)
Date: Mon, 24 Dec 2018 10:38:04 +0100
From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH RFC] mm: vmalloc: do not allow kzalloc to fail
Message-ID: <20181224093804.GA16933@osadl.at>
References: <1545337437-673-1-git-send-email-hofrat@osadl.org>
 <alpine.DEB.2.21.1812211356040.219499@chino.kir.corp.google.com>
 <20181222080421.GB26155@osadl.at>
 <20181224081056.GD9063@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181224081056.GD9063@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Nicholas Mc Guire <hofrat@osadl.org>, Andrew Morton <akpm@linux-foundation.org>, Chintan Pandya <cpandya@codeaurora.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Arun KS <arunks@codeaurora.org>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 24, 2018 at 09:10:56AM +0100, Michal Hocko wrote:
> On Sat 22-12-18 09:04:21, Nicholas Mc Guire wrote:
> > On Fri, Dec 21, 2018 at 01:58:39PM -0800, David Rientjes wrote:
> > > On Thu, 20 Dec 2018, Nicholas Mc Guire wrote:
> > > 
> > > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > > index 871e41c..1c118d7 100644
> > > > --- a/mm/vmalloc.c
> > > > +++ b/mm/vmalloc.c
> > > > @@ -1258,7 +1258,7 @@ void __init vmalloc_init(void)
> > > >  
> > > >  	/* Import existing vmlist entries. */
> > > >  	for (tmp = vmlist; tmp; tmp = tmp->next) {
> > > > -		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> > > > +		va = kzalloc(sizeof(*va), GFP_NOWAIT | __GFP_NOFAIL);
> > > >  		va->flags = VM_VM_AREA;
> > > >  		va->va_start = (unsigned long)tmp->addr;
> > > >  		va->va_end = va->va_start + tmp->size;
> > > 
> > > Hi Nicholas,
> > > 
> > > You're right that this looks wrong because there's no guarantee that va is 
> > > actually non-NULL.  __GFP_NOFAIL won't help in init, unfortunately, since 
> > > we're not giving the page allocator a chance to reclaim so this would 
> > > likely just end up looping forever instead of crashing with a NULL pointer 
> > > dereference, which would actually be the better result.
> > >
> > tried tracing the __GFP_NOFAIL path and had concluded that it would
> > end in out_of_memory() -> panic("System is deadlocked on memory\n");
> > which also should point cleanly to the cause - but I�m actually not
> > that sure if that trace was correct in all cases.
> 
> No, we do not trigger the memory reclaim path nor the oom killer when
> using GFP_NOWAIT. In fact the current implementation even ignores
> __GFP_NOFAIL AFAICS (so I was wrong about the endless loop but I suspect
> that we used to loop fpr __GFP_NOFAIL at some point in the past). The
> patch simply doesn't have any effect. But the primary objection is that
> the behavior might change in future and you certainly do not want to get
> stuck in the boot process without knowing what is going on. Crashing
> will tell you that quite obviously. Although I have hard time imagine
> how that could happen in a reasonably configured system.

I think most of the defensive structures are covering rare to almost
impossible cases - but those are precisely the hard ones to understand if
they do happen.

> 
> > > You could do
> > > 
> > > 	BUG_ON(!va);
> > > 
> > > to make it obvious why we crashed, however.  It makes it obvious that the 
> > > crash is intentional rather than some error in the kernel code.
> > 
> > makes sense - that atleast makes it imediately clear from the code
> > that there is no way out from here.
> 
> How does it differ from blowing up right there when dereferencing flags?
> It would be clear from the oops.

The question is how soon does it blow-up if it were imediate then three is
probably no real difference if there is some delay say due to the region
affected by the NULL pointer not being imediately in use - it may be very
hard to differenciate between an allocation failure and memory corruption
so having a directly associated trace should be significantly simpler to
understand - and you might actually not want a system to try booting if there
are problems at this level.

thx!
hofrat
