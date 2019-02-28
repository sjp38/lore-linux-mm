Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93244C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:40:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B1222171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:40:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B1222171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9E3F8E0003; Thu, 28 Feb 2019 04:40:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4DAC8E0001; Thu, 28 Feb 2019 04:40:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3DA68E0003; Thu, 28 Feb 2019 04:40:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 689E98E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:40:14 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e46so8346402ede.9
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:40:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=jxwFn1zU5Kr4na+/zAvhiiR1F7Fe/YvjSBUQMDXSE1c=;
        b=SdJ6HKfR6Je+kLXXakTxMgD7G+FJ4kfm4LpYwzu6/D35CPGOCD2Mo62elXfF8cK9CX
         5a24hZVSOxoPKjfjASvmbkvdyiRQAo0ckw3+fiM4uz56RILBwI73dmHX/HNg6ETIgAZx
         YLMBZh4Dg+bmK5tf091abggAci4k1vEhTq+EJSXmzAUOVfQzj7iFsGPXvHawYBN5aE3W
         UDUX/wVQ9SH55rqJs8rj9mG1TAV0Vv6eE7UlRvl4DwH6uLk2icPnb+qhoa+66rYCh/u4
         PIiRXjF767lfltjqRUgjLRKuwA9T/RgxGx/aTM7wRJplScuqejEncQ9b/7NzNzeH8YfK
         j7YQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAubnnP0X7MWz3uD/sZwEVMbK9lOp93xm6S9TTecVFieyVMs0A+Dh
	yF5Wtgg9xmRdjEHbSSJYPmt2Nn37paw+S4XvYRBtMLuiskVVun8EOmYqM37N/qeOFLv10VfAz5p
	Aohhi39OFAVjA7o1Q7xvVm1+M3m2qsuJryQPjKx7VX8pC1xaRFqGE0NJ98vsuPhRqdw==
X-Received: by 2002:a50:aef1:: with SMTP id f46mr6006777edd.184.1551346813957;
        Thu, 28 Feb 2019 01:40:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbuWx15zhhzMjkuynKYw6KzDBKwtVSAFjl7W50fHvk7vHiGWRZPYYA3OSbrcH2gdoZfewK4
X-Received: by 2002:a50:aef1:: with SMTP id f46mr6006731edd.184.1551346813119;
        Thu, 28 Feb 2019 01:40:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551346813; cv=none;
        d=google.com; s=arc-20160816;
        b=elypqe50IhtA40p0MpEN++TLe7f43dVygARJ8eeMb7tnT3o8Gan4mT3qLXQj3j7dfW
         WviFwW8mf8AUFhaR0JzDaB6hH+PH9Psq1VpCTC0/OBYf8ITxJowJTAvxlvDJkfMvO/K1
         MU0iu6A0c0rdVkBOdZx3e7KWt34YwR1zJ6DInHZwNmbAtHg/FyiF8KFsllcGqOP+fyK0
         anAp7rvn5+ZSaaofcPdT4pkawiWxXIVl9vh/1si7wwJLfBif3ksfbSMVCrHmtOZtXtDJ
         FHhBq5nCju+cD/TlZUzlzwPyvWm+uzTU2kEyJf02bVQXWCJvGrb4Mpjh9txOMVaANGE6
         A79A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=jxwFn1zU5Kr4na+/zAvhiiR1F7Fe/YvjSBUQMDXSE1c=;
        b=KjMKzTJFxDr+E69/z2JF/Z+LjaLCz6AwsGzUFmInq9B5T3WQbLs4IFjaWjRgJNVnkk
         LC/+v2Nlwv//XEIqiaq2tLIZFzg5AN/dPUqcTVKuvhqnS9Ug2kqUXmafbUEpQHnEGPXf
         kFYWvv3kdHB4LJRRKN0FtQLYEJxrXypGEAiMNCj9VqvlidXESgEUsX6reBGZEFWXjGFK
         AHghinuCXhIgrPb9+G0J0xwLWIsyMN8IY8xAcRKiFp3k6a1lmE40uYVWop9Wz7R0/dgt
         Zuy/cFGpFBEId81jg7qtAZOpQJDSdK4NKlw7JkmG3K45vTo41QraYIzxjnVq4prAVGLT
         ++LQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 41si161333edr.20.2019.02.28.01.40.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 01:40:13 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1AC1DAD36;
	Thu, 28 Feb 2019 09:40:12 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 764DB1E4263; Thu, 28 Feb 2019 10:40:11 +0100 (CET)
Date: Thu, 28 Feb 2019 10:40:11 +0100
From: Jan Kara <jack@suse.cz>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Jan Kara <jack@suse.cz>, mpe@ellerman.id.au,
	Ross Zwisler <zwisler@kernel.org>,
	Oliver O'Halloran <oohall@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
Message-ID: <20190228094011.GB22210@quack2.suse.cz>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-02-19 14:05:22, Aneesh Kumar K.V wrote:
> Add a flag to indicate the ability to do huge page dax mapping. On architecture
> like ppc64, the hypervisor can disable huge page support in the guest. In
> such a case, we should not enable huge page dax mapping. This patch adds
> a flag which the architecture code will update to indicate huge page
> dax mapping support.
> 
> Architectures mostly do transparent_hugepage_flag = 0; if they can't
> do hugepages. That also takes care of disabling dax hugepage mapping
> with this change.
> 
> Without this patch we get the below error with kvm on ppc64.
> 
> [  118.849975] lpar: Failed hash pte insert with error -4
> 
> NOTE: The patch also use
> 
> echo never > /sys/kernel/mm/transparent_hugepage/enabled
> to disable dax huge page mapping.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

Added Dan to CC for opinion. I kind of fail to see why you don't use
TRANSPARENT_HUGEPAGE_FLAG for this. I know that technically DAX huge pages
and normal THPs are different things but so far we've tried to avoid making
that distinction visible to userspace.

								Honza
> ---
> TODO:
> * Add Fixes: tag
> 
>  include/linux/huge_mm.h | 4 +++-
>  mm/huge_memory.c        | 4 ++++
>  2 files changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 381e872bfde0..01ad5258545e 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -53,6 +53,7 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  			pud_t *pud, pfn_t pfn, bool write);
>  enum transparent_hugepage_flag {
>  	TRANSPARENT_HUGEPAGE_FLAG,
> +	TRANSPARENT_HUGEPAGE_DAX_FLAG,
>  	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>  	TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
>  	TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
> @@ -111,7 +112,8 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
>  	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
>  		return true;
>  
> -	if (vma_is_dax(vma))
> +	if (vma_is_dax(vma) &&
> +	    (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_DAX_FLAG)))
>  		return true;
>  
>  	if (transparent_hugepage_flags &
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index faf357eaf0ce..43d742fe0341 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -53,6 +53,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE_MADVISE
>  	(1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)|
>  #endif
> +	(1 << TRANSPARENT_HUGEPAGE_DAX_FLAG) |
>  	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG)|
>  	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
>  	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
> @@ -475,6 +476,8 @@ static int __init setup_transparent_hugepage(char *str)
>  			  &transparent_hugepage_flags);
>  		clear_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>  			  &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DAX_FLAG,
> +			  &transparent_hugepage_flags);
>  		ret = 1;
>  	}
>  out:
> @@ -753,6 +756,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  	spinlock_t *ptl;
>  
>  	ptl = pmd_lock(mm, pmd);
> +	/* should we check for none here again? */
>  	entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
>  	if (pfn_t_devmap(pfn))
>  		entry = pmd_mkdevmap(entry);
> -- 
> 2.20.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

