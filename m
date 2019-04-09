Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6B7AC10F13
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 00:13:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 825A620883
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 00:13:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 825A620883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C4AE6B0010; Mon,  8 Apr 2019 20:13:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04B8B6B0266; Mon,  8 Apr 2019 20:13:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E30A66B0269; Mon,  8 Apr 2019 20:13:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5E3C6B0010
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 20:13:46 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c64so11614748pfb.6
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 17:13:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=njai0IS8Ev9mind6lbuJ7nDtTouKAEtd98qRyaqQAOA=;
        b=JXnQCdBlhBkAOTtaSP1Z/Rm+Isx7vp2E7cwwNRFGS+RWdaSCk7bXNWwGV5gfcWuQ2w
         saRy+vRZCKpN/IhgD5EVDQtmMFY/cU83M7S2uPfbBc7yiD3Fc+KPgbi66L7YGM4Yx5cM
         bGRyRJ6pemJ4AxufoSZm6PmfrnySHmZkaxNE5EEm6W/nqitWwjTAJqp7JTyMcKIT/SJs
         YO75JzYZuQ9CkS6zEazvdQo01nAITQS/54EwZfO+AUpqtq72hAf067P836hi/ifagbj7
         w/oQozrJpScAWjlXbF1FtUG7z1ZBy1XBuBJe7FAq+zmdPBcF2o5pIwa8BhxVsHrrzsSv
         pnhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWfPsQa5HiFLqRt21kDpvUn2cXyr1ewCCCZSusWhNgYIcUE3u8O
	5XVokTYLIApnYPQjvT+A+GR0UyiQ6KE6eB54OTXqTcHXH9QjInkq9R1lVWY5ya94vnX6/n3xXL1
	ZiJ+n/wJyPAYY4Akr1Fbnvbo3yvJHbT/GoeDQcPmZXkrYk2C5WQhhj5nNB1s7imn9qQ==
X-Received: by 2002:a63:2c09:: with SMTP id s9mr26689820pgs.411.1554768826166;
        Mon, 08 Apr 2019 17:13:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBD9DYpfBHruzuoQ4d1Q1g/Ch7xrmtYPAYbI7KYsYa6YDDFB5M0nIdY0SJtfJNqaNuB0f0
X-Received: by 2002:a63:2c09:: with SMTP id s9mr26689760pgs.411.1554768825156;
        Mon, 08 Apr 2019 17:13:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554768825; cv=none;
        d=google.com; s=arc-20160816;
        b=rwyVilBU0DB4dYmNweS5Np3GCOsTjr3iC2reCela4Eh7H9E2DG1fQEYZpj7yJR/PZy
         UHgM6wM8Ww5pJfYqZVrEZFTz/560iEMxRMAFJk8gFsRTQZEGyZWj2wQ/W9Aj0j2tf7aC
         3Lh3PiUNQ7LeZdzjbuCnE6Mcgf9W8OGcdDr7KPuQ0NdjRAhRz1EG1PC7yLgAEQYP8IxJ
         l2Q1VEPqrq+USchY7SKYVT8VoDoDGV0fAxSDdYyvDN2KINa07woYc0BuSqeUhy2UZZ4r
         c6Ck87OBQuL7IqRLxEIwF7fddLlW4QxwCYnjyVHjSP/H9sjmSxz0ZxUz/K8cNL4lTSa8
         1Obg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=njai0IS8Ev9mind6lbuJ7nDtTouKAEtd98qRyaqQAOA=;
        b=gl6qinuq4y/GP16+lzj6Hc+1+tmxe4LBjybok363kYdhmDXhaWR+on+5sm13cRRwLa
         F4k82Vc3pSdTa0EDx0RLE8etTOK7RIS/Ytt3LR2/r6tIfGR3UjRkYKJNHAVNEPVEV+cj
         mrmFb2poUGujXWZ0qo4ay+B42wKZ9c53sKZanbNB5H3xCL276ek0/Gigf0M8k/9JyI8e
         h3Nstezf+yQuwVqvLPEVZz4FwvJuG8KMqtHjNk2hzMMALpbex0nCA6YlWeKbaMcqq8Ue
         a3MbXKUm/NOMW4dzDrYz1C3Oejkou0/jEyz37x7C/TvDIYcD/LevkDIqngJZywB67eQs
         1T0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id c20si27448595pls.53.2019.04.08.17.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 17:13:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Apr 2019 17:13:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,327,1549958400"; 
   d="scan'208";a="159915232"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 08 Apr 2019 17:13:42 -0700
Date: Mon, 8 Apr 2019 17:13:36 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Subject: Re: [PATCH V3 0/7] Add FOLL_LONGTERM to GUP fast and use it
Message-ID: <20190409001336.GB2049@iweiny-DESK2.sc.intel.com>
References: <20190328084422.29911-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328084422.29911-1-ira.weiny@intel.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 01:44:15AM -0700, 'Ira Weiny' wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> Following discussion and review[1] here are the cleanups requested.
> 
> The biggest change for V3 was the disabling of the ability to use FOLL_LONGTERM
> in get_user_pages[unlocked|locked|remote]
> 
> Comments were also enhanced throughout to show potential users what
> FOLL_LONGTERM is all about and limitations it has.

Does anyone have any problems with these changes?

I would like to get official Reviewed-by tags if possible.

Thanks,
Ira

> 
> Minor review comments were fixed
> 
> Original cover letter:
> 
> HFI1, qib, and mthca, use get_user_pages_fast() due to it performance
> advantages.  These pages can be held for a significant time.  But
> get_user_pages_fast() does not protect against mapping FS DAX pages.
> 
> Introduce FOLL_LONGTERM and use this flag in get_user_pages_fast() which
> retains the performance while also adding the FS DAX checks.  XDP has also
> shown interest in using this functionality.[1]
> 
> In addition we change get_user_pages() to use the new FOLL_LONGTERM flag and
> remove the specialized get_user_pages_longterm call.
> 
> [1] https://lkml.org/lkml/2019/3/19/939
> 
> 
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
>  arch/powerpc/mm/mmu_context_iommu.c         |   3 +-
>  arch/s390/kvm/interrupt.c                   |   2 +-
>  arch/s390/mm/gup.c                          |  12 +-
>  arch/sh/mm/gup.c                            |  11 +-
>  arch/sparc/mm/gup.c                         |   9 +-
>  arch/x86/kvm/paging_tmpl.h                  |   2 +-
>  arch/x86/kvm/svm.c                          |   2 +-
>  drivers/fpga/dfl-afu-dma-region.c           |   2 +-
>  drivers/gpu/drm/via/via_dmablit.c           |   3 +-
>  drivers/infiniband/core/umem.c              |   5 +-
>  drivers/infiniband/hw/hfi1/user_pages.c     |   3 +-
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
>  fs/io_uring.c                               |   5 +-
>  fs/orangefs/orangefs-bufmap.c               |   2 +-
>  include/linux/mm.h                          |  45 ++-
>  kernel/futex.c                              |   2 +-
>  lib/iov_iter.c                              |   7 +-
>  mm/gup.c                                    | 288 +++++++++++++-------
>  mm/gup_benchmark.c                          |   5 +-
>  mm/util.c                                   |   8 +-
>  net/ceph/pagevec.c                          |   2 +-
>  net/rds/info.c                              |   2 +-
>  net/rds/rdma.c                              |   3 +-
>  net/xdp/xdp_umem.c                          |   4 +-
>  46 files changed, 314 insertions(+), 200 deletions(-)
> 
> -- 
> 2.20.1
> 

