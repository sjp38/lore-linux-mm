Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id C618B6B00AA
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 03:25:25 -0400 (EDT)
Date: Wed, 12 Sep 2012 09:25:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/memcontrol.c: Remove duplicate inclusion of sock.h
 file
Message-ID: <20120912072520.GB17516@dhcp22.suse.cz>
References: <1347350934-17712-1-git-send-email-sachin.kamat@linaro.org>
 <20120911095200.GB8058@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120911095200.GB8058@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sachin Kamat <sachin.kamat@linaro.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

Just realized that Glauber is not in the CC list. Glauber, could you
have a look? The thread started here:
http://www.spinics.net/lists/linux-mm/msg41725.html

Thanks!

On Tue 11-09-12 11:52:00, Michal Hocko wrote:
> On Tue 11-09-12 13:38:54, Sachin Kamat wrote:
> > net/sock.h is included unconditionally at the beginning of the file.
> > Hence, another conditional include is not required.
> 
> I guess we can do little bit better. What do you think about the
> following?  I have compile tested this with:
> - CONFIG_INET=y && CONFIG_MEMCG_KMEM=n
> - CONFIG_MEMCG_KMEM=y
> ---
> From 83c5a97e893b5379b7e93cfdc933d5e37756e70a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Tue, 11 Sep 2012 10:38:42 +0200
> Subject: [PATCH] memcg: clean up networking headers file inclusion
> 
> Memory controller doesn't need anything from the networking stack unless
> CONFIG_MEMCG_KMEM is selected.
> Now we are including net/sock.h and net/tcp_memcontrol.h unconditionally
> which is not necessary. Moreover struct mem_cgroup contains tcp_mem even
> if CONFIG_MEMCG_KMEM is not selected which is not necessary.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 795e525..85ec9ff 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -50,8 +50,12 @@
>  #include <linux/cpu.h>
>  #include <linux/oom.h>
>  #include "internal.h"
> +
> +#ifdef CONFIG_MEMCG_KMEM
>  #include <net/sock.h>
> +#include <net/ip.h>
>  #include <net/tcp_memcontrol.h>
> +#endif
>  
>  #include <asm/uaccess.h>
>  
> @@ -326,7 +330,7 @@ struct mem_cgroup {
>  	struct mem_cgroup_stat_cpu nocpu_base;
>  	spinlock_t pcp_counter_lock;
>  
> -#ifdef CONFIG_INET
> +#ifdef CONFIG_MEMCG_KMEM
>  	struct tcp_memcontrol tcp_mem;
>  #endif
>  };
> @@ -413,8 +417,6 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>  
>  /* Writing them here to avoid exposing memcg's inner layout */
>  #ifdef CONFIG_MEMCG_KMEM
> -#include <net/sock.h>
> -#include <net/ip.h>
>  
>  static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
>  void sock_update_memcg(struct sock *sk)
> -- 
> 1.7.10.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
