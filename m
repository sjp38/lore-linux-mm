Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B41A6C76186
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 03:21:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B2222173E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 03:21:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="kA006oxQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B2222173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07B208E0001; Wed, 17 Jul 2019 23:21:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02C0A6B0007; Wed, 17 Jul 2019 23:21:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E34A68E0001; Wed, 17 Jul 2019 23:21:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACC8A6B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 23:21:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so15827924pgh.11
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 20:21:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=BcO0HGR7e4UTl+jc1D97xviwaVY0fONvvUaL6z9KEIo=;
        b=hxsyaDEpD2cC++MbAxBHIfHlRRYg5gY1uMd59t9VosUggqneohs3o3DRDIQfOgAIMC
         Ycig+muqj6QLe0qbiMkz1UdR2Xoz8Hxxf6aQJ3/Yz5nIJu+B2TopTsNEsw4619Hd3tae
         k+mI02WgijnwNHL9L7Tp4sMqWT1uedfMppyKmL6bWmwydFlL2JQFpYKXu0lFalTslo3y
         Gpyzv4eFFSzw0JDHIldsJm6Lg4qFycPI7327PADWTi1Q7+5eZa+hZytn7RDIF0tlCpIG
         blE8dj6cfvy/Ua8obBEvP3jByQbvw5lgM34s3y/G+dLVWjAyXDA2FIizCAnQUuLZ0RDg
         g+kw==
X-Gm-Message-State: APjAAAVDcj4FGHpKHpAqOKjLSeL4NMrwDvdcwKfLs4cWMkpk1pCImXbG
	LvDQtPNEF3zLbBU0DE/ULu3r+lTSCAIsaN5Dvdpuv8dFi2z3RezUPpauvEp7XMBJUIkl5JJf43I
	ODJKmc/LLVY6FF0sowpVfPjtvKnFduV6HGZ1Jz6nPA4LpGf11+Q2aTmyaaV/0yiOcbw==
X-Received: by 2002:a63:5048:: with SMTP id q8mr44698045pgl.446.1563420091185;
        Wed, 17 Jul 2019 20:21:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAa1/fmCKd2OWBlwvwWRoTFEmuZUaUhqwbq8pheqNvJqLiaQrw6CDsbkrJ+CftiQO9/RVp
X-Received: by 2002:a63:5048:: with SMTP id q8mr44697972pgl.446.1563420090227;
        Wed, 17 Jul 2019 20:21:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563420090; cv=none;
        d=google.com; s=arc-20160816;
        b=de9Ky6ilFO8U5gWxeCIu+aj38PvyFPqNhC8AxyW9VOFHMB0ylzk2bOpoSFz7ONZpOp
         AJBU83n2oUOuzYyTj36Tszj6xzGxdt8uKAlrTUfwMIsCKizqrryP3wkUWcNHEf0kzAs/
         NhhkNGYTTZx0yTWA1dGNSKnykQLpDT6J2ZzAGeCZC1LU3lFntmvJbZnpNOhwsZ9PIGZ+
         wt5bj+iKHoreZvXfdyPvOr1IYZuLPMSGaHHDhQOzvQSBUzgHwSYFemOpxdaMVE8Yk2DE
         +n1bpKX6Sdkc6V4y6yWjEMRaEh4TnpNsjEKCxIGtNBkeHNOYasCr4hMm1n4r/RPidW9M
         joig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=BcO0HGR7e4UTl+jc1D97xviwaVY0fONvvUaL6z9KEIo=;
        b=qlb0zPW0etHVOSV3rTmoHMpucKG072vsF1/TeBdEVVb5sgLT1ndXf9Gppf4mSR/R/j
         c9itWFv0rK5epR/ftrlUnpkcZuYWJE51VFOB+JUtBtPyBdjamYrXFRjQha6UDPymG5O0
         sX6xkQD6BB9WzUeJrcA8c4vc1rIb5dIzG16iTezh1/WnIFi00JGu/4izms994qUvH0ex
         U9KfXtmJ8X7eMb+UBxIKyXjIg/1Bsd3z+07FPP4WsJE0wO1XK6i7+vhVU/TVAXxl6wyM
         3xoRTL4Th4GRPqbeBPMy4/ikdD1uiMUye8z3hyBSKVUmmY1WlwTAwlbL2joX/7dfMtJX
         Lw5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=kA006oxQ;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id z10si23917855pgv.233.2019.07.17.20.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Jul 2019 20:21:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=kA006oxQ;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45pztt4f7mz9sNr;
	Thu, 18 Jul 2019 13:21:26 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1563420086;
	bh=onp2VmPiELbvIvkg2tf00xZcG6KP/CQLzKyAEZzDib4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=kA006oxQfewIgA9PWNvgcNJ9JvzlF26mMPNUPdKr70a7iDhrLEsAq/As3QzuSrgeZ
	 +hLFNtgTLS9LvJCEVCMByH+InBq7/ul40/FzhhXCLvxeZEiheUDeK2Mn7I+XeVGtfA
	 T7z7uhHkrsfr1sDu3ktsndOKtVhzYpT4lrQywk++uGd+KViY69ioJOZXB07KPePr+j
	 8+3gB8VHfXkr5vX8cTsSoilu+hjP0X2D5YqNClpj8E5Uu/O7OlI3VIgw6iT0CAB4YQ
	 PMPWCaytNPerKOgfI0c9JKbQMCoRqHPGb5cL1QOPdDDJq14hD03oc4RwHQAirU9u4f
	 qzN3cyznabT6g==
Date: Thu, 18 Jul 2019 13:21:11 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: akpm@linux-foundation.org
Cc: broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: mmotm 2019-07-17-16-05 uploaded
Message-ID: <20190718132111.1f55f46f@canb.auug.org.au>
In-Reply-To: <20190717230610.zvRfipNL4%akpm@linux-foundation.org>
References: <20190717230610.zvRfipNL4%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/JOd2f8N3wfkBrruihbRJymm"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/JOd2f8N3wfkBrruihbRJymm
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, 17 Jul 2019 16:06:10 -0700 akpm@linux-foundation.org wrote:
>
> * mm-migrate-remove-unused-mode-argument.patch

This patch needs updating due to changes in the iomap tree.

The section that updated fs/iomap/migrate.c should be replaced by:

diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
index da4d958f9dc8..e25901ae3ff4 100644
--- a/fs/iomap/buffered-io.c
+++ b/fs/iomap/buffered-io.c
@@ -489,7 +489,7 @@ iomap_migrate_page(struct address_space *mapping, struc=
t page *newpage,
 {
 	int ret;
=20
-	ret =3D migrate_page_move_mapping(mapping, newpage, page, mode, 0);
+	ret =3D migrate_page_move_mapping(mapping, newpage, page, 0);
 	if (ret !=3D MIGRATEPAGE_SUCCESS)
 		return ret;
=20
--=20
Cheers,
Stephen Rothwell

--Sig_/JOd2f8N3wfkBrruihbRJymm
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0v5acACgkQAVBC80lX
0Gy4Fgf/e9X65fZvCbB0Nhqw4PpeHOAdJvQRDvZA84FLdP/vsEKnLjFlFir0togF
JgD4OAYOQvGeZqhbFOfSFETsraF4HOvu0CWObY7pHuDrizRDl4GX9ZKPGx/9+VkV
dLoS2uFuV0tMC9fvyT/o+kLJE/r/zZNcXOJs/E5Fpzx8R7EN4nmS71quPkhezPeb
/joItlo6DtsauVnTtUnrYqlDieWVOMCb0Xa+nHF3IzbQR/afTyoWxIYkCWhCS6/D
muCE72/kFn5C5/9A637Xtffweis6aS4t47HVEesWFh5BZoFrOzYUN7AJGLoQ9tzm
GPh337OUHu0D+XgyPiI4kazKcLXWRg==
=HJt9
-----END PGP SIGNATURE-----

--Sig_/JOd2f8N3wfkBrruihbRJymm--

