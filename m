Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BF33C06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 15:21:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DF302189E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 15:21:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DF302189E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 254E08E0005; Wed,  3 Jul 2019 11:21:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DF418E0001; Wed,  3 Jul 2019 11:21:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A60C8E0005; Wed,  3 Jul 2019 11:21:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D8C898E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 11:21:53 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x7so3048923qtp.15
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 08:21:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=gfi9ls2vrJsczVBL7e3y/AxswentGICv5J1Nm83sfgE=;
        b=EudQJd/duVbyhAZ/g3jdTuRP5Q4Q13B3zB4Ial/YJ6PuDLuNylX8EELjwbNXqkn6JG
         qLQoT4aTYO72CYdArISHUyz6s4SoP4OiP1Utw6SGna6RKh6L3S16cwG8pWS/8jXyeik2
         T+Ct1qLD4+aaZJ2crNVaK1RdZmv0fxNFtk+XLmuive75hTQSe4MJqww/qFeMHaTp1IU/
         3aWYGYNyA3UJKPdQ3bzZdzoeaEosibhzDWm0UC5INdh0FgjXUptXr0iTTqBahfdIuk3W
         CuDTstHeoU8Hb8roAbwXRJEUSAQk7NBkTwZ0BdAW1SYUd1/j7Ym0O6FZhEg642pLYYck
         xP/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXPYLF3nzU72wHmrejginD5HsRQgmwwFisAWHKqLpo44wcRo5+A
	NBalX0DLyzlWYPapH043y1vw389hWMH//kE3jwQHouG/hEPZ3gxtrAD7fvaOEyW1gCoVmoyBcje
	xuaKw0eOlVv3iU/4UvoziRIhfSZXunu/oNiFyEz6HDuS3/FKr8w5mSYhlUgIiGGHESw==
X-Received: by 2002:a37:4b56:: with SMTP id y83mr30672072qka.338.1562167313613;
        Wed, 03 Jul 2019 08:21:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoUqhzW5YPJRUFVRoMDmnZeaSBIDmoKLSUeapEyEo/WbuQGvqJthfdeJRomPBPYZlRuWne
X-Received: by 2002:a37:4b56:: with SMTP id y83mr30672041qka.338.1562167313166;
        Wed, 03 Jul 2019 08:21:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562167313; cv=none;
        d=google.com; s=arc-20160816;
        b=j5XrBf5BsRWfBtF0tU1YR4dFXL0Aq9WfEs9nusUziObDX3KPvl6qJ52sVf5KAFZkDU
         XbFU0d4bF1RkBGQKvyK8ZotS/qDbTVV3XTaPvlLD0vom2sM6VT79EeE46ALC60fJ/74T
         gFMlgM5ieo+9KmQATlDShrjVDDhEbDkjaUjj9bQMndV7guK4GbjXYdXHbb4WES5QP0le
         4S3GTpLK9M2ntfCRj8EjHcacSk6rNVuadchePf2d8la9VYZXoblXurXiNC8z8ktqNlB4
         2D1uStYoGI2+xNECXzFzoVRKPMrAKaSWKfnq7nmcb1dHFguu1b9vUWIEL9QtlG6gVZvH
         awQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=gfi9ls2vrJsczVBL7e3y/AxswentGICv5J1Nm83sfgE=;
        b=daruu58mqVKxvc7qrpa9mirZBaH93OCSrauqb8ZuEwcADc2iwLQ+0NhsbHRX4t5fjk
         zYxOSsNinfk9VQZw58Uyz6x9J6Q6phdynQL0QBcKVGs1uB3Hkr0GBu4tlm2uz9m6c9x2
         iOKAihiqeZf2pVhVuG+UQWJrgENvWAAj/3SAui6Ppoa3nafaS4o1SAcj5ksB1tylMdG3
         HX/4vj/GpDCQTQyt0BLuHgXiMDiIXAI95AVGDxBpBLzWGGFiKaJ0Pa2uRDxSCujkuEvZ
         GK3ivyD9DvuiubiNPAuIt02ubDsZ1g9Nba5OQgVRvJGcpMGic/BAzGuXffNZG+xZotx2
         Dypw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t40si2128617qtb.73.2019.07.03.08.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 08:21:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8DBD8A9DAC;
	Wed,  3 Jul 2019 15:21:47 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A01B6891C0;
	Wed,  3 Jul 2019 15:21:16 +0000 (UTC)
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
 linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>
References: <20190702183730.14461-1-longman@redhat.com>
 <20190702130318.39d187dc27dbdd9267788165@linux-foundation.org>
 <78879b79-1b8f-cdfd-d4fa-610afe5e5d48@redhat.com>
 <20190702143340.715f771192721f60de1699d7@linux-foundation.org>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <c29ff725-95ba-db4d-944f-d33f5f766cd3@redhat.com>
Date: Wed, 3 Jul 2019 11:21:16 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190702143340.715f771192721f60de1699d7@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 03 Jul 2019 15:21:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/2/19 5:33 PM, Andrew Morton wrote:
> On Tue, 2 Jul 2019 16:44:24 -0400 Waiman Long <longman@redhat.com> wrote:
>
>> On 7/2/19 4:03 PM, Andrew Morton wrote:
>>> On Tue,  2 Jul 2019 14:37:30 -0400 Waiman Long <longman@redhat.com> wrote:
>>>
>>>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
>>>> file to shrink the slab by flushing all the per-cpu slabs and free
>>>> slabs in partial lists. This applies only to the root caches, though.
>>>>
>>>> Extends this capability by shrinking all the child memcg caches and
>>>> the root cache when a value of '2' is written to the shrink sysfs file.
>>> Why?
>>>
>>> Please fully describe the value of the proposed feature to or users. 
>>> Always.
>> Sure. Essentially, the sysfs shrink interface is not complete. It allows
>> the root cache to be shrunk, but not any of the memcg caches. 
> But that doesn't describe anything of value.  Who wants to use this,
> and why?  How will it be used?  What are the use-cases?
>
For me, the primary motivation of posting this patch is to have a way to
make the number of active objects reported in /proc/slabinfo more
accurately reflect the number of objects that are actually being used by
the kernel. When measuring changes in slab objects consumption between
successive run of a certain workload, I can more easily see the amount
of increase. Without that, the data will have much more noise and it
will be harder to see a pattern.

Cheers,
Longman

