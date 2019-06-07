Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17030C468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:54:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D11C6208E3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:54:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="TANt56tM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D11C6208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F1266B0269; Fri,  7 Jun 2019 15:54:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A19C6B026A; Fri,  7 Jun 2019 15:54:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6906A6B026B; Fri,  7 Jun 2019 15:54:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32F616B0269
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:54:32 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g11so1999832plt.23
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:54:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bzTsWpyXdxWrZ6A+rscRPiBAkVoVkKQsxuRyeipwKaw=;
        b=s1KnM02bfCjOPc4Xg6WFtnWaf2cUcBLepg0sNnIB1zVPH3RXRjMWOt81NFhCOhvW+M
         Uggf4+z159g9QyI6uzY/Kq+PEb72lUCMcvcVCWASAZCUdWI9qS7fccbOmr73eQpvx/Gr
         309WNL/eku3Gl+iIewbniSMZXVNWJoNntRGAGeTYR7xnBanjnEZjJ8wsA9091YfhcXGJ
         LwFjH8CXBPD7555K0PhXuwKyeQO4p2JRLVOi69zLpogGxopAAQyGEGcE5cOHHoztjOZl
         p8O5n3fGnB1KB966R6pQlGMvyTf2zH8LR1F47Ou313iQc/fgy6xhxzq1Ec1e01azsKec
         1tBQ==
X-Gm-Message-State: APjAAAXt26xhC3O99Nxt1/O1BhNt/nN4XEoecpchIKbZ5OV4NYeQ//Bc
	v5WIkJ/xqXsWlbKFfZNuDH7ckpD3q8DBgHJfNQXle0gbYAMf0//pFVBFTfx1jnG1CvLwu7+hsEr
	Z3usR2DhficOdY4xQu7S/5om7s04ljjDXGum7ZoxJmPfvZs6ekGlYn1WkjLB4rYD8ig==
X-Received: by 2002:aa7:90ca:: with SMTP id k10mr60697005pfk.20.1559937271795;
        Fri, 07 Jun 2019 12:54:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxy4W+6+UkBVq4K0e7F8dZcWbftDX+38ze2v0avOD8Fwq4Ui6DnX30YfPrg8Ufsxg3/td18
X-Received: by 2002:aa7:90ca:: with SMTP id k10mr60696960pfk.20.1559937271112;
        Fri, 07 Jun 2019 12:54:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559937271; cv=none;
        d=google.com; s=arc-20160816;
        b=uJZs9uVl0vNswicrA5P5xDEdHDRbn6dC8mjLW9k4Fc+gTTyrkiHly+yI8txTHV6eXi
         +z2vnC/P+4PD3gGwvw66eU337f8Nef2cm5JxeScH34CncTuo/vjOmv14CvPzBfNjlh7Z
         XwcoCOLpKFf0FVzJCiek8slZ9HTNCC1h17Z4P41nzA/apq2iKUwZF7toNIkxyYIkrcEi
         f0UPeZJbHYO8+7JWjhQbMjk21rnVEMUyxheqoDsJllOqr7lqbCDAbytowGCJPQkjs+Vh
         5DEx8n0CiOhawZtn+WWWQd3nw8WYWJnF9tjRO0P05OvzGUNAnIJo1nrVtiafyVuPsNgE
         oDXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bzTsWpyXdxWrZ6A+rscRPiBAkVoVkKQsxuRyeipwKaw=;
        b=RVQ7UfbZYbKD5y7Bi2MNZCRSneMNNMaRQJCfgufflz8XwKo6r2NN/CTrXYdhrnAvCn
         SBHVdxRniuZrUY0efX6pQkvgGxlqB3X18c71H+4+1+B0N1u2orjXEH/AOm8ppQqe8tjx
         tbQZBm/cSNPaq+VKzRyw2YwOG16SQ1CJaaDBqjiYrgNoPmxRTlUOCOrReGwzuez3yfX2
         ngy1GncPXQenLjl0pnWl6yiqRKZuRWooS/oOdd75nHAevgHyJ2dGWTXKVBdzPgjc0Gvv
         s9Bs/MgVaSVnP0uPvE34fajRPHsSMzT0lOypewOL/zGIB40l2Z33ar9i3wDIvHoqduVt
         RfiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=TANt56tM;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s3si2805108pji.94.2019.06.07.12.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 12:54:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=TANt56tM;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 81E7D208C3;
	Fri,  7 Jun 2019 19:54:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559937270;
	bh=8psQmUHD9luxI22nFWbQOgpTZfWDCb9IM6SP1Gb6RuE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=TANt56tMnGHGSeTHxg2W5Nga6u0fq8FsdWYmLcrlsCGA2NGsA2mQH36A8hsYaUQl7
	 PvF+FiSUc0fahikKKGkO11OQ4+xLKsQjmAxNlLOFaGKdbVX69LqoznlxnaXcFMOm0G
	 NPbdjRpokmMR23+zPVRWYusaOBotEgcPCbhlQMLI=
Date: Fri, 7 Jun 2019 12:54:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
 linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>, Michal
 Hocko <mhocko@suse.com>
Subject: Re: [PATCH v9 11/12] libnvdimm/pfn: Fix fsdax-mode namespace
 info-block zero-fields
Message-Id: <20190607125430.81e63cd56590ab3fea37a635@linux-foundation.org>
In-Reply-To: <CAPcyv4hHs75hYs+Ye+NHHiU31C6CnBqCFdo=2c5seN7kvxKOrw@mail.gmail.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
	<155977193862.2443951.10284714500308539570.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20190606144643.4f3363db9499ebbf8f76e62e@linux-foundation.org>
	<CAPcyv4hHs75hYs+Ye+NHHiU31C6CnBqCFdo=2c5seN7kvxKOrw@mail.gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Jun 2019 15:06:26 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> On Thu, Jun 6, 2019 at 2:46 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Wed, 05 Jun 2019 14:58:58 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > > At namespace creation time there is the potential for the "expected to
> > > be zero" fields of a 'pfn' info-block to be filled with indeterminate
> > > data. While the kernel buffer is zeroed on allocation it is immediately
> > > overwritten by nd_pfn_validate() filling it with the current contents of
> > > the on-media info-block location. For fields like, 'flags' and the
> > > 'padding' it potentially means that future implementations can not rely
> > > on those fields being zero.
> > >
> > > In preparation to stop using the 'start_pad' and 'end_trunc' fields for
> > > section alignment, arrange for fields that are not explicitly
> > > initialized to be guaranteed zero. Bump the minor version to indicate it
> > > is safe to assume the 'padding' and 'flags' are zero. Otherwise, this
> > > corruption is expected to benign since all other critical fields are
> > > explicitly initialized.
> > >
> > > Fixes: 32ab0a3f5170 ("libnvdimm, pmem: 'struct page' for pmem")
> > > Cc: <stable@vger.kernel.org>
> > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> >
> > The cc:stable in [11/12] seems odd.  Is this independent of the other
> > patches?  If so, shouldn't it be a standalone thing which can be
> > prioritized?
> >
> 
> The cc: stable is about spreading this new policy to as many kernels
> as possible not fixing an issue in those kernels. It's not until patch
> 12 "libnvdimm/pfn: Stop padding pmem namespaces to section alignment"
> as all previous kernel do initialize all fields.
> 
> I'd be ok to drop that cc: stable, my concern is distros that somehow
> pickup and backport patch 12 and miss patch 11.

Could you please propose a changelog paragraph which explains all this
to those who will be considering this patch for backports?

