Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B991C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:14:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EFD3206B6
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:14:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EFD3206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4ACB8E0006; Thu, 14 Feb 2019 12:14:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFA438E0001; Thu, 14 Feb 2019 12:14:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B10058E0006; Thu, 14 Feb 2019 12:14:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 59BFA8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:14:00 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b3so2806522edi.0
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:14:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KoJ2hmB2EuTXveUt+Cu906+g5CIR2gb8MLMwmOc7vtM=;
        b=e7Tq34lKbR8OPLQV+RvbmMycUPmEftZYVk7SEq+nPgDZbS4Ap2JebkSuDVoA1+5ANn
         gIzWFFjeLC0Y1zluuHKecD5UdXommwzr2EMamLWiHqXlJ8dqu8xL8XCTUfxAYz3JAUfY
         fZ6e22MP20i2AR+tWf8UpnXDn/JnK5uc7/f47wDDRAmPU4nAbLs5RwrA94hnn9UgNg5t
         rC9Qq7FpGcmzU4g4QLegE8zEYcYbsMv3sREKKucFMWUaTgw/Ar6ODgPfG4PXrrFQ0vDM
         fWRX341v7Za8fd94urygNKWzreMFDjQUpdTDEWQWJjdR+TQq09Ztq5T5rBAH2H7hA6n3
         kn+g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAub+3qpqGcP+xGb4Ht1vj419jrJgYblneSJWsRWmPKKp5Z7Za0aS
	9ol17O+HkptZc19rVgUCBY1HvjG7kZELZ+9hNxMakCZIMnRVvigmTVIlbAv9sEXYWHfHnFhc+uM
	6ts4CMMHj0ieAmxoBn2b4Dc9ZL7ENTZz9I++CW4vBlBmFTXHbKzQ0jhOjAUOPjhs=
X-Received: by 2002:a17:906:4bc8:: with SMTP id x8mr3653280ejv.6.1550164439896;
        Thu, 14 Feb 2019 09:13:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbfJv/EZj6jwVwdhRSamaOXf3Zi0xzyRMb5ypIIWdWABaarsANfLwD/G13jajfBFYjBIZNV
X-Received: by 2002:a17:906:4bc8:: with SMTP id x8mr3653237ejv.6.1550164438977;
        Thu, 14 Feb 2019 09:13:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164438; cv=none;
        d=google.com; s=arc-20160816;
        b=o2BfFWlGbfnw2LpU7VZK0JLsj+KeOoEpLZoVHBNCgC/o2NwZzSywKvFReEIHK3Ydb/
         MnM0SSD8aYnf7kgwy8HskynSIEnj+DPYrtyScTzv/9Btv7HED70UTcdsphBNIyhLpq0L
         AAmtSiDpxg7G0FmDWnT2Tux3Mfx+YWAkbF0I5szGskGsUKe66w4Nvt1EeLwDXuussMYq
         RM8PtjbXYuAkvptfzn5sMa2ii48wlPW5mtHiwhpbF2Dgh3WzTBmauYzHNqnab/XQ1+C4
         N5TNcM6x37GCyofPSMd5OKIJ8T71zaMe0mAKlTWEMY0abceVPxwhU1OZqt4W6PFabv/X
         uPAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KoJ2hmB2EuTXveUt+Cu906+g5CIR2gb8MLMwmOc7vtM=;
        b=m3VhNOPCyHD6ybUZb/jcZmQRffrVGE7OO3rbru4/l2F0Lnlm5ANDedNZyaFMV7wgmo
         aNXLZztHu7TfUb/oq4qbGcWxNNXdBJNDBJNNVMaoiLodZXEfdo06qVuRhacJ5a9G4brU
         iYELlZya14xcIk0U8Oi3b4qCHNRbKgvv0y4ITBjh/GCm9KbKTjN1+WkVs4v5h/wJTqrD
         1sIyNX85e1tDxMWb32dNmxDOODfM5Us2t7E9k/xTgbyUREjIRVz32sAbAZbOC78rmaGD
         jsJCuPfTWZr+kxOf5MKp8yJWlI9CicAHppzwN8lMtbWhdK0D3frEZoMkhFfH2oXEU7P6
         e+bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e28si78330edj.410.2019.02.14.09.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:13:58 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 90EEAAD25;
	Thu, 14 Feb 2019 17:13:58 +0000 (UTC)
Date: Thu, 14 Feb 2019 18:13:57 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Jann Horn <jannh@google.com>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2] mmap.2: fix description of treatment of the hint
Message-ID: <20190214171357.GO4525@dhcp22.suse.cz>
References: <20190214161836.184044-1-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214161836.184044-1-jannh@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-02-19 17:18:36, Jann Horn wrote:
> The current manpage reads to me as if the kernel will always pick a free
> space close to the requested address, but that's not the case:
> 
> mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
> -1, 0) = 0x600000000000
> mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
> -1, 0) = 0x7f5042859000
> 
> You can also see this in the various implementations of
> ->get_unmapped_area() - if the specified address isn't available, the
> kernel basically ignores the hint (apart from the 5level paging hack).
> 
> Clarify how this works a bit.
> 
> Signed-off-by: Jann Horn <jannh@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
> changed in v2:
>  - be less specific about what the kernel does when the requested address
>    is unavailable to avoid constraining future behavior changes
>    (Michal Hocko)
> 
>  man2/mmap.2 | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index fccfb9b3e..dbcae59be 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -71,7 +71,12 @@ If
>  .I addr
>  is not NULL,
>  then the kernel takes it as a hint about where to place the mapping;
> -on Linux, the mapping will be created at a nearby page boundary.
> +on Linux, the kernel will pick a nearby page boundary (but always above
> +or equal to the value specified by
> +.IR /proc/sys/vm/mmap_min_addr )
> +and attempt to create the mapping there.
> +If another mapping already exists there, the kernel picks a new address that
> +may or may not depend on the hint.
>  .\" Before Linux 2.6.24, the address was rounded up to the next page
>  .\" boundary; since 2.6.24, it is rounded down!
>  The address of the new mapping is returned as the result of the call.
> -- 
> 2.21.0.rc0.258.g878e2cd30e-goog

-- 
Michal Hocko
SUSE Labs

