Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id B99086B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 01:01:39 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 435B83EE081
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:01:38 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 27E4745DE51
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:01:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F0CD45DE4D
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:01:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EE6EFE08002
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:01:37 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D1921DB8037
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:01:37 +0900 (JST)
Date: Thu, 8 Mar 2012 15:00:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] page_cgroup: fix horrid swap accounting regression
Message-Id: <20120308150002.c900b38c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1203052046410.24068@eggly.anvils>
References: <alpine.LSU.2.00.1203052046410.24068@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 5 Mar 2012 20:52:55 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Why is memcg's swap accounting so broken?  Insane counts, wrong ownership,
> unfreeable structures, which later get freed and then accessed after free.
> 
> Turns out to be a tiny a little 3.3-rc1 regression in 9fb4b7cc0724
> "page_cgroup: add helper function to get swap_cgroup": the helper
> function (actually named lookup_swap_cgroup()) returns an address
> using void* arithmetic, but the structure in question is a short.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thank you for testing/fixes.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
> 
>  mm/page_cgroup.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> --- 3.3-rc6/mm/page_cgroup.c	2012-01-20 08:42:35.320020840 -0800
> +++ linux/mm/page_cgroup.c	2012-03-05 19:51:13.535372098 -0800
> @@ -379,13 +379,15 @@ static struct swap_cgroup *lookup_swap_c
>  	pgoff_t offset = swp_offset(ent);
>  	struct swap_cgroup_ctrl *ctrl;
>  	struct page *mappage;
> +	struct swap_cgroup *sc;
>  
>  	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
>  	if (ctrlp)
>  		*ctrlp = ctrl;
>  
>  	mappage = ctrl->map[offset / SC_PER_PAGE];
> -	return page_address(mappage) + offset % SC_PER_PAGE;
> +	sc = page_address(mappage);
> +	return sc + offset % SC_PER_PAGE;
>  }
>  
>  /**
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
