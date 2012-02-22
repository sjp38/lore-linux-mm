Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 0FC536B0103
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 20:26:47 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9DFA23EE0B6
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 10:26:45 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 86E6B45DE5A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 10:26:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 71A1345DE54
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 10:26:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6305E1DB8055
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 10:26:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1956F1DB8050
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 10:26:45 +0900 (JST)
Date: Wed, 22 Feb 2012 10:25:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] chained slab caches: move pages to a different
 cache when a cache is destroyed.
Message-Id: <20120222102512.021d9d54.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1329824079-14449-5-git-send-email-glommer@parallels.com>
References: <1329824079-14449-1-git-send-email-glommer@parallels.com>
	<1329824079-14449-5-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Paul Turner <pjt@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Tue, 21 Feb 2012 15:34:36 +0400
Glauber Costa <glommer@parallels.com> wrote:

> In the context of tracking kernel memory objects to a cgroup, the
> following problem appears: we may need to destroy a cgroup, but
> this does not guarantee that all objects inside the cache are dead.
> This can't be guaranteed even if we shrink the cache beforehand.
> 
> The simple option is to simply leave the cache around. However,
> intensive workloads may have generated a lot of objects and thus
> the dead cache will live in memory for a long while.
> 
> Scanning the list of objects in the dead cache takes time, and
> would probably require us to lock the free path of every objects
> to make sure we're not racing against the update.
> 
> I decided to give a try to a different idea then - but I'd be
> happy to pursue something else if you believe it would be better.
> 
> Upon memcg destruction, all the pages on the partial list
> are moved to the new slab (usually the parent memcg, or root memcg)
> When an object is freed, there are high stakes that no list locks
> are needed - so this case poses no overhead. If list manipulation
> is indeed needed, we can detect this case, and perform it
> in the right slab.
> 
> If all pages were residing in the partial list, we can free
> the cache right away. Otherwise, we do it when the last cache
> leaves the full list.
> 

How about starting from 'don't handle slabs on dead memcg' 
if shrink_slab() can find them....

This "move" complicates all implementation, I think...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
