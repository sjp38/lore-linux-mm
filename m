Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD3D56B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 12:10:08 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id u68so132403632ywg.4
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 09:10:08 -0800 (PST)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id q13si1321100ywj.415.2017.02.07.09.10.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 09:10:07 -0800 (PST)
Received: by mail-yw0-x244.google.com with SMTP id v73so9947201ywg.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 09:10:07 -0800 (PST)
Date: Tue, 7 Feb 2017 12:10:06 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] slub: make sysfs directories for memcg sub-caches
 optional
Message-ID: <20170207171006.GB6164@htj.duckdns.org>
References: <20170204145203.GB26958@mtj.duckdns.org>
 <20170206162213.30f909b5ce4c681e2217fb4f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170206162213.30f909b5ce4c681e2217fb4f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, kernel-team@fb.com

Hello, Andrew.

On Mon, Feb 06, 2017 at 04:22:13PM -0800, Andrew Morton wrote:
> >  #ifdef CONFIG_MEMCG
> > -	if (is_root_cache(s)) {
> > +	if (is_root_cache(s) && memcg_sysfs_enabled) {
> 
> This could be turned on and off after bootup but I guess the result
> could be pretty confusing.
> 
> However there would be useful use cases?  The user would normally have
> this disabled but if he wants to do a bit of debugging then turn this
> on, create a memcg, have a poke around then turn the feature off again.

Hmm... maybe.  It's somewhat nasty to do after-the-fact.  You would
have to re-walk all the caches to create and destroy the sysfs
entries.  Given that it's a pretty fringe debug feature, I'm not sure
the added complexity would be justified.

> >  		s->memcg_kset = kset_create_and_add("cgroup", NULL, &s->kobj);
> >  		if (!s->memcg_kset) {
> >  			err = -ENOMEM;
> > @@ -5673,7 +5695,8 @@ static void sysfs_slab_remove(struct kme
> >  		return;
> >  
> >  #ifdef CONFIG_MEMCG
> > -	kset_unregister(s->memcg_kset);
> > +	if (s->memcg_kset)
> > +		kset_unregister(s->memcg_kset);
> 
> kset_unregister(NULL) is legal
> 
> --- a/mm/slub.c~slub-make-sysfs-directories-for-memcg-sub-caches-optional-fix
> +++ a/mm/slub.c
> @@ -5699,8 +5699,7 @@ static void sysfs_slab_remove(struct kme
>  		return;
>  
>  #ifdef CONFIG_MEMCG
> -	if (s->memcg_kset)
> -		kset_unregister(s->memcg_kset);
> +	kset_unregister(s->memcg_kset);
>  #endif
>  	kobject_uevent(&s->kobj, KOBJ_REMOVE);
>  	kobject_del(&s->kobj);

Ah, of course, looks good to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
