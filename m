Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 5D80C6B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 12:14:17 -0400 (EDT)
Message-ID: <51B0B58B.50203@parallels.com>
Date: Thu, 6 Jun 2013 20:15:07 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 11/35] list_lru: per-node list infrastructure
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <1370287804-3481-12-git-send-email-glommer@openvz.org> <20130605160804.be25fb655f075efe70ec57c0@linux-foundation.org>
In-Reply-To: <20130605160804.be25fb655f075efe70ec57c0@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On 06/06/2013 03:08 AM, Andrew Morton wrote:
>> +	for_each_node_mask(nid, lru->active_nodes) {
>> > +		struct list_lru_node *nlru = &lru->node[nid];
>> > +
>> > +		spin_lock(&nlru->lock);
>> > +		BUG_ON(nlru->nr_items < 0);
> This is buggy.
> 
> The bit in lru->active_nodes could be cleared by now.  We can only make
> this assertion if we recheck lru->active_nodes[nid] inside the
> spinlocked region.
> 
Sorry Andrew, how so ?
We will clear that flag if nr_items == 0. nr_items should *never* get to
be less than 0, it doesn't matter if the node is cleared or not.

If the node is cleared, we would expected the following statement to
expand to
   count += nlru->nr_items = 0;
   spin_unlock(&nlru->lock);

Which is actually cheaper than testing for the bit being still set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
