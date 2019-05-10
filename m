Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9EA4C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 21:03:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FE1E21841
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 21:03:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FE1E21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCD7B6B0003; Fri, 10 May 2019 17:03:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C57DD6B0005; Fri, 10 May 2019 17:03:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF7AD6B0006; Fri, 10 May 2019 17:03:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 89A7D6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 17:03:18 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id j66so11868806ywa.17
        for <linux-mm@kvack.org>; Fri, 10 May 2019 14:03:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=iS/v05UnfXmNJTrLhCcfslGQtQddd9ZUeOkOH+EYMe4=;
        b=SODWLzRhXJR0ui61l/9kUb8RWrAtFvqauJnoiMQV85Ik4jcBXeVwElZ0bp5tWZT1sQ
         FYtsZTJt+MZsqLIBQiPrkxu0gxDTtBsN8u8BbECtLPc8oKpZAOQ4PnwOVabUhAOTo0nw
         cE+2tikzcCfYYD4qGwuIyDjlpa6MLVqKBWURpCP1Jobo+ho7wiuANXer0V3eQ/Lcx7Oq
         GdiZkJov0Us5UAEyW3tZwznBLMNZjFFVk2RCiVxHtG9SW6RL5cUQQrdKkvXUBpxjqsZ5
         qwba0awOQV2yUJ131DgVGjUl4EUqDPtV7/v8OPJu6qGNtfkkNpKIEQkwy7rkR691EcJb
         m3Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWwwonRcX+qkSnxzbfh6ZWZvZbR8oOU+L/bg+WioXsMfipBOxN/
	/V5Hda+/aHWSoMmJ1NGhWUlUcdxmz90nV897Qa4BRXm9EuhhU+HX/BWex7F2bUulEr70QtDEMnw
	O3rcHjdaTnBOIeLCFE/ZLxhCjGJymTt94mREGOoshFTYER9fQu1I2uQcv721+pGfuOQ==
X-Received: by 2002:a25:2256:: with SMTP id i83mr6753507ybi.407.1557522198305;
        Fri, 10 May 2019 14:03:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxG6PaIUN9VONFGkmvuaYYGwW5zAAp7s7wWvhNIPVJT+JLw8nWDmUoc57e3y05FPeEmkeDp
X-Received: by 2002:a25:2256:: with SMTP id i83mr6753460ybi.407.1557522197432;
        Fri, 10 May 2019 14:03:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557522197; cv=none;
        d=google.com; s=arc-20160816;
        b=f/Fu+CuY8h/AjMfRB3zddpEiRC7aKr49doMECgQi58QLJtiWZZqaLPUgx8kOOjhqPF
         gJ3g8gcY+qEinb9QhmwX63oxwEIyUzMDkiJw+YspZhfhwtBBX+W/oRlLvVPbLpVd9T0F
         DCdk3LLevs1w9l8IyWuFm1qjFZHqcrysaHJyr4lomiWRtimhaaHpR6bfUwqXCyla7DuR
         YvhCZna8AYk1XMfIh0fxXJfEA74SmGeDPNEOgm86j3sjYu2E5Cn3onxYW2bRMS1obPDz
         ckL3EnRUgkjhlzKrXg+3OBHAJMwwT9Fnzii2LyrPCSwITvw6z1ktkNi+S0ctYdE/afD2
         X+zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=iS/v05UnfXmNJTrLhCcfslGQtQddd9ZUeOkOH+EYMe4=;
        b=gArvzn6PTGw/T8hKE9UFMEAgZ7z7qUuTPkvO+vKHstL8VrBga+dTz+8a2URHhoGMOh
         JFbnlriggRzct4SVgumcseBqa0jQxg6NMcGQfmV8Y5ATSI1/B2jGSQQxWCzrEWn8+YuX
         1jMQPM+u1qkQ+ev888YSvxBSDpaLAaeg58BByYTzOM4/EhIabfpU9Cg8RgI7g3iakBKu
         7eQ90lECvDpO1MZteP2Hgp6bCXMsxuA/1XNzl1tZKl4vxo8NMZKTDX8VZbcRHCZ/76Ye
         lN4JhXu4w7zbtjYRSlFpRDw2EgWoUSxCF7QGh9tdIyzKWB3n2696tt41HlnzZxKtxht4
         rwjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f188si344055ywb.400.2019.05.10.14.03.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 14:03:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4AKfsO8102029
	for <linux-mm@kvack.org>; Fri, 10 May 2019 17:03:17 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sdgcw9265-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 May 2019 17:03:16 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 10 May 2019 22:03:14 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 10 May 2019 22:03:10 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4AL3Arr26083446
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 21:03:10 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E0B78AE051;
	Fri, 10 May 2019 21:03:09 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 46D64AE045;
	Fri, 10 May 2019 21:03:07 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.24.29.91])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 10 May 2019 21:03:06 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Piotr Balcer <piotr.balcer@intel.com>,
        Yan Ma <yan.ma@intel.com>, Chandan Rajendra <chandan@linux.ibm.com>,
        Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
        Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] mm/huge_memory: Fix vmf_insert_pfn_{pmd, pud}() crash, handle unaligned addresses
In-Reply-To: <155741946350.372037.11148198430068238140.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155741946350.372037.11148198430068238140.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Fri, 10 May 2019 16:02:50 -0500
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19051021-0016-0000-0000-0000027A7518
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051021-0017-0000-0000-000032D73249
Message-Id: <87ef56c9ad.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-09_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905100134
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> Starting with commit c6f3c5ee40c1 "mm/huge_memory.c: fix modifying of
> page protection by insert_pfn_pmd()" vmf_insert_pfn_pmd() internally
> calls pmdp_set_access_flags(). That helper enforces a pmd aligned
> @address argument via VM_BUG_ON() assertion.
>
> Update the implementation to take a 'struct vm_fault' argument directly
> and apply the address alignment fixup internally to fix crash signatures
> like:
>
>     kernel BUG at arch/x86/mm/pgtable.c:515!
>     invalid opcode: 0000 [#1] SMP NOPTI
>     CPU: 51 PID: 43713 Comm: java Tainted: G           OE     4.19.35 #1
>     [..]
>     RIP: 0010:pmdp_set_access_flags+0x48/0x50
>     [..]
>     Call Trace:
>      vmf_insert_pfn_pmd+0x198/0x350
>      dax_iomap_fault+0xe82/0x1190
>      ext4_dax_huge_fault+0x103/0x1f0
>      ? __switch_to_asm+0x40/0x70
>      __handle_mm_fault+0x3f6/0x1370
>      ? __switch_to_asm+0x34/0x70
>      ? __switch_to_asm+0x40/0x70
>      handle_mm_fault+0xda/0x200
>      __do_page_fault+0x249/0x4f0
>      do_page_fault+0x32/0x110
>      ? page_fault+0x8/0x30
>      page_fault+0x1e/0x30
>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

> Cc: <stable@vger.kernel.org>
> Fixes: c6f3c5ee40c1 ("mm/huge_memory.c: fix modifying of page protection by insert_pfn_pmd()")
> Reported-by: Piotr Balcer <piotr.balcer@intel.com>
> Tested-by: Yan Ma <yan.ma@intel.com>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> Cc: Chandan Rajendra <chandan@linux.ibm.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>
>  drivers/dax/device.c    |    6 ++----
>  fs/dax.c                |    6 ++----
>  include/linux/huge_mm.h |    6 ++----
>  mm/huge_memory.c        |   16 ++++++++++------
>  4 files changed, 16 insertions(+), 18 deletions(-)
>
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index e428468ab661..996d68ff992a 100644
> --- a/drivers/dax/device.c
> +++ b/drivers/dax/device.c
> @@ -184,8 +184,7 @@ static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
>  
>  	*pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
>  
> -	return vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd, *pfn,
> -			vmf->flags & FAULT_FLAG_WRITE);
> +	return vmf_insert_pfn_pmd(vmf, *pfn, vmf->flags & FAULT_FLAG_WRITE);
>  }
>  
>  #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> @@ -235,8 +234,7 @@ static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
>  
>  	*pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
>  
> -	return vmf_insert_pfn_pud(vmf->vma, vmf->address, vmf->pud, *pfn,
> -			vmf->flags & FAULT_FLAG_WRITE);
> +	return vmf_insert_pfn_pud(vmf, *pfn, vmf->flags & FAULT_FLAG_WRITE);
>  }
>  #else
>  static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
> diff --git a/fs/dax.c b/fs/dax.c
> index e5e54da1715f..83009875308c 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1575,8 +1575,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
>  		}
>  
>  		trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
> -		result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
> -					    write);
> +		result = vmf_insert_pfn_pmd(vmf, pfn, write);
>  		break;
>  	case IOMAP_UNWRITTEN:
>  	case IOMAP_HOLE:
> @@ -1686,8 +1685,7 @@ dax_insert_pfn_mkwrite(struct vm_fault *vmf, pfn_t pfn, unsigned int order)
>  		ret = vmf_insert_mixed_mkwrite(vmf->vma, vmf->address, pfn);
>  #ifdef CONFIG_FS_DAX_PMD
>  	else if (order == PMD_ORDER)
> -		ret = vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd,
> -			pfn, true);
> +		ret = vmf_insert_pfn_pmd(vmf, pfn, FAULT_FLAG_WRITE);
>  #endif
>  	else
>  		ret = VM_FAULT_FALLBACK;
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 381e872bfde0..7cd5c150c21d 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -47,10 +47,8 @@ extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
>  extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			unsigned long addr, pgprot_t newprot,
>  			int prot_numa);
> -vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
> -			pmd_t *pmd, pfn_t pfn, bool write);
> -vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
> -			pud_t *pud, pfn_t pfn, bool write);
> +vm_fault_t vmf_insert_pfn_pmd(struct vm_fault *vmf, pfn_t pfn, bool write);
> +vm_fault_t vmf_insert_pfn_pud(struct vm_fault *vmf, pfn_t pfn, bool write);
>  enum transparent_hugepage_flag {
>  	TRANSPARENT_HUGEPAGE_FLAG,
>  	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 165ea46bf149..4310c6e9e5a3 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -793,11 +793,13 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  		pte_free(mm, pgtable);
>  }
>  
> -vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
> -			pmd_t *pmd, pfn_t pfn, bool write)
> +vm_fault_t vmf_insert_pfn_pmd(struct vm_fault *vmf, pfn_t pfn, bool write)
>  {
> +	unsigned long addr = vmf->address & PMD_MASK;
> +	struct vm_area_struct *vma = vmf->vma;
>  	pgprot_t pgprot = vma->vm_page_prot;
>  	pgtable_t pgtable = NULL;
> +
>  	/*
>  	 * If we had pmd_special, we could avoid all these restrictions,
>  	 * but we need to be consistent with PTEs and architectures that
> @@ -820,7 +822,7 @@ vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  
>  	track_pfn_insert(vma, &pgprot, pfn);
>  
> -	insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write, pgtable);
> +	insert_pfn_pmd(vma, addr, vmf->pmd, pfn, pgprot, write, pgtable);
>  	return VM_FAULT_NOPAGE;
>  }
>  EXPORT_SYMBOL_GPL(vmf_insert_pfn_pmd);
> @@ -869,10 +871,12 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  	spin_unlock(ptl);
>  }
>  
> -vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
> -			pud_t *pud, pfn_t pfn, bool write)
> +vm_fault_t vmf_insert_pfn_pud(struct vm_fault *vmf, pfn_t pfn, bool write)
>  {
> +	unsigned long addr = vmf->address & PUD_MASK;
> +	struct vm_area_struct *vma = vmf->vma;
>  	pgprot_t pgprot = vma->vm_page_prot;
> +
>  	/*
>  	 * If we had pud_special, we could avoid all these restrictions,
>  	 * but we need to be consistent with PTEs and architectures that
> @@ -889,7 +893,7 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  
>  	track_pfn_insert(vma, &pgprot, pfn);
>  
> -	insert_pfn_pud(vma, addr, pud, pfn, pgprot, write);
> +	insert_pfn_pud(vma, addr, vmf->pud, pfn, pgprot, write);
>  	return VM_FAULT_NOPAGE;
>  }
>  EXPORT_SYMBOL_GPL(vmf_insert_pfn_pud);

