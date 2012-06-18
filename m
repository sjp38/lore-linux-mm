Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 396546B0071
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 08:12:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D1C153EE0B6
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:12:43 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B646845DE53
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:12:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D6E845DD78
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:12:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 892761DB803E
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:12:43 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 410671DB802C
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:12:43 +0900 (JST)
Message-ID: <4FDF1ABE.7070200@jp.fujitsu.com>
Date: Mon, 18 Jun 2012 21:10:38 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 00/25] kmem limitation for memcg
References: <1340015298-14133-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1340015298-14133-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>

(2012/06/18 19:27), Glauber Costa wrote:
> Hello All,
> 
> This is my new take for the memcg kmem accounting. This should merge
> all of the previous comments from you guys, specially concerning the big churn
> inside the allocators themselves.
> 
> My focus in this new round was to keep the changes in the cache internals to
> a minimum. To do that, I relied upon two main pillars:
> 
>   * Cristoph's unification series, that allowed me to put must of the changes
>     in a common file. Even then, the changes are not too many, since the overal
>     level of invasiveness was decreased.
>   * Accounting is done directly from the page allocator. This means some pages
>     can fail to be accounted, but that can only happen when the task calling
>     kmem_cache_alloc or kmalloc is not the same task allocating a new page.
>     This never happens in steady state operation if the tasks are kept in the
>     same memcg. Naturally, if the page ends up being accounted to a memcg that
>     is not limited (such as root memcg), that particular page will simply not
>     be accounted.
> 
> The dispatcher code stays (mem_cgroup_get_kmem_cache), being the mechanism who
> guarantees that, during steady state operation, all objects allocated in a page
> will belong to the same memcg. I consider this a good compromise point between
> strict and loose accounting here.
> 

2 questions.

  - Do you have performance numbers ?

  - Do you think user-memory memcg should be switched to page-allocator level accounting ?
    (it will require some study for modifying current bached-freeing and per-cpu-stock
     logics...)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
