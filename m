Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB5B9C06513
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 19:15:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FD392186A
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 19:15:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FD392186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D5FA6B0005; Tue,  2 Jul 2019 15:15:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2870F8E0003; Tue,  2 Jul 2019 15:15:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 175908E0001; Tue,  2 Jul 2019 15:15:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA1656B0005
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 15:15:56 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s22so17323636qtb.22
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 12:15:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=Bc+JKVicEphiO115dgnlLTyRJLHBC0GoGOV/NuafloQ=;
        b=tlIpEsESDR2uluPFQqN2HhrC9Y2DT9yuDsCLr/HCmoFfZfESJ9vcqZBVa1WUJwgGIV
         yBAjQEVpaggViW3h+b2Nz3EYIrEcxZaCWKhVDTtw3SD8jPYJt5VKxBPTC1IuuUOdLs7F
         IneWW30O80qZdTbJwCSGVVQIPqduwB/Ih7IXRvffzQRIIv2mSOEn8bLv2K64VpnXoUzp
         q8LS2XmnFm9kV20oe9qdEKW5/ZptXyJrwkXTlAs04Yc7Yaa8HiklrOtHsEcg73NOQPm8
         plIHZOp+GVvuyx/AKPpVxS6eXs1SFt0Z+Ed7TTMXfMH6auSByzme7KzKxACCMY4PrrO8
         kyMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVxHvanHQZHbrU5S3CmPks+qW0WNVzO4HdpIJwIF08Sf6e5A4oB
	nLTkpFlfaeecRzJO8aJ/uwKbQXDDHURXquzfp31eUHYzEkkCJ/VCzvUlEoWf/DPfowiT/rRuShl
	tPE3sxzdTLjRSvI1uABY5634yqBuWCdGhPM+NNPQEqMD3XgFBxXIbTex6CMdndNWgzw==
X-Received: by 2002:ac8:877:: with SMTP id x52mr26607854qth.328.1562094956720;
        Tue, 02 Jul 2019 12:15:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhpHh+poq7HYP1UXgbFB4oFt123B7c7+y7heKFsn8Gtmg8w4yTLUW7hkYn4ppHGlPmJOWI
X-Received: by 2002:ac8:877:: with SMTP id x52mr26607808qth.328.1562094956067;
        Tue, 02 Jul 2019 12:15:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562094956; cv=none;
        d=google.com; s=arc-20160816;
        b=yPB/KxLstU94fIwtknB7yLXueYQBkKnKkUwTuwrGjYvqh9ad8DPvDujdK17yG+3JId
         x0cpbqzXJ99Mv+/PjmYIfG15thxOco/keGc/Kv8JMjmNDnhUkkZ381eNXApfwyff+r0V
         34gyTQlzMMQKWs0zsIZlTUPpU2FqlXY41pwi2ydqwPi2Nl/1ScgXGU+dxoWXqcgI3B11
         3I5S1sfUDHpmjmSb9y3VVHoBK06JZF+793MJcd3RhWXg7PGlQOp1AipQsQphuMYblWS2
         e9RnX18Tl8K27mehAQhwsFc6lf/LRwn1Jc0E2vUVn5pUh/fm5o7sy1Fd8i83uBtq9vuq
         zS0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=Bc+JKVicEphiO115dgnlLTyRJLHBC0GoGOV/NuafloQ=;
        b=qXVMyE6rf3cQoDB0RYn/F1osGXXqwmkfQ5igJdSiHEp7vTuRJyXTGtXtcgfkmB15Hx
         PyZS7g2HgvbmJ+o8BC+2AE0eGmFEOpajFn7+MJGwyi1fwk9YnZmJhUWXSt/U/GDf8s49
         NZEYP3m9YzF7SNWVurGUdFKdBxWfvkfg+hpoosQFD/0O2/jQ1OjLfjjz3PmaFU0dMO0/
         cI19VvQ+PCQrJS02X1pUbqGhCqSzEtNkPGTqieP/lsxrMNJFtV832irR9kwqn65yvzFu
         aGvVpk6nkJ4rfhFq+6koY1WI+QTWirKnJb4ZRLg6qr1omk019TdOZ2EBOFVkd3FEzypC
         0eNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t42si77259qtc.163.2019.07.02.12.15.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 12:15:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 25FA9C057F2E;
	Tue,  2 Jul 2019 19:15:50 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AA0471347B;
	Tue,  2 Jul 2019 19:15:42 +0000 (UTC)
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
 linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>
References: <20190702183730.14461-1-longman@redhat.com>
 <alpine.DEB.2.21.1907021206000.67286@chino.kir.corp.google.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <34af4938-f472-9d9b-e615-397217023004@redhat.com>
Date: Tue, 2 Jul 2019 15:15:42 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1907021206000.67286@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 02 Jul 2019 19:15:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/2/19 3:09 PM, David Rientjes wrote:
> On Tue, 2 Jul 2019, Waiman Long wrote:
>
>> diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
>> index 29601d93a1c2..2a3d0fc4b4ac 100644
>> --- a/Documentation/ABI/testing/sysfs-kernel-slab
>> +++ b/Documentation/ABI/testing/sysfs-kernel-slab
>> @@ -429,10 +429,12 @@ KernelVersion:	2.6.22
>>  Contact:	Pekka Enberg <penberg@cs.helsinki.fi>,
>>  		Christoph Lameter <cl@linux-foundation.org>
>>  Description:
>> -		The shrink file is written when memory should be reclaimed from
>> -		a cache.  Empty partial slabs are freed and the partial list is
>> -		sorted so the slabs with the fewest available objects are used
>> -		first.
>> +		A value of '1' is written to the shrink file when memory should
>> +		be reclaimed from a cache.  Empty partial slabs are freed and
>> +		the partial list is sorted so the slabs with the fewest
>> +		available objects are used first.  When a value of '2' is
>> +		written, all the corresponding child memory cgroup caches
>> +		should be shrunk as well.  All other values are invalid.
>>  
> This should likely call out that '2' also does '1', that might not be 
> clear enough.

You are right. I will reword the text to make it clearer.


>>  What:		/sys/kernel/slab/cache/slab_size
>>  Date:		May 2007
>> diff --git a/mm/slab.h b/mm/slab.h
>> index 3b22931bb557..a16b2c7ff4dd 100644
>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -174,6 +174,7 @@ int __kmem_cache_shrink(struct kmem_cache *);
>>  void __kmemcg_cache_deactivate(struct kmem_cache *s);
>>  void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
>>  void slab_kmem_cache_release(struct kmem_cache *);
>> +int kmem_cache_shrink_all(struct kmem_cache *s);
>>  
>>  struct seq_file;
>>  struct file;
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index 464faaa9fd81..493697ba1da5 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -981,6 +981,49 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
>>  }
>>  EXPORT_SYMBOL(kmem_cache_shrink);
>>  
>> +/**
>> + * kmem_cache_shrink_all - shrink a cache and all its memcg children
>> + * @s: The root cache to shrink.
>> + *
>> + * Return: 0 if successful, -EINVAL if not a root cache
>> + */
>> +int kmem_cache_shrink_all(struct kmem_cache *s)
>> +{
>> +	struct kmem_cache *c;
>> +
>> +	if (!IS_ENABLED(CONFIG_MEMCG_KMEM)) {
>> +		kmem_cache_shrink(s);
>> +		return 0;
>> +	}
>> +	if (!is_root_cache(s))
>> +		return -EINVAL;
>> +
>> +	/*
>> +	 * The caller should have a reference to the root cache and so
>> +	 * we don't need to take the slab_mutex. We have to take the
>> +	 * slab_mutex, however, to iterate the memcg caches.
>> +	 */
>> +	get_online_cpus();
>> +	get_online_mems();
>> +	kasan_cache_shrink(s);
>> +	__kmem_cache_shrink(s);
>> +
>> +	mutex_lock(&slab_mutex);
>> +	for_each_memcg_cache(c, s) {
>> +		/*
>> +		 * Don't need to shrink deactivated memcg caches.
>> +		 */
>> +		if (s->flags & SLAB_DEACTIVATED)
>> +			continue;
>> +		kasan_cache_shrink(c);
>> +		__kmem_cache_shrink(c);
>> +	}
>> +	mutex_unlock(&slab_mutex);
>> +	put_online_mems();
>> +	put_online_cpus();
>> +	return 0;
>> +}
>> +
>>  bool slab_is_available(void)
>>  {
>>  	return slab_state >= UP;
> I'm wondering how long this could take, i.e. how long we hold slab_mutex 
> while we traverse each cache and shrink it.

It will depends on how many memcg caches are there. Actually, I have
been thinking about using the show method to show the time spent in the
last shrink operation. I am just not sure if it is worth doing. What do
you think?

-Longman

