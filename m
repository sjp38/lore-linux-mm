Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E29B6C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F0372183F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F0372183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C572B6B000C; Thu, 28 Mar 2019 12:45:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C06B96B000D; Thu, 28 Mar 2019 12:45:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA7786B000E; Thu, 28 Mar 2019 12:45:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65AD76B000C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 12:45:37 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u8so16775070pfm.6
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:45:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=pSMtVaTsgnjEEmKj8MAwt2GQ6EuchIPa6hUgmHI6PJU=;
        b=n5xwwWHEzSl83EIN8rX4CeVWPtx/iuFiWQB+3TTnHRS0XvJEDHw37tzr6/TO7mXeWc
         DJYs6bQrzyUDW/YfFMfoFaLGKF6VlnDsMPRaVl+xpNDvolmuV2z8tMhFoKn9x3Ct5zWi
         YfAFMJEgP3KJoPDjnchZyHcvveVcXVJVR+uzGYLtJ1wRKlU4VQKT7hoTw6gwNKM90yk7
         evcKcj8jc2hvmHb0tWyTdsIIo7YqtB2VqLuqWIAuaypra4n93uGApP10A5eHzcfdUUTe
         RxmsXRL1pit5EBjYaFq/PpEwpQjgE4aLudAFqcvQmjhwfXgyPO3VjIqh8uRPCeoHqe1O
         kciw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX1oHYY162C4hxFQEOV80peAQQ+Rz/FqJJryqju6gm4FhTLZ79u
	ewNYGy76yQJFPZSUt1O5RHj4SavV9MKb7lnjIH7YvwaH02FEuDQpStnIwiIlZszvEk3n1+lbYih
	6x3Q8waZDTIAohxduEp6cPzUlsX5pSyY5UMoVCcHiauNMPQRqUQ1uQwoZm+l5fO61AA==
X-Received: by 2002:a62:b61a:: with SMTP id j26mr41571967pff.151.1553791536853;
        Thu, 28 Mar 2019 09:45:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyesR3/0w8WWmIts3keBnTYKCV0jTJaG5r5jtaUEdUdXp9FnGwzeL5B23XC6Wqlu9tIlH7j
X-Received: by 2002:a62:b61a:: with SMTP id j26mr41571873pff.151.1553791535582;
        Thu, 28 Mar 2019 09:45:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553791535; cv=none;
        d=google.com; s=arc-20160816;
        b=Gjvivu38SNM+2aFFnALx9N8AakYHod+W2tWl0vzrIjvI2nqHZ+NeQlM6daw7RVVMjO
         CU2f0Rt/YxLivwsWYu4Di2j4CDhRrPVZZTNs14Y+fZUNr9aNwvAaviR38MO6dG7xEd8l
         BZIOYfW+TIyvbOqs/whPCfxna4N8KC1Mh8oCBFsFbvIwqCHK9LVbnBlq1sILMt29S9Ci
         55ikt+x2/7Dhz+DixHbmnnA29+TT5se6qoP8XevpunmTETY+BdeHH6TbwLuno9FTy8QU
         LS3c3PibsglYyWWHH556VFI7sfUAtinlMxsYuqSwPkgEL5eBGx8yQVX6Ya3eJIJbF2oq
         TgdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=pSMtVaTsgnjEEmKj8MAwt2GQ6EuchIPa6hUgmHI6PJU=;
        b=0vfA2W7QsRZKE9+TIRgKCnz+Z4+DmVWfrSQJ0AhdHc8DzSyZdKGRZef7eVmd9EEl65
         1+lEEuddsgpA3oUsYi0Ca1md/9FkthamDT7vCNmopvpsfJFv4xeepe4qe6gO3sKwMPlZ
         B3j5EvKeoulQ2LJDHFo1s659e9ZTS3inabTT0N+b3XyuR2cxNNRxDyjfPn2zD7plGV2M
         mmtWlqtC8inMnB2D02DgYun7zcYn8OYbYzHQa0yIGsl9uD3oKhWvvLQKcxKsviMMfCEp
         CxQpDGbOfEMADF4HgdYMJY1EA5GzwyKs273S9awN+YM9VhxyIiZ0sMilwCf7f++e1LFy
         9ybA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 31si22686092plb.39.2019.03.28.09.45.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 09:45:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 09:45:32 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,281,1549958400"; 
   d="scan'208";a="218460183"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 28 Mar 2019 09:45:33 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
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
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	James Hogan <jhogan@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH V3 0/7] Add FOLL_LONGTERM to GUP fast and use it
Date: Thu, 28 Mar 2019 01:44:15 -0700
Message-Id: <20190328084422.29911-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Following discussion and review[1] here are the cleanups requested.

The biggest change for V3 was the disabling of the ability to use FOLL_LONGTERM
in get_user_pages[unlocked|locked|remote]

Comments were also enhanced throughout to show potential users what
FOLL_LONGTERM is all about and limitations it has.

Minor review comments were fixed

Original cover letter:

HFI1, qib, and mthca, use get_user_pages_fast() due to it performance
advantages.  These pages can be held for a significant time.  But
get_user_pages_fast() does not protect against mapping FS DAX pages.

Introduce FOLL_LONGTERM and use this flag in get_user_pages_fast() which
retains the performance while also adding the FS DAX checks.  XDP has also
shown interest in using this functionality.[1]

In addition we change get_user_pages() to use the new FOLL_LONGTERM flag and
remove the specialized get_user_pages_longterm call.

[1] https://lkml.org/lkml/2019/3/19/939



Ira Weiny (7):
  mm/gup: Replace get_user_pages_longterm() with FOLL_LONGTERM
  mm/gup: Change write parameter to flags in fast walk
  mm/gup: Change GUP fast to use flags rather than a write 'bool'
  mm/gup: Add FOLL_LONGTERM capability to GUP fast
  IB/hfi1: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
  IB/qib: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
  IB/mthca: Use the new FOLL_LONGTERM flag to get_user_pages_fast()

 arch/mips/mm/gup.c                          |  11 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c         |   4 +-
 arch/powerpc/kvm/e500_mmu.c                 |   2 +-
 arch/powerpc/mm/mmu_context_iommu.c         |   3 +-
 arch/s390/kvm/interrupt.c                   |   2 +-
 arch/s390/mm/gup.c                          |  12 +-
 arch/sh/mm/gup.c                            |  11 +-
 arch/sparc/mm/gup.c                         |   9 +-
 arch/x86/kvm/paging_tmpl.h                  |   2 +-
 arch/x86/kvm/svm.c                          |   2 +-
 drivers/fpga/dfl-afu-dma-region.c           |   2 +-
 drivers/gpu/drm/via/via_dmablit.c           |   3 +-
 drivers/infiniband/core/umem.c              |   5 +-
 drivers/infiniband/hw/hfi1/user_pages.c     |   3 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c |   3 +-
 drivers/infiniband/hw/qib/qib_user_pages.c  |   8 +-
 drivers/infiniband/hw/qib/qib_user_sdma.c   |   2 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c    |   9 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c   |   6 +-
 drivers/misc/genwqe/card_utils.c            |   2 +-
 drivers/misc/vmw_vmci/vmci_host.c           |   2 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c     |   6 +-
 drivers/platform/goldfish/goldfish_pipe.c   |   3 +-
 drivers/rapidio/devices/rio_mport_cdev.c    |   4 +-
 drivers/sbus/char/oradax.c                  |   2 +-
 drivers/scsi/st.c                           |   3 +-
 drivers/staging/gasket/gasket_page_table.c  |   4 +-
 drivers/tee/tee_shm.c                       |   2 +-
 drivers/vfio/vfio_iommu_spapr_tce.c         |   3 +-
 drivers/vfio/vfio_iommu_type1.c             |   3 +-
 drivers/vhost/vhost.c                       |   2 +-
 drivers/video/fbdev/pvr2fb.c                |   2 +-
 drivers/virt/fsl_hypervisor.c               |   2 +-
 drivers/xen/gntdev.c                        |   2 +-
 fs/io_uring.c                               |   5 +-
 fs/orangefs/orangefs-bufmap.c               |   2 +-
 include/linux/mm.h                          |  45 ++-
 kernel/futex.c                              |   2 +-
 lib/iov_iter.c                              |   7 +-
 mm/gup.c                                    | 288 +++++++++++++-------
 mm/gup_benchmark.c                          |   5 +-
 mm/util.c                                   |   8 +-
 net/ceph/pagevec.c                          |   2 +-
 net/rds/info.c                              |   2 +-
 net/rds/rdma.c                              |   3 +-
 net/xdp/xdp_umem.c                          |   4 +-
 46 files changed, 314 insertions(+), 200 deletions(-)

-- 
2.20.1

