Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8FE9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:17:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D3EA2229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:17:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D3EA2229F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bluematt.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EDCE8E0002; Thu, 14 Feb 2019 15:17:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0748F8E0001; Thu, 14 Feb 2019 15:17:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E58268E0002; Thu, 14 Feb 2019 15:17:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B671D8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:17:51 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a199so6046905qkb.23
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:17:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :subject:from:in-reply-to:date:cc:content-transfer-encoding
         :message-id:references:to;
        bh=/Wr4ZLkq9aHEE1cN+LAtwbm46Ug5i36H8ynIAmwOjx4=;
        b=tpUZFsT3gsIIWYZqPrQTVj39Bg6sSees1pTd9rkjvMPQzD0dpr2k0xF5IaF2acLj9m
         qpODKi0LSm6pQaPM8Z6fKmuTF/DSRZIiYr3b0EakbsAIFh++mmyT4QaYcxJDqLUe23F4
         qA7ty9q5TqsqPWj3Maf5fGs+9sK+DsdQt6EKsFaGW6/FFagQrK8BIdV3ydKIANnMoPxf
         +Wj9LZxI8/HEStUhzQt3RX9VFomUXq+Jj7QLW/XPSgmPjK08DHWWBp1Ph7k/nlGC9hZT
         vF3/44X+A8qtuJ73c1X7mEEmiNc3CiTUvFSfl1tPYI9Wd6YFPqOzNFTK2xzP/qidiZAy
         +wAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kernel@bluematt.me designates 192.241.179.72 as permitted sender) smtp.mailfrom=kernel@bluematt.me
X-Gm-Message-State: AHQUAuZISAYaOfaIoOG4h9nIKqhcVPZA9UEbWY56tdIADZUsoh4rvAJR
	L6b7qtgPMPaoEBsc/wKhHPu0ljbysxEuA1wyhL+W6jIfXixVs3tzu/FJZ9Xke/Gctm6W4EVlzDW
	LQtDBL/c6xtnxGFifRMUZWWlT6oZmhNc7EcAvqaVPemQHTaU1hzthSe/WtDkvxX3cbQ==
X-Received: by 2002:ae9:ea0f:: with SMTP id f15mr4387064qkg.113.1550175471458;
        Thu, 14 Feb 2019 12:17:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia2s0Haj31kYdLaVlwRsQF9IzcXfJCAdE8iNf6wb1/76yw/9GiB4J4fPr7z8tVmmWknBBc5
X-Received: by 2002:ae9:ea0f:: with SMTP id f15mr4387034qkg.113.1550175470867;
        Thu, 14 Feb 2019 12:17:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550175470; cv=none;
        d=google.com; s=arc-20160816;
        b=02UqEXpnaILaWuLobYxlcuMMt0XiCAv8AJNMUfkIKivc/28/lgAxr1I0JiAA2UpJC1
         WQ/mESuwROqASv8DhdYW3T88Q2+3GGmAucNrhAtBYVU6DRD0+Uc4DPxJGXDrQPF/z+wo
         dOHDG0Q3OWwWd7k1jYYaKNKIlVcQ3gEW5/9AgadbF/imSXl6nr1e4Prpb4ylq+UTunEL
         wlacp5YCoGdiRoNIytlhjFKprxJDsSpfEFHLJaN9E4W1ZvH3u+G8Yk/0h8LpYqR0NT1e
         unM8HV8dL6IUbnNhHfJ9oUTWdqERTYkZJ1P+bIqoWKqnwatgvla565CjBOQ8YmiuQolM
         KlLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version;
        bh=/Wr4ZLkq9aHEE1cN+LAtwbm46Ug5i36H8ynIAmwOjx4=;
        b=S8H/IThhlgGyts5cM16YjFCYejEbogdvwZIyuZNqSkuV+LODKZp6mHGy9JgtqQp3Vu
         bifKUgaItQhP84dmQwQWaRlQpCD/pDlO6+aWbrgsyz8VzhZLs5gMFTugl6adsRmOVld+
         +YSB//vvPh2VPjr+4T8Fn0M+xuw5JSl47BmANFsmvwkvFs14Wezaa9tizTKpTl3uqgvh
         PhuBGNgc+nAn40FdxVgR/1WL6ZNClAjdj9Evi5WkQMtpPyQvSGwEwthJ1j+0Kx+QOeNa
         ZyMiILzudsjCS2s1HRN8mKz/GPHZmmh08KqdHPdZj5glQKB4qAfWn7BxMR7YFR+qL31V
         z2WA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kernel@bluematt.me designates 192.241.179.72 as permitted sender) smtp.mailfrom=kernel@bluematt.me
Received: from mail.bluematt.me (mail.bluematt.me. [192.241.179.72])
        by mx.google.com with ESMTPS id r21si715898qtn.351.2019.02.14.12.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 12:17:50 -0800 (PST)
Received-SPF: pass (google.com: domain of kernel@bluematt.me designates 192.241.179.72 as permitted sender) client-ip=192.241.179.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kernel@bluematt.me designates 192.241.179.72 as permitted sender) smtp.mailfrom=kernel@bluematt.me
Received: from [192.168.0.100] (unknown [69.202.205.58])
	by mail.bluematt.me (Postfix) with ESMTPSA id E3B16139579;
	Thu, 14 Feb 2019 20:17:49 +0000 (UTC)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [Bug 202149] New: NULL Pointer Dereference in __split_huge_pmd on PPC64LE
From: Matt Corallo <kernel@bluematt.me>
X-Mailer: iPhone Mail (16D57)
In-Reply-To: <87bm4achnu.fsf@linux.ibm.com>
Date: Thu, 14 Feb 2019 15:17:48 -0500
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linuxppc-dev@lists.ozlabs.org, bugzilla-daemon@bugzilla.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <CCDBD6B9-31CD-4B94-AA8F-9BEF1C133AED@bluematt.me>
References: <bug-202149-27@https.bugzilla.kernel.org/> <20190104170459.c8c7fa57ba9bc8a69dee5666@linux-foundation.org> <87ef9nk4cj.fsf@linux.ibm.com> <ed4bea40-cf9e-89a1-f99a-3dbd6249847f@bluematt.me> <8736q2jbhr.fsf@linux.ibm.com> <A61367CF-277E-4E74-8A9D-C94C5E53817B@bluematt.me> <87bm4achnu.fsf@linux.ibm.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hey, sorry for the delay on this. I had some apparently-unrelated hangs that=
 I believe were due to mpt3sas instability, and at the risk of speaking too s=
oon for a bug I couldn't reliably reproduce, this patch appears to have reso=
lved it, thanks!

> On Jan 21, 2019, at 07:35, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com> w=
rote:
>=20
>=20
> Can you test this patch?
>=20
> =46rom e511e79af9a314854848ea8fda9dfa6d7e07c5e4 Mon Sep 17 00:00:00 2001
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Date: Mon, 21 Jan 2019 16:43:17 +0530
> Subject: [PATCH] arch/powerpc/radix: Fix kernel crash with mremap
>=20
> With support for split pmd lock, we use pmd page pmd_huge_pte pointer to s=
tore
> the deposited page table. In those config when we move page tables we need=
 to
> make sure we move the depoisted page table to the right pmd page. Otherwis=
e this
> can result in crash when we withdraw of deposited page table because we ca=
n find
> the pmd_huge_pte NULL.
>=20
> c0000000004a1230 __split_huge_pmd+0x1070/0x1940
> c0000000004a0ff4 __split_huge_pmd+0xe34/0x1940 (unreliable)
> c0000000004a4000 vma_adjust_trans_huge+0x110/0x1c0
> c00000000042fe04 __vma_adjust+0x2b4/0x9b0
> c0000000004316e8 __split_vma+0x1b8/0x280
> c00000000043192c __do_munmap+0x13c/0x550
> c000000000439390 sys_mremap+0x220/0x7e0
> c00000000000b488 system_call+0x5c/0x70
>=20
> Fixes: 675d995297d4 ("powerpc/book3s64: Enable split pmd ptlock.")
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
> arch/powerpc/include/asm/book3s/64/pgtable.h | 2 --
> 1 file changed, 2 deletions(-)
>=20
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/i=
nclude/asm/book3s/64/pgtable.h
> index 92eaea164700..86e62384256d 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -1262,8 +1262,6 @@ static inline int pmd_move_must_withdraw(struct spin=
lock *new_pmd_ptl,
>                     struct spinlock *old_pmd_ptl,
>                     struct vm_area_struct *vma)
> {
> -    if (radix_enabled())
> -        return false;
>    /*
>     * Archs like ppc64 use pgtable to store per pmd
>     * specific information. So when we switch the pmd,
> --=20
> 2.20.1
>=20

