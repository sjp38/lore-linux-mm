Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08C39C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 20:44:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E8921850
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 20:44:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E8921850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46A4B6B0003; Tue,  2 Jul 2019 16:44:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F3D08E0003; Tue,  2 Jul 2019 16:44:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BA828E0001; Tue,  2 Jul 2019 16:44:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 075DB6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 16:44:54 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o16so17635035qtj.6
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 13:44:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=a8AfgegtXMfnpWfoV9HzhDeQiedCpqpiw+BU3RLFggU=;
        b=kYDiv2o+4t09PckGcfkepKoSIjNOABIW2Yz8wrJCGxxr2qg7TDupCpvJOGWXavbjpX
         lehD6KOjhf5+UMrFFiY9xp+1SuSpox7FozuEwer7dmhGepWAiSIz/VmCltXtJLfX+KkO
         cKwJKsPyohu8/wI6gbWyjrc0/njtPfrQVvijn3UhJqng3DL6HrR7rjgIePgOMMsLaqFi
         YAfBDjOgCSXW3Gsw5uWkb05GmuXT6qtIlW3aXJi+jNqG2VUxszwX4dXpjZ/XnSnwEPzo
         iwPCK18E5l86KndX1YSoHulxa6A/SNHGr+OEidZfm8TwM6UQjNVTLj0KkndIQpYwM5bM
         3Yqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW+/BNlfPtdcpsWRB0h4qr4gPD888km+Y6u5Bm0Vs3uRHZ7GjGY
	N8MgHWlD7bbK8ec0xmBdcoCx3Du4HXjlm7l/hbi9A3mUbkI9ImgqSC0Gtf7EsGE8XkVm42RRPeK
	ILxfdEWM37U7bMyQ+UUDs6kPkAnlmigJMsMXjtugWVBPOO3zdfs6RZw4ULTBfG8lMYw==
X-Received: by 2002:a0c:d4eb:: with SMTP id y40mr28085018qvh.30.1562100293791;
        Tue, 02 Jul 2019 13:44:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0SzR6ZLYSQHCUxvydKwhPbtY1Ch2Y2xfa/QchX93tTvmZrKKBVICJZh7ZgxtFKy6jUHTf
X-Received: by 2002:a0c:d4eb:: with SMTP id y40mr28084981qvh.30.1562100293112;
        Tue, 02 Jul 2019 13:44:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562100293; cv=none;
        d=google.com; s=arc-20160816;
        b=N8M3ACcXNMZRQ49W7oCFv8BFc80p9Tquw1ODuuWHVUML1UWhTNQBqu4j1lVo2IIOpc
         rGyP6AKlp/87yTU1pLcdGapWzEHtyfr7Xn+JOIC8LTl2Ge0UoljSUVUgBmNAPzWQab4d
         3wOLe35ggRejOwtsc0bjW398N8wNH3Rf228uNyW4FCWLVdc5GEaDyVE1hksJSdngJUim
         Bv8v+iGGPxsXTP3vqp7IeP6L81izwyaWZEI9BXUs0QIecoI8z5b5fD/twSNP7WOlCRiX
         L4Qn+rECcIj/tXpzYXprsH3Gf+vKv6lgVB4q7GfYtA9nfAUNhGRFtH2SazbJ1M3KZhBj
         gyDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=a8AfgegtXMfnpWfoV9HzhDeQiedCpqpiw+BU3RLFggU=;
        b=a1leDVvAidD/Nv0dcjAf4wHQ1JDXRuhsVkE0jSL6pVLzVPYLPtrDXOVrQfxiBOTUHv
         53f8y9D3pXTmNjNWpxy2lsFpMyhVhvKsSRiWQ0C0etRvY7J6fIFBjGVuSwrU9aNeB8kb
         P+4T09l7ariKtd6tfY9BCwHGiiO6eRHYizlcALmeS/EC6WKDICLWo4AN/7RTPhAPPoVx
         bWvfHqVpZNabUpK50/2xuNzTdijnaxlI/WuPFR8m39PKYb7i+6SUBNxrrbJWHkdL7yTL
         l3oktXRBAxFrMh5EDecQJm/N9btKfNCfRecZ43lMzL6zi44xEfV8jVG1BBRvNDmY1ZmH
         AZtg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f189si66986qkb.246.2019.07.02.13.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 13:44:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 68284309174E;
	Tue,  2 Jul 2019 20:44:33 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 67346183E0;
	Tue,  2 Jul 2019 20:44:25 +0000 (UTC)
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
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <78879b79-1b8f-cdfd-d4fa-610afe5e5d48@redhat.com>
Date: Tue, 2 Jul 2019 16:44:24 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190702130318.39d187dc27dbdd9267788165@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 02 Jul 2019 20:44:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/2/19 4:03 PM, Andrew Morton wrote:
> On Tue,  2 Jul 2019 14:37:30 -0400 Waiman Long <longman@redhat.com> wrote:
>
>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
>> file to shrink the slab by flushing all the per-cpu slabs and free
>> slabs in partial lists. This applies only to the root caches, though.
>>
>> Extends this capability by shrinking all the child memcg caches and
>> the root cache when a value of '2' is written to the shrink sysfs file.
> Why?
>
> Please fully describe the value of the proposed feature to or users. 
> Always.

Sure. Essentially, the sysfs shrink interface is not complete. It allows
the root cache to be shrunk, but not any of the memcg caches. 

The same can also be said for others slab sysfs files which show current
cache status. I don't think sysfs files are created for the memcg
caches, but I may be wrong. In many cases, information can be available
elsewhere like the slabinfo file. The shrink operation, however, has no
other alternative available.

>> ...
>>
>> --- a/Documentation/ABI/testing/sysfs-kernel-slab
>> +++ b/Documentation/ABI/testing/sysfs-kernel-slab
>> @@ -429,10 +429,12 @@ KernelVersion:	2.6.22
>>  Contact:	Pekka Enberg <penberg@cs.helsinki.fi>,
>>  		Christoph Lameter <cl@linux-foundation.org>
>>  Description:
>> -		The shrink file is written when memory should be reclaimed from
>> -		a cache.  Empty partial slabs are freed and the partial list is
>> -		sorted so the slabs with the fewest available objects are used
>> -		first.
>> +		A value of '1' is written to the shrink file when memory should
>> +		be reclaimed from a cache.  Empty partial slabs are freed and
>> +		the partial list is sorted so the slabs with the fewest
>> +		available objects are used first.  When a value of '2' is
>> +		written, all the corresponding child memory cgroup caches
>> +		should be shrunk as well.  All other values are invalid.
> One would expect this to be a bitfield, like /proc/sys/vm/drop_caches. 
> So writing 3 does both forms of shrinking.
>
> Yes, it happens to be the case that 2 is a superset of 1, but what
> about if we add "4"?
>
Yes, I can make it into a bit fields of 2 bits, just like
/proc/sys/vm/drop_caches.

Cheers,
Longman

