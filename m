Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E23A4C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:56:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B22C2075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:56:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="0mGIO0a1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B22C2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 883756B026A; Wed,  5 Jun 2019 12:56:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 833E26B026B; Wed,  5 Jun 2019 12:56:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FB776B026C; Wed,  5 Jun 2019 12:56:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3750C6B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 12:56:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g65so763048plb.9
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 09:56:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hZ4cGeRHDextu5CN92g1Wv5jExw3YnRMZLIMsV5cvAM=;
        b=JgU0Auq1+Ukh7Iv8UyfVVQ5dvLSLsOsYwut9dAetAodw+VLmpaKaKMNoBeqPHQx1OG
         9wwC9e9RKmpjUNzxgDXIjyVe3QttZrOprulCX9Fr918x2CH4qhKDKYW94nPuaODJEbfE
         iwblfRm5Lv8VKYszAQwTq/28JAWwL1jBJf4CKnVgEhu4uUjHkyabh5Bs7yDjg+0spXxV
         7gYi6ydhmlCdP7cIfMNFKRp1e1ng1g1ilmnQ6kD/a8Hdm5vJAOpg3896rZZ6Ynoe1h/m
         OQEjLJiisn3iWaEkmPD3GRXKLRJsHR/YDyH7X6BYMws2SypDmid9eZ8uGBE5X4cttg/P
         N3Jg==
X-Gm-Message-State: APjAAAWBKY1u3uDULFrm0Szzk15etT5pzxmscgN42/W8i07u5blQ6knG
	tfKnElaLyBbvk8P8GKtoSetFxvTXoNyzqYW7/HObBsdl7OHt5je25rwnZtlojKt3+5x1ROOVFxI
	dr/uSaUY519qH9N72q4PVaBKsoRhuI3iQmur9vS/5Lv3VH9NKB7oih9UIMh3xJ69FFA==
X-Received: by 2002:a63:5152:: with SMTP id r18mr5829485pgl.324.1559753779700;
        Wed, 05 Jun 2019 09:56:19 -0700 (PDT)
X-Received: by 2002:a63:5152:: with SMTP id r18mr5829418pgl.324.1559753779048;
        Wed, 05 Jun 2019 09:56:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559753779; cv=none;
        d=google.com; s=arc-20160816;
        b=afFDkD90G3810iNm1WORFqC3tXS7QKUlf6J3RVqrz/Yt7pz2/8ehPbnoAgW2AwAYjo
         td0/ZXvgBafWeDJ+EE47uPYBlIGdvRMHQaa+0oZuznk2Br3j1nRcRBcDmRN1idVSFaZk
         wI4KGBfLYTe2Mqercr+krGZM4UGt0QXggdCi6IEzm8kNwFv3W3YwpNxHfeQLIDt4QNH+
         zS+SGT5M3fbCMt0N4BE/Vq3QMm4QWP++1lEkTh59FMlJtI59dOGP3JZmpRmI8jv3qPTe
         F3lqI8loVMdh2a86ylxCyRW8/U6cWSAnoChue/o17EARA+67RM1zXLAHMiIt/gEZLr/c
         l87w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hZ4cGeRHDextu5CN92g1Wv5jExw3YnRMZLIMsV5cvAM=;
        b=TnsAvNRoGNmD7YQ/0SJznxQmaXctgFsScN2p7DDCaCTQtx+tJ87pqG+YCgpSwa4Diq
         0LcMlUlPwAWodZnQ9ClT07eDZBvd0pxXg0UxvYIw398zrgHCl68ykrm07toeXFm+XZAj
         Lp8qxW2T3bUAiCjno6N5LDgYa6QGdPGKQQPpNGhNsHeylGcPV0EDbhqW+NSBfOABZfzB
         jcWxOkUdrlVdU6v+WIrn4NfP1a33E9egndWljyk6cmmwHXNlPoY8UPMTHWNUBAu5QK3J
         7S/2CUyZHo4slcLn0d1iQi1JKUOoWSc1T3IYk1O+bAyE6qHTy6p1ts3G3ejJ2FR5Xrk/
         tzKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0mGIO0a1;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b2sor10207431pls.45.2019.06.05.09.56.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 09:56:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0mGIO0a1;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hZ4cGeRHDextu5CN92g1Wv5jExw3YnRMZLIMsV5cvAM=;
        b=0mGIO0a16PwCvvaR5KVekuEHAAI6Q2Au9fzMg0rq9cIQZseDxcLyQnlnpLFqWAhwqe
         Yt+8W6m4lRuJQWYFUXD9kuuXHzivkv9+YZ8UX3eujcruue8CDe5Piz47SrGxpOX96mJ0
         ypMmdVL54li0Got7Cg0OG7+PNhDYXWUkLW82vaBWqVdjlLNaQ8uMIUrLZE072HIgWWHw
         iSPt/Wakz0VQISfqlzp3LI0Yq1DyQh6PFNSW0qKy89hSNq1VtvE5zOv9q4A7nI4ezK1L
         e07s/PovVfIg66ebjPwJvd25lYq0FNCUJvMgh1gTZa/ieLe5bRjaMJ7PKI0/rNFseEek
         lqtg==
X-Google-Smtp-Source: APXvYqzQNjLq7UOy1q7ENsNpX55jr/E9IvuPhShPS6v+kZtEcqMLpCvregQ854wv8sSR3be+MXorkw==
X-Received: by 2002:a17:902:a513:: with SMTP id s19mr41291953plq.261.1559753778277;
        Wed, 05 Jun 2019 09:56:18 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:cd0c])
        by smtp.gmail.com with ESMTPSA id d10sm23208447pgh.43.2019.06.05.09.56.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 09:56:17 -0700 (PDT)
Date: Wed, 5 Jun 2019 12:56:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 07/10] mm: synchronize access to kmem_cache dying flag
 using a spinlock
Message-ID: <20190605165615.GC12453@cmpxchg.org>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-8-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605024454.1393507-8-guro@fb.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 07:44:51PM -0700, Roman Gushchin wrote:
> Currently the memcg_params.dying flag and the corresponding
> workqueue used for the asynchronous deactivation of kmem_caches
> is synchronized using the slab_mutex.
> 
> It makes impossible to check this flag from the irq context,
> which will be required in order to implement asynchronous release
> of kmem_caches.
> 
> So let's switch over to the irq-save flavor of the spinlock-based
> synchronization.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> ---
>  mm/slab_common.c | 19 +++++++++++++++----
>  1 file changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 09b26673b63f..2914a8f0aa85 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -130,6 +130,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
>  #ifdef CONFIG_MEMCG_KMEM
>  
>  LIST_HEAD(slab_root_caches);
> +static DEFINE_SPINLOCK(memcg_kmem_wq_lock);
>  
>  void slab_init_memcg_params(struct kmem_cache *s)
>  {
> @@ -629,6 +630,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
>  	struct memcg_cache_array *arr;
>  	struct kmem_cache *s = NULL;
>  	char *cache_name;
> +	bool dying;
>  	int idx;
>  
>  	get_online_cpus();
> @@ -640,7 +642,13 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
>  	 * The memory cgroup could have been offlined while the cache
>  	 * creation work was pending.
>  	 */
> -	if (memcg->kmem_state != KMEM_ONLINE || root_cache->memcg_params.dying)
> +	if (memcg->kmem_state != KMEM_ONLINE)
> +		goto out_unlock;
> +
> +	spin_lock_irq(&memcg_kmem_wq_lock);
> +	dying = root_cache->memcg_params.dying;
> +	spin_unlock_irq(&memcg_kmem_wq_lock);
> +	if (dying)
>  		goto out_unlock;

What does this lock protect? The dying flag could get set right after
the unlock.

