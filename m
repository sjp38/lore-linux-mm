Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFA2BC28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:59:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B494627B3C
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B494627B3C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53D036B000A; Mon,  3 Jun 2019 10:59:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EDEC6B000C; Mon,  3 Jun 2019 10:59:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DCCA6B000D; Mon,  3 Jun 2019 10:59:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0839B6B000A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:59:02 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so562943pfv.18
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:59:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=H+ENw6jrAqiv5XC0bufM+Z1ad7r4ORDIUJsEgu2DM9I=;
        b=jbI1NiYVwbaLfI3LxEHeQK77ELlne2O9UCk/Tsn8Y3TxyIwHhcE7UYkZYn1VXjsjPg
         IGGC3aFN71xxNcqjzUzThwJtZt/TmMM458pyQnfO2cjJA95NkCYf3/vA6sPfHb4Vwgm+
         Mw6aEgiuIFAEuSi0ox/64FIjuXZa7nrYgh3b61cUq+7x5dpYWMiUH7FM01IQ6rzU6Bsd
         PeNoKJ4OL7w/9wkzz6Mne+twXXoS5/Y5tjJj2RKgt0lMVxsNJ88aUqZtwo/nfR8l9rzX
         j9H5Fr7qsluDQm0all2qM5EUkNdWHbsZVYn5yUjHSmhRlnE3ksfED8vd8Y/4N8cG3vBL
         Hf4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUkJcOtZfQtxAc1yZWAyQhjSg9f/C5ryw8LPOr1T7zPqKqBbpdA
	WC3HLBO5kz3tzyKEpvcCaDf109g5Xi2pox0r2Y6IvcTqmLmei7ZAJmTYOKl2+qOhzm64zxeHVmU
	5whN/bC+wgogMqD56zVFSIzbZ1WQx3BPDsSxoQlGxMd9Ctw+esHsCqMOgOSaBpEDSng==
X-Received: by 2002:a17:902:b195:: with SMTP id s21mr31118184plr.16.1559573941603;
        Mon, 03 Jun 2019 07:59:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVqJvbrIjbV26NsajfR73J8OQ18p7D9tvNuuciutih+evSuudVRx0U7hqtektU2IVX4b6l
X-Received: by 2002:a17:902:b195:: with SMTP id s21mr31118105plr.16.1559573940825;
        Mon, 03 Jun 2019 07:59:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559573940; cv=none;
        d=google.com; s=arc-20160816;
        b=SyN+rfvkH4MmqWmKa7K/DaIXEeRS5KZqqdZXPTjQJCWnUIYBE7ozvk4F9os1WCni+w
         m1gd1hBX+ZEo2KUYPIO7QKLUE6Ul3vm1MuJ6fjqC/y9u7FP2I3JmCH1ipa5grIuALtHp
         BXFPW8EsYZ5I8skGiAn2UHu7iiaVBxU4GIDVD/EChrUdLHbhF/E7yibeelMG4/A6J4cw
         W7dRYEhiGJrGV/PIjeC1xBGZJrcpq4Z97yFi7TJdH6+Tzv+5I3fHcexrcxBXXNLYf4we
         LfwxmrsIVsWV//28zGTGPLrYY8ZeGgs3UJlbnDhpALX+SuhBtuMCRHZXPMcwWhl0VDXY
         YRCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=H+ENw6jrAqiv5XC0bufM+Z1ad7r4ORDIUJsEgu2DM9I=;
        b=JhX2h1YOYYWHw2eI8UNZfN95JpyhFNpd6ARzeqCPkcGQ897qHEvxXtUdjKKK3j4fbh
         DJPUUa9g31vn8iD5xyFqW3QXzRyUiG3gFO6jUes7RsP/W1+ZKAH0ujoRu5REE+1jx4Ln
         8TfSu1yNI2mePBTQ/IVSobXi03K3PIGkHYeX5ADRqvnbX/y9vjk7+BTZHrkJnwqpJq8X
         kQVSltBdk7kDlY/QtNkGfl4Y5/+iMJ2XxGrRtSbANe4wivMEZ0FQs1wO2q+Mo0/jTsHD
         3CZZESbOZqc6t9PM+WzW9gi8Rp0RLxXxyFKu7C5xKDq5aydXs+vmnaJw74yAP9l9TSO8
         IniQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d10si18129081plr.307.2019.06.03.07.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 07:59:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Jun 2019 07:59:00 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 03 Jun 2019 07:58:59 -0700
Date: Mon, 3 Jun 2019 08:00:08 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190603150007.GA26623@iweiny-DESK2.sc.intel.com>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 02:34:12PM +0800, Pingfan Liu wrote:
> As for FOLL_LONGTERM, it is checked in the slow path
> __gup_longterm_unlocked(). But it is not checked in the fast path, which
> means a possible leak of CMA page to longterm pinned requirement through
> this crack.
> 
> Place a check in the fast path.
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
>  mm/gup.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index f173fcb..6fe2feb 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2196,6 +2196,29 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
>  	return ret;
>  }
>  
> +#if defined(CONFIG_CMA)
> +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
> +	struct page **pages)
> +{
> +	if (unlikely(gup_flags & FOLL_LONGTERM)) {
> +		int i = 0;
> +
> +		for (i = 0; i < nr_pinned; i++)
> +			if (is_migrate_cma_page(pages[i])) {
> +				put_user_pages(pages + i, nr_pinned - i);
> +				return i;
> +			}
> +	}
> +	return nr_pinned;
> +}
> +#else
> +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
> +	struct page **pages)
> +{
> +	return nr_pinned;
> +}
> +#endif
> +
>  /**
>   * get_user_pages_fast() - pin user pages in memory
>   * @start:	starting user address
> @@ -2236,6 +2259,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  		ret = nr;
>  	}
>  
> +	nr = reject_cma_pages(nr, gup_flags, pages);
>  	if (nr < nr_pages) {
>  		/* Try to get the remaining pages with get_user_pages */
>  		start += nr << PAGE_SHIFT;
> -- 
> 2.7.5
> 

