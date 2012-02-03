Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id E49EA6B002C
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 11:11:42 -0500 (EST)
Date: Fri, 3 Feb 2012 17:11:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix up documentation on global LRU.
Message-ID: <20120203161140.GC13461@tiehlicka.suse.cz>
References: <1328233033-14246-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1328233033-14246-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Thu 02-02-12 17:37:13, Ying Han wrote:
> In v3.3-rc1, the global LRU has been removed with commit
> "mm: make per-memcg LRU lists exclusive". The patch fixes up the memcg docs.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

For the global LRU removal
Acked-by: Michal Hocko <mhocko@suse.cz>

see the comment about the swap extension bellow.

Thanks

> ---
>  Documentation/cgroups/memory.txt |   25 ++++++++++++-------------
>  1 files changed, 12 insertions(+), 13 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 4c95c00..847a2a4 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
[...]
> @@ -209,19 +208,19 @@ In this case, setting memsw.limit_in_bytes=3G will prevent bad use of swap.
>  By using memsw limit, you can avoid system OOM which can be caused by swap
>  shortage.
>  
> -* why 'memory+swap' rather than swap.
> -The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
> -to move account from memory to swap...there is no change in usage of
> -memory+swap. In other words, when we want to limit the usage of swap without
> -affecting global LRU, memory+swap limit is better than just limiting swap from
> -OS point of view.
> -
>  * What happens when a cgroup hits memory.memsw.limit_in_bytes
>  When a cgroup hits memory.memsw.limit_in_bytes, it's useless to do swap-out
>  in this cgroup. Then, swap-out will not be done by cgroup routine and file
> -caches are dropped. But as mentioned above, global LRU can do swapout memory
> -from it for sanity of the system's memory management state. You can't forbid
> -it by cgroup.
> +caches are dropped.
> +
> +TODO:
> +* use 'memory+swap' rather than swap was due to existence of global LRU. 

Not really. It also helped inter-cgroup behavior. Consider an (anon) mem
hog which goes wild. You could end up with a full swap until it gets
killed which might be quite some time. With the swap extension, on the
other hand, you are able to stop it before it does too much damage.


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
