Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C00E66B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 19:22:15 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so125881844pfd.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 16:22:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e9si2225974pgc.241.2017.02.06.16.22.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 16:22:14 -0800 (PST)
Date: Mon, 6 Feb 2017 16:22:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] slub: make sysfs directories for memcg sub-caches
 optional
Message-Id: <20170206162213.30f909b5ce4c681e2217fb4f@linux-foundation.org>
In-Reply-To: <20170204145203.GB26958@mtj.duckdns.org>
References: <20170204145203.GB26958@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, kernel-team@fb.com

On Sat, 4 Feb 2017 09:52:03 -0500 Tejun Heo <tj@kernel.org> wrote:

> SLUB creates a per-cache directory under /sys/kernel/slab which hosts
> a bunch of debug files.  Usually, there aren't that many caches on a
> system and this doesn't really matter; however, if memcg is in use,
> each cache can have per-cgroup sub-caches.  SLUB creates the same
> directories for these sub-caches under /sys/kernel/slab/$CACHE/cgroup.
> 
> Unfortunately, because there can be a lot of cgroups, active or
> draining, the product of the numbers of caches, cgroups and files in
> each directory can reach a very high number - hundreds of thousands is
> commonplace.  Millions and beyond aren't difficult to reach either.
> 
> What's under /sys/kernel/slab is primarily for debugging and the
> information and control on the a root cache already cover its
> sub-caches.  While having a separate directory for each sub-cache can
> be helpful for development, it doesn't make much sense to pay this
> amount of overhead by default.
> 
> This patch introduces a boot parameter slub_memcg_sysfs which
> determines whether to create sysfs directories for per-memcg
> sub-caches.  It also adds CONFIG_SLUB_MEMCG_SYSFS_ON which determines
> the boot parameter's default value and defaults to 0.
> 
> ...
>
>  #ifdef CONFIG_MEMCG
> -	if (is_root_cache(s)) {
> +	if (is_root_cache(s) && memcg_sysfs_enabled) {

This could be turned on and off after bootup but I guess the result
could be pretty confusing.

However there would be useful use cases?  The user would normally have
this disabled but if he wants to do a bit of debugging then turn this
on, create a memcg, have a poke around then turn the feature off again.

>  		s->memcg_kset = kset_create_and_add("cgroup", NULL, &s->kobj);
>  		if (!s->memcg_kset) {
>  			err = -ENOMEM;
> @@ -5673,7 +5695,8 @@ static void sysfs_slab_remove(struct kme
>  		return;
>  
>  #ifdef CONFIG_MEMCG
> -	kset_unregister(s->memcg_kset);
> +	if (s->memcg_kset)
> +		kset_unregister(s->memcg_kset);

kset_unregister(NULL) is legal

--- a/mm/slub.c~slub-make-sysfs-directories-for-memcg-sub-caches-optional-fix
+++ a/mm/slub.c
@@ -5699,8 +5699,7 @@ static void sysfs_slab_remove(struct kme
 		return;
 
 #ifdef CONFIG_MEMCG
-	if (s->memcg_kset)
-		kset_unregister(s->memcg_kset);
+	kset_unregister(s->memcg_kset);
 #endif
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
