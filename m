Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 479A0C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 20:30:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD98C218EA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 20:30:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD98C218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 209056B0003; Thu, 25 Jul 2019 16:30:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C2266B0005; Thu, 25 Jul 2019 16:30:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05A9C8E0002; Thu, 25 Jul 2019 16:30:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C29B76B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 16:30:14 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n4so26450562plp.4
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:30:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3b9v6WXxpgyLOFUurf66vx9/nbh4RlaFuHrR+Si6bic=;
        b=qNaXD7l49J6LwFgJjQAZYVsxmsWHmOKLH1BHJcBTM7VQTweDSuQiqoRzMI1LitdZWm
         YomvXbZX/E75wAoyD3+73SacwbbmydoiMzkVhJkCbLlP7zCwxo/nT5APow/3aYI50hpF
         zLz2euxVJJUwrAL52rTbmcfGT9ESshOXrPdmBxhRU/mySpLFON+K9dBxdZ3el4/vg82a
         CEw8iuNNJTlSDpqqlMEnIunuJE6SZGTo0uziD3IbGeK4nTDE7yDuDXAiEJZwghFQ0WhA
         eSqZeViOIHRDetfv7fHTvY4FOs90mB3Fh+t43237bsVSEGCtNchQi+rD/7eAoqPlmW1i
         1wVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVmJYIu33OIOhB0QUcgfiTKfMMehw8/XVfDQSyfH0lQ0YsvaygF
	nEZMWRWhrurJBcaL4/HDaUhFaoHsEdpV+lPuah/diExPetuObhgg8/sMm1bBSVE8bp3bZCtgo90
	Iaw43O9REU+KhEwaMnDYec1OEG6JYwoFjnRlF1N/ATPArciNYS1DoQcEy7Ef5hNhJ8g==
X-Received: by 2002:a17:902:4e25:: with SMTP id f34mr92219843ple.305.1564086614408;
        Thu, 25 Jul 2019 13:30:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxewwnK/1rHoJQiB8bJsUU6pBUcx2T/IsIjPv0yaXxu5Y3vNgYogT6L+dQAQIUorZMAYjsX
X-Received: by 2002:a17:902:4e25:: with SMTP id f34mr92219734ple.305.1564086613009;
        Thu, 25 Jul 2019 13:30:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564086613; cv=none;
        d=google.com; s=arc-20160816;
        b=mpwiSvxcBfsF10VVwI1BbuCoAcA/tT8yUKc+maTAMSn/tOR2CXLoCfs0j+M9Ok0q0w
         70ACrl9HH0jzucpoHTr7ZUSnmC647mJO4sntmpLMNRvX1/PxOo3Z3OcZQZ7dXxa/K65S
         9zHdDZUSh2hgGeQ7408xjx+jZ+z3uhbPZn4mDPkjnXLG8Psw4m5Xnqx1ukWPBrASzQZa
         G6VpMYe8bcdPuOyvirfD4WawzBb+rCrjQwtlmbE4DyLPBMmrOe2daJJuskr/mD25BM60
         ChWPKy8pmTCK1ULzOmtf7hVrAzqJyfUzv9Oy/7QDcIZhxNa64VU2i4PdDpx6pUMQ7mol
         TGbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3b9v6WXxpgyLOFUurf66vx9/nbh4RlaFuHrR+Si6bic=;
        b=xEUXiYGMZND+vD5mryg4lHCwRmfyBI7RSARJMabJortabEBV9C9opUoDemEKwlf1t1
         Az8CSdN+7M825kKnMOUU0NszWsdGNzFFOHNTotsk8S8A+vmHFQs9GN/X7h9Uf9AeHnJv
         cvMhVwYjdhNQXwlwxVJ894PjrPyGg5hoKujJ3VWDrQC4/JfvvA6JrIj28u04Vp6qXBxs
         GfwWqCgHUxF7odb6oT4+yu9M3M0D1uaILW4xlKXXcsiva2UHDNXSRIL425oycdy4uE2I
         a023Tt5sdX2Sg6d5cmiEsVg2mXzG/tr7JbbLvsVGmansDXMwUuRTN3LbpAxpfrbph4GH
         IhXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s38si18800223pgl.138.2019.07.25.13.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 13:30:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 13:30:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,308,1559545200"; 
   d="scan'208";a="193989896"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 25 Jul 2019 13:30:12 -0700
Date: Thu, 25 Jul 2019 13:30:12 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, Matthew Wilcox <willy@infradead.org>,
	kbuild-all@01.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 2/3] mm: Introduce page_shift()
Message-ID: <20190725203011.GA7362@iweiny-DESK2.sc.intel.com>
References: <20190721104612.19120-3-willy@infradead.org>
 <201907241853.yNQTrJWd%lkp@intel.com>
 <20190724173055.d3c6993bfdad0f49f95b311c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724173055.d3c6993bfdad0f49f95b311c@linux-foundation.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 05:30:55PM -0700, Andrew Morton wrote:
> On Wed, 24 Jul 2019 18:40:25 +0800 kbuild test robot <lkp@intel.com> wrote:
> 
> > Thank you for the patch! Yet something to improve:
> > 
> > [auto build test ERROR on linus/master]
> > [cannot apply to v5.3-rc1 next-20190724]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> > 
> > url:    https://github.com/0day-ci/linux/commits/Matthew-Wilcox/Make-working-with-compound-pages-easier/20190722-030555
> > config: powerpc64-allyesconfig (attached as .config)
> > compiler: powerpc64-linux-gcc (GCC) 7.4.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         # save the attached .config to linux build tree
> >         GCC_VERSION=7.4.0 make.cross ARCH=powerpc64 
> > 
> > If you fix the issue, kindly add following tag
> > Reported-by: kbuild test robot <lkp@intel.com>
> > 
> > Note: the linux-review/Matthew-Wilcox/Make-working-with-compound-pages-easier/20190722-030555 HEAD e1bb8b04ba8cf861b2610b0ae646ee49cb069568 builds fine.
> >       It only hurts bisectibility.
> > 
> > All error/warnings (new ones prefixed by >>):
> > 
> >    drivers/vfio/vfio_iommu_spapr_tce.c: In function 'tce_page_is_contained':
> > >> drivers/vfio/vfio_iommu_spapr_tce.c:193:9: error: called object 'page_shift' is not a function or function pointer
> >      return page_shift(compound_head(page)) >= page_shift;
> >             ^~~~~~~~~~
> >    drivers/vfio/vfio_iommu_spapr_tce.c:179:16: note: declared here
> >       unsigned int page_shift)
> >                    ^~~~~~~~~~
> 
> This?

Looks reasonable to me.  But checking around it does seem like "page_shift" is
used as a parameter or variable in quite a few other places.

Is this something to be concerned with?

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> 
> --- a/drivers/vfio/vfio_iommu_spapr_tce.c~mm-introduce-page_shift-fix
> +++ a/drivers/vfio/vfio_iommu_spapr_tce.c
> @@ -176,13 +176,13 @@ put_exit:
>  }
>  
>  static bool tce_page_is_contained(struct mm_struct *mm, unsigned long hpa,
> -		unsigned int page_shift)
> +		unsigned int it_page_shift)
>  {
>  	struct page *page;
>  	unsigned long size = 0;
>  
> -	if (mm_iommu_is_devmem(mm, hpa, page_shift, &size))
> -		return size == (1UL << page_shift);
> +	if (mm_iommu_is_devmem(mm, hpa, it_page_shift, &size))
> +		return size == (1UL << it_page_shift);
>  
>  	page = pfn_to_page(hpa >> PAGE_SHIFT);
>  	/*
> @@ -190,7 +190,7 @@ static bool tce_page_is_contained(struct
>  	 * a page we just found. Otherwise the hardware can get access to
>  	 * a bigger memory chunk that it should.
>  	 */
> -	return page_shift(compound_head(page)) >= page_shift;
> +	return page_shift(compound_head(page)) >= it_page_shift;
>  }
>  
>  static inline bool tce_groups_attached(struct tce_container *container)
> _
> 

