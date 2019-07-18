Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E28CC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:52:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 090A2208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 090A2208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70EA16B0003; Thu, 18 Jul 2019 17:52:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BED16B0006; Thu, 18 Jul 2019 17:52:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5611B8E0001; Thu, 18 Jul 2019 17:52:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07F6B6B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 17:52:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so20806810eda.2
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 14:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=l5HfSiJvAfpchiW5dxqWe0qNXU8EXRJNvIuDUM5iI90=;
        b=bWyQVovuTXNmqpFA7oyf46rOeFNpmEnj4/wxVijDv6y8R/rY7xp+2ws9fix9t/NhuV
         B8B+0anoxXAJOPdLSUtLqNZGjp6maAGIrw+ouDPFCEVD0FlOEJtCRdE7dPoGm7Jt0W7a
         5MQUHQE+FIEuyigasZ2Xm7F06PP8j5ZIVRnO5H2sDFHoLgZuBTAt30jVfMzCx7V2PxmE
         G6SeOE3qNY2aOnqN6xDkjH3pCo3crVV9X3jm1Btz3H/i+5I9bz96VrJl2GKvnw370QNp
         LEBR/lDMFBkGG2OY5/n5iPkP4vq+jkCCtzpGvnfKS98B8msWKoJGnUirhXrijgZMUQet
         gx/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXJPXieC4yNrQXIXBGLN1iJHUvA0unZBOssvIJAWplC3L2+Ygk4
	B1NJ1P9sC2EZb5rrKFKYKDRR1s/CDEvTc3hwP1WIwju6bKhmiIGwE2vKPBNced5x9cqRRK81h1b
	vxVZzUOdX34D0oU5VvS+416oWY+mo+qAoEDTo4cER4Hh/o4xQdYqnfkLScfGavPg16Q==
X-Received: by 2002:a50:9273:: with SMTP id j48mr43603013eda.285.1563486727535;
        Thu, 18 Jul 2019 14:52:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGbZ/b+oTKlj4Mw/goNqTNYRiqBkk/kBwcb4HCZYGOPavYOqEu3/Eb2dIrt0lzp64wNCbD
X-Received: by 2002:a50:9273:: with SMTP id j48mr43602972eda.285.1563486726833;
        Thu, 18 Jul 2019 14:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563486726; cv=none;
        d=google.com; s=arc-20160816;
        b=b1b0VCsYsq4KhqPQBcWY1VSrq57CwfniJDgJkTrvHDNuMDYh2ENJRVkCp2yeG/NKh6
         w65gsXUefEfVapHh0M/3NoHiDnrzaTe1hQesfcwI+pFAQFC7ZtMeOxHi50YvBrBHSV26
         U58CA6KCv/VI93AbuK/+1UuBb0R1EAHKcComAcqNOg64IWUY5S3rvT6fIgipfUMNFNMx
         KGBpAtUWm+joaB96cuMhjLK9kJgT+0zWRma7j3sobAeNlF/1CSNsyFdzIUwVo7txPTTw
         X/cS8TrZt/WvUStyVHU9admt77ZZijMCriryMackjBuKvKqtuHAZHKsuyf5gRz2ttuj2
         ErEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=l5HfSiJvAfpchiW5dxqWe0qNXU8EXRJNvIuDUM5iI90=;
        b=zfiIkjnNpnE+EjIxph48SouwrpuAOYSHNl8CmaTpg1Fqg9vdNhErUc4Wa9q0giipzq
         6pPhq5xzSq4TZ3hp2UcgtH5CxOXF3tHx7owQYi8dplsGh7JTwSn2BI8KIDSLZm7hjjC7
         LwQJjxvkMGyehblWRh+Hir+BRhpK2IVf+Hdsk6NbA82jw30gjwkXqxqUFTU7MqVL6AIS
         dg7ilYLsZmKYtB8r/EqMWiaGQvLaIWu7RKiYAKhse+ZuD1OzRjPpuKlcgW7I2IuNTrcp
         dY/QcV+ODndQnd7qzkZL94CcZQ0YAwCs2j6wDE2DDjuskOYuPI4hfxrhwR0+hGgEeHs4
         7G/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 13si144459edz.208.2019.07.18.14.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 14:52:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 38828B12A;
	Thu, 18 Jul 2019 21:52:06 +0000 (UTC)
Subject: Re: [v3 PATCH 2/2] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Andrew Morton <akpm@linux-foundation.org>,
 Yang Shi <yang.shi@linux.alibaba.com>
Cc: hughd@google.com, kirill.shutemov@linux.intel.com, mhocko@suse.com,
 rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560401041-32207-3-git-send-email-yang.shi@linux.alibaba.com>
 <4a07a6b8-8ff2-419c-eac8-3e7dc17670df@suse.cz>
 <5dde4380-68b4-66ee-2c3c-9b9da0c243ca@linux.alibaba.com>
 <20190718144459.7a20ac42ee16e093bdfcfab4@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <dd44eb2f-a982-bd0e-a1ed-ab3ecbf3fc91@suse.cz>
Date: Thu, 18 Jul 2019 23:52:04 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190718144459.7a20ac42ee16e093bdfcfab4@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/18/19 11:44 PM, Andrew Morton wrote:
> On Wed, 19 Jun 2019 09:28:42 -0700 Yang Shi <yang.shi@linux.alibaba.com> wrote:
> 
>>> Sorry for replying rather late, and not in the v2 thread, but unlike
>>> Hugh I'm not convinced that we should include vma size/alignment in the
>>> test for reporting THPeligible, which was supposed to reflect
>>> administrative settings and madvise hints. I guess it's mostly a matter
>>> of personal feeling. But one objective distinction is that the admin
>>> settings and madvise do have an exact binary result for the whole VMA,
>>> while this check is more fuzzy - only part of the VMA's span might be
>>> properly sized+aligned, and THPeligible will be 1 for the whole VMA.
>>
>> I think THPeligible is used to tell us if the vma is suitable for 
>> allocating THP. Both anonymous and shmem THP checks vma size/alignment 
>> to decide to or not to allocate THP.
>>
>> And, if vma size/alignment is not checked, THPeligible may show "true" 
>> for even 4K mapping. This doesn't make too much sense either.
> 
> This discussion seems rather inconclusive.  I'll merge up the patchset
> anyway.  Vlastimil, if you think some changes are needed here then
> please let's get them sorted out over the next few weeks?

Well, Hugh did ack it, albeit without commenting on this part. I don't
feel strongly enough about this for a nack.

