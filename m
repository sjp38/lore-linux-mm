Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E9D9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:11:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9ABE218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:11:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9ABE218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 662E98E0003; Thu, 14 Feb 2019 10:11:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 612498E0001; Thu, 14 Feb 2019 10:11:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 502928E0003; Thu, 14 Feb 2019 10:11:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 26EFF8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:11:32 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id s4so5795359qts.11
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:11:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=nAUbIzHIDytdEQz7ne0188JCOOie/wkLzkeetVjZnko=;
        b=hbL3oJArfrY8HrKZhV+4H936ZvqI6i7b0ZwPbe3fb6e7DOguyUeN+vPNmcnU5wAtBJ
         TH2quz9D0PGtwV2OHOHsGw2ziA48UxCXGWOH0oVMxR0fK4yETTR9+uSHUExzz3Zo9sjA
         018IoIcsRzsvQCJ8zUvL5P3bCEwLjy80XLtf9EYMKMwyNqQJheRUglHQMeXr8VoZ2cYJ
         fhAAPJsC9c2Snwg9ewWaF2dEVjoOWxBA3Hbr9tINJ3zWWKwrJawESMUO+9wrcQZD04c1
         H6bXN97Gc8oM29ajNm62FzCMBbOn6fl+T6DWIYKBGktg0DppOeqrUR54fqC5yqkjybJV
         OS3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuY0HcSEKDKo6LQ6u5aYaPkg1tcIa1OQieXWBUyJoW0tFs3Yur2q
	Qcq32xmrAl9V3fOtPw6Cl/HRvuD8lyWV2CIqoBM6ia28z5eu7YCqefE8g9GmIKQDZS8vVIdCFJW
	dt1uv2CLwX1g/thgNQUb0/fSbLbe23zvShBNAGNwt69RlPeO7pQRzsd/zHkV34Z2CuQ==
X-Received: by 2002:ae9:c30f:: with SMTP id n15mr3151300qkg.227.1550157091875;
        Thu, 14 Feb 2019 07:11:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaDVp5NDHUOpmOHKfccBwkLtj+0TSm6qRnqW9WKqOB4B3IQZOZRlf6pPZzuxaw9LCyUbcdh
X-Received: by 2002:ae9:c30f:: with SMTP id n15mr3151243qkg.227.1550157091100;
        Thu, 14 Feb 2019 07:11:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550157091; cv=none;
        d=google.com; s=arc-20160816;
        b=UVdGS6NCPku+iEpQ4SpTR7tMf7WuFDEKYybAgzJdll78fwRvwZZrB8XM8i0gY5utYq
         Yio9ad/btKG74hAGTihRL4mcPWrdxeDzHct3YJnZoz4abvd5OZskveowIIfjmuHrwbeq
         Wm9zPgtyFohFZZHPIJGmP/ijwQJpV40nuoAqHjKPuzsM1UJ9PX//1UxTeZZXD+YI1G8X
         SmscV8GxTecsRkom2vfN/WepzV0ekpEHdafSy96IBBl31UkxYO17U6EZrlo97uzJHMWQ
         SzPldhUNWMFIWybGee3f5aQYj7HXBhC4+/iWc3lbHveGmf1v2CR0SSjBe8O3/Ewq26Bu
         9ygw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=nAUbIzHIDytdEQz7ne0188JCOOie/wkLzkeetVjZnko=;
        b=eFRE0O3adf/tAfNJut7lEgnco2f3p4m3KDzDNuUe7ZXeMFLLoFslIVQt9tVJnPlBPp
         hxxcoAh7tEx/xGzczljzq1AOtGSidPGgnq+ltiqxKqQ6uK9C9caBdamgdUPINgSKdg1W
         dpPx5LxllfJw8Age8ECjrkv8LBu12EciuVuITNQHKJmcLx549yNTlarR6+Gibq0wm1IO
         7UpFLWuk9Lytyg1aoTvCj4Mz2T2A1P2r4NxnokPSA8YL6NWWCYGTnk7I8Gm41hVoBnBo
         Ar30CyLmdoIsi9DHuUaxiH1dXHhZRZgcrXuJ+R8Mi3vOObNbQqEdtXj540ZvSP48wjL1
         oOew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t19si1748971qtt.295.2019.02.14.07.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 07:11:30 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1EF8QHN082942
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:11:29 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qnap38mhp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:11:27 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 15:11:20 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 15:11:17 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1EFBGaq66453726
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 15:11:16 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 54432A4065;
	Thu, 14 Feb 2019 15:11:16 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 91A4AA4066;
	Thu, 14 Feb 2019 15:11:15 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 14 Feb 2019 15:11:15 +0000 (GMT)
Date: Thu, 14 Feb 2019 17:11:13 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-efi <linux-efi@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Marc Zyngier <marc.zyngier@arm.com>, James Morse <james.morse@arm.com>,
        Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH 1/2] arm64: account for GICv3 LPI tables in static
 memblock reserve table
References: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
 <20190213132738.10294-2-ard.biesheuvel@linaro.org>
 <20190214083350.GA9063@rapoport-lnx>
 <CAKv+Gu8ZvMgS3VgkGVQthh-QWWoAmjxEDhj-pp98_BG4-810Wg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu8ZvMgS3VgkGVQthh-QWWoAmjxEDhj-pp98_BG4-810Wg@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021415-0028-0000-0000-000003489433
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021415-0029-0000-0000-00002406C072
Message-Id: <20190214151113.GE9063@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140106
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 03:57:35PM +0100, Ard Biesheuvel wrote:
> On Thu, 14 Feb 2019 at 09:34, Mike Rapoport <rppt@linux.ibm.com> wrote:
> >
> > On Wed, Feb 13, 2019 at 02:27:37PM +0100, Ard Biesheuvel wrote:
> > > In the irqchip and EFI code, we have what basically amounts to a quirk
> > > to work around a peculiarity in the GICv3 architecture, which permits
> > > the system memory address of LPI tables to be programmable only once
> > > after a CPU reset. This means kexec kernels must use the same memory
> > > as the first kernel, and thus ensure that this memory has not been
> > > given out for other purposes by the time the ITS init code runs, which
> > > is not very early for secondary CPUs.
> > >
> > > On systems with many CPUs, these reservations could overflow the
> > > memblock reservation table, and this was addressed in commit
> > > eff896288872 ("efi/arm: Defer persistent reservations until after
> > > paging_init()"). However, this turns out to have made things worse,
> > > since the allocation of page tables and heap space for the resized
> > > memblock reservation table itself may overwrite the regions we are
> > > attempting to reserve, which may cause all kinds of corruption,
> > > also considering that the ITS will still be poking bits into that
> > > memory in response to incoming MSIs.
> > >
> > > So instead, let's grow the static memblock reservation table on such
> > > systems so it can accommodate these reservations at an earlier time.
> > > This will permit us to revert the above commit in a subsequent patch.
> > >
> > > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > > ---
> > >  arch/arm64/include/asm/memory.h | 11 +++++++++++
> > >  include/linux/memblock.h        |  3 ---
> > >  mm/memblock.c                   | 10 ++++++++--
> > >  3 files changed, 19 insertions(+), 5 deletions(-)
> > >
> > > diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
> > > index e1ec947e7c0c..7e2b13cdd970 100644
> > > --- a/arch/arm64/include/asm/memory.h
> > > +++ b/arch/arm64/include/asm/memory.h
> > > @@ -332,6 +332,17 @@ static inline void *phys_to_virt(phys_addr_t x)
> > >  #define virt_addr_valid(kaddr)               \
> > >       (_virt_addr_is_linear(kaddr) && _virt_addr_valid(kaddr))
> > >
> > > +/*
> > > + * Given that the GIC architecture permits ITS implementations that can only be
> > > + * configured with a LPI table address once, GICv3 systems with many CPUs may
> > > + * end up reserving a lot of different regions after a kexec for their LPI
> > > + * tables, as we are forced to reuse the same memory after kexec (and thus
> > > + * reserve it persistently with EFI beforehand)
> > > + */
> > > +#if defined(CONFIG_EFI) && defined(CONFIG_ARM_GIC_V3_ITS)
> > > +#define INIT_MEMBLOCK_RESERVED_REGIONS       (INIT_MEMBLOCK_REGIONS + 2 * NR_CPUS)
> > > +#endif

Not strictly related, with high NR_CPUS the memblock.reserved becomes quite
large and mostly empty in many cases. Is there a reason arm64 does not set
ARCH_DISCARD_MEMBLOCK?

> > > +
> > >  #include <asm-generic/memory_model.h>
> > >
> > >  #endif
> > > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > > index 64c41cf45590..859b55b66db2 100644
> > > --- a/include/linux/memblock.h
> > > +++ b/include/linux/memblock.h
> > > @@ -29,9 +29,6 @@ extern unsigned long max_pfn;
> > >   */
> > >  extern unsigned long long max_possible_pfn;
> > >
> > > -#define INIT_MEMBLOCK_REGIONS        128
> > > -#define INIT_PHYSMEM_REGIONS 4
> > > -
> > >  /**
> > >   * enum memblock_flags - definition of memory region attributes
> > >   * @MEMBLOCK_NONE: no special request
> > > diff --git a/mm/memblock.c b/mm/memblock.c
> > > index 022d4cbb3618..a526c3ab8390 100644
> > > --- a/mm/memblock.c
> > > +++ b/mm/memblock.c
> > > @@ -26,6 +26,12 @@
> > >
> > >  #include "internal.h"
> > >
> > > +#define INIT_MEMBLOCK_REGIONS                128
> > > +#define INIT_PHYSMEM_REGIONS         4
> > > +#ifndef INIT_MEMBLOCK_RESERVED_REGIONS
> > > +#define INIT_MEMBLOCK_RESERVED_REGIONS       INIT_MEMBLOCK_REGIONS
> > > +#endif
> > > +
> >
> > I'd suggest
> >
> > s/INIT_MEMBLOCK_REGIONS/INIT_MEMORY_REGIONS
> > s/INIT_MEMBLOCK_RESERVED_REGIONS/INIT_RESERVED_REGIONS
> >
> 
> Well, I'd prefer to keep MEMBLOCK in the identifier, given that we are
> setting it from an arch header file as well.
 
I was bothered by lack of consistency, but you're right, namespacing here
is more important.

Care to update /** DOC: */ section as a separate patch?

> > Except that,
> >
> > Acked-by: Mike Rapoport <rppt@linux.ibm.com>
> >
> 
> Thanks
> 
> 
> > >  /**
> > >   * DOC: memblock overview
> > >   *
> > > @@ -92,7 +98,7 @@ unsigned long max_pfn;
> > >  unsigned long long max_possible_pfn;
> > >
> > >  static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
> > > -static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
> > > +static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_RESERVED_REGIONS] __initdata_memblock;
> > >  #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> > >  static struct memblock_region memblock_physmem_init_regions[INIT_PHYSMEM_REGIONS] __initdata_memblock;
> > >  #endif
> > > @@ -105,7 +111,7 @@ struct memblock memblock __initdata_memblock = {
> > >
> > >       .reserved.regions       = memblock_reserved_init_regions,
> > >       .reserved.cnt           = 1,    /* empty dummy entry */
> > > -     .reserved.max           = INIT_MEMBLOCK_REGIONS,
> > > +     .reserved.max           = INIT_MEMBLOCK_RESERVED_REGIONS,
> > >       .reserved.name          = "reserved",
> > >
> > >  #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> > > --
> > > 2.20.1
> > >
> >
> > --
> > Sincerely yours,
> > Mike.
> >
> 

-- 
Sincerely yours,
Mike.

