Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 92F046B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 23:39:45 -0400 (EDT)
Date: Sat, 18 May 2013 13:39:41 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 12/31] fs: convert inode and dentry shrinking to be
 node aware
Message-ID: <20130518033941.GB6495@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <1368382432-25462-13-git-send-email-glommer@openvz.org>
 <20130514095200.GI29466@dastard>
 <5193A95E.70205@parallels.com>
 <20130516000216.GC24635@dastard>
 <5195302A.2090406@parallels.com>
 <20130517005134.GK24635@dastard>
 <5195DC59.8000205@parallels.com>
 <51964381.8010406@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51964381.8010406@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Fri, May 17, 2013 at 06:49:37PM +0400, Glauber Costa wrote:
> On 05/17/2013 11:29 AM, Glauber Costa wrote:
> > Except that shrink_slab_node would also defer work, right?
> > 
> >> > The only thing I don't like about this is the extra nodemask needed,
> >> > which, like the scan control, would have to sit on the stack.
> >> > Suggestions for avoiding that problem are welcome.. :)
> >> >
> > I will try to come up with a patch to do all this, and then we can
> > concretely discuss.
> > You are also of course welcome to do so as well =)
> 
> 
> All right.
> 
> I played a bit today with variations of this patch that will keep the
> deferred count per node. I will rebase the whole series ontop of it (the
> changes can get quite disruptive) and post. I want to believe that
> after this, all our regression problems will be gone (famous last words).
> 
> As I have told you, I wasn't seeing problems like you are, and
> speculated that this was due to the disk speeds. While this is true,
> the patch I came up with makes my workload actually a lot better.
> While my caches weren't being emptied, they were being slightly depleted
> and then slowly filled again. With my new patch, it is almost
> a straight line throughout the whole find run. There is a dent here and
> there eventually, but it recovers quickly. It takes some time as well
> for steady state to be reached, but once it is, we have all variables
> in the equation (dentries, inodes, etc) basically flat. So I guess it
> works, and I am confident that it will make your workload better.

Sounds promising. A non-numa system gives dead flat linesonthat
workload, and that's how I want a numa system to behave as well when
there is even pressure applied across all nodes.

Sorry for not doing more here - I've been flat out the last couple
of days with XFS CRC stuff. Let me know when you have a tree rebased
as far as this patch and I'll run some tests here....

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
