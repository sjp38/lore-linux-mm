Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A659C6B0070
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 19:03:57 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A74053EE0AE
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 09:03:55 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AE2C45DE52
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 09:03:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 71D6145DE4D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 09:03:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 632AE1DB803E
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 09:03:55 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A5291DB802F
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 09:03:55 +0900 (JST)
Message-ID: <50A2DFDC.90402@jp.fujitsu.com>
Date: Wed, 14 Nov 2012 09:03:40 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/5] memcg: synchronize per-zone iterator access by a spinlock
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz> <1352820639-13521-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1352820639-13521-2-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

(2012/11/14 0:30), Michal Hocko wrote:
> per-zone per-priority iterator is aimed at coordinating concurrent
> reclaimers on the same hierarchy (or the global reclaim when all
> groups are reclaimed) so that all groups get reclaimed evenly as
> much as possible. iter->position holds the last css->id visited
> and iter->generation signals the completed tree walk (when it is
> incremented).
> Concurrent reclaimers are supposed to provide a reclaim cookie which
> holds the reclaim priority and the last generation they saw. If cookie's
> generation doesn't match the iterator's view then other concurrent
> reclaimer already did the job and the tree walk is done for that
> priority.
> 
> This scheme works nicely in most cases but it is not raceless. Two
> racing reclaimers can see the same iter->position and so bang on the
> same group. iter->generation increment is not serialized as well so a
> reclaimer can see an updated iter->position with and old generation so
> the iteration might be restarted from the root of the hierarchy.
> 
> The simplest way to fix this issue is to synchronise access to the
> iterator by a lock. This implementation uses per-zone per-priority
> spinlock which linearizes only directly racing reclaimers which use
> reclaim cookies so the effect of the new locking should be really
> minimal.
> 
> I have to note that I haven't seen this as a real issue so far. The
> primary motivation for the change is different. The following patch
> will change the way how the iterator is implemented and css->id
> iteration will be replaced cgroup generic iteration which requires
> storing mem_cgroup pointer into iterator and that requires reference
> counting and so concurrent access will be a problem.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
