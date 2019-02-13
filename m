Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 687FCC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:47:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2708D222B2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:47:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2708D222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A03F48E0002; Wed, 13 Feb 2019 06:47:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B3D98E0001; Wed, 13 Feb 2019 06:47:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A2EC8E0002; Wed, 13 Feb 2019 06:47:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2F58E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:47:28 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so1518406pgq.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:47:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2WwpL2L07AuK20ZP2HgSWeV40opIDpYTKHlG1jeLB/8=;
        b=liEjQKmcjpzmirMKv50/K9BsJGqqyxDQOBkDHwX9eExhnaBAGIza/s6CcxHOetJlv6
         yfIKbI2QDoQCNjTIu+GB+qZRNNboK+M610D12qYfAdkneU4r8YJUI9PH5cWWjRvE++p5
         y08dlCf0B+ocbeHqzBCoHkD4zByO8xmAkOzCeZYpRp4RUfme3RDYtv3vmIZOUE0c3N3F
         QunwVRYg+mwCO9w9oli25h5dKO1yNxeSsIcSDnf6KSiMUmA4Wck6Uq20nWdik55iC/S/
         GdAYxHzTwtAMsveJk1OzFIsPJC1DeajzYI+vIMPhu4FWgthM8ppRxRpQ3NUSdK8AFGUd
         eLjA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuarI1e3R59nNrGpZNkpDBrJ0gVlgkyuNaUuvpaujK/U5jx6Anml
	zK+aY5KUuDjacnhlgWRfSNyOqLnG8yiHNyFsclJYzqleVSrFqEy7dotAom+3JdAIW95lv/Lv+87
	WBnfpEyPb5pi2nrYmqrCpv/VV1hCUoF+ipRpsWd5+X9qU5AFEFFPUJ/ifnpUKa0k=
X-Received: by 2002:a17:902:e48c:: with SMTP id cj12mr103011plb.146.1550058447909;
        Wed, 13 Feb 2019 03:47:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYAuchzv4JMPMgl2t/QQ7pN128WsDae4TDTtINTRuhVEUue6Vp4L4+XhvuryR4bB1/mEcEA
X-Received: by 2002:a17:902:e48c:: with SMTP id cj12mr102948plb.146.1550058447090;
        Wed, 13 Feb 2019 03:47:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550058447; cv=none;
        d=google.com; s=arc-20160816;
        b=t3dOh5LcnxFcNslJ/zLn8RIZ3qmUd1OmaJXo7oVK/HCW3VLpoB8re3JNsfNO/bNFjW
         h9uUDxrjREKjWVxTdBMPt8x9ODXNAxhdrU4zjQpMLUTmprM7dvZ/y17oEdwlfusyH+5/
         t5fNXjsQ4p/FRIf6f5EtXk6lKcQMMd5u/03EDoZTza99OQkV3qZGxU0S2CVJZEf2bgBR
         2n5jEk6RPVfDlmZ2bXbNdFeG0FCwnJpHWSwMRi0zK85Yka96Tif5lFh7c/Ju4jufTh9m
         nMumG72Flo9TWoxrgV/FhkL8c3jPtLibpoXLsnKFm57agpUteCc2lJ9yHihutqZc0tbs
         OMYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2WwpL2L07AuK20ZP2HgSWeV40opIDpYTKHlG1jeLB/8=;
        b=rcj3Oq/TYycahqvZrpQ5y1BgFQaXFqt+W0Dq5c5FYTGUGXUaXWmeux44DGJhQ+jzZS
         3ddFaSm6mifHnQ2K5m0buPvoy0JDszIk7CCKeYPn+2bI61ZV8xC2chWomPsC+G4zNNmo
         j431p6LB0UZnSw081llFNoGRETo/6xm61Csyff85uo2ZumWM3wMMxF4Z1IsRHPgoBACY
         QCiqW1p4snDew4AsTNkBq3+IlWvmjHX2/Free9z63byQN3xKaQhCEa5dNRaGaMF0WJcT
         ki9Qt7WvIWiGFNfvRQnDlVBpTHXjym+lZ2QnM6XgC53dcs1jgbqoW8nWBO8Hgkjop7yS
         QSyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u6si15364890pfb.92.2019.02.13.03.47.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 03:47:27 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4D62DABAC;
	Wed, 13 Feb 2019 11:47:25 +0000 (UTC)
Date: Wed, 13 Feb 2019 12:47:24 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Jann Horn <jannh@google.com>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mmap.2: fix description of treatment of the hint
Message-ID: <20190213114724.GA4525@dhcp22.suse.cz>
References: <20190211163203.33477-1-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211163203.33477-1-jannh@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-02-19 17:32:03, Jann Horn wrote:
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

Do we really want to be that specific? What if a future implementation
would like to ignore the mapping even if there is no colliding mapping
already? E.g. becuase of fragmentation avoidance or whatever other
reason. If we are explicit about the current implementation we might
give a receipt to userspace to depend on that behavior.

> Signed-off-by: Jann Horn <jannh@google.com>
> ---
>  man2/mmap.2 | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index fccfb9b3e..8556bbfeb 100644
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
> +If another mapping already exists there, the kernel picks a new
> +address, independent of the hint.
>  .\" Before Linux 2.6.24, the address was rounded up to the next page
>  .\" boundary; since 2.6.24, it is rounded down!
>  The address of the new mapping is returned as the result of the call.
> -- 
> 2.20.1.791.gb4d0f1c61a-goog

-- 
Michal Hocko
SUSE Labs

