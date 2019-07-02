Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56C90C06513
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 18:39:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23D3A21721
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 18:39:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23D3A21721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6DCC8E0003; Tue,  2 Jul 2019 14:39:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1C338E0001; Tue,  2 Jul 2019 14:39:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90C828E0003; Tue,  2 Jul 2019 14:39:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70A668E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 14:39:23 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id h198so17673973qke.1
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 11:39:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=eVkSMHkZCE+DeMW+WSf2Ie0krczI8jS/VcP6CzwrUCo=;
        b=M24nlpqk35MsxyWk4qRk/02i7Up9XzYGOMVAtI6XpehJjm5qajzk7S0SYMz7iR/r+U
         xxZmaVszFPGdeeLWaP4DRzO3XWnMZ/0J4oEtoX85qSG7lVZq1vdtBtMS+dW/7OtVcyFy
         Mh70jfn5J1ukn/Zts9TCQXqFKXwMMt7WjIsdMrfXfNmImuy4VE3HQ5v51wacYf6VhVbO
         WHxh/5Psv9A0gabg1CRZzgGRNBFZnYk1RqtYwfPvtG4WaI2iie36CctWvhJvNn57pzSL
         DLrSqcthdDEO41bYTKzNZMKgjpsid1O2JVmyRe6fhv5AexCui64rGJPF0BDhJskjDg6e
         8sew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU5q1frjDFSYdm8thzmBf4OdGu8L90ecsKqpx+LsPR4W3Y6s/gB
	qMA0mC3LDJ1MyoZ4USRQ+//TBuvWfMQeQbcI3b0wES+EkNGbP3sXfw7B+qmFXxgczqgWc4ewNRJ
	/LKIlfu80s7d43Xse9hk31vTe0Lx+xjjtBEme5817aNmQfXDxLgd79KXQtZ/McJZsBw==
X-Received: by 2002:a37:6152:: with SMTP id v79mr25071952qkb.488.1562092763220;
        Tue, 02 Jul 2019 11:39:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7JaoKKOlhcu2eNMLnDA6eXRZ86rh3clMxVXpYROeIq4zROF0ncffOiDTt44kFBz62h4BK
X-Received: by 2002:a37:6152:: with SMTP id v79mr25071912qkb.488.1562092762550;
        Tue, 02 Jul 2019 11:39:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562092762; cv=none;
        d=google.com; s=arc-20160816;
        b=irNsbE9KeYyRjDWuSCe5St6gvSI5ryMWMj8JFC2d6zovz52U2kGbelr3pMpohZMdu9
         8ghRhdzzdquy9L+lrUQNe+dGhtM/Xxy2eT2G207cagXj/nfuIG3jcln1hBPXJqlnbbdv
         k7CwxIqHvLxQPXCzswsgDFhsuVIKUGTJ5y5oISqS0rrL63YaHut+4tRyU0byClwii1O5
         oyel0Bt6oTv4pMLGjx3VES2NV0V5M0PHuEQQEnfSZM03BukE6KuWIrSbjOX41p234K19
         w/jDKHf8VjONYC3ZLFfOuPKLbKq7bFBlKekHguYOUdTSYSJiZe3ekgrf5Nfs270nkAdR
         zpmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=eVkSMHkZCE+DeMW+WSf2Ie0krczI8jS/VcP6CzwrUCo=;
        b=rwsUai1rjV7NdCcQKViHQVNJq7l9WrHgwusgnzS1d+7VbDDORuhFmhKPgcdw+3QPNJ
         aSNidMprJOtIm2rQl4Ya3MPaQMgICf5fHBQhjKjcSJuSzR7vLgJKmuWM70j/673jM9Cp
         UMWBZKnyUNsoyWuHdBAQQ8JGY4opY3SZO+CWixQvySjaiE2EigcQ1wYGau5tZeH495JU
         Dj/ig0z8RR1D2TLwDTOjYIh9iK92SC02WJkjcR/ptH+tE8DOOkC6W4Rhvog6lH7A38ah
         rIcPo0UEUdS/6H01cfJ7w5NVDiHJaGFJR2c+hYA7mfNYHFyZxYRm5Pn4b+JKiGI6zOUp
         0Wpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z40si11198299qvg.93.2019.07.02.11.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 11:39:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 51EB93082AC3;
	Tue,  2 Jul 2019 18:39:19 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 67891414C;
	Tue,  2 Jul 2019 18:39:15 +0000 (UTC)
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org, linux-doc@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
 linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
 Shakeel Butt <shakeelb@google.com>, Andrea Arcangeli <aarcange@redhat.com>
References: <20190702183730.14461-1-longman@redhat.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <f52bebe1-e3be-f52c-e301-4d6fb1cc87d7@redhat.com>
Date: Tue, 2 Jul 2019 14:39:14 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190702183730.14461-1-longman@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 02 Jul 2019 18:39:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/2/19 2:37 PM, Waiman Long wrote:
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
>
> Signed-off-by: Waiman Long <longman@redhat.com>

This is a follow-up of my previous patch "mm, slab: Extend
vm/drop_caches to shrink kmem slabs". It is based on the linux-next tree.

-Longman

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


