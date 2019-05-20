Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BB46C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 15:05:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A05CF20863
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 15:05:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A05CF20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=the-dreams.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F5766B0005; Mon, 20 May 2019 11:05:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07E266B0006; Mon, 20 May 2019 11:05:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAFBA6B0007; Mon, 20 May 2019 11:05:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id A114C6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 11:05:13 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z13so6725941wrn.14
        for <linux-mm@kvack.org>; Mon, 20 May 2019 08:05:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RIa+UfNx7CVpbC8KLI3xxs1ZSITbiAf0jY38FbQsbWM=;
        b=p44u0NWEU/sEQ72LiViAKX9xtj1HP1rX9TqxA72ifRaWKue3DcWwBXZ+3UB3b+JvOr
         KqFRP2Uc2rGvnGL5/WGBZNWZ+tbB4K6dq8swQ1nWSeCGDzpm9u1mpTFA5dUV7a+Ckp84
         XdkUE77Z+V3aJ52FwvNf1hvQ7oZU/C5Rse0BD9CcnYwrmpNP1Pu/BWp+JM9Od4sWl12p
         jq07zUtV8dFDL7jGsuQ0M4IZT+Xkv1DwdcCr6L4MQ7TOBoXHpVG4VZE5kJs4oAm3KyAj
         uYzMa0fB3ihCBuyWuDHY/nUAdrlyEvFZdRaWAkVeXGIzMrzleionWdp8Jv1ODtsVI9S+
         wZVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wsa@the-dreams.de designates 88.99.104.3 as permitted sender) smtp.mailfrom=wsa@the-dreams.de
X-Gm-Message-State: APjAAAXsxwkm+otvOH1lJdbhb2Mt8TZnH4L7/YBbBmO6dPhTe7rXCs2R
	riT5U4Ding/TCjiUUfHRDVyvLD+MXtre57LQ1NFrKion+s3hITD85D0W2mNNmr+rgAleaoSy4SQ
	FGhOk0GTlIBV8Jyqjo0xwivFbbVA+z4+CETP06GcE3Hlp6xx8rjWiYcjNdM/Nx+Oa3w==
X-Received: by 2002:adf:9e46:: with SMTP id v6mr1535768wre.141.1558364713191;
        Mon, 20 May 2019 08:05:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOqTBYtEG0+bTQJOKRSJCSIfLyGDypGrF+EOUYCZWqoBA0O7gZt5h6k2S0GlWU0pR8rJEy
X-Received: by 2002:adf:9e46:: with SMTP id v6mr1535656wre.141.1558364711921;
        Mon, 20 May 2019 08:05:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558364711; cv=none;
        d=google.com; s=arc-20160816;
        b=jzUxmnpKdGLrrrj8DIIsTVUV4CA2eqhULgM/Qd1VxV1Fb8jI8/h7JnTg1ZFWfUBKWF
         WW0MYG+IAHfvf1dm6irR+e/cegtwFE62gDWyAeanDUmBp98Cspgbsg6gf9uKMJ9g9QnJ
         K8wJbesMDd889cwc2NHdO1v817KEH5B7HrpdF1TBWYco7Hh2Vkk3Mo7WdmTVMq4R8clZ
         wGfhVQrohqvQ9uj/PZMk0be81hI233jn+MNMPZiREDJ1+0FOOTp/tq67RppsEFU6zo0x
         SXIhdPl69EKC77g77p3x7q3uxI7FO06SgxBH/wLm1fVEl51reK2UB6q4unIbYoVyTlUN
         gggw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RIa+UfNx7CVpbC8KLI3xxs1ZSITbiAf0jY38FbQsbWM=;
        b=fgUHuQPVMPH0kqUESghYhVCls9/ASixHSIdYFg6q0hMn9NI639lCliXVjCp/s4208v
         Nmy3h+hGCVEUDagsoFj0Kzx5TioyDr9gpmjdX0avcOdqpyFdLzW5OtnUI5h1efAfMmPp
         J4kwFblNAPZwfF0vspO731fueWx5Bj7aib1ghPIAlJMlAAyaYj+UfS2Vktb4vVfrlUyq
         Se7RAXvIIcupeIlABCMsq6u4AIsdx9KDrAGopNy2HVzm6ila5MdriSVH3s+vN9qpjXF5
         Y4/x2vDs8a75qfPPcWXug/T0hhKysoFLzn4D2mFe38w7WNmeXQ9E+dqrCq3E52IvlVpC
         CJWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wsa@the-dreams.de designates 88.99.104.3 as permitted sender) smtp.mailfrom=wsa@the-dreams.de
Received: from pokefinder.org (sauhun.de. [88.99.104.3])
        by mx.google.com with ESMTP id b83si2855729wmc.5.2019.05.20.08.05.11
        for <linux-mm@kvack.org>;
        Mon, 20 May 2019 08:05:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of wsa@the-dreams.de designates 88.99.104.3 as permitted sender) client-ip=88.99.104.3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wsa@the-dreams.de designates 88.99.104.3 as permitted sender) smtp.mailfrom=wsa@the-dreams.de
Received: from localhost (p54B333DA.dip0.t-ipconnect.de [84.179.51.218])
	by pokefinder.org (Postfix) with ESMTPSA id 3853E2C2761;
	Mon, 20 May 2019 17:05:11 +0200 (CEST)
Date: Mon, 20 May 2019 17:05:10 +0200
From: Wolfram Sang <wsa@the-dreams.de>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	x86@kernel.org, linux-acpi@vger.kernel.org,
	linux-edac@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-amlogic@lists.infradead.org, linux-arm-msm@vger.kernel.org,
	linux-gpio@vger.kernel.org, linux-i2c@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, xen-devel@lists.xenproject.org,
	platform-driver-x86@vger.kernel.org, devel@driverdev.osuosl.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	devel@acpica.org, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	linux-kselftest@vger.kernel.org
Subject: Re: [PATCH 10/10] docs: fix broken documentation links
Message-ID: <20190520150510.GA2606@kunai>
References: <cover.1558362030.git.mchehab+samsung@kernel.org>
 <4fd1182b4a41feb2447c7ccde4d7f0a6b3c92686.1558362030.git.mchehab+samsung@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="6c2NcOVqGQ03X4Wi"
Content-Disposition: inline
In-Reply-To: <4fd1182b4a41feb2447c7ccde4d7f0a6b3c92686.1558362030.git.mchehab+samsung@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 20, 2019 at 11:47:39AM -0300, Mauro Carvalho Chehab wrote:
> Mostly due to x86 and acpi conversion, several documentation
> links are still pointing to the old file. Fix them.
>=20
> Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>

Thanks, didn't notice that.

>  Documentation/i2c/instantiating-devices          |  2 +-

=2E..

> diff --git a/Documentation/i2c/instantiating-devices b/Documentation/i2c/=
instantiating-devices
> index 0d85ac1935b7..5a3e2f331e8c 100644
> --- a/Documentation/i2c/instantiating-devices
> +++ b/Documentation/i2c/instantiating-devices
> @@ -85,7 +85,7 @@ Method 1c: Declare the I2C devices via ACPI
>  -------------------------------------------
> =20
>  ACPI can also describe I2C devices. There is special documentation for t=
his
> -which is currently located at Documentation/acpi/enumeration.txt.
> +which is currently located at Documentation/firmware-guide/acpi/enumerat=
ion.rst.
> =20
> =20
>  Method 2: Instantiate the devices explicitly

For this I2C part:

Reviewed-by: Wolfram Sang <wsa@the-dreams.de>


--6c2NcOVqGQ03X4Wi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEOZGx6rniZ1Gk92RdFA3kzBSgKbYFAlziwiIACgkQFA3kzBSg
Kbb/+hAArOEJ2RcuEqvOP7Ge80J7VxtEVTCR0sWRFg/7cpRGLnwf1qLSAUlfAJYj
fUhZ9ANfeB4Y4ZltOPwJ34KNtZy/kYzYyoy/WgiNfJUrf+s7auOF+dMXRvBe8VyX
v/pHpAMzTf8rtNkaESOahPExL1lgrI2dShZa3Mxofm2eb3Kam0OJRr6Cvj7mA/Rq
PHq1QUlG+Y3hZdvAHjQ6GN6wr+pNnhqeSSAd3BZg5MZQpPRiaK+C4tPkqOD/TNwX
9+iPJTMPhWsdei4UO1POHGCOclFatxkPOQm9JjsTD1h1lEJK7Afs1cTCd0crwpzW
nQuj+MSjKTqcOwQ4hF1x6PwlbJm4Hq/+r6b50UsnQYai6pt7Khp9OISmYTxPQhgI
8aXZbjsMB3k9ebYulULGdF0f3p/IPoqneTUf3yi5OxNbhJ8eyNcQ4l35MP9hEyYb
H/9a/G4GXP7CLyCtKd53OtNeE1tTF4zGKIhe7v9OInHolA3gLx1R1rxiBeQB+XyA
NO/4FdEIZ1QWAyl7m1aWBtYpar2uvFyEhZWG3sVhZYsA9dQNBfgzFSu60wus7hy4
D9FxYijaEnHZvPivrTwfcp8ittAvsIrM3xANcOhWXEU6eC6w0KX15QiiyPQUbssL
H3fPVUBxQlwicyY98Dvh7eJmnD1WEsMcDmDI5RqrAxhdD/bxbN0=
=b4+p
-----END PGP SIGNATURE-----

--6c2NcOVqGQ03X4Wi--

