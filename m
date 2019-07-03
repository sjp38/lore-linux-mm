Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB42FC5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 21:34:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FFB521882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 21:34:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="BvceXGMm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FFB521882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42C918E0025; Wed,  3 Jul 2019 17:34:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DCF48E0024; Wed,  3 Jul 2019 17:34:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 257328E0025; Wed,  3 Jul 2019 17:34:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0DC68E0024
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 17:33:59 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x13so2299559pgk.23
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 14:33:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=24P0euDqb6bBFTZwcx3Hb8dPOpEblYuiN0lfXVKKvaQ=;
        b=PphnuMK/IMDTv4JT6cTeLSqVqc/JxeXe05zdnNq+o8gLIQsjNAHnrUJxf2LZPiHrsC
         ouWTrRF88538plPF4j2Hg+pl2TyijshAXBP35ZQKItLs00GWzC/tYfWx7WRDTGKWwEa7
         k8yD958OHSi7GdOUViZKsEGK/tusTMWOLo3ewoJ0RDNkqLQ3V19jzP6r91R5GjI4TkWH
         mSe5YhCs9cXr5FpjwGmPILx4Z70xG4NhkLR+mgrgQd5ubvrC2TAE+HhamF9sgbgW9xSD
         BRYfdXhpbVS7GH5MKE2MHjew84TUUVGAL33ximrxX1sXGx2U6NdiYqsZPUIzR6XLWjY+
         di9w==
X-Gm-Message-State: APjAAAX+3ITveGiNgHmt3/sYv8wCKeHwpNqTBLxHcLo3/U2FguOTyJ65
	OXZeGNYlGSKdcfxF8NpMILOnLEfg/xLNTYWd9n8piFnlGCGZTgfvVBnJwHGoHaXRbwCP9G46zUT
	vJ26vEH4KdQxEUddSXJI1i2zgOWSolzxAOJ9KUOrFvesXA+lK4imL7P9IcLrUD8HrKQ==
X-Received: by 2002:a65:5242:: with SMTP id q2mr24475103pgp.135.1562189639438;
        Wed, 03 Jul 2019 14:33:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4KvXrgbuOKSwHSm1YJfuAzb0So48tjykXwjL+s16d+JEWWf09itJpc9htL6vKGaQnnTAa
X-Received: by 2002:a65:5242:: with SMTP id q2mr24475052pgp.135.1562189638789;
        Wed, 03 Jul 2019 14:33:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562189638; cv=none;
        d=google.com; s=arc-20160816;
        b=zGGogAUsnoflC53cxyc458cI4vWAAY8K8ybvT5JboXWP5NB0mc3YMvgDlZQisikx4H
         FnOPyodOY7ESGqzzckaA0aPKcOKc6sJG0pCBbjt3mc56TFd4mWKDs5J6nd/V0cT2Vl2S
         awpGMpt7k+CMVyP8+yDNfOTQa0Q93+r0O4Iwj+SumQjqAluTbmmIU/iBaPtoaUILg/XW
         hmj7pD1za8VZrFjluQrBjYOMhQtYNhi8niZvxzO0Ek2N6dszc2GSirLIqeuDhJOeLGZs
         SQq90Ntgk5HsvAFkZLTUSLFnnlHBzP7X1xjt+CepmZO7lZSTsvhNTBJfVjy7GCyykJdk
         tYjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=24P0euDqb6bBFTZwcx3Hb8dPOpEblYuiN0lfXVKKvaQ=;
        b=j2hl28TzPHHJ8vyJCbdl68nEkkMda0BpTPnEzwr202gweieEy5g0l4aSB2BPXeXLw1
         kUG/DRPBqcPnzlxRFoa+wr0d3gRtoLEolqawAbrMvpyiDD+rZE0f+F3Fn1ye6kKiJkc7
         XLDPAdNheEfMFRhqZjkzKCBmpdixihM8WkZVKgZLrFbrPrRgwcRJTa9gjEXDg3DHXwUh
         WzbctoxF2trmBmOP6d0fa6x/pbl0E2uYGia20yGQkS8T7osLwP1d6ByTV/MOjRrP7FI0
         Ule5OKnqWmcWXzMfZlmIKFlsTCucKLIDDrTT9sso9+Wpk5WyE5TzGc3WBJoaBZvKCT4e
         A/FA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=BvceXGMm;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id v38si3223328plg.277.2019.07.03.14.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 14:33:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=BvceXGMm;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45fDrJ03Pnz9s8m;
	Thu,  4 Jul 2019 07:33:51 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1562189632;
	bh=Os+jzgQMICZR69IdtZ2LPrWGr3wL6t8dfhpo9PW9CTc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=BvceXGMmlD2pgIGNG4nRkkfwbZOsnSGFutgb9K7qpsyEMTPB+3lIDosiN7RYgY+6D
	 P7OD5zI76p5WSsPw6OB/AKHY2QrJU7vzHtRsvz/Z42ZznveL6e1r3id+GYPtQih/qY
	 kZqHCBDlUJqF2iE6Jkt8MEI+GzYmJX9Bvg+CuQBx0L+BPw4ggURceiRfx2Fg1jRCh3
	 RwLod3wU3Eey0ZiFBf0Cj4fi7HemDArKarPKAUKrkVN1Ny/nFVAJQFnCKkTA5ncOUF
	 McZOsnicRdX4IwPaMR/kCLxAVzSz6Fs5xJROthl7FeZE3KR2d1RbhmQ0KZgcMBOi+P
	 Z5cdAmX544oTA==
Date: Thu, 4 Jul 2019 07:33:50 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, "linux-next@vger.kernel.org"
 <linux-next@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
 <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>, "Yang, Philip" <Philip.Yang@amd.com>, Dave Airlie
 <airlied@linux.ie>, "Deucher, Alexander" <Alexander.Deucher@amd.com>
Subject: Re: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Message-ID: <20190704073350.1776b317@canb.auug.org.au>
In-Reply-To: <a9764210-9401-471b-96a7-b93606008d07@amd.com>
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
	<20190703141001.GH18688@mellanox.com>
	<a9764210-9401-471b-96a7-b93606008d07@amd.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_//OkC/dWzQJ./2kmAlmbmsCZ"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_//OkC/dWzQJ./2kmAlmbmsCZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Felix,

On Wed, 3 Jul 2019 21:03:32 +0000 "Kuehling, Felix" <Felix.Kuehling@amd.com=
> wrote:
>
> It looks like Stephen already applied my patch as a conflict resolution=20
> on linux-next, though. I see linux-next/master is getting updated=20
> non-fast-forward. So is the idea that its history will updated again=20
> with the final resolution on drm-next or drm-fixes?

linux-next gets rebased every day (that is its nature).  Do not worry
about that, I will cope with whatever you do.

--=20
Cheers,
Stephen Rothwell

--Sig_//OkC/dWzQJ./2kmAlmbmsCZ
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0dHz4ACgkQAVBC80lX
0Gxxdgf9E2csugoLApYbShqrhYZvNZV6CSi5bk64nkcRGjGhYrf/iOJKJFYLu8ef
N2UJofT51bVSvo5N4jHHXznLj5BYaPfpk7ZnOWBrcT96QFZQJ3pUVGwwcBU9Vfvi
MjxDEhNsbKvG987UnTXy4M3s9ZQ3h+YDrWv4gHZACBoTXFHJtpQWzlq7KuI2qVei
YPVWtEA18ygX1C6yAkKcaqeI4BW+43xio9ZLvCy86DFouyF0+cLkJAi+oe2eysX+
RKsrOjnEIdKlq1xKV0OGuT6ovuEHqUBj1vm6AFUZQ0XoUATrvSt7xtWYvETG1seN
RQ51nmJ3eG1uft0nzra48IztE1E6lw==
=QFow
-----END PGP SIGNATURE-----

--Sig_//OkC/dWzQJ./2kmAlmbmsCZ--

