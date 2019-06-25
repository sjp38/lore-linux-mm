Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5297DC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EBA1208CA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EBA1208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D7456B0003; Tue, 25 Jun 2019 18:30:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 961668E0003; Tue, 25 Jun 2019 18:30:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 828078E0002; Tue, 25 Jun 2019 18:30:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4789A6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 18:30:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x9so199133pfm.16
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:30:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=WcXdXf7UfxPdAjw8dJxo9ZwjX0byo09DEKRlSo14mkk=;
        b=E/afrZROtl+2ut+OeIVNPfUvUJFHPFHsm/acbu2I+a3M1WIVMuRy82Zg8ny6R3NHok
         ZUF8PBEE+R+tlYnP6BTtwp4zJXRHxAv/qKrUELZ2duT26CVU0Hg3HfUvIDNTIUsEQ4ew
         jeppMlocyYNV/a42+FkM6rQL7p+VqKlePRaMwu+jktTp/zEashW9oTgmn3gy4EMpfCtl
         2lxI4BjQs4VvXZEvnz4Rw3A2qdYzuneookjqXMXJs0sRH0+oznLqs2mhMIyBWYWsjNyi
         Kyb65N1431s69mt6fIH7EnamZ0MToQvuPHzUjE+RFn95Ba/wX9LUi7rKd93B9eIW4dGb
         5dMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVxNf8sOVqr4EdWrtk6/lCkWCzCnejjl3gxbpUZLhkSCCTlEfpq
	ZorScuxb3mOL3looPhY8NHiHa3SoKKyvp/Z8kHtAjeMN6GxxmXFmdibFetJ1rkY1RDdxUuxe7TY
	3YLDfDmSszZP2ZQ8L5ycqb5nfSjPlbWDXku5XinBtTHbgQnuoObn/+m9Gdugp3v2dlA==
X-Received: by 2002:a17:902:8489:: with SMTP id c9mr1095366plo.327.1561501819780;
        Tue, 25 Jun 2019 15:30:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6ww8OAdF70CDS9gSnh+3mccKqCA48WyqlfkTjVx7yzTaUj+I2foKSnAX1jMbNtiy0eZ+l
X-Received: by 2002:a17:902:8489:: with SMTP id c9mr1095316plo.327.1561501819167;
        Tue, 25 Jun 2019 15:30:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561501819; cv=none;
        d=google.com; s=arc-20160816;
        b=UEL4otdBMwpI/srlCQHpsSbw5zTk11t8vB9tT6zIzv0Kq4ClAXde5v8qYri8BFewhY
         EEKSBfJYl7AvW9GQDim8ecysOqNYX30zE1mu+ZV07uXioPuSCX4lpx2qPoHVz8TI9DhK
         qOYomYxVVADAUYJmDpcf+yvoaUUqFbAjsr2HlCvIZbQL80cPSvdgsyHi3AWcPbM0fBh1
         5TWrJf+IIiSuvpbBm5l4KQL+ChzSq3qLaPErzvZEz4vjU7aN6FDENpHCPxG9xvnOcyEm
         JHFbKIQkbcvdZmVN4AogufBMzjwUZk2RhLeJwe7YPuWZuXPcbT/URrUmvblCdotIbau5
         pRTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WcXdXf7UfxPdAjw8dJxo9ZwjX0byo09DEKRlSo14mkk=;
        b=nLtGwcArwlsMb7TKYUe22NM1e/YY+kGcByE75Q6oXMx9nslFUFQC0U19MRhetQ1dD5
         7QqZNr5c4wCjaislKacyLs1rcflOEdX1DXlyaIsLilIBgqv3cSsjgxfUw7XYpd04ftv0
         BbA/LdX8XOe9T/eXHQH1EDo92zlreMbs4k7uBt5qlv9+VhJhY2V8SLZEjBZTCoHu5rrc
         CbV9FoInesl0cyL+MFQPp6mlnzhVtmOzvrwaN86wFlDuXC6FsQ588YPCI1RbePH6udaW
         TRFvpt6wnNsLk0gdYvMB5OiYYKt/VRMn7vuv70WezFgct9Itp21VnrQWNWNgCsK7OeAb
         o2Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id m6si110914pjl.60.2019.06.25.15.30.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 15:30:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TVCU4oo_1561501813;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVCU4oo_1561501813)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 26 Jun 2019 06:30:16 +0800
Subject: Re: [v3 PATCH 3/4] mm: shrinker: make shrinker not depend on memcg
 kmem
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560376609-113689-4-git-send-email-yang.shi@linux.alibaba.com>
 <20190625151425.6fafced70f42e6db49496ac6@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3d099616-2fc6-fa4e-377c-2f406e3302f9@linux.alibaba.com>
Date: Tue, 25 Jun 2019 15:30:13 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190625151425.6fafced70f42e6db49496ac6@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/25/19 3:14 PM, Andrew Morton wrote:
> On Thu, 13 Jun 2019 05:56:48 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>> Currently shrinker is just allocated and can work when memcg kmem is
>> enabled.  But, THP deferred split shrinker is not slab shrinker, it
>> doesn't make too much sense to have such shrinker depend on memcg kmem.
>> It should be able to reclaim THP even though memcg kmem is disabled.
>>
>> Introduce a new shrinker flag, SHRINKER_NONSLAB, for non-slab shrinker.
>> When memcg kmem is disabled, just such shrinkers can be called in
>> shrinking memcg slab.
> This causes a couple of compile errors with an allnoconfig build.
> Please fix that and test any other Kconfig combinations which might
> trip things up.

I just tested !CONFIG_TRANSPARENT_HUGEPAGE, but I didn't test 
!CONFIG_MEMCG. It looks we need keep the code for !CONFIG_MEMCG, will 
post the corrected patches soon.


