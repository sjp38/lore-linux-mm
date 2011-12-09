Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 254546B005C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 20:22:29 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B80353EE0C0
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:22:27 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BB4145DE88
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:22:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C79645DE86
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:22:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 47B691DB8053
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:22:27 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 00EA71DB8052
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:22:27 +0900 (JST)
Date: Fri, 9 Dec 2011 10:21:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 1/9] Basic kernel memory functionality for the Memory
 Controller
Message-Id: <20111209102113.cdb85da8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323120903-2831-2-git-send-email-glommer@parallels.com>
References: <1323120903-2831-1-git-send-email-glommer@parallels.com>
	<1323120903-2831-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, Paul Menage <paul@paulmenage.org>

On Mon,  5 Dec 2011 19:34:55 -0200
Glauber Costa <glommer@parallels.com> wrote:

> This patch lays down the foundation for the kernel memory component
> of the Memory Controller.
> 
> As of today, I am only laying down the following files:
> 
>  * memory.independent_kmem_limit
>  * memory.kmem.limit_in_bytes (currently ignored)
>  * memory.kmem.usage_in_bytes (always zero)
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>
> CC: Paul Menage <paul@paulmenage.org>
> CC: Greg Thelen <gthelen@google.com>

As I wrote, please CC Johannes and  Michal Hocko for memcg related parts.

A few questions.
==
> +	val = !!val;
> +
> +	if (parent && parent->use_hierarchy &&
> +	   (val != parent->kmem_independent_accounting))
> +		return -EINVAL;
==
Hm, why you check val != parent->kmem_independent_accounting ?

	if (parent && parent->use_hierarchy)
		return -EINVAL;
?

BTW, you didn't check this cgroup has children or not.
I think

	if (this_cgroup->use_hierarchy &&
             !list_empty(this_cgroup->childlen))
		return -EINVAL;


==
> +	/*
> +	 * TODO: We need to handle the case in which we are doing
> +	 * independent kmem accounting as authorized by our parent,
> +	 * but then our parent changes its parameter.
> +	 */
> +	cgroup_lock();
> +	memcg->kmem_independent_accounting = val;
> +	cgroup_unlock();

Do we need cgroup_lock() here ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
