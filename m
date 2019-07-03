Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F355C06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 16:16:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17B7221882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 16:16:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17B7221882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BB578E0007; Wed,  3 Jul 2019 12:16:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86B5B8E0001; Wed,  3 Jul 2019 12:16:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75A628E0007; Wed,  3 Jul 2019 12:16:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 538B48E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 12:16:23 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s22so3295080qtb.22
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 09:16:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=S4yejAAHSoPV/che1txXx4bW+5vyZRuRC4f7sDaoGTY=;
        b=P3byB+4I//JPmxKC/sFNPTWhdLkBJQ/shrgNJSAjG9cNEt90wa2qLfpkidA/+YedmQ
         AK/LGOWrGHEz5xggB0NbCnItFb24/EAWwpsUlWROepD92J+qyQRPu2Me4zOzQ71fhfUM
         +DoviAtPAUFDI/4GF482SbU1LOQc2lUezfHx3sVUD6CPbh3S+Dp0VEH/S6oUCv/b2qXr
         h2z0vqx9qHg4d5yHhwvyLdEO+N6CtMqsxINyTXR9GkbnFq3MdxrszuYOd6DNzgXrS1cy
         2uKpKlZUwChpWNFA5nCUYwTdOwftzr9AbJ/PlQNWMznsmAq4RahksJX4lODlqiRbwTvC
         /19g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXFyCwkwVEnkzBv5f1p8nNLR99EnaNJJqAaukI+niQH95SmBTXV
	PO5ouEz0b1mby2ffunp5zgQn54pL1JWf5vcCrK7CMUSa2fQaVR/bwk7BFrjeXfOBLmts3JUno9/
	ORDaSDdw8T6oovjvp0aZQb7rT9nPriqOMgGgcSk+Ubwtew0VnAaojuZ7K6DnVolbnJg==
X-Received: by 2002:a37:7083:: with SMTP id l125mr30308757qkc.71.1562170583100;
        Wed, 03 Jul 2019 09:16:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzk0cTYadH2ODlzqoZs5Elr+sT2RorOS0miIIK75aDPaK+jbW/+gGGGY7tY3Bnn3la6slE9
X-Received: by 2002:a37:7083:: with SMTP id l125mr30308726qkc.71.1562170582547;
        Wed, 03 Jul 2019 09:16:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562170582; cv=none;
        d=google.com; s=arc-20160816;
        b=NwqWX8zPrh8xWVCcHfh33OkD2fr4VXWEj3w2ZRf4k6bChDRG1dYpnBQx24zsyHrVct
         +vWSMcr1L1ehGKQVF5jzr9V7vZWxqdHGfs3p1TprvmupZDIv1gCoIiDWmrdXdMHt93UW
         DGpc8O1XQLnz2Vrjo73Us65Xbl1Ueoi+sW8YXbmOgkcmdJiZt0uHYuEvDuvTlbki9hjp
         fktBSB/NLXfP4Gyijta6SUFVkr6T+18KCbN5OIxBBheCwWCJDjHft9Pq6QfaBG8j5WWe
         JBJxwXFOrdiHcdPViL8qsQKW3+oDDcmZHEn/Mn49xZX25rKJIfmhh26TTVnRzZAMk82l
         SwbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=S4yejAAHSoPV/che1txXx4bW+5vyZRuRC4f7sDaoGTY=;
        b=bKQAx8Pw2IZMewfm38BsN00MwcK53kdXAGjSugI12UvsUMapqyo1byVYc1xGxUDD8t
         xnVJEHo/3uD3eSv4poFy8iKuR2lNP17kJ8NnkvfPwqgUpMyPCZp3sLp9TcNbUjn4KIU4
         LVzFk3f4TFljaklUJgafgDVpnQ5oB9gfy4E3pk8w2IiAxRuMk2jiOARHfZnHbYXXvhrR
         LAnhnesN4xmru9tDOyGxztbHuCB1RxWv6ArkQjSs+hNdzgtGOVddltg7YahR2pVLgl8i
         ZQ3jV5H7H6b2jT+rEr2guTAS7afmQWKA9ZQOwhPZk/8YHsL9HkZEIXccVqouMzvZ6338
         5/FA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d188si2326907qkf.189.2019.07.03.09.16.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 09:16:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A38FE307D853;
	Wed,  3 Jul 2019 16:16:16 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1165519698;
	Wed,  3 Jul 2019 16:16:09 +0000 (UTC)
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
 linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>
References: <20190702183730.14461-1-longman@redhat.com>
 <20190702130318.39d187dc27dbdd9267788165@linux-foundation.org>
 <78879b79-1b8f-cdfd-d4fa-610afe5e5d48@redhat.com>
 <20190702143340.715f771192721f60de1699d7@linux-foundation.org>
 <c29ff725-95ba-db4d-944f-d33f5f766cd3@redhat.com>
 <20190703155314.GT978@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <ca6147ca-25be-cba6-a7b9-fcac6d21345d@redhat.com>
Date: Wed, 3 Jul 2019 12:16:09 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190703155314.GT978@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 03 Jul 2019 16:16:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/3/19 11:53 AM, Michal Hocko wrote:
> On Wed 03-07-19 11:21:16, Waiman Long wrote:
>> On 7/2/19 5:33 PM, Andrew Morton wrote:
>>> On Tue, 2 Jul 2019 16:44:24 -0400 Waiman Long <longman@redhat.com> wrote:
>>>
>>>> On 7/2/19 4:03 PM, Andrew Morton wrote:
>>>>> On Tue,  2 Jul 2019 14:37:30 -0400 Waiman Long <longman@redhat.com> wrote:
>>>>>
>>>>>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
>>>>>> file to shrink the slab by flushing all the per-cpu slabs and free
>>>>>> slabs in partial lists. This applies only to the root caches, though.
>>>>>>
>>>>>> Extends this capability by shrinking all the child memcg caches and
>>>>>> the root cache when a value of '2' is written to the shrink sysfs file.
>>>>> Why?
>>>>>
>>>>> Please fully describe the value of the proposed feature to or users. 
>>>>> Always.
>>>> Sure. Essentially, the sysfs shrink interface is not complete. It allows
>>>> the root cache to be shrunk, but not any of the memcg caches. 
>>> But that doesn't describe anything of value.  Who wants to use this,
>>> and why?  How will it be used?  What are the use-cases?
>>>
>> For me, the primary motivation of posting this patch is to have a way to
>> make the number of active objects reported in /proc/slabinfo more
>> accurately reflect the number of objects that are actually being used by
>> the kernel.
> I believe we have been through that. If the number is inexact due to
> caching then lets fix slabinfo rather than trick around it and teach
> people to do a magic write to some file that will "solve" a problem.
> This is exactly what drop_caches turned out to be in fact. People just
> got used to drop caches because they were told so by $random web page.
> So really, think about the underlying problem and try to fix it.
>
> It is true that you could argue that this patch is actually fixing the
> existing interface because it doesn't really do what it is documented to
> do and on those grounds I would agree with the change.

I do think that we should correct the shrink file to do what it is
designed to do to include the memcg caches as well.


>  But do not teach
> people that they have to write to some file to get proper numbers.
> Because that is just a bad idea and it will kick back the same way
> drop_caches.

The /proc/slabinfo file is a well-known file that is probably used
relatively extensively. Making it to scan through all the per-cpu
structures will probably cause performance issues as the slab_mutex has
to be taken during the whole duration of the scan. That could have
undesirable side effect.

Instead, I am thinking about extending the slab/objects sysfs file to
also show the number of objects hold up by the per-cpu structures and
thus we can get an accurate count by subtracting it from the reported
active objects. That will have a more limited performance impact as it
is just one kmem cache instead of all the kmem caches in the system.
Also the sysfs files are not as commonly used as slabinfo. That will be
another patch in the near future.

Cheers,
Longman

