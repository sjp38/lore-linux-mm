Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6B82A6B0044
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:01:14 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0G317b7022223
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jan 2009 12:01:08 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F81645DD74
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 12:01:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D50ED45DD70
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 12:01:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ABD6F1DB804B
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 12:01:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A9B31DB8045
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 12:01:06 +0900 (JST)
Date: Fri, 16 Jan 2009 12:00:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] cgroup:add css_is_populated
Message-Id: <20090116120001.f37e1895.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Li-san, If you don't like this, could you give me an idea for
"How to check cgroup is fully ready or not" ?

BTW, why "we have a half filled direcotory - oh well" is allowed....

Thanks,
-Kame



On Thu, 15 Jan 2009 19:27:12 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> cgroup creation is done in several stages.
> After allocated and linked to cgroup's hierarchy tree, all necessary
> control files are created.
> 
> When using CSS_ID, scanning cgroups without cgrouo_lock(), status
> of cgroup is important. At removal of cgroup/css, css_tryget() works fine
> and we can write a safe code. At creation, we need some flag to show 
> "This cgroup is not ready yet"
> 
> This patch adds CSS_POPULATED flag.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
> Index: mmotm-2.6.29-Jan14/include/linux/cgroup.h
> ===================================================================
> --- mmotm-2.6.29-Jan14.orig/include/linux/cgroup.h
> +++ mmotm-2.6.29-Jan14/include/linux/cgroup.h
> @@ -69,6 +69,7 @@ struct cgroup_subsys_state {
>  enum {
>  	CSS_ROOT, /* This CSS is the root of the subsystem */
>  	CSS_REMOVED, /* This CSS is dead */
> +	CSS_POPULATED, /* This CSS finished all initialization */
>  };
>  
>  /*
> @@ -90,6 +91,11 @@ static inline bool css_is_removed(struct
>  	return test_bit(CSS_REMOVED, &css->flags);
>  }
>  
> +static inline bool css_is_populated(struct cgroup_subsys_state *css)
> +{
> +	return test_bit(CSS_POPULATED, &css->flags);
> +}
> +
>  /*
>   * Call css_tryget() to take a reference on a css if your existing
>   * (known-valid) reference isn't already ref-counted. Returns false if
> Index: mmotm-2.6.29-Jan14/kernel/cgroup.c
> ===================================================================
> --- mmotm-2.6.29-Jan14.orig/kernel/cgroup.c
> +++ mmotm-2.6.29-Jan14/kernel/cgroup.c
> @@ -2326,8 +2326,10 @@ static int cgroup_populate_dir(struct cg
>  	}
>  
>  	for_each_subsys(cgrp->root, ss) {
> +		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
>  		if (ss->populate && (err = ss->populate(ss, cgrp)) < 0)
>  			return err;
> +		set_bit(CSS_POPULATED, &css->flags);
>  	}
>  
>  	return 0;
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
