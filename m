Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D77CC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 23:29:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF8B3217F5
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 23:29:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF8B3217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 693316B0003; Fri, 10 May 2019 19:29:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 644026B0005; Fri, 10 May 2019 19:29:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 559A86B0006; Fri, 10 May 2019 19:29:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C38D6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 19:29:30 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 17so5144838pfi.12
        for <linux-mm@kvack.org>; Fri, 10 May 2019 16:29:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oJri1sKWbB/M5UOff7RFRvbxSyh+RWxEUImL4v3+cYY=;
        b=fikW5HiHymTTbyBon6HmOSkAtxNw5WQA2J4vkYtOcd0PorB+GlWy1aq+sAa07HtLew
         AuxleH2FNcicYhRWrO+vnE3iWY9PgwrlekIdTX46hqkyj2SyZW0q9nDlETnOV4tXYkQk
         Gu868A+RD5vG3/5ZpaKeOr7rXzrN8cbSV/fWNbA7qLlN54Cs2MzZ1KXbNjMNwURy2QeR
         4JJasBVODqWUMOcntiFFJjp23GlHqcKtVIOiG4AMxjRajcMAecg3ckLsMllR4J93HZRF
         T59KSNRZkZIANC05i9KTlma04C4ILkTEeg+r/3M0tt20ZPkcYoQor0vwe1fINode7g4F
         TEJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXE2AkqvPjM3IEGqzgVhNgGhj8HWJwpoi+GXW1zoZfFTU0XgIu4
	jySbjKaRJhbdQISAFT3+WHJ6iddMAbs50KDsLEMje1SZTBibn5mQgGPrqqV13bdmWjt9+s5abw4
	oK40Oe325gv1pi+kv1uDSSxuF4lKpZa+3uy6KrCHQ4/tKCwhi0O0Ja7slWhVU0ejZJw==
X-Received: by 2002:aa7:8dc3:: with SMTP id j3mr17581092pfr.141.1557530969793;
        Fri, 10 May 2019 16:29:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9uI6nW6eOH9eMS1SuG0lkorey1r8oYzhRufHOB1xsJp4GQTKm57iSTS3coRbuLX4Qq+ta
X-Received: by 2002:aa7:8dc3:: with SMTP id j3mr17581054pfr.141.1557530969099;
        Fri, 10 May 2019 16:29:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557530969; cv=none;
        d=google.com; s=arc-20160816;
        b=KnkjCD7k1fmOboyfyMwUhr6lw/Z+sd9cY16Rvd7R4d7OzzrGEGp2+ZoCz4cLzE4Fpk
         LC7VtYiosXXG9Pi3kfLalsjeqrrmk7/CXEnFvei4iGZCNaCQfhp0k3DPJ6IfCYfvhQay
         rn9sqhcQ6JzBY+et/C/ag4EvuBVJiKlvD3qY54Q+UK1nLF/JO/m/gPRPqNQTRCsj34Kl
         RrUPeLSn44k12yPDtlSMvKqKZAdlKN5aaknFxsj5BcS3lSCx5nVM6CXe1Zy2fkc7k6TE
         1hnSPumT0fMS9yrb4sQxia+tMZqabky5jBVVVFpCwIMfaiapam/H0yPT43UMriAYZ88e
         AWfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oJri1sKWbB/M5UOff7RFRvbxSyh+RWxEUImL4v3+cYY=;
        b=Xnv55i/KJXNWefzKObCdykpTz1ETPQmaS25U66mu42DAEJcU0vE0jCtNxFSc2z8F6y
         64UNnPEytlLNqVJ5vjG3yWIN8ZkKwr7kzda+k8W8m2wy+JaoPdxYAGUjzZVcCBRFrB9Q
         YnlWk21+DmdkRQTQT7Dwts3rpwxov9X4LtxQIF1JIvKDPeN21LgcYzu5jfF1r0crbQK8
         C5e0H/Jc9+e+VvHdaSBSIxEpJ9ez5aXCxUL8UDuRD5VOCZ3HEfAHNJgHv1yABF9y7Rgx
         idNwxzJFb8LCdNgboQxh8lM4kJhEXi7Nq2m8HS0N/LZpjErTd/GQhEdIpOK9rFA26VcL
         8gJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r17si8626025pgv.128.2019.05.10.16.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 16:29:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 May 2019 16:29:28 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 10 May 2019 16:29:28 -0700
Date: Fri, 10 May 2019 16:30:04 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH v2 00/15] Remove 'order' argument from many mm functions
Message-ID: <20190510233004.GB14369@iweiny-DESK2.sc.intel.com>
References: <20190510135038.17129-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 06:50:23AM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> This is a little more serious attempt than v1, since nobody seems opposed
> to the concept of using GFP flags to pass the order around.  I've split
> it up a bit better, and I've reversed the arguments of __alloc_pages_node
> to match the order of the arguments to other functions in the same family.
> alloc_pages_node() needs the same treatment, but there's about 70 callers,
> so I'm going to skip it for now.
> 
> This is against current -mm.  I'm seeing a text saving of 482 bytes from
> a tinyconfig vmlinux (1003785 reduced to 1003303).  There are more
> savings to be had by combining together order and the gfp flags, for
> example in the scan_control data structure.
> 
> I think there are also cognitive savings to be had from eliminating
> some of the function variants which exist solely to take an 'order'.
> 
> Matthew Wilcox (Oracle) (15):

For the series:

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

>   mm: Remove gfp_flags argument from rmqueue_pcplist
>   mm: Pass order to __alloc_pages_nodemask in GFP flags
>   mm: Pass order to __alloc_pages in GFP flags
>   mm: Pass order to alloc_page_interleave in GFP flags
>   mm: Pass order to alloc_pages_current in GFP flags
>   mm: Pass order to alloc_pages_vma in GFP flags
>   mm: Pass order to __alloc_pages_node in GFP flags
>   mm: Pass order to __get_free_page in GFP flags
>   mm: Pass order to prep_new_page in GFP flags
>   mm: Pass order to rmqueue in GFP flags
>   mm: Pass order to get_page_from_freelist in GFP flags
>   mm: Pass order to __alloc_pages_cpuset_fallback in GFP flags
>   mm: Pass order to prepare_alloc_pages in GFP flags
>   mm: Pass order to try_to_free_pages in GFP flags
>   mm: Pass order to node_reclaim() in GFP flags
> 
>  arch/ia64/kernel/uncached.c       |  6 +-
>  arch/ia64/sn/pci/pci_dma.c        |  4 +-
>  arch/powerpc/platforms/cell/ras.c |  5 +-
>  arch/x86/events/intel/ds.c        |  4 +-
>  arch/x86/kvm/vmx/vmx.c            |  4 +-
>  drivers/misc/sgi-xp/xpc_uv.c      |  5 +-
>  include/linux/gfp.h               | 59 +++++++++++--------
>  include/linux/migrate.h           |  2 +-
>  include/linux/swap.h              |  2 +-
>  include/trace/events/vmscan.h     | 28 ++++-----
>  kernel/profile.c                  |  2 +-
>  mm/filemap.c                      |  2 +-
>  mm/gup.c                          |  4 +-
>  mm/hugetlb.c                      |  5 +-
>  mm/internal.h                     |  5 +-
>  mm/khugepaged.c                   |  2 +-
>  mm/mempolicy.c                    | 34 +++++------
>  mm/migrate.c                      |  9 ++-
>  mm/page_alloc.c                   | 98 +++++++++++++++----------------
>  mm/shmem.c                        |  5 +-
>  mm/slab.c                         |  3 +-
>  mm/slob.c                         |  2 +-
>  mm/slub.c                         |  2 +-
>  mm/vmscan.c                       | 26 ++++----
>  24 files changed, 157 insertions(+), 161 deletions(-)
> 
> -- 
> 2.20.1
> 

