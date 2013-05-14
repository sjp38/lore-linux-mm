Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 41D926B0069
	for <linux-mm@kvack.org>; Tue, 14 May 2013 03:37:35 -0400 (EDT)
Message-ID: <5191E9EA.9040709@parallels.com>
Date: Tue, 14 May 2013 11:38:18 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/31] kmemcg shrinkers
References: <1368382432-25462-1-git-send-email-glommer@openvz.org> <20130513071359.GM32675@dastard> <51909D84.7040800@parallels.com> <20130514014805.GA29466@dastard> <20130514052244.GC29466@dastard>
In-Reply-To: <20130514052244.GC29466@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org

On 05/14/2013 09:22 AM, Dave Chinner wrote:
> I've found the problem. dentry_kill() returns the current dentry if
> it cannot lock the dentry->d_inode or the dentry->d_parent, and when
> that happens try_prune_one_dentry() silently fails to prune the
> dentry.  But, at this point, we've already removed the dentry from
> both the LRU and the shrink list, and so it gets dropped on the
> floor.
> 
Great. I had already an idea that it had something to do with a dentry
being removed from the LRU and not being put back, but I was looking at
the wrong circumstance. oz, oz oi oi oi!

> patch 4 needs some work:
> 
> 	- fix the above leak shrink list leak
> 	- fix the scope of the sb locking inside shrink_dcache_sb()
> 	- remove the readditional of dentry_lru_prune().
I readded this just because there are more work that needs to be done
upon prune that is always the same. This is specially true in later
patches, IIRC. I don't think dentry_lru_prune() has anything to do
directly with the problem we are seeing now, and this is just a question
of duplicated code vs not. But I am ultimately fine either way.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
