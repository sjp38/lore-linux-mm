Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2DAF56B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 23:00:02 -0500 (EST)
Message-ID: <4966CB89.1020403@cn.fujitsu.com>
Date: Fri, 09 Jan 2009 11:59:05 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/4] cgroup: support per cgroup subsys state ID (CSS
 ID)
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com> <20090108182817.2c393351.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090108182817.2c393351.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

>  static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
>  {
>  	struct inode *inode = new_inode(sb);
> @@ -2335,6 +2339,7 @@ static void init_cgroup_css(struct cgrou
>  	css->cgroup = cgrp;
>  	atomic_set(&css->refcnt, 1);
>  	css->flags = 0;
> +	css->id = NULL;
>  	if (cgrp == dummytop)
>  		set_bit(CSS_ROOT, &css->flags);
>  	BUG_ON(cgrp->subsys[ss->subsys_id]);
> @@ -2410,6 +2415,10 @@ static long cgroup_create(struct cgroup 
>  			goto err_destroy;
>  		}
>  		init_cgroup_css(css, ss, cgrp);
> +		if (ss->use_id)
> +			if (alloc_css_id(ss, parent, cgrp))
> +				goto err_destroy;
> +		/* At error, ->destroy() callback has to free assigned ID. */

A bug here:

if alloc_css_id(ss, parent, cgrp) failed, then ss->destroy() called free_css_id(),
then panic.

maybe check if (css->id == NULL) in free_css_id() ?

>  	}
>  
>  	cgroup_lock_hierarchy(root);
> @@ -2699,6 +2708,8 @@ int __init cgroup_init(void)
>  		struct cgroup_subsys *ss = subsys[i];
>  		if (!ss->early_init)
>  			cgroup_init_subsys(ss);
> +		if (ss->use_id)
> +			cgroup_subsys_init_idr(ss);
>  	}
>  
>  	/* Add init_css_set to the hash table */
> @@ -3231,3 +3242,260 @@ static int __init cgroup_disable(char *s
>  	return 1;
>  }
>  __setup("cgroup_disable=", cgroup_disable);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
