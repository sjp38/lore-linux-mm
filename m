Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FFF8C28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 16:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FA9120693
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 16:15:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FA9120693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C81406B027A; Thu,  6 Jun 2019 12:15:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C31016B027D; Thu,  6 Jun 2019 12:15:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B20AE6B027E; Thu,  6 Jun 2019 12:15:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7911C6B027A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 12:15:52 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j21so1631657pff.12
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 09:15:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xEoOsJCl9B7w4jWFHWKPrUHI08IrYTJNXsZHGapYT7w=;
        b=NHri8tsyAhJWXj+ByfoA7T4pgpvM8h1+dLfOIjGKgUIoO9btqBoeVT1dCJ0li2y2Ys
         xtXsSVNP7UL8LgqYfNlBcMnw18ryxiTpi/NXnnmZhWBb3lJRL9bRF7BkpbAeoMOtiuNW
         IVf4ZNXnk8ny+Le2mXpufOMItwFWstdKWbBH5Xyoo3Bwlz5i85i4goDUzp9aXKmyQ+Bf
         5+LdV5LVU3Smk26yHiu3qtWwsXDGoMhOE5Qm+p2jeDjeJCUn2YNS7ZCDlg7R5W7oCCnk
         akS3oho/hnxDb9q4EX9o9ljvbCb3ER62QVxx9crUv8L07rxcQl5KTbBaMgbplA8VIJP8
         rQhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUaFmA7ixOg5vQfrTCCDPRnf9sgbtdoaBYBIXBpedPF/xOXsNOp
	NPPJIpr8jE4AFY/R03J5DZPgNJ4EVnWIKwsLnKrINB2bPMHcFJFGfoGVhH7ht8Sw0RFH4zLy2ym
	IX/9DPY5u2VVENXWpQXHVaxEajgsb5Kj+3Lj54jwi92KQq0pFHtt9Y6usFPch46qNBw==
X-Received: by 2002:a63:4147:: with SMTP id o68mr4099896pga.76.1559837752144;
        Thu, 06 Jun 2019 09:15:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYmwZF30duZ7fUPK0CU6nJcpsuYtRZioTIKrKq4j9PMSoRd+MN5Pq5fCl+2OUUk2vDDIRN
X-Received: by 2002:a63:4147:: with SMTP id o68mr4099858pga.76.1559837751340;
        Thu, 06 Jun 2019 09:15:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559837751; cv=none;
        d=google.com; s=arc-20160816;
        b=irFiyQc3cn9VZLJj5PA/aq2zVnfjVd+m21Kp8A+0YCVA1nlicugbvrC8ydworTNxCj
         2FS8oWuw9PYPU20FBYSxj+RflFYqcfpVhW6lRM6pA3o6E6mF5QxvZbBdbMRl3H483Pnj
         jtaN8N9q3uQ5nNO4HoCgg2LArezzIUu/NUWS1IKA93xnpYI/y8JIbCLvn1982zPc5IQ9
         c17I2hvgMKmHtBpEKmrIPppjUHhHIyIOrShdRtJzYKPosPwRCSlWbUWgqWGV8WDRVcCV
         nWHJcS2SjvsqroPMiGg5bZsLb9Ng1YnnUA/7QzP/Gi3lQfyyJ85B9n/LdESDbn1Cb0gz
         gOwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xEoOsJCl9B7w4jWFHWKPrUHI08IrYTJNXsZHGapYT7w=;
        b=edla/odwee7fYUQrb5ptmx2GYwz7AU9t2P3MkJrKCNLILNoneFTSoSffD7BPDcfkBF
         eCnyDDbIHQ26GNnEZaINPh9H8JErAKBRkydRLNrQ52N2LmWRuRxXtBZM6PjF0CnVVDcj
         i6zNCpwFoMzbcRN66bq3zJRBSTpIa9d9GkuNtbDug+kV8MK59rGYf96e4JESfY+3EtZ2
         VCyepMPw64MI1JOvg4bk1+LxY/9mLT2UshCnoV2EDogdafCiinLm9D/DY1ku0kGoipWe
         /lTO8tUV+tDu61K94ALs/UseL4t4yEzgn8CwYcNXQgX9MpxRL7uGqAIub96957tkSAja
         HQoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id w16si2332099pgf.138.2019.06.06.09.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 09:15:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 09:15:50 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga006.fm.intel.com with ESMTP; 06 Jun 2019 09:15:50 -0700
Date: Thu, 6 Jun 2019 09:17:02 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Theodore Ts'o <tytso@mit.edu>,
	Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 07/10] fs/ext4: Fail truncate if pages are GUP pinned
Message-ID: <20190606161702.GA11374@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606014544.8339-8-ira.weiny@intel.com>
 <20190606105855.GG7433@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606105855.GG7433@quack2.suse.cz>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 12:58:55PM +0200, Jan Kara wrote:
> On Wed 05-06-19 18:45:40, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > If pages are actively gup pinned fail the truncate operation.
> > 
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > ---
> >  fs/ext4/inode.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> > index 75f543f384e4..1ded83ec08c0 100644
> > --- a/fs/ext4/inode.c
> > +++ b/fs/ext4/inode.c
> > @@ -4250,6 +4250,9 @@ int ext4_break_layouts(struct inode *inode, loff_t offset, loff_t len)
> >  		if (!page)
> >  			return 0;
> >  
> > +		if (page_gup_pinned(page))
> > +			return -ETXTBSY;
> > +
> >  		error = ___wait_var_event(&page->_refcount,
> >  				atomic_read(&page->_refcount) == 1,
> >  				TASK_INTERRUPTIBLE, 0, 0,
> 
> This caught my eye. Does this mean that now truncate for a file which has
> temporary gup users (such buffers for DIO) can fail with ETXTBUSY?

I thought about that before and I _thought_ I had accounted for it.  But I
think you are right...

>
> That
> doesn't look desirable.

No not desirable at all...  Ah it just dawned on my why I thought it was ok...
I was wrong.  :-/

> If we would mandate layout lease while pages are
> pinned as I suggested, this could be dealt with by checking for leases with
> pins (breaking such lease would return error and not break it) and if
> breaking leases succeeds (i.e., there are no long-term pinned pages), we'd
> just wait for the remaining references as we do now.

Agreed.

But I'm going to respond with some of the challenges of this (and ideas I had)
when replying to your other email.

Ira

> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

