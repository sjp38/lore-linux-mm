Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39141C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 11:48:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5549020659
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 11:48:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=protonmail.com header.i=@protonmail.com header.b="xGmN2FoT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5549020659
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=protonmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E03866B0003; Thu, 18 Jul 2019 07:48:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8CE06B0005; Thu, 18 Jul 2019 07:48:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2D098E0001; Thu, 18 Jul 2019 07:48:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72F976B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 07:48:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so19823825edt.4
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 04:48:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:dkim-signature:to:from:cc:reply-to:subject
         :message-id:in-reply-to:references:feedback-id:mime-version
         :content-transfer-encoding;
        bh=cL2SsivVQdCHoOaitMMq0EG0ZsqsvmEA1RMpNbp8a5w=;
        b=K91SrPAxFyQIBbWX6jqXsivR9aeFFPBcSYIg7a81NmxtmdT2dkGrKvAk4Ad4WLycP0
         /mIPxuz4w21lAuWvFPMqcfHxKRAIp+ntlDnqaxD4PwHp0r3Ih8pXUhauTya5QGOklTH3
         SiBZcptnfLnFDd82Ig9mBrvNAlmJeJgPKuMX+0iDjHGzLKumOauEN4ESriubBiQ0NA+D
         hW5FtjjMKAPmWDMAL67YKzNpNRpGn1tjKTsrm8PMeJdicSLmskgOsqhc/sA6S31tLoXC
         iflcMDYCgD7UWy1bJMA9JbjxKpxFWpspKSGn9bI+h1EycIwwG0nRGusUjWlHIa2l2BB/
         Kdwg==
X-Gm-Message-State: APjAAAWaEQaQo0y7lgDAPRoxkCDb0J9M/ZFlS5sroUTgrUNFitkp7gQd
	Ri/iy5JG8x8Yh0aVtO/u6zhIXNQwKN3xHiQzB8VQCAMT9hIq1gPE4szTDTE911Yu+FdRzuH4/29
	dGwBf8tGKqGIXfQePmPCeXZHY+RgC1YUiSzE2vyX4FkXoQT/5/5H327dlQGuamc1+kg==
X-Received: by 2002:a17:906:5409:: with SMTP id q9mr36326633ejo.209.1563450497918;
        Thu, 18 Jul 2019 04:48:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvlP+Ec8a8d5vvtfMkwouwfex1+9XvFrsTIccSPB66dYvE4h3EQzl+//gxYNDfmJvKJLic
X-Received: by 2002:a17:906:5409:: with SMTP id q9mr36326595ejo.209.1563450497172;
        Thu, 18 Jul 2019 04:48:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563450497; cv=none;
        d=google.com; s=arc-20160816;
        b=HJ5NHsnyPxsLqMAS6HJA3bdM1EF9+1R5omSwBGoUvmQifSCvHD+ZL5I+Z0HLFayDR8
         1waw5vXtQFbpzJzYM4edOTwHfxEAsg4ZUoPpVQ81ihbvurC+HZ5lV7iIP6vyzTUzK+LZ
         IKjk74UrTVmuS7wFPQ2s/9qB7v50HxxKNtsVEvnZqy3HX4R4LmUn/ePLSI/5snyWxYjJ
         OqLnSSet/Ko1MekxwYkpkNtARMRaMMc2xXy/1Wdgzhuk7lypFc3dVBKd82gmhQ4yYwKg
         SBFENCZpUxP2zCBd7hkWVQeh5U8/RTO4tQ4DxHsBo2qcbn6sV962d28eThGlhs9vBBom
         8Rvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:feedback-id:references
         :in-reply-to:message-id:subject:reply-to:cc:from:to:dkim-signature
         :date;
        bh=cL2SsivVQdCHoOaitMMq0EG0ZsqsvmEA1RMpNbp8a5w=;
        b=qHJ32XnFagnuXzL4yQ4tNWep1w+QOx3rGH4zPgTcoG0s8lD0d7Rn25qddHCXqa/DaW
         QEAcWcWM4Y/CB2NJUGzglSJ3Xrcp+iLy8Xj0oYy+IqU3AdVu18G3W9TMbVKvp10o1hEG
         e64R4GGU8BmDsfLj4Xjm5cL0p9eU3gUNLZdt3KbvGhHQpkFiILHn4gf7zS/Tzqt9WAa/
         xqgOMPtrSMxq8u0v4F+vEw+GQJr/lPN80o6vl8BbTdMYphBoN71OapeZOIJmeyKm2vHN
         a3yEUbJMGF6Ak9lznQbifsFt6OItdl/FWu6OMQ/BnSlM79BNe3NVn4lvkgwP0UlRRwUF
         Exhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=xGmN2FoT;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.130 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Received: from mail-40130.protonmail.ch (mail-40130.protonmail.ch. [185.70.40.130])
        by mx.google.com with ESMTPS id f35si102224edd.350.2019.07.18.04.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 04:48:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.130 as permitted sender) client-ip=185.70.40.130;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=xGmN2FoT;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.130 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Date: Thu, 18 Jul 2019 11:48:10 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=default; t=1563450496;
	bh=cL2SsivVQdCHoOaitMMq0EG0ZsqsvmEA1RMpNbp8a5w=;
	h=Date:To:From:Cc:Reply-To:Subject:In-Reply-To:References:
	 Feedback-ID:From;
	b=xGmN2FoTM80n8Kbmd039VEpwz9ogj1YYaAln2ycHKcSQ18VtsSkUgondVcR+5Qg5x
	 lj1Bs2Je2yK1HnN5EaTR+khBj/qDkS0ydSMmpfwPFeMk8hjbkAFnDKMRRwP+KeVTYQ
	 IURslDlJrrpVZUO3Fy8owTCAqmJ5hmCyivsAFItI=
To: Mel Gorman <mgorman@techsingularity.net>
From: howaboutsynergy@protonmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Reply-To: howaboutsynergy@protonmail.com
Subject: Re: [PATCH] mm: compaction: Avoid 100% CPU usage during compaction when a task is killed
Message-ID: <Wnnv8a76Tvw9MytP99VFfepO4X71QaFWTMyYNrCv1KvQrfDitFfdgbYvH8ibLZ9b1oe_dpPfDdQ1I2wwayzXkRJiYf1fnFOx6sC6udVFveE=@protonmail.com>
In-Reply-To: <20190718085708.GE24383@techsingularity.net>
References: <20190718085708.GE24383@techsingularity.net>
Feedback-ID: cNV1IIhYZ3vPN2m1zihrGlihbXC6JOgZ5ekTcEurWYhfLPyLhpq0qxICavacolSJ7w0W_XBloqfdO_txKTblOQ==:Ext:ProtonMail
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Thursday, July 18, 2019 10:57 AM, Mel Gorman <mgorman@techsingularity.ne=
t> wrote:

> "howaboutsynergy" reported via kernel buzilla number 204165 that
<SNIP>

> I haven't included a Reported-and-tested-by as the reporters real name
> is unknown but this was caught and repaired due to their testing and
> tracing. If they want a tag added then hopefully they'll say so before
> this gets merged.
>
nope, don't want :)

Thanks a lot for your work, time, understanding-how-things-work and concise=
ness(level over 9000), Mel Gorman. Much appreciated, enjoyed the read and h=
appy to see this fixed! Hooray!

Best of luck.
Cheers!

