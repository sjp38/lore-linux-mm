Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C45F9C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:05:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A62C208E3
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:05:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A62C208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D5CA8E0003; Tue, 30 Jul 2019 17:05:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25FEC8E0001; Tue, 30 Jul 2019 17:05:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 175558E0003; Tue, 30 Jul 2019 17:05:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2F718E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 17:05:52 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id c21so6868121uao.21
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:05:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=8OVdJtKbIuHNeaAmHrYp4QUgLmn/UwVV+QQLtxKMZh4=;
        b=ZXTQGQbBK+icB3EjYOaeDyWSyTa91nkF2JL/LxCWPL3gF6KxOwgIkKFvf0kYex/nby
         qLUPahxIhdOO+N0p3UXMtDtqr1Cvmp/BX6cXeY+nVFSHcC+3z4pSKPeNJRYfVXGKwLpT
         3jO0eOuzRKSCLsI7Wj8ZDs5piMC+sJcrfJkDFk25j5ikx3e1DPNc/ldzayn05jCqjYBF
         TW/3fc0ScyTNIWI2UQxKJtXzHkZvnE574f/PJrRmUirS8JDJaR+eKWnjNiumfbA5fuJ4
         5K8Jdy3k5CwiHABSUi9RJXaVPv4C9uivuDS16A3rwDhItGMS/5uZ8Rtorb/UZOtltv1j
         xSdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXOCKRZNDRQ5x+f4JT1M21b7cQsyHDvY1BxDbv9MpgtdyzGiqJa
	nyzCFZGV1BFjQZhG144WmXsO4i0vK09U6ZzUotB8CJhTcT9srMbswu4tIx28dTo3hxtSUjpymvE
	jcEvp2AFhe6GZWHiQ/zxJ8AsD0IgCyxQCrwmIQCdUbGR8efWoz+X1+pxq6BK5XUdanA==
X-Received: by 2002:a67:bb01:: with SMTP id m1mr72647048vsn.88.1564520752680;
        Tue, 30 Jul 2019 14:05:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbR9o+3NxqPC+eijEEk/jaVkx/EyP5NdCjDNLnKEEhtalN0+6BmpCiFLL/UC1HHURP9mxA
X-Received: by 2002:a67:bb01:: with SMTP id m1mr72647007vsn.88.1564520752177;
        Tue, 30 Jul 2019 14:05:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564520752; cv=none;
        d=google.com; s=arc-20160816;
        b=qe4qnskqMqiK3E0ycCVeQ0snn8ANiObSg3jAdZOpgXxNfTzFu+1g8tyGdBaw/N4UWB
         rXgw0wRGeBPAYQkuP9H7mCa54qf1c90JDMiWqzjagw6Ge14ljkKNzI9gxtYGr/iLYnff
         iGnAR3q/G/G7iv6HqrIDUO3RtRhK2/rHHLprltOBVPxxcjqEREQyOnLwzsvxU0U2mnr5
         7dZcmNOl5BfZ8R/rjtF0C2pKe7cXDyWcNVTISVHUebu5EDNAhgDNxXMo6iZQh31iBkHc
         fXreF1j0M2tQlgKs4bKhMJNfLdcIuVwTWgNW/f3ykHIMfAInZFEULMSrd+ci1Ulwfgdu
         3+7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=8OVdJtKbIuHNeaAmHrYp4QUgLmn/UwVV+QQLtxKMZh4=;
        b=JCN621qDQRZITeyE2VH06QAjKLeuIOBMB/98YKGFZBYb46qjPp1Px2jrGtMzvtjwkh
         RIS6IQaE6efyldS08P4BZT11jFaBn8+/URaKn/Arqez7KzO2C4uedHwSXr6D1C+KjCZc
         1jWGUpDthShbKF9VSZg2RqOjI4K9ygvm+zSr7sEMfw+DirsuZtxpnvgnUMCUQwWkznRW
         +o7HHQx3ds4rxFCNHs3Vn2POEhM9nzENYEE//Cqfs6iJEpryAcIenn12vrSgRs5wzsV7
         qv9MlJnIf41EFFuCFR2nAHTzxEd6APeUSnVmZTLfhKE8oBcv11lt0bX5Oe/YlQUYeKRS
         B50A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a1si15317701vsj.381.2019.07.30.14.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 14:05:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4E9BF308AA11;
	Tue, 30 Jul 2019 21:05:51 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7AA7E60BEC;
	Tue, 30 Jul 2019 21:05:49 +0000 (UTC)
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Michal Hocko <mhocko@kernel.org>
Cc: Rik van Riel <riel@surriel.com>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Phil Auld <pauld@redhat.com>
References: <20190729210728.21634-1-longman@redhat.com>
 <ec9effc07a94b28ecf364de40dee183bcfb146fc.camel@surriel.com>
 <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
 <20190730072439.GL9330@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <31cea85f-8d8e-a701-db75-fe1ec67d6c29@redhat.com>
Date: Tue, 30 Jul 2019 17:05:48 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190730072439.GL9330@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 30 Jul 2019 21:05:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/30/19 3:24 AM, Michal Hocko wrote:
> On Mon 29-07-19 17:42:20, Waiman Long wrote:
>> On 7/29/19 5:21 PM, Rik van Riel wrote:
>>> On Mon, 2019-07-29 at 17:07 -0400, Waiman Long wrote:
>>>> It was found that a dying mm_struct where the owning task has exited
>>>> can stay on as active_mm of kernel threads as long as no other user
>>>> tasks run on those CPUs that use it as active_mm. This prolongs the
>>>> life time of dying mm holding up some resources that cannot be freed
>>>> on a mostly idle system.
>>> On what kernels does this happen?
>>>
>>> Don't we explicitly flush all lazy TLB CPUs at exit
>>> time, when we are about to free page tables?
>> There are still a couple of calls that will be done until mm_count
>> reaches 0:
>>
>> - mm_free_pgd(mm);
>> - destroy_context(mm);
>> - mmu_notifier_mm_destroy(mm);
>> - check_mm(mm);
>> - put_user_ns(mm->user_ns);
>>
>> These are not big items, but holding it off for a long time is still not
>> a good thing.
> It would be helpful to give a ball park estimation of how much that
> actually is. If we are talking about few pages worth of pages per idle
> cpu in the worst case then I am not sure we want to find an elaborate
> way around that. We are quite likely having more in per-cpu caches in
> different subsystems already. It is also quite likely that large
> machines with many CPUs will have a lot of memory as well.

I think they are relatively small. So I am not going to pursue it
further at this point.

Cheers,
Longman

