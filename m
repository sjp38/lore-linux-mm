Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9B3EA6B0062
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 21:41:32 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8O1fW4C005417
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 24 Sep 2009 10:41:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 774FD45DD75
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:41:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 579C145DE6E
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:41:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 35DAB1DB803A
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:41:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC9CA1DB803E
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 10:41:31 +0900 (JST)
Date: Thu, 24 Sep 2009 10:39:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
Message-Id: <20090924103919.9397ac87.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1253227412-24342-3-git-send-email-ngupta@vflare.org>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
	<1253227412-24342-3-git-send-email-ngupta@vflare.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Sep 2009 04:13:30 +0530
Nitin Gupta <ngupta@vflare.org> wrote:

> @@ -585,6 +617,8 @@ static int swap_entry_free(struct swap_info_struct *p,
>  			swap_list.next = p - swap_info;
>  		nr_swap_pages++;
>  		p->inuse_pages--;
> +		if (p->swap_free_notify_fn)
> +			p->swap_free_notify_fn(p->bdev, offset);
>  	}
>  	if (!swap_count(count))
>  		mem_cgroup_uncharge_swap(ent);

A nitpick but I feel I have to explain why mem_cgroup_ucharge_swap() is called
here. (difference with p->swap_free_notify_fn)

if (!swap_count(count))

means "It seems no users for this swap entry but we're not sure there are
       SwapCache for this entry or not."

In mem_cgroup_uncharge_swap(), swap_cgroup is checked and if there is
a record (which means the SwapCache is not mapped anywhere), swap usage
is uncharged.

This is for race window at freeing swap entry via
zap_pte_range() => free_swap_and_cache().
(swap entry is not freed if the page is locked.)

I'll add some explanation in next series of memcg-cleanup patches.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
