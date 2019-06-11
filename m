Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCE35C31E45
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:28:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F84A2086A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:28:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=dilger-ca.20150623.gappssmtp.com header.i=@dilger-ca.20150623.gappssmtp.com header.b="BNyH/I0a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F84A2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=dilger.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 216286B0006; Tue, 11 Jun 2019 17:28:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C6186B0008; Tue, 11 Jun 2019 17:28:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B6C36B000A; Tue, 11 Jun 2019 17:28:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAB306B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 17:28:04 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d2so8467832pla.18
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 14:28:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:message-id:mime-version
         :subject:date:in-reply-to:cc:to:references;
        bh=kHOmEXm44ofEStTL89clw86zKCfMK7pxZweKkVj60zc=;
        b=RAU8JfLTxHWkCFHGCATvn8Al+VdPK1jPwbndMDJm8O6f1FRU8CdP+L5f4N2/VaPC8O
         dFQlmJHjYwxQ7nZC9Fyoa0sgbR1lUNWFiW9DlqrzPjd9dv0eYSzazBHPkQvmTnOTg9lJ
         YkaqDE9z1gbjSqum3tJ7lgWfRdzUzz8+4gptAHUIVvxpg7WAPJt/TBnD46YutbOLKkN3
         mGAC3GKyjPd8JWU6ysRBCOWeeX155klUE02FmwYDJrIYvziOHxL3niKCo2OEQfWWvqL8
         sYY+qw7nVSb0o1YZ8LPYeIZELQ0uDnoA+UC4d+jDBsXoo2m21S13Xf6hOBuLewSySHjM
         BwWQ==
X-Gm-Message-State: APjAAAUmflutl3F6jU/5IBys1iGM2iQ1YwAlj6Q1oCLr4Qj675drCXCq
	xdL6gI8FY162dMUteA5Kxzxg0MZZV+kh3vZ6EvECaFgCIBrLKkcptSkEa8HvCslWdBTtiuG5sNd
	+FD+uwPvvQ4CdFHYAtI+/xRLRWhe2NuXr/rmIJR0Aduad5Z2WJSZwYngEDnKvd004Fw==
X-Received: by 2002:a17:90a:ad83:: with SMTP id s3mr28914727pjq.43.1560288484485;
        Tue, 11 Jun 2019 14:28:04 -0700 (PDT)
X-Received: by 2002:a17:90a:ad83:: with SMTP id s3mr28914692pjq.43.1560288483790;
        Tue, 11 Jun 2019 14:28:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560288483; cv=none;
        d=google.com; s=arc-20160816;
        b=PwxPQ/lmgsh8DMDHvv1PkBOB4TZiAao4HJ4oITJ1xmbQr3BZ7tPzWtHhFPubGozhNJ
         7JrO4my4IEcCRWONExYp77OQ4m1PCq0OY9Jf3487whmyqNWeuiVhxLREiO1IyveEeeAc
         7Kb4MiSFrZr9O0pFA8JU5iPr8X5ki0V8ztlor2eKe+CfkKd9nCZFuwcJhr5hetwhg64h
         i4+W0qOWGuZ7ktqdegsj86VGI2leZk85tmMIiYn1jXzrbMo/hxwKseHoOSzr0BALZrDZ
         98mfvvNSebUvmjxkFGXXknY7L/W/f9AJDlZwL0YA3C8krkhz/U8cnot0J3s785cbi/A2
         12WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
         :from:dkim-signature;
        bh=kHOmEXm44ofEStTL89clw86zKCfMK7pxZweKkVj60zc=;
        b=BpteBllco+6Y1wjyZ5PLx+rR+RMyEO30JWPUJB4g/iYg1I1seQzv08lht+Ujzsmw6J
         Yx1ted5eRuTWf6x2r1GiMqoJwPrRZmKEDWTsEdK8bA6tABf2lOOXi64GigDi2sKfSVSo
         4tDr9YJ6JO9WWWSuOlp8fcYMz5L9KzDvEtoGR6GJjyRB4PG3KdCVR2PVE+AEE1FDjkAD
         OaFFPTTqDAj62/eLQ2se6FedsHsElwBNtKzpQfS98CX62Xj6qbJSOI2N5hmP7vtMLxZR
         n3JGZz7iFPuhEVDFfZpiMzcHGQX4W4rRmTkN3mhfxkKfmoUz66PyIk1OYLO3odtWTIgm
         XJRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@dilger-ca.20150623.gappssmtp.com header.s=20150623 header.b="BNyH/I0a";
       spf=pass (google.com: domain of adilger@dilger.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=adilger@dilger.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a22sor16536394plm.8.2019.06.11.14.28.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 14:28:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of adilger@dilger.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@dilger-ca.20150623.gappssmtp.com header.s=20150623 header.b="BNyH/I0a";
       spf=pass (google.com: domain of adilger@dilger.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=adilger@dilger.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dilger-ca.20150623.gappssmtp.com; s=20150623;
        h=from:message-id:mime-version:subject:date:in-reply-to:cc:to
         :references;
        bh=kHOmEXm44ofEStTL89clw86zKCfMK7pxZweKkVj60zc=;
        b=BNyH/I0aTFapdWvAUe1tA6vh4V7SGGnKW9i2iryYsCgfyNFoPcnfrRh6ENitI8pQJy
         ceJmUE14+hVNBM9WC+xAjbbK0ncjBtDNhZsREXS8wFJSFtJTAC+2kp/Gx/2pDb6cUMf8
         JpUjBxKEfOQvrL9m9kMePR3M4fWdfHCrRVaSTbbHZtX1SELIRUg9HXb/1sKatJNSwuF+
         QO1DomLI907tfm1bq218gSHTCncrOyxsRkBkmStrHKSsQYkjWyIsW3ZSK9J+lpNXxDiR
         oojDQ9O14TWNGl2rGOpuLibgYG5bNECymjz1Ygn5Bb6fBc1ArnndD5ref2xpl4j3WuJU
         Jxfw==
X-Google-Smtp-Source: APXvYqx8fSWzb0HB5KPULCR4fAdvphiu+yCLRaPJ3mwALDMWZWEo99vzBDgf+T6A9kZ8B2J2ELLLxQ==
X-Received: by 2002:a17:90a:a505:: with SMTP id a5mr29364827pjq.27.1560288483342;
        Tue, 11 Jun 2019 14:28:03 -0700 (PDT)
Received: from cabot.adilger.ext (S0106a84e3fe4b223.cg.shawcable.net. [70.77.216.213])
        by smtp.gmail.com with ESMTPSA id a192sm6068716pfa.84.2019.06.11.14.28.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 14:28:02 -0700 (PDT)
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <315FEA4D-41B1-4C5B-89AA-7ABA93D66E0A@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_5B427BF6-3A60-46C7-A8F9-EE572E3F0487";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH V2] include: linux: Regularise the use of FIELD_SIZEOF
 macro
Date: Tue, 11 Jun 2019 15:28:00 -0600
In-Reply-To: <20190611140907.899bebb12a3d731da24a9ad1@linux-foundation.org>
Cc: Shyam Saini <shyam.saini@amarulasolutions.com>,
 kernel-hardening@lists.openwall.com,
 linux-kernel@vger.kernel.org,
 keescook@chromium.org,
 linux-arm-kernel@lists.infradead.org,
 linux-mips@vger.kernel.org,
 intel-gvt-dev@lists.freedesktop.org,
 intel-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org,
 netdev@vger.kernel.org,
 linux-ext4 <linux-ext4@vger.kernel.org>,
 devel@lists.orangefs.org,
 linux-mm@kvack.org,
 linux-sctp@vger.kernel.org,
 bpf@vger.kernel.org,
 kvm@vger.kernel.org,
 mayhs11saini@gmail.com,
 Alexey Dobriyan <adobriyan@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
References: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
 <20190611134831.a60c11f4b691d14d04a87e29@linux-foundation.org>
 <6DCAE4F8-3BEC-45F2-A733-F4D15850B7F3@dilger.ca>
 <20190611140907.899bebb12a3d731da24a9ad1@linux-foundation.org>
X-Mailer: Apple Mail (2.3273)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--Apple-Mail=_5B427BF6-3A60-46C7-A8F9-EE572E3F0487
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jun 11, 2019, at 3:09 PM, Andrew Morton <akpm@linux-foundation.org> =
wrote:
>=20
> On Tue, 11 Jun 2019 15:00:10 -0600 Andreas Dilger <adilger@dilger.ca> =
wrote:
>=20
>>>> to FIELD_SIZEOF
>>>=20
>>> As Alexey has pointed out, C structs and unions don't have fields -
>>> they have members.  So this is an opportunity to switch everything =
to
>>> a new member_sizeof().
>>>=20
>>> What do people think of that and how does this impact the patch =
footprint?
>>=20
>> I did a check, and FIELD_SIZEOF() is used about 350x, while =
sizeof_field()
>> is about 30x, and SIZEOF_FIELD() is only about 5x.
>=20
> Erk.  Sorry, I should have grepped.
>=20
>> That said, I'm much more in favour of "sizeof_field()" or =
"sizeof_member()"
>> than FIELD_SIZEOF().  Not only does that better match "offsetof()", =
with
>> which it is closely related, but is also closer to the original =
"sizeof()".
>>=20
>> Since this is a rather trivial change, it can be split into a number =
of
>> patches to get approval/landing via subsystem maintainers, and there =
is no
>> huge urgency to remove the original macros until the users are gone.  =
It
>> would make sense to remove SIZEOF_FIELD() and sizeof_field() quickly =
so
>> they don't gain more users, and the remaining FIELD_SIZEOF() users =
can be
>> whittled away as the patches come through the maintainer trees.
>=20
> In that case I'd say let's live with FIELD_SIZEOF() and remove
> sizeof_field() and SIZEOF_FIELD().

The real question is whether we want to live with a sub-standard macro =
for
the next 20 years rather than taking the opportunity to clean it up now?

> I'm a bit surprised that the FIELD_SIZEOF() definition ends up in
> stddef.h rather than in kernel.h where such things are normally
> defined.  Why is that?

Cheers, Andreas






--Apple-Mail=_5B427BF6-3A60-46C7-A8F9-EE572E3F0487
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAl0AHOAACgkQcqXauRfM
H+BPvRAAvxlKWQUZz2tRSIBu/vtfIKMWVyY8fctru8Y1oH+Slx4hWvJ/xxYWjMIa
LJJgybj3MjwTd30FmSWmmQmKDyjo5oWGelOeLzVfueI8blZIaDcUYT1rrM9h7F4G
RD22ST6XCWjj5oAmVBW/XHxRIFD6uHtwOnby9a4LgkFOehdkDBhopfAMduEZrW7P
qNa2T0M660SXtmt8dy89Ynb+sge7iinnRyPKkxNaweIXYGVtZzoScRFNK0vSZjbm
TgVIKwFyLDbdX1bJFQHZDWnfchCRqQrrmHyIl+wAGTccpfen4bGhDqW0wU1+rQpv
G2RL1z+N2WiWwKx/TmdPatglD2Hqr73jKfvi7X+DzkJ0nJdYMKnNRpe3S2rZwFjf
MHpmP35Ql2/96bDulYuirHOVvSrrXF/RXZLUp6MuTu2rGankXETXgiP0lkKcmOZW
gvA0pFTKFD8YaGf0NU9jS/OUOjYpqhMkBSK2C3d0UdRMCQzRWAudLzM9quRH7vCm
SfRD6QWHQfOELlKMenRptxYEi8IM3+3R4G1g3VmR7YCegpayslXiSKpgnBAqw4W0
Z4q6nJ/YOwNTjwzs9ndgCZfGpW6JxKYY0DuQe7ld+ngnXNdVrH1X5pZz9ASV9Wli
CowwSgwFlqOSkmcy52L7pRGDGSI/yWwzl6QHtjT8o0e30S27eCs=
=UFIV
-----END PGP SIGNATURE-----

--Apple-Mail=_5B427BF6-3A60-46C7-A8F9-EE572E3F0487--

