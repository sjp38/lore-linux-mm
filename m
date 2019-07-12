Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08A26C742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:42:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF5A92084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:42:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="WuNZwoFg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF5A92084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4059B8E0129; Fri, 12 Jul 2019 04:42:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B52F8E00DB; Fri, 12 Jul 2019 04:42:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CCDC8E0129; Fri, 12 Jul 2019 04:42:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA4868E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 04:42:00 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so5134678pfy.20
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 01:42:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=HxU7TIHcF0N+QiqX2H3P/mNb1dmy3KRNh4Wb68qwErk=;
        b=XU96HwaLftoZsWCVZp5j48gixB+j53RtY7cFg9CkSGI65Ih0rJ1yKnuSW9YJPngNI7
         sAIV9Fdg3Hy+WNjmWEtcwNWIVcWNZkUvlDaNUXs0LNLYJwhmi4l3vIMv9gOXiEICkA6C
         I7D4ol7pvmbeAGiGxmXnl68snEeyhGFFPYYaMWbUpvL7ISV5RwPkZ6sA/vHp2+3yCvRH
         O27ZxreeL85Deck8+EnTm1FMRB2QIRejp2jhMVy+cF68iQHHzc07q8aeZUwpoU8RXkF9
         OzeGebFLn72n+f8tjvPJB87Fm4DUhXUUbq8GJX2RrQKZFtbLz0h6ZMqKHeu/vW3oPBJ0
         f8WQ==
X-Gm-Message-State: APjAAAUocebLdgKAcxRm0QubiFOA1i2cei+pu+gGIAOqL2P9QDRrWL9q
	m6rkIohPPZvmNd/g/gk9WLUQD/+HSeJmzPLWsOqC9ntFEHgJT4cO+3nSNupZat78jQkHTmsbP6n
	MdGRDfSLEoRO8LQ4C0z9O28/xRyNzjdEnbu6LKLm7Bv6wmHBpay00L5/CK4ErHd2zHg==
X-Received: by 2002:a63:eb06:: with SMTP id t6mr4863667pgh.107.1562920920510;
        Fri, 12 Jul 2019 01:42:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsCbzAboABoO9eNTrFRcqXnaWzheNQfeySDymNokmskok/BGXwCiARhx5Y53k9prx4qlQz
X-Received: by 2002:a63:eb06:: with SMTP id t6mr4863607pgh.107.1562920919751;
        Fri, 12 Jul 2019 01:41:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562920919; cv=none;
        d=google.com; s=arc-20160816;
        b=LO6zcdO2u4ZdYf4v9PFNNjXWV8i8foClJHbyG85CJGGeufGVHGCnvPCfZbHXiJNHVZ
         MSGKRBDMRrjgZdAR1DJo0LaeGx5VlQKXIVQAlRYlOkGWz0hMTi3EVmIuH+oqz2Xo/oSS
         pHVfTS6JHHMteQeK9t2066wn1WXRxwz9WzGW7i93ybhnB9LoJiNWB7fbldDle4gJ8h4h
         PFNDdPd3li5DUhxoutAIMbyNlqobvkVSjMDN5wwvNYQDiJ2LXGtJ4i1otLWjKEOsh+1H
         aHX3KvN+9U+9pMrqqpsuxacVOEV/AyUk33KTzUU0j7USlFNVT/XzRi80NRp9JY1yXk16
         v/0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=HxU7TIHcF0N+QiqX2H3P/mNb1dmy3KRNh4Wb68qwErk=;
        b=y0sHsvaYBRX+R0NC/pszW3c/NA37wKwd1/oMMVHM/aEQgq19YETbEdwhYX9Uzoulwh
         1GPTatk3kuo0BZnYm7j9Xf7YjUwbmH5fDJD3Kv4nPvAThnJ46hhF034DnrbyoQYdqS1r
         O4yEyyCtW7H2Cqabp2hKvb7Qcz8DloKzgw0IpbT+0Mo6kQKKeDFR9HQ5eWOo2XZsJLR5
         mLq498gVwforVkmDM8l0EfYnRF8HAzcxqhC4Tf7S2bcEFNAeLo8VXHdKpF4aVuK69Ywx
         DCJI4nrBYVMfDdX41pwsC5ulFBxylSvIjYwJm3faP4lb4rZi6d7BbFsjp42bVZzh/tSP
         auAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=WuNZwoFg;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id e6si7524089pgl.305.2019.07.12.01.41.59
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 01:41:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=WuNZwoFg;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45lRHM60K8z9s00;
	Fri, 12 Jul 2019 18:41:51 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1562920914;
	bh=XMy057h7tEqUdteK4IfiKdKfqoRVIuXrEgiej/z+E30=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=WuNZwoFgEMQjylkarzZqrwhJHJfSfAndylVc8H1asf7TwExA9LFB1MP3+Srbny6Ng
	 WSOf0n3AGT7y5G3JbpPC5b/mZ1C+DUsSqZu8IRGsEcnmyrsyAKBnQEKj4bgiElRZJ7
	 FoBTUDC/NS1IYvTwzIJ9nJtfCb1GFOG1F2t+x70/3PAABZxkHw5+Gr1JNHW9Ux6FuE
	 6pubM+Y4ILGevkpkgO+O3xxhqCWmEFgSZGWQnJhEF+G0ywFrnmk65nKWC5h+HNMV4f
	 zPAiyDMVfCPFVcfNcYKaAYG1IvEWh2eax1FXdUMu87XijfMykOVdQPEgxtc/b03FFc
	 eef1WUOMABWmg==
Date: Fri, 12 Jul 2019 18:40:55 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Andrew Morton
 <akpm@linux-foundation.org>, linux-mm@kvack.org, Catalin Marinas
 <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter
 Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, "Kirill A . Shutemov"
 <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@kernel.org>,
 linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org,
 x86@kernel.org
Subject: Re: [PATCH V2] mm/ioremap: Probe platform for p4d huge map support
Message-ID: <20190712184055.47a7a54b@canb.auug.org.au>
In-Reply-To: <87tvbrennf.fsf@concordia.ellerman.id.au>
References: <1561699231-20991-1-git-send-email-anshuman.khandual@arm.com>
	<20190702160630.25de5558e9fe2d7d845f3472@linux-foundation.org>
	<fbc147c7-bec2-daed-b828-c4ae170010a9@arm.com>
	<87tvbrennf.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/gEMDf8pJbcBsPcmqhs4eMy2"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/gEMDf8pJbcBsPcmqhs4eMy2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Fri, 12 Jul 2019 17:07:48 +1000 Michael Ellerman <mpe@ellerman.id.au> wr=
ote:
>
> The return value of arch_ioremap_p4d_supported() is stored in the
> variable ioremap_p4d_capable which is then returned by
> ioremap_p4d_enabled().
>=20
> That is used by ioremap_try_huge_p4d() called from ioremap_p4d_range()
> from ioremap_page_range().

When I first saw this, I wondered if we expect
arch_ioremap_p4d_supported() to ever return something that is not
computable at compile time.  If not, why do we have this level of
redirection?  Why not just make it a static inline functions defined in
an arch specific include file (or even just a CONFIG_ option)?

In particular, ioremap_p4d_enabled() either returns ioremap_p4d_capable
or 0 and is static to one file and has one call site ...  The same is
true of ioremap_pud_enabled() and ioremap_pmd_enabled().
--=20
Cheers,
Stephen Rothwell

--Sig_/gEMDf8pJbcBsPcmqhs4eMy2
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0oR5cACgkQAVBC80lX
0Gzspwf/VrAAnMW4h6ldvfqp7zGCa4zwIPADkPvWSNBoahsOMNPdBxKy/NjSosk4
9HSdh6ediokUaf9wY3ZTNacC8wlg5LRk8g9FZlcT4de4qSx5Fk7sIy4rXY7HrhBZ
uTyxqI19f8AlG3JCzfxBuA+/xgKl7/KctQC70jAWFGItK0DM0V08dkWVJ1MUBAra
QwXtOIFA2TNMFleSAM19/lvZiKG8mkWjrv1wBZtDPbVPg87UfSPLcS9XplOVd1in
FnI2Zz/xDu5853kJFQl1ERorfRDMqnUXGRHNl3L+6+KZoeVp8pHBoS5pYC/6B/Er
APSpYNV5gTnvKd8cpVJEw/3uUmEJgw==
=5AC8
-----END PGP SIGNATURE-----

--Sig_/gEMDf8pJbcBsPcmqhs4eMy2--

