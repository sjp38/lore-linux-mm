Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33B03C48BDA
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 00:06:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0AAB20815
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 00:06:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="g9H0EqGd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0AAB20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 700366B0003; Wed, 26 Jun 2019 20:06:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BA808E0003; Wed, 26 Jun 2019 20:06:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 503748E0002; Wed, 26 Jun 2019 20:06:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13C666B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 20:06:23 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x3so227291pgp.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 17:06:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=yvv2xnA6HSsaDM0hNLpCq5cOsPLEOcjtp6Gg5uV6AQ0=;
        b=Dl03Tjy7oCY415u27Cm6vQRmMXJzlNOjVMWprb65EBIVO8HTiMfhdGTp9QUtoey8oN
         rjbmk0lEHYaIvyPKGiCZPpujP62sFQi+yoM69lVYc0kljwBeq5J2NNbVqX8jNAmNJ8l0
         NKfyHyqm6J3IwvNXnE/ZdccQJnz7QUFc/PB22GASb4lCAVHVptN5ifxd2a24CGQo4Ok8
         kYFnsvJNk6JiuRuMtmSLQjlauMSy6HOfS0UjmLrIH2wy01S1y/xdksKcMk4z8dnQ/x3C
         9zzgUeYXIHu/tiS69PdEV7+t9Pwz21jtSE6JEKOK0kOiadNcSt9IsSS08HcbObDPaDRS
         lpiw==
X-Gm-Message-State: APjAAAVUwuSgbvDOJ1ke86x5iHzvbfS4XZbyfV3kvUxlmAFrtn7yY54m
	uhEcLiHjuW7mTTzuWSROcZowg416xd3G5MOlvUnD6g5o1I1peqf6AYE4m3YP+Vkg0zCTLbWHRtp
	uq9m/6AOEmZIKDz2wbLAtIi+I75voYNxfTxKipHIyrnJMXJ6ztIKF1SazbFaNQ1uz0Q==
X-Received: by 2002:a17:90a:30e4:: with SMTP id h91mr2099520pjb.37.1561593982668;
        Wed, 26 Jun 2019 17:06:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEvBiXVkwCXmYcLAm9iKyFeWiCxldhFJ07IzVFpV8ZEgcJ8rROemjjboWb34n5tKGl7GpB
X-Received: by 2002:a17:90a:30e4:: with SMTP id h91mr2099457pjb.37.1561593981929;
        Wed, 26 Jun 2019 17:06:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561593981; cv=none;
        d=google.com; s=arc-20160816;
        b=y8iiNLsnZE1GH0J6kZX+dhR57YxGL3OxHnNduZ57L6ZryMoLq86nkzCBV00u4Nbbhx
         LJsQ/aMdXX53sjsWs2TT4iRE6pOxVFof2+i9w3mva4CnG/DVkcJ06a4nXfkEFVd7wlcy
         ZEjP4OXwp3wE2UrrgjBnXmXtPOQeJ03xzHwlLd0AoRhFHJjWmlWmUIHPF8LNTh5H1qeM
         nCjqybhetEH9PC6qHC0jOtmrMfC/643JlyPjzTHEpfMoEOoSCkFQiYrxjw+tyfKcK98J
         anZfLav5vRRmgG7neFA+dhaMIWEMKm7J/QLQDgj9ewXWZR/c0/4R8e2kWQk7Vlo+tjtF
         3aVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=yvv2xnA6HSsaDM0hNLpCq5cOsPLEOcjtp6Gg5uV6AQ0=;
        b=HHMGEpLBUfaq2cAW7uIDEWxP2ov/160rZppYRt3Ri6c0Sn1UEC0ix+p3U+AP9BHbTZ
         xv2UZ8grmR3B1uKIE+6zyDy2EErFQSl/rXHIi8dJ8O7GKRqxnd6yNFpIVtu9QkdvCRFt
         POw5LEi1TrJ3F2rzbiiWcVlDteSsxbQ7O4bZMrbrslNSTSx88Xp3/lJqJ9ElzooF7Dl9
         NbY3YftYkMbbSPJfGsysEtH2rC9nUhDr55IT2kobdFP6fzYaXAVsdcBFhPWJWnx48VTQ
         Fd7zb/9luTvI/ZdanBPuHWOIJlfC0U1bDUGXTxC2/UwQ0haGwI/yG6OYnbSfUqthD4G0
         D4bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=g9H0EqGd;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id y3si478836pgi.125.2019.06.26.17.06.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 17:06:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=g9H0EqGd;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45Z0YP74Bsz9s3l;
	Thu, 27 Jun 2019 10:06:17 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1561593978;
	bh=8Hr8+8sV64MiYrtvdI2lrD9HaUyy8PmtsfdtCacMw54=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=g9H0EqGdNbqlbtj25nvoH/11hrDm8DuMaOp1WI2LIIcnmMWaYtU7IDhdzf63mWfUi
	 ol8nRp003otS79GiD1mz9pfHW9SYHi3ndgpmfqmIom1GKo6YfExsGeJet7CdAxlst1
	 d4jYVioAs9+LNVT8/+zGe17hND8oy9RK9Dp3LI124Qgkjbj5CD+UuWerqnY5wnxZUT
	 4b/BFhZvU464RccRBcYJ7lOjjTWMNoSKec3cK7S++SCAWsOq45UdHKwwRijv3mLgpA
	 IqvHH2J76vNfh2Jt23VRpL/IiYb/CQBVft3fZm6oXSh4kKzbCzYiZhAkco0w2mowg9
	 FMfDj5RvPZK9w==
Date: Thu, 27 Jun 2019 10:06:17 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Nicholas Piggin
 <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
 linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 linux-next@vger.kernel.org
Subject: Re: [PATCH] powerpc/64s/radix: Define arch_ioremap_p4d_supported()
Message-ID: <20190627100617.74c74e79@canb.auug.org.au>
In-Reply-To: <1561555260-17335-1-git-send-email-anshuman.khandual@arm.com>
References: <1561555260-17335-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/n9_h8L+fKQmZXfOCydxkhZu"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/n9_h8L+fKQmZXfOCydxkhZu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Anshuman,

On Wed, 26 Jun 2019 18:51:00 +0530 Anshuman Khandual <anshuman.khandual@arm=
.com> wrote:
>
> Recent core ioremap changes require HAVE_ARCH_HUGE_VMAP subscribing archs
> provide arch_ioremap_p4d_supported() failing which will result in a build
> failure like the following.
>=20
> ld: lib/ioremap.o: in function `.ioremap_huge_init':
> ioremap.c:(.init.text+0x3c): undefined reference to
> `.arch_ioremap_p4d_supported'
>=20
> This defines a stub implementation for arch_ioremap_p4d_supported() keepi=
ng
> it disabled for now to fix the build problem.
>=20
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-next@vger.kernel.org
>=20
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> This has been just build tested and fixes the problem reported earlier.
>=20
>  arch/powerpc/mm/book3s64/radix_pgtable.c | 5 +++++
>  1 file changed, 5 insertions(+)
>=20
> diff --git a/arch/powerpc/mm/book3s64/radix_pgtable.c b/arch/powerpc/mm/b=
ook3s64/radix_pgtable.c
> index 8904aa1..c81da88 100644
> --- a/arch/powerpc/mm/book3s64/radix_pgtable.c
> +++ b/arch/powerpc/mm/book3s64/radix_pgtable.c
> @@ -1124,6 +1124,11 @@ void radix__ptep_modify_prot_commit(struct vm_area=
_struct *vma,
>  	set_pte_at(mm, addr, ptep, pte);
>  }
> =20
> +int __init arch_ioremap_p4d_supported(void)
> +{
> +	return 0;
> +}
> +
>  int __init arch_ioremap_pud_supported(void)
>  {
>  	/* HPT does not cope with large pages in the vmalloc area */
> --=20
> 2.7.4
>=20

I will add that as a merge resolution patch for the akpm-current tree
merge today.

--=20
Cheers,
Stephen Rothwell

--Sig_/n9_h8L+fKQmZXfOCydxkhZu
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0UCHkACgkQAVBC80lX
0GzSRwf7BzDnZme1lz1V4QMONN1IuVY+pZX1QXKrRyb02gfpevX+bps5fVXU900w
Ba2QoMMkdVL042M4+W390SZxydX+BTcEfgxSgEFxQNKNv+3qolu6YKdQGszWhl5y
8I6VTUln4K3U+5QrEsx2GOfr+TP1ktGlrDQRvn58tkfr0GBy8eu5VvKMM+3zyh/L
iYqND4uA2ufFY550R3KI9uCh2y7nbaOIm6GWqIiBmwEQBiRctcL1EQMuKqQii938
bFS8SbP7WHkdRGB9L6AMACbjEPGLPwWodrMd0oA1yhcfYz38wkIJPVrI1cTmltS0
jmhRFG6gblzMWAbvnlBmbS3Zrs33bg==
=UR4X
-----END PGP SIGNATURE-----

--Sig_/n9_h8L+fKQmZXfOCydxkhZu--

