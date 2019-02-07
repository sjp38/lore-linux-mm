Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C5B5C282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 19:26:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8EEF206BA
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 19:26:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8EEF206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AA3D8E0062; Thu,  7 Feb 2019 14:26:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 459A38E0002; Thu,  7 Feb 2019 14:26:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3981E8E0062; Thu,  7 Feb 2019 14:26:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id F06AF8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 14:26:07 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id w16so588696pll.15
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 11:26:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vCUtK4xdm3mL3qxQAX0IUB7gf44E9r0R4/l21bx323o=;
        b=iRa8G5BsLX/ubHkZMPytQNIWB+w2jzMB2+F430eLM0W4zVB5Gpvq77+KMwES/3tC1G
         61K1mrr9MiVdsxliwUaT9kJieGO7CFHO8SVCPc7a4gMCLsSUVF0nQQDC8dMuM1v2tiPD
         v5sjRRKgpye0Y4LFA8P576m5PCGo5TNzkV7YP6L7rvFIE6HxkTUvzBOLhbvjIin29rhr
         o+FSCtMBubLYg84JvX9BjjwmeLRm9tRCPEtN2hfSLPg8UE0iNsklLv8BVLm/N+vQ4+qT
         e2DxlMS4ef4DXO5HP4uraWzNikxh+04QO8ruZOJGBdLhKr1IhB0AcFJLEvG8DDaUQ2uw
         /6Nw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuYsxT9u7/A/unLZ4QdLt8bWEsYjT3nQssmJaDqD1/q1TqUjT9tF
	LzzxyhTGpux9gnHPFmpB0HK6Sovj1PRXk0qjU8fh/fp8MmPEmAm1a7J+6lmS3SBvpLbjxGKxTY2
	RJbcncGk4N/ufzXKOB5W3V43z/3rVxQYqNkw7+KjY0HA6AS2dJu65QuapRO6P4JI=
X-Received: by 2002:a62:520b:: with SMTP id g11mr18091176pfb.53.1549567567580;
        Thu, 07 Feb 2019 11:26:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbmWXcTzZLzaUzZOJ7B0C+OfoAf0Ynlfddejh00bJ9n4VgB3hCs4H2wMXG3sg7ggN8nfyZ9
X-Received: by 2002:a62:520b:: with SMTP id g11mr18091114pfb.53.1549567566746;
        Thu, 07 Feb 2019 11:26:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549567566; cv=none;
        d=google.com; s=arc-20160816;
        b=oSXHsX5r4OjrhPOba6419xiiPPMorpE1v+8St2nxN/UCrkvSe2tgnrDrtQEytCIvvl
         FsPkt1pYD9aSLvLOjk/NmsJo7cQCpOM/f6xkOGLBtdBpOeOr3fbmxBjf2UYscTDBx9XH
         GU/ZI6ExFyP48PC6ERKwF/aNKDyywmGBhwjFgkyiXZMCUCEsIIK6cCgvEH32JEqp0UuM
         8XGB/tor+wSWSBiuwOPMoadJe7agKXmEpuY4N+E0vVkqhBNE9jItuf/SW9PSgKW+x8pj
         tWHaXQrO5tcUFeRyT34d8WaJeQURsilSZUl+rLM6BpKPRidKb1quKCS54MFc1SWEsUgC
         5NaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=vCUtK4xdm3mL3qxQAX0IUB7gf44E9r0R4/l21bx323o=;
        b=ROc0YasjHtYcWP4XZ05uXcig2CiHwTZEYZRhTT/CEunHdjEdySzOl9poARIbb7DrQW
         3aNN0n7TWmKTnTc+ffhm55nGNDCSDOQmUF4qoMacYJLnmj7zSsaLsMl0JQ7+WN1OiDqN
         ainV2vFubSoECEcgAFnqw3AO64zVnetd1Mel03eYrLi/qB00tBY45QM/a9AXqegdl/4g
         4NnLHUdq2OQAEy7g3wth4DRYqFQaaUtNAOaPDYykXLsc5txy515oiub2o7SJdzThIv/j
         8xQcfMFk79eu7zjhzjNrC7K9b7wOY+4+KyU3/L5XMtLLcmoBtpmu6a2fHwkysNWWIdAE
         OjOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e129si9092053pgc.333.2019.02.07.11.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 11:26:06 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 68F3DAF29;
	Thu,  7 Feb 2019 19:26:04 +0000 (UTC)
Date: Thu, 7 Feb 2019 11:25:55 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
To: Paul Burton <paul.burton@mips.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>,
	"linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
	Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH 2/2] MIPS/c-r4k: do no use mmap_sem for gup_fast()
Message-ID: <20190207192555.n3qtle4yqmfb2tpo@linux-r8p5>
Mail-Followup-To: Paul Burton <paul.burton@mips.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>,
	"linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
	Davidlohr Bueso <dbueso@suse.de>
References: <20190207053740.26915-1-dave@stgolabs.net>
 <20190207053740.26915-3-dave@stgolabs.net>
 <20190207190007.jz4rz6e6qxwazxm7@pburton-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190207190007.jz4rz6e6qxwazxm7@pburton-laptop>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 07 Feb 2019, Paul Burton wrote:

>Hi Davidlohr,
>
>On Wed, Feb 06, 2019 at 09:37:40PM -0800, Davidlohr Bueso wrote:
>> It is well known that because the mm can internally
>> call the regular gup_unlocked if the lockless approach
>> fails and take the sem there, the caller must not hold
>> the mmap_sem already.
>>
>> Fixes: e523f289fe4d (MIPS: c-r4k: Fix sigtramp SMP call to use kmap)
>> Cc: Ralf Baechle <ralf@linux-mips.org>
>> Cc: Paul Burton <paul.burton@mips.com>
>> Cc: James Hogan <jhogan@kernel.org>
>> Cc: linux-mips@vger.kernel.org
>> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
>
>Thanks - this looks good, but:
>
> 1) The problem it fixes was introduced in v4.8.
>
> 2) Commit adcc81f148d7 ("MIPS: math-emu: Write-protect delay slot
>    emulation pages") actually left flush_cache_sigtramp unused, and has
>    been backported to stable kernels also as far as v4.8.
>
>Therefore this will just fix code that never gets called, and I'll go
>delete the whole thing instead.

Even better.

Thanks,
Davidlohr

