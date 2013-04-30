Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 5A6966B00E3
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 10:15:02 -0400 (EDT)
Date: Tue, 30 Apr 2013 15:14:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 05/31] dcache: remove dentries from LRU before putting
 on dispose list
Message-ID: <20130430141456.GE6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-6-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-6-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On Sat, Apr 27, 2013 at 03:19:01AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> One of the big problems with modifying the way the dcache shrinker
> and LRU implementation works is that the LRU is abused in several
> ways. One of these is shrink_dentry_list().
> 
> Basically, we can move a dentry off the LRU onto a different list
> without doing any accounting changes, and then use dentry_lru_prune()
> to remove it from what-ever list it is now on to do the LRU
> accounting at that point.
> 
> This makes it -really hard- to change the LRU implementation. The
> use of the per-sb LRU lock serialises movement of the dentries
> between the different lists and the removal of them, and this is the
> only reason that it works. If we want to break up the dentry LRU
> lock and lists into, say, per-node lists, we remove the only
> serialisation that allows this lru list/dispose list abuse to work.
> 
> To make this work effectively, the dispose list has to be isolated
> from the LRU list - dentries have to be removed from the LRU
> *before* being placed on the dispose list. This means that the LRU
> accounting and isolation is completed before disposal is started,
> and that means we can change the LRU implementation freely in
> future.
> 
> This means that dentries *must* be marked with DCACHE_SHRINK_LIST
> when they are placed on the dispose list so that we don't think that
> parent dentries found in try_prune_one_dentry() are on the LRU when
> the are actually on the dispose list. This would result in
> accounting the dentry to the LRU a second time. Hence
> dentry_lru_prune() has to handle the DCACHE_SHRINK_LIST case
> differently because the dentry isn't on the LRU list.
> 
> [ v2: don't decrement nr unused twice, spotted by Sha Zhengju ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
