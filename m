Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id AF1D96B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 03:27:19 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 16ECE3EE0C2
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:27:18 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0009845DE52
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:27:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D852C45DE50
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:27:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C8E371DB802C
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:27:17 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BB761DB8038
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:27:17 +0900 (JST)
Message-ID: <515936B5.8070501@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 16:26:45 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-3-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

(2013/03/29 18:13), Glauber Costa wrote:
> In very low free kernel memory situations, it may be the case that we
> have less objects to free than our initial batch size. If this is the
> case, it is better to shrink those, and open space for the new workload
> then to keep them and fail the new allocations.
> 
> More specifically, this happens because we encode this in a loop with
> the condition: "while (total_scan >= batch_size)". So if we are in such
> a case, we'll not even enter the loop.
> 
> This patch modifies turns it into a do () while {} loop, that will
> guarantee that we scan it at least once, while keeping the behaviour
> exactly the same for the cases in which total_scan > batch_size.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reviewed-by: Dave Chinner <david@fromorbit.com>
> Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
> CC: "Theodore Ts'o" <tytso@mit.edu>
> CC: Al Viro <viro@zeniv.linux.org.uk>
> ---
>   mm/vmscan.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 

Doesn't this break

==
                /*
                 * copy the current shrinker scan count into a local variable
                 * and zero it so that other concurrent shrinker invocations
                 * don't also do this scanning work.
                 */
                nr = atomic_long_xchg(&shrinker->nr_in_batch, 0);
==

This xchg magic ?

Thnks,
-Kame


> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 88c5fed..fc6d45a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -280,7 +280,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>   					nr_pages_scanned, lru_pages,
>   					max_pass, delta, total_scan);
>   
> -		while (total_scan >= batch_size) {
> +		do {
>   			int nr_before;
>   
>   			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
> @@ -294,7 +294,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>   			total_scan -= batch_size;
>   
>   			cond_resched();
> -		}
> +		} while (total_scan >= batch_size);
>   
>   		/*
>   		 * move the unused scan count back into the shrinker in a
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
