Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFDC5C468BC
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 06:17:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81D23206E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 06:17:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gBDc6s5w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81D23206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACFE76B0266; Mon, 10 Jun 2019 02:17:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A80A06B026A; Mon, 10 Jun 2019 02:17:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96F736B026B; Mon, 10 Jun 2019 02:17:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3C06B0266
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 02:17:13 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so5168993pla.3
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 23:17:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=QUcM2bfCpfs+CF5Q3MEY89CqL+kCuIGlPKR4lAGQQUE=;
        b=PZo6P+yZHPTU+BcqO2u8v2K5qDXZbNH1HNFK1OyMqd4225c7AfoU/Z5uVCyFGvphja
         iWX7Sewf9ZZ4NFeUyGJxUo5yP2mZl8ofaeb4/ky2BBSxQSaGfMXVlAepsDu+xpLyq2sT
         V4p48wvjleLe8IiYgxp8tmSIcZiCcV5mcVC/e/XAplbZDwlvEf8rVuMr/4Idbp1FZzww
         xC/iVp6SoUbCWdQKasiadzNMOanxxOyfW8749ZLL/w5YrNckWG6bmN8bpIy0sNhHF2TY
         XKAzk6rGpydG2gh1B8hk1c7UTcYopn/LLNY0qBPo1IgQuR+LKhTrsXq1UoMHuaoU/X1o
         4eGg==
X-Gm-Message-State: APjAAAV1bnLiHDSuO+1JXaB3w31jgSBXnn7ItjxyKKLn2UY4QoYHf0j8
	5PbXzWubbMAs3934K9oKKout3L1c/lJWW65iY8/vuvLvkX3UEHowMSHndsMp4FTdQkcGkkHAZ0f
	h/KDhTdOtw25uBW80VIKx1QQyGjoWVBovoVsABhK9wmaleOZlokekmnmIXdLf8yUTVQ==
X-Received: by 2002:a63:4d0b:: with SMTP id a11mr14034998pgb.74.1560147432904;
        Sun, 09 Jun 2019 23:17:12 -0700 (PDT)
X-Received: by 2002:a63:4d0b:: with SMTP id a11mr14034970pgb.74.1560147432094;
        Sun, 09 Jun 2019 23:17:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560147432; cv=none;
        d=google.com; s=arc-20160816;
        b=vkTul0TT2gzcXWGghZ+ORejUZL/9Re/gUpcxeAcUZf5O+D2Kl4TW/gP/gfVE72s95r
         jclT7kGrPNo3fvULXfknnwsMG8epsq8sjkgX3poBAAENJTdRiMy2jDXgPAWJrsfFMiTa
         rWs1c16gBHUMyFBK0vqAnK7wVHM+HwyC5gvF1coOdhWTgv5GZ31Cm7eTKBEJq2BsSjHo
         nu4POgUnAV6+Gn3ZsVL3nnxNMmC0kRiJG/JfnOqk9n+enVUF7BylW4jH2mkZJTyg+/Iu
         DlMShlsErFof8Qja2a6HzeLIobNBDtCLrCOohEKrP0f+eufoUWsGxUink1o8PWsAcrKb
         ooFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=QUcM2bfCpfs+CF5Q3MEY89CqL+kCuIGlPKR4lAGQQUE=;
        b=EXpyp0SSoDfz/d8GzKQKEvmLTbESSAIi8mGzuhzRdySn8peNdY7H1lZMx21IEnaTsT
         xUzFSVw3L+EpYVjkRrfCmXMyv+zpKUcbpp7UmtAYBz3XWSYkyGpqGWldZxRBJ0dvfEuD
         HZNxWImRpjTM+VeGKj960GKBvEjPMoSPR67p+HK1kMZTadswViq41yOX+VGGYjBIF05U
         yRb7wQe+h4hWwcVKSVLy2nuRBakhIGNM4bEloafATaF58lPkXaXI7yKZpjbWIYt3hjDb
         +ocq3LkWHLp/lNtuqHW6UT3u4y/7Hdi6l/u2qet7R1gFNVo6+63kFC30YS/cu6RLu6z6
         cY7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gBDc6s5w;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s198sor4361747pgs.39.2019.06.09.23.17.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 23:17:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gBDc6s5w;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=QUcM2bfCpfs+CF5Q3MEY89CqL+kCuIGlPKR4lAGQQUE=;
        b=gBDc6s5wefUKJtnMQTjQlBkkBMula3LNzwu5ME6utMbGVzJqi2ERsUVzab2XgCGaqv
         DQJ7aci9f7H4UxABCmtK3IE2t8OCIG662iAbqbilxNeqS0dImhTkOdQHbMhey38dlu7s
         PqfAltLOAHAzHYFnBJttsikw1L9OCZE32ELJUTXo6NbGTBY4EJWHKsIZWbjH8QdjZ4ji
         mHYGdGjvjHo305WfGXJMbWPHUTRwh5L6q/9f5A5e71SrlX9R1JG594iKIVUHm0Sq/KGn
         FcrgeoxtVcPtQACR+Fk9WCSjtKK/cisrT2gfbd54KXApIEX6H/VO8hAhENIFVIXdYOWv
         T9hQ==
X-Google-Smtp-Source: APXvYqw34wde3ng/Qx9tQNG4a1tJVYDA4kMn2ZLcc1X5fYZq17VRglbkiBgljRp0MRwhwJZOeiXzvg==
X-Received: by 2002:a63:de43:: with SMTP id y3mr14823919pgi.271.1560147431601;
        Sun, 09 Jun 2019 23:17:11 -0700 (PDT)
Received: from localhost (60-241-56-246.tpgi.com.au. [60.241.56.246])
        by smtp.gmail.com with ESMTPSA id q1sm15483011pfb.156.2019.06.09.23.17.09
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 09 Jun 2019 23:17:10 -0700 (PDT)
Date: Mon, 10 Jun 2019 16:14:48 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/4] arm64: support huge vmap vmalloc
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
	<20190610043838.27916-2-npiggin@gmail.com>
	<c49a8fa7-c700-b45b-31b8-1d49afc42136@arm.com>
In-Reply-To: <c49a8fa7-c700-b45b-31b8-1d49afc42136@arm.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1560147087.rpy7pimoej.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Anshuman Khandual's on June 10, 2019 3:47 pm:
>=20
>=20
> On 06/10/2019 10:08 AM, Nicholas Piggin wrote:
>> Applying huge vmap to vmalloc requires vmalloc_to_page to walk huge
>> pages. Define pud_large and pmd_large to support this.
>>=20
>> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
>> ---
>>  arch/arm64/include/asm/pgtable.h | 2 ++
>>  1 file changed, 2 insertions(+)
>>=20
>> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/p=
gtable.h
>> index 2c41b04708fe..30fe7b344bf7 100644
>> --- a/arch/arm64/include/asm/pgtable.h
>> +++ b/arch/arm64/include/asm/pgtable.h
>> @@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *fi=
le, unsigned long pfn,
>>  				 PMD_TYPE_TABLE)
>>  #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) =3D=3D \
>>  				 PMD_TYPE_SECT)
>> +#define pmd_large(pmd)		pmd_sect(pmd)
>> =20
>>  #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
>>  #define pud_sect(pud)		(0)
>> @@ -438,6 +439,7 @@ extern pgprot_t phys_mem_access_prot(struct file *fi=
le, unsigned long pfn,
>>  #define pud_table(pud)		((pud_val(pud) & PUD_TYPE_MASK) =3D=3D \
>>  				 PUD_TYPE_TABLE)
>>  #endif
>> +#define pud_large(pud)		pud_sect(pud)
>> =20
>>  extern pgd_t init_pg_dir[PTRS_PER_PGD];
>>  extern pgd_t init_pg_end[];
>=20
> Another series (I guess not merged yet) is trying to add these wrappers
> on arm64 (https://patchwork.kernel.org/patch/10883887/).
>=20

Okay good, I'll just cherry pick it for the series.

Thanks,
Nick

=

