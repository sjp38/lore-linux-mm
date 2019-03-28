Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48198C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:50:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EBDF2184E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:50:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EBDF2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84DD66B0007; Thu, 28 Mar 2019 22:50:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FB806B0008; Thu, 28 Mar 2019 22:50:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EA836B000C; Thu, 28 Mar 2019 22:50:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3094B6B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:50:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f6so615094pgo.15
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:50:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=TJTVNXJGp6fpao2xfmuI8J1PxLLgsZQ7TWL+COztGPE=;
        b=KigjxHI9Mi5G2nofH4ZOwRnjUTW+57KURhwgpyLx+7mzVBUxjumdenNj9+uhIFUR6Y
         omSHKEaa175vQydaxrf3VlI2+IofAoxpKpQcrOfLtTFdS0u2iXpHoD3KtVWPSW7WFbWh
         ads4uH7deWze97hkeBmRwehWX+wHkc4kadWw21IEpezujnsXc2RY3Hq0VCrV9ZT6Ngxe
         9GshvVSiHilJrlxRH56MnCYLJT6chzhQxRLdd1u6HavlHZCe9QMnci0hgcw1tAdPTCHE
         /I5v37/od6dqM/L7mh6NZmGchphdKA4GhCMLFtW/sypJCu+jJr+Zv+wGOw928rweo34n
         QH4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUrMhvN4OEACpvgZtdNp5HUS5Gys7rSmTFPfMqBBCOcvkJTcrw8
	EqPucOUqoTj+WNRqiOxSZAsU+liBYKDQgGfpuDMbswrI+qPBMRFBw5kXLxEemT+YP+zxZNYufdr
	tp+CGnZgFhvoxYvCQ0Xu/T4vAE/kuE8B1zbrymInMJDz8yIbBXMGey0TUekHhggvv2g==
X-Received: by 2002:a17:902:728b:: with SMTP id d11mr47085415pll.257.1553827817857;
        Thu, 28 Mar 2019 19:50:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqZkDC6L/pB6pPlquoR4Z7vwpbimFJnX/2bwFoeOhXi+ClLrNYJCG0xQE4kL/kYAyiqF0K
X-Received: by 2002:a17:902:728b:: with SMTP id d11mr47085356pll.257.1553827817058;
        Thu, 28 Mar 2019 19:50:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553827817; cv=none;
        d=google.com; s=arc-20160816;
        b=OpkpNGjDNGsp7I3hYhCWk57xq7/znoRPhsMU3G5G5eOYFJ7lNnuQHUYqLd5TyGLVeN
         vioXaGheZotiWgj3+cyr/Ggsfqxiz0K6G7qxChReDMNTVLAJI2jbM9LStzuPCGB5tYZt
         vmW7TF52dzVlbgi1HcRUCaQcZbOJS8nZ44xOjH1c8hwLok6dm1ETCKmguBurYsoi6SEW
         sl49oIptvkvhzPu6wGOY8SSdDGdVCO1Udzla/F5QfG+m24oU/53CUqvn09LhFjmuLPRq
         Wb4NT84G8LtWO9eqZc3wLUqyWAWc55hckrYpmp/vg9OOFW8FzeOWUvzxvS2kBFSkolCL
         GZsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=TJTVNXJGp6fpao2xfmuI8J1PxLLgsZQ7TWL+COztGPE=;
        b=wNGUTEFNqq77p5tk8ohz3+ox90RIMRqbJn0mAVihS0c0EYxbK0y56msQNjlncqzOU4
         45rrhtrjCM0HEQwDuugQysghTsbx7RXsTlBVQktoGtUEVfLbaogiMTzduxyQafGOyex9
         e/DTgRFhn4aoScmcOVaf2KZRANrPA8yJUi/J8lzdh1wjCqLj2Bhkd+ZWpCbiF5SnEFDQ
         SsFvyL9gmH3w0muK8IG0u7EMdN7E1KOsygw/fwpNPXZgd/Ckx6gqMOWEK9cKGWIXA0YJ
         wMlO+7PyxIxBFGIFN+zLjsx4A9xHxKd+8gEBp8sUjDBOFCatA2Tevvw4cGvHVcDr4aN2
         Y/Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a22si698011pfc.217.2019.03.28.19.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 19:50:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 19:50:14 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,283,1549958400"; 
   d="scan'208";a="131143137"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 28 Mar 2019 19:50:13 -0700
Date: Thu, 28 Mar 2019 11:49:06 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 06/11] mm/hmm: improve driver API to work and wait
 over a range v2
Message-ID: <20190328184906.GL31324@iweiny-DESK2.sc.intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-7-jglisse@redhat.com>
 <20190328161221.GE31324@iweiny-DESK2.sc.intel.com>
 <20190329005654.GA16680@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190329005654.GA16680@redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 08:56:54PM -0400, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 09:12:21AM -0700, Ira Weiny wrote:
> > On Mon, Mar 25, 2019 at 10:40:06AM -0400, Jerome Glisse wrote:
> > > From: Jérôme Glisse <jglisse@redhat.com>
> > > 

[snip]

> > > +/*
> > > + * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
> > > + *
> > > + * When waiting for mmu notifiers we need some kind of time out otherwise we
> > > + * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
> > > + * wait already.
> > > + */
> > > +#define HMM_RANGE_DEFAULT_TIMEOUT 1000
> > > +
> > >  /* This is a temporary helper to avoid merge conflict between trees. */
> > > +static inline bool hmm_vma_range_done(struct hmm_range *range)
> > > +{
> > > +	bool ret = hmm_range_valid(range);
> > > +
> > > +	hmm_range_unregister(range);
> > > +	return ret;
> > > +}
> > > +
> > >  static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> > >  {
> > > -	long ret = hmm_range_fault(range, block);
> > > -	if (ret == -EBUSY)
> > > -		ret = -EAGAIN;
> > > -	else if (ret == -EAGAIN)
> > > -		ret = -EBUSY;
> > > -	return ret < 0 ? ret : 0;
> > > +	long ret;
> > > +
> > > +	ret = hmm_range_register(range, range->vma->vm_mm,
> > > +				 range->start, range->end);
> > > +	if (ret)
> > > +		return (int)ret;
> > > +
> > > +	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
> > > +		up_read(&range->vma->vm_mm->mmap_sem);
> > > +		return -EAGAIN;
> > > +	}
> > > +
> > > +	ret = hmm_range_fault(range, block);
> > > +	if (ret <= 0) {
> > > +		if (ret == -EBUSY || !ret) {
> > > +			up_read(&range->vma->vm_mm->mmap_sem);
> > > +			ret = -EBUSY;
> > > +		} else if (ret == -EAGAIN)
> > > +			ret = -EBUSY;
> > > +		hmm_range_unregister(range);
> > > +		return ret;
> > > +	}
> > > +	return 0;
> > 
> > Is hmm_vma_fault() also temporary to keep the nouveau driver working?  It looks
> > like it to me.
> > 
> > This and hmm_vma_range_done() above are part of the old interface which is in
> > the Documentation correct?  As stated above we should probably change that
> > documentation with this patch to ensure no new users of these 2 functions
> > appear.
> 
> Ok will update the documentation, note that i already posted patches to use
> this new API see the ODP RDMA link in the cover letter.
> 

Thanks,  Sorry for my previous email on this patch.  After looking more I see
that this is the old interface but this was not clear.  And I have not had time
to follow the previous threads.  I'm finding time to do this now...

Sorry,
Ira

