Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAFC87Kd020908
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 15 Nov 2008 21:08:07 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6608B45DE50
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 21:08:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 435B445DE4F
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 21:08:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A8031DB803B
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 21:08:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CE4E31DB8037
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 21:08:06 +0900 (JST)
Message-ID: <30315.10.75.179.61.1226750886.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081115200400.1399c7e0.d-nishimura@mtf.biglobe.ne.jp>
References: <20081115183721.cfc1b80b.d-nishimura@mtf.biglobe.ne.jp><41265.10.75.179.62.1226745093.squirrel@webmail-b.css.fujitsu.com>
    <20081115200400.1399c7e0.d-nishimura@mtf.biglobe.ne.jp>
Date: Sat, 15 Nov 2008 21:08:06 +0900 (JST)
Subject: Re: [PATCH mmotm] memcg: make resize limit hold mutex
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:
> On Sat, 15 Nov 2008 19:31:33 +0900 (JST)
> "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> =====
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>
> mem_cgroup_resize_memsw_limit() try to hold memsw.lock while holding
> res.lock, so below message is showed when trying to write
> memory.memsw.limit_in_bytes file.
>
>
>     [ INFO: possible recursive locking detected ]
>     2.6.28-rc4-mm1-mmotm-2008-11-14-20-50-ef4e17ef #1
>
>     bash/4406 is trying to acquire lock:
>      (&counter->lock){....}, at: [<c0498408>]
> mem_cgroup_resize_memsw_limit+0x8d/0x113
>
>     but task is already holding lock:
>      (&counter->lock){....}, at: [<c04983d6>]
> mem_cgroup_resize_memsw_limit+0x5b/0x113
>
>     other info that might help us debug this:
>     1 lock held by bash/4406:
>      #0:  (&counter->lock){....}, at: [<c04983d6>]
> mem_cgroup_resize_memsw_limit+0x5b/0x113
>
>     stack backtrace:
>     Pid: 4406, comm: bash Not tainted
> 2.6.28-rc4-mm1-mmotm-2008-11-14-20-50-ef4e17ef #1
>     Call Trace:
>      [<c066e60f>] ? printk+0xf/0x18
>      [<c044d0c0>] __lock_acquire+0xc67/0x1353
>      [<c044d793>] ? __lock_acquire+0x133a/0x1353
>      [<c044d81c>] lock_acquire+0x70/0x97
>      [<c0498408>] ? mem_cgroup_resize_memsw_limit+0x8d/0x113
>      [<c0671519>] _spin_lock_irqsave+0x3a/0x6d
>      [<c0498408>] ? mem_cgroup_resize_memsw_limit+0x8d/0x113
>      [<c0498408>] mem_cgroup_resize_memsw_limit+0x8d/0x113
>      [<c0518a6c>] ? memparse+0x14/0x66
>      [<c0498594>] mem_cgroup_write+0x4a/0x50
>      [<c045e063>] cgroup_file_write+0x181/0x1c6
>      [<c0449e43>] ? lock_release_holdtime+0x1a/0x168
>      [<c04ec725>] ? security_file_permission+0xf/0x11
>      [<c049b5f0>] ? rw_verify_area+0x76/0x97
>      [<c045dee2>] ? cgroup_file_write+0x0/0x1c6
>      [<c049bce6>] vfs_write+0x8a/0x12e
>      [<c049be23>] sys_write+0x3b/0x60
>      [<c0403867>] sysenter_do_call+0x12/0x3f
>
>
> This patch define a new mutex and make both mem_cgroup_resize_limit and
> mem_cgroup_memsw_resize_limit hold it to remove spin_lock_irqsave.
>
>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Seems good.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> This patch can be applied after memcg-add-mem_cgroup_disabled-fix.patch.
>
>  mm/memcontrol.c |   40 ++++++++++++++++++++++++++--------------
>  1 files changed, 26 insertions(+), 14 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 09ce42a..691e052 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -35,6 +35,7 @@
>  #include <linux/vmalloc.h>
>  #include <linux/mm_inline.h>
>  #include <linux/page_cgroup.h>
> +#include <linux/mutex.h>
>  #include "internal.h"
>
>  #include <asm/uaccess.h>
> @@ -1147,27 +1148,38 @@ int mem_cgroup_shrink_usage(struct mm_struct *mm,
> gfp_t gfp_mask)
>  	return 0;
>  }
>
> +static DEFINE_MUTEX(set_limit_mutex);
>  int mem_cgroup_resize_limit(struct mem_cgroup *memcg, unsigned long long
> val)
>  {
>
>  	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
>  	int progress;
> +	u64 memswlimit;
>  	int ret = 0;
>
> -	if (do_swap_account) {
> -		if (val > memcg->memsw.limit)
> -			return -EINVAL;
> -	}
> -
> -	while (res_counter_set_limit(&memcg->res, val)) {
> +	while (retry_count) {
>  		if (signal_pending(current)) {
>  			ret = -EINTR;
>  			break;
>  		}
> -		if (!retry_count) {
> -			ret = -EBUSY;
> +		/*
> +		 * Rather than hide all in some function, I do this in
> +		 * open coded manner. You see what this really does.
> +		 * We have to guarantee mem->res.limit < mem->memsw.limit.
> +		 */
> +		mutex_lock(&set_limit_mutex);
> +		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> +		if (memswlimit < val) {
> +			ret = -EINVAL;
> +			mutex_unlock(&set_limit_mutex);
>  			break;
>  		}
> +		ret = res_counter_set_limit(&memcg->res, val);
> +		mutex_unlock(&set_limit_mutex);
> +
> +		if (!ret)
> +			break;
> +
>  		progress = try_to_free_mem_cgroup_pages(memcg,
>  				GFP_HIGHUSER_MOVABLE, false);
>  		if (!progress)
> @@ -1180,7 +1192,6 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup
> *memcg,
>  				unsigned long long val)
>  {
>  	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
> -	unsigned long flags;
>  	u64 memlimit, oldusage, curusage;
>  	int ret;
>
> @@ -1197,19 +1208,20 @@ int mem_cgroup_resize_memsw_limit(struct
> mem_cgroup *memcg,
>  		 * open coded manner. You see what this really does.
>  		 * We have to guarantee mem->res.limit < mem->memsw.limit.
>  		 */
> -		spin_lock_irqsave(&memcg->res.lock, flags);
> -		memlimit = memcg->res.limit;
> +		mutex_lock(&set_limit_mutex);
> +		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
>  		if (memlimit > val) {
> -			spin_unlock_irqrestore(&memcg->res.lock, flags);
>  			ret = -EINVAL;
> +			mutex_unlock(&set_limit_mutex);
>  			break;
>  		}
>  		ret = res_counter_set_limit(&memcg->memsw, val);
> -		oldusage = memcg->memsw.usage;
> -		spin_unlock_irqrestore(&memcg->res.lock, flags);
> +		mutex_unlock(&set_limit_mutex);
>
>  		if (!ret)
>  			break;
> +
> +		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  		try_to_free_mem_cgroup_pages(memcg, GFP_HIGHUSER_MOVABLE, true);
>  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  		if (curusage >= oldusage)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
