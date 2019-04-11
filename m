Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2B6DC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:38:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA01B206BA
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:38:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA01B206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 274EC6B000D; Thu, 11 Apr 2019 10:38:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2220C6B000E; Thu, 11 Apr 2019 10:38:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C53D6B0010; Thu, 11 Apr 2019 10:38:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 953E96B000D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:38:08 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id s7so1451660lja.16
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:38:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=h76eSpzne8M4TmoMWfvEL9HDmjbo6inSFUsCztM/xrI=;
        b=rD8X+c52XND6XtjXHIe7mP48hicKL/tHxHYP2wu3TKr/zu78quKhBb5J+S8qAMz/AY
         OqmFPGASQ82KY0Ol/KF08lTxOL4VcnLFuexcwXxAVvaeZ9/++N6NCVfVvgbnV+1D5eos
         BzGDsnnEoJMEgTMBxlI6nF0/AMYL0WpWFFF4DFFxzxKBkZo5H9QZMeKKNtu45piv8aOw
         O7ai0Taf5VstDx5PqDIQq88h+SJwfX3Q+Aw2nWRSjGVjXOdCjhifDijyDRBCQFaxWJxj
         ra/K0C4TugJGKE1fLhYDcGGynAZ05V4m08i2ZV+vo7BDG5PWXJNGj8QNNClEKnLlDrLT
         jjwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWit0JB+aBwZcTYOp2q7KN47XJ8h7WHh7S2NUq5G6q6RgMy/404
	HlysUdWzafl0kKvXjnn5rHRRScmyrlxLx2pSHwcneDumYy8SN0p4hJo4g2elBbfOcDWHAH4fZkx
	i7jWO8n7k4NEbgmALEZ1lWOmXgwrIZVVBdJ9vgIcir2tJpxQ3UYcKnJz38ehaM14sWg==
X-Received: by 2002:a2e:7805:: with SMTP id t5mr26344560ljc.106.1554993487931;
        Thu, 11 Apr 2019 07:38:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKR1AVCzVkZuvrwx2WVbcQeUfJVtRMRr4eLAEf7n3Vl8O1fpinsHqE+O7MiOGsF3SrhqR/
X-Received: by 2002:a2e:7805:: with SMTP id t5mr26344524ljc.106.1554993487058;
        Thu, 11 Apr 2019 07:38:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554993487; cv=none;
        d=google.com; s=arc-20160816;
        b=jwZK1TiaugHkRsG9qrfhcvbABUmbWgFY3/4q7BVx8mMFkMUKHYsuWOcSZjZ0FLr1q5
         jBJ9SGBvdbaYd7F4G1LEOOioWVEwHRLpSzjBviRqTxC4vaPGRtNXlNYuVAG/IYxeUtP3
         FfxSTIrSyrwL3/JjIVIMN6UWLu97qGWYEGl8wp1D0bL1og0cCNnrPtadgqqwipIdc0J/
         x4tG/gLchBwKJeJaSZfSzNIfFSjjPbNv4npYyvVaMOdXtBOybTpkIqyi/KjKrkTlbpec
         szk1FeeXQF92fDkEoGYchgoYh/3hxBr4UsItOlPsL7veiRU5N+viHezi7+QNJO70mnyl
         tFNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=h76eSpzne8M4TmoMWfvEL9HDmjbo6inSFUsCztM/xrI=;
        b=A06k5qjrhgL5qnQILGkNNXdbCsu6pbOnfbrj7D8ol418CcHqjwh/aDygM7pZaML1p+
         7axbVv2cHZJssoJEsvaDc6Z2SkTigaCU28kpDOhmmkb1itunBSDH5MlnPLGnrVtwGT6c
         +bkkLneXiDSZMH5Oo1EPx8JtiYDaeWbd26Gi0p5PxOdcO8l5Wn1DNbOSFAiLUl+8dfL4
         TMtikTwFFrwa/c+mWjoYxpE9ktAPGIwGkvdtaA3JjEz0+IQwjC6XxFyo8sjKxVuORPLv
         +slf1RbVA1+Ux84yvEkRuEo8g5oOL1wfR6ZIUpVyu0SxBKsyOw9a2SQOStKKWad5WuXx
         tyRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id a1si27044055lfo.3.2019.04.11.07.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 07:38:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hEapr-0002mK-Np; Thu, 11 Apr 2019 17:37:51 +0300
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
To: Waiman Long <longman@redhat.com>, Tejun Heo <tj@kernel.org>,
 Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
 Shakeel Butt <shakeelb@google.com>, Aaron Lu <aaron.lu@intel.com>,
 aryabinin@virtuozzo.com
References: <20190410191321.9527-1-longman@redhat.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <1b6ee304-6176-15a0-c3fa-0b59cdd60085@virtuozzo.com>
Date: Thu, 11 Apr 2019 17:37:51 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190410191321.9527-1-longman@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.04.2019 22:13, Waiman Long wrote:
> The current control mechanism for memory cgroup v2 lumps all the memory
> together irrespective of the type of memory objects. However, there
> are cases where users may have more concern about one type of memory
> usage than the others.
> 
> We have customer request to limit memory consumption on anonymous memory
> only as they said the feature was available in other OSes like Solaris.
> 
> To allow finer-grained control of memory, this patchset 2 new control
> knobs for memory controller:
>  - memory.subset.list for specifying the type of memory to be under control.
>  - memory.subset.high for the high limit of memory consumption of that
>    memory type.
> 
> For simplicity, the limit is not hierarchical and applies to only tasks
> in the local memory cgroup.
> 
> Waiman Long (2):
>   mm/memcontrol: Finer-grained control for subset of allocated memory
>   mm/memcontrol: Add a new MEMCG_SUBSET_HIGH event
> 
>  Documentation/admin-guide/cgroup-v2.rst |  35 +++++++++
>  include/linux/memcontrol.h              |   8 ++
>  mm/memcontrol.c                         | 100 +++++++++++++++++++++++-
>  3 files changed, 142 insertions(+), 1 deletion(-)

CC Andrey.

In Virtuozzo kernel we have similar functionality for limitation of page cache in a cgroup:

https://github.com/OpenVZ/vzkernel/commit/8ceef5e0c07c7621fcb0e04ccc48a679dfeec4a4

