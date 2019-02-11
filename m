Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AB05C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:52:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24BE72054F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:52:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24BE72054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB0838E016F; Mon, 11 Feb 2019 16:52:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A613F8E0165; Mon, 11 Feb 2019 16:52:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94FC38E016F; Mon, 11 Feb 2019 16:52:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5394F8E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:52:51 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id k14so373401pls.2
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:52:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DfwhzluMiJRkhh6w2zMSxGd5hXl4FLNYOUk9Jd94V7Y=;
        b=ogC2BZK1qAl9/nnYugCzKD4BGSwayna5FLFfpSz1JAUuCuo+953i7yG6VINQG8mB3t
         yXKhZwurm/7kHLeNs0P6w4l/9HdUBkywtiQfhBI3if2VwSI8XPk6MzgB/G9sP0nefPcX
         e4Cz7mKDWCRG0VrwxAXBnfWWAApEvXF0tNI6FR3fz9ta+Q9IVhx8rdbqZLMrucWe+CCo
         YxL+z8gLavfjm4foGINUkwk1xgx7CsLbl/0st8x/xcRNh/j7dut0GLXIhmkw5NvglaA6
         EtTWHFgcQsBG0lNu/XfE9BylrmCaFFjp7N7sknR1IBiQGkOU+eDsjunSB8S/4NJtktyP
         kLRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubPelBhsBjurGHhpBWPRLYTFJdxIIlfxQ7wq6NCXgz48uuYZTZ1
	cqIE6GhrEiQW2JDOHQ8huUjjAuVtr3cQVStVbKRoVDdyclZtXBTuAFHUSCiqvVWWr4pcSQ+u+kb
	N7HA7yguYWCYy16KbU1BZzay05TIeBTGGqu+0D1j74rJEzrrmYqBm70A1yP27KXNY6Q==
X-Received: by 2002:a17:902:8f8d:: with SMTP id z13mr396920plo.95.1549921970914;
        Mon, 11 Feb 2019 13:52:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY8vcJtFkOTFmpcZ98H0asx0LpLze4sa4D7y2mo+xagSj46QP7rGPNsF85pnZykOj7hoq5Y
X-Received: by 2002:a17:902:8f8d:: with SMTP id z13mr396865plo.95.1549921970049;
        Mon, 11 Feb 2019 13:52:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549921970; cv=none;
        d=google.com; s=arc-20160816;
        b=XN357FUVlrpBrLBYgas5/jcDDtuNYKg9EMOw2Gkxk1pLhfvUvGM2yynq62XZ1nBp71
         ACLEHUBlxMv4yWdpkYS5z3UcQxS/hZwLbPm+DXIiEdY3DnOLmNf0EUzAQ8HJ4zkdjdi8
         AaLywxWI0O0OiVDdTu/h227TZlx/a8DrKj4P6JH22LlACrfrlh4gwsbm82DDpcO6AnuD
         ar1k9bLAnwG+GCpDaSWZLDc/2bpgOjpA/TxXFbzf2pTgx4PJ17yvM/Gtv5CVMVHUZMYm
         zH/iLqpp+8XZZId+3S3HSzaJHgPcbaf/hU6ghHu50LlmEIt5tO42ogjUvJVLTMHXsj0x
         jB5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DfwhzluMiJRkhh6w2zMSxGd5hXl4FLNYOUk9Jd94V7Y=;
        b=bEuCr6Mz33dPSod9WQFAZONIPll96wbaWYCuNeRGYB8DWDb7bqwTnGigDFwzKzIwZx
         OVwrbmhomizbIYSIE18TsFoewlsZk0jvxH/NWyTZV/2GzoGPahSt8MbFKZ49A9WOlykw
         jhwOkpt4MBMBMomirhXkPNQC5YFkdM5C4r0oRfslSAXvD2IxFHG73CxR6FWqO5WPEVpg
         gg2fdOyk6YuqLaImHfVPB9jV6qBQN8NAs+42BBv294IL1aYenCFCU4F5fz5UuUrQ4w4I
         f4tTrMjWG3h58eAJJnGVYyrbxIR4zSBMgmiyOvkJkbuJKjNvGc7BOX0I/1GjBEaZFEiN
         LOcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j66si3226500pfb.182.2019.02.11.13.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:52:50 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 13:52:49 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="318156768"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga006.fm.intel.com with ESMTP; 11 Feb 2019 13:52:49 -0800
Date: Mon, 11 Feb 2019 13:52:38 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>, netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
Message-ID: <20190211215238.GA23825@iweiny-DESK2.sc.intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211201643.7599-3-ira.weiny@intel.com>
 <20190211203916.GA2771@ziepe.ca>
 <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
 <20190211212652.GA7790@iweiny-DESK2.sc.intel.com>
 <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 01:39:12PM -0800, John Hubbard wrote:
> On 2/11/19 1:26 PM, Ira Weiny wrote:
> > On Mon, Feb 11, 2019 at 01:13:56PM -0800, John Hubbard wrote:
> >> On 2/11/19 12:39 PM, Jason Gunthorpe wrote:
> >>> On Mon, Feb 11, 2019 at 12:16:42PM -0800, ira.weiny@intel.com wrote:
> >>>> From: Ira Weiny <ira.weiny@intel.com>
> >> [...]
> >> It seems to me that the longterm vs. short-term is of questionable value.
> > 
> > This is exactly why I did not post this before.  I've been waiting our other
> > discussions on how GUP pins are going to be handled to play out.  But with the
> > netdev thread today[1] it seems like we need to make sure we have a "safe" fast
> > variant for a while.  Introducing FOLL_LONGTERM seemed like the cleanest way to
> > do that even if we will not need the distinction in the future...  :-(
> 
> Yes, I agree. Below...
> 
> > [...]
> > This is also why I did not change the get_user_pages_longterm because we could
> > be ripping this all out by the end of the year...  (I hope. :-)
> > 
> > So while this does "pollute" the GUP family of calls I'm hoping it is not
> > forever.
> > 
> > Ira
> > 
> > [1] https://lkml.org/lkml/2019/2/11/1789
> > 
> 
> Yes, and to be clear, I think your patchset here is fine. It is easy to find
> the FOLL_LONGTERM callers if and when we want to change anything. I just think
> also it's appopriate to go a bit further, and use FOLL_LONGTERM all by itself.
> 
> That's because in either design outcome, it's better that way:
> 
> -- If we keep the concept of "I'm a long-term gup call site", then FOLL_LONGTERM
> is just right. The gup API already has _fast and non-fast variants, and once
> you get past a couple, you end up with a multiplication of names that really
> work better as flags. We're there.
> 
> -- If we drop the concept, then you've already done part of the work, by removing
> the _longterm API variants.

Fair enough.   But to do that correctly I think we will need to convert
get_user_pages_fast() to use flags as well.  I have a version of this series
which includes a patch does this, but the patch touched a lot of subsystems and
a couple of different architectures...[1]

I can't test them all.  If we want to go that way I'm up for submitting the
patch...  But if we remove longterm in the future we may be left with a
get_user_pages_fast() which really only needs 1 flag.  But perhaps overall we
would be better off?

Ira


[1] mm/gup.c: Change GUP fast to use flags rather than write bool

To facilitate additional options to get_user_pages_fast change the
singular write parameter to be the more generic gup_flags.

This patch currently does not change any functionality.  New
functionality will follow in subsequent patches.

Many of the get_user_pages_fast call sites were unchanged because they
already used FOLL_WRITE or 0 as appropriate.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 arch/mips/mm/gup.c                         | 11 ++++++-----
 arch/powerpc/kvm/book3s_64_mmu_hv.c        |  4 ++--
 arch/powerpc/kvm/e500_mmu.c                |  2 +-
 arch/powerpc/mm/mmu_context_iommu.c        |  4 ++--
 arch/s390/kvm/interrupt.c                  |  2 +-
 arch/s390/mm/gup.c                         | 12 ++++++------
 arch/sh/mm/gup.c                           | 11 ++++++-----
 arch/sparc/mm/gup.c                        |  9 +++++----
 arch/x86/kvm/paging_tmpl.h                 |  2 +-
 arch/x86/kvm/svm.c                         |  2 +-
 drivers/fpga/dfl-afu-dma-region.c          |  2 +-
 drivers/gpu/drm/via/via_dmablit.c          |  3 ++-
 drivers/infiniband/hw/hfi1/user_pages.c    |  3 ++-
 drivers/misc/genwqe/card_utils.c           |  2 +-
 drivers/misc/vmw_vmci/vmci_host.c          |  2 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c    |  6 ++++--
 drivers/platform/goldfish/goldfish_pipe.c  |  3 ++-
 drivers/rapidio/devices/rio_mport_cdev.c   |  4 +++-
 drivers/sbus/char/oradax.c                 |  2 +-
 drivers/scsi/st.c                          |  3 ++-
 drivers/staging/gasket/gasket_page_table.c |  4 ++--
 drivers/tee/tee_shm.c                      |  2 +-
 drivers/vfio/vfio_iommu_spapr_tce.c        |  3 ++-
 drivers/vhost/vhost.c                      |  2 +-
 drivers/video/fbdev/pvr2fb.c               |  2 +-
 drivers/virt/fsl_hypervisor.c              |  2 +-
 drivers/xen/gntdev.c                       |  2 +-
 fs/orangefs/orangefs-bufmap.c              |  2 +-
 include/linux/mm.h                         |  4 ++--
 kernel/futex.c                             |  2 +-
 lib/iov_iter.c                             |  7 +++++--
 mm/gup.c                                   | 10 +++++-----
 mm/util.c                                  |  8 ++++----
 net/ceph/pagevec.c                         |  2 +-
 net/rds/info.c                             |  2 +-
 net/rds/rdma.c                             |  3 ++-
 36 files changed, 81 insertions(+), 65 deletions(-)


