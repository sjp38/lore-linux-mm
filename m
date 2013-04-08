Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id A19066B0080
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 05:00:57 -0400 (EDT)
Date: Mon, 8 Apr 2013 18:01:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Message-ID: <20130408090131.GB21654@lge.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
 <1364548450-28254-3-git-send-email-glommer@parallels.com>
 <20130408084202.GA21654@lge.com>
 <51628412.6050803@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51628412.6050803@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Mon, Apr 08, 2013 at 12:47:14PM +0400, Glauber Costa wrote:
> On 04/08/2013 12:42 PM, Joonsoo Kim wrote:
> > Hello, Glauber.
> > 
> > On Fri, Mar 29, 2013 at 01:13:44PM +0400, Glauber Costa wrote:
> >> In very low free kernel memory situations, it may be the case that we
> >> have less objects to free than our initial batch size. If this is the
> >> case, it is better to shrink those, and open space for the new workload
> >> then to keep them and fail the new allocations.
> >>
> >> More specifically, this happens because we encode this in a loop with
> >> the condition: "while (total_scan >= batch_size)". So if we are in such
> >> a case, we'll not even enter the loop.
> >>
> >> This patch modifies turns it into a do () while {} loop, that will
> >> guarantee that we scan it at least once, while keeping the behaviour
> >> exactly the same for the cases in which total_scan > batch_size.
> > 
> > Current user of shrinker not only use their own condition, but also
> > use batch_size and seeks to throttle their behavior. So IMHO,
> > this behavior change is very dangerous to some users.
> > 
> > For example, think lowmemorykiller.
> > With this patch, he always kill some process whenever shrink_slab() is
> > called and their low memory condition is satisfied.
> > Before this, total_scan also prevent us to go into lowmemorykiller, so
> > killing innocent process is limited as much as possible.
> > 
> shrinking is part of the normal operation of the Linux kernel and
> happens all the time. Not only the call to shrink_slab, but actual
> shrinking of unused objects.
> 
> I don't know therefore about any code that would kill process only
> because they have reached shrink_slab.
> 
> In normal systems, this loop will be executed many, many times. So we're
> not shrinking *more*, we're just guaranteeing that at least one pass
> will be made.

This one pass guarantee is a problem for lowmemory killer.

> Also, anyone looking at this to see if we should kill processes, is a
> lot more likely to kill something if we tried to shrink but didn't, than
> if we successfully shrunk something.

lowmemory killer is hacky user of shrink_slab interface. It kill a process
if system memory goes under some level. It check that condition every time
it is called. Without this patch, it cannot check that condition
if total_scan < batch_size. But with this patch, it check that condition
more frequently, so there will be side-effect.

Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
