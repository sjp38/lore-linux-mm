Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 255066B002C
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 20:44:58 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B86DA3EE0B5
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:44:56 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ECB345DEAD
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:44:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8722C45DEA6
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:44:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A619E08002
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:44:56 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 34AC41DB803F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:44:56 +0900 (JST)
Date: Tue, 28 Feb 2012 10:43:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 19/21] memcg: check lru vectors emptiness in
 pre-destroy
Message-Id: <20120228104331.37f9bcfd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135319.12988.73209.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135319.12988.73209.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:53:19 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> We must abort cgroup destroying if it still not empty,
> resource counter cannot catch isolated uncharged pages.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

I like this. 
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>

> ---
>  mm/memcontrol.c |   10 +++++++++-
>  1 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4de8044..fbeff85 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4859,8 +4859,16 @@ free_out:
>  static int mem_cgroup_pre_destroy(struct cgroup *cont)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	int ret;
> +
> +	ret = mem_cgroup_force_empty(memcg, false);
> +	if (ret)
> +		return ret;
>  
> -	return mem_cgroup_force_empty(memcg, false);
> +	if (mem_cgroup_nr_lru_pages(memcg, -1))
> +		return -EBUSY;
> +
> +	return 0;
>  }
>  
>  static void mem_cgroup_destroy(struct cgroup *cont)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
