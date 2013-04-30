Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 4772B6B00EF
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 11:37:12 -0400 (EDT)
Date: Tue, 30 Apr 2013 16:37:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 02/31] vmscan: take at least one pass with shrinkers
Message-ID: <20130430153707.GD11497@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-3-git-send-email-glommer@openvz.org>
 <20130430132239.GB6415@suse.de>
 <517FC7B4.5030101@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <517FC7B4.5030101@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Tue, Apr 30, 2013 at 05:31:32PM +0400, Glauber Costa wrote:
> On 04/30/2013 05:22 PM, Mel Gorman wrote:
> > On Sat, Apr 27, 2013 at 03:18:58AM +0400, Glauber Costa wrote:
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
> >>
> >> Signed-off-by: Glauber Costa <glommer@openvz.org>
> >> Reviewed-by: Dave Chinner <david@fromorbit.com>
> >> Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
> >> CC: "Theodore Ts'o" <tytso@mit.edu>
> >> CC: Al Viro <viro@zeniv.linux.org.uk>
> > 
> > There are two cases where this *might* cause a problem and worth keeping
> > an eye out for.
> > 
> 
> Any test case that you envision that could help bringing those issues
> forward should they exist ? (aside from getting it into upstream trees
> early?)
> 

hmm.

fsmark multi-threaded in a small-memory machine with a small number of
very large files greater than the size of physical memory might trigger
it. There should be a small number of inodes active so less than the 128
that would have been ignored before the patch. As the files are larger
than memory, kswapd will be awake and calling shrinkers so if the
shrinker is really discarding active inodes then the performance will
degrade.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
