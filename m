Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E958C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:38:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33A7C20665
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:38:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33A7C20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3D9E8E0003; Wed, 26 Jun 2019 17:38:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC6628E0002; Wed, 26 Jun 2019 17:38:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B66DB8E0003; Wed, 26 Jun 2019 17:38:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8618E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 17:38:25 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 3so40363pgc.5
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:38:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=N54BhY8sgWFT6Ng6bhW9GE3BodSBeilXIICt7rOFHyw=;
        b=mimmuD8u68uYDKzl8GY+7q6qv6/dAepsIWVomMz8dImAB+VUQk6AeKSE8CXGpzXwdE
         3Y29B5NjXEequP6bpL6n3LA1tAqySDOREF5GJmw2ta2tSWGYmL0dDnAKgyy0dTVFJijT
         q3T6qpluKBY2ncQD5QXckEyaHVYteTm7Mx2sSeEkHHbgk2KbhVw9zfj9sx20TqV6J38n
         R9ZqmVuuDxYJGOqU56Zb2a+bl56uxy6lLjibm6aw9Ti4WIIwflQoHELKUA0ZTwcEtEyV
         76wQTTGVCOFasfikAX5qpRiQfgrTki5R2FxSeY75fbz9Av7H9B3YdM9o11QBIMsq3sK5
         d/lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXa5aIuxsiTiq3UnsuZ2ao38NZ2iPzQAdhufU73YcOKYXcUXVVW
	N0Bnhv8gRxn8Adf4rJVpI3V8wEBottH62EEcKDz5sVrwqUmTx60U1qgZUQsmyeK6gAE2ON6bR1j
	TPDTKdwF5gWOLM9pbD8UlcGcRvn1dAJh2zQWwIqRcLiapoQMaqD9SJQBYqtjclRXYdw==
X-Received: by 2002:a63:4d05:: with SMTP id a5mr109328pgb.19.1561585104961;
        Wed, 26 Jun 2019 14:38:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxt3VFNq3AnBknUbegMc+rwO6qqHFt8z0Xy6jXMjVD+OTUDt9P0qmwfzcVRv3KkZCRb67e
X-Received: by 2002:a63:4d05:: with SMTP id a5mr109279pgb.19.1561585103997;
        Wed, 26 Jun 2019 14:38:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561585103; cv=none;
        d=google.com; s=arc-20160816;
        b=fpeaULqTzdRKxO8b877OugclZHrF6S/avuBsdmeBrMjsFjL3+3Iz0YhVK0Q5gwUjO8
         HW/77aCuHNobP/RANfenPiHCOgvcRtlro9YQ/tqOExnZ7W6dA+nDl8EG9bZuETYKj7t7
         1hl3LxCjaLbY/yxx3+F8IcNJfzyPDv6I522a0j24nYAemAAxIpoOyLcHXNkRYKH7ufj/
         VTEHWkDjxSCtRjbdrUAms9506/j4M7FYj9Wj6jh9LstjfR+wPXrpSc7UiZ1S+fhDGmpC
         4WF17XC7WcB1IIsxK+2qBK1SNn0JM8I3GMEqn7KbJXdsE6U/3l5kCFvSctONGt+2J8wa
         tlYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=N54BhY8sgWFT6Ng6bhW9GE3BodSBeilXIICt7rOFHyw=;
        b=McxZSl6RBAFnZCaLsOheQeZpcYW2H3BUYqQzHAswH89rB9gtI/PN1BEaRDMQA6dskq
         KxAPi0ge3Lk/rKWJsImYdwiTAMA5NIHtPUiXK0Hnjc8q6lDLHeOW/LgqaCgElDurwCWi
         gblfx5zKx0jnRywnHzzLmLooy8D6XeSFGrGJ9dHoV6my1M7+azcs0vB15YIF5REsggia
         YPFqTF4V4+bN2ddA2SMt+nAzj4cOtVqul7iqoHXfj1OMPbbeRzYdv+gHgM8UxOoiQ7HM
         Op47y6UiPNmzr/Kitpk0Ruk4j+oP5YfmgeI3Gjk8zDFJX51tmKnG8sucjMAl/jrOOI84
         /6cQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y16si320212pfe.129.2019.06.26.14.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 14:38:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 14:38:23 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,421,1557212400"; 
   d="scan'208";a="360456463"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 26 Jun 2019 14:38:23 -0700
Date: Wed, 26 Jun 2019 14:38:23 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 24/25] mm: remove the HMM config option
Message-ID: <20190626213822.GB8399@iweiny-DESK2.sc.intel.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-25-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626122724.13313-25-hch@lst.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:23PM +0200, Christoph Hellwig wrote:
> All the mm/hmm.c code is better keyed off HMM_MIRROR.  Also let nouveau
> depend on it instead of the mix of a dummy dependency symbol plus the
> actually selected one.  Drop various odd dependencies, as the code is
> pretty portable.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Seems reasonable to me.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  drivers/gpu/drm/nouveau/Kconfig |  3 +--
>  include/linux/hmm.h             |  5 +----
>  include/linux/mm_types.h        |  2 +-
>  mm/Kconfig                      | 27 ++++-----------------------
>  mm/Makefile                     |  2 +-
>  mm/hmm.c                        |  2 --
>  6 files changed, 8 insertions(+), 33 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
> index 6303d203ab1d..66c839d8e9d1 100644
> --- a/drivers/gpu/drm/nouveau/Kconfig
> +++ b/drivers/gpu/drm/nouveau/Kconfig
> @@ -84,11 +84,10 @@ config DRM_NOUVEAU_BACKLIGHT
>  
>  config DRM_NOUVEAU_SVM
>  	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
> -	depends on ARCH_HAS_HMM
>  	depends on DEVICE_PRIVATE
>  	depends on DRM_NOUVEAU
> +	depends on HMM_MIRROR
>  	depends on STAGING
> -	select HMM_MIRROR
>  	default n
>  	help
>  	  Say Y here if you want to enable experimental support for
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 3d00e9550e77..b697496e85ba 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -62,7 +62,7 @@
>  #include <linux/kconfig.h>
>  #include <asm/pgtable.h>
>  
> -#if IS_ENABLED(CONFIG_HMM)
> +#ifdef CONFIG_HMM_MIRROR
>  
>  #include <linux/device.h>
>  #include <linux/migrate.h>
> @@ -332,9 +332,6 @@ static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
>  	return hmm_device_entry_from_pfn(range, pfn);
>  }
>  
> -
> -
> -#if IS_ENABLED(CONFIG_HMM_MIRROR)
>  /*
>   * Mirroring: how to synchronize device page table with CPU page table.
>   *
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index f33a1289c101..8d37182f8dbe 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -501,7 +501,7 @@ struct mm_struct {
>  #endif
>  		struct work_struct async_put_work;
>  
> -#if IS_ENABLED(CONFIG_HMM)
> +#ifdef CONFIG_HMM_MIRROR
>  		/* HMM needs to track a few things per mm */
>  		struct hmm *hmm;
>  #endif
> diff --git a/mm/Kconfig b/mm/Kconfig
> index eecf037a54b3..1e426c26b1d6 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -669,37 +669,18 @@ config ZONE_DEVICE
>  
>  	  If FS_DAX is enabled, then say Y.
>  
> -config ARCH_HAS_HMM_MIRROR
> -	bool
> -	default y
> -	depends on (X86_64 || PPC64)
> -	depends on MMU && 64BIT
> -
> -config ARCH_HAS_HMM
> -	bool
> -	depends on (X86_64 || PPC64)
> -	depends on ZONE_DEVICE
> -	depends on MMU && 64BIT
> -	depends on MEMORY_HOTPLUG
> -	depends on MEMORY_HOTREMOVE
> -	depends on SPARSEMEM_VMEMMAP
> -	default y
> -
>  config MIGRATE_VMA_HELPER
>  	bool
>  
>  config DEV_PAGEMAP_OPS
>  	bool
>  
> -config HMM
> -	bool
> -	select MMU_NOTIFIER
> -	select MIGRATE_VMA_HELPER
> -
>  config HMM_MIRROR
>  	bool "HMM mirror CPU page table into a device page table"
> -	depends on ARCH_HAS_HMM
> -	select HMM
> +	depends on (X86_64 || PPC64)
> +	depends on MMU && 64BIT
> +	select MMU_NOTIFIER
> +	select MIGRATE_VMA_HELPER
>  	help
>  	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
>  	  process into a device page table. Here, mirror means "keep synchronized".
> diff --git a/mm/Makefile b/mm/Makefile
> index ac5e5ba78874..91c99040065c 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -102,5 +102,5 @@ obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
>  obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
>  obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
>  obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
> -obj-$(CONFIG_HMM) += hmm.o
> +obj-$(CONFIG_HMM_MIRROR) += hmm.o
>  obj-$(CONFIG_MEMFD_CREATE) += memfd.o
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 90ca0cdab9db..d62ce64d6bca 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -25,7 +25,6 @@
>  #include <linux/mmu_notifier.h>
>  #include <linux/memory_hotplug.h>
>  
> -#if IS_ENABLED(CONFIG_HMM_MIRROR)
>  static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
>  
>  static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
> @@ -1326,4 +1325,3 @@ long hmm_range_dma_unmap(struct hmm_range *range,
>  	return cpages;
>  }
>  EXPORT_SYMBOL(hmm_range_dma_unmap);
> -#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> -- 
> 2.20.1
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

