Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 54B016B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 09:11:20 -0400 (EDT)
Date: Thu, 22 Mar 2012 14:11:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 2/3] memcg: reduce size of struct page_cgroup.
Message-ID: <20120322131112.GC18665@tiehlicka.suse.cz>
References: <4F66E6A5.10804@jp.fujitsu.com>
 <4F66E7D7.4040406@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F66E7D7.4040406@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, suleiman@google.com, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

On Mon 19-03-12 17:01:27, KAMEZAWA Hiroyuki wrote:
> Now, page_cgroup->flags has only 3bits. Considering alignment of
> struct mem_cgroup, which is allocated by kmalloc(), we can encode
> pointer to mem_cgroup and flags into a word.
                                  into a single word.

> 
> After this patch, pc->flags is encoded as
> 
>  63                           2     0
>   | pointer to memcg..........|flags|

Looks good.
Acked-by: Michal Hocko <mhocko@suse.cz>

> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page_cgroup.h |   15 ++++++++++++---
>  1 files changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 92768cb..bca5447 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -1,6 +1,10 @@
>  #ifndef __LINUX_PAGE_CGROUP_H
>  #define __LINUX_PAGE_CGROUP_H
>  
> +/*
> + * Because these flags are encoded into ->flags with a pointer,
> + * we cannot have too much flags.
                     ^^^^^^^^^^^^^^ 
cannot have too many flags 
but an explicit BUILD_BUG_ON would be much more precise than a comment I
guess.

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
