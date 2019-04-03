Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E11E6C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:34:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8600521473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:34:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="m75kWfPE";
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="MP0IpBtb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8600521473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mailbox.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 193116B0008; Wed,  3 Apr 2019 04:34:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 142CD6B000A; Wed,  3 Apr 2019 04:34:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F24576B000C; Wed,  3 Apr 2019 04:34:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8FA6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:34:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p90so4490715edp.11
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:34:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:mime-version
         :in-reply-to;
        bh=kB9VOlwjPLXqFLUHfORYIfl2+yq8lAZmEZKVJBsa66k=;
        b=Vq5G75g23h1jxnsYPV4bhaWB/vsIrc30qeCsA4/Hj8QKVIpfRGc71T1QPxlwv63Yyk
         Nbo74VaMcODUQd3Yie9Tc0kFw2TTj4qoz4VgUleZfYFgsKuJ0YdEyRexh03eJS7+w+vH
         /1wLzVyQ4LxJgqUbSjJRGsnab4ED/YFLFcLiiBrg44A1PyBDtpsDrvbqNnQEY71Rcs0M
         8DbiOm92tARmmiIrzs5g1umZQFTDXA1ZCt4Uyhn5s53ayFcd2fNBdatebLYnrsvlWSrp
         jixELr/qp3T5d5mGcqWIBJex8LTDbSiq6OAt0BuOtHxQ1N14UysfmEsajN186OZn8pL9
         ewYw==
X-Gm-Message-State: APjAAAWz8f817nRvoCylotzScXHyV0kL1YxkiKfiTdHDYJbsKqxHpCXZ
	pHIyXXFZGnxRcKgyAZDavbZh33RSaRJNGqYjJdr4H1HD2Xlad7JmB/y0Dd5ymT5rlFuUPv8LVMv
	OJoKMJT/oRueUl27nRmday1Ndfd2osa94yCfjBeB2AlwsvjLXGRZO5DReGRJGLXTbgA==
X-Received: by 2002:a17:906:824a:: with SMTP id f10mr35673957ejx.105.1554280443209;
        Wed, 03 Apr 2019 01:34:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAbzgVq/xLeNDKEdJ3LA2s1/RGmnzic6SA3Le6QTW/1bi1maq0eHx42/ec8tjdiCBGR9EV
X-Received: by 2002:a17:906:824a:: with SMTP id f10mr35673929ejx.105.1554280442412;
        Wed, 03 Apr 2019 01:34:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554280442; cv=none;
        d=google.com; s=arc-20160816;
        b=ExD+xhAD7hvzkZRI6lU4uLvjXQNHI1Or0fdJV3kaUv+MALPcpLc4gRxUnrEr6KCmjr
         MwfI/3D4aQBdh5W/7eFF9rMyEpg3r5PQVVEFh9OMCYl9QbV1POj1oXqs4/hDnilT9cv2
         j0qX9c/nWVRYCkYxOcag789ph7IwkPFuR+pnalLc335oM+p0bo8zLmN9hVbbb17pDIbQ
         JOTXbbetPgtCqRZ5RpHxOE9ykouxepDmOMYeoEsoHtttho/UwnSMjaPjJoeHB5iDj/KW
         pyanTMWGGt56cxkH1ITLa8mEvk4bscyRwWYsHLkatp2qNiT9TT8ZDMO37q48dq4CDaoF
         fLMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:date:message-id:autocrypt:openpgp:from
         :references:cc:to:subject:dkim-signature:dkim-signature;
        bh=kB9VOlwjPLXqFLUHfORYIfl2+yq8lAZmEZKVJBsa66k=;
        b=kVKuC3MEh0wQ39CFlEOAG34Kp+jxn16HwRhU334gA+fvIYxM01ZvFtKGZ5YuTiUhbG
         V6TB7EHM9M4q6uHwA3VLZDiv75T+iLFpJ1OR70zVZUt5kqEb6gJEOSR4xQKGTmpl/pQE
         3uhXlTsHX8c6fTc35zJzuKXyyYKk/SlYFe4sbhxUmFj2ZcJzGzmJokqlHVRdl5DOEf68
         l5Fg1hAef0Klqp7qK5+VDehwXBStKUX4VMXu0zCvPRWIVWzsI8sPDpvhWVHPojhg0//5
         Ig5gldDITud4UG/mgQv6umtG5/My8eyUyN2muSlYD+NnbBiGf5nmaXqju4vgUGXsT3H+
         nOcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=m75kWfPE;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=MP0IpBtb;
       spf=pass (google.com: domain of jrf@mailbox.org designates 80.241.60.212 as permitted sender) smtp.mailfrom=jrf@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from mx1.mailbox.org (mx1.mailbox.org. [80.241.60.212])
        by mx.google.com with ESMTPS id e11si2819399edd.399.2019.04.03.01.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 01:34:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrf@mailbox.org designates 80.241.60.212 as permitted sender) client-ip=80.241.60.212;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=m75kWfPE;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=MP0IpBtb;
       spf=pass (google.com: domain of jrf@mailbox.org designates 80.241.60.212 as permitted sender) smtp.mailfrom=jrf@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from smtp2.mailbox.org (smtp2.mailbox.org [80.241.60.241])
	(using TLSv1.2 with cipher ECDHE-RSA-CHACHA20-POLY1305 (256/256 bits))
	(No client certificate requested)
	by mx1.mailbox.org (Postfix) with ESMTPS id 314684C196;
	Wed,  3 Apr 2019 10:34:01 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=mailbox.org; h=
	content-type:content-type:in-reply-to:mime-version:date:date
	:message-id:from:from:references:subject:subject:received; s=
	mail20150812; t=1554280436; bh=W/NgxRCzZWyQDNppUXdGOTTL6+Rf4CZFJ
	t5+8LSCS5Q=; b=m75kWfPEI3TasptKTrxzXpNmLeag+vqaoLGc9V94joVCEJk51
	7sAmBdq4y65Ka+ek99Yyx9SOweAI0nROz5ZEEpeO+ndQe1GfcJAwCAAzzoFTMXH+
	nIs2eP20jL1dsYp2pGxt1krbSmTxGYO41DDebJpi9gk/GpLltr2R0+vNGIGKwKRV
	1FqkvC3CHD+AlJG9ldGm4qJuc1nXAls21vhcNwCxOnJPJ7/kLFbJI0i0QA9j/Ozu
	bO5HEYR62XrAEvHCiG6xkzXHWQxV/CjuBiCEhCfsQdjL8FH04XnOE9GTnh6B5nti
	NtOAFOB3q+0V1QYdjNno58qw+0JPsxsFqdcfQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mailbox.org; s=mail20150812;
	t=1554280439; h=from:from:sender:reply-to:subject:subject:date:date:
	 message-id:message-id:to:to:cc:cc:mime-version:mime-version:
	 content-type:content-type:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=kB9VOlwjPLXqFLUHfORYIfl2+yq8lAZmEZKVJBsa66k=;
	b=MP0IpBtbPWpKa/MGQsEXe5sk8gvrlV4YKI/zEhguZsORXBxDIRKyt8BZiXxEwoS0UuvLpX
	Zj3iYBFs/akn9jtv9lomyvyRl4/WoFcTEpQscUtODY+T3qd3XcPjI9pG3Hi/lyi2hXdjds
	6vLC8sHIDpS3pS1syFRncFtElCZLVVkM7wQnLI1R1Oe43ZvKN/s6ZbItSIclzaZkf0xsQh
	JHZ2rd835m2XDQbGMPkqYjYnFwAiuPY7uec0x4iFnzH0br5t00SFm1fpHUmz0Z2RPjfysv
	Yb9tft4Z6qNT8cWkKJY9MiMjqtDE9LAGd65hkoOxQ0BZ014sQBybzCB8nDL6Xw==
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp2.mailbox.org ([80.241.60.241])
	by spamfilter01.heinlein-hosting.de (spamfilter01.heinlein-hosting.de [80.241.56.115]) (amavisd-new, port 10030)
	with ESMTP id DriGsFpQoQpu; Wed,  3 Apr 2019 10:33:56 +0200 (CEST)
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
To: Andrew Morton <akpm@linux-foundation.org>,
 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
 =?UTF-8?Q?Rodolfo_Garc=c3=ada_Pe=c3=b1as_=28kix=29?= <kix@kix.es>,
 Oliver Winker <oliverml1@oli1170.net>, Jan Kara <jack@suse.cz>,
 bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
 Maxim Patlasov <mpatlasov@parallels.com>,
 Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be,
 atillakaraca72@hotmail.com, matheusfillipeag@gmail.com
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
From: Rainer Fiebig <jrf@mailbox.org>
Openpgp: preference=signencrypt
Autocrypt: addr=jrf@mailbox.org; prefer-encrypt=mutual; keydata=
 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
 SJBEfJI=
Message-ID: <da186f07-1988-8c60-aa46-96f640a91076@mailbox.org>
Date: Wed, 3 Apr 2019 10:34:11 +0200
MIME-Version: 1.0
In-Reply-To: <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="aj2DRkx6my2l3m6pz6I8vEJAib7taAik9"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--aj2DRkx6my2l3m6pz6I8vEJAib7taAik9
Content-Type: multipart/mixed; boundary="Rwn7rr0n0gwqMD2igH2DEHC8I0HvzlqPQ";
 protected-headers="v1"
From: Rainer Fiebig <jrf@mailbox.org>
To: Andrew Morton <akpm@linux-foundation.org>,
 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
 =?UTF-8?Q?Rodolfo_Garc=c3=ada_Pe=c3=b1as_=28kix=29?= <kix@kix.es>,
 Oliver Winker <oliverml1@oli1170.net>, Jan Kara <jack@suse.cz>,
 bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
 Maxim Patlasov <mpatlasov@parallels.com>,
 Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be,
 atillakaraca72@hotmail.com, matheusfillipeag@gmail.com
Message-ID: <da186f07-1988-8c60-aa46-96f640a91076@mailbox.org>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
In-Reply-To: <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>

--Rwn7rr0n0gwqMD2igH2DEHC8I0HvzlqPQ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 03.04.19 um 01:25 schrieb Andrew Morton:
>=20
> I cc'ed a bunch of people from bugzilla.
>=20
> Folks, please please please remember to reply via emailed
> reply-to-all.  Don't use the bugzilla interface!

Do you want this as a general rule? If so, an according message should
be displayed after login into Bugzilla. How else would people know?

Regards!

Rainer Fiebig





--Rwn7rr0n0gwqMD2igH2DEHC8I0HvzlqPQ--

--aj2DRkx6my2l3m6pz6I8vEJAib7taAik9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEE6yx5PjBNuGB2qJXG8OH3JiWK+PUFAlykcAQACgkQ8OH3JiWK
+PUK2A/+MYw86rr+n5H2eaHWaYmzXv5w1i7AbHhVAcA/T78eogWFIZhYc4LyeJJ5
MAJHfNGPaNY+qc4j9fUb0TOvLB66urEjO7UM8j80yjJciyii2RWTJw61YEthjYrH
HOs1hSYfVyYcx3LQbTxqHcJs01RNkfPB5CN5fbee/qimGKtsr8Z/BNGqAyKgWUfE
gb2qczFQJPfhlsWZtPlRio3yXnhAO1Vnp1+JR7aTjEueBYZL6zf05WqWvq1dp8U5
cMPet6jnzzcO4hU5Qg9AiNDvHKYp1c7rE8kvAL58f5bc9TGfj1M8f/eINgnCyV7a
dP4i5ZbLBXtXCUG8GWmWPM87fILCKV2MAktq7Se13pREOe+XNsK4Jn/G/LPWEX2c
QPkY+V+HTGzM7660VNyP4Gz9UdNPeQrZmRaaDfT0shkhCCTpSCUckZJYL8rcCmW5
JvDB88k8cd4tDnlSFSX7j6GFVcCM6KCKQCqDwBEtROXFb301Xowkqxw5Ko/wTQ11
qOYUDKTNYHfvKasCrQ6VoCduTwFYcVZZR5+kHA1GQG1ZEnIFQ7lja0eFHWig1QGI
VQRH2lev/5zpZw49ozJZtlfUkljp/q2++osKwOlvTyxvTdaXS4wX+Q63KE7LrHK/
Jva0gvGM2xm0OaQqCVOC84X3PrFx/wdcfDStPhvlK2/EsAG7kH4=
=iR8C
-----END PGP SIGNATURE-----

--aj2DRkx6my2l3m6pz6I8vEJAib7taAik9--

