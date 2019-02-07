Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EC76C282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:50:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E002D21908
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:50:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E002D21908
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E9988E001D; Thu,  7 Feb 2019 00:50:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 499158E0002; Thu,  7 Feb 2019 00:50:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 389228E001D; Thu,  7 Feb 2019 00:50:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA4A08E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 00:50:28 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f17so3846157edm.20
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 21:50:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=h3PFKSWca8vh7EmoRn0pj7yonqdG7zjk9vklSQN/fSU=;
        b=rTR6jxue6KM/Rx4ohMogzVLpuNQgXEVfiI0TKqpb3Qsk/evaWD6kBtFJWEPN6NOaiQ
         vCxixoavtUQIEGKQR41rd1kEWfyCa78vNsxKl56XxS4JqV6v5OvcKyK/Ej5l3XKqlZpm
         8LlsZ7n4+WxknOCloUe4bHkX8XAPZQn0MdVJuwpnDvhhzMjAz2pQecOVkzm3mGNaoYGR
         j6xBmTIQ3kVfKfI/pY4Aoli+poEXO1quGINjontHH1VIvJCTwildSueZO+GYHQbw4QpH
         bgdEtNHGT/iNgIO5wFB9r2Xtd0bzhpq2COBNIIjAf9Kk2hZIIiOlffl85X1ASiO4+we0
         oupw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuYItK+/8y5W4vj/OKdgknbv4WUKU/O6reAzeFJfhzoMuj9ajshh
	7UsIcLhHZjz4C1KYkfJWTSpm8sTdCn7jNuqVDgtNzhtzEFk8EaRQJ9o8NTs6PBZNQqNvZSMfWTM
	2zhpIXYEpNtjrugrAeZNU7WpHMUQD82/+ilZZwd9sBoozuIFftiHWNSxUcnQVqE8=
X-Received: by 2002:a17:906:3105:: with SMTP id 5-v6mr10273463ejx.122.1549518628514;
        Wed, 06 Feb 2019 21:50:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYFS4WKiO/4buOCKeoyimDvVVJ7nlVmgvNpEjxRI2E5XrcQ/i4DUeNVmPBuLH8g3AdG40hy
X-Received: by 2002:a17:906:3105:: with SMTP id 5-v6mr10273426ejx.122.1549518627746;
        Wed, 06 Feb 2019 21:50:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549518627; cv=none;
        d=google.com; s=arc-20160816;
        b=vMRNwEr0vpg11Hc+/gD8P4iwJ96RgXC0rjUC9KKwAZq17PDet8obWSHqbcARtFg8mv
         pE9YF99o6WBiMy0FmZgDJ9i/108D5G3gcZ9Xk/Jm/dcX8cLL8gGKlxjDOEItHV2TGwPm
         IFnSxdbCQ0m510pyj33kYrUn4Ucil4hYF4q4Bg+vU/oBCkKw0g1zkUAVpDk+b2MRaRau
         u0qrBevvUVMhWUBI3dhip0lulrwAE2O6dIoLdxd2mZWg3Fz4dzVrLZVMcTAaylCcc5Hu
         NqasAQrN2BPQ7HIsXW33qXpKc/i5ddvTcqzGe0Pw5zZlwG/zkTWFVoR9JCryIsF6mNet
         rvMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=h3PFKSWca8vh7EmoRn0pj7yonqdG7zjk9vklSQN/fSU=;
        b=d5FV9l+DRLs5gTy82ZY7skgPn/LEEK2Wuo/mtJyPfV4Yf0GLvBtCHzxspqZZb4INqK
         SZwN7XyMHeZBHZPzGTam2SaBZbuDNcEcrN0Rmo/dDJe3OH3aSzCk3j1b+ZCvBX6v5BGe
         uKkswjBXzH0Ikx2p/oOmLfqNXxghgOnwh0ZHab+YaOiOD166h9JitX/Cg1V63ETDJlFw
         PdXB+c8dKo8RDuoyhawFm7puld7GAJAsTKtbc8eGb4mTxY+n3XEwbZVpvpNQM439IEyT
         pLYNyszE2FPP+6d2hLPBL5R819VDKvI95Hssy9/bQM+kaJRlmfqWqwyJGhiK2jW9tgGk
         v0pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18si3398758eda.445.2019.02.06.21.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 21:50:27 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 28E4FAD6B;
	Thu,  7 Feb 2019 05:50:26 +0000 (UTC)
Date: Wed, 6 Feb 2019 21:50:20 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -tip 0/2] more get_user_pages mmap_sem cleanups
Message-ID: <20190207055020.2czn72rk6fwpz7nu@linux-r8p5>
Mail-Followup-To: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
References: <20190207053740.26915-1-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190207053740.26915-1-dave@stgolabs.net>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Unlike what the subject says, this is not against -tip, it applies
on today's -next.

On Wed, 06 Feb 2019, Davidlohr Bueso wrote:

>Hi,
>
>Here are two more patchlets that cleanup mmap_sem and gup abusers.
>The second is also a fixlet.
>
>Compile-tested only. Please consider for v5.1
>
>Thanks!
>
>Davidlohr Bueso (2):
>  xsk: do not use mmap_sem
>  MIPS/c-r4k: do no use mmap_sem for gup_fast()
>
> arch/mips/mm/c-r4k.c | 6 +-----
> net/xdp/xdp_umem.c   | 6 ++----
> 2 files changed, 3 insertions(+), 9 deletions(-)
>
>-- 
>2.16.4
>

