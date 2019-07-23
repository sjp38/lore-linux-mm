Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E37ADC76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:30:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A49562182B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:30:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A49562182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 457D58E0002; Tue, 23 Jul 2019 10:30:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 408C66B000D; Tue, 23 Jul 2019 10:30:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F6DB8E0002; Tue, 23 Jul 2019 10:30:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F64F6B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:30:14 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id r11so4148327uao.3
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 07:30:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=p6pI8ZVBikqtSstA53p+RN3PZUNckGvqGuKPrkWSdM8=;
        b=Z91m/qofPwUtvKNaQTXg1udfb1sOh+16zX1DA2mcyzSiVxfGftRDGqBOVJmXp6JgZK
         suUtP6Rdkey7YdNBzxmt1f5gVvWP9zI/HEJUtsWyiE54SRTuU1JIgWSFc0YLnOcmo87K
         gOMx2QAZJ+D4JWwCvVUMlSWkYVgaksuq8KGIOoOejU6b42X6xJuVNhRwCkMt0GXMfwD+
         obnkGlyP2IPHRTK1a9kLBkDRZazQK0d8Qctn3I1Lg+NcFWxtGvExEdt9wTbKdRJduMDR
         epBGRhmfVxZRt5tYH8ZnfkkRDUBIHSr9SKD9gFYBkNvmu4FuegUFQ/hhHAIPQ3da2s5/
         gd1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVwgBfYbMcVa6Sy1PumpOs2XwygtArwga30xC3lqPDazp0iwH7V
	dcycHE7wXknAgmHKi9bAXP/Z+apJtMGschDMdYDXHvZzVbW+Z+3i25GBOirz8bBhUeIzBW3FExu
	IoDvsaln17P6jdpPtWkUg7+MhGE1vbSgHfooCJNFSD7tfqxB6Pyu+mSmNl/MAKtWfSA==
X-Received: by 2002:a67:fd91:: with SMTP id k17mr47762937vsq.121.1563892213824;
        Tue, 23 Jul 2019 07:30:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxieFQXsRn5Vx3YHnXpCopXAH53HUE0IxHcHELb8P2YnvuuHMxpirqVKA7TaBsea8rSXmxf
X-Received: by 2002:a67:fd91:: with SMTP id k17mr47762887vsq.121.1563892213151;
        Tue, 23 Jul 2019 07:30:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563892213; cv=none;
        d=google.com; s=arc-20160816;
        b=aFw4Lpfg7HDECxfImN8E4Mws1Tu7xJf1ICO0ukwwL2xxWE49HkPEpdNvvtDWJpQzNs
         z2xDJDu8UUeUcApID+vOgSHOkuQe5ltiyYd1Rs6jz6rN2pee1pwnw3uJzcp7GK7HNOI9
         QV10nbwQ8wM5J2OmnkckNJbXq3WK/p4tNwP1UeufCO0W+rxNELIB2e6Xgb5pBH4gq4fT
         c9/W5trGkiKaIK9lGTbHgwXDs44x5W5uMRSfAsPAg3WvgrId9nkl2llDPbnbG9vY8hTC
         65xvM5duNi20NHOrsMIaebvqV6nWkCiLUTPVi/5bpw7s5JqCfHcNfw2qvXWIUYNU4Re7
         W6ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=p6pI8ZVBikqtSstA53p+RN3PZUNckGvqGuKPrkWSdM8=;
        b=US3uSYPHJWx//1GyzfMoDLJiKKgdcTSWeME/enUj+O+TuVvWPrzwXgevRVl/g+jb00
         AgwgtbVUHIR4dtwk44rT9Jzrgjk1W5lwLVR+IEUQ4Jy0u+BBnKu7fC43mMf806gQC2Op
         zBEWyK7Mm13E4mdqLDtt3Kg0Lr90Q21RqOJz6YuLlLMPFtRRw5ykpkdllI1JKJmliAtu
         LxSCwO9PZc7WlOXIAl/zdQP9+k4OPPU9aFf6CxYKps5VrzpZU+C5wh4dMIOpBcRiZwgV
         hj+beAzwd+dUJ25la2n5cHV96s72gfW9UCXXSqoIzC7FhXc1fTc2pKPt/QQgkCk7iZGV
         9Lnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x62si11204467vkg.89.2019.07.23.07.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 07:30:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3914781F18;
	Tue, 23 Jul 2019 14:30:11 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1EBAC600D1;
	Tue, 23 Jul 2019 14:30:08 +0000 (UTC)
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
To: peter enderborg <peter.enderborg@sony.com>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
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
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <f878a00c-5d84-534b-deac-5736534a61cd@redhat.com>
Date: Tue, 23 Jul 2019 10:30:07 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <71ab6307-9484-fdd3-fe6d-d261acf7c4a5@sony.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 23 Jul 2019 14:30:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/22/19 8:46 AM, peter enderborg wrote:
> On 7/2/19 8:37 PM, Waiman Long wrote:
>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
>> file to shrink the slab by flushing all the per-cpu slabs and free
>> slabs in partial lists. This applies only to the root caches, though.
>>
>> Extends this capability by shrinking all the child memcg caches and
>> the root cache when a value of '2' is written to the shrink sysfs file.
>>
>> On a 4-socket 112-core 224-thread x86-64 system after a parallel kernel
>> build, the the amount of memory occupied by slabs before shrinking
>> slabs were:
>>
>>  # grep task_struct /proc/slabinfo
>>  task_struct         7114   7296   7744    4    8 : tunables    0    0
>>  0 : slabdata   1824   1824      0
>>  # grep "^S[lRU]" /proc/meminfo
>>  Slab:            1310444 kB
>>  SReclaimable:     377604 kB
>>  SUnreclaim:       932840 kB
>>
>> After shrinking slabs:
>>
>>  # grep "^S[lRU]" /proc/meminfo
>>  Slab:             695652 kB
>>  SReclaimable:     322796 kB
>>  SUnreclaim:       372856 kB
>>  # grep task_struct /proc/slabinfo
>>  task_struct         2262   2572   7744    4    8 : tunables    0    0
>>  0 : slabdata    643    643      0
>
> What is the time between this measurement points? Should not the shrinked memory show up as reclaimable?

In this case, I echoed '2' to all the shrink sysfs files under
/sys/kernel/slab. The purpose of shrinking caches is to reclaim as much
unused memory slabs from all the caches, irrespective if they are
reclaimable or not. We do not reclaim any used objects. That is why we
see the numbers were reduced in both cases.

Cheers,
Longman

