Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE35AC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 18:08:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB4482067D
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 18:08:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB4482067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A26E6B000C; Mon, 12 Aug 2019 14:08:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42C1E6B000E; Mon, 12 Aug 2019 14:08:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 319916B0010; Mon, 12 Aug 2019 14:08:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id 09D586B000C
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:08:45 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AC076180AD7C3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:08:44 +0000 (UTC)
X-FDA: 75814561368.21.sense51_2f20ba6f0371c
X-HE-Tag: sense51_2f20ba6f0371c
X-Filterd-Recvd-Size: 3424
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:08:43 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Aug 2019 11:08:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,378,1559545200"; 
   d="scan'208";a="175965853"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 12 Aug 2019 11:08:42 -0700
Date: Mon, 12 Aug 2019 11:08:42 -0700
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
Subject: Re: [RFC PATCH v2 08/19] fs/xfs: Fail truncate if page lease can't
 be broken
Message-ID: <20190812180841.GD19746@iweiny-DESK2.sc.intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-9-ira.weiny@intel.com>
 <20190809232209.GA7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809232209.GA7777@dread.disaster.area>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 10, 2019 at 09:22:09AM +1000, Dave Chinner wrote:
> On Fri, Aug 09, 2019 at 03:58:22PM -0700, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > If pages are under a lease fail the truncate operation.  We change the order of
> > lease breaks to directly fail the operation if the lease exists.
> > 
> > Select EXPORT_BLOCK_OPS for FS_DAX to ensure that xfs_break_lease_layouts() is
> > defined for FS_DAX as well as pNFS.
> > 
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > ---
> >  fs/Kconfig        | 1 +
> >  fs/xfs/xfs_file.c | 5 +++--
> >  2 files changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/Kconfig b/fs/Kconfig
> > index 14cd4abdc143..c10b91f92528 100644
> > --- a/fs/Kconfig
> > +++ b/fs/Kconfig
> > @@ -48,6 +48,7 @@ config FS_DAX
> >  	select DEV_PAGEMAP_OPS if (ZONE_DEVICE && !FS_DAX_LIMITED)
> >  	select FS_IOMAP
> >  	select DAX
> > +	select EXPORTFS_BLOCK_OPS
> >  	help
> >  	  Direct Access (DAX) can be used on memory-backed block devices.
> >  	  If the block device supports DAX and the filesystem supports DAX,
> 
> That looks wrong.

It may be...

>
> If you require xfs_break_lease_layouts() outside
> of pnfs context, then move the function in the XFS code base to a
> file that is built in. It's only external dependency is on the
> break_layout() function, and XFS already has other unconditional
> direct calls to break_layout()...

I'll check.  This patch was part of the original series and I must admit I
don't remember why I did it this way...

Thanks,
Ira

> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

