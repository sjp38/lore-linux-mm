Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B660360021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 23:48:38 -0500 (EST)
Date: Mon, 28 Dec 2009 13:42:45 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v4 4/4] memcg: implement memory thresholds
Message-Id: <20091228134245.8db992d1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <7a4e1d758b98ca633a0be06e883644ad8813c077.1261858972.git.kirill@shutemov.name>
References: <cover.1261858972.git.kirill@shutemov.name>
	<3f29ccc3c93e2defd70fc1c4ca8c133908b70b0b.1261858972.git.kirill@shutemov.name>
	<59a7f92356bf1508f06d12c501a7aa4feffb1bbc.1261858972.git.kirill@shutemov.name>
	<c2379f3965225b6d62e64c64f8c0e67fee085d7f.1261858972.git.kirill@shutemov.name>
	<7a4e1d758b98ca633a0be06e883644ad8813c077.1261858972.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, 27 Dec 2009 04:09:02 +0200, "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> It allows to register multiple memory and memsw thresholds and gets
> notifications when it crosses.
> 
> To register a threshold application need:
> - create an eventfd;
> - open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
> - write string like "<event_fd> <memory.usage_in_bytes> <threshold>" to
>   cgroup.event_control.
> 
> Application will be notified through eventfd when memory usage crosses
> threshold in any direction.
> 
> It's applicable for root and non-root cgroup.
> 
> It uses stats to track memory usage, simmilar to soft limits. It checks
> if we need to send event to userspace on every 100 page in/out. I guess
> it's good compromise between performance and accuracy of thresholds.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>  Documentation/cgroups/memory.txt |   19 +++-
>  mm/memcontrol.c                  |  275 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 293 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index b871f25..195af07 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -414,7 +414,24 @@ NOTE1: Soft limits take effect over a long period of time, since they involve
>  NOTE2: It is recommended to set the soft limit always below the hard limit,
>         otherwise the hard limit will take precedence.
>  
> -8. TODO
> +8. Memory thresholds
> +
> +Memory controler implements memory thresholds using cgroups notification
> +API (see cgroups.txt). It allows to register multiple memory and memsw
> +thresholds and gets notifications when it crosses.
> +
> +To register a threshold application need:
> + - create an eventfd using eventfd(2);
> + - open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
> + - write string like "<event_fd> <memory.usage_in_bytes> <threshold>" to
> +   cgroup.event_control.
> +
> +Application will be notified through eventfd when memory usage crosses
> +threshold in any direction.
> +
> +It's applicable for root and non-root cgroup.
> +
> +9. TODO
>  
>  1. Add support for accounting huge pages (as a separate controller)
>  2. Make per-cgroup scanner reclaim not-shared pages first
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 36eb7af..3a0a6a1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
It would be a nitpick, but my patch(http://marc.info/?l=linux-mm-commits&m=126152804420992&w=2)
has already modified here.

I think it might be better for you to apply my patches by hand or wait for next mmotm
to be released to avoid bothering Andrew.
(There is enough time left till the next merge window :))

(snip)

> +static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
> +{
> +	struct mem_cgroup_threshold_ary *thresholds;
> +	u64 usage = mem_cgroup_usage(memcg, swap);
> +	int i, cur;
> +
I think calling mem_cgroup_usage() after checking "if(!thresholds)"
decreases the overhead a little when we don't set any thresholds.
I've confirmed that the change makes the assembler output different.

> +	rcu_read_lock();
> +	if (!swap) {
> +		thresholds = rcu_dereference(memcg->thresholds);
> +	} else {
> +		thresholds = rcu_dereference(memcg->memsw_thresholds);
> +	}
> +
> +	if (!thresholds)
> +		goto unlock;
> +
> +	cur = atomic_read(&thresholds->cur);
> +
> +	/* Check if a threshold crossed in any direction */
> +
> +	for(i = cur; i >= 0 &&
> +		unlikely(thresholds->entries[i].threshold > usage); i--) {
> +		atomic_dec(&thresholds->cur);
> +		eventfd_signal(thresholds->entries[i].eventfd, 1);
> +	}
> +
> +	for(i = cur + 1; i < thresholds->size &&
> +		unlikely(thresholds->entries[i].threshold <= usage); i++) {
> +		atomic_inc(&thresholds->cur);
> +		eventfd_signal(thresholds->entries[i].eventfd, 1);
> +	}
> +unlock:
> +	rcu_read_unlock();
> +}
> +


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
