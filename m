Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21F6CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 19:14:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEF652133D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 19:14:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEF652133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F5878E0004; Wed, 27 Feb 2019 14:14:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17EC48E0001; Wed, 27 Feb 2019 14:14:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 045B08E0004; Wed, 27 Feb 2019 14:14:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B05CA8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 14:14:34 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id j95so13082562plb.21
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 11:14:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eHv3kauXZUZTOe6xfjEqA9g9d6gK3NE2bjENAUH6YRg=;
        b=YkY6rjLTZURaZ8HOVwQCNEhwc/VZOM7Rh86Sy481rzfdK0S9o5+ljY7XH8WjiuKJnX
         Jel4eXqcOSXrU7qIiHuZQY498tm1zc+9bRBUvZaawk28mvpY+cZIYkjQxOY2B/0ppXmP
         6jpi2dOtP66eL9UP1sGu5CIjvl/eiq5GlQGTKGNpVt0H1fTWHH72B96OICDfai9eI+oZ
         sqCtZBm3HXZBIUfuhtP1LaLW1XLJIFkidquiozYTZVH26bloCMlkGnbO0Qi9zvUSZMvB
         mzTZVFx/rC7hBdC9GFtZQj3vVllOUyrcA/SKkIP/xgXXLf5zPBeLwf77BgK2fgs1Ftuf
         xVdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuamNzOu0cBW1q2z5KNLBMUZGhL+Y1XH1OUZI/NrXxoQzbRQ8Os6
	dVQPgD/B1jOoQiwvVG4Zly8rSugEYmn0LukYEWQjf4wABSqjZ+pyCZpdfrq3TmU2aag70oDd4Gx
	7UQIP/c/UFQ9llbbBK0tILKcDk+2rIvv+1AvYoyQwQP8YRV/Xci9hq5cJqeyzZELXpQ==
X-Received: by 2002:a17:902:20c3:: with SMTP id v3mr3838003plg.268.1551294874317;
        Wed, 27 Feb 2019 11:14:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbSCb9oTxEpnqnWSUdUSkFZoECUb3oyKH82+X8stctwOGmqxTJKuaEpyN4ixQY/a5Nk+4zn
X-Received: by 2002:a17:902:20c3:: with SMTP id v3mr3837891plg.268.1551294872891;
        Wed, 27 Feb 2019 11:14:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551294872; cv=none;
        d=google.com; s=arc-20160816;
        b=IIA3nRxqEHwr47dZKiRI/cp0qTEetqoPIL8T42RmKodjSMRWfXXoB5Kk3b9K5rmyg/
         MKRU0H2ugA5cpnLg9HZJfWIS07o3rV5Vp0EEmZU3BGHKPuCjlMXMoxxfMYmO0Cdk7F/2
         tXxcr/IlH+iGP2DsJN68G+p9IX1R8rWTAy5NhgBRa6BzSirPSxTDaTGGCL1F2HKVMOTX
         RpBugX6DinbVGSGGQM56veCEsW2NZwS3wFQteVvKG5lqFxE59ykYvxvDxb8QJ45hmTvj
         KbhmVUFEoujWIxYuPdo7GeO5gRkC4mChkoE3ugJFhkVY26+OM7JhuP2de6qzqXp8as/m
         6AmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eHv3kauXZUZTOe6xfjEqA9g9d6gK3NE2bjENAUH6YRg=;
        b=nRVnzUtlRIecmSo+L2rrMvO3KqPG39+EQYOPFGnSWMIkZISalrzsqz/xyrdfkMRXMH
         Z7M8yXDZOIiRfyfed+6z7P5vrNC5DNB4Auxmw0F7r80uKbGukR/daxJ5Jj1Cw6iGe9h7
         gSMr43uBBO4t/P2J0wnMOYJj1EfDKvcWy6C2r1luXjDFJ/Jb2jFOM2T7P20H6ikL3Pgt
         xRmTXK9o2+Jl5ksPwKiMtOIaXKtpxvzeufW20feGOPaQ0xyG7x/YZccDpYst5cyHqS2x
         0qgLh8/E4OZMEXOMKf/WyHd2qiOJ1IoHW+rmfqOMgUb4XIPkiIOeP4evF/3tIj7qyiTq
         Fa8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m11si15258815plt.189.2019.02.27.11.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 11:14:32 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Feb 2019 11:14:32 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,420,1544515200"; 
   d="scan'208";a="150535022"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 27 Feb 2019 11:14:31 -0800
Date: Wed, 27 Feb 2019 11:14:42 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
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
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org, kvm-ppc@vger.kernel.org,
	kvm@vger.kernel.org, linux-fpga@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, linux-scsi@vger.kernel.org,
	devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org, ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Subject: Re: [RESEND PATCH 0/7] Add FOLL_LONGTERM to GUP fast and use it
Message-ID: <20190227191442.GB31669@iweiny-DESK2.sc.intel.com>
References: <20190220053040.10831-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220053040.10831-1-ira.weiny@intel.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 09:30:33PM -0800, 'Ira Weiny' wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> Resending these as I had only 1 minor comment which I believe we have covered
> in this series.  I was anticipating these going through the mm tree as they
> depend on a cleanup patch there and the IB changes are very minor.  But they
> could just as well go through the IB tree.
> 
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

Is there anything I need to do on this series or does anyone have any
objections to it going into 5.1?  And if so who's tree is it going to go
through?

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

