Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB296F1q030309
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Dec 2008 18:06:15 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 96C5045DE50
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 18:06:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 78CBD45DD72
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 18:06:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AB8B1DB803C
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 18:06:15 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 10A1D1DB8037
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 18:06:15 +0900 (JST)
Date: Tue, 2 Dec 2008 18:05:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 11/11] memcg: show reclaim_stat
Message-Id: <20081202180525.2023892c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081201211905.1CEB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081201211905.1CEB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon,  1 Dec 2008 21:19:49 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> added following four field to memory.stat file.
> 
>   - recent_rotated_anon
>   - recent_rotated_file
>   - recent_scanned_anon
>   - recent_scanned_file
> 
> it is useful for memcg reclaim debugging.
> 
I'll put this under CONFIG_DEBUG_VM.

Thanks,
-Kame

> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
> 
> Index: b/mm/memcontrol.c
> ===================================================================
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1799,6 +1799,31 @@ static int mem_control_stat_show(struct 
>  
>  	cb->fill(cb, "inactive_ratio", mem_cont->inactive_ratio);
>  
> +	{
> +		int nid, zid;
> +		struct mem_cgroup_per_zone *mz;
> +		unsigned long recent_rotated[2] = {0, 0};
> +		unsigned long recent_scanned[2] = {0, 0};
> +
> +		for_each_online_node(nid)
> +			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> +				mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
> +
> +				recent_rotated[0] +=
> +					mz->reclaim_stat.recent_rotated[0];
> +				recent_rotated[1] +=
> +					mz->reclaim_stat.recent_rotated[1];
> +				recent_scanned[0] +=
> +					mz->reclaim_stat.recent_scanned[0];
> +				recent_scanned[1] +=
> +					mz->reclaim_stat.recent_scanned[1];
> +			}
> +		cb->fill(cb, "recent_rotated_anon", recent_rotated[0]);
> +		cb->fill(cb, "recent_rotated_file", recent_rotated[1]);
> +		cb->fill(cb, "recent_scanned_anon", recent_scanned[0]);
> +		cb->fill(cb, "recent_scanned_file", recent_scanned[1]);
> +	}
> +
>  	return 0;
>  }
>  
> 
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
