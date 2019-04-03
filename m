Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E284C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:23:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED5BB2147A
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:23:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="gyeqjJr4";
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="amauV29x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED5BB2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mailbox.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DB856B0008; Wed,  3 Apr 2019 04:23:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 765A56B000A; Wed,  3 Apr 2019 04:23:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DFA36B000C; Wed,  3 Apr 2019 04:23:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0701A6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:23:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 41so7119031edq.0
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:23:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:mime-version
         :in-reply-to;
        bh=vACzMnxw6x58wlccDwsJXqe6NqBOhwov8kGmhEfdkJE=;
        b=Okyc3I0sF82wNPYWGayuC5SrjqTYleiy6IysMlZCWmChxufsnWvNTdsLHXBEYWIP+X
         yhipAzL2UoEHkaq6DmTwBIVs0L8T43LOvVigNmUEUvfor7F4MgXOoM6dnwuYlSSftXDO
         hBT1D38H7oDH5PF5VPoOFkYJ+oVcBIuBL+wabX9ZvVk+F8/roI1uB3I473tm3thtt9fn
         LNvQoeg7ya1rr1vM2tsBg2L5zqJgxQCPXTwrR5HvWbuLgf5bGUiZe7ETWSXMKZWj/wcB
         fza4vfYv5GNsfa2Oi8Iqfz2n+dWdkTb+WOFFobztAiLZ3uLlILGxOQXhvKJKoMbH+nSy
         7M7g==
X-Gm-Message-State: APjAAAVC4ihtl1IvfdSd5eTt8IQ6oevcvunOI2FXYaHoq+U8TRK0cf9H
	bs//rQPKlNJUp5uX5MOCjzt6I6KEG9TyG5RQI7cBGHBeqr02Vubxe7B76aOst96foXrj6nzUcQq
	t/i7ZfqAD9C4kljeTo/M69WTo6K+LyMaGxMtGk4QaPcK026qTAtPHGBByJDX8M1Oalg==
X-Received: by 2002:aa7:dc4a:: with SMTP id g10mr35698568edu.103.1554279819550;
        Wed, 03 Apr 2019 01:23:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrz0M7J51GV0OgT/Ozg8rg7nlDVwS81V0Whf4+95dq2badfyfa8rdGZvY2D4aHrgrrJ2NF
X-Received: by 2002:aa7:dc4a:: with SMTP id g10mr35698517edu.103.1554279818618;
        Wed, 03 Apr 2019 01:23:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554279818; cv=none;
        d=google.com; s=arc-20160816;
        b=Uzvh8xPGmAajADafCm6jAZVgSO16hmry/u5JHPVBBPcbYhOR7lIiTHO1lWN8U3UMGR
         DU8FcKxM77jJ/4t5VMaqS6COUecfUZGrLUc4RlAstGf6l+tUtgSWPz1HfBCJ0i9ceV2U
         ik9AxJ0qFszrq9mcek1jdUakRNXXBVBKWb3RYtad8ngM4rqXslylqHZxP+iYe/oLWjY8
         Gwgz6LUcBS5qzcKHFopK+UzcIn82Y3NioiCxd4Nf7ej4x4DEJfBsZlpOh2f0Lzrip7Vl
         INaexDbCa9JmbhVpiG+ThoQJtNt8iwa8xeHClTxTFxHCzsCBcFassbwFfJbv25E2NYQE
         9bdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:date:message-id:autocrypt:openpgp:from
         :references:cc:to:subject:dkim-signature:dkim-signature;
        bh=vACzMnxw6x58wlccDwsJXqe6NqBOhwov8kGmhEfdkJE=;
        b=HQgjsRkR4eOQjqIlvLvJi0i6TONmTFqd4TMdJYkBYkD2hDXLJJFAczJPprzbCKvq7W
         ZpHxQ0XuK+PwwvT485RJ+cG6zBNhS+9XQrglUC/elmHyDctq3SWwi/nIpbDwiLaGqCXE
         C3TMjn1VHj+CrU3QpER1Nqvghd1SWFRnwonPrbQzulH5FGYidrN5+dbhx7A92PadeoV7
         VUBsGWPBoIfEBB1N3N67yY7gRkMPGArPVBbzTnWQZ/zZEyaPwTrwMMvgH3gGPm0DEIZc
         TpvoigYKRl4Amfdtvim7DI5X1JXagD2g+N9zhksOHp03Muzpo9KQXrbrEwoAXYm/v6PN
         fUog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=gyeqjJr4;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=amauV29x;
       spf=pass (google.com: domain of jrf@mailbox.org designates 2001:67c:2050:104:0:2:25:2 as permitted sender) smtp.mailfrom=jrf@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from mx2.mailbox.org (mx2a.mailbox.org. [2001:67c:2050:104:0:2:25:2])
        by mx.google.com with ESMTPS id s41si777039edd.16.2019.04.03.01.23.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 01:23:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrf@mailbox.org designates 2001:67c:2050:104:0:2:25:2 as permitted sender) client-ip=2001:67c:2050:104:0:2:25:2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=gyeqjJr4;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=amauV29x;
       spf=pass (google.com: domain of jrf@mailbox.org designates 2001:67c:2050:104:0:2:25:2 as permitted sender) smtp.mailfrom=jrf@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from smtp2.mailbox.org (smtp2.mailbox.org [80.241.60.241])
	(using TLSv1.2 with cipher ECDHE-RSA-CHACHA20-POLY1305 (256/256 bits))
	(No client certificate requested)
	by mx2.mailbox.org (Postfix) with ESMTPS id B6390A1731;
	Wed,  3 Apr 2019 10:23:37 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=mailbox.org; h=
	content-type:content-type:in-reply-to:mime-version:date:date
	:message-id:from:from:references:subject:subject:received; s=
	mail20150812; t=1554279812; bh=dnEN7GddzwsmeEiOv1H4v5GMeUJVQXIdT
	dqqiKu/5TY=; b=gyeqjJr4/hGV3qFzgVAxFu7GyiZz1E5VxM/a7TztWOg99hk1v
	eKZKsSARb+r3xMCr1aP9hsfGyW1D0YWDKsNKRzftWn6yad7musgpy3sf7mUAs1s6
	QXliCKSYnfCXctdGKbmN7j034bFr5k9RCHUWKP9iP+zLeQS+xXJkbfVoHgimFiTo
	MfjnGBHRXtcCABtCjYedkLVMY4Whsq4RyGdEiJiFVMJw1Rh0deXVrHz8MUGz9ddP
	oIeijbLYRO430BU8y4SQ6kFd8o+U5XXExOQ1oQgzAebzg3eVuxxFjtbpcLx8VKJZ
	GYahH7q5FCzuEFkOmOAzzUdxXJ0C6HYY0um1g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mailbox.org; s=mail20150812;
	t=1554279815; h=from:from:sender:reply-to:subject:subject:date:date:
	 message-id:message-id:to:to:cc:cc:mime-version:mime-version:
	 content-type:content-type:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=vACzMnxw6x58wlccDwsJXqe6NqBOhwov8kGmhEfdkJE=;
	b=amauV29x/1gWnaLcoTKJuL+8npF3FAEtMz5myZ0WnEWhsXFfaWlmxRAChRomUHaz09q55p
	zpb8fG0OB00vMaH2boLWfGuvZwFQIP53hVYZTL5V+HyR0SaikWjycisyMA3AH3tRLPMF1V
	aznEXrbLrapT8KtD2F2tRJkj9ec7grNbvDdnVzrfdR63VNtmHQvMvvGSeibrQEB7v0gH/Y
	2t4oYRuttjPwPmS4pdEW1mBwzp0uoBrNzVdREPbWmQVEWjCWi9z5WWRUG6un7buCUT0EUV
	H+JmRAcz/6WBQoPfVDPTntNVe9oSXnXu2DF3mF+pi1HGbOFmy5eI4l/V4i0uzQ==
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp2.mailbox.org ([80.241.60.241])
	by hefe.heinlein-support.de (hefe.heinlein-support.de [91.198.250.172]) (amavisd-new, port 10030)
	with ESMTP id evZivunZoNAL; Wed,  3 Apr 2019 10:23:32 +0200 (CEST)
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
To: Matheus Fillipe <matheusfillipeag@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?Q?Rodolfo_Garc=c3=ada_Pe?=
 =?UTF-8?Q?=c3=b1as?= <kix@kix.es>, Oliver Winker <oliverml1@oli1170.net>,
 Jan Kara <jack@suse.cz>, bugzilla-daemon@bugzilla.kernel.org,
 linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>,
 Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be,
 atillakaraca72@hotmail.com
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
 <CAFWuBvcAFhhPk4K-w7OLVBo8psWuDdUP4hJNLq3QeFUyg=_Mow@mail.gmail.com>
From: Rainer Fiebig <jrf@mailbox.org>
Openpgp: preference=signencrypt
Autocrypt: addr=jrf@mailbox.org; prefer-encrypt=mutual; keydata=
 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
 SJBEfJI=
Message-ID: <8bfe1578-6ace-4bb2-5a31-295660f0f8a4@mailbox.org>
Date: Wed, 3 Apr 2019 10:23:46 +0200
MIME-Version: 1.0
In-Reply-To: <CAFWuBvcAFhhPk4K-w7OLVBo8psWuDdUP4hJNLq3QeFUyg=_Mow@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="mus55juQZ7jBrSNGxkDbrn5jXuxqvoFIo"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mus55juQZ7jBrSNGxkDbrn5jXuxqvoFIo
Content-Type: multipart/mixed; boundary="OqpTniGmsTT1EPYZ1UG5nPUeY3FlA93bQ";
 protected-headers="v1"
From: Rainer Fiebig <jrf@mailbox.org>
To: Matheus Fillipe <matheusfillipeag@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?Q?Rodolfo_Garc=c3=ada_Pe?=
 =?UTF-8?Q?=c3=b1as?= <kix@kix.es>, Oliver Winker <oliverml1@oli1170.net>,
 Jan Kara <jack@suse.cz>, bugzilla-daemon@bugzilla.kernel.org,
 linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>,
 Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be,
 atillakaraca72@hotmail.com
Message-ID: <8bfe1578-6ace-4bb2-5a31-295660f0f8a4@mailbox.org>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
 <CAFWuBvcAFhhPk4K-w7OLVBo8psWuDdUP4hJNLq3QeFUyg=_Mow@mail.gmail.com>
In-Reply-To: <CAFWuBvcAFhhPk4K-w7OLVBo8psWuDdUP4hJNLq3QeFUyg=_Mow@mail.gmail.com>

--OqpTniGmsTT1EPYZ1UG5nPUeY3FlA93bQ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 03.04.19 um 05:54 schrieb Matheus Fillipe:
> Wow! Here I am to revive this topic in 2019! I have exactly the same
> problem, on ubuntu 18.04.2 with basically all kernels since 4.15.0-42 u=
p to
> 5, which was all I tested, currently on 4.18.0-17-generic... I guess th=
is
> has nothing to do with the kernel anyway.
>=20
> It was working fine before, even with proprietary nvidia drivers which
> would generally cause a bug on the resume and not while saving the ram
> snapshot. I've been trying to tell this to the ubuntu guys and you can =
see
> my whole story with this problem right here:
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1819915
>=20
> Shortly, I tried with or without nvidia modules enabled (or intel or us=
ing
> nouveau), many different kernels, disabled i915, and this is all  get i=
n
> all those different combinations:
> https://launchpadlibrarian.net/417327528/i915.jpg
>=20
> The event is pretty random and seems to be more likely to happen after =
2 or
> 4 gb of ram is ever used (I have 16 in total), and nothing changes if l=
ater
> I reduce the ram usage later. But is random, I successfully hibernated =
with
> 11gb in use yesterday, just resumed and hibernated 5 seconds later with=
out
> doing nothing else  than running hibernate, and got freeze there.
>=20
> This also happens randomly if there's just 3 or 2 gb in use, likely on =
the
> second attempt of after more than 5 minutes after the computer is on. W=
hat
> can be wrong here?
>=20

The last time that I've encountered this issue was sometime in 2017
under conditions described in Comment 23. And that's true for
s2both/s2disk and the kernel-methods.

It seems that you are using the uswsusp package. In that case it might
be worth taking a look at the settings in /etc/suspend.conf. What works
here is:

#image size =3D 3500000
early writeout =3D n
#threads =3D y

If this doesn't help, you should try hard to figure out what has changed
from Ubuntu 18.04.1 to 18.04.2 as it worked with the former for you.


--OqpTniGmsTT1EPYZ1UG5nPUeY3FlA93bQ--

--mus55juQZ7jBrSNGxkDbrn5jXuxqvoFIo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEE6yx5PjBNuGB2qJXG8OH3JiWK+PUFAlykbZ8ACgkQ8OH3JiWK
+PXGMQ//X9MvEx6prLUQmEl4bSMz2MfEsZxqEGmm7PpU9PccEqx+FyqtAM3dX4ZT
AuNJqofhpTVxuDjSPBCfy9lhsLZ6BiS6tL9BVCxgA/KA7Wex3zCm89wLoGPJ+uO4
MqcI0s2VJTIXeMDEwU/0GdICfFHbpCucRrmMJfJn8xHOiIEKFHr4kLa2xPnMfMAO
nP0uyqspFlPWYRJZZAFlqizA0u2s0sOr9X4GzPXAas4qAeFwxj7SRTMKIebHowSM
0VNEDbyZmsB1vQ/swlITCoFOT8c/fKMVxyHYpV4se5VwDupBU9a6w9pMjlsviC6G
q7c1GcbreElS1uuCC/QzQq6o+IIg4Hz6D+zF0Hz/7XgsVS5db/J02undCrTjePG3
ZtUDASWo4x98qcB4NlcORSK1UYOw4witFQbpEsoRhvlr+E+QNYJQ11lRtbcd2oW+
CAXUHmyveEwUvilXWOvr1W5xuuQVHGX2MChVDkBE7mtrILN65HJycyasTf53nrEZ
oybjawdEuXr5Gcz6pqvKgSegf3OPR6vQM4IZBtgb4aoOO1mdsbrqvsHipNrohBsp
2ygCKMSrQ7Uy7kSQZyIGcEv6C8EG56xhQkRaul1GcoaPgBfPc5v68HjTkAv3f7sn
CQ0eDjYPPBjnuSHKWXvfg8d6CNiF3zMVbVh7GS6loaHiHUaRZ5o=
=JNhG
-----END PGP SIGNATURE-----

--mus55juQZ7jBrSNGxkDbrn5jXuxqvoFIo--

