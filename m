Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B528FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 20:33:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 430A5217F5
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 20:33:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="rVH+m+xL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 430A5217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C4DE6B0278; Thu, 28 Mar 2019 16:33:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 876706B027A; Thu, 28 Mar 2019 16:33:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78B7B6B027B; Thu, 28 Mar 2019 16:33:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38AE86B0278
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:33:45 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id t5so17157333pfh.18
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 13:33:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=o+a/SAiZ8f2SWEWLbL14a/AHxKB3R3uRQE9ibApvFzo=;
        b=l9iZIH3UDmsFkelcDVDytiq+l+9UpeWlhThaHqx0aRM2KpWVhdXMRibu/NbcqaP5qp
         pPFM3NlsfJG30+yQKQNTLzQUkVKQqBo8k9y5TFeUCkTM+C/zbf8z/wGZ4hH/K5RtNl4Y
         R+XIpJTXleKX+rrq4lxJada+9r2W3hIeQfEbKVhJdbDR4DWiV5e0N4eyEuG/jZF0WqZK
         6Ki2f/kT2PZEeJjrKbFM2L9jvIcSQGISBtrpMiHSSi7V6+CIjnmvtfaDz/bcc7Wn3ZTw
         WRZQjUvLLuyot3lElIxdn5F0M4uNDrZUru6JGp9zdfGjcnBhyalcy8vyUMdH7h3Fm+59
         JCGA==
X-Gm-Message-State: APjAAAV1rvsiI6vx0CfPcgjXavknGCtUQyAIbg6M8268inwFkEHmgYXu
	Up5jShtbmU7c3Qzy4ZL2U0I431aOz8N205MFqxr4AlJCHR/iv3d1geXQE0bYcOE1GnxMpylNTO/
	wkuHSyBHhlruhI/TjpVsCWPbDB79ho2NBMi3h4pnedl/yL4IsFNkP8SvyJ6SJ0W6Amw==
X-Received: by 2002:a17:902:2f:: with SMTP id 44mr45019532pla.139.1553805224820;
        Thu, 28 Mar 2019 13:33:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqza2tYz8F5EJnOFwTPFx1WrwQhHm98uXojn82+B5KFrNk925Btd/JjfScyZnpoqq/KRz1v6
X-Received: by 2002:a17:902:2f:: with SMTP id 44mr45019475pla.139.1553805224095;
        Thu, 28 Mar 2019 13:33:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553805224; cv=none;
        d=google.com; s=arc-20160816;
        b=Z/JcEQEkmw5usQnyYO16PeVINJOSjbaCshhNNIspn1E2jGhpZIlrXqUUfT35Oz86+a
         pa+VOruuRNucBRmequ98C1glKJjY7x7klq8rqPZPfyYYbILxu2krRU8VRL5/vULpxaZD
         JQqN/t8GJzX4knVTtOB7y0IcmkiZ8nNnLOThVhlSYOtcJQMLjmww20LJ5qgTlSv/9IUG
         rGxi+1kIMys2Xn+s1d6mvzW9AB+IQIMcZ9hfq1ohPdkzSsBwfu8mc+BNcjAavaTJ60cX
         WhDREyPmD/6+STppnRTEAJNAklvB29XbEh3i1ckODmuZ00m1APklApNm2k9Jzfx0Ky0Y
         1/xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=o+a/SAiZ8f2SWEWLbL14a/AHxKB3R3uRQE9ibApvFzo=;
        b=ZAbudHSry2/FlwVVnFFBZJfsJqvXMqeqPEQ2cENqIu9KadBhNvthVSOAhyearhmcbQ
         a3+e4XrJ2cJxn/S/Y54qXl3r43QZ9teIHY5be0o2b5C0OGdg4cwDuq7jiL7X8u4Tzj/p
         l4Bv9cEmQi8T4Q1puvnKSpjC5FvJRRY2i5QvhvFH+uVCLHaKK+FJltKIJhZaPejSLsDX
         uYUdQaCdQZZIK1PjWZ1HI6b2tQkE7sQYdICzCpDQHThPlZpzyrvSkWi30xOYp4BbRwvB
         nkwwloLIjFEM43ItMTUH9hD3rG9zn3UT5W7w+sRZdpwXHdoUgJCOwjaU3IWlvl/F7d9F
         fszA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rVH+m+xL;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id l13si61128pgp.571.2019.03.28.13.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 13:33:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rVH+m+xL;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d2fa50002>; Thu, 28 Mar 2019 13:33:41 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 13:33:43 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 13:33:43 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 20:33:43 +0000
Subject: Re: [PATCH v2 01/11] mm/hmm: select mmu notifier when selecting HMM
To: <jglisse@redhat.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>, Dan Williams
	<dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-2-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <d4889f44-0cc5-3ef6-deeb-7302c93c1f90@nvidia.com>
Date: Thu, 28 Mar 2019 13:33:42 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190325144011.10560-2-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553805221; bh=o+a/SAiZ8f2SWEWLbL14a/AHxKB3R3uRQE9ibApvFzo=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=rVH+m+xL2BxNvS6qdiawWzdzngrp29z3aMootYghbquzyuTBuiD0uULk7EcEdiSxC
	 AgPVAWB3MSZxyWqYw/gZuFZrraF7vPcNztWTNwyqRm2NC1H8XVs+OYVhlgIj1sLUO0
	 pAbOqrC0xQOMtYZ0srtx3N1GYtooxq6lsFekMrXYmh/rcBNNJgVTG8W5qhnQtZ+DSE
	 q+9//0amEirw0w69sh2gmn1qMlahnuCScS28MQNd1DSfAeM0GDe4asvNuU3lzzs5Mq
	 PZWb5QgvI6PgWgrQVvBA3AF0dxhscVxvV5r0svpUA5+xM8ElkZjty0CNabpUUOSXL+
	 IsSeRPIxnErHg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> To avoid random config build issue, select mmu notifier when HMM is
> selected. In any cases when HMM get selected it will be by users that
> will also wants the mmu notifier.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Acked-by: Balbir Singh <bsingharora@gmail.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> ---
>  mm/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 25c71eb8a7db..0d2944278d80 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -694,6 +694,7 @@ config DEV_PAGEMAP_OPS
> =20
>  config HMM
>  	bool
> +	select MMU_NOTIFIER
>  	select MIGRATE_VMA_HELPER
> =20
>  config HMM_MIRROR
>=20

Yes, this is a good move, given that MMU notifiers are completely,
indispensably part of the HMM design and implementation.

The alternative would also work, but it's not quite as good. I'm
listing it in order to forestall any debate:=20

  config HMM
  	bool
 +	depends on MMU_NOTIFIER
  	select MIGRATE_VMA_HELPER

...and "depends on" versus "select" is always a subtle question. But in
this case, I'd say that if someone wants HMM, there's no advantage in
making them know that they must first ensure MMU_NOTIFIER is enabled.
After poking around a bit I don't see any obvious downsides either.

However, given that you're making this change, in order to avoid odd
redundancy, you should also do this:

diff --git a/mm/Kconfig b/mm/Kconfig
index 0d2944278d80..2e6d24d783f7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -700,7 +700,6 @@ config HMM
 config HMM_MIRROR
        bool "HMM mirror CPU page table into a device page table"
        depends on ARCH_HAS_HMM
-       select MMU_NOTIFIER
        select HMM
        help
          Select HMM_MIRROR if you want to mirror range of the CPU page tab=
le of a


thanks,
--=20
John Hubbard
NVIDIA

