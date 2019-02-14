Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD49EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:20:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6846120823
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:20:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6846120823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F311A8E0002; Thu, 14 Feb 2019 11:20:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE0BA8E0001; Thu, 14 Feb 2019 11:20:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA9838E0002; Thu, 14 Feb 2019 11:20:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA968E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:20:29 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r13so4638671pgb.7
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:20:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=T9KsBbeFePGJltMJpIT+vr79PdfWHv3EPCO73RHnxO4=;
        b=eLEi0lFHLQ8pEh/sA4Q84M8ODsCDA7rp7tJz0vxFrAaTIuofrhYwrW2OOXt3ZCyhxS
         qyiJ+SJArJysxf9ZylK9hz8HuTB8NSxQG1mJwuDA+HNO9Cb4n1JAjtAA4hIeVuks0O9S
         ze5puTLwMg3dg43WRz8lO3ZQDtxERTRRgsOrJ+Sf8SR/LCpBj7wS9VCYVIE04jdrVN5x
         nnkzPdW9gF3zVAWjWEDKfdUs2hYnF1IjC4TCeXu4cdXtaKwFdIxlYONkhoNezU0RWSX1
         3z4g3LLQ6eDoTX9T8ij/tF3RYnC/aMh84j26R2P4sfPnLNN9V0ymvXWA7HAphVE2cW5x
         OFcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuYA7YufXtMcrvZ7mN8WrrkniaPSb5QTVjLPYDtrXmjjMdnppuuj
	GJ22fPrqAfvXoLW+AW4WDYKqFFXUPsgAtM8fUg9e7pGOOcU4i5MIW5YmYWXuAM5R+Qu/rFGF35a
	zUyOnHqq94ssqt4pxxJaiwJ1q7dMR89h5ngukRLecMgqDC02+bJq8zbvBXdJfRdmTAQ==
X-Received: by 2002:a63:4913:: with SMTP id w19mr645212pga.394.1550161229256;
        Thu, 14 Feb 2019 08:20:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYk8oc2rQrSRLZMFZM9Y3mjUqvaOAGGx314F8CybP0prB6tOww5bMacS22b3daBGHbxranS
X-Received: by 2002:a63:4913:: with SMTP id w19mr645136pga.394.1550161228194;
        Thu, 14 Feb 2019 08:20:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550161228; cv=none;
        d=google.com; s=arc-20160816;
        b=NBm9T/t7Ij+MucYPjy3VcbiAtcLmZbJCzQeGaFPzovwcOYQdIZaIgKBAw1plDZ2Kru
         PdCK3MnHpoiU9WWrG2t3VhJtbF5zv3g7wW0vxdmC8WLvNNaxMreNffRGD73xwbtjW2z2
         EC37uCWXN62KK5C0QVX9z5Cb5PZBWaLXoC2LcCCtQnDsBMzAPzgKYSF+PbrI1vBwiFeo
         VxP3P/bZYq0AzzclLBTiGjhLJlbDD9i+gsNF/gZ3XnFx4e2GNmMrV1GNQSkDWxrHKPpG
         GD0atv0ysbzV/m8oCJH0HmO+vRT2qMexIe+sMkJwP+kIEQ2ooAwmgJR9smov6JZTn/ql
         n4NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=T9KsBbeFePGJltMJpIT+vr79PdfWHv3EPCO73RHnxO4=;
        b=iFKvxE0W3/KpY8e5mVDZNmTmzbBi3NJB86fWOWKIBYuHa9zkbKTTjk5Bj/lqOAcq9m
         ISG7oOUH5/e/fb611/kQ80Rzs9MXYt/O0378MzDvmVwp6piWQvSqSW+iH5Lbeqd9OfZv
         kdW2yLerM95lUoaj8bdKtaO4Db/MrIb2Ftq/HAqm0ZLoay5fBlskkTltoC+k/J+jztxW
         Y6IOIxafhaSXsee4ETTonMUrFj8OfNKBtGgwox87iFvI33qySvD6ctnItUtUeMUf7HdV
         tL4O+vKN4oxhiqMBzon3K6kk15JeMqP+yR0SYJxLgqLb1keYTOjy3zft+r1N6lGiE9Ik
         MdHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z63si2794436pfz.132.2019.02.14.08.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 08:20:28 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1EGKKlV020728
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:20:27 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qnaq9w9bd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:20:26 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 16:20:21 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 16:20:15 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1EGKEj058392708
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 14 Feb 2019 16:20:14 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A12D9A4057;
	Thu, 14 Feb 2019 16:20:14 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B43D8A4051;
	Thu, 14 Feb 2019 16:20:13 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 14 Feb 2019 16:20:13 +0000 (GMT)
Date: Thu, 14 Feb 2019 18:20:12 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Russell King <linux@armlinux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>, Guan Xuetao <gxt@pku.edu.cn>,
        linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
        linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 7/8] initramfs: proide a generic free_initrd_mem
 implementation
References: <20190213174621.29297-1-hch@lst.de>
 <20190213174621.29297-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213174621.29297-8-hch@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021416-0012-0000-0000-000002F5C2C9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021416-0013-0000-0000-0000212D408D
Message-Id: <20190214162011.GH9063@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=960 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140111
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Subject: initramfs: proide a generic free_initrd_mem implementation

Nit:                ^ provide

On Wed, Feb 13, 2019 at 06:46:20PM +0100, Christoph Hellwig wrote:
> For most architectures free_initrd_mem just expands to the same
> free_reserved_area call.  Provide that as a generic implementation
> marked __weak.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/alpha/mm/init.c      | 8 --------
>  arch/arc/mm/init.c        | 7 -------
>  arch/c6x/mm/init.c        | 7 -------
>  arch/h8300/mm/init.c      | 8 --------
>  arch/m68k/mm/init.c       | 7 -------
>  arch/microblaze/mm/init.c | 7 -------
>  arch/nds32/mm/init.c      | 7 -------
>  arch/nios2/mm/init.c      | 7 -------
>  arch/openrisc/mm/init.c   | 7 -------
>  arch/parisc/mm/init.c     | 7 -------
>  arch/powerpc/mm/mem.c     | 7 -------
>  arch/sh/mm/init.c         | 7 -------
>  arch/um/kernel/mem.c      | 7 -------
>  arch/unicore32/mm/init.c  | 7 -------
>  init/initramfs.c          | 5 +++++
>  15 files changed, 5 insertions(+), 100 deletions(-)
> 
> diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
> index a42fc5c4db89..97f4940f11e3 100644
> --- a/arch/alpha/mm/init.c
> +++ b/arch/alpha/mm/init.c
> @@ -291,11 +291,3 @@ free_initmem(void)
>  {
>  	free_initmem_default(-1);
>  }
> -
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void
> -free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
> index e1ab2d7f1d64..c357a3bd1532 100644
> --- a/arch/arc/mm/init.c
> +++ b/arch/arc/mm/init.c
> @@ -214,10 +214,3 @@ void __ref free_initmem(void)
>  {
>  	free_initmem_default(-1);
>  }
> -
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void __init free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
> index af5ada0520be..5504b71254f6 100644
> --- a/arch/c6x/mm/init.c
> +++ b/arch/c6x/mm/init.c
> @@ -67,13 +67,6 @@ void __init mem_init(void)
>  	mem_init_print_info(NULL);
>  }
> 
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void __init free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> -
>  void __init free_initmem(void)
>  {
>  	free_initmem_default(-1);
> diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
> index 6519252ac4db..2eff00de2b78 100644
> --- a/arch/h8300/mm/init.c
> +++ b/arch/h8300/mm/init.c
> @@ -101,14 +101,6 @@ void __init mem_init(void)
>  	mem_init_print_info(NULL);
>  }
> 
> -
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> -
>  void
>  free_initmem(void)
>  {
> diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
> index 933c33e76a48..c62e41563bb9 100644
> --- a/arch/m68k/mm/init.c
> +++ b/arch/m68k/mm/init.c
> @@ -144,10 +144,3 @@ void __init mem_init(void)
>  	init_pointer_tables();
>  	mem_init_print_info(NULL);
>  }
> -
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> index b17fd8aafd64..3bd32de46abb 100644
> --- a/arch/microblaze/mm/init.c
> +++ b/arch/microblaze/mm/init.c
> @@ -186,13 +186,6 @@ void __init setup_memory(void)
>  	paging_init();
>  }
> 
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> -
>  void free_initmem(void)
>  {
>  	free_initmem_default(-1);
> diff --git a/arch/nds32/mm/init.c b/arch/nds32/mm/init.c
> index 253f79fc7196..c02e10ac5e76 100644
> --- a/arch/nds32/mm/init.c
> +++ b/arch/nds32/mm/init.c
> @@ -249,13 +249,6 @@ void free_initmem(void)
>  	free_initmem_default(-1);
>  }
> 
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> -
>  void __set_fixmap(enum fixed_addresses idx,
>  			       phys_addr_t phys, pgprot_t flags)
>  {
> diff --git a/arch/nios2/mm/init.c b/arch/nios2/mm/init.c
> index 16cea5776b87..60736a725883 100644
> --- a/arch/nios2/mm/init.c
> +++ b/arch/nios2/mm/init.c
> @@ -82,13 +82,6 @@ void __init mmu_init(void)
>  	flush_tlb_all();
>  }
> 
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void __init free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> -
>  void __ref free_initmem(void)
>  {
>  	free_initmem_default(-1);
> diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
> index d157310eb377..d0d94a4391d4 100644
> --- a/arch/openrisc/mm/init.c
> +++ b/arch/openrisc/mm/init.c
> @@ -221,13 +221,6 @@ void __init mem_init(void)
>  	return;
>  }
> 
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> -
>  void free_initmem(void)
>  {
>  	free_initmem_default(-1);
> diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
> index 059187a3ded7..1b445e206ca8 100644
> --- a/arch/parisc/mm/init.c
> +++ b/arch/parisc/mm/init.c
> @@ -935,10 +935,3 @@ void flush_tlb_all(void)
>  	spin_unlock(&sid_lock);
>  }
>  #endif
> -
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 33cc6f676fa6..976c706a64e2 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -388,13 +388,6 @@ void free_initmem(void)
>  	free_initmem_default(POISON_FREE_INITMEM);
>  }
> 
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void __init free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> -
>  /*
>   * This is called when a page has been modified by the kernel.
>   * It just marks the page as not i-cache clean.  We do the i-cache
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index a8e5c0e00fca..2fa824336ec2 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -410,13 +410,6 @@ void free_initmem(void)
>  	free_initmem_default(-1);
>  }
> 
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> -
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>  		bool want_memblock)
> diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
> index 799b571a8f88..48b24b63b10d 100644
> --- a/arch/um/kernel/mem.c
> +++ b/arch/um/kernel/mem.c
> @@ -172,13 +172,6 @@ void free_initmem(void)
>  {
>  }
> 
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> -
>  /* Allocate and free page tables. */
> 
>  pgd_t *pgd_alloc(struct mm_struct *mm)
> diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
> index e3f4f791e10a..01271ce52ef9 100644
> --- a/arch/unicore32/mm/init.c
> +++ b/arch/unicore32/mm/init.c
> @@ -316,10 +316,3 @@ void free_initmem(void)
>  {
>  	free_initmem_default(-1);
>  }
> -
> -#ifdef CONFIG_BLK_DEV_INITRD
> -void free_initrd_mem(unsigned long start, unsigned long end)
> -{
> -	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> -}
> -#endif
> diff --git a/init/initramfs.c b/init/initramfs.c
> index cf8bf014873f..f3aaa58ac63d 100644
> --- a/init/initramfs.c
> +++ b/init/initramfs.c
> @@ -527,6 +527,11 @@ extern unsigned long __initramfs_size;
>  #include <linux/initrd.h>
>  #include <linux/kexec.h>
> 
> +void __weak free_initrd_mem(unsigned long start, unsigned long end)
> +{
> +	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> +}
> +
>  #ifdef CONFIG_KEXEC_CORE
>  static bool kexec_free_initrd(void)
>  {
> -- 
> 2.20.1
> 

-- 
Sincerely yours,
Mike.

