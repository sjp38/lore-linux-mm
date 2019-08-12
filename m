Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83CA9C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 18:05:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D7CB20663
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 18:05:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D7CB20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCCA26B0008; Mon, 12 Aug 2019 14:05:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7F076B000A; Mon, 12 Aug 2019 14:05:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6B076B000C; Mon, 12 Aug 2019 14:05:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id A4D936B0008
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:05:55 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 3A62C181AC9B4
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:05:55 +0000 (UTC)
X-FDA: 75814554270.04.plot94_16533154df95d
X-HE-Tag: plot94_16533154df95d
X-Filterd-Recvd-Size: 4819
Received: from mga17.intel.com (mga17.intel.com [192.55.52.151])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:05:53 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Aug 2019 11:05:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,378,1559545200"; 
   d="scan'208";a="177558391"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 12 Aug 2019 11:05:51 -0700
Date: Mon, 12 Aug 2019 11:05:51 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 07/19] fs/xfs: Teach xfs to use new
 dax_layout_busy_page()
Message-ID: <20190812180551.GC19746@iweiny-DESK2.sc.intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-8-ira.weiny@intel.com>
 <20190809233037.GB7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809233037.GB7777@dread.disaster.area>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 10, 2019 at 09:30:37AM +1000, Dave Chinner wrote:
> On Fri, Aug 09, 2019 at 03:58:21PM -0700, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > dax_layout_busy_page() can now operate on a sub-range of the
> > address_space provided.
> > 
> > Have xfs specify the sub range to dax_layout_busy_page()
> 
> Hmmm. I've got patches that change all these XFS interfaces to
> support range locks. I'm not sure the way the ranges are passed here
> is the best way to do it, and I suspect they aren't correct in some
> cases, either....
> 
> > diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
> > index ff3c1fae5357..f0de5486f6c1 100644
> > --- a/fs/xfs/xfs_iops.c
> > +++ b/fs/xfs/xfs_iops.c
> > @@ -1042,10 +1042,16 @@ xfs_vn_setattr(
> >  		xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
> >  		iolock = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
> >  
> > -		error = xfs_break_layouts(inode, &iolock, BREAK_UNMAP);
> > -		if (error) {
> > -			xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
> > -			return error;
> > +		if (iattr->ia_size < inode->i_size) {
> > +			loff_t                  off = iattr->ia_size;
> > +			loff_t                  len = inode->i_size - iattr->ia_size;
> > +
> > +			error = xfs_break_layouts(inode, &iolock, off, len,
> > +						  BREAK_UNMAP);
> > +			if (error) {
> > +				xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
> > +				return error;
> > +			}
> 
> This isn't right - truncate up still needs to break the layout on
> the last filesystem block of the file,

I'm not following this?  From a user perspective they can't have done anything
with the data beyond the EOF.  So isn't it safe to allow EOF to grow without
changing the layout of that last block?

> and truncate down needs to
> extend to "maximum file offset" because we remove all extents beyond
> EOF on a truncate down.

Ok, I was trying to allow a user to extend the file without conflicts if they
were to have a pin on the 'beginning' of the original file.  This sounds like
you are saying that a layout lease must be dropped to do that?  In some ways I
think I understand what you are driving at and I think I see how I may have
been playing "fast and loose" with the strictness of the layout lease.  But
from a user perspective if there is a part of the file which "does not exist"
(beyond EOF) does it matter that the layout there may change?

> 
> i.e. when we use preallocation, the extent map extends beyond EOF,
> and layout leases need to be able to extend beyond the current EOF
> to allow the lease owner to do extending writes, extending truncate,
> preallocation beyond EOF, etc safely without having to get a new
> lease to cover the new region in the extended file...

I'm not following this.  What determines when preallocation is done?

Forgive my ignorance on file systems but how can we have a layout for every
file which is "maximum file offset" for every file even if a file is only 1
page long?

Thanks,
Ira

> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

