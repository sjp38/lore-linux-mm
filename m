Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=FAKE_REPLY_C,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D26D8C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:29:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AB9F21920
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:29:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AB9F21920
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F78E8E0002; Fri, 15 Feb 2019 13:29:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8298E0001; Fri, 15 Feb 2019 13:29:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BE018E0002; Fri, 15 Feb 2019 13:29:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF73A8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:29:44 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e68so7444742plb.3
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:29:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:reply-to:mime-version:content-disposition
         :user-agent;
        bh=eJX5+HKF5cZ+yX4ACXSl639OGzVXGxRmd72CVoAegoQ=;
        b=Al7K6BcUQrJj/UonU9IP9Z5oxc8zykJ9vUHvupsBZPoocWkcq+hQbHfPSbzJCLmcQ5
         B6Ft3ipIEpSotTlbpBmajB+Ar6c6wvHBnsZgw6GnppC41+oqJu+1JRcDW7CybJ28OHoU
         pI9rVWnJweAdqFUNPiliYjS54B8FRdT8ryhF7t8DHsW5NTnCfZXbeB9qm4tcdIK7I46s
         8ZTCaoix5RQibKGaXi4Ri0A8i3MVYBMqaX1BjEdQkdsp4Whtxl8wyXSdNagT3BRSTFX0
         4hJ6LZABudvKoXDT3hx6u4OG/5MvqF9Ntb+fLtxXdF9ZJgQFMsecJ2m9BZio3ipBs2NJ
         qOVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYzY18kzAfiJLC7RhN4hA0luwPry4WMOHUKoDSe0pTcv2jyKPep
	Gf8VJg+AI6zUVyq2AaAfRd/24sikrdhv+eAnv/9xLd8MNAQfT4rEUyDYb/a+aZrTS431DYeFuWP
	7KfwPjSYyhwaNt1zgPvLvFmjxjSCHcNqbl8BZWUVmXfRNXHABkhEHl2It2+E60CeDBw==
X-Received: by 2002:a62:60c5:: with SMTP id u188mr11169101pfb.4.1550255384457;
        Fri, 15 Feb 2019 10:29:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbJvB/x5yC4AwUjGW3ck7nQTItsVcF4jO8oYR4KAX9qvUokSGv/1/CHNC6Zf6llguoJ5Umw
X-Received: by 2002:a62:60c5:: with SMTP id u188mr11169034pfb.4.1550255383406;
        Fri, 15 Feb 2019 10:29:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550255383; cv=none;
        d=google.com; s=arc-20160816;
        b=TgCraaW2nLPhOoGj0xVA42k287cDw0SlMnXSgOQw4NgJ8by6LlFUilYpUUm+sAs4l0
         ch87qN3fX7rjGC2APlcrvCQpkEPG+PrHf4bufYBxiZvq2BW9lP8YftO4bIT5pHweK4+Q
         rKQbzq3d9H7ryvjbGz8kiTmZRbu6FnKZ1D5ZM+Bzb91E+sPqFAaXpKDv1ZG/c6wa1w16
         TPDDlpHsWOl0JcYHiI7Q3Wg72TDaTI94khCCC5NtBAf5l6hVB0w4o2q+7G3o2X2FNkxF
         xKBD1yfPfSGakREHpWuf5iTcjWWyHCbTgjuztcyyLmMo4ZSkVq5dd8hh1nbl5HiQ6N67
         PMdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:reply-to:message-id
         :subject:to:from:date;
        bh=eJX5+HKF5cZ+yX4ACXSl639OGzVXGxRmd72CVoAegoQ=;
        b=XsUgJETKIXrUDt1RA3vpjsHps8o58AWf1JeRXuwFjG0xUcuNI3fJnS/uo4oKLPCcwx
         5mvMfceKlHdv5wpINo/jXKnvyXS2If+M/aU4m7XEzCTcH1dB/5P9zn/gXDLycVctueOD
         GgRWjrx6pzUs1mm8MeNsEMk2oqtDGk9ZYdZO3f7apRGWU7qAFFQRZWVUjZHn/bOlgM3J
         b6GMyGxRGeHT/n/jIJHm21++uKxKAhW7jCF9ul0VFqWsQu9s4EN/mtzGr5AVvgmTrfFN
         3IPCOhzHFbnj55TwJSMeNnK149UbB/vfUWX0R8WjzJ84rMHqs8qR2z/TVjQh0jEdxW7G
         Ikbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id k2si6096849pfc.189.2019.02.15.10.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 10:29:43 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Feb 2019 10:29:42 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,373,1544515200"; 
   d="scan'208";a="124787412"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 15 Feb 2019 10:29:42 -0800
Date: Fri, 15 Feb 2019 10:29:36 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org, kvm@vger.kernel.org,
	linux-fpga@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org,
	linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org, linux-mm@kvack.org,
	ceph-devel@vger.kernel.org, rds-devel@oss.oracle.com
Subject: Re: [PATCH V2 0/7] Add FOLL_LONGTERM to GUP fast and use it
Message-ID: <20190215182935.GC26988@iweiny-DESK2.sc.intel.com>
Reply-To: 20190211201643.7599-1-ira.weiny@intel.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> NOTE: This series depends on my clean up patch to remove the write parameter
> from gup_fast_permitted()[1]
> 
> HFI1, qib, and mthca, use get_user_pages_fast() due to it performance
> advantages.  These pages can be held for a significant time.  But
> get_user_pages_fast() does not protect against mapping of FS DAX pages.
> 
> Introduce FOLL_LONGTERM and use this flag in get_user_pages_fast() which
> retains the performance while also adding the FS DAX checks.  XDP has also
> shown interest in using this functionality.[2]
> 
> In addition we change get_user_pages() to use the new FOLL_LONGTERM flag and
> remove the specialized get_user_pages_longterm call.
> 
> [1] https://lkml.org/lkml/2019/2/11/237
> [2] https://lkml.org/lkml/2019/2/11/1789

Any comments on this series?  I've touched a lot of subsystems which I think
require review.

Thanks,
Ira

> 
> Ira Weiny (7):
>   mm/gup: Replace get_user_pages_longterm() with FOLL_LONGTERM
>   mm/gup: Change write parameter to flags in fast walk
>   mm/gup: Change GUP fast to use flags rather than a write 'bool'
>   mm/gup: Add FOLL_LONGTERM capability to GUP fast
>   IB/hfi1: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
>   IB/qib: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
>   IB/mthca: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
> 
>  arch/mips/mm/gup.c                          |  11 +-
>  arch/powerpc/kvm/book3s_64_mmu_hv.c         |   4 +-
>  arch/powerpc/kvm/e500_mmu.c                 |   2 +-
>  arch/powerpc/mm/mmu_context_iommu.c         |   4 +-
>  arch/s390/kvm/interrupt.c                   |   2 +-
>  arch/s390/mm/gup.c                          |  12 +-
>  arch/sh/mm/gup.c                            |  11 +-
>  arch/sparc/mm/gup.c                         |   9 +-
>  arch/x86/kvm/paging_tmpl.h                  |   2 +-
>  arch/x86/kvm/svm.c                          |   2 +-
>  drivers/fpga/dfl-afu-dma-region.c           |   2 +-
>  drivers/gpu/drm/via/via_dmablit.c           |   3 +-
>  drivers/infiniband/core/umem.c              |   5 +-
>  drivers/infiniband/hw/hfi1/user_pages.c     |   5 +-
>  drivers/infiniband/hw/mthca/mthca_memfree.c |   3 +-
>  drivers/infiniband/hw/qib/qib_user_pages.c  |   8 +-
>  drivers/infiniband/hw/qib/qib_user_sdma.c   |   2 +-
>  drivers/infiniband/hw/usnic/usnic_uiom.c    |   9 +-
>  drivers/media/v4l2-core/videobuf-dma-sg.c   |   6 +-
>  drivers/misc/genwqe/card_utils.c            |   2 +-
>  drivers/misc/vmw_vmci/vmci_host.c           |   2 +-
>  drivers/misc/vmw_vmci/vmci_queue_pair.c     |   6 +-
>  drivers/platform/goldfish/goldfish_pipe.c   |   3 +-
>  drivers/rapidio/devices/rio_mport_cdev.c    |   4 +-
>  drivers/sbus/char/oradax.c                  |   2 +-
>  drivers/scsi/st.c                           |   3 +-
>  drivers/staging/gasket/gasket_page_table.c  |   4 +-
>  drivers/tee/tee_shm.c                       |   2 +-
>  drivers/vfio/vfio_iommu_spapr_tce.c         |   3 +-
>  drivers/vfio/vfio_iommu_type1.c             |   3 +-
>  drivers/vhost/vhost.c                       |   2 +-
>  drivers/video/fbdev/pvr2fb.c                |   2 +-
>  drivers/virt/fsl_hypervisor.c               |   2 +-
>  drivers/xen/gntdev.c                        |   2 +-
>  fs/orangefs/orangefs-bufmap.c               |   2 +-
>  include/linux/mm.h                          |  17 +-
>  kernel/futex.c                              |   2 +-
>  lib/iov_iter.c                              |   7 +-
>  mm/gup.c                                    | 220 ++++++++++++--------
>  mm/gup_benchmark.c                          |   5 +-
>  mm/util.c                                   |   8 +-
>  net/ceph/pagevec.c                          |   2 +-
>  net/rds/info.c                              |   2 +-
>  net/rds/rdma.c                              |   3 +-
>  44 files changed, 232 insertions(+), 180 deletions(-)
> 
> -- 
> 2.20.1
> 

