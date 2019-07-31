Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A308BC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:15:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65701206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:15:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65701206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F32248E0003; Wed, 31 Jul 2019 10:15:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE2E58E0001; Wed, 31 Jul 2019 10:15:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD1508E0003; Wed, 31 Jul 2019 10:15:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9BCF8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:15:33 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c207so58068058qkb.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:15:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=M9Vk9zC8MZ3jn34/iSg0F5Cu3MhGkHBnusKieaHiGuc=;
        b=AONl2umtxXR22jYYC/FhCTk6CL0hQLHnL+296B+LUgi0Sccgogus8wdQmEYUx2uX0d
         3D9zZSAWFpyCVxJ1biY2CbIl4mHs6NBznDtKQbnPKi74V6XULMHj54nha5nUj5F3bEuJ
         KMQ4E4sZuvxQDwtI+Kb3m+wRlTjPS4iYAqhqXumZTDqqERrJl+QPdccpLmPdTnoaFZgl
         /ka/zFIa2xcm7UCPbPS0jSu86XINhQkCKn7Y1swoa5xOYYufgnuZa0KIIsSIdWGnSt5b
         KJAm/lB99HFrAkFdt3TLWSQzzBMFnTx5P+vTpLssLDidFW5NE/JFpYOI9XMCYhwWo9Ue
         lTOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVpRF6M8ye5v9dfVq+2KjtSXxpcgbK9siUbulY6YY54/8FtJ4vE
	mZIk4ZpJi2H/1SUu5jG8xErBJSPYhfiThaDJMuZgxap0fnPPQhQkKxm2KBZNh/Xxz4UJzFfHKnI
	dySn6kODEzCnYXX+dT5T0y39xGChGD1jSZ2fqgMvPn71eU2i594pDDHBG6iUMRZfD/Q==
X-Received: by 2002:ac8:19ac:: with SMTP id u41mr83998002qtj.46.1564582533527;
        Wed, 31 Jul 2019 07:15:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwe9BbDXObZbvCuPisZwHD4kQRBqiusDLER85kvRt7ieMw/pTbMY+qiy4VJkvEpA3Ekt/ik
X-Received: by 2002:ac8:19ac:: with SMTP id u41mr83997935qtj.46.1564582532817;
        Wed, 31 Jul 2019 07:15:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564582532; cv=none;
        d=google.com; s=arc-20160816;
        b=EhvTiEFVrhvDkA3Hzqi1Kz04RZ428IKiSj+JpNu47c5ObQMg3p7n+I3Ym5Q2KRXvPO
         1tO07/pxFNzbM3IiPQsivTj4FdJR9AEg4bMPrgsOgWv/H/Plvr16WKU/CGmyqonkr1Yo
         KI34H4YEvqNNHYf5utGW4lnIbJcUD/jITgvRJWdqNyXqxK5apmINMWeYCajp9HjcjoZZ
         MRuWQGxFiOQ6VDmqlv03vFrjXHGGpYF9f0QuCwlvRfvusJC2cTdm0lb39luZftaQHVvr
         HjH42z64Et2IsV9KZPt/7cKZc8/ZjxZRKLw17i42U1/4cMjrbOn5dFkJXd2Jy/t7ffS+
         MHIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=M9Vk9zC8MZ3jn34/iSg0F5Cu3MhGkHBnusKieaHiGuc=;
        b=kefjEM/vUCXHxLcnA+2qigpfN5RDt9Z/h6hRFzsoZ11Ldy+7Hfd76rcfxXds2pkCZo
         9KSn39vjjxs35Ad7vb24p/cM0+IDNX6rI9d10hnABXrclFd//8bWK5/jSwNdaLCz2y15
         7DQfjo4V7W9MfbMJ8uFOX3tF0tqxr1e0/gCPmI9amP7OaPGVqnqMNmrzd4P2rig9PobA
         JhGdxTHD6mdeY75xpj2EeYq44UiiN44G7c7/BgufnEiGR8jgk36BK0wJb2YAqF9EJmgZ
         1P9bjdwFb7eUocl8HFNz9YJL2g28zOoa2KaqWkXwOjrtIhKBqU7IjcYis7OSd7Y+oNlX
         X/bw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y9si39909544qth.62.2019.07.31.07.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:15:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 019922BF02;
	Wed, 31 Jul 2019 14:15:32 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BD30E5D9C5;
	Wed, 31 Jul 2019 14:15:17 +0000 (UTC)
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Rik van Riel <riel@surriel.com>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>,
 Michal Hocko <mhocko@kernel.org>
References: <20190729210728.21634-1-longman@redhat.com>
 <ec9effc07a94b28ecf364de40dee183bcfb146fc.camel@surriel.com>
 <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
 <8021be4426fdafdce83517194112f43009fb9f6d.camel@surriel.com>
 <b5a462b8-8ef6-6d2c-89aa-b5009c194000@redhat.com>
 <c91e6104acaef118ae09e4b4b0c70232c4583293.camel@surriel.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <01125822-c883-18ce-42e4-942a4f28c128@redhat.com>
Date: Wed, 31 Jul 2019 10:15:17 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <c91e6104acaef118ae09e4b4b0c70232c4583293.camel@surriel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 31 Jul 2019 14:15:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/31/19 9:48 AM, Rik van Riel wrote:
> On Tue, 2019-07-30 at 17:01 -0400, Waiman Long wrote:
>> On 7/29/19 8:26 PM, Rik van Riel wrote:
>>> On Mon, 2019-07-29 at 17:42 -0400, Waiman Long wrote:
>>>
>>>> What I have found is that a long running process on a mostly idle
>>>> system
>>>> with many CPUs is likely to cycle through a lot of the CPUs
>>>> during
>>>> its
>>>> lifetime and leave behind its mm in the active_mm of those
>>>> CPUs.  My
>>>> 2-socket test system have 96 logical CPUs. After running the test
>>>> program for a minute or so, it leaves behind its mm in about half
>>>> of
>>>> the
>>>> CPUs with a mm_count of 45 after exit. So the dying mm will stay
>>>> until
>>>> all those 45 CPUs get new user tasks to run.
>>> OK. On what kernel are you seeing this?
>>>
>>> On current upstream, the code in native_flush_tlb_others()
>>> will send a TLB flush to every CPU in mm_cpumask() if page
>>> table pages have been freed.
>>>
>>> That should cause the lazy TLB CPUs to switch to init_mm
>>> when the exit->zap_page_range path gets to the point where
>>> it frees page tables.
>>>
>> I was using the latest upstream 5.3-rc2 kernel. It may be the case
>> that
>> the mm has been switched, but the mm_count field of the active_mm of
>> the
>> kthread is not being decremented until a user task runs on a CPU.
> Is that something we could fix from the TLB flushing
> code?
>
> When switching to init_mm, drop the refcount on the
> lazy mm?
>
> That way that overhead is not added to the context
> switching code.

I have thought about that. That will require changing the active_mm of
the current task to point to init_mm, for example. Since TLB flush is
done in interrupt context, proper coordination between interrupt and
process context will require some atomic instruction which will defect
the purpose.

Cheers,
Longman

