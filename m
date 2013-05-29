Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 4627E6B0119
	for <linux-mm@kvack.org>; Wed, 29 May 2013 17:16:33 -0400 (EDT)
Date: Wed, 29 May 2013 14:16:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv12 3/4] zswap: add to mm/
Message-Id: <20130529141630.8f2d1aa9b16d05e60e4a7ada@linux-foundation.org>
In-Reply-To: <20130529210820.GF428@cerebellum>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1369067168-12291-4-git-send-email-sjenning@linux.vnet.ibm.com>
	<20130528145918.acbd84df00313e527cf04d1b@linux-foundation.org>
	<20130529145720.GA428@cerebellum>
	<20130529112929.24005ae9cf1d9d636b2ea42f@linux-foundation.org>
	<20130529195027.GC428@cerebellum>
	<20130529125747.23a6a26cdcb013842bf31644@linux-foundation.org>
	<20130529210820.GF428@cerebellum>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, 29 May 2013 16:08:20 -0500 Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:

> On Wed, May 29, 2013 at 12:57:47PM -0700, Andrew Morton wrote:
> > On Wed, 29 May 2013 14:50:27 -0500 Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> > 
> > > On Wed, May 29, 2013 at 11:29:29AM -0700, Andrew Morton wrote:
> > > > On Wed, 29 May 2013 09:57:20 -0500 Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > > > +/*********************************
> > > > > > > +* helpers
> > > > > > > +**********************************/
> > > > > > > +static inline bool zswap_is_full(void)
> > > > > > > +{
> > > > > > > +	return (totalram_pages * zswap_max_pool_percent / 100 <
> > > > > > > +		zswap_pool_pages);
> > > > > > > +}
> > > > > > 
> > > > > > We have had issues in the past where percentage-based tunables were too
> > > > > > coarse on very large machines.  For example, a terabyte machine where 0
> > > > > > bytes is too small and 10GB is too large.
> > > > > 
> > > > > Yes, this is known limitation of the code right now and it is a high priority
> > > > > to come up with something better.  It isn't clear what dynamic sizing policy
> > > > > should be used so, until such time as that policy can be determined, this is a
> > > > > simple stop-gap that works well enough for simple setups.
> > > > 
> > > > It's a module parameter and hence is part of the userspace interface. 
> > > > It's undesirable that the interface be changed, and it would be rather
> > > > dumb to merge it as-is when we *know* that it will be changed.
> > > > 
> > > > I don't think we can remove the parameter altogether (or can we?), so I
> > > > suggest we finalise it ASAP.  Perhaps rename it to
> > > > zswap_max_pool_ratio, with a range 1..999999.  Better ideas needed :(
> > > 
> > > zswap_max_pool_ratio is fine with me.  I'm not entirely clear on the change
> > > though.  Would that just be a name change or a change in meaning?
> > 
> > It would be a change in behaviour.  The problem which I'm suggesting we
> > address is that a 1% increment is too coarse.
> 
> Sorry, but I'm not getting this.  This zswap_max_pool_ratio is a ratio of what
> to what?  Maybe if you wrote out the calculation of the max pool size using
> this ratio I'll get it.
> 

This:

	totalram_pages * zswap_max_pool_percent / 100

means that we have are able to control the pool size in 10GB increments
on a 1TB machine.  Past experience with other tunables tells us that
this can be a problem.  Hence my (lame) suggestion that we replace it
with

	totalram_pages * zswap_max_pool_ratio / 1000000


Another approach would be to stop using a ratio altogether, and make the
tunable specify an absolute number of bytes.  That's how we approached
this problem in the case of /proc/sys/vm/dirty_background_ratio.  See
https://lkml.org/lkml/2008/11/23/160.

(And it's "bytes", not "pages" because PAGE_SIZE can vary by a factor
of 16, which is a lot). 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
