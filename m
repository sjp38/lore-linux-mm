Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 269756B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 05:52:06 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n819qBYT010102
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Sep 2009 18:52:11 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8636D45DE58
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 18:52:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B59645DE54
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 18:52:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 17307E1800E
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 18:52:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 88E1EE1801D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 18:52:10 +0900 (JST)
Date: Tue, 1 Sep 2009 18:50:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm][BUG] free is bigger than presnet Re: mmotm
 2009-08-27-16-51 uploaded
Message-Id: <20090901185013.c86bd937.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0909011031140.13740@sister.anvils>
References: <200908272355.n7RNtghC019990@imap1.linux-foundation.org>
	<20090901180032.55f7b8ca.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0909011031140.13740@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009 10:33:31 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Tue, 1 Sep 2009, KAMEZAWA Hiroyuki wrote:
> > 
> > I'm not digggin so much but /proc/meminfo corrupted.
> > 
> > [kamezawa@bluextal cgroup]$ cat /proc/meminfo
> > MemTotal:       24421124 kB
> > MemFree:        38314388 kB
> 
> If that's without my fix to shrink_active_list(), I'd try again with.
> Hugh
> 
Thank you very much. I missed this patch.
It's fixed.

Regards,
-Kame


> [PATCH mmotm] vmscan move pgdeactivate modification to shrink_active_list fix
> 
> mmotm 2009-08-27-16-51 lets the OOM killer loose on my loads even
> quicker than last time: one bug fixed but another bug introduced.
> vmscan-move-pgdeactivate-modification-to-shrink_active_list.patch
> forgot to add NR_LRU_BASE to lru index to make zone_page_state index.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
> 
>  mm/vmscan.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> --- mmotm/mm/vmscan.c	2009-08-28 10:07:57.000000000 +0100
> +++ linux/mm/vmscan.c	2009-08-28 18:30:33.000000000 +0100
> @@ -1381,8 +1381,10 @@ static void shrink_active_list(unsigned
>  	reclaim_stat->recent_rotated[file] += nr_rotated;
>  	__count_vm_events(PGDEACTIVATE, nr_deactivated);
>  	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
> -	__mod_zone_page_state(zone, LRU_ACTIVE + file * LRU_FILE, nr_rotated);
> -	__mod_zone_page_state(zone, LRU_BASE + file * LRU_FILE, nr_deactivated);
> +	__mod_zone_page_state(zone, NR_ACTIVE_ANON + file * LRU_FILE,
> +							nr_rotated);
> +	__mod_zone_page_state(zone, NR_INACTIVE_ANON + file * LRU_FILE,
> +							nr_deactivated);
>  	spin_unlock_irq(&zone->lru_lock);
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
