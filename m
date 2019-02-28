Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06F7AC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:37:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C181E2171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:37:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C181E2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52D438E0003; Thu, 28 Feb 2019 06:37:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 504068E0001; Thu, 28 Feb 2019 06:37:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F53C8E0003; Thu, 28 Feb 2019 06:37:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB11B8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:37:09 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id h16so8379265edq.16
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:37:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=53FU41LaTNdbtI/ZXh2UKiryTlrZPh5Cuybqkgl/qvs=;
        b=XP/TgCpx2kqYSAkMaPx+ca51qP6WG6E1foRKRwcZlo2BdHK6opjDaoEoNOmNYqnAnZ
         wpllAyds1Q8ANrxUruc56DQBRtZ0UVe5s/GtvxWjS+IgP40X9hbPqqeMTPA8wPzjU2I/
         09FqQxx4bgG/oPeA5lKaGCOgZbs8IBLeDVQhryeqaIyweuVWbrqMa4d1w7VIK2T7IxIk
         NJg9nMnhN08LulLjPqv0Le2z1LDcS0GIIc77fFmh2KLjglZLj1YEUWMlP0t8OeUvso2/
         Y4E8Q0Nfur96wtg5+bz+8CnwGumoVNIoJ0yjbHh2wSz8nVKy8syTSHdHYOLPZhHYhTLa
         Dzvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAualvQkqOaro81m2f6S+bSmIv7dalVher04BEXEacAx/nmAyDiEr
	CMNg70e6l/HOmi3Afoj2omfleDeWIU1Qc/GD+W7hjW0NSSsCmU2DhVmeLCW5L4BW3f6M4/FPI1K
	5IRGI8WKVJ93Y0bVsX7M4MoCGGmDcI9KuQX+ZiK+k6D2UmA8T0AJORuaFYT/VzaE1Ew==
X-Received: by 2002:a50:b84d:: with SMTP id k13mr6210847ede.275.1551353829434;
        Thu, 28 Feb 2019 03:37:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZKd4BYhsXwe7n2ZajnyXZ4mxeR0dsnSPJqlPJogosJL/AEr3Ww+ZEiJ3sLD0sOGLEl8FBG
X-Received: by 2002:a50:b84d:: with SMTP id k13mr6210805ede.275.1551353828660;
        Thu, 28 Feb 2019 03:37:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551353828; cv=none;
        d=google.com; s=arc-20160816;
        b=XtF2gFrOpCkwvCAc7T75Vx/G+4f1otbly3Vjh6zKG//DjFq98LjbYMleiDGIi9Wlvs
         lNGMCXl657PzPYrkYEYTD/d+MLagIbLJACYvBdDfJMyPZBME8IOsnDzMa1JseFmYrVip
         UyM1pAoywpDtOXvgGk/FVCwtvvmm5zT9xX9yTqrZj0Wlz7bynzDAW3mQTq4eDPvl+59D
         /Kiy/DXcmaZK1EMAIA1cTi2O3Z/VRrA8sYPwbwHbNPJiunJzCaDM9EzFlRQBqYTSJrH7
         pUvdQsfQLgnPqFCoo4Tlwj8dexW4Lq+1M1Qy4RpuvdpkIwNiI81P5E+MZd5gFgVmGNhR
         Eg8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=53FU41LaTNdbtI/ZXh2UKiryTlrZPh5Cuybqkgl/qvs=;
        b=yXL1Hk3m4tvTLv+cp+ipSsg4pISutN5ztJ71kgMZ5K2nD5l9Qnb+DHvPYVOYEyToX/
         E1nwjM6lpTiBmMBXIsHvEXA1ZKMqmiJzEdkvI4UN/mhozYyCQQzAGdB3GS/Stf8pVBIH
         eItkbcT8iNxRSgQxWxnGO6Za8OWRFoRjK5RwiaI0E7+yBX4tI0ht94eUUicElBxmz6k+
         J59O9IfPB5P1nZdFHDOsYqZMEdg7YRjyk+8ghOQIEhuFo/0pNbPLH71FhK5m7nUC0hhE
         hsYzOangCySxJciEOs4m9i4Pn2DJ8T1IpKL6rlu3m5iKsSpIxta1+fVAGsIM2OfEyBeD
         fPow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i20si1826354ejv.191.2019.02.28.03.37.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 03:37:08 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1SBXxZ0046087
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:37:07 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qxdxt2v13-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:37:06 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 28 Feb 2019 11:37:04 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 28 Feb 2019 11:36:57 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1SBav1G61407436
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 11:36:57 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E8BD64C046;
	Thu, 28 Feb 2019 11:36:56 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 61E7D4C040;
	Thu, 28 Feb 2019 11:36:55 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 28 Feb 2019 11:36:55 +0000 (GMT)
Date: Thu, 28 Feb 2019 13:36:53 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Steven Price <steven.price@arm.com>, Linux MM <linux-mm@kvack.org>,
        Andy Lutomirski <luto@kernel.org>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Will Deacon <will.deacon@arm.com>,
        the arch/x86 maintainers <x86@kernel.org>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Mark Rutland <Mark.Rutland@arm.com>,
        "Liang, Kan" <kan.liang@linux.intel.com>,
        linux-m68k <linux-m68k@lists.linux-m68k.org>
Subject: Re: [PATCH v3 09/34] m68k: mm: Add p?d_large() definitions
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-10-steven.price@arm.com>
 <CAMuHMdXCjuurBiFzQBeLPUFu=mmSowvb=37XyWmF_=xVhkQm4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdXCjuurBiFzQBeLPUFu=mmSowvb=37XyWmF_=xVhkQm4g@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022811-0008-0000-0000-000002C5FFBF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022811-0009-0000-0000-0000223250FB
Message-Id: <20190228113653.GB3766@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-28_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902280081
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Feb 27, 2019 at 08:27:40PM +0100, Geert Uytterhoeven wrote:
> Hi Steven,
> 
> On Wed, Feb 27, 2019 at 6:07 PM Steven Price <steven.price@arm.com> wrote:
> > walk_page_range() is going to be allowed to walk page tables other than
> > those of user space. For this it needs to know when it has reached a
> > 'leaf' entry in the page tables. This information is provided by the
> > p?d_large() functions/macros.
> >
> > For m68k, we don't support large pages, so add stubs returning 0
> >
> > CC: Geert Uytterhoeven <geert@linux-m68k.org>
> > CC: linux-m68k@lists.linux-m68k.org
> > Signed-off-by: Steven Price <steven.price@arm.com>
> 
> Thanks for your patch!
> 
> >  arch/m68k/include/asm/mcf_pgtable.h      | 2 ++
> >  arch/m68k/include/asm/motorola_pgtable.h | 2 ++
> >  arch/m68k/include/asm/pgtable_no.h       | 1 +
> >  arch/m68k/include/asm/sun3_pgtable.h     | 2 ++
> >  4 files changed, 7 insertions(+)
> 
> If the definitions are the same, why not add them to
> arch/m68k/include/asm/pgtable.h instead?

Maybe I'm missing something, but why the stubs have to be defined in
arch/*/include/asm/pgtable.h rather than in include/asm-generic/pgtable.h?

> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> -- 
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
> 

-- 
Sincerely yours,
Mike.

