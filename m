Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 069CFC32755
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:58:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6A36206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:58:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6A36206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 323148E0005; Wed, 31 Jul 2019 05:58:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 302C28E0001; Wed, 31 Jul 2019 05:58:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EA098E0005; Wed, 31 Jul 2019 05:58:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDDBE8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:58:35 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i27so42921829pfk.12
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:58:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=cQF4WS4RI5nisIM6w7DWApNArIS1mTgh3UNCzggmSzA=;
        b=U5za2JjIJSFsGfzGornRzwu9nVAJRdiVwDiehrzkrBb0SVW6+zlvIV1bjZR9IET00g
         LIoLfh9vBGg6aCOUZzV1AOFiXoT3sNz0nvLCm8yBuUTMsr8IlEfV04hBDqbAi6uWnfcU
         wwnKuMjazkDihy5oI2KIXBIOwTmYgqdumfsmSqA8eizOpNw41CeItt8vTjx5e+dpRMA1
         hkRWhU6nygCqzjWBMkadK5ouB7f16ahHVKjN3im2ybySn6IEqkgcZTMkivYioA7HaBEc
         JTe95yiAdydb0qXHBowNj4lKktecWiqy47p7XYsT1TIRQe2teEDriHKsmMSoaSz2uaQb
         1e+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWtwwlX5sMr5DEPtiE6FlZ57CbzLPaWI3Krj0Q4ykWhitc+4I17
	l9hOz6chFD3PcOPjqrb3zofjFqo0SRpAwQEGe0y3RaSLbGEKUbg/ky/yMmkVJFVMEw1bBoPtKoY
	mrHeMD7WAIy9AG90C3ZHQqeJyRZxB9LtARQMi3tS79bXqXIJGn3+AczQRAwfj8VZZPg==
X-Received: by 2002:a17:902:b909:: with SMTP id bf9mr25807427plb.309.1564567115545;
        Wed, 31 Jul 2019 02:58:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdbZyU8n2JVxx5g0B/RdcSWiinJKzIWAUikj1N12MEBX//vn9TcMpIoPh6VXaGI0iM8Fb8
X-Received: by 2002:a17:902:b909:: with SMTP id bf9mr25807373plb.309.1564567114750;
        Wed, 31 Jul 2019 02:58:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564567114; cv=none;
        d=google.com; s=arc-20160816;
        b=M8MfazEC0EvbPYBt04gsp6zDejZ/cgCEUo3BS2vWTn7iBmocv3Vydy19IhN0NfWWUx
         IVDVKKxaqH1eiMBQjAvLoPKxzmvFzgeQVyplC/k5pErzj9aDs+6TTCr4wzzWMa86N/K5
         bIEOHQPgPeogisC0Nj7vcrjF+wd2SwRSsEXpuwR2aOsLt12EOSm9U6mGyWP73xFDGzFT
         NVU8TLUcnXVPgF8TmZQhs4u9VdyBUmgr6wnhSVqDHyo+08DnqzRgwrISTlgDyS63KA8B
         szwE1v4E3uLDPsG/SEZr2kLekpXKsBGiC+sORjH/SVrO0UHYg8Uo3FKkXug2oRcCmxNo
         5qDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=cQF4WS4RI5nisIM6w7DWApNArIS1mTgh3UNCzggmSzA=;
        b=OMD/R36DgRGNFuXXoGRZwvDmuK9A97eFXus28tf2LP1FnXHZ7qGVQrazZFPfdeNH5G
         GWAev4YaId6uVUAqTZXPYuXsscQXA6qL5jOjAY/k6PuAF6QW7a71YtU0re0YIhlhkdUB
         FSWof8aWW7M/8CEA/hsgq94/v3Hdfv978KfNorQHBDyqjFU7na4ldIIN/FMCie5DDtA5
         EbCVcPZjLcEDlSoG/uRpV/N29MFog2Ka/RGxK4mbAl00FhwbDpy4jvaAwdBrP/EtweZL
         ysaeF7CcGQdXyMdjYhD6svlPAID+4AOv/xlYo8xuzCj1iNZXy9spVuuOA2TAbWxX3d9r
         ygSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o1si1205570pja.67.2019.07.31.02.58.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 02:58:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6V9wDsL028635
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:58:34 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u37n5380g-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:58:31 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Wed, 31 Jul 2019 10:57:51 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 31 Jul 2019 10:57:48 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6V9vlWW33358064
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 09:57:47 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C11224C04A;
	Wed, 31 Jul 2019 09:57:47 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 465574C044;
	Wed, 31 Jul 2019 09:57:44 +0000 (GMT)
Received: from in.ibm.com (unknown [9.109.246.128])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 31 Jul 2019 09:57:43 +0000 (GMT)
Date: Wed, 31 Jul 2019 15:27:35 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
        Ralph Campbell <rcampbell@nvidia.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 5/9] nouveau: simplify nouveau_dmem_migrate_to_ram
Reply-To: bharata@linux.ibm.com
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-6-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729142843.22320-6-hch@lst.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19073109-0012-0000-0000-00000337F1FF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19073109-0013-0000-0000-000021719A7D
Message-Id: <20190731095735.GB18807@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-31_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907310102
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 05:28:39PM +0300, Christoph Hellwig wrote:
> Factor the main copy page to ram routine out into a helper that acts on
> a single page and which doesn't require the nouveau_dmem_fault
> structure for argument passing.  Also remove the loop over multiple
> pages as we only handle one at the moment, although the structure of
> the main worker function makes it relatively easy to add multi page
> support back if needed in the future.  But at least for now this avoid
> the needed to dynamically allocate memory for the dma addresses in
> what is essentially the page fault path.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/nouveau/nouveau_dmem.c | 158 ++++++-------------------
>  1 file changed, 39 insertions(+), 119 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> index 21052a4aaf69..036e6c07d489 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> @@ -86,13 +86,6 @@ static inline struct nouveau_dmem *page_to_dmem(struct page *page)
>  	return container_of(page->pgmap, struct nouveau_dmem, pagemap);
>  }
>  
> -struct nouveau_dmem_fault {
> -	struct nouveau_drm *drm;
> -	struct nouveau_fence *fence;
> -	dma_addr_t *dma;
> -	unsigned long npages;
> -};
> -
>  struct nouveau_migrate {
>  	struct vm_area_struct *vma;
>  	struct nouveau_drm *drm;
> @@ -146,130 +139,55 @@ static void nouveau_dmem_fence_done(struct nouveau_fence **fence)
>  	}
>  }
>  
> -static void
> -nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
> -				  const unsigned long *src_pfns,
> -				  unsigned long *dst_pfns,
> -				  unsigned long start,
> -				  unsigned long end,
> -				  struct nouveau_dmem_fault *fault)
> +static vm_fault_t nouveau_dmem_fault_copy_one(struct nouveau_drm *drm,
> +		struct vm_area_struct *vma, unsigned long addr,
> +		unsigned long src, unsigned long *dst, dma_addr_t *dma_addr)
>  {
> -	struct nouveau_drm *drm = fault->drm;
>  	struct device *dev = drm->dev->dev;
> -	unsigned long addr, i, npages = 0;
> -	nouveau_migrate_copy_t copy;
> -	int ret;
> -
> -
> -	/* First allocate new memory */
> -	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
> -		struct page *dpage, *spage;
> -
> -		dst_pfns[i] = 0;
> -		spage = migrate_pfn_to_page(src_pfns[i]);
> -		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE))
> -			continue;
> +	struct page *dpage, *spage;
>  
> -		dpage = alloc_page_vma(GFP_HIGHUSER, vma, addr);
> -		if (!dpage) {
> -			dst_pfns[i] = MIGRATE_PFN_ERROR;
> -			continue;
> -		}
> -		lock_page(dpage);
> -
> -		dst_pfns[i] = migrate_pfn(page_to_pfn(dpage)) |
> -			      MIGRATE_PFN_LOCKED;
> -		npages++;
> -	}
> +	spage = migrate_pfn_to_page(src);
> +	if (!spage || !(src & MIGRATE_PFN_MIGRATE))
> +		return 0;
>  
> -	/* Allocate storage for DMA addresses, so we can unmap later. */
> -	fault->dma = kmalloc(sizeof(*fault->dma) * npages, GFP_KERNEL);
> -	if (!fault->dma)
> +	dpage = alloc_page_vma(GFP_HIGHUSER, args->vma, addr);
> +	if (!dpage)
>  		goto error;
> +	lock_page(dpage);
>  
> -	/* Copy things over */
> -	copy = drm->dmem->migrate.copy_func;
> -	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
> -		struct page *spage, *dpage;
> -
> -		dpage = migrate_pfn_to_page(dst_pfns[i]);
> -		if (!dpage || dst_pfns[i] == MIGRATE_PFN_ERROR)
> -			continue;
> -
> -		spage = migrate_pfn_to_page(src_pfns[i]);
> -		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE)) {
> -			dst_pfns[i] = MIGRATE_PFN_ERROR;
> -			__free_page(dpage);
> -			continue;
> -		}
> -
> -		fault->dma[fault->npages] =
> -			dma_map_page_attrs(dev, dpage, 0, PAGE_SIZE,
> -					   PCI_DMA_BIDIRECTIONAL,
> -					   DMA_ATTR_SKIP_CPU_SYNC);
> -		if (dma_mapping_error(dev, fault->dma[fault->npages])) {
> -			dst_pfns[i] = MIGRATE_PFN_ERROR;
> -			__free_page(dpage);
> -			continue;
> -		}
> -
> -		ret = copy(drm, 1, NOUVEAU_APER_HOST,
> -				fault->dma[fault->npages++],
> -				NOUVEAU_APER_VRAM,
> -				nouveau_dmem_page_addr(spage));
> -		if (ret) {
> -			dst_pfns[i] = MIGRATE_PFN_ERROR;
> -			__free_page(dpage);
> -			continue;
> -		}
> -	}
> +	*dma_addr = dma_map_page(dev, dpage, 0, PAGE_SIZE, DMA_BIDIRECTIONAL);
> +	if (dma_mapping_error(dev, *dma_addr))
> +		goto error_free_page;
>  
> -	nouveau_fence_new(drm->dmem->migrate.chan, false, &fault->fence);
> +	if (drm->dmem->migrate.copy_func(drm, 1, NOUVEAU_APER_HOST, *dma_addr,
> +			NOUVEAU_APER_VRAM, nouveau_dmem_page_addr(spage)))
> +		goto error_dma_unmap;
>  
> -	return;
> +	*dst = migrate_pfn(page_to_pfn(dpage)) | MIGRATE_PFN_LOCKED;
>  
> +error_dma_unmap:
> +	dma_unmap_page(dev, *dma_addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
> +error_free_page:
> +	__free_page(dpage);
>  error:
> -	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, ++i) {
> -		struct page *page;
> -
> -		if (!dst_pfns[i] || dst_pfns[i] == MIGRATE_PFN_ERROR)
> -			continue;
> -
> -		page = migrate_pfn_to_page(dst_pfns[i]);
> -		dst_pfns[i] = MIGRATE_PFN_ERROR;
> -		if (page == NULL)
> -			continue;
> -
> -		__free_page(page);
> -	}
> -}
> -
> -static void
> -nouveau_dmem_fault_finalize_and_map(struct nouveau_dmem_fault *fault)
> -{
> -	struct nouveau_drm *drm = fault->drm;
> -
> -	nouveau_dmem_fence_done(&fault->fence);
> -
> -	while (fault->npages--) {
> -		dma_unmap_page(drm->dev->dev, fault->dma[fault->npages],
> -			       PAGE_SIZE, PCI_DMA_BIDIRECTIONAL);
> -	}
> -	kfree(fault->dma);
> +	return VM_FAULT_SIGBUS;

Looks like nouveau_dmem_fault_copy_one() is now returning VM_FAULT_SIGBUS
for success case. Is this expected?

Regards,
Bharata.

