Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A36CC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 16:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35732222FC
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 16:33:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35732222FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8022B6B0007; Wed,  7 Aug 2019 12:33:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B0A66B000C; Wed,  7 Aug 2019 12:33:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 677826B000D; Wed,  7 Aug 2019 12:33:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 146726B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 12:33:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so56412188edd.22
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 09:33:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=HPTyuxZECDYpmL7fNV0I27d9sRoi6aXt4bKBtbLftII=;
        b=UXzPrIF6aPsygK878PNRM6g9A5Kg3oN+Jlf+7cijXBID38cDnnFo940fn3l1cuK5xe
         F1Y5i0MDRKFSjBu3HGBvL14RmtXDr46CmFZktd/XfZtqQCb4UI0Fq4GhoMM5P7b6NNmf
         fXWFnu/4rwYAs7njMxJ02MP9QxeJOS4ZshKQvfL00n6tQazaYgRBJvrk54RmEki4Q2D+
         4HT9cw5oZ0zJxtHbBFVfPi2O/3LDKswYmp/eC6NcokGqHYoAP7erQ4+uZhg1cWa65jtZ
         QvqlPGl6lkHA4i/MJKogeJFPoThsGciVlninEjgrXMjOnBDO7cpnqBUKjNKXFrW+Ls+q
         Dd3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXiJb0PB3nVUdFr8o1oBYVarZHFV5w3SSS4F843HImqEbPS/R9r
	TaFSVHedV/J9b6se0jNyI0+A8qZjkUyn2t5N8+LbSNnCzt7Ih7F5tppl4Wu7WjJxOZn0odtvdnc
	RqlGHnX96UXWxMINK8+QPfBtIGe66xVb4s0Kx8eT2Swo0MXKQ+Wj647s+gub+cT8gzg==
X-Received: by 2002:a50:9999:: with SMTP id m25mr10852675edb.183.1565195620612;
        Wed, 07 Aug 2019 09:33:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4vqGITTAf8RLu7PJBFc6DHit1f0eELAOiPEFaukm7NEcbcgF3lNyE9VYOFTxHTh40ZEus
X-Received: by 2002:a50:9999:: with SMTP id m25mr10852589edb.183.1565195619746;
        Wed, 07 Aug 2019 09:33:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565195619; cv=none;
        d=google.com; s=arc-20160816;
        b=nmRpNeM/qUJFtbTTUA7IQSf5tCD+SWtBy2VcuRA3m1wpZMBRO8fSI/tCvO+KtO5gsh
         YN9fikkhhE6p8jw8zfbqZSx6wuAGPIwZlxompCXLVyu+4YzQ2VBnfoqFldp6bFbumwXl
         jRbQU1uSDOwKf/skWcytH6zslmvSSo+GXrFI7qLXhYN/vJ3sHqW+30y3wj7TOoir2dj0
         F1R8KtH/2AbqTfMhXs7zBW36C38fo8kBQtZ8NHdDPWW+GGEggzasZ+9IlnKITeP4ZUPB
         6HO2OdWaz7iE0EKKRgMO06cVjpo92Rot0586lR048PtZSesVweKLVwJ3tk2V3bnziKSJ
         NcUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=HPTyuxZECDYpmL7fNV0I27d9sRoi6aXt4bKBtbLftII=;
        b=rO1MO4n2TjZywz7UIaeHMivdHz8FqdYxJ4GFwiihSgK4EYtXG6XcsvDjv+P4YXWSzy
         xIsX3BB9FJ9DYrZ6UEzBC3HwFvNu3qxV2gBS363v74xOe5D5dukAHHbitIIJnfpDyblT
         UkMDLIqm5i4SXhMfhxVTAGZusMp+EEQ8+rx6WLXdZtvxt8aYiBXRy8OJzQW0OBP4Rv1z
         alzjL/7nVlQgnygtSHM5S+x21e4chAhUEbQkiAYQqIQocyfeQfID6I3rzKkTv7O+HlH/
         2Y6TvXh9HApoKuVXKP1uRu76krTQLrHg3hsIrfcrKDKY3BTqOOSVjmQ2e1ji1O4iIEoQ
         RDMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si32766772edd.67.2019.08.07.09.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 09:33:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F06F7AF93;
	Wed,  7 Aug 2019 16:33:38 +0000 (UTC)
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
To: Waiman Long <longman@redhat.com>,
 peter enderborg <peter.enderborg@sony.com>, Christoph Lameter
 <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
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
 <71ab6307-9484-fdd3-fe6d-d261acf7c4a5@sony.com>
 <f878a00c-5d84-534b-deac-5736534a61cd@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <85f9074a-064c-acbc-2a22-968026f0a8c3@suse.cz>
Date: Wed, 7 Aug 2019 18:33:36 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <f878a00c-5d84-534b-deac-5736534a61cd@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/19 4:30 PM, Waiman Long wrote:
> On 7/22/19 8:46 AM, peter enderborg wrote:
>> On 7/2/19 8:37 PM, Waiman Long wrote:
>>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
>>> file to shrink the slab by flushing all the per-cpu slabs and free
>>> slabs in partial lists. This applies only to the root caches, though.
>>>
>>> Extends this capability by shrinking all the child memcg caches and
>>> the root cache when a value of '2' is written to the shrink sysfs file.
>>>
>>> On a 4-socket 112-core 224-thread x86-64 system after a parallel kernel
>>> build, the the amount of memory occupied by slabs before shrinking
>>> slabs were:
>>>
>>>  # grep task_struct /proc/slabinfo
>>>  task_struct         7114   7296   7744    4    8 : tunables    0    0
>>>  0 : slabdata   1824   1824      0
>>>  # grep "^S[lRU]" /proc/meminfo
>>>  Slab:            1310444 kB
>>>  SReclaimable:     377604 kB
>>>  SUnreclaim:       932840 kB
>>>
>>> After shrinking slabs:
>>>
>>>  # grep "^S[lRU]" /proc/meminfo
>>>  Slab:             695652 kB
>>>  SReclaimable:     322796 kB
>>>  SUnreclaim:       372856 kB
>>>  # grep task_struct /proc/slabinfo
>>>  task_struct         2262   2572   7744    4    8 : tunables    0    0
>>>  0 : slabdata    643    643      0
>>
>> What is the time between this measurement points? Should not the shrinked memory show up as reclaimable?
> 
> In this case, I echoed '2' to all the shrink sysfs files under
> /sys/kernel/slab. The purpose of shrinking caches is to reclaim as much
> unused memory slabs from all the caches, irrespective if they are
> reclaimable or not.

Well, SReclaimable counts pages allocated by kmem caches with
SLAB_RECLAIM_ACCOUNT flags, which should match those that have a shrinker
associated and can thus actually reclaim objects. That shrinking slabs affected
SReclaimable just a bit while reducing SUnreclaim by more than 50% looks
certainly odd.
For example the task_struct cache is not a reclaimable one, yet shows massive
reduction. Could be that the reclaimable objects were pinning non-reclaimable
ones, so the shrinking had secondary effects in non-reclaimable caches.

> We do not reclaim any used objects. That is why we
> see the numbers were reduced in both cases.
> 
> Cheers,
> Longman
> 

