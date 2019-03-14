Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D90A7C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:06:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81DCB205F4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:06:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81DCB205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2C588E0003; Thu, 14 Mar 2019 05:06:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDAD28E0001; Thu, 14 Mar 2019 05:06:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCBEA8E0003; Thu, 14 Mar 2019 05:06:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 827988E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 05:06:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r7so2060088eds.18
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 02:06:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6wK+0HtmkpcTjpCOl+sT4piptRFHUY1gGFuPVst64Ek=;
        b=bF674M7bh8vs2rTHQoIl05z5Y79a8SaEewH3Vdw9JlgPAk9bTatOOcnoFCefa90cL1
         41J+KdK8cVkNqzi97bKsxd7/hw3UDFMGgQE/qNxIxRukxqag7exgllMfNM0AiONuxSla
         Uzbu3edGkCKf1CzMYj9OpyGTXOW0Xez6Y1MvLSNNXwCDt7mLoqFHAQYyT4PTekW2ZMjp
         8A68LeNDXLeGRiHRW9+lWUkghqseCzve3NHuAtMEysbQzcrcXtK1lq0C9wR+ZPGQhd4u
         Atltb62iOsxcsumB/vVTsNtAJRkFBLj5JVTehwRLAXbWvtGi5Ki0f+ziwznXRFfKvLYc
         yIlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXPZZk1MZlbhHJ5K58yNM5OV0p5UOELoIHLh2zOzvRptaEVbiS7
	ONiUuUxjLM/v4Ply/tdX/bR3t5maKGRm1hNMAxhFoEeEuDfLnmYxcWZkV9pKOyUmhSf6djorLvs
	GitLccQ0nUS9Aa0VEUbR6UgX1H0lD2SknJSDZL5txKUmdBpy0ZFEv7FBvS2QDMxhfNQ==
X-Received: by 2002:a17:906:2969:: with SMTP id x9mr30950088ejd.223.1552554397098;
        Thu, 14 Mar 2019 02:06:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9Hvz5FTk8NqZS7QzuKv9GkoEsNebofQBckISu2IXz7LeU9NTOWEgmkRtMBh1fvK0hpcN8
X-Received: by 2002:a17:906:2969:: with SMTP id x9mr30950041ejd.223.1552554396299;
        Thu, 14 Mar 2019 02:06:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552554396; cv=none;
        d=google.com; s=arc-20160816;
        b=LVq4u+SM6JCS6FRF2p5/vREjxN/8Z88CPhnUegw3muTKHrYwrKaITgrKbzkxtPMJvj
         NStRis0K0OEa0/uRfaVLtWBrfD7Uv3ftN46i01pF/+MBF5uFLcq0jLH+5axBqJTdETbI
         GG0tXjZrKQsF5Dpccpy/JyxL4TPdskJ4iK4daL6iOm/WR0jvpX+WJFDB2RjdK6w6t6PU
         lMaXMU76ykKOazsBJ3spZmBDGMNzwX/W64PHPGpQUQbFaMD6QnH1/DVtQakk6/JhPPKn
         AAEjMz4fvAm7nYUOaSWRoQaILiA6KxGq7T1pYvC6BfKTdhumTFnJ2UcVqlKEbfRB5Sf7
         X+Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6wK+0HtmkpcTjpCOl+sT4piptRFHUY1gGFuPVst64Ek=;
        b=UpTv7wYK8JZoJF+aE11TE+wNILYQe7wZl4PBtdSkcvRUPGqeMMkIbaeWFF+TjXzk9R
         XkbouKoGAaZHnxONDPqqTv398nFk8HGPvwTS5ZHzB3bjhWqqRhfOftfoAzjH4grVDz66
         DW2/qu6npxC/FE8rdX5N2+LEm6Othwmw5eNRL6ed/KCwxhzP0RYhmw9VwYfwidzYsV92
         uo36v5zRBiIDmED5iCO81oNO3IR4ox/uDp+5FuX6Avu03kmsNhjToFdvr93vJT6m4fSb
         EU6shaMyPx+aTN5YHbE2FGjYyn+R+9qUvX+E+QXWLyyqcEw0rmtnkhkxCGy/fsHhIKCJ
         HQZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f16si1052514ejf.304.2019.03.14.02.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 02:06:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A2D92AEA3;
	Thu, 14 Mar 2019 09:06:35 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 49D8B1E3FE8; Thu, 14 Mar 2019 10:06:35 +0100 (CET)
Date: Thu, 14 Mar 2019 10:06:35 +0100
From: Jan Kara <jack@suse.cz>
To: Christopher Lameter <cl@linux.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dave Chinner <david@fromorbit.com>, Ira Weiny <ira.weiny@intel.com>,
	john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190314090635.GC16658@quack2.suse.cz>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190310224742.GK26298@dastard>
 <01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@email.amazonses.com>
 <20190312103932.GD1119@iweiny-DESK2.sc.intel.com>
 <20190312221113.GF23020@dastard>
 <20190313160319.GA15134@infradead.org>
 <010001697880bfdc-4503d0dd-03cd-4c91-84a0-c18af1eab145-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001697880bfdc-4503d0dd-03cd-4c91-84a0-c18af1eab145-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-03-19 19:21:37, Christopher Lameter wrote:
> On Wed, 13 Mar 2019, Christoph Hellwig wrote:
> 
> > On Wed, Mar 13, 2019 at 09:11:13AM +1100, Dave Chinner wrote:
> > > On Tue, Mar 12, 2019 at 03:39:33AM -0700, Ira Weiny wrote:
> > > > IMHO I don't think that the copy_file_range() is going to carry us through the
> > > > next wave of user performance requirements.  RDMA, while the first, is not the
> > > > only technology which is looking to have direct access to files.  XDP is
> > > > another.[1]
> > >
> > > Sure, all I doing here was demonstrating that people have been
> > > trying to get local direct access to file mappings to DMA directly
> > > into them for a long time. Direct Io games like these are now
> > > largely unnecessary because we now have much better APIs to do
> > > zero-copy data transfer between files (which can do hardware offload
> > > if it is available!).
> >
> > And that is just the file to file case.  There are tons of other
> > users of get_user_pages, including various drivers that do large
> > amounts of I/O like video capture.  For them it makes tons of sense
> > to transfer directly to/from a mmap()ed file.
> 
> That is very similar to the RDMA case and DAX etc. We need to have a way
> to tell a filesystem that this is going to happen and that things need to
> be setup for this to work properly.

The way to tell filesystem what's happening is exactly what we are working
on with these patches...

> But if that has not been done then I think its proper to fail a long term
> pin operation on page cache pages. Meaning the regular filesystems
> maintain control of whats happening with their pages.

And as I mentioned in my other email, we cannot just fail the pin for
pagecache pages as that would regress existing applications.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

