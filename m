Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B72356B010F
	for <linux-mm@kvack.org>; Wed, 29 May 2013 17:08:32 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 29 May 2013 17:08:31 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 13F3938C804D
	for <linux-mm@kvack.org>; Wed, 29 May 2013 17:08:28 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4TL8Sqg39846096
	for <linux-mm@kvack.org>; Wed, 29 May 2013 17:08:28 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4TL8Qel014493
	for <linux-mm@kvack.org>; Wed, 29 May 2013 17:08:28 -0400
Date: Wed, 29 May 2013 16:08:20 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv12 3/4] zswap: add to mm/
Message-ID: <20130529210820.GF428@cerebellum>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1369067168-12291-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130528145918.acbd84df00313e527cf04d1b@linux-foundation.org>
 <20130529145720.GA428@cerebellum>
 <20130529112929.24005ae9cf1d9d636b2ea42f@linux-foundation.org>
 <20130529195027.GC428@cerebellum>
 <20130529125747.23a6a26cdcb013842bf31644@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130529125747.23a6a26cdcb013842bf31644@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, May 29, 2013 at 12:57:47PM -0700, Andrew Morton wrote:
> On Wed, 29 May 2013 14:50:27 -0500 Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> 
> > On Wed, May 29, 2013 at 11:29:29AM -0700, Andrew Morton wrote:
> > > On Wed, 29 May 2013 09:57:20 -0500 Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> > > 
> > > > > > +/*********************************
> > > > > > +* helpers
> > > > > > +**********************************/
> > > > > > +static inline bool zswap_is_full(void)
> > > > > > +{
> > > > > > +	return (totalram_pages * zswap_max_pool_percent / 100 <
> > > > > > +		zswap_pool_pages);
> > > > > > +}
> > > > > 
> > > > > We have had issues in the past where percentage-based tunables were too
> > > > > coarse on very large machines.  For example, a terabyte machine where 0
> > > > > bytes is too small and 10GB is too large.
> > > > 
> > > > Yes, this is known limitation of the code right now and it is a high priority
> > > > to come up with something better.  It isn't clear what dynamic sizing policy
> > > > should be used so, until such time as that policy can be determined, this is a
> > > > simple stop-gap that works well enough for simple setups.
> > > 
> > > It's a module parameter and hence is part of the userspace interface. 
> > > It's undesirable that the interface be changed, and it would be rather
> > > dumb to merge it as-is when we *know* that it will be changed.
> > > 
> > > I don't think we can remove the parameter altogether (or can we?), so I
> > > suggest we finalise it ASAP.  Perhaps rename it to
> > > zswap_max_pool_ratio, with a range 1..999999.  Better ideas needed :(
> > 
> > zswap_max_pool_ratio is fine with me.  I'm not entirely clear on the change
> > though.  Would that just be a name change or a change in meaning?
> 
> It would be a change in behaviour.  The problem which I'm suggesting we
> address is that a 1% increment is too coarse.

Sorry, but I'm not getting this.  This zswap_max_pool_ratio is a ratio of what
to what?  Maybe if you wrote out the calculation of the max pool size using
this ratio I'll get it.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
