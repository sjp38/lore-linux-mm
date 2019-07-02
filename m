Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 604C1C5B578
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 02:55:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3718216C8
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 02:55:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OQloBSmL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3718216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5427E6B0003; Mon,  1 Jul 2019 22:55:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F2C18E0003; Mon,  1 Jul 2019 22:55:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B9598E0002; Mon,  1 Jul 2019 22:55:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 062F46B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 22:55:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q11so8231626pll.22
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 19:55:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=yh72SMFSBekrHMHAzJEsEH43qcxL2exqJGEt88fMstM=;
        b=XEJSvHI3xmxrIQ4ntJYc/zQvp7bqmvdqJJ4wcHPpitgR/Y3xWWbKwbRWgV6k5tXGSD
         3DgheDE4b71mvTVpr9aSvu0RyXtExvx+XtZv99yAbr8Yheuu2uqBLKS9Y8I7PwWzaX9W
         fr8UvOenAiMEw7DFWGyVRCgJk0xzJzBe9qQ3YUAhgZCj8jv13nT1YZDGXSDTPhDVC2im
         qeu4ZRyYxcJ7zYEqpLmKi+b4E68UGWbGishyX2ImOpOn0qquPSIlJjmhrqg9cmA4THSS
         Doo6EjLI7WS5lNUekUgbHOABWcIcoBNsEOVAjTeciUQ2xrWONCcUFAhw0ZjX/KbEPvVv
         226g==
X-Gm-Message-State: APjAAAWPywl43EyIcBrUSBngeJkWURbr16o6YrCXf81Va/DURzh6NYbn
	f6Ems3e+yasoTjJ//gti/My0JjTXb/dGfIMfkQdEnc7TfEnykREkpAI9KAKe23ASXyUxGC/Tr48
	mQtAOWoQyc+E8a1j2bXxAf7/I3oabbf64P424z/FbU/LHyvN8SZh7lRAevld3Dyuc6Q==
X-Received: by 2002:a17:902:5a4c:: with SMTP id f12mr32698728plm.332.1562036133521;
        Mon, 01 Jul 2019 19:55:33 -0700 (PDT)
X-Received: by 2002:a17:902:5a4c:: with SMTP id f12mr32698674plm.332.1562036132743;
        Mon, 01 Jul 2019 19:55:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562036132; cv=none;
        d=google.com; s=arc-20160816;
        b=axEjMQ2hIUY3qOXY2AIqCOlRuGmKxQJS+4VXKB4DP9VhtLBk+7mC4eOlXnIrANQvyv
         y3oF/u1FqB42mJB4rbHn21xBYS4RUp8o9gXepBq1VQvryuATph+DEfr5QnHa467R6sPY
         YqWLLewI5/8BRyd289JSoicj4Kgo1Ihz4+WvjWvgcFzm1p+JpGJ1Y10KRAmAmcSf0FSL
         1YnmC9u5yVl3eqG5e55rg8XseTrTOA7hAAo+1+p0nyWt82ozc+CHGKFf9d0R/HdaKIUH
         aLTgAiGz9Q8qUC7EGc1ppuvpIZw8eSExuQJln8VDfwokcqv9kCPI0Ouh9K9K9LdhxcHC
         q1VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=yh72SMFSBekrHMHAzJEsEH43qcxL2exqJGEt88fMstM=;
        b=SZgO1Mdf0UH5/Vhu9yII+yuX27V8DvbGd9wMDFt6ppZWQQgUnZ1YIraC7YZixv6hiS
         yAgtMFyHB6NQg7b+0ATHbK8y/ubnTMMkC6Km76sLn3QokMg8UbttuYZPUrbkKkIuG6aG
         4k10pj+TqTPQYzyi09scwlbcDWpmy6xWIbB8yJigqKWfjthS7gGtxL2cWHX7VNETOPRX
         nig6AboohnNEBi3dJ8ChQNmJcm1xzrPKNAn6mYVMTWSxUW5JP3OgvFDLjl4bOoKAfJxi
         0vh+U4gFjTjk9+oJysfBAygyirYt/J5/yrhqG7fu/5E9+LImWHnCxWD3qWGlhND5EDIN
         5l0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OQloBSmL;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e8sor14309778plb.48.2019.07.01.19.55.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 19:55:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OQloBSmL;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=yh72SMFSBekrHMHAzJEsEH43qcxL2exqJGEt88fMstM=;
        b=OQloBSmLK7yZ68Nmhh3ZNo6BLX04mI8FD6n8AeTw37MNwj0uMNbWidDAheX5FJ/Znt
         FRzI3+hb/f6xTgs8hr0qR9TZ9OHETLisz4gXDouc1TOgihYQlbeV4GUgK1BwxOdpvGMc
         hGQj+HGKUJUHtHB1LSlUfu6YD9ajCK+Jq5Giva1slXFpNcXTmhPFtFKvyolKV+VnvwCs
         +mcnr4ORNAQD3T8DPa0Izny+94iWrnftJZ5i+foB8mwBago8ICdTU4o6YjGfQgtq2Gjs
         0fIyhWwDKZdJk7d3KDG2qYX7D/1tuC7vaBUyAchhzuMG+JtMHLXqu3nFv+R8NsJW09zS
         9omA==
X-Google-Smtp-Source: APXvYqx4btuHxQBeOFukhSzSKKwHsk18ZBVKxKzevK0qIIRUp7DmMiBws+GtDKL9X7ZhzyJrivZoIg==
X-Received: by 2002:a17:902:f204:: with SMTP id gn4mr32852271plb.3.1562036132165;
        Mon, 01 Jul 2019 19:55:32 -0700 (PDT)
Received: from localhost ([175.45.73.101])
        by smtp.gmail.com with ESMTPSA id cq4sm769147pjb.23.2019.07.01.19.55.30
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 01 Jul 2019 19:55:31 -0700 (PDT)
Date: Tue, 02 Jul 2019 12:55:12 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH v2 1/3] arm64: mm: Add p?d_large() definitions
To: "linux-mm @ kvack . org" <linux-mm@kvack.org>, Steven Price
	<steven.price@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual
	<anshuman.khandual@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Catalin Marinas <catalin.marinas@arm.com>, Christophe Leroy
	<christophe.leroy@c-s.fr>, "linux-arm-kernel @ lists . infradead . org"
	<linux-arm-kernel@lists.infradead.org>, "linuxppc-dev @ lists . ozlabs . org"
	<linuxppc-dev@lists.ozlabs.org>, Mark Rutland <mark.rutland@arm.com>,
	Will Deacon <will.deacon@arm.com>
References: <20190701064026.970-1-npiggin@gmail.com>
	<20190701064026.970-2-npiggin@gmail.com>
	<0a3e0833-908d-b7eb-e6e7-6413b2e37094@arm.com>
In-Reply-To: <0a3e0833-908d-b7eb-e6e7-6413b2e37094@arm.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1562035876.apiyxfrmrw.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Price's on July 1, 2019 7:57 pm:
> On 01/07/2019 07:40, Nicholas Piggin wrote:
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information will be provided by th=
e
>> p?d_large() functions/macros.
>>=20
>> For arm64, we already have p?d_sect() macros which we can reuse for
>> p?d_large().
>>=20
>> pud_sect() is defined as a dummy function when CONFIG_PGTABLE_LEVELS < 3
>> or CONFIG_ARM64_64K_PAGES is defined. However when the kernel is
>> configured this way then architecturally it isn't allowed to have a
>> large page that this level, and any code using these page walking macros
>> is implicitly relying on the page size/number of levels being the same a=
s
>> the kernel. So it is safe to reuse this for p?d_large() as it is an
>> architectural restriction.
>>=20
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Signed-off-by: Steven Price <steven.price@arm.com>
>=20
> Hi Nicolas,
>=20
> This appears to my patch which I originally posted as part of converting
> x86/arm64 to use a generic page walk code[1].

Hey, yeah it is, I'd intended to mark you as the author but must have
forgot to change it in git.

> I'm not sure that this
> patch makes much sense on its own, in particular it was working up to
> having a generic macro[2] which means the _large() macros could be used
> across all architectures.

It goes with this series which makes _large macros usable for archs
that define HUGE_VMAP. I posted the same thing earlier and Anshuman
noted you'd done it too so I deferred to yours (I thought it would
go via arm64 tree and that this would just allow Andrew to easily
reconcile the merge).

If your series is not going upstream this time then the changelog
probably doesn't make so much sense, so I could just send my version
to the arm64 tree.

Thanks,
Nick

=

