Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 39E8C8D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 12:11:20 -0500 (EST)
Date: Thu, 10 Feb 2011 12:10:20 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] Re: [PATCH R3 5/7] xen/balloon: Protect against
 CPU exhaust by event/x proces
Message-ID: <20110210171020.GB3993@dumpdata.com>
References: <20110203162851.GH1364@router-fw-old.local.net-space.pl>
 <20110210155142.GC12087@dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110210155142.GC12087@dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: jeremy@goop.org, xen-devel@lists.xensource.com, ian.campbell@citrix.com, haicheng.li@linux.intel.com, linux-kernel@vger.kernel.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, dave@linux.vnet.ibm.com, linux-mm@kvack.org, rientjes@google.com, andi.kleen@intel.com, akpm@linux-foundation.org, fengguang.wu@intel.com, wdauchy@gmail.com

On Thu, Feb 10, 2011 at 10:51:42AM -0500, Konrad Rzeszutek Wilk wrote:
> On Thu, Feb 03, 2011 at 05:28:51PM +0100, Daniel Kiper wrote:
> > Protect against CPU exhaust by event/x process during
> > errors by adding some delays in scheduling next event.
> > 
> > Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
> > ---
> >  drivers/xen/balloon.c |   99 +++++++++++++++++++++++++++++++++++++++---------
> >  1 files changed, 80 insertions(+), 19 deletions(-)
> > 
> > diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> > index 4223f64..ed103d4 100644
> > --- a/drivers/xen/balloon.c
> > +++ b/drivers/xen/balloon.c
> > @@ -66,6 +66,20 @@
> >  
> >  #define BALLOON_CLASS_NAME "xen_memory"
> >  
> > +/*
> > + * balloon_process() state:
> > + *
> > + * BP_ERROR: error, go to sleep,
> > + * BP_DONE: done or nothing to do,
> > + * BP_HUNGRY: hungry.
> > + */
> > +
> > +enum bp_state {
> > +	BP_ERROR,
> 
> BP_EAGAIN?
> 
> So if we fail to increase the first hour, we would keep on trying to
> increase forever (with a 32 second delay between each call). Do you
> think it makes sense (as a future patch, not tied in with this patchset)
> to printout a printk(KERN_INFO that we have been trying to increase
> for the last X hours, seconds and have not gone anywhere (and perhaps
> stop trying to allocate more memory?).

Duh, you did that in the next patch with the mh_policy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
