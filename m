Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Mon, 24 Dec 2018 09:10:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm: vmalloc: do not allow kzalloc to fail
Message-ID: <20181224081056.GD9063@dhcp22.suse.cz>
References: <1545337437-673-1-git-send-email-hofrat@osadl.org>
 <alpine.DEB.2.21.1812211356040.219499@chino.kir.corp.google.com>
 <20181222080421.GB26155@osadl.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181222080421.GB26155@osadl.at>
Sender: linux-kernel-owner@vger.kernel.org
To: Nicholas Mc Guire <der.herr@hofr.at>
Cc: David Rientjes <rientjes@google.com>, Nicholas Mc Guire <hofrat@osadl.org>, Andrew Morton <akpm@linux-foundation.org>, Chintan Pandya <cpandya@codeaurora.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Arun KS <arunks@codeaurora.org>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat 22-12-18 09:04:21, Nicholas Mc Guire wrote:
> On Fri, Dec 21, 2018 at 01:58:39PM -0800, David Rientjes wrote:
> > On Thu, 20 Dec 2018, Nicholas Mc Guire wrote:
> > 
> > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > index 871e41c..1c118d7 100644
> > > --- a/mm/vmalloc.c
> > > +++ b/mm/vmalloc.c
> > > @@ -1258,7 +1258,7 @@ void __init vmalloc_init(void)
> > >  
> > >  	/* Import existing vmlist entries. */
> > >  	for (tmp = vmlist; tmp; tmp = tmp->next) {
> > > -		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> > > +		va = kzalloc(sizeof(*va), GFP_NOWAIT | __GFP_NOFAIL);
> > >  		va->flags = VM_VM_AREA;
> > >  		va->va_start = (unsigned long)tmp->addr;
> > >  		va->va_end = va->va_start + tmp->size;
> > 
> > Hi Nicholas,
> > 
> > You're right that this looks wrong because there's no guarantee that va is 
> > actually non-NULL.  __GFP_NOFAIL won't help in init, unfortunately, since 
> > we're not giving the page allocator a chance to reclaim so this would 
> > likely just end up looping forever instead of crashing with a NULL pointer 
> > dereference, which would actually be the better result.
> >
> tried tracing the __GFP_NOFAIL path and had concluded that it would
> end in out_of_memory() -> panic("System is deadlocked on memory\n");
> which also should point cleanly to the cause - but I�m actually not
> that sure if that trace was correct in all cases.

No, we do not trigger the memory reclaim path nor the oom killer when
using GFP_NOWAIT. In fact the current implementation even ignores
__GFP_NOFAIL AFAICS (so I was wrong about the endless loop but I suspect
that we used to loop fpr __GFP_NOFAIL at some point in the past). The
patch simply doesn't have any effect. But the primary objection is that
the behavior might change in future and you certainly do not want to get
stuck in the boot process without knowing what is going on. Crashing
will tell you that quite obviously. Although I have hard time imagine
how that could happen in a reasonably configured system.

> > You could do
> > 
> > 	BUG_ON(!va);
> > 
> > to make it obvious why we crashed, however.  It makes it obvious that the 
> > crash is intentional rather than some error in the kernel code.
> 
> makes sense - that atleast makes it imediately clear from the code
> that there is no way out from here.

How does it differ from blowing up right there when dereferencing flags?
It would be clear from the oops.
-- 
Michal Hocko
SUSE Labs
