Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 1CF106B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 09:19:53 -0400 (EDT)
Received: by ggm4 with SMTP id 4so7942802ggm.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 06:19:52 -0700 (PDT)
Date: Wed, 4 Jul 2012 21:19:42 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [RFC][PATCH 1/2] add res_counter_usage_safe
Message-ID: <20120704131941.GA21100@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <4FEC300A.7040209@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEC300A.7040209@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Wanpeng Li <liwp.linux@gmail.com>

On Thu, Jun 28, 2012 at 07:20:58PM +0900, Kamezawa Hiroyuki wrote:
>This series is a cleaned up patches discussed in a few days ago, the topic
>was how to make compaction works well even if there is a memcg under OOM.
>==
>memcg: add res_counter_usage_safe()
>
>I think usage > limit means a sign of BUG. But, sometimes,
>res_counter_charge_nofail() is very convenient. tcp_memcg uses it.
>And I'd like to use it for helping page migration.
>
>This patch adds res_counter_usage_safe() which returns min(usage,limit).
>By this we can use res_counter_charge_nofail() without breaking
>user experience.
>
>Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>---
> include/linux/res_counter.h |    2 ++
> kernel/res_counter.c        |   15 +++++++++++++++
> net/ipv4/tcp_memcontrol.c   |    2 +-
> 3 files changed, 18 insertions(+), 1 deletions(-)
>
>diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
>index 7d7fbe2..a6f8cc5 100644
>--- a/include/linux/res_counter.h
>+++ b/include/linux/res_counter.h
>@@ -226,4 +226,6 @@ res_counter_set_soft_limit(struct res_counter *cnt,
> 	return 0;
> }
> 
>+u64 res_counter_usage_safe(struct res_counter *cnt);
>+
> #endif
>diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>index ad581aa..e84149b 100644
>--- a/kernel/res_counter.c
>+++ b/kernel/res_counter.c
>@@ -171,6 +171,21 @@ u64 res_counter_read_u64(struct res_counter *counter, int member)
> }
> #endif
> 
>+/*
>+ * Returns usage. If usage > limit, limit is returned.
>+ * This is useful not to break user experiance if the excess
                                      ^^^^^^^^
/experiance/experience
>+ * is temporal.
>+ */
>+u64 res_counter_usage_safe(struct res_counter *counter)
>+{
>+	u64 usage, limit;
>+
>+	limit = res_counter_read_u64(counter, RES_LIMIT);
>+	usage = res_counter_read_u64(counter, RES_USAGE);
>+
>+	return min(usage, limit);
>+}
>+
> int res_counter_memparse_write_strategy(const char *buf,
> 					unsigned long long *res)
> {
>diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
>index b6f3583..a73dce6 100644
>--- a/net/ipv4/tcp_memcontrol.c
>+++ b/net/ipv4/tcp_memcontrol.c
>@@ -180,7 +180,7 @@ static u64 tcp_read_usage(struct mem_cgroup *memcg)
> 		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
> 
> 	tcp = tcp_from_cgproto(cg_proto);
>-	return res_counter_read_u64(&tcp->tcp_memory_allocated, RES_USAGE);
>+	return res_counter_usage_safe(&tcp->tcp_memory_allocated);
> }
> 
> static u64 tcp_cgroup_read(struct cgroup *cont, struct cftype *cft)
>-- 
>1.7.4.1
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
