Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CC8DC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 14:51:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED7162083D
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 14:51:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED7162083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57C586B0007; Fri,  7 Jun 2019 10:51:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 523966B000C; Fri,  7 Jun 2019 10:51:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 380A16B000E; Fri,  7 Jun 2019 10:51:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EEBB26B0007
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 10:51:02 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j7so1636828pfn.10
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 07:51:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ONrEX0pLSNG7X0Q/0w97Q79cpcqRNXaRPFhLlTP43jc=;
        b=PMwOfIC4Hb0XLlGK25yLoAWhbSUQsptlgp55DAOMGFwsF5B+4oVdHnoHtuxp0SxXDW
         5dvfTC1Q7h3nD3uZqb3kDLS+KsNmLEy+3jwInDFQiBxBjBJ/iHBkFBRlRieSaQQgeIhZ
         alFymcZfVwnelpLvzvQ3BFWT7S6YhMPk+/aDjJFpFvtsUAw4bV4WM04KAnE12kAoqOv9
         yw/Mm946ij2fq9Uevzpu5BG/K0rHtdYAvVDK8tnDg1i9Ql9mNYPuXB+eJQJuE24VNb8x
         v8wNl5SEaTIwHn0tPJZiT0dM2EjLtNCSErsg0AUeRux5aOPNPnPR+7jjQdEuZBdwjcSS
         azYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVvR3JjTNA9gyvbuzMhy9ikJ0JWoEh3mdnM3dGnQtpaaAuygDJS
	OsRKM13WECN5lf67qCVA2t2fWe1VsYdptYI1Du3W0wlAcmuQULc1hvqlFusXlISwhDnshp86+2o
	MmZORMRtqe+8zwvW/jLl+HQkt00QU2s9kIpj30EBZ9TlysLH1UwD4cpuNon23eC1zFA==
X-Received: by 2002:a63:5462:: with SMTP id e34mr2876578pgm.400.1559919062548;
        Fri, 07 Jun 2019 07:51:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6EKC/3bqNM0suszUSbqUohmtAATpt3IoWogWCThxkOZLfqH/V5OJR5m8E7OkkgASkGt0+
X-Received: by 2002:a63:5462:: with SMTP id e34mr2876457pgm.400.1559919061070;
        Fri, 07 Jun 2019 07:51:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559919061; cv=none;
        d=google.com; s=arc-20160816;
        b=sCBrzmXgqSTy07anAwGxfuzTIwnRYSSwx/LGsAVp2wjqqDtNYexNm58KaxAsU+usQb
         iFnOL4cXtcmVs/yvtfi1QWrQdt71jzwHbgSfrfSaR/Q8ANJgBw9B8zqOeD9pjRpLEUP6
         /HtNL46wmFRv+CqxU9TcXdrkwPwJlgYmb/hsUOaPaODI+z7tGRKu0MkEsOuZbGyC3esg
         QNsfHvLm/UJD9Iclr3qSrJ4Q6vKrqGhIgE+ZcjyuOvhC1BQLmUlBmSbdrI5qKlgOXYn2
         sb6GILt7OTjni/01pI/9JEJBSVOjDp5QHQH4XopD3Y15DN3JlUXisdWsbDF41KMF+lMh
         Eu5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ONrEX0pLSNG7X0Q/0w97Q79cpcqRNXaRPFhLlTP43jc=;
        b=ZiGTN8rMd+IgBtkbnXQBQuJTX9Z75PJw5HgMYG1r47ZIvd+enavM9lh3jWnt4b8oef
         pLXucvfZ+cMxqxccZ9wmMX58TeSc3YW8gYh7T5sVgasvIsVsHh5HcvxDbwGS7Cm6/yBk
         oBuu1pN4sBUFAk93HydBC955HZ2f/geIbuDVB/YZtAYKKUeDhDVaKvn/CxVqmfaN5BAa
         /4arSkIsy7ud0kHV5/u3neVzUKRe1aq+8/gZknMBWjX8+jJpqI4hwUSqPP6vrxV3GHOP
         TjaZxWCfnOdBmquXCyVb/1zq494xcJ+pCJ2H0M5+frLj0xJDYR2Phuc+WxvyE8yg0nJI
         mMJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id m1si1815345pjr.47.2019.06.07.07.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 07:51:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 07:51:00 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,563,1557212400"; 
   d="scan'208";a="182683628"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga002.fm.intel.com with ESMTP; 07 Jun 2019 07:51:00 -0700
Date: Fri, 7 Jun 2019 07:52:13 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607121729.GA14802@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 09:17:29AM -0300, Jason Gunthorpe wrote:
> On Fri, Jun 07, 2019 at 12:36:36PM +0200, Jan Kara wrote:
> 
> > Because the pins would be invisible to sysadmin from that point on. 
> 
> It is not invisible, it just shows up in a rdma specific kernel
> interface. You have to use rdma netlink to see the kernel object
> holding this pin.
> 
> If this visibility is the main sticking point I suggest just enhancing
> the existing MR reporting to include the file info for current GUP
> pins and teaching lsof to collect information from there as well so it
> is easy to use.
> 
> If the ownership of the lease transfers to the MR, and we report that
> ownership to userspace in a way lsof can find, then I think all the
> concerns that have been raised are met, right?

I was contemplating some new lsof feature yesterday.  But what I don't think we
want is sysadmins to have multiple tools for multiple subsystems.  Or even have
to teach lsof something new for every potential new subsystem user of GUP pins.

I was thinking more along the lines of reporting files which have GUP pins on
them directly somewhere (dare I say procfs?) and teaching lsof to report that
information.  That would cover any subsystem which does a longterm pin.

> 
> > ugly to live so we have to come up with something better. The best I can
> > currently come up with is to have a method associated with the lease that
> > would invalidate the RDMA context that holds the pins in the same way that
> > a file close would do it.
> 
> This is back to requiring all RDMA HW to have some new behavior they
> currently don't have..
> 
> The main objection to the current ODP & DAX solution is that very
> little HW can actually implement it, having the alternative still
> require HW support doesn't seem like progress.
> 
> I think we will eventually start seein some HW be able to do this
> invalidation, but it won't be universal, and I'd rather leave it
> optional, for recovery from truely catastrophic errors (ie my DAX is
> on fire, I need to unplug it).

Agreed.  I think software wise there is not much some of the devices can do
with such an "invalidate".

Ira

