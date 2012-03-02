Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 944CB6B007E
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 11:27:57 -0500 (EST)
Received: by bkwq16 with SMTP id q16so2239714bkw.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 08:27:55 -0800 (PST)
Date: Fri, 2 Mar 2012 20:27:53 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [RFC] memcg usage_in_bytes does not account file mapped and slab
 memory
Message-ID: <20120302162753.GA11748@oksana.dev.rtsoft.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, John Stultz <john.stultz@linaro.org>

... and thus is useless for low memory notifications.

Hi all!

While working on userspace low memory killer daemon (a supposed
substitution for the kernel low memory killer, i.e.
drivers/staging/android/lowmemorykiller.c), I noticed that current
cgroups memory notifications aren't suitable for such a daemon.

Suppose we want to install a notification when free memory drops below
8 MB. Logically (taking memory hotplug aside), using current usage_in_bytes
notifications we would install an event on 'total_ram - 8MB' threshold.

But as usage_in_bytes doesn't account file mapped memory and memory
used by kernel slab, the formula won't work.

Currently I use the following patch that makes things going:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 228d646..c8abdc5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3812,6 +3812,9 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 
        val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
        val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
+       val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
+       val += global_page_state(NR_SLAB_RECLAIMABLE);
+       val += global_page_state(NR_SLAB_UNRECLAIMABLE);


But here are some questions:

1. Is there any particular reason we don't currently account file mapped
   memory in usage_in_bytes?

   To me, MEM_CGROUP_STAT_FILE_MAPPED hunk seems logical even if we
   don't use it for lowmemory notifications.

   Plus, it seems that FILE_MAPPED _is_ accounted for the non-root
   cgroups, so I guess it's clearly a bug for the root memcg?

2. As for NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE, it seems that
   these numbers are only applicable for the root memcg.
   I'm not sure that usage_in_bytes semantics should actually account
   these, but I tend to think that we should.

All in all, not accounting both 1. and 2. looks like bugs to me.

But if for some reason we don't want to change usage_in_bytes, should
I just go ahead and implement a new cftype (say free_in_bytes), which
would account free memory as total_ram - cache - rss - mapped - slab,
with ability to install notifiers? That way we would also could solve
memory hotplug issue in the kernel, so that userland won't need to
bother with reinstalling lowmemory notifiers when memory added/removed.

Thanks!

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
