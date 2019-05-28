Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CDA1C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:41:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F69E21734
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:41:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F69E21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 003946B0284; Tue, 28 May 2019 13:41:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF7FA6B0288; Tue, 28 May 2019 13:41:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0DC16B0289; Tue, 28 May 2019 13:41:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id B62786B0284
	for <linux-mm@kvack.org>; Tue, 28 May 2019 13:41:42 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id z1so10625914oth.8
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:41:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=6CbXQYZqerkXoGquBlnSw/Irwo3z1mFraxnU6Bh/fac=;
        b=ntE5dh7ey4bZdl2SvoZFM/9zgpmmwifkI9nsK6LwX68v4oSb60RjiWZG91iI3GGh+e
         se37WB4obv9+xfUJCAmbnrygf/eLHbk6S49J+sYjPaonNjaC7E3nDX4aGEBs/dJnspau
         l29Kyx/jEMmp32ebthjSuPcV+mXG+rmOuYTtwRzVKih5kQOQ+iPFKB36Hotiy+0WhKZk
         JyopMQ7XYZr5tfR/b90IVQcvOmjvDxsYf3cukQAQPwxOqq5O9zOotGMY96oR39QJ4jAx
         A6IpLGF7C3xAU7JC03FF92YHd6FgGCJUrtsJiOg+HyBEa/75r0mgKQOVEryLB+706HYf
         xRJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXjKUxA5c7PgdqHbcZT9a9xa4dFm6LRzhaBQ56nr6Jq2CM0R3Lx
	cmU1THGZv7ddTZglA1oWZJgE9BxC9UdL6Y/eLJdLBL1T70KdcY/1uk4HmL7QLu/Nn6erzj97MUe
	DWebp2/sK2EiJNaxyXYmkGDbJPQt2z1WEl5GxswfA4v9mp/NOF1moI8d6Bvt7UC5P5w==
X-Received: by 2002:a9d:1b67:: with SMTP id l94mr78086458otl.239.1559065302448;
        Tue, 28 May 2019 10:41:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgzWnTC+CNZVwg/5fvRaN0KrUik+jX+C4YdSqUoM6fhH9G6ZAH9NSU5zVv0GXvCU40ahZH
X-Received: by 2002:a9d:1b67:: with SMTP id l94mr78086406otl.239.1559065301309;
        Tue, 28 May 2019 10:41:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559065301; cv=none;
        d=google.com; s=arc-20160816;
        b=z9rBEDwHv2dtPOi770QYssfDcxxqbxBrwf5c7JffMwUjqoCeVUI2SS+qJh39sEWG5i
         HL9nE5JC+NUDLpP01RH2GzpmCkMtX6pNh1SeQK2pZELR6agtLnNVCIjBN+pA3vBJV+/5
         RYJh9sWyaYSyo2j3c+Hb2Y/kaYZrMHVBhiNrv3BQ9q+dPNArngNKBGF3Qvt4TEL0iH/M
         cRgsD8vfHlS1IK40Oh6ScfXdjVm/+kD4KeNtDapqBdDcolK4Mso1WnnKzvElbESLgN0q
         wp5PgSeKaOnVGRKVpQZjsuvwTSn1Mc2KxIJNU2iJIM4BK+RjREUSxpkpjIKozeFvyskf
         RvvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=6CbXQYZqerkXoGquBlnSw/Irwo3z1mFraxnU6Bh/fac=;
        b=Z6RfP8eSAl2iZMqAvV2r3v+PFJUoa4kDIMHUg6yj+sVOTm2hNfeS4Zq8lgSzIYiO1m
         qZdr0ee0RAMiCyD/E9uiqbYvZ7Zul7vPGZFFI5dvmvXwWjD5q1Ls30B3XyB+f+KyPp/R
         JJ1tZa1EIcwYJhVBMQZ2za8PWHdNFt7JASnUUqh1ID11T7LCUAliPLZg8ZkP05WkTore
         d1xZsCYfZfnToxrfq6Q0s33nK80YQpkgbPCk18p+Vn3f38f3gip+EH+hulARhVoFo8Q3
         rQ5CzFE4sZLKK6r5oAOe08bTMDYHz64EQlAevpn23pe2wyzkN0INwCpyyoMlJFxddOWb
         u3Ew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n204si4021542oif.141.2019.05.28.10.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 10:41:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6F89730833AF;
	Tue, 28 May 2019 17:41:38 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 45C4B1019607;
	Tue, 28 May 2019 17:41:35 +0000 (UTC)
Subject: Re: [PATCH v5 5/7] mm: rework non-root kmem_cache lifecycle
 management
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Rik van Riel <riel@surriel.com>, Shakeel Butt <shakeelb@google.com>,
 Christoph Lameter <cl@linux.com>, cgroups@vger.kernel.org
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-6-guro@fb.com>
 <20190528170828.zrkvcdsj3d3jzzzo@esperanza>
 <96b8a923-49e4-f13e-b1e3-3df4598d849e@redhat.com>
 <20190528173959.h4hq55b3ajlfpjrk@esperanza>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <518419c5-ee74-d9a1-c01c-f1a3306d2d34@redhat.com>
Date: Tue, 28 May 2019 13:41:34 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190528173959.h4hq55b3ajlfpjrk@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 28 May 2019 17:41:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/28/19 1:39 PM, Vladimir Davydov wrote:
> On Tue, May 28, 2019 at 01:37:50PM -0400, Waiman Long wrote:
>> On 5/28/19 1:08 PM, Vladimir Davydov wrote:
>>>>  static void flush_memcg_workqueue(struct kmem_cache *s)
>>>>  {
>>>> +	/*
>>>> +	 * memcg_params.dying is synchronized using slab_mutex AND
>>>> +	 * memcg_kmem_wq_lock spinlock, because it's not always
>>>> +	 * possible to grab slab_mutex.
>>>> +	 */
>>>>  	mutex_lock(&slab_mutex);
>>>> +	spin_lock(&memcg_kmem_wq_lock);
>>>>  	s->memcg_params.dying = true;
>>>> +	spin_unlock(&memcg_kmem_wq_lock);
>>> I would completely switch from the mutex to the new spin lock -
>>> acquiring them both looks weird.
>>>
>>>>  	mutex_unlock(&slab_mutex);
>>>>  
>>>>  	/*
>> There are places where the slab_mutex is held and sleeping functions
>> like kvzalloc() are called. I understand that taking both mutex and
>> spinlocks look ugly, but converting all the slab_mutex critical sections
>> to spinlock critical sections will be a major undertaking by itself. So
>> I would suggest leaving that for now.
> I didn't mean that. I meant taking spin_lock wherever we need to access
> the 'dying' flag, even if slab_mutex is held. So that we don't need to
> take mutex_lock in flush_memcg_workqueue, where it's used solely for
> 'dying' synchronization.

OK, that makes sense. Thanks for the clarification.

Cheers,
Longman

