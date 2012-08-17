Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 4E0E56B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:31:16 -0400 (EDT)
Message-ID: <502DD663.2020504@parallels.com>
Date: Fri, 17 Aug 2012 09:28:03 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/6] memcg: pass priority to prune_icache_sb()
References: <1345150430-30910-1-git-send-email-yinghan@google.com>
In-Reply-To: <1345150430-30910-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On 08/17/2012 12:53 AM, Ying Han wrote:
> The same patch posted two years ago at:
> http://permalink.gmane.org/gmane.linux.kernel.mm/55467
> 
> No change since then and re-post it now mainly because it is part of the
> patchset I have internally. Also, the issue that the patch addresses would
> be more problematic after the patchset.
> 
> Two changes included:
> 1. only remove inode with pages in its mapping when reclaim priority hits 0.
> 
> It helps the situation when shrink_slab() is being too agressive, it ends up
> removing the inode as well as all the pages associated with the inode.
> Especially when single inode has lots of pages points to it.
> 
> The problem was observed on a production workload we run, where it has small
> number of large files. Page reclaim won't blow away the inode which is pinned
> by dentry which in turn is pinned by open file descriptor. But if the
> application is openning and closing the fds, it has the chance to trigger
> the issue. The application will experience performance hit when that happens.
> 
> After the whole patchset, the code will call the shrinker more often by adding
> shrink_slab() into target reclaim. So the performance hit will be more likely
> to be observed.
> 
> 2. avoid wrapping up when scanning inode lru.
> 
> The target_scan_count is calculated based on the userpage lru activity,
> which could be bigger than the inode lru size. avoid scanning the same
> inode twice by remembering the starting point for each scan.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

I don't doubt the problem, but having a field in sc that is used for
only one shrinker, and specifically to address a corner case, sounds
like a bit of a hack.

Wouldn't it be possible to make sure that such inodes are in the end of
the shrinkable list, so they are effectively left for last without
messing with priorities?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
