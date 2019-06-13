Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30BC9C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:12:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0085021537
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:12:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0085021537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F3B96B000C; Thu, 13 Jun 2019 17:12:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A44C6B000D; Thu, 13 Jun 2019 17:12:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BA2B6B000E; Thu, 13 Jun 2019 17:12:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 471F56B000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:12:03 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v62so225482pgb.0
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 14:12:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Sf0T6+DE0Yp7Ry/3pib9DUa+9/DFe+NNfT6qIti9mKA=;
        b=IMRm66kH+KtCVmEBPqpwm8CPqvE/8W5J3p37p2dwzb3UTE+eKNp4NNCexDpLt+h5zn
         36CzKDLdDW/9HF6rv5Uvj51qP9W+tmY4bjtUkJFo9UgFdTzoN6dGVkWr+iD0jpusowQl
         Y/e7rFYwfYl3L6M8I3yhZKNlM4MnZBGOCJISiirqq9NviQtQaZ1OOMpDWfZiFvQG1dQu
         TU49JYq2ep5ksvGvAotS45f3OTijJ6OCIh4IeRf7iHeK3PAl0jJ3aEAGSkiYmR91cLon
         /XTiJbbch/YQYX3rc6CT3xPDPmaPGGLnzhSRjzwp8Mv627Aukh+sF66rsoqLnkRuTX4P
         bprQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWQYI3N9LAX25v7LtSewa3QOvP4xj+oQlgJWyZCt5Cf2PehFHKk
	W4rGEysHq1X2ShLSQypuihT3+kMg+95cG8HVjuXbJo5wKnP6uFlKKmyp3CV4DEBwQ9asyc9JsgS
	pW4nCMn4K5yl5sa4RjzNCN0834StaNbxaB1X9dRM/WJ4T7sObHQq+7c1cczy7q/JD9A==
X-Received: by 2002:a62:834d:: with SMTP id h74mr51015819pfe.254.1560460322936;
        Thu, 13 Jun 2019 14:12:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcjT+dl6GXv6waQSLLBsgTTdjx+0NQ8hX1iNTc4Q3OXvifKA82Dr0XSdBFsIwd8hg8I4on
X-Received: by 2002:a62:834d:: with SMTP id h74mr51015754pfe.254.1560460322076;
        Thu, 13 Jun 2019 14:12:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560460322; cv=none;
        d=google.com; s=arc-20160816;
        b=jPOD2ssBlpOtFyWcA7dU/f4W7eCi307MvvbvGeIRP5IvoJoy4XqdQmYrpAuSebLxLj
         /K4SJosxkV0R39pSK2wiSa/fu6jwtzQQJgZh9PW7PTkQR69kDqdT72wBfrMS4ysdhML9
         CEw4DPrWFbxWKZXXyJct/Ve/+qrhD2qT7ihE5yGsvecBnr7oBA+DbcFahRa0YXzkIAF2
         a+uuk+Gs4puoVWCvobJs9UWY4LC3sxDrMLTh3wy65uNnnadJziEVWGMpGQ6IhJ/2cgjc
         3ezewcCxjRktNlTiRjNLn6I0V2ek3NFeuKJkchNY52Klm0jt03GfLKZ81ZtSPKma6Hl+
         GPJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Sf0T6+DE0Yp7Ry/3pib9DUa+9/DFe+NNfT6qIti9mKA=;
        b=t3w128fvsqD37iZUmmxOsg1On1iIbjHf6RyEvprW/m9wXLhrMIKRTk1Dzy8VMTgUBb
         QWxNEPO8U7cpYVBPDyjVlf/t2yATsbQ1XIRit++2evTt9u2f9+ublMxQ9IXYqTSPyNC/
         MKbo2XCdDKYeGk/Q1Gq6f/toCZHPT3UxBIVkhSJ98rpThFVt7Nbj9Q7aGgZekEJG6mVc
         I3dFqB/sPIaFdqvyyFftUI1C85IizhSXHcALjvuzdfQElwYb9b0dRthO+6Ju4v84MKQq
         /AaQCG+kqwamKKRpxQjAH0hB4D1FGQHlJmQNh1gDahAAVZXVXBUlri9wn+WfZyyamgT1
         os6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j6si503584pfi.184.2019.06.13.14.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 14:12:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 14:12:01 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 13 Jun 2019 14:12:00 -0700
Date: Thu, 13 Jun 2019 14:13:21 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190613211321.GC32404@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
 <20190613152755.GI32656@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613152755.GI32656@bombadil.infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 08:27:55AM -0700, Matthew Wilcox wrote:
> On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> > e.g. Process A has an exclusive layout lease on file F. It does an
> > IO to file F. The filesystem IO path checks that Process A owns the
> > lease on the file and so skips straight through layout breaking
> > because it owns the lease and is allowed to modify the layout. It
> > then takes the inode metadata locks to allocate new space and write
> > new data.
> > 
> > Process B now tries to write to file F. The FS checks whether
> > Process B owns a layout lease on file F. It doesn't, so then it
> > tries to break the layout lease so the IO can proceed. The layout
> > breaking code sees that process A has an exclusive layout lease
> > granted, and so returns -ETXTBSY to process B - it is not allowed to
> > break the lease and so the IO fails with -ETXTBSY.
> 
> This description doesn't match the behaviour that RDMA wants either.
> Even if Process A has a lease on the file, an IO from Process A which
> results in blocks being freed from the file is going to result in the
> RDMA device being able to write to blocks which are now freed (and
> potentially reallocated to another file).

I don't understand why this would not work for RDMA?  As long as the layout
does not change the page pins can remain in place.

Ira

