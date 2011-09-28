Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 92F689000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 22:19:11 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4F8003EE0C2
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 11:19:06 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 30E9045DE5D
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 11:19:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 17B2545DE58
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 11:19:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A4EA1DB8054
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 11:19:06 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA2651DB804E
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 11:19:05 +0900 (JST)
Message-ID: <4E8284C6.1050900@jp.fujitsu.com>
Date: Wed, 28 Sep 2011 11:21:58 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: add barrier to prevent evictable page in unevictable
 list
References: <1317174330-2677-1-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1317174330-2677-1-git-send-email-minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jweiner@redhat.com, mel@csn.ul.ie, riel@redhat.com, lee.schermerhorn@hp.com

(2011/09/28 10:45), Minchan Kim wrote:
> When racing between putback_lru_page and shmem_unlock happens,
> progrom execution order is as follows, but clear_bit in processor #1
> could be reordered right before spin_unlock of processor #1.
> Then, the page would be stranded on the unevictable list.
> 
> spin_lock
> SetPageLRU
> spin_unlock
>                                 clear_bit(AS_UNEVICTABLE)
>                                 spin_lock
>                                 if PageLRU()
>                                         if !test_bit(AS_UNEVICTABLE)
>                                         	move evictable list
> smp_mb
> if !test_bit(AS_UNEVICTABLE)
>         move evictable list
>                                 spin_unlock
> 
> But, pagevec_lookup in scan_mapping_unevictable_pages has rcu_read_[un]lock so
> it could protect reordering before reaching test_bit(AS_UNEVICTABLE) on processor #1
> so this problem never happens. But it's a unexpected side effect and we should
> solve this problem properly.

Do we still need this after Hannes removes scan_mapping_unevictable_pages?


> 
> This patch adds a barrier after mapping_clear_unevictable.
> 
> side-note: I didn't meet this problem but just found during review.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
