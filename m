Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 152476B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 03:28:50 -0400 (EDT)
Message-ID: <5195DC59.8000205@parallels.com>
Date: Fri, 17 May 2013 11:29:29 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 12/31] fs: convert inode and dentry shrinking to be
 node aware
References: <1368382432-25462-1-git-send-email-glommer@openvz.org> <1368382432-25462-13-git-send-email-glommer@openvz.org> <20130514095200.GI29466@dastard> <5193A95E.70205@parallels.com> <20130516000216.GC24635@dastard> <5195302A.2090406@parallels.com> <20130517005134.GK24635@dastard>
In-Reply-To: <20130517005134.GK24635@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On 05/17/2013 04:51 AM, Dave Chinner wrote:
>> +		total_scan /= nr_active_nodes;
>> > +		for_each_node_mask(nid, shrinkctl->nodes_to_scan) {
>> > +			if (total_scan > 0)
>> > +				new_nr += atomic_long_add_return(total_scan / nr_active_nodes,
>> > +						&shrinker->nr_in_batch[nid]);
> (you do the total_scan / nr_active_nodes twice here)
> 

Thanks. Indeed. As I told you, I boot tested this, but since I haven't
seen the behavior you are seeing, I didn't give it a lot of testing.

I am a lot more interested in finding out if this approach is worth it.
So if you could give something like this a go, that would be awesome.


>> > +			else
>> > +				new_nr += atomic_long_read(&shrinker->nr_in_batch[nid]);
>> >  
>> > +		}
> I don't think this solves the problem entirely - it still aggregates
> multiple nodes together into the one count. It might be better, but
> it will still bleed the deferred count from a single node into other
> nodes that have no deferred count.
> 

Yes, but only the nodes that are being scan in this moment, no?
If the shrinker is deferring because we returned -1, this means that
nobody was able to shrink anything.

> Perhaps we need to factor this code a little first - separate the
> calculation from the per-shrinker loop, so we can do something like:
> 
> shrink_slab_node(shr, sc, nid)
> {
> 	nodemask_clear(sc->nodemask);
> 	nodemask_set(sc->nodemask, nid)
> 	for each shrinker {
> 		deferred_count = atomic_long_xchg(&shr->deferred_scan[nid], 0);
> 
> 		deferred_count = __shrink_slab(shr, sc, deferred_count);
> 
> 		atomic_long_add(deferred_count, &shr->deferred_scan[nid]);
> 	}
> }
> 
> And the existing shrink_slab function becomes something like:
> 
> shrink_slab(shr, sc, nodemask)
> {
> 	if (shr->flags & SHRINKER_NUMA_AWARE) {
> 		for_each_node_mask(nid, nodemask)
> 			shrink_slab_node(shr, sc, nid)
> 		return;
> 	}
I am fine with a numa aware flag.

> 
> 	for each shrinker {
> 		deferred_count = atomic_long_xchg(&shr->deferred_scan[0], 0);
> 
> 		deferred_count = __shrink_slab(shr, sc, deferred_count);
> 
> 		atomic_long_add(deferred_count, &shr->deferred_scan[0]);
> 	}
> }
> 
> This then makes the deferred count properly node aware when the
> underlying shrinker needs it to be, and prevents bleed from one node
> to another. I'd much prefer to see us move to an explicitly node
> based iteration like this than try to hack more stuff into
> shrink_slab() and confuse it further.
> 

Except that shrink_slab_node would also defer work, right?

> The only thing I don't like about this is the extra nodemask needed,
> which, like the scan control, would have to sit on the stack.
> Suggestions for avoiding that problem are welcome.. :)
>

I will try to come up with a patch to do all this, and then we can
concretely discuss.
You are also of course welcome to do so as well =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
