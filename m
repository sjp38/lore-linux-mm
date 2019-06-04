Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DAAFC28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:54:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8AA023CBA
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:54:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8AA023CBA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 960886B0270; Tue,  4 Jun 2019 12:54:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EA376B0271; Tue,  4 Jun 2019 12:54:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78CB56B0272; Tue,  4 Jun 2019 12:54:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2FF6B0270
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:54:38 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f9so16580673pfn.6
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:54:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UdpBYgiDIWDyW9pK5bHCF7O/6X2xvtL1enElQmIQnuU=;
        b=jyrb6ah+eL37AVgjQnQp8oDlOKKiefyHGVIbV5Vn6khYKyREadm7lT3nR5gT5atH1l
         veCGVFhzBH9trwl+oA+9IOO7CJcHVtOh97oCBtoGRTjRLU8jm3m/ioWcnLJ5eh1fkSdl
         Gvn/OJhsp7iwECsDCL5I+6Gy96YpRqqeBUW52y0Z4xgfFhrQZumKUJwktEChXVWcvyGy
         v7FIZztNVpN//v+4wUEnFRQSddh7kBvZAi2VL17Ufu4+YklOzrr7piex+W25z+1yRng5
         uqjtQW7z440zovENuTrp7pFJoCJBgDjNKKOdgTYAwO9ygmQEA/7dQRjTpwfmOruX9wph
         OqzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWTvPBPWgMnnh3NYEQrOlM9w8MCh75dDP8WfLSw4UmKOG7tPr0n
	T/YUvWVOAfn2vnVJA62w6W+GMH+NTgT6iSjFNBoyRdyPtYQsUc/JmYaL5QcFFiQOdzcblkni1En
	v0ZhDgMUjHXgWiWySjoLQm7EzF43bC6Ff91sCqcl7D7sWl2U5DV7ukjf8g+8BhqHzfA==
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr32421992plq.144.1559667277911;
        Tue, 04 Jun 2019 09:54:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKBm1D/KEW5bmazZlsl4AMKUgrUHKrLQZdVTRN0dWAVERR+zf+OFXd291tfJPBBhLo4NHU
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr32421949plq.144.1559667277242;
        Tue, 04 Jun 2019 09:54:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559667277; cv=none;
        d=google.com; s=arc-20160816;
        b=rXguWPapLPlBRulXQOKT8oLYdouWfUGC+Zyp3EoGSxGRHTNEFiXQuxRIIueQMawI32
         YHWnDwRE7/QUnlsDeXkagzDcu5C20THgPswrPGR+mwJW2W0kU79KXbUYFwlRS85zH1tu
         CgjTn/+qdsiIJJDKj8kX/DZlz+zBk6HmlJiTff593sDLZHV2FknnREGTeySNeTyxY6Hh
         5iAcCy67Po5tGueOWKsTZxVzeuPCEM28xyiByy56PtIQPjHZl9QOWM3GeYbI7qMciLnh
         W09KH7gX0Rwmt9lToquT28UBoQT/hlmrnazOzOoFYEWilp34hcafYSNp1DogBTV80R5d
         OYHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UdpBYgiDIWDyW9pK5bHCF7O/6X2xvtL1enElQmIQnuU=;
        b=gQk9hrrPnvPTcIT7fLmgMKpEUh/W5DAbgh/7l2NNcvxXtkdXx5E21FVhQ5SiulCmmv
         5a3tt7rvv5xdruHVnd/BjYLpK7BBjZw+DA91uBjhKNiVSMIB60g+fHv87WanYyCdB6Xe
         LZ850V+VgkL71mkgGI2G4OHbPhRJNk0YKuhArCykYhcVMO3dGQnrs9sy3llBaIOiiEbW
         kPr5CohjVegCi8oMoPX/xU9FrCGHlSyqwbyrE/XhXyDVHQExAa6KDIDPqqqoC/JCCQ9f
         OB+akWA9ygreHFEi3WbF7VyJa04mDWC6zY3znRKG/qdwAc5zl9+5zWWKH6KcVO8cK3yQ
         eg+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l13si22897262pjq.69.2019.06.04.09.54.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 09:54:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Jun 2019 09:54:24 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 04 Jun 2019 09:54:24 -0700
Date: Tue, 4 Jun 2019 09:55:34 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190604165533.GA3980@iweiny-DESK2.sc.intel.com>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
 <20190603164206.GB29719@infradead.org>
 <20190603235610.GB29018@iweiny-DESK2.sc.intel.com>
 <20190604070808.GA28858@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604070808.GA28858@infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 12:08:08AM -0700, Christoph Hellwig wrote:
> On Mon, Jun 03, 2019 at 04:56:10PM -0700, Ira Weiny wrote:
> > On Mon, Jun 03, 2019 at 09:42:06AM -0700, Christoph Hellwig wrote:
> > > > +#if defined(CONFIG_CMA)
> > > 
> > > You can just use #ifdef here.
> > > 
> > > > +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
> > > > +	struct page **pages)
> > > 
> > > Please use two instead of one tab to indent the continuing line of
> > > a function declaration.
> > > 
> > > > +{
> > > > +	if (unlikely(gup_flags & FOLL_LONGTERM)) {
> > > 
> > > IMHO it would be a little nicer if we could move this into the caller.
> > 
> > FWIW we already had this discussion and thought it better to put this here.
> > 
> > https://lkml.org/lkml/2019/5/30/1565
> 
> I don't see any discussion like this.  FYI, this is what I mean,
> code might be easier than words:

Indeed that is more clear.  My apologies.

Ira

> 
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097cf9e4..62d770b18e2c 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2197,6 +2197,27 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
>  	return ret;
>  }
>  
> +#ifdef CONFIG_CMA
> +static int reject_cma_pages(struct page **pages, int nr_pinned)
> +{
> +	int i = 0;
> +
> +	for (i = 0; i < nr_pinned; i++)
> +		if (is_migrate_cma_page(pages[i])) {
> +			put_user_pages(pages + i, nr_pinned - i);
> +			return i;
> +		}
> +	}
> +
> +	return nr_pinned;
> +}
> +#else
> +static inline int reject_cma_pages(struct page **pages, int nr_pinned)
> +{
> +	return nr_pinned;
> +}
> +#endif /* CONFIG_CMA */
> +
>  /**
>   * get_user_pages_fast() - pin user pages in memory
>   * @start:	starting user address
> @@ -2237,6 +2258,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  		ret = nr;
>  	}
>  
> +	if (nr && unlikely(gup_flags & FOLL_LONGTERM))
> +		nr = reject_cma_pages(pages, nr);
> +
>  	if (nr < nr_pages) {
>  		/* Try to get the remaining pages with get_user_pages */
>  		start += nr << PAGE_SHIFT;
> 

