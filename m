Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 75AE66B004D
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 03:22:14 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 615A13EE081
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:22:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B48C45DEB4
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:22:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3475C45DEAD
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:22:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 26C7D1DB803B
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:22:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF0061DB803E
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:22:11 +0900 (JST)
Date: Tue, 21 Feb 2012 17:20:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/10] mm/memcg: apply add/del_page to lruvec
Message-Id: <20120221172042.20f407fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202201530530.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
	<alpine.LSU.2.00.1202201530530.23274@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Feb 2012 15:32:06 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Go further: pass lruvec instead of zone to add_page_to_lru_list() and
> del_page_from_lru_list(); and pagevec_lru_move_fn() pass lruvec down
> to its target functions.
> 
> This cleanup eliminates a swathe of cruft in memcontrol.c,
> including mem_cgroup_lru_add_list(), mem_cgroup_lru_del_list() and
> mem_cgroup_lru_move_lists(), which never actually touched the lists.
> 
> In their place, mem_cgroup_page_lruvec() to decide the lruvec,
> previously a side-effect of add, and mem_cgroup_update_lru_size()
> to maintain the lru_size stats.
> 
> Whilst these are simplifications in their own right, the goal is to
> bring the evaluation of lruvec next to the spin_locking of the lrus,
> in preparation for the next patch.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>


Hmm.. a nitpick.

You do 
  lruvec = mem_cgroup_page_lruvec(page, zone);

What is the difference from

  lruvec = mem_cgroup_page_lruvec(page, page_zone(page)) 

?

If we have a function
  lruvec = mem_cgroup_page_lruvec(page)

Do we need 
  lruvec = mem_cgroup_page_lruvec_zone(page, zone) 

?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
