Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id DF8A06B00BB
	for <linux-mm@kvack.org>; Wed, 29 May 2013 09:05:41 -0400 (EDT)
Date: Wed, 29 May 2013 15:05:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with
 zone shrinking code
Message-ID: <20130529130538.GD10224@dhcp22.suse.cz>
References: <20130517160247.GA10023@cmpxchg.org>
 <1369674791-13861-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369674791-13861-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 27-05-13 19:13:08, Michal Hocko wrote:
[...]
> Nevertheless I have encountered an issue while testing the huge number
> of groups scenario. And the issue is not limitted to only to this
> scenario unfortunately. As memcg iterators use per node-zone-priority
> cache to prevent from over reclaim it might quite easily happen that
> the walk will not visit all groups and will terminate the loop either
> prematurely or skip some groups. An example could be the direct reclaim
> racing with kswapd. This might cause that the loop misses over limit
> groups so no pages are scanned and so we will fall back to all groups
> reclaim.

And after some more testing and head scratching it turned out that
fallbacks to pass#2 I was seeing are caused by something else. It is
not race between iterators but rather reclaiming from zone DMA which
has troubles to scan anything despite there are pages on LRU and so we
fall back. I have to look into that more but what-ever the issue is it
shouldn't be related to the patch series.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
