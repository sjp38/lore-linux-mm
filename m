Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B79E7C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 12:46:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BF34218A0
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 12:46:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BF34218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sony.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3E976B0005; Mon, 22 Jul 2019 08:46:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F03D8E0003; Mon, 22 Jul 2019 08:46:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 905EF8E0001; Mon, 22 Jul 2019 08:46:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC3E6B0005
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:46:53 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id e16so8469522lja.23
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:46:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=F7WB7XMO/ExQslkEd8g5bMu9vu8U2QUmZyKXqVdfCZc=;
        b=rn2Wr98u/dk5sFyHqxQIA5iKzf3NMH1FXqptynmOI9UNYAYiOznK3VItyHvocoDxpO
         asFvNdF0E7hVTjY8A+vv+pSMb0wSX99JOtFnzwjMo8YqrG+0cR63O2gB5YI4yFJm/O9o
         U5JdsdXwOFUpOkLtfnLcYugdpS/al48xV/kB1XYnWfH1oE2I+dA50E0SqRPSuJa7/KP0
         5E14yxdTGFBt45F5l4fB+emoMrpHyD3FpHm+GzBJyE/ZZBfaFUuG57zVWw2C9ihP5tT+
         xd2KUvNJ1lWegkCr6O8c3nKHSNAW7l+mg8it3ZdP+gNFSbydr3hZN8EnFBFV18whi9lc
         n3Ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peter.enderborg@sony.com designates 37.139.156.29 as permitted sender) smtp.mailfrom=Peter.Enderborg@sony.com
X-Gm-Message-State: APjAAAXqXDKCIg1Vyb6XbEToY28+ssOcsrqrvMd55an1q8+Pxx3GFjLt
	gR22b1BWAl+mYlOx4770bvwNUUTNTzsEPlYh/RrzBIdcjvLibg1pYK1g0BYIsYrYe2HEbrNRiYH
	cprKmXYg9THQyQm0MSlgZ4KvLYO2znNzdnPtpGQgFAzU+QJDb93INlo+0BJZ7r/SAvw==
X-Received: by 2002:a2e:b0d0:: with SMTP id g16mr35767255ljl.161.1563799612501;
        Mon, 22 Jul 2019 05:46:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxt1YAVor/4IyM/rhdOKVmEFMagjFQDsJJjXZRgBYyWo+ClQQgjjN3m8aVHXkaEkK6FuOyy
X-Received: by 2002:a2e:b0d0:: with SMTP id g16mr35767203ljl.161.1563799611325;
        Mon, 22 Jul 2019 05:46:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563799611; cv=none;
        d=google.com; s=arc-20160816;
        b=IwXMio+qQn8iYRPKH1hXZT9mlVIcOqSKzuVKUVeMMhZnezLiGxUEHWmLu7Jc3IgRFd
         UiNZIiDqU3wgL4Z7VQ/Z0WEkpR+Zd3kmIKE4Nep+LB/oFo9gdI+LQNWU6A7NVvKy5k4G
         FXui4xyf0vbWS6hQV9UatiJSK/cekAi1ozN4X2EPAaMAD96ceLRA2koQ8bs6u2nR2Q/0
         URH3bZSbpysuvSKfBEjYK3HKdtLBW0LFU0rllaTtaGBfe1vOg2ZLgyz7ZCmRBmGJCbjj
         gdYzMUxEJ3ZTdg0uqSUzGFV9lttGXpd9fQq/ZrSCC6731JUQkwTmv1feH2ET3ZNNqOU0
         aPBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=F7WB7XMO/ExQslkEd8g5bMu9vu8U2QUmZyKXqVdfCZc=;
        b=jyLYJgsO9+jsFtyYF7lkOHl0jUQ7ctRIRduHjTdkrwnkiPDGMw+WqkHwH9o0ziKoB5
         JGwFp48mioeyjhZTb/R10HdGUqEfIkMIYo75zSJ5Bx2j+A2lrmHoSMiwL+7vXCZ07I4E
         uHBh6a9cQZG+ueoJpVqYD7omPC7+/gyJLF9+KL8HFO2zIF9+Fmn+2UyCbkWNjhMPMg1i
         0uaIbLhrETC0GPGXdR8Ana2T9B8N6vOe4Ux3PoewFsquKK+TbQRJwk12bEG6VUVJ/az6
         91iz/RWBJF8Ybm3RUAFVdzTvt6x01UlPwaYYXGYQ5y38gedsUVr5c35KWPezqc3MxNuF
         bQFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peter.enderborg@sony.com designates 37.139.156.29 as permitted sender) smtp.mailfrom=Peter.Enderborg@sony.com
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id y19si30637196ljh.176.2019.07.22.05.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Jul 2019 05:46:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of peter.enderborg@sony.com designates 37.139.156.29 as permitted sender) client-ip=37.139.156.29;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peter.enderborg@sony.com designates 37.139.156.29 as permitted sender) smtp.mailfrom=Peter.Enderborg@sony.com
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
To: Waiman Long <longman@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka
 Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo
 Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
	Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
CC: <linux-mm@kvack.org>, <linux-doc@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <cgroups@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Roman Gushchin <guro@fb.com>, Shakeel Butt
	<shakeelb@google.com>, Andrea Arcangeli <aarcange@redhat.com>
References: <20190702183730.14461-1-longman@redhat.com>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <71ab6307-9484-fdd3-fe6d-d261acf7c4a5@sony.com>
Date: Mon, 22 Jul 2019 14:46:47 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190702183730.14461-1-longman@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-SEG-SpamProfiler-Analysis: v=2.3 cv=L6RjvNb8 c=1 sm=1 tr=0 a=T5MYTZSj1jWyQccoVcawfw==:117 a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=IkcTkHD0fZMA:10 a=0o9FgrsRnhwA:10 a=20KFwNOVAAAA:8 a=Z4Rwk6OoAAAA:8 a=hTz6g4Jj1mwQyzJQMEoA:9 a=QEXdDO2ut3YA:10 a=aA9c7OsbRBYA:10 a=HkZW87K1Qel5hWWM3VKY:22
X-SEG-SpamProfiler-Score: 0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/2/19 8:37 PM, Waiman Long wrote:
> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
> file to shrink the slab by flushing all the per-cpu slabs and free
> slabs in partial lists. This applies only to the root caches, though.
>
> Extends this capability by shrinking all the child memcg caches and
> the root cache when a value of '2' is written to the shrink sysfs file.
>
> On a 4-socket 112-core 224-thread x86-64 system after a parallel kernel
> build, the the amount of memory occupied by slabs before shrinking
> slabs were:
>
>  # grep task_struct /proc/slabinfo
>  task_struct         7114   7296   7744    4    8 : tunables    0    0
>  0 : slabdata   1824   1824      0
>  # grep "^S[lRU]" /proc/meminfo
>  Slab:            1310444 kB
>  SReclaimable:     377604 kB
>  SUnreclaim:       932840 kB
>
> After shrinking slabs:
>
>  # grep "^S[lRU]" /proc/meminfo
>  Slab:             695652 kB
>  SReclaimable:     322796 kB
>  SUnreclaim:       372856 kB
>  # grep task_struct /proc/slabinfo
>  task_struct         2262   2572   7744    4    8 : tunables    0    0
>  0 : slabdata    643    643      0


What is the time between this measurement points? Should not the shrinked memory show up as reclaimable?


> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  Documentation/ABI/testing/sysfs-kernel-slab | 10 +++--
>  mm/slab.h                                   |  1 +
>  mm/slab_common.c                            | 43 +++++++++++++++++++++
>  mm/slub.c                                   |  2 +
>  4 files changed, 52 insertions(+), 4 deletions(-)
>
> diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
> index 29601d93a1c2..2a3d0fc4b4ac 100644
> --- a/Documentation/ABI/testing/sysfs-kernel-slab
> +++ b/Documentation/ABI/testing/sysfs-kernel-slab
> @@ -429,10 +429,12 @@ KernelVersion:	2.6.22
>  Contact:	Pekka Enberg <penberg@cs.helsinki.fi>,
>  		Christoph Lameter <cl@linux-foundation.org>
>  Description:
> -		The shrink file is written when memory should be reclaimed from
> -		a cache.  Empty partial slabs are freed and the partial list is
> -		sorted so the slabs with the fewest available objects are used
> -		first.
> +		A value of '1' is written to the shrink file when memory should
> +		be reclaimed from a cache.  Empty partial slabs are freed and
> +		the partial list is sorted so the slabs with the fewest
> +		available objects are used first.  When a value of '2' is
> +		written, all the corresponding child memory cgroup caches
> +		should be shrunk as well.  All other values are invalid.
>  
>  What:		/sys/kernel/slab/cache/slab_size
>  Date:		May 2007
> diff --git a/mm/slab.h b/mm/slab.h
> index 3b22931bb557..a16b2c7ff4dd 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -174,6 +174,7 @@ int __kmem_cache_shrink(struct kmem_cache *);
>  void __kmemcg_cache_deactivate(struct kmem_cache *s);
>  void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
>  void slab_kmem_cache_release(struct kmem_cache *);
> +int kmem_cache_shrink_all(struct kmem_cache *s);
>  
>  struct seq_file;
>  struct file;
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 464faaa9fd81..493697ba1da5 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -981,6 +981,49 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
>  }
>  EXPORT_SYMBOL(kmem_cache_shrink);
>  
> +/**
> + * kmem_cache_shrink_all - shrink a cache and all its memcg children
> + * @s: The root cache to shrink.
> + *
> + * Return: 0 if successful, -EINVAL if not a root cache
> + */
> +int kmem_cache_shrink_all(struct kmem_cache *s)
> +{
> +	struct kmem_cache *c;
> +
> +	if (!IS_ENABLED(CONFIG_MEMCG_KMEM)) {
> +		kmem_cache_shrink(s);
> +		return 0;
> +	}
> +	if (!is_root_cache(s))
> +		return -EINVAL;
> +
> +	/*
> +	 * The caller should have a reference to the root cache and so
> +	 * we don't need to take the slab_mutex. We have to take the
> +	 * slab_mutex, however, to iterate the memcg caches.
> +	 */
> +	get_online_cpus();
> +	get_online_mems();
> +	kasan_cache_shrink(s);
> +	__kmem_cache_shrink(s);
> +
> +	mutex_lock(&slab_mutex);
> +	for_each_memcg_cache(c, s) {
> +		/*
> +		 * Don't need to shrink deactivated memcg caches.
> +		 */
> +		if (s->flags & SLAB_DEACTIVATED)
> +			continue;
> +		kasan_cache_shrink(c);
> +		__kmem_cache_shrink(c);
> +	}
> +	mutex_unlock(&slab_mutex);
> +	put_online_mems();
> +	put_online_cpus();
> +	return 0;
> +}
> +
>  bool slab_is_available(void)
>  {
>  	return slab_state >= UP;
> diff --git a/mm/slub.c b/mm/slub.c
> index a384228ff6d3..5d7b0004c51f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -5298,6 +5298,8 @@ static ssize_t shrink_store(struct kmem_cache *s,
>  {
>  	if (buf[0] == '1')
>  		kmem_cache_shrink(s);
> +	else if (buf[0] == '2')
> +		kmem_cache_shrink_all(s);
>  	else
>  		return -EINVAL;
>  	return length;


