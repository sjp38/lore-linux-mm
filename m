Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F0FBC28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:01:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63A3927B2A
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:01:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63A3927B2A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0342C6B000A; Mon,  3 Jun 2019 11:01:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F26C36B000C; Mon,  3 Jun 2019 11:01:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCF956B000D; Mon,  3 Jun 2019 11:01:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5C4E6B000A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 11:01:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x5so13809747pfi.5
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 08:01:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MV40JVrvD4ESIMZwQyW7uslN6VQeE5qInMFxmpdTVGs=;
        b=l6m5IYAS98Jp3KPMVdkRpZNEThNUwGTiFd9e0CLN5KozrnxngHZjmkffY+A1mdGJRm
         EYByZ2MltazRYTufFHoe7NbcoUcSlHtb7ar/9UnjgzbEHqZ5OyI/3HXPvb7sXC/cwG8X
         Ia2rlr/o9QDloGeY8663N1NotUWVRLQKRqWH8yNMNGctvv98ayQDGj+d1klDYsTcGS+v
         4mBBt1o5Q+JwpA0HgzdnaGls7c4l3vATkw4q/SPcmOcPPrYGKHLz2EpErk2PEflfeOk2
         crGFhRkBuZ4CRhRDNwtBbai0wDhYj4navr1cgQViODEGS9tZN1an0vlPWpOV4kuXFX0K
         ISgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV+BVljI1xPx2lnaZTOy8nadh9C7Dh6FZWeJIKkbBM3PmfsjeIt
	/jgzhCt3hQrXX4UcU5WVk8E7g6RXwBECvFXBKG0ld7tBukaI10y1Shlyu7WGexVFqGp4x+pjaFZ
	hTLhcH+55Q9TiH2+7Ze5KuJaCqpFDYU/+qkGNo8hRsNv2We7eXqo6bUrZR2MS4QgI5w==
X-Received: by 2002:a17:90a:19d:: with SMTP id 29mr2616997pjc.71.1559574072349;
        Mon, 03 Jun 2019 08:01:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxudEfGdcsQs+nKzVZpjh7woXW8qBqXOMDNTOA9PtzZa8EwKHVerMaUsDpjelK20EL/grhX
X-Received: by 2002:a17:90a:19d:: with SMTP id 29mr2616903pjc.71.1559574071636;
        Mon, 03 Jun 2019 08:01:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559574071; cv=none;
        d=google.com; s=arc-20160816;
        b=w4cDeW1DyYIg9nhiLespA94ruTQFuluKKJ4I/S4UPYGsL/qGEk0PZvYUF5eigOlFME
         tsm6hclV6hOfB9OutqhkbA7YLx+uiXF4BAv12iREBZ4K1U3Qm49wcGXvBhzsNbkwMcJx
         VgczlVdBbh+ZP5AaJ9Y0r7K4zoEeaba0nKV2yrkCdDjGkmvA3ET7AvDSn1rfScJ3J66N
         3SmWAW2ssgaDyIkm5iKx12avPGggsnfUXnpDqtYIOo5aI7tB9k2vfnciF6VA/R2gtXHz
         fJ7HtI+XztnlNV/7LqhExY1ud5JKa+YhzAKS1ZeISJFwFk3eDU/ftXtiMgRsygeWGsN6
         BQ0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MV40JVrvD4ESIMZwQyW7uslN6VQeE5qInMFxmpdTVGs=;
        b=WvDU7PqCntKX2ZVAf1XYuHWjDa8zTPjZjopSjrWwKG1zO3r+uejpXuLMPSBvDJTn3X
         cPSzdPTdqaCY2RWchTMBIwumvgmQ1JHxeyyBVERW7dzB1pr0CV4UsdKuSHLxb8/SNMnK
         1iAb+adRXQuFQ3HtCwJcF44oTtYRjX24yDQvCLqWw9Q41xnKc+HR+KvtFvSFp/fdviXz
         /ee6tZc5qrUi1x6cYG6YSANsDrsXQi2v24nFF7+V0Ai6Eg9zndw22Fo3nrgH3WbVD7CC
         JNR+MobZhMU8pfLaaMCPdzaVwjUDpe9Q6Wm1YP/8gKhso/2Yx1DgH1pquRxtJy5Ty/4w
         gXsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id x21si12973315pln.204.2019.06.03.08.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 08:01:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Jun 2019 08:01:11 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga004.jf.intel.com with ESMTP; 03 Jun 2019 08:01:10 -0700
Date: Mon, 3 Jun 2019 08:02:18 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv2 2/2] mm/gup: rename nr as nr_pinned in
 get_user_pages_fast()
Message-ID: <20190603150218.GB26623@iweiny-DESK2.sc.intel.com>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
 <1559543653-13185-2-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559543653-13185-2-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 02:34:13PM +0800, Pingfan Liu wrote:
> To better reflect the held state of pages and make code self-explaining,
> rename nr as nr_pinned.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Keith Busch <keith.busch@intel.com>
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/gup.c | 22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 6fe2feb..106ab22 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2239,7 +2239,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  			unsigned int gup_flags, struct page **pages)
>  {
>  	unsigned long addr, len, end;
> -	int nr = 0, ret = 0;
> +	int nr_pinned = 0, ret = 0;
>  
>  	start &= PAGE_MASK;
>  	addr = start;
> @@ -2254,26 +2254,26 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  
>  	if (gup_fast_permitted(start, nr_pages)) {
>  		local_irq_disable();
> -		gup_pgd_range(addr, end, gup_flags, pages, &nr);
> +		gup_pgd_range(addr, end, gup_flags, pages, &nr_pinned);
>  		local_irq_enable();
> -		ret = nr;
> +		ret = nr_pinned;
>  	}
>  
> -	nr = reject_cma_pages(nr, gup_flags, pages);
> -	if (nr < nr_pages) {
> +	nr_pinned = reject_cma_pages(nr_pinned, gup_flags, pages);
> +	if (nr_pinned < nr_pages) {
>  		/* Try to get the remaining pages with get_user_pages */
> -		start += nr << PAGE_SHIFT;
> -		pages += nr;
> +		start += nr_pinned << PAGE_SHIFT;
> +		pages += nr_pinned;
>  
> -		ret = __gup_longterm_unlocked(start, nr_pages - nr,
> +		ret = __gup_longterm_unlocked(start, nr_pages - nr_pinned,
>  					      gup_flags, pages);
>  
>  		/* Have to be a bit careful with return values */
> -		if (nr > 0) {
> +		if (nr_pinned > 0) {
>  			if (ret < 0)
> -				ret = nr;
> +				ret = nr_pinned;
>  			else
> -				ret += nr;
> +				ret += nr_pinned;
>  		}
>  	}
>  
> -- 
> 2.7.5
> 

