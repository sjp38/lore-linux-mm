Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8C72C06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 10:46:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CD1921479
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 10:46:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lHT1gLTx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CD1921479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 122278E0003; Tue,  2 Jul 2019 06:46:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D3B88E0001; Tue,  2 Jul 2019 06:46:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2C038E0003; Tue,  2 Jul 2019 06:46:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE80E8E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 06:46:30 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so9391122pgk.16
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 03:46:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6cBwA3P4pK6o2+nVZ7Vcd7+4pu0xybI+tIRbsYv/qE0=;
        b=gkLEhNb2EhctztzN6VWUKisXbCFdHF18u4EE7ccfZjn1BkOOorwnLy+E7Ie8z5Zp3Y
         qaU0iC5iHbTndIoVdOhse30reT8vGac2rroFWkjuwGAsl9pZ7ihP/crX/wBCq/XykdM8
         t0bw5w9Vrx+rXgYJWNTBNtD+NuJZtH0iS6INj25OR9kWd1ErovDY1w+RpPHuq5ui65bd
         l5diP66x1WYfLV/tjQQRUWYjr1+ZzQwMUh35IDBgUOQowpjd+CKQCTqXeN23LO1oD2UR
         /VERCibLBJHXOIH0WvKoQE48RUAREbv5TspgI7TCIakq1hmiLvTuaEiLeeX/KWuwOf7O
         XCDA==
X-Gm-Message-State: APjAAAUE3tnS2fQdcrFzC2v6VTyUbeKj3wfPDvVlX2AdO6JTvCZHy2bX
	Hi8MDvggnpotFdBlAvyvThrS/Y/7o0rpIEuwkMrfnunk3N24ipsIfoOHlpG6Iwqo8ptDdf4vamu
	U7YbHLAhemD5MoFiI3koDNJbH+xw8k8+0WfZSsiuPfqVceCdPSGm91aci0WM++YiHrw==
X-Received: by 2002:a17:90a:c596:: with SMTP id l22mr4957331pjt.46.1562064390334;
        Tue, 02 Jul 2019 03:46:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIZ4Wl+I0hVP2oPCOLitMK7JdKZSW5rsZRQ3eFNR9mTfaXleHO6cKwK1VkZh5zkvCpZHpt
X-Received: by 2002:a17:90a:c596:: with SMTP id l22mr4957255pjt.46.1562064389462;
        Tue, 02 Jul 2019 03:46:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562064389; cv=none;
        d=google.com; s=arc-20160816;
        b=mEwy0rbjBFcsFqhglTW7K+0cU/vB0ejlCrF0JyCJYt/ELAal8rUmHsoNqzTYsRqCpr
         uhGwdaZkHB0ehlZbUXCJ2UJoGYB4PbXqicqQ225zfAuqHjzKHYywfXtVPqGTANnvKddd
         2tDxceqqMBTAjLkPYKKUkCTPnQRWIoDsiv4hZm5USjXCIpkXpGIDVAj4TfLTOaNp6/HX
         fqDuASWOnZIxPSez4nTVKidLvRAadgLC3lHL//nigMS7IA5wDhYuTb0ksQ7gxpSs1EMC
         Ol3JyB0kKOX04wEMzcl3GcjEVV9Zhqez5FELeSrYPjQiAgYD3o5VGtkPuiiteKC9o627
         SCxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6cBwA3P4pK6o2+nVZ7Vcd7+4pu0xybI+tIRbsYv/qE0=;
        b=wm+LOAk36Kq/5tiQWBsBzz6jjye43ELMf2n/vjcClj8alIiBq78QPLZCGn/VgaHBVq
         hINOXfZHZKLbGscMuIwu/XmB0fuBDzL1EowLJWmUrdWnKBJQSCjMWeD6Jvn8R/LVrNQw
         mWm3ee3pGpOsmiFT/o1XfQb3Ovlys3RO/W467UlqGea1RZ6K93of013ikzkPLIFc8vIG
         mBuy+n62oDWi5CRv9LDY3jcUqtLpnwPsvTso8A3mEKwx6mKHpb9/Au0o7SHKUCgRQul0
         YwLfQ/sJFN7pl4PTV22PKGzge82ehGWVeRCj6P50gt1nubdRJKEQ5J5f8koMivrEgN9J
         43VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lHT1gLTx;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c1si12764962pgp.45.2019.07.02.03.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 03:46:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lHT1gLTx;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1F1912089C;
	Tue,  2 Jul 2019 10:46:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562064389;
	bh=d+I6qmH/QCTka+zqQ3WJk0DN02qfJCa2dtx6zDjiFBw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=lHT1gLTx89TB/WseAPEgeg3jwtTWQV6ml6he79iKQjNFXeKsq2Y/pY0Qx/aENG06K
	 5DpyVTVBeZpDKR0tWxu8dHhMryM4/aMUuF6qEwhyWZfjnxML3x5zfiPL6RrMGHFpNu
	 6t0z6xuHoV/H6X4hqAqpwROND3ZAIpBEhas5HSAI=
Date: Tue, 2 Jul 2019 11:46:24 +0100
From: Will Deacon <will@kernel.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Steven Price <steven.price@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linuxppc-dev@lists.ozlabs.org, Mark Rutland <mark.rutland@arm.com>,
	Will Deacon <will.deacon@arm.com>
Subject: Re: Re: [PATCH 1/3] arm64: mm: Add p?d_large() definitions
Message-ID: <20190702104623.6mgpqt5ns4sj32in@willie-the-truck>
References: <20190623094446.28722-1-npiggin@gmail.com>
 <20190623094446.28722-2-npiggin@gmail.com>
 <20190701092756.s4u5rdjr7gazvu66@willie-the-truck>
 <3d002af8-d8cd-f750-132e-12109e1e3039@arm.com>
 <20190701101510.qup3nd6vm6cbdgjv@willie-the-truck>
 <1562036522.cz5nnz6ri2.astroid@bobo.none>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562036522.cz5nnz6ri2.astroid@bobo.none>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 02, 2019 at 01:07:11PM +1000, Nicholas Piggin wrote:
> Will Deacon's on July 1, 2019 8:15 pm:
> > On Mon, Jul 01, 2019 at 11:03:51AM +0100, Steven Price wrote:
> >> On 01/07/2019 10:27, Will Deacon wrote:
> >> > On Sun, Jun 23, 2019 at 07:44:44PM +1000, Nicholas Piggin wrote:
> >> >> walk_page_range() is going to be allowed to walk page tables other than
> >> >> those of user space. For this it needs to know when it has reached a
> >> >> 'leaf' entry in the page tables. This information will be provided by the
> >> >> p?d_large() functions/macros.
> >> > 
> >> > I can't remember whether or not I asked this before, but why not call
> >> > this macro p?d_leaf() if that's what it's identifying? "Large" and "huge"
> >> > are usually synonymous, so I find this naming needlessly confusing based
> >> > on this patch in isolation.
> 
> Those page table macro names are horrible. Large, huge, leaf, wtf?
> They could do with a sensible renaming. But this series just follows
> naming that's alreay there on x86.

I realise that, and I wasn't meaning to have a go at you. Just wanted to
make my opinion clear by having a moan :)

Will

