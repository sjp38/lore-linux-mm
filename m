Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 9CF8A6B0006
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 10:20:15 -0400 (EDT)
Message-ID: <515AE948.1000704@parallels.com>
Date: Tue, 2 Apr 2013 18:20:56 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: don't do cleanup manually if mem_cgroup_css_online()
 fails
References: <515A8A40.6020406@huawei.com> <20130402121600.GK24345@dhcp22.suse.cz> <20130402141646.GQ24345@dhcp22.suse.cz>
In-Reply-To: <20130402141646.GQ24345@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 04/02/2013 06:16 PM, Michal Hocko wrote:
>  mem_cgroup_css_online
>       memcg_init_kmem
>         mem_cgroup_get		# refcnt = 2
>           memcg_update_all_caches
>             memcg_update_cache_size	# fails with ENOMEM

Here is the thing: this one in kmem only happens for kmem enabled
memcgs. For those, we tend to do a get once, and put only when the last
kmem reference is gone.

For non-kmem memcgs, refcnt will be 1 here, and will be balanced out by
the mem_cgroup_put() in css_free.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
