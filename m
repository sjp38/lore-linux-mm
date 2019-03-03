Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F0F2C4360F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 00:57:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0665720835
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 00:57:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0665720835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9697D8E0003; Sun,  3 Mar 2019 19:57:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93F168E0001; Sun,  3 Mar 2019 19:57:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82E5A8E0003; Sun,  3 Mar 2019 19:57:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED658E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 19:57:34 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f10so3066851pgp.13
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 16:57:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WV1qjjN+RqkL9Z2bxUESvGtb+y4eGxOlfx17XJCxEeM=;
        b=pRJogX0/9zqXixq1CQF7s05HtvP7NkaTOm73ZkqESG76ai9YevvrQfMawMEX9FXK85
         I1cO9U35S6bLh0oMr2D4ZZkkqVrIUKBI5xU2UgrQVQEfWtxI97QsoEwFfeSwQEAVfTEI
         /E6Iy7sImV+O34JgFBG2g2AfTtrG6ju9rNGSV9a/ush9WYgUl7JVN7jLrJqxJNFZovxy
         Ibw/F7yayPweHAH3geuO+Cr7L2hipwf3xlDuwa6F53sAvH160XU4JOOzGM/ZyJYh3ESx
         dqONRO+//ki9+2N0HfqUQQhARfKmzChFzBquo7kCGURU9HE65pTA02vasNaWtjoHrJTk
         6l/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWjXoxLf1gQgjU14rjTdVuXqckt33u5Ec2Rw6hxEIfWHjglFPRc
	1ock02adHbeqRLCm5M2R/fia73K0/s+UKp6jMDbNHs38xUfg0bEnSiNJ78D481kT4c1SeZYWb1e
	ZieGRhIU4XteK/wfOcYw2CJZZQtZ2NVUTndm4UNOoe74tcX87dD81CR381TUFoUJmUA==
X-Received: by 2002:a63:591f:: with SMTP id n31mr15821367pgb.304.1551661053895;
        Sun, 03 Mar 2019 16:57:33 -0800 (PST)
X-Google-Smtp-Source: APXvYqweehXqp4HsABoVylqQIBwe1+WixEcrf89LHra2otN6HODzJ2/a/lrM4mIXrgUjbeVdnMUz
X-Received: by 2002:a63:591f:: with SMTP id n31mr15821312pgb.304.1551661052852;
        Sun, 03 Mar 2019 16:57:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551661052; cv=none;
        d=google.com; s=arc-20160816;
        b=etKNWE2Hj3uTfmXw/HqKg4ShwNQLaVFUN8SohYcMCixdVnjgHFPcfSA8HMexeDMChC
         QBlCz0INQY84r9OYTa4JruOAGmW4J99LP527CGs2gv4gJXyQrY4BcfRJNySlTuKf9CQ8
         PDkhWpaeyt59CvO7REZilSvjNehmBeP6vsoPptGxlBfcdAlZPzWrdJpeNrJC+hhRSFZ6
         wqBWCvX190VBbMauRWFaGlq01tXUevKxYngDy3UIFYUABEBic4rde4RrrPJaotdRV4I/
         LJqPIDsEXRDIPMZLQMZ5GfHVA/4Y7qCj00jmILQ4w/edpIiMiR5rFsKUz7dghbDIEAZq
         /fkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WV1qjjN+RqkL9Z2bxUESvGtb+y4eGxOlfx17XJCxEeM=;
        b=sl1SHP3IWK/GDqSbI86JbhF/urWTP7UGw6oNe4YzPdqWzYY8Iv4lS12VfGIvF4GUJ3
         r061luTep/onvLiQsMRkWyWGlKIGdylfferFC1KvaaiHkzqS6P1Fb4LthkDgCe6VatFz
         owSM3YntpiSe71hAVTLik41BlDizqHYDSg1HemhsDYtyGpsIwjnL8FEdP1NwiB1v1Su5
         SzbBuQl1/ZXbsALmY+VyyT82ls6Lg4kSGQmStPnedaZhIJu5NQ/hv60pGlriwod1CKgV
         xGQwL+ZsvbtLetUDxQfX4TjEPfmu4hd3SaoVpkC7eGahmDSaBXKRWBOZMn/szCgE50rQ
         LaZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d125si4179224pfd.206.2019.03.03.16.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 16:57:32 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Mar 2019 16:57:32 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,438,1544515200"; 
   d="scan'208";a="137790581"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 03 Mar 2019 16:57:31 -0800
Date: Sun, 3 Mar 2019 08:55:51 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Artemy Kovalyov <artemyko@mellanox.com>
Cc: "john.hubbard@gmail.com" <john.hubbard@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error
 handling paths
Message-ID: <20190303165550.GB27123@iweiny-DESK2.sc.intel.com>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 03, 2019 at 11:52:41AM +0200, Artemy Kovalyov wrote:
> 
> 
> On 02/03/2019 21:44, Ira Weiny wrote:
> > 
> > On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrote:
> > > From: John Hubbard <jhubbard@nvidia.com>
> > > 
> > > ...
> > > 3. Dead code removal: the check for (user_virt & ~page_mask)
> > > is checking for a condition that can never happen,
> > > because earlier:
> > > 
> > >      user_virt = user_virt & page_mask;
> > > 
> > > ...so, remove that entire phrase.
> > > 
> > >   		bcnt -= min_t(size_t, npages << PAGE_SHIFT, bcnt);
> > >   		mutex_lock(&umem_odp->umem_mutex);
> > >   		for (j = 0; j < npages; j++, user_virt += PAGE_SIZE) {
> > > -			if (user_virt & ~page_mask) {
> > > -				p += PAGE_SIZE;
> > > -				if (page_to_phys(local_page_list[j]) != p) {
> > > -					ret = -EFAULT;
> > > -					break;
> > > -				}
> > > -				put_page(local_page_list[j]);
> > > -				continue;
> > > -			}
> > > -
> > 
> > I think this is trying to account for compound pages. (ie page_mask could
> > represent more than PAGE_SIZE which is what user_virt is being incrimented by.)
> > But putting the page in that case seems to be the wrong thing to do?
> > 
> > Yes this was added by Artemy[1] now cc'ed.
> 
> Right, this is for huge pages, please keep it.
> put_page() needed to decrement refcount of the head page.

You mean decrement the refcount of the _non_-head pages?

Ira

> 

