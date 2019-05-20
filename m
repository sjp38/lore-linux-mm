Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03DD5C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:54:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC85B206BA
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:54:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZU1x/Bp2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC85B206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31FE16B0005; Mon, 20 May 2019 10:54:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A90B6B0006; Mon, 20 May 2019 10:54:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 170BC6B0007; Mon, 20 May 2019 10:54:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2C316B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:54:28 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id c2so3372984vsm.9
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:54:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=8cXCSMG/utY4UucWb4ekygNexeTn9aJiisIiVvtivhA=;
        b=bsLgsYLQ55LOEDhTrObHt9DB5yp8nV7vH8AgRskq7vIFycmXKMp4wXbRa52rJ3talw
         H91YSlRyrcbDK40gY+3jZqElzCKrzVc9Q0/qdq1eoIBalrj5RmCRRqirRT+5yUt5uM6n
         BDGqMFTWm99E27xvK0xrC9aXI+1swgaARIQfwB0HWu3xTQ++6maJNPuMyNpyrhrrYD2g
         +sV+qQGlu+LYysj/phTsDmdW929+/Ijs5mXPYnTKPF1dJHLjocuVHNZ+pNBZ8IBhZi+n
         WFzWEGVdzEQ0YCjhvOylu9a0gp1jhtaQyM+Ta9jpbOTrgC6KdsOniCLAmUDGjf3Tf8k7
         ghlg==
X-Gm-Message-State: APjAAAVXY+5Ax51uoPWtTwX/lz+D3+5SWOa4eMYTknvOma4H4Qwut88i
	e0hBUf5SSiTZ2BEitXUr9Y6+sFjY0ZKhILcnB3lBOc+ir5Ca8DHwYX6FvchzyorMir5EaAheZxj
	ZFvTAc9Kn2H8FzN0Ev7yb/9j3FTIMdPpKyYjg/lURoAeHDsRhVEfw0yUp9h9w81oWvg==
X-Received: by 2002:a05:6102:c7:: with SMTP id u7mr22334964vsp.226.1558364068616;
        Mon, 20 May 2019 07:54:28 -0700 (PDT)
X-Received: by 2002:a05:6102:c7:: with SMTP id u7mr22334900vsp.226.1558364067989;
        Mon, 20 May 2019 07:54:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558364067; cv=none;
        d=google.com; s=arc-20160816;
        b=sf9CJ2dpSaKI/4R1lXevHA+Vr2G6upryWke9kAqjf/Rz0/wSSavO4CVIp/0ZA7Nh9p
         OUXVBMKv8ALsHBoOUsG7Wj0qhlof8GyHjGyI58ND3c2ID5casm3MJHxJ+bLTPPxXCtPp
         oqNb0xzrOmABQSLZgNsZG6Z0kp5X6ha4MWc3rhIWNjmTRGj2s6DgJR3ot2bTVH9OLPUc
         29Iim33YVJjDgWWHSWeGZR9oO9aaNLgEknNu4HFwdtTjSnGt3HNOElH4d4R2RImlPmhI
         nF7NHQBli0YrWcDE3RCQhofuRngllHmx+/oCXNl7qH1oSX52gQQE6KFyLyEVsNUGroGu
         bLmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=8cXCSMG/utY4UucWb4ekygNexeTn9aJiisIiVvtivhA=;
        b=jKl1ZUcTNMFZBAjOF6s1ea3l0vRmDZKVNwDkda2x1TT8OkQFNbMZg666gLpgxMTAzB
         KnP4XHCTU6Yv94NPMuQGrPYvg8dKTcwYpCN6sPdm1hnc5kYQUWe6qfrTUenkF7JvGpRO
         +CoDM76iRl/JyFeqU0vScj5dTnOi/t/2jU54XDSpd6rRv3mX3uOCWkT9bri7/S656b5H
         67iy2FPmRXMFzA8fTFJr7fBK+LCFSSYajlgSZzwkJCugIrdq2Tr7a9G9zQsRat7s8Wxm
         rROiSBECmEQVjNF3yUCKrVicO7XaHo9dcZ4h1mNiFflBEoYhHCRl1M42spPSm+jLk69L
         bd4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ZU1x/Bp2";
       spf=pass (google.com: domain of longman9394@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=longman9394@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x26sor598174uar.56.2019.05.20.07.54.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 07:54:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman9394@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ZU1x/Bp2";
       spf=pass (google.com: domain of longman9394@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=longman9394@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=8cXCSMG/utY4UucWb4ekygNexeTn9aJiisIiVvtivhA=;
        b=ZU1x/Bp2X6efOLs6VCJ6w1Y0/Tx//zW4Ud90lRRbRSmCiz5AojOo473KCRA1bw98rL
         Xr8VvLNK5CrMk2GXwtG407SUCkWPF3GcdHtkGzyYxq9CO0MN8PeXxCh2EVJV95XXloKQ
         ts6dEhyIdh71+h7iYVn147d+/97Sj7jezcx+AncoJt0Js2Pki95HdfKfeuxQ4aK0LrEg
         L8w8tHdtnJzu6vuHtsCmaj698Jci8ICsaiU5knDuPLCDSgalX75JuSBfVb/yntUmDFBz
         guLP5Ak5FGNc8SFTBSYNfxGmPH3qKxIYZspdEBK9dNELQhFtZteuW8hrYaPt9WWJauX4
         qMNw==
X-Google-Smtp-Source: APXvYqwlmD0ueYLqSZ4VSGxhwR1uaHyYJwtikMj8/LvKbmobY+swajNr6uJX9UnneAMOHiTbm0GAbw==
X-Received: by 2002:ab0:42e4:: with SMTP id j91mr14823452uaj.28.1558364067745;
        Mon, 20 May 2019 07:54:27 -0700 (PDT)
Received: from llong.remote.csb (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 125sm5502165vkt.11.2019.05.20.07.54.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 07:54:26 -0700 (PDT)
Subject: Re: [PATCH v4 5/7] mm: rework non-root kmem_cache lifecycle
 management
To: Roman Gushchin <guro@fb.com>
Cc: Shakeel Butt <shakeelb@google.com>,
 Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Rik van Riel <riel@surriel.com>, Christoph Lameter <cl@linux.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
References: <20190514213940.2405198-1-guro@fb.com>
 <20190514213940.2405198-6-guro@fb.com>
 <CALvZod6Zb_kYHyG02jXBY9gvvUn_gOug7kq_hVa8vuCbXdPdjQ@mail.gmail.com>
From: Waiman Long <longman9394@gmail.com>
Message-ID: <5e3c4646-3e4f-414a-0eca-5249956d68a5@gmail.com>
Date: Mon, 20 May 2019 10:54:24 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CALvZod6Zb_kYHyG02jXBY9gvvUn_gOug7kq_hVa8vuCbXdPdjQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/14/19 8:06 PM, Shakeel Butt wrote:
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 4e5b4292a763..1ee967b4805e 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -45,6 +45,8 @@ static void slab_caches_to_rcu_destroy_workfn(struct work_struct *work);
>  static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
>                     slab_caches_to_rcu_destroy_workfn);
>
> +static void kmemcg_queue_cache_shutdown(struct percpu_ref *percpu_ref);
> +

kmemcg_queue_cache_shutdown is only defined if CONFIG_MEMCG_KMEM is
defined. If it is not defined, a compilation warning can be produced.
Maybe putting the declaration inside a CONFIG_MEMCG_KMEM block:

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 61d7a96a917b..57ba6cf3dc39 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -45,7 +45,9 @@ static void slab_caches_to_rcu_destroy_workfn(struct
work_stru
ct *work);
 static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
             slab_caches_to_rcu_destroy_workfn);
 
+#ifdef CONFIG_MEMCG_KMEM
 static void kmemcg_queue_cache_shutdown(struct percpu_ref *percpu_ref);
+#endif
 
 /*
  * Set of flags that will prevent slab merging
-- 

Cheers,
Longman

