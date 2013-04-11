Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 496436B0036
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 20:41:24 -0400 (EDT)
Date: Thu, 11 Apr 2013 10:41:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Message-ID: <20130411004114.GC10481@dastard>
References: <51628412.6050803@parallels.com>
 <20130408090131.GB21654@lge.com>
 <51628877.5000701@parallels.com>
 <20130409005547.GC21654@lge.com>
 <20130409012931.GE17758@dastard>
 <20130409020505.GA4218@lge.com>
 <20130409123008.GM17758@dastard>
 <20130410025115.GA5872@lge.com>
 <20130410100752.GA10481@dastard>
 <CAAmzW4OMyZ=nVbHK_AiifPK5LVxvhOQUXmsD5NGfo33CBjf=eA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4OMyZ=nVbHK_AiifPK5LVxvhOQUXmsD5NGfo33CBjf=eA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Apr 10, 2013 at 11:03:39PM +0900, JoonSoo Kim wrote:
> Another one what I found is that they don't account "nr_reclaimed" precisely.
> There is no code which check whether "current->reclaim_state" exist or not,
> except prune_inode().

That's because prune_inode() can free page cache pages when the
inode mapping is invalidated. Hence it accounts this in addition
to the slab objects being freed.

IOWs, if you have a shrinker that frees pages from the page cache,
you need to do this. Last time I checked, only inode cache reclaim
caused extra page cache reclaim to occur, so most (all?) other
shrinkers do not need to do this.

It's just another wart that we need to clean up....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
