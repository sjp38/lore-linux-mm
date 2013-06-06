Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id A2F5C6B0037
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 04:20:58 -0400 (EDT)
Message-ID: <51B04697.90106@parallels.com>
Date: Thu, 6 Jun 2013 12:21:43 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 11/35] list_lru: per-node list infrastructure
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <1370287804-3481-12-git-send-email-glommer@openvz.org> <20130605160804.be25fb655f075efe70ec57c0@linux-foundation.org> <20130606032107.GQ29338@dastard>
In-Reply-To: <20130606032107.GQ29338@dastard>
Content-Type: multipart/mixed;
	boundary="------------060106060804000607000707"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

--------------060106060804000607000707
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 06/06/2013 07:21 AM, Dave Chinner wrote:
>> It's unclear that active_nodes is really needed - we could just iterate
>> > across all items in list_lru.node[].  Are we sure that the correct
>> > tradeoff decision was made here?
> Yup. Think of all the cache line misses that checking
> node[x].nr_items != 0 entails. If MAX_NUMNODES = 1024, there's 1024
> cacheline misses right there. The nodemask is a much more cache
> friendly method of storing active node state.
> 
> not to mention that for small machines with a large MAX_NUMNODES,
> we'd be checking nodes that never have items stored on them...
> 
>> > What's the story on NUMA node hotplug, btw?
> Do we care? hotplug doesn't change MAX_NUMNODES, and if you are
> removing a node you have to free all the memory on the node,
> so that should already be tken care of by external code....
> 

Mel have already complained about this.
I have a patch that makes it dynamic but I didn't include it in here
because the series was already too big. I was also hoping to get it
ontop of the others, to avoid disruption.

I am attaching here for your appreciation.

For the record, nr_node_ids is firmware provided and it is actually
possible nodes, not online nodes. So hotplug won't change that.



--------------060106060804000607000707
Content-Type: text/x-patch;
	name="0001-list_lru-dynamically-adjust-node-arrays.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-list_lru-dynamically-adjust-node-arrays.patch"


--------------060106060804000607000707--
