Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1133C6008C6
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 04:59:58 -0400 (EDT)
Message-ID: <4C738B34.6070602@cn.fujitsu.com>
Date: Tue, 24 Aug 2010 17:04:52 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com> <20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> CC'ed to Paul Menage and Li Zefan.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> When cgroup subsystem use ID (ss->use_id==1), each css's ID is assigned
> after successful call of ->create(). css_ID is tightly coupled with
> css struct itself but it is allocated by ->create() call, IOW,
> per-subsystem special allocations.
> 
> To know css_id before creation, this patch adds id_attached() callback.
> after css_ID allocation. This will be used by memory cgroup's quick lookup
> routine.
> 
> Maybe you can think of other implementations as
> 	- pass ID to ->create()
> 	or
> 	- add post_create()
> 	etc...
> But when considering dirtiness of codes, this straightforward patch seems
> good to me. If someone wants post_create(), this patch can be replaced.
> 
> Changelog: 20100820
>  - new approarch.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Li Zefan <lizf@cn.fujitsu.com>

...
>  
> Index: mmotm-0811/include/linux/cgroup.h
> ===================================================================
> --- mmotm-0811.orig/include/linux/cgroup.h
> +++ mmotm-0811/include/linux/cgroup.h
> @@ -475,6 +475,7 @@ struct cgroup_subsys {
>  			struct cgroup *cgrp);
>  	void (*post_clone)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
> +	void (*id_attached)(struct cgroup_subsys *ss, struct cgroup *cgrp);

Maybe pass the id number to id_attached() is better.

And actually the @ss argument is not necessary, because the memcg's
id_attached() handler of course knows it's dealing with the memory
cgroup subsystem.

So I suspect we can just remove all the @ss from all the callbacks..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
