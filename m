Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 2B8866B0037
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 23:55:05 -0400 (EDT)
Date: Wed, 5 Jun 2013 20:54:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 12/35] shrinker: add node awareness
Message-Id: <20130605205450.d9bc576b.akpm@linux-foundation.org>
In-Reply-To: <20130606032659.GR29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-13-git-send-email-glommer@openvz.org>
	<20130605160810.5b203c3368b9df7d087ee3b1@linux-foundation.org>
	<20130606032659.GR29338@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Thu, 6 Jun 2013 13:26:59 +1000 Dave Chinner <david@fromorbit.com> wrote:

> On Wed, Jun 05, 2013 at 04:08:10PM -0700, Andrew Morton wrote:
> > On Mon,  3 Jun 2013 23:29:41 +0400 Glauber Costa <glommer@openvz.org> wrote:
> > 
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > Pass the node of the current zone being reclaimed to shrink_slab(),
> > > allowing the shrinker control nodemask to be set appropriately for
> > > node aware shrinkers.
> > 
> > Again, some musings on node hotplug would be interesting.
> > 
> > > --- a/drivers/staging/android/ashmem.c
> > > +++ b/drivers/staging/android/ashmem.c
> > > @@ -692,6 +692,9 @@ static long ashmem_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
> > >  				.gfp_mask = GFP_KERNEL,
> > >  				.nr_to_scan = 0,
> > >  			};
> > > +
> > > +			nodes_setall(sc.nodes_to_scan);
> > 
> > hm, is there some way to do this within the initializer? ie:
> > 
> > 				.nodes_to_scan = magic_goes_here(),
> 
> Nothing obvious - it's essentially a memset call, so I'm not sure
> how that could be put in the initialiser...

I was thinking something like

		.nodes_to_scan = node_online_map,

which would solve both problems.  But node_online_map is nowhere near
the appropriate type, ho-hum.

We could newly accumulate such a thing in register_one_node(), but I
don't see a need.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
