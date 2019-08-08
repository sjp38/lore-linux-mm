Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06532C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:43:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF20F2173C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:43:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF20F2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69F036B0003; Thu,  8 Aug 2019 13:43:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62BB26B0006; Thu,  8 Aug 2019 13:43:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 518816B0007; Thu,  8 Aug 2019 13:43:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13FF46B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 13:43:31 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so58611349edu.11
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 10:43:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rNH82QolQNP9Pv+6bY7Cdvt8l3HvRf6sz/YqpahQXY4=;
        b=oelhfL852sk7H1++cFDl74JHCpaAotKRQMYgHvhI4/A3NS2uM6c0WeabXEB9x/exs5
         Q3tBv7SVuVNGhgTflbS7XovF9afFI98o5znOSJIcceoDW2bi9M8YgIAEEJbVuIyzQu1B
         VHWb1lIWqdDyMHzOUV6CNnftSFpHy12nZ+ur0CPADpWZM2iY7LL/XdS6I2HRLz+ghLe5
         T5VFYuX53EA+p0DHoXSrACCU/ga7Fkxs07gnDjePF72QdJ+Co3M03vNm5dfasiIHOAIz
         yldR/b98Y3xWu69O5GnrAlxmfqXVV7oyjV7YGl2i1Rw4hlkWUiZ/EVndpRo0johvW/sT
         YN8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAXkoc85IRpyacKX7XlJOPxU2dYKGQH+EpgcAhYPs2lz6T8lWKmv
	kNME9p2TWSkngtu/h3x9bvBhxqZ6JRQYGz2RXHJgiBvPR5kQn56llCZdj8Dfmk4RNKESw60etkg
	c5egbpBGIKg3siZMLBuNmBMZ7orGWtmXY4EyenSf9tZsFnZw1dJvs0WFs2hBhD6jXRQ==
X-Received: by 2002:a50:ee0d:: with SMTP id g13mr17288868eds.113.1565286210660;
        Thu, 08 Aug 2019 10:43:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSSQ3HV8d68BgMkRy1NUxZWQfB6vP0O1sXMteJD5PXt3/6I34WK0JwEO2TEyQX+ZJO1fJL
X-Received: by 2002:a50:ee0d:: with SMTP id g13mr17288797eds.113.1565286209889;
        Thu, 08 Aug 2019 10:43:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565286209; cv=none;
        d=google.com; s=arc-20160816;
        b=riIupXxGjGSgKu9TNpvNnz0RLz57NLfXsSsBjOO45WRqGFlyAFWIm2LEmjDi8h2dII
         3l+OfmWtceDTyxHt1iLppWx24D1mF17K+Ua1lBo/SOD2s8IRvm/6Fsa81PXt+0/A0iz8
         T3FCEcvd0W/l6FhgjKXy5v1RqZv89Ki5enKRyKhry3Vx2Sjk7r8OBSYpuQlkTrYvMva7
         /ehexxALGhB5q6aqhW0ATv4ipLP8BZKXCYAJJi0zvIDC+zpp5kY55sHNyTjX35IA+PvD
         9/b5HkRK63FEQjlA0dyAwD13DyEqXf0c5gcp3goJ0iZV/XaHlWxKtieRJ+TatgXHOVGc
         1tCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rNH82QolQNP9Pv+6bY7Cdvt8l3HvRf6sz/YqpahQXY4=;
        b=XSRU24QIWht3FBZaSdvKN74vgqLcVQG+VIUAlQIS370nhkVfdtsW4H7+CKVzl7WhCH
         plhnP+XyZ6bq2cSg1PaNz8KUxoG2RRHnphBGWBjrIDfNDWDR6FiQN4AlCI9k31bdwURp
         nwtnUS8cDfSYhuKuWwD8/qGAYxhUxdDYzGOHU6f0DD1wEJ+dYAK5y+TLTcdfkgUpe4hT
         iUL7TEHNnn9t3DpB2IkLQxfZurfAJNEx/LYWpdPrtnliEKL3HX8Uj35qpOk02RRsoKkv
         CzIWk5vlB5hN4Mz2qcRxyW3l/wbE1dVJDx8vgIRxLko2yEIBYNAR6t05gOx6ax3chSZg
         3kIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c4si34882381edq.280.2019.08.08.10.43.29
        for <linux-mm@kvack.org>;
        Thu, 08 Aug 2019 10:43:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EF16815A2;
	Thu,  8 Aug 2019 10:43:28 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B55B33F575;
	Thu,  8 Aug 2019 10:43:27 -0700 (PDT)
Date: Thu, 8 Aug 2019 18:43:25 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org,
	aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org,
	linux-kernel@vger.kernel.org, dvyukov@google.com
Subject: Re: [PATCH v3 1/3] kasan: support backing vmalloc space with real
 shadow memory
Message-ID: <20190808174325.GD47131@lakrids.cambridge.arm.com>
References: <20190731071550.31814-1-dja@axtens.net>
 <20190731071550.31814-2-dja@axtens.net>
 <20190808135037.GA47131@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808135037.GA47131@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 02:50:37PM +0100, Mark Rutland wrote:
> Hi Daniel,
> 
> This is looking really good!
> 
> I spotted a few more things we need to deal with, so I've suggested some
> (not even compile-tested) code for that below. Mostly that's just error
> handling, and using helpers to avoid things getting too verbose.

FWIW, I had a quick go at that, and I've pushed the (corrected) results
to my git repo, along with an initial stab at arm64 support (which is
currently broken):

https://git.kernel.org/pub/scm/linux/kernel/git/mark/linux.git/log/?h=kasan/vmalloc

Thanks,
Mark.

