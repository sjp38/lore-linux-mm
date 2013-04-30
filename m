Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 234316B00F1
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 11:46:54 -0400 (EDT)
Date: Tue, 30 Apr 2013 16:46:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 09/31] inode: convert inode lru list to generic lru
 list code.
Message-ID: <20130430154649.GI6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-10-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-10-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On Sat, Apr 27, 2013 at 03:19:05AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> [ glommer: adapted for new LRU return codes ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>

Looks mostly mechanical with the main mess in the conversion of the
isolate function.

> +	if (inode_has_buffers(inode) || inode->i_data.nrpages) {
> +		__iget(inode);
> +		spin_unlock(&inode->i_lock);
> +		spin_unlock(lru_lock);
> +		if (remove_inode_buffers(inode)) {
> +			unsigned long reap;
> +			reap = invalidate_mapping_pages(&inode->i_data, 0, -1);
> +			if (current_is_kswapd())
> +				__count_vm_events(KSWAPD_INODESTEAL, reap);
> +			else
> +				__count_vm_events(PGINODESTEAL, reap);
> +			if (current->reclaim_state)
> +				current->reclaim_state->reclaimed_slab += reap;
>  		}
> +		iput(inode);
> +		spin_lock(lru_lock);
> +		return LRU_RETRY;
> +	}

Only concern is this and whether it can cause the lru_list_walk to
infinite loop if the inode is being continually used and the LRU list is
too small to win the race.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
