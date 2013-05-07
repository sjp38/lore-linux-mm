Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id B2DD86B00D8
	for <linux-mm@kvack.org>; Tue,  7 May 2013 09:46:16 -0400 (EDT)
Message-ID: <518905D4.8080208@parallels.com>
Date: Tue, 7 May 2013 17:47:00 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 09/31] inode: convert inode lru list to generic lru
 list code.
References: <1367018367-11278-1-git-send-email-glommer@openvz.org> <1367018367-11278-10-git-send-email-glommer@openvz.org> <20130430154649.GI6415@suse.de>
In-Reply-To: <20130430154649.GI6415@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On 04/30/2013 07:46 PM, Mel Gorman wrote:
> On Sat, Apr 27, 2013 at 03:19:05AM +0400, Glauber Costa wrote:
>> From: Dave Chinner <dchinner@redhat.com>
>>
>> [ glommer: adapted for new LRU return codes ]
>> Signed-off-by: Dave Chinner <dchinner@redhat.com>
>> Signed-off-by: Glauber Costa <glommer@openvz.org>
> 
> Looks mostly mechanical with the main mess in the conversion of the
> isolate function.
> 
>> +	if (inode_has_buffers(inode) || inode->i_data.nrpages) {
>> +		__iget(inode);
>> +		spin_unlock(&inode->i_lock);
>> +		spin_unlock(lru_lock);
>> +		if (remove_inode_buffers(inode)) {
>> +			unsigned long reap;
>> +			reap = invalidate_mapping_pages(&inode->i_data, 0, -1);
>> +			if (current_is_kswapd())
>> +				__count_vm_events(KSWAPD_INODESTEAL, reap);
>> +			else
>> +				__count_vm_events(PGINODESTEAL, reap);
>> +			if (current->reclaim_state)
>> +				current->reclaim_state->reclaimed_slab += reap;
>>  		}
>> +		iput(inode);
>> +		spin_lock(lru_lock);
>> +		return LRU_RETRY;
>> +	}
> 
> Only concern is this and whether it can cause the lru_list_walk to
> infinite loop if the inode is being continually used and the LRU list is
> too small to win the race.
> 
The way I read, this situation only happens when we have pending
buffers, and before returning LRU_RETRY, we do our best to release it.
That means that eventually, it will be released.

Now, of course it is hard to determine how long it will going to take,
and that can take a while in small LRUs. One way to avoid this, would be
to use a new flag in the inode. Set it before we return LRU_RETRY, and
don't retry twice.

I actually think this is sensible, but I am talking from the top of my
head. I haven't really measured how many retries does it usually take
for us to be able to free it.

Another option would be to just return LRU_SKIP and leave it to the next
shrinking cycle to free it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
