Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44383C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 02:17:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D028D218D3
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 02:17:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LI6Pwpnp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D028D218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D4BD6B0003; Wed, 20 Mar 2019 22:17:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15DEB6B0006; Wed, 20 Mar 2019 22:17:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F40786B0007; Wed, 20 Mar 2019 22:17:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B05236B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 22:17:35 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u8so4323528pfm.6
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 19:17:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=thSPW+DbNyo/B6n0hblHK9PLdW84i8rPMI1jjSEdyzE=;
        b=RhTe3XmMhsUTMo7O0AEhIfsO90L20Pw7Z7ti83CIHMJ1B8KLEe+CnwYVD3zeo3JC4a
         HtwJAjO9BNUVaEVTngoqewf+6iDQNl3Lo9gVgzz3aI1CP9EL94k5hYyXCcMnoFU51zu9
         uIe6iWasT+sARAqeboKshLWbfHx65aExrRrKcN2lXFcXKWFTRMd5bcbi0nfGJ7ieT0Qw
         fUg+/6nqESxFyN+67HlpVmO3O7t5tOWLIyXUuqzPrbMfGwnaMCINXsrU7lcJ2r19UBZR
         pEK9AlFuWYaKaw5KtRI7MPpOpcqN6BrIdZIx5cGsinpwng+bSyAHN4OV8E+ln53b5At8
         uE4w==
X-Gm-Message-State: APjAAAXZ8Mtv+CK7Qxs8N8fE0qV5UH5Sjflta9QxlTLq2r8EKG3Ep0Zg
	Gqs8Dg+vhmosNdvmUzORLtHCgPGFlD9MPCwQDrKTGkPkji41HWvJenWLvE1OGxl8yx8SC4J8rIh
	XBdTS6NH9WJmy2HCKqNMn6ievwolszn2fEMkr4zE4cX1B+lHY4Y5PZkqqKIv3ifZb9Q==
X-Received: by 2002:a17:902:b60c:: with SMTP id b12mr1014655pls.261.1553134655225;
        Wed, 20 Mar 2019 19:17:35 -0700 (PDT)
X-Received: by 2002:a17:902:b60c:: with SMTP id b12mr1014600pls.261.1553134654414;
        Wed, 20 Mar 2019 19:17:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553134654; cv=none;
        d=google.com; s=arc-20160816;
        b=xQPIwo1kAkbnVLRCYWut5cB6fQof7bFcbXh/LI11majHT5cQL0Td9IaVcI/E8aCLmN
         xPTRB8/+Uxrdm1lM1RVKLcY1Zh+s2sjeTUQ8+8rxyjX0UfW6Sxl2Jh8btTJkasuBhD8h
         I1Lc0NfP3QUr7+3N43T2B0c1uRPbpy00GrkjYpGlpBb0RyT/iriM0jmwx3H0P+kSbtWQ
         +xvth+2yCc6kZ29TR9BJCBPzg0AOe33WqqIPbYNpqk5Ahd4mqZ2oCeENEg+wyKgJ0F/2
         3tDaJxXSojJYJgVXM+iHRmJDCoMrVHd3aU44pMGoVj+in/+nj5T25LBlcvxjG6FNmPbc
         gsBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=thSPW+DbNyo/B6n0hblHK9PLdW84i8rPMI1jjSEdyzE=;
        b=Mwc1QWX7PVlvipFN6kmjYsD0UMpUVUfmMsyLBcNIcefS9jP1JM9rpvP8CRSL+KV0Vc
         F17+oLJCMU6Ze+fXQoHXZqkyqRQEE/f6qwG1NDpJ0f39G/zw8JvOSQ5zRaCyYHEpAU7q
         jIdwdfgcqBviVAreCHC1Huh70QEHq8YaUQpOkdtWyB0xKYoAMIwmHkRGOU2EHXB1jer0
         SfOr68+LepP/aO2Km7wVLY9EkzWRaI+JIyuttPGzu3dadFKmx43jjmfSas6tY9nbztv7
         0LXlccZX/65jXYv14lRGZh+ZCGh/XEJcmRcVndOMt4RqlUD61oYnrVaHwGN4ReCJPCcX
         7j5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LI6Pwpnp;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b15sor4046997pfb.23.2019.03.20.19.17.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 19:17:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LI6Pwpnp;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=thSPW+DbNyo/B6n0hblHK9PLdW84i8rPMI1jjSEdyzE=;
        b=LI6PwpnpQ92HB00y16XO2SI6qWg9n7wSZ4F/O+61BlrKyDJ7HGGwMnqxdAcH0Fis5t
         JYMNy9JEnSoodmBmoaI5tq4M4toMcYvVpNnr37g1+zs9/zNVd6Ln+ns3RhoEOqXPs+sd
         fJEIXiNfbRPJFxxPR8Z1AEJSy/6B6Nb92X4WHwzvL1XfJ7NXQs305EEgbeyk4goQHVv6
         4AFDYd6bDAiQZ3qwlkub3je2sgnh+Zphq8zsWYuDLMfP5CpHCBsDVJvb//TjyHjM6px3
         rZffcEqZiuonAV/itsYMU5DkWXX5YnlG/uZlFGuBiPzASdb2k1CdUHDtkoh/KGNb+FES
         bniA==
X-Google-Smtp-Source: APXvYqwoJhIIGpas5lhZvTnUrMsQiQfmzyToN39SYYfDiPH8wan45oLPsQ6IPZM2Kz6fnO2XW+c8lA==
X-Received: by 2002:a62:55c7:: with SMTP id j190mr983047pfb.226.1553134653801;
        Wed, 20 Mar 2019 19:17:33 -0700 (PDT)
Received: from localhost ([218.189.10.173])
        by smtp.gmail.com with ESMTPSA id j71sm7326588pfc.6.2019.03.20.19.17.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 19:17:33 -0700 (PDT)
Date: Thu, 21 Mar 2019 10:17:21 +0800
From: Yue Hu <zbestahu@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: iamjoonsoo.kim@lge.com, mingo@kernel.org, vbabka@suse.cz,
 rppt@linux.vnet.ibm.com, rdunlap@infradead.org, linux-mm@kvack.org,
 huyue2@yulong.com
Subject: Re: [PATCH] mm/cma: fix the bitmap status to show failed allocation
 reason
Message-ID: <20190321101721.00006f19.zbestahu@gmail.com>
In-Reply-To: <20190320151245.ff79af49fe364ac01d4edb14@linux-foundation.org>
References: <20190320060829.9144-1-zbestahu@gmail.com>
	<20190320151245.ff79af49fe364ac01d4edb14@linux-foundation.org>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Mar 2019 15:12:45 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 20 Mar 2019 14:08:29 +0800 Yue Hu <zbestahu@gmail.com> wrote:
>=20
> > Currently one bit in cma bitmap represents number of pages rather than
> > one page, cma->count means cma size in pages. So to find available pages
> > via find_next_zero_bit()/find_next_bit() we should use cma size not in
> > pages but in bits although current free pages number is correct due to
> > zero value of order_per_bit. Once order_per_bit is changed the bitmap
> > status will be incorrect. =20
>=20
> When fixing a bug, please always describe the end-user visible runtime
> effects of that bug?
>=20

Hi Andrew,

=46rom perspective of bitmap function, the size input is not correct. It will
affect the available pages at some position to debug the failure issue.

This is an example with order_per_bit =3D 1

Before this change:
[    4.120060] cma: number of available pages: 1@93+4@108+7@121+7@137+7@153=
+7@169+7@185+7@201+3@213+3@221+3@229+3@237+3@245+3@253+3@261+3@269+3@277+3@=
285+3@293+3@301+3@309+3@317+3@325+19@333+15@369+512@512=3D> 638 free of 102=
4 total pages

After this change:
[    4.143234] cma: number of available pages: 2@93+8@108+14@121+14@137+14@=
153+14@169+14@185+14@201+6@213+6@221+6@229+6@237+6@245+6@253+6@261+6@269+6@=
277+6@285+6@293+6@301+6@309+6@317+6@325+38@333+30@369=3D> 252 free of 1024 =
total pages

Obviously the bitmap status before is incorrect, i can add this effect desc=
ribtion
in v2, but seems the patch has been merged?

Thx.

