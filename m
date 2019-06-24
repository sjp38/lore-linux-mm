Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40A95C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:43:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E05572083D
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:43:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E05572083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FBFE6B0003; Mon, 24 Jun 2019 00:43:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AD8D8E0002; Mon, 24 Jun 2019 00:43:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 175E58E0001; Mon, 24 Jun 2019 00:43:09 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D71D86B0003
	for <Linux-mm@kvack.org>; Mon, 24 Jun 2019 00:43:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i27so8774973pfk.12
        for <Linux-mm@kvack.org>; Sun, 23 Jun 2019 21:43:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jzKNAu5h1WzG7/2PP8JC50O0fd77m4pnz3+PT5fMQiw=;
        b=mpWlPbHIUgCurtyi7kYbGUe15ZxHd83/j++W+5PDcAfoEYKUwIYMpwssJfM6NavSGQ
         etk404e5Vy5k8VlRXN/QDwNdwgUhqkgtpk3CCnu6SsB9BCXRYj/GOon3EI58LopJppiz
         5Z4+jCYo5xAm87Fmh+QsaN9yyYvTvqsWUFfmIRdGFQQDlAVUT7vsl+5+R0TMDuXh1Wwv
         SX32nb83zCMabwCC3UDkni4AtL6flTYZ7bBKPuRKfwhmAMuli5e5wpG7HnEuyeS6+Pei
         yeZHwel0NZ+C6ZR5f3gliDZPrUSD/y8d1dRl0NNO1q/9RgT0CpGuBsyY+pSsavNRMSM0
         gPZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU2E+W+jbyhpeiTwcB/2u7oZ9etStny9wmaj27LPYOLYpRPZUSo
	LYE1ntGmjM+hLPa51qgq4JFLvkKWnJKiBDbSk7t+0TXMFMO190/6b8KwMCj1c3yAnZaAhswTlUE
	Xa+U43JtdKq4vatjYHxGL4baw1OivQsMhe2+zO84Dg5DMqUAN4+EDy3QBwU68sq/dzQ==
X-Received: by 2002:a63:dc56:: with SMTP id f22mr31422297pgj.305.1561351388346;
        Sun, 23 Jun 2019 21:43:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGLHb+vJt8qy02BGj1UnWlCG1p5kwLhI7o9aMEg20og6fVr2B9pOVzdeSq+rByTKktoIXL
X-Received: by 2002:a63:dc56:: with SMTP id f22mr31422253pgj.305.1561351387492;
        Sun, 23 Jun 2019 21:43:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561351387; cv=none;
        d=google.com; s=arc-20160816;
        b=q8CK7e2ph3LWMKbnLMDh+wIIQmqHqH3SgxuqiSO758wCPt6xVO62mm2bjcFHyhfJqB
         0ZlcVVMhjmMXgO9X4MslwpJH0P4yeBetdAYpSogVsj6idzyAPMF1gPBWZFWi3xcSUYOC
         q2M4HIMEgDsqXOMFOU9K+4MG1OZMatvJmJoEdJFlO9hc63kuJ4lAiLKEBFYP4d7+/FCf
         4te43nRr5R41aiXchGC0VI3bGTd2Bnc0hsuxGJtaPFXMvccWHJPgqkuHIfYAfrIcDsAO
         7gkNFMVG+EKnY6svWdTlrIMbEmFtDc5bV3KzDe9WEQ9w1DTA1ko7iytQ2gkXydAcWv7/
         jXog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jzKNAu5h1WzG7/2PP8JC50O0fd77m4pnz3+PT5fMQiw=;
        b=cWJtigsc48oA7RxNO9Nwsvwjh0Vk/g8SmwuH/dj6DlqmU9S+9tM7QLNCPGIar3T4Pf
         7ZvGGj4vYRIWvnflQtUHJwpdaRujZgCi8DTYYCQiOjhnK9dEyZYeE1Ie9P5lu3rOJ6t7
         BCdBLNqSKbfavqG+rTPhW31xkyU1tpyZ2aPQikjHTSdjp0gX9Y/yg1HjmVC8G2J1pVWt
         OBHa5U1rlqjAxqsp3JXBVHnnjxZwFP1vPHY5UNV3v26EQlxM4ER4d7+eyBAjbfZHGHkH
         nIVzG6lxLGAubiFcKVdTYpBteRqqRs2y+mVPVa4Ba2gU77Xq9ceFfSTBIHrKlqS+Kl+D
         PwyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r4si8717347pgp.249.2019.06.23.21.43.07
        for <Linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 21:43:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jun 2019 21:43:06 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,411,1557212400"; 
   d="scan'208";a="312585521"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga004.jf.intel.com with ESMTP; 23 Jun 2019 21:43:06 -0700
Date: Sun, 23 Jun 2019 21:43:06 -0700
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
Subject: Re: [PATCHv2] mm/gup: speed up check_and_migrate_cma_pages() on huge
 page
Message-ID: <20190624044305.GA30102@iweiny-DESK2.sc.intel.com>
References: <1561349561-8302-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561349561-8302-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 12:12:41PM +0800, Pingfan Liu wrote:
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
>  mm/gup.c | 19 ++++++++++++-------
>  1 file changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097..544f5de 100644
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
> +			step = compound_order(head) - (pages[i] - head);

Sorry if I missed this last time.  compound_order() is not correct here.

Ira

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

