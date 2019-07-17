Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BDB1C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 08:04:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 032BE217D9
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 08:04:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="dy2fEZZc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 032BE217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F8CB6B0006; Wed, 17 Jul 2019 04:04:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AA058E0003; Wed, 17 Jul 2019 04:04:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 799568E0001; Wed, 17 Jul 2019 04:04:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4199A6B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:04:30 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y9so11650771plp.12
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 01:04:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=a/uLJPoZ87Fx3PgnBNv0eSPgO1nYx3akKRZuuGtEZ4w=;
        b=YPH+XeK1ugSaF+i241K4FXzSDUAC7EDcb4UHJJKi+tzLnyLaxsUx2dS9IBWxVchaxh
         rqkqXF7zlgbNCR0/I4i7/JIc6iC7yk7VnNQCOaN3IlDiQsSd3Wq8ENQo00VyewtfsDaW
         eCxMIGYpzStpzv3cPcOV0f7a1HtNiP329BlRWzMqInF91ZLUNpjO6+PjSCXuDKRnhXRQ
         oatVfODI58ClSMx+i4KIbagb+rqnovD37MSXjkbMueA9kPJiXPv9CtPjmfMTUacnrPpF
         7zFtTatycGhmQS5KqentSywxh16mWSKlAgcp8ByM/HZCNqcSZ0h6HvB0w3oMAI+ZJ3/d
         ajqA==
X-Gm-Message-State: APjAAAVVwQP57TZ661Y08bPRN0l+lQU3ty3uCwsI/S/OBegnKgBE8INR
	9LRsly9aiGKDPzwmjIDUbLpbSDye576tPMfbdNrx7HrHjXLK2j7v41PHSipCL4XxUZkPI4FldF/
	HWWcnc71WmpzPCbGOMIkaLPxS4Wp4dJbVeDlLSCxcMdkmR/zjVcijfEfbIYdWiaujSg==
X-Received: by 2002:a17:90a:3aed:: with SMTP id b100mr42835426pjc.63.1563350669834;
        Wed, 17 Jul 2019 01:04:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMc/S93166+K4uyT9RaRsIHncRqiS8hYCg6T91RHU1FkBMOOTEiKAzRCkqKSwLo2NDm+6j
X-Received: by 2002:a17:90a:3aed:: with SMTP id b100mr42835382pjc.63.1563350669139;
        Wed, 17 Jul 2019 01:04:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563350669; cv=none;
        d=google.com; s=arc-20160816;
        b=0+BlSepzIwrSOu7H8/EuclToV0yhThySFdDiweme0GTtczpJD0KIxTd31ORAMHfcwx
         zCU6eA/VC2DBLYdEggQ3MKZztRyZqJb7BFbz7HlAykZZazo1+I6XOpDHJRz+yBtaoiAk
         vgJAbUXnxYa0gaMmLKOeU1EVaUz4kQKslqrdaRVxulVpaH9DCz5K6o49kxLF4I+nLHFf
         C8wZzUG7hcslLe9D1TSbhSgQqXwCQ/HtAhsDdSAVviYIeBfUrkFjc/fdoHqh9B7IgNMq
         du9xf/bCwrjx4WCKOE/BkQvmL2c3zKlnJrZhEocM3Jyk/WWvaBKc5W7b0/At5Lnw/RRq
         4GwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=a/uLJPoZ87Fx3PgnBNv0eSPgO1nYx3akKRZuuGtEZ4w=;
        b=08mD3dPpoGmczKfgGLOrrr8kWLLULvphT8geGELd1gO3tvc7kZVMRaRVScGeIixlFx
         82pxyHfXJqww8xTg+xvcFPhv/9zdtPB78cJrtPlZfXnZcsY9SYFSGPxlsktqREwxeoNI
         xKuNIPrHvosY/6wlPecXdTwRbjtl4P73rJuSTJe6mCUkVX2kDEGRz4GOQ3b2b0uvZRdS
         ppXusWLqNI4bnIWdCowraoykNBmx6Ydhs40nK8I4FzkmYvh6w+0zkqeOQ3LpX9YjqHKz
         h1M+zN+FhhLAjze7zqZFVKmk/a+0Jf4WpPIfwIsLr9vacMGOosFyXuuP0SqZMVNicpds
         agZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=dy2fEZZc;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id b5si21760368pjo.26.2019.07.17.01.04.28
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Jul 2019 01:04:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=dy2fEZZc;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45pVCt0PSTz9s3Z;
	Wed, 17 Jul 2019 18:04:26 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1563350666;
	bh=a/uLJPoZ87Fx3PgnBNv0eSPgO1nYx3akKRZuuGtEZ4w=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=dy2fEZZcIJo2wBbj48S2iAkFUtNWMBRzr2Qk5c31yIes15jKezc0d19Yn2/nRunzV
	 T1+S0H7OR7aHrKKKfbAOEZM2j9tzSMuDCIAzKPvxAZKfzsiMCFMHk4HObiMN90K8N+
	 S8Uu9ixLhg6VfIcwPaPs9hID7D1mng/bMyfjmUF50Q/4MF5SRul/Ql70xwsXlxrMUN
	 pXuNzIErv4teLLvuAL79D7vCZf08q837HJVZ56KudCeDZWAl9UxX4SGlMni0xO391k
	 NX51YN+3PNwSo2vBOl3v7z/Ti6wP/C7Std+ngJLmUAHSm68Lr+BQtueMxk9Xcqc9JM
	 PbRWBpf7N/1dg==
Date: Wed, 17 Jul 2019 18:04:24 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org
Subject: Re: mmotm 2019-07-16-17-14 uploaded
Message-ID: <20190717180424.320fecea@canb.auug.org.au>
In-Reply-To: <072ca048-493c-a079-f931-17517663bc09@infradead.org>
References: <20190717001534.83sL1%akpm@linux-foundation.org>
	<8165e113-6da1-c4c0-69eb-37b2d63ceed9@infradead.org>
	<20190717143830.7f7c3097@canb.auug.org.au>
	<a9d0f937-ef61-1d25-f539-96a20b7f8037@infradead.org>
	<072ca048-493c-a079-f931-17517663bc09@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/0xDDOA42emBhMWNDZGG8_SB"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/0xDDOA42emBhMWNDZGG8_SB
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Randy,

On Tue, 16 Jul 2019 23:21:48 -0700 Randy Dunlap <rdunlap@infradead.org> wro=
te:
>
> drivers/dma-buf/dma-buf.c:
> <<<<<<< HEAD
> =3D=3D=3D=3D=3D=3D=3D
> #include <linux/pseudo_fs.h>
> >>>>>>> linux-next/akpm-base =20

I can't imagine what went wrong, but you can stop now :-)

$ grep '<<< HEAD' linux-next.patch | wc -l
1473

I must try to find the emails where Andrew and I discussed the
methodology used to produce the linux-next.patch from a previous
linux-next tree.
--=20
Cheers,
Stephen Rothwell

--Sig_/0xDDOA42emBhMWNDZGG8_SB
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0u1ogACgkQAVBC80lX
0GxzaggAoE9HdBJS5ZBRVSngMC4N2eSP3jr4MoEmIdRyK55EvCn9XYaNbFiKAQ5D
Tj17ooVhZnrDecRYnpn/weZ1Q2y7s4mzOAhwdsOeFdNuuMk9R5u1igEo/7vgW0Wm
4ea+V5cvGhW6ZDIx14oz/pa/YpY2DXf4SC8wxMJZwTccK44jtc5gYsA2QK1vBI5O
tQwdkr+jRUswKGosxoKxsXEX27PZXThwrxyjdrEDlyb+Y9Ef6MxNTiEOo/qkYMQM
M2hPMNpQ14lIt7jiTQpmlSaWIqPFN2AnyEkLNuEFDVAIaw6tUcK1mApYTsSWbh3o
LeNHaYdOMs6PRoyrsie0Kl1GSM52cQ==
=PNdR
-----END PGP SIGNATURE-----

--Sig_/0xDDOA42emBhMWNDZGG8_SB--

