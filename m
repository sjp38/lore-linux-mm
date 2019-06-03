Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50692C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 23:55:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20C84206BB
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 23:55:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20C84206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 643BB6B0274; Mon,  3 Jun 2019 19:55:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F3936B0276; Mon,  3 Jun 2019 19:55:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 509AF6B0277; Mon,  3 Jun 2019 19:55:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1799F6B0274
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 19:55:04 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j36so11027893pgb.20
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 16:55:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BfrVSN4ODjfVBZQclyBy3XPLkba4Y9mgxbJUUtpjQ4w=;
        b=YYRUFx5k3ZtC9WUk9DQ/IglRkKcqIxh5sXfZxdA1o35uLIFT/ncaoMNfe8/AlbwFav
         T9js1vQf+/1pwDorU5iTL08BM0oHJBhwuktdoPhSkK9hTXKmxIU3+ZTkhk6+kHd4nWaE
         zYrh8BbZVjBlBRGrm6l5EDz9/hneCIkSA/j9pNwhVUo+Q1I3opZLIOlBBdDc9KGMK35k
         kd5G0/x3fAm6ouqODwEQhLBxgPEyJO/ah8PzhBogBatsEb/RSTgRzxedDTYQ2BfwXAN1
         HeDnYm2Bz0NyTmaHqmk9cKAgH1dCNmOiw+JHVmAH0kEcnIjhldWUZuD+u4SbJntZBx8S
         KjGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUvXd/2NKKhaXvTww/uumKAx7HmkM6OAaJbtTDE3GJqvlwlhMvV
	dYxFQ7x3eAiaq5S8gpJ32/Zl+3cFFW77KZTF5obbmBkvnOKadBHKKFFjaVJ3FmIhkLfylJfw7wS
	9CUcUBRys9JaiTxGDosJdsDuzvHrjyTZlRbjfPChkatXjDc4VgY8h3F9MvlaJSTzAaw==
X-Received: by 2002:a65:63c8:: with SMTP id n8mr30414071pgv.96.1559606103757;
        Mon, 03 Jun 2019 16:55:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjRt+et3eFzjpuT+kb8NoznkbINaR0b/kPQ/rUiJd5/dHIZU6JXvIAgFrTqcbfqDQoiYNc
X-Received: by 2002:a65:63c8:: with SMTP id n8mr30414006pgv.96.1559606102523;
        Mon, 03 Jun 2019 16:55:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559606102; cv=none;
        d=google.com; s=arc-20160816;
        b=RyQXNVgSpOCBm4SgwgSHx+25pEn95P2Sw5VqV+CKSsb4N6XEj6/fU0X62SB750ShDc
         2qsfevgoAOfwz7F60lKGdeR4F9DELZn3yaurvzu93TwgnZnqz+qzg/GE0JUrLkwUSj46
         dP4cFhzAXO/jytnFayJWFJkWL34K87tJYt6ekzknIGW6T5B0UOYE/sz5acbLwkyvpE6n
         FkpZ9JpfIA9WurcM8dDBRfDC+bsAT7i6Zu6qIGM3mtD0E+R3hfB31kmqo6ClGY7ZnW8X
         3vBsutcnxOqnUC4WVVWgKP286rqNhzmRUAylBXXucQR7PuH7DVfS5s9gfws2kY6m+Dp9
         za1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BfrVSN4ODjfVBZQclyBy3XPLkba4Y9mgxbJUUtpjQ4w=;
        b=lg6j2CISHIXT31XqFJlecuF1m0PQKBSQua35ZL0sUQRRdPLEcmWQ7DaHhCU1/8PqCV
         MPVjZZQx8X0wjRwATGZ0V+bFMRsNaj6LRnKC65VImNBntIpVtMAY1gEnUlbkdYFd3SsE
         6lS0GFeyLdQNGKKUI/ylX8e7z2hh2W46MbNYfp64l5Xrqs4W+smutQm8ZxCg2UkqRikC
         +XIcdoEHGkw0YiTihpoTeLKtdSO3AikHTnjBpH2joWw/Bm+p7xGrXrzX14idA4dHqsSw
         gTHMdbwf/2JkRswCwgonesj7OZxxsp+b54bYHiBqjk2i7cleH2XPEwHyAOWt6XFrw0BM
         qnBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w16si20274313plp.185.2019.06.03.16.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 16:55:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Jun 2019 16:55:01 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga006.fm.intel.com with ESMTP; 03 Jun 2019 16:55:01 -0700
Date: Mon, 3 Jun 2019 16:56:10 -0700
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
Message-ID: <20190603235610.GB29018@iweiny-DESK2.sc.intel.com>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
 <20190603164206.GB29719@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603164206.GB29719@infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 09:42:06AM -0700, Christoph Hellwig wrote:
> > +#if defined(CONFIG_CMA)
> 
> You can just use #ifdef here.
> 
> > +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
> > +	struct page **pages)
> 
> Please use two instead of one tab to indent the continuing line of
> a function declaration.
> 
> > +{
> > +	if (unlikely(gup_flags & FOLL_LONGTERM)) {
> 
> IMHO it would be a little nicer if we could move this into the caller.

FWIW we already had this discussion and thought it better to put this here.

https://lkml.org/lkml/2019/5/30/1565

Ira

[PS John for some reason your responses don't appear in that thread?]

