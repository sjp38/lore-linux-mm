Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 763DD6B0038
	for <linux-mm@kvack.org>; Thu,  9 May 2013 17:01:24 -0400 (EDT)
Message-ID: <518C0ECF.8010302@parallels.com>
Date: Fri, 10 May 2013 01:02:07 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 08/31] list: add a new LRU list type
References: <1368079608-5611-1-git-send-email-glommer@openvz.org> <1368079608-5611-9-git-send-email-glommer@openvz.org> <20130509133742.GW11497@suse.de>
In-Reply-To: <20130509133742.GW11497@suse.de>
Content-Type: multipart/mixed;
	boundary="------------030502060200010009090907"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

--------------030502060200010009090907
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit

On 05/09/2013 05:37 PM, Mel Gorman wrote:
> On Thu, May 09, 2013 at 10:06:25AM +0400, Glauber Costa wrote:
>> From: Dave Chinner <dchinner@redhat.com>
>>
>> Several subsystems use the same construct for LRU lists - a list
>> head, a spin lock and and item count. They also use exactly the same
>> code for adding and removing items from the LRU. Create a generic
>> type for these LRU lists.
>>
>> This is the beginning of generic, node aware LRUs for shrinkers to
>> work with.
>>
>> [ glommer: enum defined constants for lru. Suggested by gthelen,
>>   don't relock over retry ]
>> Signed-off-by: Dave Chinner <dchinner@redhat.com>
>> Signed-off-by: Glauber Costa <glommer@openvz.org>
>> Reviewed-by: Greg Thelen <gthelen@google.com>
>>>
>>> <SNIP>
>>>
>> +
>> +unsigned long
>> +list_lru_walk(
>> +	struct list_lru *lru,
>> +	list_lru_walk_cb isolate,
>> +	void		*cb_arg,
>> +	long		nr_to_walk)
>> +{
>> +	struct list_head *item, *n;
>> +	unsigned long removed = 0;
>> +
>> +	spin_lock(&lru->lock);
>> +restart:
>> +	list_for_each_safe(item, n, &lru->list) {
>> +		enum lru_status ret;
>> +
>> +		if (nr_to_walk-- < 0)
>> +			break;
>> +
>> +		ret = isolate(item, &lru->lock, cb_arg);
>> +		switch (ret) {
>> +		case LRU_REMOVED:
>> +			lru->nr_items--;
>> +			removed++;
>> +			break;
>> +		case LRU_ROTATE:
>> +			list_move_tail(item, &lru->list);
>> +			break;
>> +		case LRU_SKIP:
>> +			break;
>> +		case LRU_RETRY:
>> +			goto restart;
>> +		default:
>> +			BUG();
>> +		}
>> +	}
> 
> What happened your suggestion to only retry once for each object to
> avoid any possibility of infinite looping or stalling for prolonged
> periods of time waiting on XFS to do something?
> 
Sorry. It wasn't clear for me if you were just trying to make sure we
had a way out in case it proves to be a problem, or actually wanted a
change.

In any case, I cannot claim to be as knowledgeable as Dave in the
subtleties of such things in the final behavior of the shrinker. Dave,
can you give us your input here?

I also have another recent observation on this:

The main difference between LRU_SKIP and LRU_RETRY is that LRU_RETRY
will go back to the beginning of the list, and start scanning it again.

This is *not* the same behavior we had before, where we used to read:

        for (nr_scanned = nr_to_scan; nr_scanned >= 0; nr_scanned--) {
                struct inode *inode;
                [ ... ]

                if (inode_has_buffers(inode) || inode->i_data.nrpages) {
                        __iget(inode);
                        [ ... ]
                        iput(inode);
                        spin_lock(&sb->s_inode_lru_lock);

                        if (inode != list_entry(sb->s_inode_lru.next,
                                                struct inode, i_lru))
                                continue; <=====
                        /* avoid lock inversions with trylock */
                        if (!spin_trylock(&inode->i_lock))
                                continue; <=====
                        if (!can_unuse(inode)) {
                                spin_unlock(&inode->i_lock);
                                continue; <=====
                        }
                }

It is my interpretation that we in here, we won't really reset the
search, but just skip this inode.

Another problem is that by restarting the search the way we are doing
now, we actually decrement nr_to_walk twice in case of a retry. By doing
a retry-once test, we can actually move nr_to_walk to the end of the
switch statement, which has the good side effect of getting rid of the
reason we had to allow it to go negative.

How about we fold the following attached patch to this one? (I would
still have to give it a round of testing)


--------------030502060200010009090907
Content-Type: text/x-patch; name="lru.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="lru.patch"

diff --git a/lib/list_lru.c b/lib/list_lru.c
index da9b837..4aa069b 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -195,12 +195,10 @@ list_lru_walk_node(
 	unsigned long isolated = 0;
 
 	spin_lock(&nlru->lock);
-restart:
 	list_for_each_safe(item, n, &nlru->list) {
+		bool first_pass = true;
 		enum lru_status ret;
-
-		if ((*nr_to_walk)-- < 0)
-			break;
+restart:
 
 		ret = isolate(item, &nlru->lock, cb_arg);
 		switch (ret) {
@@ -217,10 +215,17 @@ restart:
 		case LRU_SKIP:
 			break;
 		case LRU_RETRY:
+			if (!first_pass)
+				break;
+			first_pass = true;
 			goto restart;
 		default:
 			BUG();
 		}
+
+		if ((*nr_to_walk)-- == 0)
+			break;
+
 	}
 	spin_unlock(&nlru->lock);
 	return isolated;

--------------030502060200010009090907--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
