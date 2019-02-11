Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F19D8C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:01:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F561218A1
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:01:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="EZQrmNGE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F561218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48FB58E0177; Mon, 11 Feb 2019 17:01:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43F588E0176; Mon, 11 Feb 2019 17:01:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32F468E0177; Mon, 11 Feb 2019 17:01:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7AC8E0176
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:01:14 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id m2so299707ybp.20
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:01:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=vWs2aKXh4VkvG7WO8haiJ5PzQmL2tFLJDsIxpuuhupo=;
        b=B6AGlz/CPci4m1VAOZCtob5+stdRmWLBx9WOtkyxQKtmTLmvzgKbu97eEUAdEbAd/r
         ssDlb/4zXrySVURtPMWWNguJJQuYUOzMnAMDftBN3mKNhCT1Zogq+F1HCsKx96a/vDbU
         FcEuGj4UN7rZo2sTRdlnc4zT9qwSdHTgpR/NqyAVDKC17/BTKeQcNaahpHENLfOoAmBx
         oT2oIrhECe5QEH6m8HQG+I7xeF5HHamp0F2GNTdAunUR3M18qXklpMIlxYkwVYpszLeI
         Z2Pfac3uTSQOQ+3+GzxPa/1Lj9zfn83tF5uXbW8vkuufSECbAYX2vWUKAQ9SC4YUssZ6
         0xBw==
X-Gm-Message-State: AHQUAubMZFp72PmyrE0I1DiYthjzuJw+k6fwdPFL3r5hPmjRlkRpOjBt
	MoB/lxoBtSSj5/ZxS/3WkDaLENTcoB5Qz6cIcnrijiwQXjUD/Zq8cx44Qnehh+AtU9W2vDlyc/A
	4NPZTOZMA3hC0+bspPXN8oHf3SorYW0Qhhom37xHwssyl86rnO4eOipXZHZ6n9E23eA==
X-Received: by 2002:a0d:ca06:: with SMTP id m6mr329730ywd.98.1549922473750;
        Mon, 11 Feb 2019 14:01:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia/Em7s/jzfeo4khg+Kxm4aNIUiVcarDffxtqlaclecKwph+9JGHdZFsb1RUdlc2n1viCD4
X-Received: by 2002:a0d:ca06:: with SMTP id m6mr329683ywd.98.1549922473063;
        Mon, 11 Feb 2019 14:01:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549922473; cv=none;
        d=google.com; s=arc-20160816;
        b=hgIHElV9/RknTxzgFwMT2O1D0IpuEjZftdKDMpSZ7RQIO+WSWf0cNTB7am7TnLrajd
         nzfs7C8clc0kZkV9ATQfWyM3EVA8TQR/sQx1fgQPUdVJG2Vf9xCqoJZy66AMWrewZKGn
         3hPnzCNn+60eW/y7EdkyO4ae2UJGHXtJVAHbWPKbtbRbK6qaeMID7F+YZWh/BXHHeNWe
         C6Yqf3zWBRHV4erFAw0F5XEclZW7AkKLh5ySl/YTku9VQgn9QrM+H7rYeMBrbT0AWrmP
         oq01R8UGNPbX494hMnxojEqqknLBvq4/knrkLb6AH9n0SjFuNpEKn8rfLQsvS7jCZM9q
         g8lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=vWs2aKXh4VkvG7WO8haiJ5PzQmL2tFLJDsIxpuuhupo=;
        b=JB7td3lDmcapxYrBB+XuguTRgbT1eRQNS3DEX5LNplWglLnkW/1zWhcszlZnWusW43
         Rz+YJhvMs7nvW6EO8EUFaJH4EAbXLLu3gtN4AMGKUhcCCddsjhPvWnauZrbrS15DnNTc
         dPTI9mzI/xmzyZ+ByKgnF6j6Zv9wqy5qT6ceESzAgO+FnZRCB2HOwAiEk+GKIJlwGzUi
         30j4nymMF1SI9uMYN2W8BFA0jBYaM3TJ577uBqCEfCYHwgPeDs7knc/9irWLHM0lcF5p
         dFyUYBhnJCxVKi0i3TBwY1mlc7LVxhv3UdG4SV0S2V/AEi+AZ5UMzbmTPq6+xl2OwRJ3
         6PsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=EZQrmNGE;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id h32si6405618ybi.219.2019.02.11.14.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:01:13 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=EZQrmNGE;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c61f0850002>; Mon, 11 Feb 2019 14:00:38 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 11 Feb 2019 14:01:12 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 11 Feb 2019 14:01:12 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 11 Feb
 2019 22:01:11 +0000
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
To: Ira Weiny <ira.weiny@intel.com>
CC: Jason Gunthorpe <jgg@ziepe.ca>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>, Daniel Borkmann
	<daniel@iogearbox.net>, Davidlohr Bueso <dave@stgolabs.net>,
	<netdev@vger.kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams
	<dan.j.williams@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211201643.7599-3-ira.weiny@intel.com> <20190211203916.GA2771@ziepe.ca>
 <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
 <20190211212652.GA7790@iweiny-DESK2.sc.intel.com>
 <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
 <20190211215238.GA23825@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <f392756e-f885-e32e-77a9-d3a51689bee0@nvidia.com>
Date: Mon, 11 Feb 2019 14:01:11 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190211215238.GA23825@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549922438; bh=vWs2aKXh4VkvG7WO8haiJ5PzQmL2tFLJDsIxpuuhupo=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=EZQrmNGEqpt0sljknlDD5qDlmVF+KBcIX1F9PjPhl1qC3uyH76fvnqkaxSFw8QeFl
	 tNUm1VP4uk1PJDLX9jOZ49OA00wchP3s8+oAfLb+KGzX20/vXDU7FEpbLmMdwF0umt
	 uXq1LTcC5dbPzJBXMHz7UN1qZrTsDZQhV6n6hq+Xtozit/Y+gfpqTlgGuqWmJxoape
	 2RbUjashm8TFMTMfSmdQZ/D5QzO3aaX9CB1SzVlUWoWsWOcysXLS/+8mwvJsrnKBLM
	 sP9qgYuiorn9eS3zZkbff50xGSijAGyoiPxkSROf9nIPMLSb5T1O/uL854sjh/f9p+
	 oD9g8x5lI235Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/11/19 1:52 PM, Ira Weiny wrote:
> On Mon, Feb 11, 2019 at 01:39:12PM -0800, John Hubbard wrote:
>> On 2/11/19 1:26 PM, Ira Weiny wrote:
>>> On Mon, Feb 11, 2019 at 01:13:56PM -0800, John Hubbard wrote:
>>>> On 2/11/19 12:39 PM, Jason Gunthorpe wrote:
>>>>> On Mon, Feb 11, 2019 at 12:16:42PM -0800, ira.weiny@intel.com wrote:
>>>>>> From: Ira Weiny <ira.weiny@intel.com>
>>>> [...]
> Fair enough.   But to do that correctly I think we will need to convert
> get_user_pages_fast() to use flags as well.  I have a version of this series
> which includes a patch does this, but the patch touched a lot of subsystems and
> a couple of different architectures...[1]
> 
> I can't test them all.  If we want to go that way I'm up for submitting the

I have a similar problem, and a similar list of call sites, for the
put_user_pages() conversion, so that file list looks familiar. And the
arch-specific gup implementations are about to complicate my life too. :)

> patch...  But if we remove longterm in the future we may be left with a
> get_user_pages_fast() which really only needs 1 flag.  But perhaps overall we
> would be better off?
> 
> Ira

I certainly think so, yes.


thanks,
-- 
John Hubbard
NVIDIA
> 
> 
> [1] mm/gup.c: Change GUP fast to use flags rather than write bool
> 
> To facilitate additional options to get_user_pages_fast change the
> singular write parameter to be the more generic gup_flags.
> 
> This patch currently does not change any functionality.  New
> functionality will follow in subsequent patches.
> 
> Many of the get_user_pages_fast call sites were unchanged because they
> already used FOLL_WRITE or 0 as appropriate.
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  arch/mips/mm/gup.c                         | 11 ++++++-----
>  arch/powerpc/kvm/book3s_64_mmu_hv.c        |  4 ++--
>  arch/powerpc/kvm/e500_mmu.c                |  2 +-
>  arch/powerpc/mm/mmu_context_iommu.c        |  4 ++--
>  arch/s390/kvm/interrupt.c                  |  2 +-
>  arch/s390/mm/gup.c                         | 12 ++++++------
>  arch/sh/mm/gup.c                           | 11 ++++++-----
>  arch/sparc/mm/gup.c                        |  9 +++++----
>  arch/x86/kvm/paging_tmpl.h                 |  2 +-
>  arch/x86/kvm/svm.c                         |  2 +-
>  drivers/fpga/dfl-afu-dma-region.c          |  2 +-
>  drivers/gpu/drm/via/via_dmablit.c          |  3 ++-
>  drivers/infiniband/hw/hfi1/user_pages.c    |  3 ++-
>  drivers/misc/genwqe/card_utils.c           |  2 +-
>  drivers/misc/vmw_vmci/vmci_host.c          |  2 +-
>  drivers/misc/vmw_vmci/vmci_queue_pair.c    |  6 ++++--
>  drivers/platform/goldfish/goldfish_pipe.c  |  3 ++-
>  drivers/rapidio/devices/rio_mport_cdev.c   |  4 +++-
>  drivers/sbus/char/oradax.c                 |  2 +-
>  drivers/scsi/st.c                          |  3 ++-
>  drivers/staging/gasket/gasket_page_table.c |  4 ++--
>  drivers/tee/tee_shm.c                      |  2 +-
>  drivers/vfio/vfio_iommu_spapr_tce.c        |  3 ++-
>  drivers/vhost/vhost.c                      |  2 +-
>  drivers/video/fbdev/pvr2fb.c               |  2 +-
>  drivers/virt/fsl_hypervisor.c              |  2 +-
>  drivers/xen/gntdev.c                       |  2 +-
>  fs/orangefs/orangefs-bufmap.c              |  2 +-
>  include/linux/mm.h                         |  4 ++--
>  kernel/futex.c                             |  2 +-
>  lib/iov_iter.c                             |  7 +++++--
>  mm/gup.c                                   | 10 +++++-----
>  mm/util.c                                  |  8 ++++----
>  net/ceph/pagevec.c                         |  2 +-
>  net/rds/info.c                             |  2 +-
>  net/rds/rdma.c                             |  3 ++-
>  36 files changed, 81 insertions(+), 65 deletions(-)
> 
> 

