Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 494E6C31E51
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:38:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00E2220665
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:38:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S6UNpDi/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00E2220665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 905016B0003; Tue, 18 Jun 2019 23:38:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B6CB8E0002; Tue, 18 Jun 2019 23:38:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77D9B8E0001; Tue, 18 Jun 2019 23:38:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 400976B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:38:42 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d190so7450244pfa.0
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 20:38:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=X5S359TT2jtWbNMb2akLbFAUxVXw3JQDVjQ+R52t1xY=;
        b=Ia3PD0wksPvopBcgoWbRImt+88WBbg9jqvh3oMmjK9bY29336lJrlDpIbOWy+j1MMc
         YvmSiLkMVN7UzxAQRffndeUx/M1shJ+bNqJitWnP5viDlgJDpNTB5bTpW6t6uiMGHyRm
         TRdglZOCPYB8YczWJOgWMLbjoPmXo9AG+xv8kQnqzoid/zwQilK+TAAHK0PsehIAZdRG
         agJZ/EuoTLJ/BzQ36FTSyguHxyMSAf9WgadZvZRAz9HgRayR9AuOM+J6hex/TYtzMSfy
         v10uw+ImhygCWhOXDCqrd0Jq0FqlvJ2JaVXbsaPJRMt9o01pEKI2+rKAbrGDLV48s8lH
         9IGA==
X-Gm-Message-State: APjAAAUYkTJYTOTR2XONdfT4XbMJFq9sST99fdKJq0v+eH/UoAHLjwAh
	GkAV3MS0pSZOUXxq8TKRyHI/TbI3hgGnOzL5kJaMDnIjTJhw2JU9mLhSgbM1asLJ5rXLw701tpV
	Gjd6L0OTkta7SgfDQNejvTMTgLfBpi24RDtvtgJ8mfN8K6pZd/h2JOVsZYojyVt9ZIw==
X-Received: by 2002:a17:902:e282:: with SMTP id cf2mr94995741plb.301.1560915521931;
        Tue, 18 Jun 2019 20:38:41 -0700 (PDT)
X-Received: by 2002:a17:902:e282:: with SMTP id cf2mr94995698plb.301.1560915521302;
        Tue, 18 Jun 2019 20:38:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560915521; cv=none;
        d=google.com; s=arc-20160816;
        b=XH0zRZKPW7P3KudpQ7svSDmnvUidBaufgt9ogRuLLxO/zpUPgGBzgL1rAkB1AP7SBz
         4nO5xLD2etrfbXGWTdtjzStFWJ2Xn5M+tPbs2qss9DmTygQ9t/aDZuZX9hqIoPXvrMpa
         xpQ9uWSW1FaHIOiW28eyFOtKiol82uJnIBauZpCm2ogQ2ffQRs7BeBE0bR7Q5OD0Yhs4
         NfGMKl1KFsKq0u47GIjYRMHi36dR6CdpTxnq2Ayo9ILmxWng2WOklJDe+l4q53czN8ld
         2tsTjez6evfDkN0ZzS6csK7j8CaKlD60HwLDDC5GBNUyYx24JD5WFJv+mvS67is9GYQI
         xMHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=X5S359TT2jtWbNMb2akLbFAUxVXw3JQDVjQ+R52t1xY=;
        b=tBUiT9L+M2P0Yu9Rgu7Lj0If1QjNC9nVM5gYwWHURDeufNwBOk8AgzviIdpcoUh/xy
         keDSqB7kGKqPhbDLNae6PPpbROvtCCuy9iNTZQhvykp5nYV8bObPiT2djBrI7elXavnK
         KVy3zrYKe/bM3LXWsJ0S7kjUsiR4IhpWNlZjfmccE9v0keTQ17SrBSh+i/8V7voJpphn
         KC0/z3juv2oTw3km/LM5BI0A44xkWqA29PaNPfK4JMSWARjzmNtTHZi2VFOT8wzzHz4R
         eTTEAk/bi/86rj1Mlr385qLbKkXUcA/6PdsyboRa9UFdoX7kxKEPS+7jKFQjHN7lyW3h
         JSbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="S6UNpDi/";
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z28sor1871143pgk.86.2019.06.18.20.38.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 20:38:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="S6UNpDi/";
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=X5S359TT2jtWbNMb2akLbFAUxVXw3JQDVjQ+R52t1xY=;
        b=S6UNpDi/FNqJ1wWojVY5Qfy9zBjyJFliXTvsl4vQVTsMqBMwOGNUKuZEfRXJW8VKmj
         D3T4za6dyg+WLPx42iPOExedOSsY0K6XEyda6izcLy3Ki6BXqqgBz6Sn6moEc5Vzex+Q
         nabKV97AkgIinO/iCOdzvFnRvDYnLKbm49K9EawFITT4ZT373SKVZVe6+6ycX7aCEpUg
         NIz+2rX6aQig9QiekVK7api9ev7wvhV/bRWSCDX+Je5V3w8lpGebW1BgpUqv/EhOlxg+
         m5/HqAQwhqSZWLYU+oNlTIqveSGoIqg+v2mIGihx6AGxZrPC8M5eE8V5xoWeEmyEPpt7
         sK6g==
X-Google-Smtp-Source: APXvYqwnSBPFeZZjes4n8S6fPdWj8hj9VM+/z9NnV7ssCaV0ebSAiRrrqcOoX7VBgbIPkomjZ7oI3w==
X-Received: by 2002:a65:4009:: with SMTP id f9mr5756765pgp.110.1560915520951;
        Tue, 18 Jun 2019 20:38:40 -0700 (PDT)
Received: from localhost (193-116-92-108.tpgi.com.au. [193.116.92.108])
        by smtp.gmail.com with ESMTPSA id u4sm15770215pfu.26.2019.06.18.20.38.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 20:38:40 -0700 (PDT)
Date: Wed, 19 Jun 2019 13:33:36 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 4/4] mm/vmalloc: Hugepage vmalloc mappings
To: Anshuman Khandual <anshuman.khandual@arm.com>, Mark Rutland
	<mark.rutland@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
	<20190610043838.27916-4-npiggin@gmail.com>
	<20190610141036.GA16989@lakrids.cambridge.arm.com>
	<1560177786.t6c5cn5hw4.astroid@bobo.none>
	<a1747247-f4f6-ea9a-149c-07c7eb9193d8@arm.com>
In-Reply-To: <a1747247-f4f6-ea9a-149c-07c7eb9193d8@arm.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1560915007.fpyj1b1zh5.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Anshuman Khandual's on June 11, 2019 4:17 pm:
>=20
>=20
> On 06/10/2019 08:14 PM, Nicholas Piggin wrote:
>> Mark Rutland's on June 11, 2019 12:10 am:
>>> Hi,
>>>
>>> On Mon, Jun 10, 2019 at 02:38:38PM +1000, Nicholas Piggin wrote:
>>>> For platforms that define HAVE_ARCH_HUGE_VMAP, have vmap allow vmalloc=
 to
>>>> allocate huge pages and map them
>>>>
>>>> This brings dTLB misses for linux kernel tree `git diff` from 45,000 t=
o
>>>> 8,000 on a Kaby Lake KVM guest with 8MB dentry hash and mitigations=3D=
off
>>>> (performance is in the noise, under 1% difference, page tables are lik=
ely
>>>> to be well cached for this workload). Similar numbers are seen on POWE=
R9.
>>>
>>> Do you happen to know which vmalloc mappings these get used for in the
>>> above case? Where do we see vmalloc mappings that large?
>>=20
>> Large module vmalloc could be subject to huge mappings.
>>=20
>>> I'm worried as to how this would interact with the set_memory_*()
>>> functions, as on arm64 those can only operate on page-granular mappings=
.
>>> Those may need fixing up to handle huge mappings; certainly if the abov=
e
>>> is all for modules.
>>=20
>> Good point, that looks like it would break on arm64 at least. I'll
>> work on it. We may have to make this opt in beyond HUGE_VMAP.
>=20
> This is another reason we might need to have an arch opt-ins like the one
> I mentioned before.
>=20

Let's try to get the precursor stuff like page table functions and
vmalloc_to_page in this merge window, and then concentrate on the
huge vmalloc support issues after that.

Christophe points out that powerpc is likely to have a similar=20
problem which I didn't realise, so I'll re think it.

Thanks,
Nick
=

