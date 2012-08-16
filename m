Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 2F7806B0081
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 17:13:05 -0400 (EDT)
Message-ID: <502D61E1.8040704@redhat.com>
Date: Thu, 16 Aug 2012 17:10:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/6] memcg: vfs isolation in memory cgroup
References: <1345150417-30856-1-git-send-email-yinghan@google.com>
In-Reply-To: <1345150417-30856-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, dchinner@redhat.com

On 08/16/2012 04:53 PM, Ying Han wrote:
> The patchset adds the functionality of isolating the vfs slab objects per-memcg
> under reclaim. This feature is a *must-have* after the kernel slab memory
> accounting which starts charging the slab objects into individual memcgs. The
> existing per-superblock shrinker doesn't work since it will end up reclaiming
> slabs being charged to other memcgs.

> The patch now is only handling dentry cache by given the nature dentry pinned
> inode. Based on the data we've collected, that contributes the main factor of
> the reclaimable slab objects. We also could make a generic infrastructure for
> all the shrinkers (if needed).

Dave Chinner has some prototype code for that.

As an aside, the slab LRUs can also keep
recent_scanned, recent_rotated and recent_pressure
statistics, so we can balance pressure between the
normal page LRUs and the slab LRUs in the exact
same way my patch series balances pressure between
cgroups.

This could be important, because the slab LRUs
span multiple memory zones, while the normal page
LRUs only live in one memory zone each.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
