Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFC71C0650E
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 01:09:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97EF121850
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 01:09:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Rx8pCaA3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97EF121850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 089196B0003; Thu,  4 Jul 2019 21:09:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 039338E0003; Thu,  4 Jul 2019 21:09:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6A198E0001; Thu,  4 Jul 2019 21:09:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5CB16B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 21:09:15 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id u84so994546iod.1
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 18:09:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=eyz59IIlxroI/5AObcZylVy5ugEcgCvG6BZl1gh14To=;
        b=LUmBFSi0V1m6gx9GZh+2F+GqQr4iT+mas0416BeyIZgb9jQUNlIJzBV78gt2vkC/3O
         g7QU7r4BN//BI/B5rMYQ+yoK+Uaw2EkYepD2lzzeva/VpehGg2DewczjpKDyxgFHwcuV
         wMzDylfePjv7vvDD7F28M1b/MLPXUaaD3qzdoHh/znCZsek3yVJsTdD1dIO5qMUjlDGv
         LLVwb6xgL9Rhv4awrefiqNb0cID2Dnl58/ZcvCpwSiHNCP9iBDbO09FLggHneHIfPwYF
         AUIo2U/TusLbmjP24oNCIDl6PxRRSOZxUPFBHRTrAywSy2RX+GE/roe6F0Rf9geRuisg
         GuOg==
X-Gm-Message-State: APjAAAXbJo67szOHEbkIynz8CTwgAIasGxeUuNsYWIGT4MKViUrRuD48
	g3xYQXGcWYgX4G/kjSUPQ0WKe5Phqku/ckKJ55BWor5y6QoXXk+CtNDd565vLwlEZwMSJATzPqR
	1jJXHbhK3iSHnKT4Nbbj2Rz7Nl0OuhMM185hS5Klyb7iOCD399FPS1G3gRP6v8e8gZw==
X-Received: by 2002:a02:c90d:: with SMTP id t13mr1092834jao.62.1562288955509;
        Thu, 04 Jul 2019 18:09:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwU7lWPKtyC21jxMJAy6R86+Vqbsx74zV5csOdU4LLhHzXs/4k2vNMcxM3QxhZHOUT9m1BA
X-Received: by 2002:a02:c90d:: with SMTP id t13mr1092791jao.62.1562288954638;
        Thu, 04 Jul 2019 18:09:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562288954; cv=none;
        d=google.com; s=arc-20160816;
        b=nYkYJN7zhotIhQqa8hJtkixZdDT46fJwT7s18dZcXg9J1j+x1ddnrts5Fcy4LzkKwV
         VNovAOoYtiCWn/YYAfDQ8u14tg6/d5bT2VuXY1FThq6EXO1jxedVhDqCLVs6sn1/dlYC
         /OnM07lHI1esQ2pi1Yr+I5OhSFzCeLVzQiZRaUeMtYznAvmCa0bx5zZ28QzNwsJX9Pq4
         76km+GlIXlZXr+8fEjfpLDt9FWDVfwTbKVDXpBCrLKxF9q9hCYZbcFI+ptXzC67jDSET
         60THvm4WDWlFYY2jrmDm+ue/pYo8si6LYDV882sDWBX6pWItQW7RfpLRgZX2yULHWJ1R
         mW9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=eyz59IIlxroI/5AObcZylVy5ugEcgCvG6BZl1gh14To=;
        b=w+SQkKmXb+BUafl8dwnN0lNxAmVDt/yFF+Yg6t3TYOXkuIpMSRsvaF2RuWjekDNusj
         CVmZa7PoYNo8ZE8gUWkDgEU1wVArhjoWr+VSFDOU0a9kYiJ/aVmv9Xt/sXTuNiv9vyY9
         zTzVVGFaxYyNweZKdd44jSP6ebZ7TMO0/oODpCD0r0QAUOf2kaQf+l3DX7BWtTSQcneH
         y9lBYI7dteBKy2fPQ07lo7iVY8/eJY1n97KriNEFf9ldUOAVQTsx2tdwXmYTRCAJltIq
         boZbGq0s7/ZF4fYDQPaKnwAXUl0+RjqYwj+u1l+Np2jEia9ipsxU1sMrEIh/EANTaMqH
         Aeow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Rx8pCaA3;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u26si9296475ioc.91.2019.07.04.18.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 04 Jul 2019 18:09:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Rx8pCaA3;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:Subject:Sender:
	Reply-To:Cc:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=eyz59IIlxroI/5AObcZylVy5ugEcgCvG6BZl1gh14To=; b=Rx8pCaA3ngvEF9QS1FSM86H3RU
	4/yULantxK7XgIacTgEf53fzj0aTXuJDONEnFMURxAcrkhN3SropTweasB2VvUUJeKGcAFLKOxuqB
	y0qgFj+iJnidkMBG3sNXbsaa+/3082Vi8LPGSzuDPbxHL/IY9vkxho9QaJ10IrKlGX9ze8IfHH+mo
	sK7hSaZ6uIYC2GI4Pz6/EVWH1C5iaiS6FnATYM37jdeLl1hJuqJEsMMTBnOJ/PHidNQ3qVAvL0iVh
	j79D1HGhy65YkfhRaungaMcTavle3CIcb0j5eMYeAf7n0YG+SX/Zt31rNxVATFT3H/GcRvV2SNRhF
	Luy3S9jw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjCil-0006l7-NC; Fri, 05 Jul 2019 01:09:03 +0000
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 dri-devel <dri-devel@lists.freedesktop.org>
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
Date: Thu, 4 Jul 2019 18:09:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/4/19 3:01 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-07-04-15-01 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/

I get a lot of these but don't see/know what causes them:

../scripts/Makefile.build:42: ../drivers/gpu/drm/i915/oa/Makefile: No such file or directory
make[6]: *** No rule to make target '../drivers/gpu/drm/i915/oa/Makefile'.  Stop.
../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915/oa' failed
make[5]: *** [drivers/gpu/drm/i915/oa] Error 2
../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915' failed

-- 
~Randy

