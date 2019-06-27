Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64755C5B577
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 23:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E95620B7C
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 23:38:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E95620B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0D6E6B0005; Thu, 27 Jun 2019 19:38:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E3B18E0003; Thu, 27 Jun 2019 19:38:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D28B8E0002; Thu, 27 Jun 2019 19:38:15 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3EC6B0005
	for <Linux-mm@kvack.org>; Thu, 27 Jun 2019 19:38:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so2554801pfi.6
        for <Linux-mm@kvack.org>; Thu, 27 Jun 2019 16:38:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6ub5rS7DrtMMA8Bt1+uOqsBRl8P5SiRiczVvmt2TfKE=;
        b=gJyQH8UfN1XKtRUVUnDu8cPujk66vKK0dZgUymA4hmK+iL156/pVkkJ3OLXUZlgXKM
         l7l2wrn+pd4+Yyoh0oNEaKO5INVX+OZkmvlQ5gYZEJyVSHOs20EddiWwYSa3j9amiFNI
         awcTNlSets6usmsbZyvJVN4Rey4EbVklhVtT05PN+0sSuoT/LpoeJnO0awMtxZTKLv2t
         TE52RrdYTBDs3ENagqVbzJT7W189AG+10qIrdeveojXtAMJdQvDIaaHrm3vfuRM3gr7a
         UM26sOqGhXG723pF80aSOIhicZpakC4WUN51MFc/Ld7ntYVQ9NCq39N+VBHYzuS0gBYs
         sKdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVKbYBmNMpGskkyIF1M6ek99cDS1aDnsP/0lWDUp4DbMh4Elcjh
	MubQ8r6DjbZxMDyg+fleusTTf0Mj+6vLBINe8lvIZ6fmlW54wneG3R0J0oZVbxCscmBdR203tmB
	CUOzlk5ML/VjuMNB+ngjy06w06opTVlMtf5jh4SxIApHID34dAhMV3wmWRpntkZCFRg==
X-Received: by 2002:a17:90a:710c:: with SMTP id h12mr4937017pjk.36.1561678694932;
        Thu, 27 Jun 2019 16:38:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx//aGuIrzdgBYnqyKyo6YicVCoKr2mUyi613lvpnxM7OypZ99Ma0LP9tbjR01RHHRcg9my
X-Received: by 2002:a17:90a:710c:: with SMTP id h12mr4936966pjk.36.1561678694199;
        Thu, 27 Jun 2019 16:38:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561678694; cv=none;
        d=google.com; s=arc-20160816;
        b=Yjn4McOxIdWU4E2Q6E2P2HV/LJqo25T/sCZWkSOxY5UCATMsXNLI/zQO9wnvQnyngg
         yzG8di65jU31SUFcZ2S6dXMTTe2oIahwvyoHNFIVZAz6L0ldGuaNKcYUU43izNjjQIoB
         xMiSlbJgwUIq4Qr4ahgHVr3G0q1flXmtOlJkphqZ+sVlrcefnpVMkn4zNOPxgY/ibwep
         an9FdVwnmOOtN4c3l5zYG5jBVhbRsXIXmLy9+A+bgIl1/7W+ldwZWx9yI2ixsekHSgAH
         SIN6SpLe0ixE5R/+zLg1W8EBBfoZa/9C42N9qub4W6sIA6XkxjNzyGClkagFjv4zEBK3
         NE4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6ub5rS7DrtMMA8Bt1+uOqsBRl8P5SiRiczVvmt2TfKE=;
        b=cm4BNRku4oMwFA7XnSvMVb+41lt/7DzVavqSPXf2YGcxNc2sT6qc/EdUaKJi3udivn
         60gSXSYLxUR21fugUZABXCQ4t84hKnPyJFag4ns9523ljDTxJ8WrbQ+YQLGP9cbFiOHy
         2ANNHCTEz7ICsHTudDLEbNUZDcOATKcNVimHwcbdfaMw/vAViJ7XfaKVglYjZqmBHpnX
         zA8oDtLlIsGQM22HceFueMOvI4mT+eJlOArdSUUQfcrNTe0DKh4YB6XZth7pupAPBR30
         NVwpE4Fi17+dOCWKS08t5Z566vmN60ypf4h4BmEleImCIYB6NibZU5wIoLrDen+aqrRQ
         NV2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l21si490735pgb.409.2019.06.27.16.38.13
        for <Linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 16:38:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Jun 2019 16:38:13 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,425,1557212400"; 
   d="scan'208";a="167595836"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 27 Jun 2019 16:38:11 -0700
Date: Thu, 27 Jun 2019 16:38:11 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Christoph Hellwig <hch@lst.de>, Keith Busch <keith.busch@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Linux-kernel@vger.kernel.org
Subject: Re: [PATCHv5] mm/gup: speed up check_and_migrate_cma_pages() on huge
 page
Message-ID: <20190627233805.GA8695@iweiny-DESK2.sc.intel.com>
References: <1561612545-28997-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561612545-28997-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 01:15:45PM +0800, Pingfan Liu wrote:
> Both hugetlb and thp locate on the same migration type of pageblock, since
> they are allocated from a free_list[]. Based on this fact, it is enough to
> check on a single subpage to decide the migration type of the whole huge
> page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
> similar on other archs.
> 
> Furthermore, when executing isolate_huge_page(), it avoid taking global
> hugetlb_lock many times, and meanless remove/add to the local link list
> cma_page_list.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Keith Busch <keith.busch@intel.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Linux-kernel@vger.kernel.org
> ---
> v3 -> v4: fix C language precedence issue
> v4 -> v5: drop the check PageCompound() and improve notes
>  mm/gup.c | 23 +++++++++++++++--------
>  1 file changed, 15 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097..1deaad2 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1336,25 +1336,30 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  					struct vm_area_struct **vmas,
>  					unsigned int gup_flags)
>  {
> -	long i;
> +	long i, step;
>  	bool drain_allow = true;
>  	bool migrate_allow = true;
>  	LIST_HEAD(cma_page_list);
>  
>  check_again:
> -	for (i = 0; i < nr_pages; i++) {
> +	for (i = 0; i < nr_pages;) {
> +
> +		struct page *head = compound_head(pages[i]);
> +
> +		/*
> +		 * gup may start from a tail page. Advance step by the left
> +		 * part.
> +		 */
> +		step = (1 << compound_order(head)) - (pages[i] - head);
>  		/*
>  		 * If we get a page from the CMA zone, since we are going to
>  		 * be pinning these entries, we might as well move them out
>  		 * of the CMA zone if possible.
>  		 */
> -		if (is_migrate_cma_page(pages[i])) {
> -
> -			struct page *head = compound_head(pages[i]);
> -
> -			if (PageHuge(head)) {
> +		if (is_migrate_cma_page(head)) {
> +			if (PageHuge(head))
>  				isolate_huge_page(head, &cma_page_list);
> -			} else {
> +			else {
>  				if (!PageLRU(head) && drain_allow) {
>  					lru_add_drain_all();
>  					drain_allow = false;
> @@ -1369,6 +1374,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  				}
>  			}
>  		}
> +
> +		i += step;
>  	}
>  
>  	if (!list_empty(&cma_page_list)) {
> -- 
> 2.7.5
> 

