Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3EA1C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:55:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96E6320B1F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:55:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96E6320B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2474E6B0005; Wed, 26 Jun 2019 14:55:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F6898E0003; Wed, 26 Jun 2019 14:55:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E5868E0002; Wed, 26 Jun 2019 14:55:16 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9C206B0005
	for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 14:55:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h15so2366204pfn.3
        for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 11:55:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZtTRraAMt7m/RqDJmMDqPjRJFSfo1+ML/qP3YsiTr1I=;
        b=SAKsCNsLhllvuu8uu4BcTxOpNobjlGB3+RssqoedS/Yhy1J3fGR2FTP8HgrPme40d3
         SIhpE7/MFWT6CQznxuOIM2k2A5JJpm6FwSbM4A8p+2DcT9oxn8qvdCSahzPLN1Xnlnad
         N0CsYv/QvjZbXhsmcMOTSeeFBCj3uFohCjERYsKxgpmiHFpe98IGS1Xy7rD3O/Ha6SEI
         UR7QbLHf5bjqMkqNpzzjzmPE049sI+LX6suLx1Sh3NFpdiUbIXvGLdcosy2xpiUQ5Pfm
         8CutkSXq+3dQs58T+PAFAwnn3D2kyH/6zc+IY9Ip3UtTS/CApJVx9Jh1Wdod9BiGVQk2
         i7iA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXFBaMbuoGZ+qGK8hrZ++lQdCqBKB1S8ZT1fNWg8OCXaFoIgiG/
	rUgwh4g5oLOUNKHFxm6gtuwhrzdaY9YvimaIUF0mv/vBLtyXfU6+AcVM4EpqUvmU5YaGC0Dqihv
	eV3LdGFB+htKu7Rlk0HFX2el8K2dqhyA38SINxhPK6J3SfTAltaJNYepOjAiBmdEc3A==
X-Received: by 2002:a17:902:ea:: with SMTP id a97mr7154055pla.182.1561575315419;
        Wed, 26 Jun 2019 11:55:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTe90nLatPuzscCzpiWk7xyiPiqdgaeOEljHeAZpdGH7ImJRp53vread3zUlnaH//ejQq3
X-Received: by 2002:a17:902:ea:: with SMTP id a97mr7153994pla.182.1561575314760;
        Wed, 26 Jun 2019 11:55:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561575314; cv=none;
        d=google.com; s=arc-20160816;
        b=Zf0W1etANMjKz1BghzlaXjeNlmCxiPbP+N+Y65BUukXySdzYllVg4tnStLhiJhlxq1
         4DeizY+Z3j7WwkGNS/K6NuYedxC3aj1GEqhHTnm37IQnwrLBUR28EAArHbZKql22dxTF
         7uPJBFzjDWQ6pksR+ZddwZyHMkFIg6McfOmEaSlh/rTA52bOrxu1GlkLmQLMLuin6XzF
         DPuharGDJbbfVvRZjLRzNePHLneknIm9pJViSPUuXZpvbVdViPFGygD4xSHcP8HNME1k
         bOQQ0cLlgXsImtdnBVld/ClRJa5ecvUnNZ9gCn5qja0KU9S5S5zmh/IqGJ0kfBsIqM4L
         if4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZtTRraAMt7m/RqDJmMDqPjRJFSfo1+ML/qP3YsiTr1I=;
        b=fMTgPjAkByBD6K7QoDN0jUz/g/WgVGnoJmL1Tyd41D3+QvTXraGflUEbCD8Flsbsuf
         VSsrmwr6yF+KuOnSCmGyTIYLD8ytyDSLn3pApWGlWEXbe1NzVRBF0aIsvfuDvw1hl6xi
         C1OJnMqvBYcmLZFdJDMS8PKTe44oreEW4sa/5z+rrg1PD9tbW04fYhT799up3GsXXndp
         b5qNTB8yGs4OtJYtmrKvNZmwECwUHQk2wHhyk6E//VBFfCN3T7dUypaNdDvR9UPtbxKZ
         lMJRrzVzXsf1hS162S9gMyaTMTTds81NTGKy4qUNxKRNXWYfsk9ABmUWfAvIbuwqao5w
         VVQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v15si18715793pfm.238.2019.06.26.11.55.14
        for <Linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 11:55:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 11:55:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,420,1557212400"; 
   d="scan'208";a="170142644"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 26 Jun 2019 11:55:12 -0700
Date: Wed, 26 Jun 2019 11:55:12 -0700
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
Subject: Re: [PATCHv4] mm/gup: speed up check_and_migrate_cma_pages() on huge
 page
Message-ID: <20190626185512.GD4605@iweiny-DESK2.sc.intel.com>
References: <1561554600-5274-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561554600-5274-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 09:10:00PM +0800, Pingfan Liu wrote:
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
> 
>  mm/gup.c | 19 ++++++++++++-------
>  1 file changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097..ffca55b 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1342,19 +1342,22 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  	LIST_HEAD(cma_page_list);
>  
>  check_again:
> -	for (i = 0; i < nr_pages; i++) {
> +	for (i = 0; i < nr_pages;) {
> +
> +		struct page *head = compound_head(pages[i]);
> +		long step = 1;
> +
> +		if (PageCompound(head))
> +			step = (1 << compound_order(head)) - (pages[i] - head);
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
> @@ -1369,6 +1372,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
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

