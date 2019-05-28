Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CAFAC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:08:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54BB521726
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:08:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CxnItHns"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54BB521726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E764F6B0274; Tue, 28 May 2019 13:08:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E25AD6B0279; Tue, 28 May 2019 13:08:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D14FB6B027A; Tue, 28 May 2019 13:08:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0CA6B0274
	for <linux-mm@kvack.org>; Tue, 28 May 2019 13:08:34 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id d18so1506124lfn.11
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:08:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=eSIxYkcdixCKshTAAgauoFvEH6o7/CVdQzS8JHWoXBo=;
        b=JefDaOFSr3FTNSSptsoQgo9UdmB77hTZ4zvVf2bcYq+/vDQBa/VdKK4i9ZZrSZYfNe
         dZc609ohLmuNbbJnKKIdWvUGbLmtFg+W2CE1oioJIXiz8qQZyfPyOGPPSn7IzXBGazsD
         PAWFepCmJf5QEd30l5Izf3DtBzPqGgRzadRG+ou2kT978CEtNFo8ZbU57rilS1T58dgu
         XVkRAbE43mdsmt6dNvwfC7c7v12R3QQ2BG04sI5R0fJXX9hYMvq2gULY2O/rVCvkJsGc
         So0xr+ddSiS+Twn0UxffzbCIcGPjWGNTi4ONhWKm1PapYaVeYob+FGXgEFKpTL4bSuCB
         FLxg==
X-Gm-Message-State: APjAAAW02qXCEdkH+2lNFQA25VkJNSFtlFLRuAI/+61vOOQTFX4CbHt7
	aq2RQl0FA72Jy6r7KWhti3WAt1fSbeiM6e+HqaiZvC9ZXk3IZBg6x3ylbi8/9MTD8wYnjYNZIZ0
	NCj/s98phOHsXQ69fnNcVnc/UoKsfBJH7jtwewM9eRwWNQFBFvLeDx4mYy03NL3caWw==
X-Received: by 2002:a2e:8156:: with SMTP id t22mr633893ljg.191.1559063313650;
        Tue, 28 May 2019 10:08:33 -0700 (PDT)
X-Received: by 2002:a2e:8156:: with SMTP id t22mr633860ljg.191.1559063312755;
        Tue, 28 May 2019 10:08:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559063312; cv=none;
        d=google.com; s=arc-20160816;
        b=qJ348FfRjjQiHjT3cYj2neu93yWvfG6beZcSKFARfYc9eZjoxq6musHxZIOvKhAcYq
         TOB9ksZaODY2Ucpg1rFgB9F6TBJo1tuQHnme5TMFhTxlm9fX0mfV/lyuJUuXzoqiJiJW
         YWUlLrtzxMR0c3S9NavuNVYDTIZCHBO6anDZP4XKodduo822FV6a90W+PY9y7m21YXcy
         io9RG2LopsDDLN6vx7vyZKmkdxoQQXPhtSgC8rDTyhMwvm93e+QZnuTJYqNZXO4pGIkN
         3BPcU9Mr5Xu50u7oGwI4aj0qaFVyNdsvP2YKIvvOUqJ7cC7ckHCeBNxMNzcQ++ntqSYX
         Ndww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=eSIxYkcdixCKshTAAgauoFvEH6o7/CVdQzS8JHWoXBo=;
        b=0xIcGo1VrQXWpcGjsRABerZCQt/3ru9zvemtDTD7HnJm43vuzNvJIuBhh1LMJ2Vlnb
         puTGGK78Bg2BKLWiueAORUSWQAPIPeEMeEROXw5E1eaoXG63Pj+O0WWzO5Xom3HNlpvi
         MOPnlxqzkTfpLRw7ZLPKRSsafbMEFRgwLvPaLPyYlJgZjBIja7LUIySKmeXIlTbWU0Gn
         gb/b6s+LlVUrPZgn7I3xNvZXXZx8cuXpxG68r3yjcE8O3Sz6qseADYr7Fw1HqJOkskMZ
         1ZeojMtXd7ybYbEvMendxv9o9JF5pdaOegx40EeYG7aqciLomYFj4CLKhjRpDMPBv0eg
         aFIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CxnItHns;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y18sor3948962lfh.42.2019.05.28.10.08.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 10:08:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CxnItHns;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=eSIxYkcdixCKshTAAgauoFvEH6o7/CVdQzS8JHWoXBo=;
        b=CxnItHnsesXuxSeLCbxyq9Qzebn6SCvY7q8rl4VSmEDy6OgJ33k/LviCwobWrOuX31
         8h3CjYytq2Qx3nRTG89frfKemk4goXBw00VmBONWrQm4RT9R44DJeELSUtXUNVUQI3Pi
         2h+Th+gatt1NdMJg2oX2E5N6sG2jpK7/koWX3EImvxbOcuDaGa2EUDwtGAhn6D64yBdi
         G06hZlGysibO+bGEz4LUuV0RdSzVDDDOBq8hKFKQbuF30D7KJNpyDfc3gXNtdFAZkWnT
         foF0Icqh0P0qkvbJiWMumfU8C+MFlL2P54vZ7Z2y3GUbEJiJ/8imYCJkKIAWN0Ic0y4G
         cojg==
X-Google-Smtp-Source: APXvYqxpK6td1ccwuMiO7YgOHGdtIpb6u4hgHImxnQciGQnJ7u/EDJK4CjzzG/JnER3qRDJ8G+UnEw==
X-Received: by 2002:ac2:46ef:: with SMTP id q15mr6098737lfo.63.1559063312356;
        Tue, 28 May 2019 10:08:32 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id t13sm3006255lji.47.2019.05.28.10.08.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 10:08:31 -0700 (PDT)
Date: Tue, 28 May 2019 20:08:28 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>, cgroups@vger.kernel.org,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 5/7] mm: rework non-root kmem_cache lifecycle
 management
Message-ID: <20190528170828.zrkvcdsj3d3jzzzo@esperanza>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-6-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521200735.2603003-6-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Roman,

On Tue, May 21, 2019 at 01:07:33PM -0700, Roman Gushchin wrote:
> This commit makes several important changes in the lifecycle
> of a non-root kmem_cache, which also affect the lifecycle
> of a memory cgroup.
> 
> Currently each charged slab page has a page->mem_cgroup pointer
> to the memory cgroup and holds a reference to it.
> Kmem_caches are held by the memcg and are released with it.
> It means that none of kmem_caches are released unless at least one
> reference to the memcg exists, which is not optimal.
> 
> So the current scheme can be illustrated as:
> page->mem_cgroup->kmem_cache.
> 
> To implement the slab memory reparenting we need to invert the scheme
> into: page->kmem_cache->mem_cgroup.
> 
> Let's make every page to hold a reference to the kmem_cache (we
> already have a stable pointer), and make kmem_caches to hold a single
> reference to the memory cgroup.

Is there any reason why we can't reference both mem cgroup and kmem
cache per each charged kmem page? I mean,

  page->mem_cgroup references mem_cgroup
  page->kmem_cache references kmem_cache
  mem_cgroup references kmem_cache while it's online

TBO it seems to me that not taking a reference to mem cgroup per charged
kmem page makes the code look less straightforward, e.g. as you
mentioned in the commit log, we have to use mod_lruvec_state() for memcg
pages and mod_lruvec_page_state() for root pages.

> 
> To make this possible we need to introduce a new percpu refcounter
> for non-root kmem_caches. The counter is initialized to the percpu
> mode, and is switched to atomic mode after deactivation, so we never
> shutdown an active cache. The counter is bumped for every charged page
> and also for every running allocation. So the kmem_cache can't
> be released unless all allocations complete.
> 
> To shutdown non-active empty kmem_caches, let's reuse the
> infrastructure of the RCU-delayed work queue, used previously for
> the deactivation. After the generalization, it's perfectly suited
> for our needs.
> 
> Since now we can release a kmem_cache at any moment after the
> deactivation, let's call sysfs_slab_remove() only from the shutdown
> path. It makes deactivation path simpler.

But a cache can be dangling for quite a while after cgroup was taken
down, even after this patch, because there still can be pages charged to
it. The reason why we call sysfs_slab_remove() is to delete associated
files from sysfs ASAP. I'd try to preserve the current behavior if
possible.

> 
> Because we don't set the page->mem_cgroup pointer, we need to change
> the way how memcg-level stats is working for slab pages. We can't use
> mod_lruvec_page_state() helpers anymore, so switch over to
> mod_lruvec_state().

> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 4e5b4292a763..8d68de4a2341 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -727,9 +737,31 @@ static void kmemcg_schedule_work_after_rcu(struct rcu_head *head)
>  	queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
>  }
>  
> +static void kmemcg_cache_shutdown_after_rcu(struct kmem_cache *s)
> +{
> +	WARN_ON(shutdown_cache(s));
> +}
> +
> +static void kmemcg_queue_cache_shutdown(struct percpu_ref *percpu_ref)
> +{
> +	struct kmem_cache *s = container_of(percpu_ref, struct kmem_cache,
> +					    memcg_params.refcnt);
> +
> +	spin_lock(&memcg_kmem_wq_lock);

This code may be called from irq context AFAIU so you should use
irq-safe primitive.

> +	if (s->memcg_params.root_cache->memcg_params.dying)
> +		goto unlock;
> +
> +	WARN_ON(s->memcg_params.work_fn);
> +	s->memcg_params.work_fn = kmemcg_cache_shutdown_after_rcu;
> +	call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);

I may be totally wrong here, but I have a suspicion we don't really need
rcu here.

As I see it, you add this code so as to prevent memcg_kmem_get_cache
from dereferencing a destroyed kmem cache. Can't we continue using
css_tryget_online for that? I mean, take rcu_read_lock() and try to get
css reference. If you succeed, then the cgroup must be online, and
css_offline won't be called until you unlock rcu, right? This means that
the cache is guaranteed to be alive until then, because the cgroup holds
a reference to all its kmem caches until it's taken offline.

> +unlock:
> +	spin_unlock(&memcg_kmem_wq_lock);
> +}
> +
>  static void kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
>  {
>  	__kmemcg_cache_deactivate_after_rcu(s);
> +	percpu_ref_kill(&s->memcg_params.refcnt);
>  }
>  
>  static void kmemcg_cache_deactivate(struct kmem_cache *s)
> @@ -854,8 +861,15 @@ static int shutdown_memcg_caches(struct kmem_cache *s)
>  
>  static void flush_memcg_workqueue(struct kmem_cache *s)
>  {
> +	/*
> +	 * memcg_params.dying is synchronized using slab_mutex AND
> +	 * memcg_kmem_wq_lock spinlock, because it's not always
> +	 * possible to grab slab_mutex.
> +	 */
>  	mutex_lock(&slab_mutex);
> +	spin_lock(&memcg_kmem_wq_lock);
>  	s->memcg_params.dying = true;
> +	spin_unlock(&memcg_kmem_wq_lock);

I would completely switch from the mutex to the new spin lock -
acquiring them both looks weird.

>  	mutex_unlock(&slab_mutex);
>  
>  	/*

