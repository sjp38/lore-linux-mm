Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 405726B0034
	for <linux-mm@kvack.org>; Wed, 29 May 2013 15:53:28 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 29 May 2013 13:53:27 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 034A319D8045
	for <linux-mm@kvack.org>; Wed, 29 May 2013 13:50:28 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4TJoZUF154896
	for <linux-mm@kvack.org>; Wed, 29 May 2013 13:50:35 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4TJoXLM024080
	for <linux-mm@kvack.org>; Wed, 29 May 2013 13:50:34 -0600
Date: Wed, 29 May 2013 14:50:27 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv12 3/4] zswap: add to mm/
Message-ID: <20130529195027.GC428@cerebellum>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1369067168-12291-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130528145918.acbd84df00313e527cf04d1b@linux-foundation.org>
 <20130529145720.GA428@cerebellum>
 <20130529112929.24005ae9cf1d9d636b2ea42f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130529112929.24005ae9cf1d9d636b2ea42f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, May 29, 2013 at 11:29:29AM -0700, Andrew Morton wrote:
> On Wed, 29 May 2013 09:57:20 -0500 Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> 
> > > > +/*********************************
> > > > +* helpers
> > > > +**********************************/
> > > > +static inline bool zswap_is_full(void)
> > > > +{
> > > > +	return (totalram_pages * zswap_max_pool_percent / 100 <
> > > > +		zswap_pool_pages);
> > > > +}
> > > 
> > > We have had issues in the past where percentage-based tunables were too
> > > coarse on very large machines.  For example, a terabyte machine where 0
> > > bytes is too small and 10GB is too large.
> > 
> > Yes, this is known limitation of the code right now and it is a high priority
> > to come up with something better.  It isn't clear what dynamic sizing policy
> > should be used so, until such time as that policy can be determined, this is a
> > simple stop-gap that works well enough for simple setups.
> 
> It's a module parameter and hence is part of the userspace interface. 
> It's undesirable that the interface be changed, and it would be rather
> dumb to merge it as-is when we *know* that it will be changed.
> 
> I don't think we can remove the parameter altogether (or can we?), so I
> suggest we finalise it ASAP.  Perhaps rename it to
> zswap_max_pool_ratio, with a range 1..999999.  Better ideas needed :(

zswap_max_pool_ratio is fine with me.  I'm not entirely clear on the change
though.  Would that just be a name change or a change in meaning?

Also, we can keep the tunable as I imagine there will always be some use for a
manual override of the (future) dynamic policy.  When the dynamic policy is
available, we can just say that zswap_max_pool_ratio = 0 means "use dynamic
policy" and change the default to 0.  Does that sounds reasonable?

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
