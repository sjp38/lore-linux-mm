Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D38DC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 15:14:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8CB52189E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 15:14:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8CB52189E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B6E48E0003; Wed,  3 Jul 2019 11:14:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 567A68E0001; Wed,  3 Jul 2019 11:14:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 456538E0003; Wed,  3 Jul 2019 11:14:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21FFF8E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 11:14:51 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z16so3021108qto.10
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 08:14:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=mw6p6jaR3RBoj1LRzqhPVPfN0Hhu76CvRXMv/H6rWzI=;
        b=GfOCiZdfD9xXll6RJr8XJ2zJMy//JPrrO1pYshSiZmDXgzB8ksbkb4tdyyJ3UfyhLV
         ndfD10BCcwHDv5uBERDN+MY6rMzz9DztgJ78tyGE0/aAYauivcPGIGDw2trh5gCEMYnV
         crjZ5EQ1irZAoO7UFDIcQYn+QH4D19qzFVq2z+C6x6y3irYymGRetREjcuxi5qDE/Y4O
         /7FGHDmXVIK353fhWF/k1ml5GoY109cfNerwhbbI/Alkr7TBZaYoGs1senT+T0LDXO5i
         1Tz1qPtGLjTrHZndM5o2F+LsfO+MIV440xH6XVlUKPObQuA0h1N9knFHgpfKYxfp8qN3
         Rqmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXeJnAHi40rSW/lhkEYob3Yk2rfKDDlAhunp9NJoIfrxZJE7lAG
	z7OsCjx9ojHI8veNrkN5qQeS9HXufUzPdJagTrXFCJCHzc6zz0jF+YimfSDYRcd6HJ7Ne+58RcG
	Tg5ygrtDtexVoQbQSasim6mXUTVwkjOPiAV5L2ow5TKMp2nPVi9k1iCmzU6JIaaDqxQ==
X-Received: by 2002:ac8:929:: with SMTP id t38mr31319661qth.287.1562166890882;
        Wed, 03 Jul 2019 08:14:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvwet7hukpSuOHgPrf2UgCKI2wv5xNx4fyghBuBFGbNdmoQxPlY819EHQv1E0K5IQyFRHg
X-Received: by 2002:ac8:929:: with SMTP id t38mr31319529qth.287.1562166889131;
        Wed, 03 Jul 2019 08:14:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562166889; cv=none;
        d=google.com; s=arc-20160816;
        b=lRoZftiwZTA/JMtyKf3fdRkL9kDfIOq2PVaI3auYa1/o3oFPsfAqpCrsB84Sh1A/nt
         wdkd6eyprv7Y6IPwUU8VmauvnaZ9xAAu9tHt03v+hqHnDOjy3VmGbR1kliYDilRQZNVf
         gIswYcPckj2lCMYvTrsgDH3rvxQUWBeILB+0fP5W7hXo5m/6OlwYWunhWZBSmFaoT/hT
         7OmIU31//O69cs/UmP2Cxa0qy+UD9TQLN87teGvoXsinOiLO+fQgEwhxZZ6+Utm6sEd/
         QsrJMqQUQrwVdF1XOoQDcSmC/wvkBnsNbNiRaAgC32wBJtEQ6gPIcY0+2Yh/fhC+gtIe
         jeVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=mw6p6jaR3RBoj1LRzqhPVPfN0Hhu76CvRXMv/H6rWzI=;
        b=xcjDxbN1Nhs0G/Q4l3NF7avj1LVBsxGbHWE7Ht8g+AJBVw9ZRPPPLrs28rN1zwgDks
         qKXrDWo+P7eRCRQsfrlWWYsrY5YS4otVVpK97oyee33oiD/rDUjv7+0EhQ/b3VFiCFW/
         vnkIiUYvIIx/JLkDFAABv5TwoLsNBt1CQ7GX3obHpxUkh+rbEokmM5Mx47iARHa4DQOn
         BIbBKycJLpzx0bX6UHDJ6quyO3HDH488F240bYzHBBoJIAFtI+EcbF78J7tqOctmvw6w
         arTzBZcWMX0wbT4qtm3Y/FpkLglmgi4db//BgXFPnqNRbLfhMRpFI2m0JzRUCtaKP9BB
         xSHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k51si2119473qta.254.2019.07.03.08.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 08:14:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A41D981F12;
	Wed,  3 Jul 2019 15:14:37 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CE7F3608C1;
	Wed,  3 Jul 2019 15:14:28 +0000 (UTC)
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
 linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>
References: <20190702183730.14461-1-longman@redhat.com>
 <20190703065628.GK978@dhcp22.suse.cz>
 <9ade5859-b937-c1ac-9881-2289d734441d@redhat.com>
 <20190703143701.GR978@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <bf569ee8-1999-97c1-d49f-ef58eef5f62c@redhat.com>
Date: Wed, 3 Jul 2019 11:14:28 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190703143701.GR978@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 03 Jul 2019 15:14:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/3/19 10:37 AM, Michal Hocko wrote:
> On Wed 03-07-19 09:12:13, Waiman Long wrote:
>> On 7/3/19 2:56 AM, Michal Hocko wrote:
>>> On Tue 02-07-19 14:37:30, Waiman Long wrote:
>>>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
>>>> file to shrink the slab by flushing all the per-cpu slabs and free
>>>> slabs in partial lists. This applies only to the root caches, though.
>>>>
>>>> Extends this capability by shrinking all the child memcg caches and
>>>> the root cache when a value of '2' is written to the shrink sysfs file.
>>> Why do we need a new value for this functionality? I would tend to think
>>> that skipping memcg caches is a bug/incomplete implementation. Or is it
>>> a deliberate decision to cover root caches only?
>> It is just that I don't want to change the existing behavior of the
>> current code. It will definitely take longer to shrink both the root
>> cache and the memcg caches.
> Does that matter? To whom and why? I do not expect this interface to be
> used heavily.
The only concern that I can see is the fact that I need to take the
slab_mutex when iterating the memcg list to prevent concurrent
modification. That may have some impact on other applications running in
the system. However, I can put a precaution statement on the user-doc to
discuss the potential performance impact.
>> If we all agree that the only sensible
>> operation is to shrink root cache and the memcg caches together. I am
>> fine just adding memcg shrink without changing the sysfs interface
>> definition and be done with it.
> The existing documentation is really modest on the actual semantic:
> Description:
>                 The shrink file is written when memory should be reclaimed from
>                 a cache.  Empty partial slabs are freed and the partial list is
>                 sorted so the slabs with the fewest available objects are used
>                 first.
>
> which to me sounds like all slabs are free and nobody should be really
> thinking of memcgs. This is simply drop_caches kinda thing. We surely do
> not want to drop caches only for the root memcg for /proc/sys/vm/drop_caches
> right?
>
I am planning to reword the document to make the effect of using this
sysfs file more explicit.

Cheers,
Longman

