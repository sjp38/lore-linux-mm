Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF625C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 23:42:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F56620850
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 23:42:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F56620850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B2496B0005; Wed, 10 Apr 2019 19:42:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 562246B0006; Wed, 10 Apr 2019 19:42:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 451466B0007; Wed, 10 Apr 2019 19:42:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B87C6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 19:42:04 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d15so3080527pgt.14
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 16:42:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=0sglOTR88UK4BN8We6xPBN2APcnpXzXvcEWvQ5HbMU8=;
        b=XzaRYm+V0lV1qmoVKseQuDtG90x0ikpMg7inwfOXVxOHXmGjVJgGNaWUmKw+k4NeTw
         czqLI8mi9URdlDpYRrTOTh7jGpdN7wlxSVBhb1d7M5j/Whvg6HwJMysPiL+ZS4QmXcv8
         9m0AGW0pYLUiuuQSk6mS6zAbpDJ8ZvGVxPJwr/kg1ZOM9aLU6tgmI2gYCyRpLdxdV9OV
         PJylzihkVV3yyK/Rrwj7atulhm9HBQE7EgsBs++aFL1BDKikCIGrJHao2nvHyjT5tIUV
         aetJp1VPvmNd72ghHx5brk0Vv/Wex6vqx9F1q0KTXQDEXk7kIJ6Lk1I8EjjmT3VvUp+r
         9WrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVeYlPe/2tqhWPhkNslUQKkydNjLGrh64xSEohV6qfE0ZP9li9M
	wUCka8YosZd/LX/zLiklHup9ksP8UNSUZ8QeSrDJ0EM8WZYQNymuaftRv9H5miG9pH6Vj4yCr+y
	thEy82GpYeUORFblwiRJbIxVw2GkmJM5g9AByHRMc7D2tdgtUI61xDbvwZNiiW8o/wQ==
X-Received: by 2002:a62:ab14:: with SMTP id p20mr46300281pff.23.1554939723548;
        Wed, 10 Apr 2019 16:42:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxK2vhe7VG/Idof1zx9myrl5u9lRZoG58AmGrly/OlvQU2UaSXGP3RFGcEQ07x1lKZeh2+S
X-Received: by 2002:a62:ab14:: with SMTP id p20mr46300219pff.23.1554939722595;
        Wed, 10 Apr 2019 16:42:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554939722; cv=none;
        d=google.com; s=arc-20160816;
        b=PUn8xEMRdy79jm6rvhsmO8h7KmbvL6ux54i8gAPs46uCbSqdeSurbojz4z6uFx4YWW
         fdE2b/G/s1mORdXkHgQGIDwQS8+/xdCsBibMQKnRheDvxdiaRDeCMUINnJ49pU0+TEV8
         3D4afUTgVCIw6hR/Ux1zg/wXqK9C3D8w8x73gbv/zdIRymd358e3O1BeRCXh3ARAtrjc
         wtvBJvOGxbs42FEbfo1cfp0sef8FU1lViWwq7lu2DOW/kIDKHldPBfcyu/IoqdYIljA7
         Gzw4zjJYbtvUL1RjBs6WaQmAX1qIotvEhrd7/E2x3JLSyrD+dokfLdwWIe8rIkzzrYEp
         r5Mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=0sglOTR88UK4BN8We6xPBN2APcnpXzXvcEWvQ5HbMU8=;
        b=VlhReGvwLeyl3/FKHx9uJoL9/kTyfk80vi3auVxVzs6UwhhTVuxj92B1Hl8NFkQH39
         zcxJOI+sfFFykMmEqpDjZyjwtEl/Xj2yHR6E8fbI2LpqFps8j1fn2cqZTtAsB0+AZRoV
         qvuhONloBFyN52SXwf6FB5WbyiCkZTNZ4lS3aYP+ZUmwQwPx2RDHyWVYOnXNMSBIo9ia
         hZZrkgGIOlK18QgBfFyZK4plGuHU5T3jkTcs7xE3xuhqbsBYZl17KwVMCWfDiKYWQxbd
         HIYmsJ+lH1Xoq2sBYWwXF1RPhibLaQ5gIlfYokfFVz7IUPBBktl2ddL/CGLMCsOGU0dN
         qtGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id i195si33153416pgd.521.2019.04.10.16.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 16:42:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Apr 2019 16:42:01 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,335,1549958400"; 
   d="scan'208";a="134714856"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 10 Apr 2019 16:42:00 -0700
Date: Wed, 10 Apr 2019 16:41:57 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: jglisse@redhat.com
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v6 7/8] mm/mmu_notifier: pass down vma and reasons why
 mmu notifier is happening v2
Message-ID: <20190410234124.GE22989@iweiny-DESK2.sc.intel.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
 <20190326164747.24405-8-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190326164747.24405-8-jglisse@redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 12:47:46PM -0400, Jerome Glisse wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> CPU page table update can happens for many reasons, not only as a result
> of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> as a result of kernel activities (memory compression, reclaim, migration,
> ...).
> 
> Users of mmu notifier API track changes to the CPU page table and take
> specific action for them. While current API only provide range of virtual
> address affected by the change, not why the changes is happening
> 
> This patch is just passing down the new informations by adding it to the
> mmu_notifier_range structure.
> 
> Changes since v1:
>     - Initialize flags field from mmu_notifier_range_init() arguments
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: Christian König <christian.koenig@amd.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Peter Xu <peterx@redhat.com>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Krčmář <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Christian Koenig <christian.koenig@amd.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>  include/linux/mmu_notifier.h | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 62f94cd85455..0379956fff23 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -58,10 +58,12 @@ struct mmu_notifier_mm {
>  #define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
>  
>  struct mmu_notifier_range {
> +	struct vm_area_struct *vma;
>  	struct mm_struct *mm;
>  	unsigned long start;
>  	unsigned long end;
>  	unsigned flags;
> +	enum mmu_notifier_event event;
>  };
>  
>  struct mmu_notifier_ops {
> @@ -363,10 +365,12 @@ static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
>  					   unsigned long start,
>  					   unsigned long end)
>  {
> +	range->vma = vma;
> +	range->event = event;
>  	range->mm = mm;
>  	range->start = start;
>  	range->end = end;
> -	range->flags = 0;
> +	range->flags = flags;

Which of the "user patch sets" uses the new flags?

I'm not seeing that user yet.  In general I don't see anything wrong with the
series and I like the idea of telling drivers why the invalidate has fired.

But is the flags a future feature?

For the series:

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

Ira

>  }
>  
>  #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
> -- 
> 2.20.1
> 

