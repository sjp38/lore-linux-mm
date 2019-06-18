Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B42F6C46477
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:59:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A796214AF
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:59:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A796214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 255166B0005; Tue, 18 Jun 2019 12:59:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DE548E0002; Tue, 18 Jun 2019 12:59:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0812F8E0001; Tue, 18 Jun 2019 12:59:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9A9A6B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:59:52 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c4so12827171qkd.16
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:59:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=jbg2gvpZyX4cO6a3E9Z4XawgBlE+FKPXjXpiA3SrO7M=;
        b=kILWY2cMxihK8+RO5rV1X5fS9mF+371JYOnpYbFmLcj77ZMvDfF0c/Gz7+5cdy4SiD
         xh8HrxaMADtfbANmn0PkXHMaOc8l3GgEGEBAIaoD4MKB95vqoAPBqY58lXWTl12Gzxqn
         sCakTkJyvUmnY8sP0CORGAqxOI5ZNtKAgTEfVLjoM5VJDwvde51TdqYDrCchah9aEEMM
         3qjkk03/VvWFFXXURmi1Y0ZFpu7B1omCTHR3jy9+fHsefmRe119lOOrxwYNAODV/By/x
         kaP3CVzpUJzSpRBymtetsgeVzBtIIHiMza69bSR17eqW0V3fwRetu8/lx84ktS+0LvpS
         jN8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWB6hoUIuYim9cXTizCbubrIeLfvOECgS2ZYYwTbBc1HLMjjgnc
	oozeKr5Y9dThe6fir9KbJGfJN0HI0StQeOFZXbAvufaZXY3WVBePjPTMpTQmpLCqM7mJyinXLT4
	1Ydy0e41rX8OnXDhobyV0VdLDUqOupmSz8N+LRGu7keov/BidIZ/rZM0EsJfs/X6o3Q==
X-Received: by 2002:ac8:41d1:: with SMTP id o17mr26596262qtm.17.1560877192666;
        Tue, 18 Jun 2019 09:59:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKwct+1uTZKLW2hW/x1DMDj8vDrG+WKQxqzJ48Ch2PMoD9fv742pE/JVc7FZH//Wrg5I9p
X-Received: by 2002:ac8:41d1:: with SMTP id o17mr26596219qtm.17.1560877192090;
        Tue, 18 Jun 2019 09:59:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560877192; cv=none;
        d=google.com; s=arc-20160816;
        b=0i+VHoR5fnhfXrKLjtNFcTeSjTfCs+5IfNCmKbPVD+WDH8WPL0t+IuabXNkqOgb1dO
         3tL7SV1F1J0/hZAgNYbYzcGDSmhbSqLvbCG8dQb3CnYB2pvebupLehbQqG4dsqqJ9qL+
         /q16rUJIAQajAi7KBGPrN/bepst9OCA3cdxEC2XAggc1R+UkbZpTEmzgfuUi1jF0uufP
         KYesNKBS1cgsNtNF85SSlyP9NGpc0fB/xjpJtzVEHb78E/gR1tEsdWE2wO7QasCtmuis
         ijzyrjgEO8gRrIG/sMvWTo1ehmkI3bdqJMISUdUwvgzEbYWNcGRruu0PpAn/r6YLkhBc
         RTWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=jbg2gvpZyX4cO6a3E9Z4XawgBlE+FKPXjXpiA3SrO7M=;
        b=T7N8zUS91dHMea9maOgQAIOtpGJ0ePPH/8mciwrZ0iV9NBDCAJextosgFdkZGc1aRE
         MxclNehxtvXsmIfP1wQUhNA15RDIjU1nQhX8U6rrnvZVI9NqGTJrpKhaKC8vZj+eSY2Q
         IN5SjBh/kLhLAs1rHz5acqhog1DwIdhgHNaLTgZMafHv9rQEqWqaRuHmno9q2QPuKjBW
         5pUPIJ4MonQzg3sFln4FtItiliUqWRCDHf6teME3aqKcVDfWASGewVLaxcszE8zyn3D+
         4Nc73XJwIyPXouWHgkf0SF4+MZlFYepP7gdRcT3lDvJmUtmUFmZnJHj9+d37Mq4BqTOG
         Bivg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i3si1845031qvt.69.2019.06.18.09.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 09:59:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7200C3162909;
	Tue, 18 Jun 2019 16:59:30 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8A3241001E73;
	Tue, 18 Jun 2019 16:59:24 +0000 (UTC)
Subject: Re: [PATCH] mm, memcg: Report number of memcg caches in slabinfo
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-api@vger.kernel.org
References: <20190617142149.5245-1-longman@redhat.com>
 <20190617143842.GC1492@dhcp22.suse.cz>
 <9e165eae-e354-04c4-6362-0f80fe819469@redhat.com>
 <20190618123750.GG3318@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <dee4dee2-1f4f-a7c9-0014-dca54b991377@redhat.com>
Date: Tue, 18 Jun 2019 12:59:24 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190618123750.GG3318@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 18 Jun 2019 16:59:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/18/19 8:37 AM, Michal Hocko wrote:
> On Mon 17-06-19 10:50:23, Waiman Long wrote:
>> On 6/17/19 10:38 AM, Michal Hocko wrote:
>>> [Cc linux-api]
>>>
>>> On Mon 17-06-19 10:21:49, Waiman Long wrote:
>>>> There are concerns about memory leaks from extensive use of memory
>>>> cgroups as each memory cgroup creates its own set of kmem caches. There
>>>> is a possiblity that the memcg kmem caches may remain even after the
>>>> memory cgroup removal.
>>>>
>>>> Therefore, it will be useful to show how many memcg caches are present
>>>> for each of the kmem caches.
>>> How is a user going to use that information?  Btw. Don't we have an
>>> interface to display the number of (dead) cgroups?
>> The interface to report dead cgroups is for cgroup v2 (cgroup.stat)
>> only. I don't think there is a way to find that for cgroup v1.
> Doesn't debug_legacy_files provide the information for both cgroups
> APIs?

Not really. The debug controller doesn't provide information about the
number of dead cgroups, for instance. Of course, we can always add those
information there. Also the debug controller is not typically configured
into a production kernel.


>> Also the
>> number of memcg kmem caches may not be the same as the number of
>> memcg's. It can range from 0 to above the number of memcg's.  So it is
>> an interesting number by itself.
> Is this useful enough to put into slabinfo? Doesn't this sound more like
> a debugfs kinda a thing?

I guess it is probably more on the debug side of things. I add it to
slabinfo as the data is readily available. It will be much more work if
we need to export the data via debugfs.

We are seeing the kmem_cache slab growing continuously overtime when
running a container-based workloads. Roman's kmem_cache reparenting
patch will hopefully solve a major part of the problem, but we still
need a way to confirm that by looking at how many memcg kmem_caches are
associated with each root kmem_cache.

Cheers,
Longman

