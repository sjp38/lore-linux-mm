Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AC69C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CBD321852
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CBD321852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E2E58E0016; Tue, 29 Jan 2019 13:50:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 493B78E0003; Tue, 29 Jan 2019 13:50:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EAC98E0016; Tue, 29 Jan 2019 13:50:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D86F78E0015
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:36 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id a23so17624093pfo.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LO6uE/n1t+5ifcz3BMGrSt1mWI6jQqx2BZkjkAw/sGQ=;
        b=BxzVy5iec2c9ykUr/Jm3XxDLFxSmxIjcmxT5Tr8fes0Ju+SiRWwyhJZxyVYL2NOaGR
         vKRYzBzOP+V3zPSOLSPWDQN1ArPUSBSFlAfbtbUdisPk+WEEMRNVLwACzFd/vXO7+wiq
         wzGlW1SvLHyMBJX7UtQGoX9zuSR5gXJ8w0a37LVMQObi9YTKBDdFSIwtnHb/1hmSY+VE
         SYPkzYAOaeHj24ymtlPYnNcpY6ZHHfEoUHJC51o8RExavo3qGqKjLGBlJ/yO4P5LxSXF
         NxeOvhmXYdcoWDrDchVDCT14vx7KcvjEERGtOUMUxd15sxanrvygGWJGE7lnLd3sEHvi
         V8CA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfF1PBuD3IHtEzMi6g9Q0zfVoSaL61dVYV4AUVOg+dxXSVhCOX0
	SwxHuTx9HBsEMUg3eL6WKX5uEca8hzLtCzFdlCfOcIub8toShLgz3wy0WH9m33eBZWT1zqP54/a
	xG9wvVvBtlZXr4DZo5uoy/U55tz2yMkF4BFzqbJtfUEaqbEqpSqF0jnK6I9mXivpoCw==
X-Received: by 2002:a63:83:: with SMTP id 125mr24209781pga.343.1548787836547;
        Tue, 29 Jan 2019 10:50:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6aF6FQ+NoS8kzwtSqWW3LcHz8jF79ac7NATd0BuByTDD/Q4c3wTZuVKIKglI7neTt5/wsW
X-Received: by 2002:a63:83:: with SMTP id 125mr24209739pga.343.1548787835860;
        Tue, 29 Jan 2019 10:50:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787835; cv=none;
        d=google.com; s=arc-20160816;
        b=gGcwE4W5thNKKfiRmZAeR5Dg7LJ1dhdckeQWZ+MQsdVvaaDxTtp8bk7L+nGbomneoQ
         NEvl7CuTnbgvWKTlKLmp+PcNYdQDhU6xRIkrlcqKiLTEVAhxTdPgwbgdWe7i0Bmdcsep
         hH/v90m3d6ucmnQpYmG+VEu/gaZn34CuU25PXcGxjNrY1JhWXvwXCXoKYm0+dQYJdVAo
         UNtCli2BHQ7ZwExjwVH3gBUpYVghbEshf1Ey59+1GmFdWdgrQ+JAX+8uRXyY6/rr7eIW
         FuZkVek2t7FfzRWGv7S5e68Evf912fTy/xOA3SRRhv1l1McjSFOM26nw8EhkD/SFvdRJ
         tesw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LO6uE/n1t+5ifcz3BMGrSt1mWI6jQqx2BZkjkAw/sGQ=;
        b=UGOTCjcZGlUbGT3VGSfSn+bhcn/vUBNZlEmMCZHbaqUFtrVZAjM0q50n3iQCH/YEX2
         0wGeCASXkAdii/da2eekN/c85a5N5snBzlYB12CBZI0l8jVdweN96Da1eKTajRH3LPS+
         VxsP7m0ie9V/lODxvYUVr8tx9oLS7S20WTjkIxXuoKHCC2utNfP+a2fdhRBIwZ4aqHjF
         yNUjTqEHKje+RELMkaEDmnBPJDORg81DcwfVwlCu2LPAskJ/7u2GqgqQZMe6431skfYG
         liDa7n0g49TvMs3bKuwkPW2zw0YZjfKR1I07HCVbPIH4BCXr+IDYZJ2gRDTCyYGbv6+9
         D2kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s71si35982526pfk.105.2019.01.29.10.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 10:50:35 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Jan 2019 10:50:35 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,537,1539673200"; 
   d="scan'208";a="295436405"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga005.jf.intel.com with ESMTP; 29 Jan 2019 10:50:34 -0800
Date: Tue, 29 Jan 2019 10:50:05 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org,
	dledford@redhat.com, jack@suse.de, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	dennis.dalessandro@intel.com, mike.marciniszyn@intel.com,
	Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH 3/6] drivers/IB,qib: do not use mmap_sem
Message-ID: <20190129185005.GC10129@iweiny-DESK2.sc.intel.com>
References: <20190121174220.10583-1-dave@stgolabs.net>
 <20190121174220.10583-4-dave@stgolabs.net>
 <20190128233140.GA12530@ziepe.ca>
 <20190129044607.GL25106@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129044607.GL25106@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 09:46:07PM -0700, Jason Gunthorpe wrote:
> On Mon, Jan 28, 2019 at 04:31:40PM -0700, Jason Gunthorpe wrote:
> > On Mon, Jan 21, 2019 at 09:42:17AM -0800, Davidlohr Bueso wrote:
> > > The driver uses mmap_sem for both pinned_vm accounting and
> > > get_user_pages(). By using gup_fast() and letting the mm handle
> > > the lock if needed, we can no longer rely on the semaphore and
> > > simplify the whole thing as the pinning is decoupled from the lock.
> > > 
> > > This also fixes a bug that __qib_get_user_pages was not taking into
> > > account the current value of pinned_vm.
> > > 
> > > Cc: dennis.dalessandro@intel.com
> > > Cc: mike.marciniszyn@intel.com
> > > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > > Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> > >  drivers/infiniband/hw/qib/qib_user_pages.c | 67 ++++++++++--------------------
> > >  1 file changed, 22 insertions(+), 45 deletions(-)
> > 
> > I need you to respin this patch/series against the latest rdma tree:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git
> > 
> > branch for-next
> > 
> > > diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
> > > -static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
> > > -				struct page **p)
> > > -{
> > > -	unsigned long lock_limit;
> > > -	size_t got;
> > > -	int ret;
> > > -
> > > -	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> > > -
> > > -	if (num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
> > > -		ret = -ENOMEM;
> > > -		goto bail;
> > > -	}
> > > -
> > > -	for (got = 0; got < num_pages; got += ret) {
> > > -		ret = get_user_pages(start_page + got * PAGE_SIZE,
> > > -				     num_pages - got,
> > > -				     FOLL_WRITE | FOLL_FORCE,
> > > -				     p + got, NULL);
> > 
> > As this has been rightly changed to get_user_pages_longterm, and I
> > think the right answer to solve the conflict is to discard some of
> > this patch?
> 
> .. and I'm looking at some of the other conversions here.. *most
> likely* any caller that is manipulating rlimit for get_user_pages
> should really be calling get_user_pages_longterm, so they should not
> be converted to use _fast?

Is this a question?  I'm not sure I understand the meaning here?

Ira

> 
> Jason

