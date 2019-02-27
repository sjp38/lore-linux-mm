Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2B42C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:40:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AF3A21873
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:40:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AF3A21873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=de.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C00B28E001D; Wed, 27 Feb 2019 12:40:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B87CD8E0001; Wed, 27 Feb 2019 12:40:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A29568E001D; Wed, 27 Feb 2019 12:40:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 739468E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:40:32 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id r21so7613009oie.11
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:40:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:references:mime-version:message-id
         :content-transfer-encoding;
        bh=gXMW0K3Lmn5/vqfZW+JOTVgQGxsFi5odITHtSzY3JzE=;
        b=NuzVdDcgcHFZVYh4WMEYezGEqQwhK2IA1N/1cAZ4NK8WFDy2NSeubcXnSxKS30HR8a
         DvXXMCvJzlmZQ7yuk2aqLZ/EgKWtdwvt8/PXbPiAlKoMaod6vrbh6583jTgqspJ2Jx73
         JnNk6nNxXWh2xitQjokB4nj6sVcnNPRLQxneHKKZjmVUHRcDlgaWrL4GJFCBh/142Wiy
         e3lXA41nA8MooiIq2vfK5Ga8VRwd7ED7i+7Oeye5e921zobU1+GYohnOoSLSAJhJQPo6
         LVgi33OFS3vnrZ57XeZ7CTERD0ADWa5qXHZMysiBwQ+dai96pteIrsTeVWY7nl2dkybP
         DhQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of schwidefsky@de.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=schwidefsky@de.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuame4/LyNsdvZbP7KRkl0rZS1lYk1Q53Vq5lpQWfNeI3G8xNQL9
	Te1F1cPIEGtKkGwnBVbN+kkYX+HXHdIKaZqFKm5LuG13SAXmYW8Lw2SS7o06vK/EYlTk96npnvk
	/qh0FLpuhFind7WecoECMy1bZtoMOCnWbcLsjqHPoQWKWS0vKkPfU9oGHqN59Rb/eAQ==
X-Received: by 2002:a9d:73d6:: with SMTP id m22mr2923944otk.322.1551289232240;
        Wed, 27 Feb 2019 09:40:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibr+eg+qLwFuZraNhRgdWxzoKRmjvlLT1m1vfolWxxiMCB5RbSLKkDKN/VgIiqHD7MTANjY
X-Received: by 2002:a9d:73d6:: with SMTP id m22mr2923903otk.322.1551289231316;
        Wed, 27 Feb 2019 09:40:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551289231; cv=none;
        d=google.com; s=arc-20160816;
        b=kB3o5x6LArPp6gwWk8WA4e+/wIuJQqHCFcn0tr+J++09L4x+Q5ujTLP5YZ8VwVV3qM
         Jd7r7dxrdwpCLG2csrsEq6B7TLIm1xBO8B7NY8325b9jy5ohODuDVR5Zan/OetgXCCDJ
         YIuERTWHde/b+tvXt6r68QIFQK9JzATL88UWGbqf1fIbiVFeZIC14YA67g7+Y8ZoUKjx
         /y8cAbvdS6wx4G7E+vsIkSJ5T7D+EXzw8NyJgSa4+8OdC7Oz31QcPgOjwkxyAB9E5f6o
         mMyRX2my+hQcCcwaQUKf9NbkatESnsFP3Ka0A/BR4u0Kg9rCf7WY0vyyrmk+KhU/nBaL
         DWTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:mime-version:references
         :in-reply-to:subject:cc:to:from:date;
        bh=gXMW0K3Lmn5/vqfZW+JOTVgQGxsFi5odITHtSzY3JzE=;
        b=qriXyQGtUmSMm//5c/XYHSQQwGYr2h7AUtfxdcEoIjN3A06E9rJsdk4vwQ8z/2+v8R
         tizEmTh3sI4F8nsP0z+qX1I1+AlQfncRdt2xBNugNisBmkEfyHCdfgFTjWU5irnAZW6P
         WqEfkoOQmtUQHRSxUybegGbQKq5Fu2CDlublY/jETfsrSWRy07M5vJVbGy4NxlcMx7LI
         Udhstwv1FezMbm9vLrOrWApK/KNGXb0rlDuRWzJnkIo7UuP4wY57uDyNvPQ25dAAVzSW
         ydmiE+5fZrHr1FnqIcXJ1/mVbgD3kpAwGNzt8SB4yT+B5r7D2yFzbhN1AgS7t7DnS9Ny
         hR2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of schwidefsky@de.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=schwidefsky@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 70si7045278otf.123.2019.02.27.09.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 09:40:31 -0800 (PST)
Received-SPF: pass (google.com: domain of schwidefsky@de.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of schwidefsky@de.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=schwidefsky@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1RHcLpQ012274
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:40:30 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qwwcudne8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:40:29 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 27 Feb 2019 17:40:20 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 27 Feb 2019 17:40:15 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1RHeEEs23527458
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 17:40:14 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3A060A405C;
	Wed, 27 Feb 2019 17:40:14 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 90B1EA4054;
	Wed, 27 Feb 2019 17:40:13 +0000 (GMT)
Received: from mschwideX1 (unknown [9.152.212.60])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 27 Feb 2019 17:40:13 +0000 (GMT)
Date: Wed, 27 Feb 2019 18:40:12 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
        Ard Biesheuvel
 <ard.biesheuvel@linaro.org>,
        Arnd Bergmann <arnd@arndb.de>, Borislav Petkov
 <bp@alien8.de>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Dave Hansen
 <dave.hansen@linux.intel.com>,
        Ingo Molnar <mingo@redhat.com>, James Morse
 <james.morse@arm.com>,
        =?UTF-8?B?SsOpcsO0bWU=?= Glisse
 <jglisse@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Thomas
 Gleixner <tglx@linutronix.de>,
        Will Deacon <will.deacon@arm.com>, x86@kernel.org,
        "H. Peter Anvin" <hpa@zytor.com>, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, Mark
 Rutland <Mark.Rutland@arm.com>,
        "Liang, Kan" <kan.liang@linux.intel.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org
Subject: Re: [PATCH v3 18/34] s390: mm: Add p?d_large() definitions
In-Reply-To: <20190227170608.27963-19-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
	<20190227170608.27963-19-steven.price@arm.com>
X-Mailer: Claws Mail 3.13.2 (GTK+ 2.24.30; x86_64-pc-linux-gnu)
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19022717-0012-0000-0000-000002FAEED7
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022717-0013-0000-0000-0000213297C2
Message-Id: <20190227184012.2e251154@mschwideX1>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-27_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902270119
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2019 17:05:52 +0000
Steven Price <steven.price@arm.com> wrote:

> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
> 
> For s390, we don't support large pages, so add a stub returning 0.

Well s390 does support 1MB and 2GB large pages, pmd_large() and pud_large()
are non-empty. We do not support 4TB or 8PB large pages though, which
makes the patch itself correct. Just the wording is slightly off.
 
> CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
> CC: Heiko Carstens <heiko.carstens@de.ibm.com>
> CC: linux-s390@vger.kernel.org
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  arch/s390/include/asm/pgtable.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
> index 063732414dfb..9617f1fb69b4 100644
> --- a/arch/s390/include/asm/pgtable.h
> +++ b/arch/s390/include/asm/pgtable.h
> @@ -605,6 +605,11 @@ static inline int pgd_present(pgd_t pgd)
>  	return (pgd_val(pgd) & _REGION_ENTRY_ORIGIN) != 0UL;
>  }
> 
> +static inline int pgd_large(pgd_t pgd)
> +{
> +	return 0;
> +}
> +
>  static inline int pgd_none(pgd_t pgd)
>  {
>  	if (pgd_folded(pgd))
> @@ -645,6 +650,11 @@ static inline int p4d_present(p4d_t p4d)
>  	return (p4d_val(p4d) & _REGION_ENTRY_ORIGIN) != 0UL;
>  }
> 
> +static inline int p4d_large(p4d_t p4d)
> +{
> +	return 0;
> +}
> +
>  static inline int p4d_none(p4d_t p4d)
>  {
>  	if (p4d_folded(p4d))


-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

