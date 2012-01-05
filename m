Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 55D5D6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 01:02:06 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E8DF43EE0BC
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:02:04 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE1A345DE52
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:02:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B5AE845DE4F
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:02:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7D631DB8041
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:02:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 61C2A1DB803B
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:02:04 +0900 (JST)
Date: Thu, 5 Jan 2012 15:00:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] memcg: fix page migration to reset_owner
Message-Id: <20120105150053.cc9d5a34.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112281622080.8257@eggly.anvils>
References: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
	<alpine.LSU.2.00.1112281622080.8257@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Wed, 28 Dec 2011 16:23:29 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Usually, migration pages coming to unmap_and_move()'s putback_lru_page()
> have been charged and have pc->mem_cgroup set; but there are several ways
> in which a freshly allocated uncharged page can get there, oopsing when
> added to LRU.  Call mem_cgroup_reset_owner() immediately after allocating.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Ah, ok. It calls putback_lru_page()...

Thank you very much!.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
> Fix N to
>     memcg: clear pc->mem_cgorup if necessary.
> 
>  mm/migrate.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- mmotm.orig/mm/migrate.c	2011-12-22 02:53:31.900041565 -0800
> +++ mmotm/mm/migrate.c	2011-12-28 14:52:37.243034125 -0800
> @@ -841,6 +841,8 @@ static int unmap_and_move(new_page_t get
>  	if (!newpage)
>  		return -ENOMEM;
>  
> +	mem_cgroup_reset_owner(newpage);
> +
>  	if (page_count(page) == 1) {
>  		/* page was freed from under us. So we are done. */
>  		goto out;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
