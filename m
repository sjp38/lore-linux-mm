Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E7FA86B004A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 21:06:43 -0400 (EDT)
Date: Thu, 30 Jun 2011 18:06:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v2
Message-Id: <20110630180653.1df10f38.akpm@linux-foundation.org>
In-Reply-To: <20110701092059.be4400f7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110630130134.63a1dd37.akpm@linux-foundation.org>
	<20110701085013.4e8cbb02.kamezawa.hiroyu@jp.fujitsu.com>
	<20110701092059.be4400f7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, 1 Jul 2011 09:20:59 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 1 Jul 2011 08:50:13 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 30 Jun 2011 13:01:34 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > Ok, I'll check it. Maybe I miss !CONFIG_SWAP...
> > 
> 
> v4 here. Thank you for pointing out. I could think of several ways but
> maybe this one is good because using vm_swappines with !CONFIG_SWAP seems
> to be a bug.

No, it isn't a bug - swappiness also controls the kernel's eagerness to
unmap and reclaim mmapped pagecache.

> tested with allyesconfig/allnoconfig.

Did it break the above?

> +#ifdef CONFIG_SWAP
> +static int vmscan_swappiness(struct scan_control *sc)
> +{
> +	if (scanning_global_lru(sc))
> +		return vm_swappiness;

Well that's a bit ugly - it assumes that all callers set
scan_control.swappiness to vm_swappiness then never change it.  That
may be true in the current code.

Ho hum, I guess that's a simplification we can make.

> +	return mem_cgroup_swappiness(sc->mem_cgroup);
> +}
> +#else
> +static int vmscan_swappiness(struct scan_control *sc)
> +{
> +	/* Now, this function is never called with !CONFIG_SWAP */
> +	BUG();
> +	return 0;
> +}
> +#endif
>
> ...
>
> @@ -1789,8 +1804,8 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
>  	 * With swappiness at 100, anonymous and file have the same priority.
>  	 * This scanning priority is essentially the inverse of IO cost.
>  	 */
> -	anon_prio = sc->swappiness;
> -	file_prio = 200 - sc->swappiness;
> +	anon_prio = vmscan_swappiness(sc);
> +	file_prio = 200 - vmscan_swappiness(sc);

hah, this should go BUG if CONFIG_SWAP=n.  But it won't, because we
broke get_scan_count().  It fails to apply vm_swappiness to file-backed
pages if there's no available swap, which is daft.

I think this happened in 76a33fc380c9a ("vmscan: prevent
get_scan_ratio() rounding errors") which claims "this patch doesn't
really change logics, but just increase precision".


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
