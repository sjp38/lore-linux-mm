Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 9948A6B00FB
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 15:59:59 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so6472480bkw.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:59:57 -0700 (PDT)
Message-ID: <4F679039.6070609@openvz.org>
Date: Mon, 19 Mar 2012 23:59:53 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/3] page cgroup diet
References: <4F66E6A5.10804@jp.fujitsu.com>
In-Reply-To: <4F66E6A5.10804@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "suleiman@google.com" <suleiman@google.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, Tejun Heo <tj@kernel.org>

KAMEZAWA Hiroyuki wrote:
> This is just an RFC...test is not enough yet.
> 
> I know it's merge window..this post is just for sharing idea.
> 
> This patch merges pc->flags and pc->mem_cgroup into a word. Then,
> memcg's overhead will be 8bytes per page(4096bytes?).
> 
> Because this patch will affect all memory cgroup developers, I'd like to
> show patches before MM Summit. I think we can agree the direction to
> reduce size of page_cgroup..and finally integrate into 'struct page'
> (and remove cgroup_disable= boot option...)
> 
> Patch 1/3 - introduce pc_to_mem_cgroup and hide pc->mem_cgroup
> Patch 2/3 - remove pc->mem_cgroup
> Patch 3/3 - remove memory barriers.
> 
> I'm now wondering when this change should be merged....
> 

This is cool, but maybe we should skip this temporary step and merge all this stuff into page->flags.
I think we can replace zone-id and node-id in page->flags with cumulative dynamically allocated lruvec-id,
so there will be enough space for hundred cgroups even on 32-bit systems.

After lru_lock splitting page to lruvec translation will be much frequently used than page to zone,
so page->zone and page->node translations can be implemented as page->lruvec->zone and page->lruvec->node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
