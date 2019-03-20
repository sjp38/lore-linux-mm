Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4889C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:10:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E16E2175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:10:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rRSjBEvu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E16E2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 271E36B0006; Tue, 19 Mar 2019 21:10:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 220206B0007; Tue, 19 Mar 2019 21:10:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C3F36B0008; Tue, 19 Mar 2019 21:10:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9C096B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 21:10:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z1so779256pfz.8
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:10:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=hIdsISv5yPCS5cuuuJe1mtyrZh/Lcqy2MMFx/vVZ7bA=;
        b=hzDvPyF7zqqjvsabC7ier7527fcqqJP/CFLlmzXtKsx0GQnC26dCp2iBDHt4GRzkx7
         7gVlJlYeu8n3oWzXsGuO/1sFeuE59mcHkpLQ66Y1eLz0wV03TcBU22CXx296FapHmsk5
         O8g6M/R6MUxhgC4wX03jyX2xvoNqWfu7Pqbh6sWXuAXZyNcgzvLvXBhAwspIENoDF/qk
         JL9Cf2OZfk/uGlJbfCD0/nwWpiQyKd3+YPrPhl2PkzZdMl2yYAul2vssxKVskVuEWdrd
         YQIr+IqcIJ30FKc7rbmJOUr1KMX/uc5avkSeeCwJGeghJ5QPDZSbuwzxW5eN6V2hBTV1
         MM2A==
X-Gm-Message-State: APjAAAXt0JeR5P3hIjMVZMXVcn+nkFfod3HIK6SfDXHHtyABVQyxyk+G
	8vDGmepm07RAT9JI30z3zewh7/yXoh81R4AOC3kfiy3LM0yk/GNCKnoKT/wL0XimPXIYb2FPjY3
	VDDTrvb9GHFE/mcBvHaYY3GTl+7GtmnyXBEk+uzMJRbWXkj1Rpnqab3GCgGFb3Kcf1A==
X-Received: by 2002:a63:1b21:: with SMTP id b33mr4679092pgb.245.1553044252210;
        Tue, 19 Mar 2019 18:10:52 -0700 (PDT)
X-Received: by 2002:a63:1b21:: with SMTP id b33mr4679024pgb.245.1553044251158;
        Tue, 19 Mar 2019 18:10:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553044251; cv=none;
        d=google.com; s=arc-20160816;
        b=dBbt0iILdolGCiFSeV1WMgejXXXQPjnW5gk7/HDKGzHbUE8c2lM+NDsFVIlpkZTvch
         yYI86/Y3huSjOj39ECvcxNtx21bJgpEZfA9B79Eu/mDpix3oZFmbkbTVw0Dgx0/w1nvD
         ZpyGSi+0Yi5iH46PvFfh+5jOgHgj8O+EDUtSi8oKGgFnLPdnlIzoCbZyYbpfgKnW4ahP
         O8hQK2lXgkTpMFA2DVsq+4BcBlBZwpIOkuGrfr68bhc5ReTJwR8qvHmDKv40W/HslfrT
         /u7iigY3c6zaQNowj06qrvelMWCAfERt7EEwcqQIK1kNLSpOcjD9+k88MiqHoZGkR/9Q
         vl5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=hIdsISv5yPCS5cuuuJe1mtyrZh/Lcqy2MMFx/vVZ7bA=;
        b=FVYSa1MJPNIKld7jMhRoYw9nSfh1zVA3Lu2qXEvoy1q5fACu6xyglseSZ3/QmC2gqH
         5A9tuky266wv7S5bR7JrwUNoanh+e4Zeo0ZHzrMmhJCb7+V5BfjSoeqINFuGi5N/7cRQ
         KvoIJIGp+SR8NzHx3JU7+YO1jUT2NXJ9P8eTFuF+daIgwZB4Y3yCtJ041I71vXEbAuBk
         PJVn/qzkKImE5Y4SxfhTH6kGeRDQfBNa1VpUkAwwWJ2z+/+BgTVa57EuMjcXxMm0fKVk
         kw3qf8zOoVEW67Y7O35VTplYzSPQzLB/fU3lrx+fFgQv/whDwt+e8WVPh/k5JLGiDZAU
         GYhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rRSjBEvu;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor471441pgr.22.2019.03.19.18.10.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 18:10:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rRSjBEvu;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=hIdsISv5yPCS5cuuuJe1mtyrZh/Lcqy2MMFx/vVZ7bA=;
        b=rRSjBEvuq6CwPO6V8PH4QpUhIcHsuJza6P4nOekQnxYO9upU6QfONfU7Di8xmmLY5T
         tuWWsYMB5NiYqWVk78vNyqORKp/d4ZMAUSJ/Skney/omDNoBJqjkTDKMIj2QGWjxYwLB
         DkxUhvqhj4Nhr2kOpHknroYrlpltyEGKDrnLPFZTsRDgYDdsmqLutK8qY8p+rFNvjRAB
         PmH9xtdWdo36iAELA9Zmnn8XsL8Ofyrkrl6uQv2mvWLXbOndc+cMQJYlS/q1MToeTQeB
         QUlgeEKe12NnNZPyCSR/jXPyuBQVkHyZzugzRsiaFWed6LgtIFISI0ObvmnHT5v1wQUy
         cfOQ==
X-Google-Smtp-Source: APXvYqzNqxQ10Cek3L6LMJxVKefwkQ2rsGRE5G0ZuTEekssOFYsim2t3TLLX3pEP6tJmdMNScHADlA==
X-Received: by 2002:a63:e554:: with SMTP id z20mr11865916pgj.234.1553044250539;
        Tue, 19 Mar 2019 18:10:50 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id b8sm332538pfi.129.2019.03.19.18.10.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 18:10:49 -0700 (PDT)
Date: Tue, 19 Mar 2019 18:10:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
cc: Chintan Pandya <cpandya@codeaurora.org>, Joe Perches <joe@perches.com>, 
    Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] driver : staging : ion: optimization for decreasing
 memory fragmentaion
In-Reply-To: <1552561599-23662-1-git-send-email-huangzhaoyang@gmail.com>
Message-ID: <alpine.DEB.2.21.1903191809420.18028@chino.kir.corp.google.com>
References: <1552561599-23662-1-git-send-email-huangzhaoyang@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Mar 2019, Zhaoyang Huang wrote:

> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> 
> Two action for this patch:
> 1. set a batch size for system heap's shrinker, which can have it buffer
> reasonable page blocks in pool for future allocation.
> 2. reverse the order sequence when free page blocks, the purpose is also
> to have system heap keep as more big blocks as it can.
> 
> By testing on an android system with 2G RAM, the changes with setting
> batch = 48MB can help reduce the fragmentation obviously and improve
> big block allocation speed for 15%.
> 
> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> ---
>  drivers/staging/android/ion/ion_heap.c        | 12 +++++++++++-
>  drivers/staging/android/ion/ion_system_heap.c |  2 +-
>  2 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
> index 31db510..9e9caf2 100644
> --- a/drivers/staging/android/ion/ion_heap.c
> +++ b/drivers/staging/android/ion/ion_heap.c
> @@ -16,6 +16,8 @@
>  #include <linux/vmalloc.h>
>  #include "ion.h"
>  
> +unsigned long ion_heap_batch = 0;

static?

> +
>  void *ion_heap_map_kernel(struct ion_heap *heap,
>  			  struct ion_buffer *buffer)
>  {
> @@ -303,7 +305,15 @@ int ion_heap_init_shrinker(struct ion_heap *heap)
>  	heap->shrinker.count_objects = ion_heap_shrink_count;
>  	heap->shrinker.scan_objects = ion_heap_shrink_scan;
>  	heap->shrinker.seeks = DEFAULT_SEEKS;
> -	heap->shrinker.batch = 0;
> +	heap->shrinker.batch = ion_heap_batch;
>  
>  	return register_shrinker(&heap->shrinker);
>  }
> +
> +static int __init ion_system_heap_batch_init(char *arg)
> +{
> +	 ion_heap_batch = memparse(arg, NULL);
> +

No bounds checking?  What are the legitimate upper and lower bounds here?

> +	return 0;
> +}
> +early_param("ion_batch", ion_system_heap_batch_init);
> diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
> index 701eb9f..d249f8d 100644
> --- a/drivers/staging/android/ion/ion_system_heap.c
> +++ b/drivers/staging/android/ion/ion_system_heap.c
> @@ -182,7 +182,7 @@ static int ion_system_heap_shrink(struct ion_heap *heap, gfp_t gfp_mask,
>  	if (!nr_to_scan)
>  		only_scan = 1;
>  
> -	for (i = 0; i < NUM_ORDERS; i++) {
> +	for (i = NUM_ORDERS - 1; i >= 0; i--) {
>  		pool = sys_heap->pools[i];
>  
>  		if (only_scan) {

Can we get a Documentation update on how we can use ion_batch and what the 
appropriate settings are (and in what circumstances)?

