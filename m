Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 186456B00DB
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 11:46:08 -0500 (EST)
Date: Tue, 17 Jan 2012 17:46:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] [PATCH 3/7 v2] memcg: remove PCG_MOVE_LOCK flag from
 pc->flags
Message-ID: <20120117164605.GB22142@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri 13-01-12 17:40:19, KAMEZAWA Hiroyuki wrote:
> 
> From 1008e84d94245b1e7c4d237802ff68ff00757736 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 12 Jan 2012 15:53:24 +0900
> Subject: [PATCH 3/7] memcg: remove PCG_MOVE_LOCK flag from pc->flags.
> 
> PCG_MOVE_LOCK bit is used for bit spinlock for avoiding race between
> memcg's account moving and page state statistics updates.
> 
> Considering page-statistics update, very hot path, this lock is
> taken only when someone is moving account (or PageTransHuge())

Outdated comment? THP is not an issue here.

> And, now, all moving-account between memcgroups (by task-move)
> are serialized.
> 
> So, it seems too costly to have 1bit per page for this purpose.
> 
> This patch removes PCG_MOVE_LOCK and add hashed rwlock array
> instead of it. This works well enough. Even when we need to
> take the lock, 

Hmmm, rwlocks are not popular these days very much. 
Anyway, can we rather make it (source) memcg (bit)spinlock instead. We
would reduce false sharing this way and would penalize only pages from
the moving group.

The patch seems to be correct but I do not like the rwlock part very
much. I would replace it if possible.

[...]

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
