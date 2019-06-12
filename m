Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F006C468B0
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 20:27:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2A3120866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 20:27:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="dosYpfHy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2A3120866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 400C36B0269; Wed, 12 Jun 2019 16:27:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B0566B026A; Wed, 12 Jun 2019 16:27:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A00F6B026B; Wed, 12 Jun 2019 16:27:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA81D6B0269
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 16:27:08 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t64so10394301pgt.8
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:27:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=wQSIjj1uz1dtSEsQ8et37d1oi55PupCcmG/N44FomHg=;
        b=HgrHWyYuEyYIUMZ0/eZzDzdf93PS/sOLbr0k389uPVRPwBSXZwBYeYpOlE9Lx86ci1
         3wQACwYxIzUATkPyQVXd18J1hcDrs1RMbYLgij/BToL8U9YZkyXBxfbmD43Hv7QUo7A5
         Epib/AmdjiO/wR2t00+pyJQCWUW6o5oqYweDMBfCyPIRmfz21kKexZy137gaM3MhoYxb
         XP+jkuVRW+5I97YsB2QowUO+9JbEGWDjNuNYgGXHkqeub6g80jRXgYIxC9yO2xcf4xAx
         I19EKX5tPCpXZHN8A8+m9asFaLQMSVKfeBJuyx2UxMJoR8mVwk+uuheQNkQw+Q7RQ/o2
         WLjQ==
X-Gm-Message-State: APjAAAVkoQuEEvbyyLmbN8e85+MN/P1Mjfs7EASPLCLi3239uUARWXkp
	yzh2+YrcG/64UX1k9MQniHrEvkeUsunahJwrHZoX+akDMILm1AeHr5KnUnh0E6oqdx5e3bc5ZBz
	vn6g/3eY3WALjdvAVwVvLHe1rRaKm+nBV4a/MxbJSyZWjzbBrZ+Cf2m3vXebt3Jh7ww==
X-Received: by 2002:a17:90a:bb01:: with SMTP id u1mr115293pjr.92.1560371228580;
        Wed, 12 Jun 2019 13:27:08 -0700 (PDT)
X-Received: by 2002:a17:90a:bb01:: with SMTP id u1mr115249pjr.92.1560371227946;
        Wed, 12 Jun 2019 13:27:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560371227; cv=none;
        d=google.com; s=arc-20160816;
        b=UNqdAVJdulcGXpkXc9MeJvlUTNpsULf9QJ0Ufhnsff7iR6XeAZ79QHk98FyUKS7BHP
         9YkBk/aQX3UfmNyGgkYegD1LE3/3gxDvqu/XPa5+zVks7ifP3F+KwCjXN3XA5smz7Bpt
         CbmhWGHETwXLOC2U9SmbZffNudkovH6jDmN6FXc3ZY8fH/dk8nzkcIGpEVJPIdSW5zlx
         MaaTExLMDsuouh8Kz7jcJxv0X7JUljfIoVaje8J9+VFvxlko5qdKaE96SKqEI5rCi+n7
         6UUrhbzHUEOfr1vT8/BljfWrd8IZFWbuwC1lnLF8KJr6a6s+3Q3SzDoEytmj7BVTgIjg
         51WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=wQSIjj1uz1dtSEsQ8et37d1oi55PupCcmG/N44FomHg=;
        b=blj/7/6KnDwO5sSR0rHEJ2nbRXu1bq8kqShkFQVF8Rbda3iUihHACQaSiJtE75kMxR
         JTxrwBuE61oONv2EHhRXhxy2vFnQSSr1Rxi57IRQ1VyL/DQ3PKv3QvrYSE3BIzZu81kd
         vtTgqJrhO9l1KqgY/R3fiBezLJz7Uy/oT0lXPYLpaaBb5tstbSEuxSwDOPCOrAT6Omth
         JowAfBC7WViUkPXAq9DxdVorOfjXGq8vzXdMYFlnxsENUX698nuGQoz4++8YCz/VZCfb
         u7m8NgF/KY5EMV1fIov2s207asIL1uCu54OyBXY0rTRZFHZk1diaCMj+AsjVLjkLpBV7
         7diw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=dosYpfHy;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2sor690771pll.35.2019.06.12.13.27.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 13:27:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=dosYpfHy;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=wQSIjj1uz1dtSEsQ8et37d1oi55PupCcmG/N44FomHg=;
        b=dosYpfHyXQnOIHiak4h4vT7DtMsiDthIYDzQhi40A07vw+2UujEnaY2h1t/znWnsFr
         quz6BW2DabQNadx+sDAO2O97r0jLz2nrIHQjYC9CHjraeetUerSWSoTLviI8HPycXoZZ
         EhrCJYG29dvXZxU6C2YJtgjuh1T7f1raROHKgUW3XwqaYfDhqi2gu8n47/JClJNSwZFK
         Cy50WsRvmzOO0Wm82pvIO18xzLdWmPQlSHYbVv4RpfrfhpGtr7WHpa/8Vj6GKkjUbi4J
         I1Lys/X6FYmMf0ochoRNkJNNr7r0V1GDgqmSXn2lH+6rIIfw12YCjQ4hkbB9ywHjoOzK
         tg3A==
X-Google-Smtp-Source: APXvYqz0dHD5fq+ketC5HFnEXuKjsrvf/JQonYxBDCeP2VEnkY8AJZcbmbqYowRApnU+lnXqwECpog==
X-Received: by 2002:a17:902:760f:: with SMTP id k15mr58881187pll.125.1560371227543;
        Wed, 12 Jun 2019 13:27:07 -0700 (PDT)
Received: from ?IPv6:2601:646:c200:1ef2:e92e:2d95:2c68:42e6? ([2601:646:c200:1ef2:e92e:2d95:2c68:42e6])
        by smtp.gmail.com with ESMTPSA id m1sm267870pjv.22.2019.06.12.13.27.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 13:27:06 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM secrets
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
Date: Wed, 12 Jun 2019 13:27:04 -0700
Cc: Marius Hillenbrand <mhillenb@amazon.de>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com,
 linux-mm@kvack.org, Alexander Graf <graf@amazon.de>,
 David Woodhouse <dwmw@amazon.co.uk>,
 the arch/x86 maintainers <x86@kernel.org>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
References: <20190612170834.14855-1-mhillenb@amazon.de> <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 12, 2019, at 12:55 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
>> On 6/12/19 10:08 AM, Marius Hillenbrand wrote:
>> This patch series proposes to introduce a region for what we call
>> process-local memory into the kernel's virtual address space.=20
>=20
> It might be fun to cc some x86 folks on this series.  They might have
> some relevant opinions. ;)
>=20
> A few high-level questions:
>=20
> Why go to all this trouble to hide guest state like registers if all the
> guest data itself is still mapped?
>=20
> Where's the context-switching code?  Did I just miss it?
>=20
> We've discussed having per-cpu page tables where a given PGD is only in
> use from one CPU at a time.  I *think* this scheme still works in such a
> case, it just adds one more PGD entry that would have to context-switched.=


Fair warning: Linus is on record as absolutely hating this idea. He might ch=
ange his mind, but it=E2=80=99s an uphill battle.=

