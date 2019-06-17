Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33EECC31E5D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:36:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBDA820644
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:36:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBDA820644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53F476B0003; Mon, 17 Jun 2019 12:36:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F0708E0002; Mon, 17 Jun 2019 12:36:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 405FE8E0001; Mon, 17 Jun 2019 12:36:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA4356B0003
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:36:36 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so17156307eds.14
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:36:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ixv+eGXKTowsQd4kSC6437PjWxMZSw4RTfDydACcbNY=;
        b=D4f8JU2xBjxnbz6zLfikhmmAgwaTtRsPBmK8M+fW+rVv1q6QEJfuIEgDVDfCxhYnUB
         DFqVMv6SGXHJnZKR0xAFe97HCEtESrbbs3CTTobgZO3R3snV/VUs077NyR5K07eSPoe5
         X1wA6Dioxn7zI/mI8Tjn2ySrFEYRFxQ0znVHHLnqH/pXWG31GDSQYxy0cygQd372aMVt
         b/p5HNx4mh8hjII8aUJjeGtMU1mnQHJk/UkCqhy/Ie2cfJFO2VT+gbCZFW4eVDLDJ/Ba
         N9aD8dUvD9t90iwbbagljonPc9/4J7nYjTyB+8JAlWbtoeIHWtnmCb6/RWIt91/HmI5M
         /6Ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAUudUmCGd1l2gcasccDFHTk86ZAEYvZTTcsEwowCQxorGOhK9X1
	pmaMc/EHY1krk4NYjC6XDtqgon9SrZBGDG0GVCEuQ//oN7cTtHfepo1CvjEqRgshHKS8UziC0w9
	CPzZxi9ODd4611XIfHve6YWrRAsEj98xgq/iuGWrZxixrqO5orMf13zBmujjGrYs1eQ==
X-Received: by 2002:a17:906:c404:: with SMTP id u4mr51732742ejz.123.1560789396432;
        Mon, 17 Jun 2019 09:36:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwslmzzoXWAWx0AFVUeipPQOVznLQwXvAH190M6nfNc7T15JHqR7Dm70pzlCfc7q++2yIw
X-Received: by 2002:a17:906:c404:: with SMTP id u4mr51732672ejz.123.1560789395421;
        Mon, 17 Jun 2019 09:36:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560789395; cv=none;
        d=google.com; s=arc-20160816;
        b=uFloPNTar3i4TJmT3QTepZ10Tmeb1o+r3LOveHrEkEYc11ZA8xKiiRz2I6UQJ4VnH8
         Z1bBAvXSOl/UCQXIDUUGk3TU5zBeBN+TmDvRMqyOazJ1J4PXTW1TmabvuvUn+MiMTy3h
         EVFJajV4z1nckn64Wi9atC39QJnMIt4ZurFuhi+2mph+N95dO1AiKSXqYmUkbqxNL4bz
         Wv/GYhaMTSBJ6iVGt3V5EA+7Rzv2XCdiXV1nmyFF3zskGNIjINK1/+BtVmXL2oSIha7m
         Cw+VN0OocGFKNjxrIllmTQi9qBPCWxa0PL6ghHmbh6x74eP7MQe08+BSTx7DkDszY2sP
         IQgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ixv+eGXKTowsQd4kSC6437PjWxMZSw4RTfDydACcbNY=;
        b=vTpzQRfeK5poOjvn5n5yrCrYNaqNvN5j5ORhDDBOX5WciZN0/c6kL+TEHX9EV0nnJL
         /FatiQs6Wx+fC2nHzZaznDrs8bEKTbWRBIfKc87/rbFn4WfElBpgErdOJDKVlxUoQyJM
         /UKwABh2TRoeYZ5+yW4zuy7Qq4ZBTxrZVKiSLTGf3pTM+mqdrj7gwTgUe3PBN1sBhkYy
         8XI4JzgrNaTY6RjFVoI7LVDvrIU2DlqrrxD0wPhryJYyDKlbbWYMPPy3OMZKwEGDueSF
         4saClppHZvb6hiew2oMT7zc1HJ8DdMhamrm4X/SXSKzV0rf7PSWuNWtN263zrtITgYXL
         +05g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l1si9386929edb.84.2019.06.17.09.36.35
        for <linux-mm@kvack.org>;
        Mon, 17 Jun 2019 09:36:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8A67528;
	Mon, 17 Jun 2019 09:36:34 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D6AFA3F718;
	Mon, 17 Jun 2019 09:36:32 -0700 (PDT)
Date: Mon, 17 Jun 2019 17:36:30 +0100
From: Will Deacon <will.deacon@arm.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Qian Cai <cai@lca.pw>,
	akpm@linux-foundation.org, Roman Gushchin <guro@fb.com>,
	catalin.marinas@arm.com, linux-kernel@vger.kernel.org,
	mhocko@kernel.org, linux-mm@kvack.org, vdavydov.dev@gmail.com,
	hannes@cmpxchg.org, cgroups@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
Message-ID: <20190617163630.GH30800@fuggles.cambridge.arm.com>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
 <20190610114326.GF15979@fuggles.cambridge.arm.com>
 <1560187575.6132.70.camel@lca.pw>
 <20190611100348.GB26409@lakrids.cambridge.arm.com>
 <20190613121100.GB25164@rapoport-lnx>
 <20190617151252.GF16810@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617151252.GF16810@rapoport-lnx>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On Mon, Jun 17, 2019 at 06:12:52PM +0300, Mike Rapoport wrote:
> Andrew, can you please add the patch below as an incremental fix?
> 
> With this the arm64::pgd_alloc() should be in the right shape.
> 
> 
> From 1c1ef0bc04c655689c6c527bd03b140251399d87 Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.ibm.com>
> Date: Mon, 17 Jun 2019 17:37:43 +0300
> Subject: [PATCH] arm64/mm: don't initialize pgd_cache twice
> 
> When PGD_SIZE != PAGE_SIZE, arm64 uses kmem_cache for allocation of PGD
> memory. That cache was initialized twice: first through
> pgtable_cache_init() alias and then as an override for weak
> pgd_cache_init().
> 
> After enabling accounting for the PGD memory, this created a confusion for
> memcg and slub sysfs code which resulted in the following errors:
> 
> [   90.608597] kobject_add_internal failed for pgd_cache(13:init.scope) (error: -2 parent: cgroup)
> [   90.678007] kobject_add_internal failed for pgd_cache(13:init.scope) (error: -2 parent: cgroup)
> [   90.713260] kobject_add_internal failed for pgd_cache(21:systemd-tmpfiles-setup.service) (error: -2 parent: cgroup)
> 
> Removing the alias from pgtable_cache_init() and keeping the only pgd_cache
> initialization in pgd_cache_init() resolves the problem and allows
> accounting of PGD memory.
> 
> Reported-by: Qian Cai <cai@lca.pw>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/arm64/include/asm/pgtable.h | 3 +--
>  arch/arm64/mm/pgd.c              | 5 +----
>  2 files changed, 2 insertions(+), 6 deletions(-)

Looks like this actually fixes caa841360134 ("x86/mm: Initialize PGD cache
during mm initialization") due to an unlucky naming conflict!

In which case, I'd actually prefer to take this fix asap via the arm64
tree. Is that ok?

Will

