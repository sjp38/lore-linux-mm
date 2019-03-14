Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8C76C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:53:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60258217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:53:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60258217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF9C78E000B; Thu, 14 Mar 2019 01:53:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA8A98E0001; Thu, 14 Mar 2019 01:53:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D70668E000B; Thu, 14 Mar 2019 01:53:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94E708E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:53:02 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n10so4965934pgp.21
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:53:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=h99WpfSsiu0Zdbtyzecd183RKs3Zqa9m70YqNMBytPQ=;
        b=doGQC4x5BL8E45AoCzPXMtvi1PdzIYUfmnwR6rvYkyjl1MByiQKntRjp3cfVWvTObp
         kiaASaLhp/zwc70yThQupKz7H6HkH7DyOI06pZq7UjslBBCcEJKIHgy93N/IhDPiUn3i
         PGfqFLUMN9Yabt0I0P/I4jWwrqY8VkMDpobtOtsLk0QgdRiqCl9AdItoO3C5LsCnUHXP
         c7YohTsoF3bdLElU8Qrv/jn4vcdEcljVR4z4Oy+LJv6ut2sQlviDYfmed0CagLrmCPzS
         vV/C3KzEggJdFmc9qNftYhksfmmJoRNFoIerVTySZlThQWGwu70QMQYHa7KEOJhAu2RX
         8NXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXEDRqlFmO1pUEkQtgTmfvFrOOG0e2XXaxf2nUj+MkLGCwZVfM7
	Q2bvlCkfGxdnJz2Mas/bKuQ67cIGgiYy/Ma3n/zyYpXfFQMqvlZhTf6MdsWH78Z/Kxvn8XYzGm0
	4GQU+9JpO8CJQejPah2n60QyKwqYR5jUQDupN+F4UXDQx/jCqqddtXSF0ukRUVH8x1g==
X-Received: by 2002:a62:17d4:: with SMTP id 203mr46883876pfx.244.1552542782130;
        Wed, 13 Mar 2019 22:53:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgniO/08WeXYlUvAfh6V5mK1lgVrEuQWoBQk9V+dmLJmyZxKZQvNqQtQj1flmHzsYqDrbE
X-Received: by 2002:a62:17d4:: with SMTP id 203mr46883830pfx.244.1552542780899;
        Wed, 13 Mar 2019 22:53:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552542780; cv=none;
        d=google.com; s=arc-20160816;
        b=PRRRQ1ziJRCn9o6qSB20kZb8VJPJD+fRcbY8NwawjAka2Qn4R/A2E4kvod84O6d1BF
         /zITghg1hSDvRF2YgAKNkQ7hm16Fzkuyajsmne+qNlJG7R3wLIUSLAW0Tp+ImSlbfhXB
         Crnhm1T/RoJYMYmsuDnjOCGUMpCkl9oOhBDRIEANTD9OMgQUPuO54y3ZYijyIgAC1bwH
         39/GM7eKOBjgpfJ/kNfo8G++WomZbfRIHu0RsLE63irCo5Tk0d/1bWqimszMi7lRoRGc
         4EYZ/kGxTTy2OFB+6xLlYaE6/bJUJPNwFDVRS4OWmbmo8UKZeVJzl6xW9JpNSt1GoDX6
         jccg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=h99WpfSsiu0Zdbtyzecd183RKs3Zqa9m70YqNMBytPQ=;
        b=HlCWjaNAKis9JjMJZvyPZG5ITye9dLbx5fm4wEXbPSywdAuCeWTIWYRZ5kt+TLpXXk
         jLX6yKvFJeJV3t9odXX5ebTrf3b6lW26clL9XLQyG9qCGsrBr16WKD3QrMPdDWeaVUIo
         3QRxNhi9/PjUXYWHjwN32eQHE+MFdP8e4OkBmuJa8R9NcoF65Psv5r5aZay5XYDdG19m
         FxGM6G/+c/wVMiRYvHmWLv19zgrb3pW/YiifqVst6dfeKdaoILpaT9IGwObln83teIoe
         I2i49C/4tu+bQMVFFgwDzEms3Raxs7lAgYJCc3Kf7WnzdIOYY3XLRwS9ZHZYusghqS2o
         FAMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z15si11269028pgv.209.2019.03.13.22.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 22:53:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2E5nHh5071250
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:53:00 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r7g6ea7cy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:53:00 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 14 Mar 2019 05:52:57 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Mar 2019 05:52:49 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2E5qmkN29294708
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 14 Mar 2019 05:52:48 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 689BBAE05D;
	Thu, 14 Mar 2019 05:52:48 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A5193AE056;
	Thu, 14 Mar 2019 05:52:43 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.31.88])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 14 Mar 2019 05:52:43 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Alexandre Ghiti <alex@ghiti.fr>, Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>,
        "David S . Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
        x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
        Andy Lutomirski <luto@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: Re: [PATCH v6 4/4] hugetlb: allow to free gigantic pages regardless of the configuration
In-Reply-To: <20190307132015.26970-5-alex@ghiti.fr>
References: <20190307132015.26970-1-alex@ghiti.fr> <20190307132015.26970-5-alex@ghiti.fr>
Date: Thu, 14 Mar 2019 11:22:42 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19031405-0028-0000-0000-00000353D00E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031405-0029-0000-0000-000024125AE4
Message-Id: <87va0movdh.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-14_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903140038
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Alexandre Ghiti <alex@ghiti.fr> writes:

> On systems without CONTIG_ALLOC activated but that support gigantic pages,
> boottime reserved gigantic pages can not be freed at all. This patch
> simply enables the possibility to hand back those pages to memory
> allocator.
>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: David S. Miller <davem@davemloft.net> [sparc]
> ---
>  arch/arm64/Kconfig                           |  2 +-
>  arch/arm64/include/asm/hugetlb.h             |  4 --
>  arch/powerpc/include/asm/book3s/64/hugetlb.h |  7 ---
>  arch/powerpc/platforms/Kconfig.cputype       |  2 +-
>  arch/s390/Kconfig                            |  2 +-
>  arch/s390/include/asm/hugetlb.h              |  3 --
>  arch/sh/Kconfig                              |  2 +-
>  arch/sparc/Kconfig                           |  2 +-
>  arch/x86/Kconfig                             |  2 +-
>  arch/x86/include/asm/hugetlb.h               |  4 --
>  include/linux/gfp.h                          |  2 +-
>  mm/hugetlb.c                                 | 57 ++++++++++++--------
>  mm/page_alloc.c                              |  4 +-
>  13 files changed, 44 insertions(+), 49 deletions(-)
>
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 091a513b93e9..af687eff884a 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -18,7 +18,7 @@ config ARM64
>  	select ARCH_HAS_FAST_MULTIPLIER
>  	select ARCH_HAS_FORTIFY_SOURCE
>  	select ARCH_HAS_GCOV_PROFILE_ALL
> -	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
> +	select ARCH_HAS_GIGANTIC_PAGE
>  	select ARCH_HAS_KCOV
>  	select ARCH_HAS_MEMBARRIER_SYNC_CORE
>  	select ARCH_HAS_PTE_SPECIAL
> diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
> index fb6609875455..59893e766824 100644
> --- a/arch/arm64/include/asm/hugetlb.h
> +++ b/arch/arm64/include/asm/hugetlb.h
> @@ -65,8 +65,4 @@ extern void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
>  
>  #include <asm-generic/hugetlb.h>
>  
> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> -static inline bool gigantic_page_supported(void) { return true; }
> -#endif
> -
>  #endif /* __ASM_HUGETLB_H */
> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> index 5b0177733994..d04a0bcc2f1c 100644
> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> @@ -32,13 +32,6 @@ static inline int hstate_get_psize(struct hstate *hstate)
>  	}
>  }
>  
> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> -static inline bool gigantic_page_supported(void)
> -{
> -	return true;
> -}
> -#endif
> -
>  /* hugepd entry valid bit */
>  #define HUGEPD_VAL_BITS		(0x8000000000000000UL)
>  

As explained in https://patchwork.ozlabs.org/patch/1047003/
architectures like ppc64 have a hypervisor assisted mechanism to indicate
where to find gigantic huge pages(16G pages). At this point, we don't use this
reserved pages for anything other than hugetlb backing and hence there
is no runtime free of this pages needed ( Also we don't do
runtime allocation of them).

I guess you can still achieve what you want to do in this patch by
keeping gigantic_page_supported()?

NOTE: We should rename gigantic_page_supported to be more specific to
support for runtime_alloc/free of gigantic pages

-aneesh

