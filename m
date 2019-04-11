Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16D40C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:22:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7460217F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:22:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7460217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58C056B000D; Thu, 11 Apr 2019 10:22:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53DFC6B000E; Thu, 11 Apr 2019 10:22:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42D4B6B0010; Thu, 11 Apr 2019 10:22:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2146B000D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:22:36 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id p26so5643971qtq.21
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:22:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=HIxVLZjqp4MH33lnupVZYwTAxNsDbfL0VH8DqWCvrfI=;
        b=LTtR4UpKWyThdE4d3pEE/w3JJNOv8Gjsy7Z1bZ5frIlR0GtwSpu0zR2bg4aO02/YbB
         zs2UHYJX3fgX9GZ7Joy8C3I/92HoeP9J/QO+nL+6QH0veRrpyqhTw7BWGHpmVAt/TYKx
         OvtNsxWNjBIjGqVqeQ0QmEWYI8O4B4NUVMf7TI1TuzIRMKeDllCoEzmxd32mOT6Xbp94
         BVZ7rJk8RdnnsWPfc/NiXZnWuJlZRG+pg1xj3KVUdpsSepGMgL8lTW2oh1xiWW4YwlCF
         qrZn/Ewb6ypJ+d7GcPpLuaJsPLZ0TKjy+Jo70PLHYRrhQuxDpYidOwlJLaEiJwAn60vU
         43xQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUZ/gMosyGP66QkI7vHt61Z6A1e6U+xRQqTCdX7RwQKKvli2W5e
	pANy7G/+pU40WPfjDhKptZNN2SpOMDoiYmoVqYZQBU8qgarbGTcLKAjEBOyOOGqaZs8vyo+68t6
	5veBvJHdaneh8NmX4/vkbdJLkkwNQqPFCg284AHViJ3QacL+eyZfuLvTAzZU0ucgJsQ==
X-Received: by 2002:a05:620a:15f5:: with SMTP id p21mr6643540qkm.5.1554992555633;
        Thu, 11 Apr 2019 07:22:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywkuycXfsUEetSjv++vct5/3wygZz9ymtXFqZ8biiVOrWnLRgbUJ50FFZC7XiIVhTZCUUD
X-Received: by 2002:a05:620a:15f5:: with SMTP id p21mr6643450qkm.5.1554992554543;
        Thu, 11 Apr 2019 07:22:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554992554; cv=none;
        d=google.com; s=arc-20160816;
        b=dsLi2cVw+GZ5foSpD9BxCQg9OBoptxSvZZR/fKiA1o5cxDORMujPfeM9Dz6TEedw05
         HAKUB2qL7T2DXriFuSsZa1nP6S5QfBpas+NcuRXOEVn8j/LsiFiMQ6tEJtI1WQwJExb2
         xfu12smej+iUV9jFTIoO6jf4saNDdqq7/qrFZdlfwgvwGP7HPP0khiSWKAO0TYDElaea
         4EmEUX88OYoOsaFlQcQeDO8wgO2JKo9KkAi93drMGSCisobxPUPimVOyBp7hvJ0BcmCS
         F4LLFBTScnNL6gjKoDxrjLoIOiG7JQ0A3ZgdwMGA10V1JmjQCK4pE+DhCuqu3RIuN6/0
         h4Jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=HIxVLZjqp4MH33lnupVZYwTAxNsDbfL0VH8DqWCvrfI=;
        b=DYCVTxKXlXvqRPHxF7iFwAH24fyPBeg5fsj2RS+EKNruGds2PYEHUqXapW/J8ttNVa
         aRW2/A4ivFmFhg7fXc3ZGY3oQFbIVbz8zm0Yi6gU0UpYO06kFab9OAUMRNkeHcH4fMVD
         U99NnO4RmvTaBqSMUIqgIxU2JtN2CzCQw0M4DF91Og3Eg1e8/m6NPgq56nv+gV9S6Spv
         aQQEfoQQBgTj4iz8cqGazA6WaQjdbQU/3EbUQPp2UMaDLK9wcJTolMdYCypUlFmoROli
         llwgelZTVtjdI6iyW8ZVUpG6LcwACUMYOriUmNWcg4lgpWJGwyU9bSrulozkPhByfePR
         hUYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r43si5214206qte.172.2019.04.11.07.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 07:22:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5010FC7910;
	Thu, 11 Apr 2019 14:22:28 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-47.bos.redhat.com [10.18.17.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 52F6E61B60;
	Thu, 11 Apr 2019 14:22:23 +0000 (UTC)
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
To: Chris Down <chris@chrisdown.name>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Jonathan Corbet <corbet@lwn.net>,
 Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>,
 linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
 Shakeel Butt <shakeelb@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>
References: <20190410191321.9527-1-longman@redhat.com>
 <20190410213824.GA13638@chrisdown.name>
From: Waiman Long <longman@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=longman@redhat.com; prefer-encrypt=mutual; keydata=
 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
 weim8xU=
Organization: Red Hat
Message-ID: <d8d6f82f-a950-8eea-16ce-9189e78f37fd@redhat.com>
Date: Thu, 11 Apr 2019 10:22:22 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190410213824.GA13638@chrisdown.name>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 11 Apr 2019 14:22:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/10/2019 05:38 PM, Chris Down wrote:
> Hi Waiman,
>
> Waiman Long writes:
>> The current control mechanism for memory cgroup v2 lumps all the memor=
y
>> together irrespective of the type of memory objects. However, there
>> are cases where users may have more concern about one type of memory
>> usage than the others.
>
> I have concerns about this implementation, and the overall idea in
> general. We had per-class memory limiting in the cgroup v1 API, and it
> ended up really poorly, and resulted in a situation where it's really
> hard to compose a usable system out of it any more.
>
> A major part of the restructure in cgroup v2 has been to simplify
> things so that it's more easy to understand for service owners and
> sysadmins. This was intentional, because otherwise the system overall
> is hard to make into something that does what users *really* want, and
> users end up with a lot of confusion, misconfiguration, and generally
> an inability to produce a coherent system, because we've made things
> too hard to piece together.
>
> In general, for purposes of resource control, I'm not convinced that
> it makes sense to limit only one kind of memory based on prior
> experience with v1. Can you give a production use case where this
> would be a clear benefit, traded off against the increase in
> complexity to the API?
>

As I said in my previous email on this thread, the customer considered
pages cache as common goods not fully representing the "real" memory
footprint used by an application.=C2=A0 Depending on actual mix of
applications running on a system, there are certainly cases where their
view is correct. In fact, what the customer is asking for is not even
provided by the v1 API even with that many classes of memory that you
can choose from.

>> For simplicity, the limit is not hierarchical and applies to only task=
s
>> in the local memory cgroup.
>
> We've made an explicit effort to make all things hierarchical -- this
> confuses things further. Even if we did have something like this, it
> would have to respect the hierarchy, we really don't want to return to
> the use_hierarchy days where users, sysadmins, and even ourselves are
> confused by the resource control semantics that are supposed to be
> achieved.

I see your point. I am now suggesting that this new feature is limited
to just leaf memory cgroup for now. We can extend it to full
hierarchical support in the future if necessary.

>
>> We have customer request to limit memory consumption on anonymous memo=
ry
>> only as they said the feature was available in other OSes like Solaris=
=2E
>
> What's the production use case where this is demonstrably providing
> clear benefits in terms of resource control? How can it compose as
> part of an easy to understand, resource controlling system? I'd like
> to see a lot more information on why this is needed, and the usability
> and technical tradeoffs considered.=20

Simply put, the customers want to control and limit memory consumption
based on the anonymous memory (RSS) that are used by the applications.
This was what they were doing in the past and their tooling was based on
this. They want to continue doing that after migrating to Linux. Adding
page cache into the mix and they don't know how they should handle that.

Cheers,
Longman

