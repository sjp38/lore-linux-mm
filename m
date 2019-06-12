Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 776E8C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 20:56:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B0C6208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 20:56:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="YKatqYp5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B0C6208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98E596B0010; Wed, 12 Jun 2019 16:56:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 918406B0266; Wed, 12 Jun 2019 16:56:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76A8A6B0269; Wed, 12 Jun 2019 16:56:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 408996B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 16:56:37 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f9so12861278pfn.6
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:56:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=TZPBYSKEoaIkhIv00E3WuJ5aJFmWavGoQVJ9IN5iIvo=;
        b=bOtlde/cNSEKlY5w9xwzWdZrCHEOuCv8GDifrOOnhT+uNtSqe8hOYbbysFVBsO1XLC
         5F3L9zmrZqsLkuJzXGeCjtin6iwUj5+Wvk74pK8sXpB7BOcFZFRh0xBqQQEX+fLcZnpM
         PLzXZ/Wk9zInLfOoi9KRbqNqaCZCA6weOts1Qa5zc+wBcN2RheBYIJVm5qp6/mT56sSd
         N9Axbxe5QGPsmW7TDc9gM7pXwpXZCesS6TXeh4vAYHEq75r56/lEcrf/obzdSLcMOKnj
         fbBFbStUwFQe6MxLiPyr1orqTkJse1OwnosXRcA5x37qriuPOIEDUUOkrl3Y+xTUhULa
         Qhkg==
X-Gm-Message-State: APjAAAUHMiA01AcEvvnvBf3DLc5sGGrJICBTr5nQBV8US0jrKGUGsg+B
	k3N9diWl4yAYuT7lTZBQqKCY1UOaVcc0whGi8jIn7r6xgPFY0Kv/KKGMF8scz7QHA80wi1rgEx1
	M2Vi6+ubUR6pvKfzdg4pb/v12zM2HgZj6p9K8bPZp2z0bqeyCyf7Re+ze6VwyFNQFqQ==
X-Received: by 2002:a63:1c59:: with SMTP id c25mr994289pgm.395.1560372996705;
        Wed, 12 Jun 2019 13:56:36 -0700 (PDT)
X-Received: by 2002:a63:1c59:: with SMTP id c25mr994254pgm.395.1560372995791;
        Wed, 12 Jun 2019 13:56:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560372995; cv=none;
        d=google.com; s=arc-20160816;
        b=sHUgKMnC8FWusf6VTfFEItH7eI9lk+CCU5ZIMmxTVtyx9pK+baYG5fNripOD6nmQRj
         5XHW+dp1hSuUK5Qz7qVtrSK+wZJCj7Px8Le3XUP0mLH16lJfi76jWZ2GXHqeo4BiW9PR
         lX2xlWDL02CKbyF+5Xa46UorOdOqh2KAhev6qdcC7ryXTOKff/aNyGlhKAL1q9FmTrJ3
         fnxmgWoR5uAHQCvat04fIoIHUoJdvqXyr7vdSYP+GQBFkhCBovVph+qFR5fcsjjDCg6M
         trrgfqmZih5RuIsv+8TUtg5eIOgljczeQ0t8kG1hsj8Gcp6hq9f3finz9jzZaJ+gTI3v
         i/aQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=TZPBYSKEoaIkhIv00E3WuJ5aJFmWavGoQVJ9IN5iIvo=;
        b=wGJFwSL2HKm1udJQbZuTtltsKSpRJSH7ad+gCukRLfUqDyfOia8+6Llcn60kllcERR
         vysxoJh7zKJRKA/rAMYNhqqDwWzLy/lRSiCCE9dnyPzPMi201iuB+w2hG4QSh3RqQzDx
         bFwikxa17Eq0fmRKkLm6q4+RDD2Z5W3UKIlWqEwz0YuS5houGRH1cAhGEmGiFNhYZg4a
         bMThOdRHpfGDoES7u9T/Gw514+ACJyOljNtuOwP98K3qiMUoMNhMzBFbh/V+jw3YLLW1
         einqgLdbusQEqN5oZevb/nr+SujvyKJgzr+iN84zZ3+Rh6yvi4+iLoAFH00tp6s8Gmro
         LmKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=YKatqYp5;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9sor1116577pfd.44.2019.06.12.13.56.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 13:56:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=YKatqYp5;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=TZPBYSKEoaIkhIv00E3WuJ5aJFmWavGoQVJ9IN5iIvo=;
        b=YKatqYp5ZMD0rZsPMDq0to0PJDreG1XUyrx5SqWGPFgdgJtrZRf5AOIxLF1RFphdWH
         R8Uycb+uWLqjH30x5HeS9diZaO6zEKBi4ehrFWwTQQhEoyWIgNqsqXzSVDTswGRL/9KD
         uhKfahNauFol7O1XFQvxQp5RulEWOEW7iex6oysSu++JNYIgkrqn3WOcSrgDk5zaBXNp
         8B+4btiQ/WZSa7P4mcOyuxUL08dr8X75WN0f9Llk7Bg6kYQ1G/dW5uqsTcyfJCabZyCo
         CSzxOII00f5vEnofzolLz3aqRMf0Y2IeopHbP2PjiAMHgx7OfqBg8uf57PLTsF74jSYO
         KVmQ==
X-Google-Smtp-Source: APXvYqxo/ItMtB3OUs84fhqaf0UCPf/u6DxMcudVwkkrFpAqbneRAxpY8FuZIOMzxuIx2mCUlvJvAg==
X-Received: by 2002:aa7:90ce:: with SMTP id k14mr89000454pfk.239.1560372995458;
        Wed, 12 Jun 2019 13:56:35 -0700 (PDT)
Received: from ?IPv6:2601:646:c200:1ef2:e92e:2d95:2c68:42e6? ([2601:646:c200:1ef2:e92e:2d95:2c68:42e6])
        by smtp.gmail.com with ESMTPSA id v18sm455164pfg.182.2019.06.12.13.56.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 13:56:34 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM secrets
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <3cd533c1-3f18-a84f-fbb2-264751ed3eeb@intel.com>
Date: Wed, 12 Jun 2019 13:56:31 -0700
Cc: Marius Hillenbrand <mhillenb@amazon.de>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com,
 linux-mm@kvack.org, Alexander Graf <graf@amazon.de>,
 David Woodhouse <dwmw@amazon.co.uk>,
 the arch/x86 maintainers <x86@kernel.org>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <FD3482AC-3FB0-41DE-9347-5BD7C3DE8B11@amacapital.net>
References: <20190612170834.14855-1-mhillenb@amazon.de> <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com> <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net> <3cd533c1-3f18-a84f-fbb2-264751ed3eeb@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000039, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 12, 2019, at 1:41 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
> On 6/12/19 1:27 PM, Andy Lutomirski wrote:
>>> We've discussed having per-cpu page tables where a given PGD is
>>> only in use from one CPU at a time.  I *think* this scheme still
>>> works in such a case, it just adds one more PGD entry that would
>>> have to context-switched.
>> Fair warning: Linus is on record as absolutely hating this idea. He
>> might change his mind, but it=E2=80=99s an uphill battle.
>=20
> Just to be clear, are you referring to the per-cpu PGDs, or to this
> patch set with a per-mm kernel area?

per-CPU PGDs=

