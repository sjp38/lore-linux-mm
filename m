Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D97496B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 13:48:21 -0500 (EST)
Date: Wed, 29 Feb 2012 15:45:29 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: SLAB Out-of-memory diagnostics
Message-ID: <20120229184528.GA8034@t510.redhat.com>
References: <20120229032715.GA23758@t510.redhat.com>
 <alpine.LFD.2.02.1202290934020.4850@tux.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.02.1202290934020.4850@tux.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Feb 29, 2012 at 09:37:23AM +0200, Pekka Enberg wrote:
> On Wed, 29 Feb 2012, Rafael Aquini wrote:
> > Following the example at mm/slub.c, add out-of-memory diagnostics to the SLAB
> > allocator to help on debugging OOM conditions. This patch also adds a new
> > sysctl, 'oom_dump_slabs_forced', that overrides the effect of __GFP_NOWARN page
> > allocation flag and forces the kernel to report every slab allocation failure.
> > 
> > An example print out looks like this:
> > 
> >   <snip page allocator out-of-memory message>
> >   SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
> >      cache: bio-0, object size: 192, order: 0
> >      node0: slabs: 3/3, objs: 60/60, free: 0
> > 
> > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> > ---
> >  Documentation/sysctl/vm.txt |   23 ++++++++++++++++++
> >  include/linux/slab.h        |    2 +
> >  kernel/sysctl.c             |    9 +++++++
> >  mm/slab.c                   |   55 ++++++++++++++++++++++++++++++++++++++++++-
> >  4 files changed, 88 insertions(+), 1 deletions(-)
> 
> No SLUB support for this?

SLUB already has its version of slab_out_of_memory. I did not propose the sysctl
knob for slub, however. (If we find the knob useful, I can propose its extention
to slub, later).

> 
> > diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> > index 96f0ee8..75bdf91 100644
> > --- a/Documentation/sysctl/vm.txt
> > +++ b/Documentation/sysctl/vm.txt
> > @@ -498,6 +498,29 @@ this is causing problems for your system/application.
> >  
> >  ==============================================================
> >  
> > +oom_dump_slabs_forced
> > +
> > +Overrides the effects of __GFP_NOWARN page allocation flag, thus forcing
> > +the system to print warnings about every allocation failure for the
> > +slab allocator, and helping on debugging certain OOM conditions.
> > +The print out is pretty similar, and complements data that is reported by
> > +the page allocator out-of-memory warning:
> > +
> > +<snip page allocator out-of-memory message>
> > +  SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
> > +     cache: bio-0, object size: 192, order: 0
> > +     node0: slabs: 3/3, objs: 60/60, free: 0
> > +
> > +If this is set to zero, the default behavior is observed and warnings will only
> > +be printed out for allocation requests that didn't set the __GFP_NOWARN flag.
> > +
> > +When set to non-zero, this information is shown whenever the allocator finds
> > +itself failing to grant a request, regardless the __GFP_NOWARN flag status.
> > +
> > +The default value is 0 (disabled).
> > +
> > +==============================================================
> > +
> 
> Why do you want to add a sysctl for this? That'd be an ABI that we need to 
> keep around forever.
> 
> Is there any reason we shouldn't just enable this unconditionally?

I was afraid of this code becoming a source of garrulous and scaring warnings
by just ignoring __GFP_NOWARN flag, however, I was also concerned with the
'hiding' effect the flag imposes for certain requests, specially when one is
interested in checking  all those requests out. Therefore, I thought a sysctl
knob would be the best option to control the __GFP_NOWARN overriding behavior of
slab_out_of_memory printouts without messing with the allocation flags
themselves, as well as not imposing the need for reboots to start checking all
slab allocation failures out.

  Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
