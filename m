Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 250FDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 01:56:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2EB8222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 01:56:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="V94OLrF3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2EB8222A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 670858E0002; Wed, 13 Feb 2019 20:56:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61F558E0001; Wed, 13 Feb 2019 20:56:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 535ED8E0002; Wed, 13 Feb 2019 20:56:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2969C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 20:56:28 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id p5so4240397qtp.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:56:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3CGkQT7h8Gsjs+mnP8a/TLO+n94REOr+hRiFIimk1wY=;
        b=dGjHhCHAnkTk3ZQBOQqNF91l2vad+jBQpmELk3Fl/Qb9C25tnTVTooBdrpqWN4P+pm
         Q+plGyuDkxLGJCHfNdxGWPAjPY/ZkU2uoGV1do2DnamEW4a0XkAY/97g8PmgbqJLO5Eb
         arOo+HN4xFKPCpIEjqOMt739Ty2j+Nv5IM6MRqMCxR30JSnZ9lPHbIlLWHE5NrxH07d1
         XnpPqKgh0R5cQff4SV4AuJda++yu/a9GzpTpjFQsPDo7a/h2V3oQ6qfBU0xGhcC0Nssq
         F/ghE11dkIXQJU6rEZ5w/Vx4sU7OhSPS256fFxYlknp2EN87bIzTWxsODsHRqiSzfsOc
         rcfg==
X-Gm-Message-State: AHQUAuYE8kNgzd6uHWuwKhsRUtlASl37FvELkELe+bxUOitALTb4plF8
	isNbKWFb9bXahp8QaYA0w0H/ai1DNtbWe6foTmRTwOMtMZDTEvkISvQ58Gnl10jrlQhruo/4omT
	NbphIhPct/ca7jt0W7J4pYrFClaXzQpNx4QJrlaFgTno8SWm62VDQp2GTeHhg+hd0XP9N/3fyKQ
	Bn1ltxH2elIPSBR/wpFDWKMrwTp7Eafqv2FfDPjNGoosM51Ivt1kL2GZqIja3uQrZMUVAM+s7sS
	W6n2YNmWTolxbSYagAdevPkmFP7Ij/fPSxiLNDASzRTQQNJrgnJcaxLjLv+Fp5vSxMpCDMlGo1S
	FXbqHfjQolAFFvz4zN5zPQbm2i1iHg8s7nhEBHYaQTYJFGvJE19vAcl/l/UVQFy/eIM4NC5hj73
	3
X-Received: by 2002:a0c:eb4b:: with SMTP id c11mr956066qvq.207.1550109387954;
        Wed, 13 Feb 2019 17:56:27 -0800 (PST)
X-Received: by 2002:a0c:eb4b:: with SMTP id c11mr956048qvq.207.1550109387468;
        Wed, 13 Feb 2019 17:56:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550109387; cv=none;
        d=google.com; s=arc-20160816;
        b=Ga651DHCTAIW6fl2nnHA9rlPJonoc1gBourt244RNugBHNoLUulsjBt3T8WZajxfze
         +rOTp698G/lcwfx0X3VUWc/M61ueDXBKu51+Xt8JZ6WZnSio6BonA7aYsdyEr4B0yrKw
         DLMbvQ6IVzOX+20uuYlpVd1dC1aF2BTxm0Nown5OUJk3uI++QDc46VE/sAXb23q7kZiK
         1x8wAsbNSz1GP7V1/yvf1q8FkY5wCYSIyXCTheg8QuSuMhrQeBy5fsAV7BVkxJAE2OhJ
         rBXk6qEkyXKIXoqcyIIQbpS9czCg9M6rtHBTyTphJTldEcwAYc2kkQZw//ugXl83HeNQ
         XAjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=3CGkQT7h8Gsjs+mnP8a/TLO+n94REOr+hRiFIimk1wY=;
        b=ovrLSMpWNjwZORKDbLM5NvFlD5YxuScPp+hhXQM3lEPkL62R67pUhBSafdMZ+kiB7x
         +PMSgWzgLnlXYioP7KW9bj105kb9F4kzqhhyYGbMX6O4trt7ShlVyUizxiKAxsFv1yKA
         cZOaUmmhPWv4vcmJG1E+QMsEzYeZh008k6Dybk43sTElfEj8c4obdMkcEYF8O6FaupuH
         Qp+aEY5JVnimvHvQRbpSopjTKX6+cNEaOl+Vznq3zS9pV7XkzlKGkj8eTBoVcBXNZSKR
         N4GE1pPqNTi3g+iA1YOyD5S7lUbzHPUQu2uQj+kJ/eBX3HwXtQ/Ay9ONRmUWM19g16fP
         4LLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=V94OLrF3;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u81sor602424qki.141.2019.02.13.17.56.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 17:56:27 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=V94OLrF3;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=3CGkQT7h8Gsjs+mnP8a/TLO+n94REOr+hRiFIimk1wY=;
        b=V94OLrF3GzIKHTK8ENOjh+EcyFT4Cs0IHIonz0lHss1imeLhbyKo1NtNqOViFIBhwC
         MOpANeLX5y8Ef9b8t+RYbyDfM/URfIsoQnduvVSBSx6QZ3lD2zrnnKPWDeFnEEkgNuwE
         cZPuCFXyIOsbe1ZfXw0wN86i2n6gc8mVCsptN9BQxACkns9DJJ06RqXGqQzGMWEK7jTb
         7f5chmTyDSEMgu7sK7pVtXuNR5WEZiZhIYw3GKZmiVkBgHlrVIMNQ3x1NU0ny8leJDoU
         x9BVrPNnwc/siVUYjock6uEXkpe3ZZTHNbybs6FWS/ZHvnDsjLKt1uTXaj+lpZj8HRIg
         R8Gg==
X-Google-Smtp-Source: AHgI3IYCzJNRF4MvwhSX1BX9K5QGZEqqnvfISRM/7ZAiUwGzaHzTtHfFbzqRMWIt/8Zrl/w46VbOXA==
X-Received: by 2002:a37:b46:: with SMTP id 67mr909438qkl.161.1550109387183;
        Wed, 13 Feb 2019 17:56:27 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id a19sm56287qth.50.2019.02.13.17.56.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 17:56:26 -0800 (PST)
Subject: Re: [PATCH] kasan, slub: fix more conflicts with
 CONFIG_SLAB_FREELIST_HARDENED
To: Andrey Konovalov <andreyknvl@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 kasan-dev <kasan-dev@googlegroups.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>
References: <bf858f26ef32eb7bd24c665755b3aee4bc58d0e4.1550103861.git.andreyknvl@google.com>
 <CAAeHK+z=ft93RNx7rvq1QFr3kiOFVzBVACEFN4fL8nbEVOEXKA@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <d3cc9a82-d51c-e493-da2e-94903d5330a6@lca.pw>
Date: Wed, 13 Feb 2019 20:56:25 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAAeHK+z=ft93RNx7rvq1QFr3kiOFVzBVACEFN4fL8nbEVOEXKA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/13/19 7:27 PM, Andrey Konovalov wrote:
> On Thu, Feb 14, 2019 at 1:25 AM Andrey Konovalov <andreyknvl@google.com> wrote:
>>
>> When CONFIG_KASAN_SW_TAGS is enabled, ptr_addr might be tagged.
>> Normally, this doesn't cause any issues, as both set_freepointer()
>> and get_freepointer() are called with a pointer with the same tag.
>> However, there are some issues with CONFIG_SLUB_DEBUG code. For
>> example, when __free_slub() iterates over objects in a cache, it
>> passes untagged pointers to check_object(). check_object() in turns
>> calls get_freepointer() with an untagged pointer, which causes the
>> freepointer to be restored incorrectly.
>>
>> Add kasan_reset_tag to freelist_ptr(). Also add a detailed comment.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> 
> Reported-by: Qian Cai <cai@lca.pw>

Tested-by: Qian Cai <cai@lca.pw>

