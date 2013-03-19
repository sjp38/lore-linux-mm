Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 1CFE06B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 10:06:37 -0400 (EDT)
Date: Tue, 19 Mar 2013 15:06:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 4/5] memcg: do not call page_cgroup_init at system_boot
Message-ID: <20130319140635.GH7869@dhcp22.suse.cz>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
 <1362489058-3455-5-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1362489058-3455-5-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On Tue 05-03-13 17:10:57, Glauber Costa wrote:
> If we are not using memcg, there is no reason why we should allocate
> this structure, that will be a memory waste at best. We can do better
> at least in the sparsemem case, and allocate it when the first cgroup
> is requested. It should now not panic on failure, and we have to handle
> this right.

lookup_page_cgroup needs a special handling as well. Callers are not
prepared to get NULL and the current code would even explode with
!CONFIG_DEBUG_VM.

Anyway, agreed with what Kame said. This is really hard to read. Would
it be possible to split it up somehow - sorry for not being more helpful
here...

> flatmem case is a bit more complicated, so that one is left out for
> the moment.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/page_cgroup.h |  28 +++++----
>  init/main.c                 |   2 -
>  mm/memcontrol.c             |   3 +-
>  mm/page_cgroup.c            | 150 ++++++++++++++++++++++++--------------------
>  4 files changed, 99 insertions(+), 84 deletions(-)
> 
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
