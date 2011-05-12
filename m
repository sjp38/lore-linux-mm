Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0297E6B0026
	for <linux-mm@kvack.org>; Thu, 12 May 2011 11:33:25 -0400 (EDT)
Message-ID: <4DCBFDB9.10209@redhat.com>
Date: Thu, 12 May 2011 11:33:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [rfc patch 2/6] vmscan: make distinction between memcg reclaim
 and LRU list selection
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org> <1305212038-15445-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1305212038-15445-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/12/2011 10:53 AM, Johannes Weiner wrote:
> The reclaim code has a single predicate for whether it currently
> reclaims on behalf of a memory cgroup, as well as whether it is
> reclaiming from the global LRU list or a memory cgroup LRU list.
>
> Up to now, both cases always coincide, but subsequent patches will
> change things such that global reclaim will scan memory cgroup lists.
>
> This patch adds a new predicate that tells global reclaim from memory
> cgroup reclaim, and then changes all callsites that are actually about
> global reclaim heuristics rather than strict LRU list selection.
>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>
> ---
>   mm/vmscan.c |   96 ++++++++++++++++++++++++++++++++++------------------------
>   1 files changed, 56 insertions(+), 40 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f6b435c..ceeb2a5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -104,8 +104,12 @@ struct scan_control {
>   	 */
>   	reclaim_mode_t reclaim_mode;
>
> -	/* Which cgroup do we reclaim from */
> -	struct mem_cgroup *mem_cgroup;
> +	/*
> +	 * The memory cgroup we reclaim on behalf of, and the one we
> +	 * are currently reclaiming from.
> +	 */
> +	struct mem_cgroup *memcg;
> +	struct mem_cgroup *current_memcg;

I can't say I'm fond of these names.  I had to read the
rest of the patch to figure out that the old mem_cgroup
got renamed to current_memcg.

Would it be better to call them my_memcg and reclaim_memcg?

Maybe somebody else has better suggestions...

Other than the naming, no objection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
