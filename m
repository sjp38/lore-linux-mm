Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B71BC76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 18:09:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0022E21849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 18:09:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0022E21849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B07A8E0003; Thu, 18 Jul 2019 14:09:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 761628E0001; Thu, 18 Jul 2019 14:09:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 651028E0003; Thu, 18 Jul 2019 14:09:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 468EE8E0001
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 14:09:03 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x10so25073448qti.11
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:09:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=sBWOqE2A010CznC7NX/a8DiwlqgQs+NCyT3Z6+Tcnu4=;
        b=fcbN6tSIQByWT8s6T/wOygKjkxrq6shSb4u4B/it8wvDgkI05Vg7RB15CD4ffMbU4k
         qWUAU8FXac8U+XldZ9a+72J1h/tCe4FhwnZqe1y6NVtVht2ThrE7QGJaBKTGuCGixcCz
         Nh4Ac8YsgFXhQOdhNcycm4f+pKOBrOYrglyMnMKD+WH62vPjiyZwZ5MGBf9e9l9DGRtw
         AsCh6j5FbglC7rwnmnaMElghIRIa18st008o54JBG4v92LrJ0FB4FSJyCRtdFnJZE/vs
         JhPVo3bAaAP4ztSWpXWU1K0liZZbs8WUhH15IJBs72V0TmcC80pU7R6Nga/LwQWqHc8q
         evuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWgI6lQ4eoyo0Qj3EdOVQUjZRjnu04nvcdq5dpbacCas3yT4msJ
	Qr7YHTR9W9+TVPU/w3UzdeZzqNLTELaMLwnXPp4fOc9t7hNytsY+YIjMbMviEkt7gmC4SVpzqcF
	fJT77krojTuqru+1p/uArvfS6yzWKl9QXA8vUbWpasZTc19j1vl3qhBYR00Dj+NeSgA==
X-Received: by 2002:aed:3ed8:: with SMTP id o24mr32062364qtf.252.1563473343079;
        Thu, 18 Jul 2019 11:09:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznQ+w46FiomMw+GKPfkRUbHi5veqp749jCL8bSi/mhFB31sgsHbeUbvndB+b9KhyPBgz9V
X-Received: by 2002:aed:3ed8:: with SMTP id o24mr32062336qtf.252.1563473342681;
        Thu, 18 Jul 2019 11:09:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563473342; cv=none;
        d=google.com; s=arc-20160816;
        b=KCwvn/iaoUZrVHh+KYQ29Pa0edW9bajuTHyGxUHpfjPF0BiuzOT9V4NGjIy5CzmiUL
         NYyjo6/AWBpd37f0HMSg7Qnt0GVCzQwLV0NVx+TBCESDNAJL5jvVstitvEhuuJynHFIZ
         j4Q/rUciAK/bUzjF22gX+iZ1it0w55P4zItT6QTn7D6essc4WMs1xTLaUclVGIhtWh6z
         WXm+JE8WfZGxCaIUrVwN+dzbJUb/EcJCegiKz46HKPKfi7GCn9Cn46tHkTqMAifkDkel
         BHWxF/5MMsj7oc8flafTXyziYbJRLrZL/jwzCaM9MxFpV9AkZ40TILTedBdzEP2ZzpWX
         Obkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=sBWOqE2A010CznC7NX/a8DiwlqgQs+NCyT3Z6+Tcnu4=;
        b=aSJ7fNg8Rf4igMq6lEQxJ/dqE3Mq5yIPRXwpuu99G1JUzmm4EJeBCa+fWgx7d9MBzy
         hhLW3BvxYd0d+OzyxU7y8l+GWMTxmpmFIDGH4d8wTn39vx8r4uD8EJUUV0DWfTY/SlH/
         xedFJFXjg/tTOnXvgxSA6YzrBttUrLApx4ZFeFJoWE86lNrgvKVOut1Laas+uwvOYANA
         TgObJdyemQspfc1Cf6/2kEn6o+rJ8tuUuQHMSOYzxG6E7ALJQBrKjBDbfY/KhPkLFf2U
         MWLcFpKZGpSqcbpnEvmkFHZR2s/cSsbxCfLKySfhE0TQZZg7dcUEsgxJKYN4w8lAw/7U
         q89A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m19si16452124qka.219.2019.07.18.11.09.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 11:09:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DA9DC81DE5;
	Thu, 18 Jul 2019 18:09:01 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B827360922;
	Thu, 18 Jul 2019 18:09:00 +0000 (UTC)
Subject: Re: [PATCH v2 0/2] mm, slab: Extend slab/shrink to shrink all memcg
 caches
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
References: <20190718180733.18596-1-longman@redhat.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <4d2ca559-4a59-1368-7b40-f05b9aefe84e@redhat.com>
Date: Thu, 18 Jul 2019 14:09:00 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190718180733.18596-1-longman@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 18 Jul 2019 18:09:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/18/19 2:07 PM, Waiman Long wrote:
>  v2:
>   - Just extend the shrink sysfs file to shrink all memcg caches without
>     adding new semantics.
>   - Add a patch to report the time of the shrink operation.
>
> This patchset enables the slab/shrink sysfs file to shrink all the
> memcg caches that are associated with the given root cache. The time of
> the shrink operation can now be read from the shrink file.
>
> Waiman Long (2):
>   mm, slab: Extend slab/shrink to shrink all memcg caches
>   mm, slab: Show last shrink time in us when slab/shrink is read
>
>  Documentation/ABI/testing/sysfs-kernel-slab | 14 +++++---
>  include/linux/slub_def.h                    |  1 +
>  mm/slab.h                                   |  1 +
>  mm/slab_common.c                            | 37 +++++++++++++++++++++
>  mm/slub.c                                   | 14 +++++---
>  5 files changed, 59 insertions(+), 8 deletions(-)
>
Sorry, it is a mistake. Please ignore it.

-Longman

