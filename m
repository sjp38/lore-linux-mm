Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5DCF46B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 20:28:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7U0SZ7O000569
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 30 Aug 2010 09:28:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8125445DE5D
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 09:28:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5227245DE4F
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 09:28:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3634B1DB8040
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 09:28:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D50061DB803A
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 09:28:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in /proc/vmstat
In-Reply-To: <1282963227-31867-5-git-send-email-mrubin@google.com>
References: <1282963227-31867-1-git-send-email-mrubin@google.com> <1282963227-31867-5-git-send-email-mrubin@google.com>
Message-Id: <20100830092446.524B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 30 Aug 2010 09:28:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

> The kernel already exposes the user desired thresholds in /proc/sys/vm
> with dirty_background_ratio and background_ratio. But the kernel may
> alter the number requested without giving the user any indication that
> is the case.
> 
> Knowing the actual ratios the kernel is honoring can help app developers
> understand how their buffered IO will be sent to the disk.
> 
>         $ grep threshold /proc/vmstat
>         nr_dirty_threshold 409111
>         nr_dirty_background_threshold 818223

?
afaict, you and wu agreed /debug/bdi/default/stats is enough good.
why do you change your mention?


> 
> Signed-off-by: Michael Rubin <mrubin@google.com>
> ---
>  include/linux/mmzone.h |    2 ++
>  mm/vmstat.c            |    5 +++++
>  2 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d42f179..ad48963 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -106,6 +106,8 @@ enum zone_stat_item {
>  	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
>  	NR_FILE_PAGES_DIRTIED,	/* number of times pages get dirtied */
>  	NR_PAGES_CLEANED,	/* number of times pages enter writeback */
> +	NR_DIRTY_THRESHOLD,	/* writeback threshold */
> +	NR_DIRTY_BG_THRESHOLD,	/* bg writeback threshold */

Don't need this even though we add this two fields into /proc/sys/vm.
It can be calculated at displaing time.



>  #ifdef CONFIG_NUMA
>  	NUMA_HIT,		/* allocated in intended node */
>  	NUMA_MISS,		/* allocated in non intended node */
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 8521475..2342010 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -17,6 +17,7 @@
>  #include <linux/vmstat.h>
>  #include <linux/sched.h>
>  #include <linux/math64.h>
> +#include <linux/writeback.h>
>  
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
> @@ -734,6 +735,8 @@ static const char * const vmstat_text[] = {
>  	"nr_shmem",
>  	"nr_dirtied",
>  	"nr_cleaned",
> +	"nr_dirty_threshold",
> +	"nr_dirty_background_threshold",
>  
>  #ifdef CONFIG_NUMA
>  	"numa_hit",
> @@ -917,6 +920,8 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
>  		return ERR_PTR(-ENOMEM);
>  	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
>  		v[i] = global_page_state(i);
> +
> +	global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD, v + NR_DIRTY_THRESHOLD);
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  	e = v + NR_VM_ZONE_STAT_ITEMS;
>  	all_vm_events(e);
> -- 
> 1.7.1
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
