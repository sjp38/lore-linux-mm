Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81242C3A59E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 22:25:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ED20208E4
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 22:25:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ED20208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA9526B0007; Wed,  4 Sep 2019 18:25:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D31846B0008; Wed,  4 Sep 2019 18:25:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD1B46B000A; Wed,  4 Sep 2019 18:25:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0252.hostedemail.com [216.40.44.252])
	by kanga.kvack.org (Postfix) with ESMTP id 94FBA6B0007
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 18:25:54 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 29738181AC9AE
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 22:25:54 +0000 (UTC)
X-FDA: 75898671828.17.toad74_8ab1b6711a451
X-HE-Tag: toad74_8ab1b6711a451
X-Filterd-Recvd-Size: 4504
Received: from mga06.intel.com (mga06.intel.com [134.134.136.31])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 22:25:52 +0000 (UTC)
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Sep 2019 15:25:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,468,1559545200"; 
   d="scan'208";a="185252801"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 04 Sep 2019 15:25:50 -0700
Date: Wed, 4 Sep 2019 15:25:50 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 16/19] RDMA/uverbs: Add back pointer to system
 file object
Message-ID: <20190904222549.GC31319@iweiny-DESK2.sc.intel.com>
References: <20190809225833.6657-17-ira.weiny@intel.com>
 <20190812130039.GD24457@ziepe.ca>
 <20190812172826.GA19746@iweiny-DESK2.sc.intel.com>
 <20190812175615.GI24457@ziepe.ca>
 <20190812211537.GE20634@iweiny-DESK2.sc.intel.com>
 <20190813114842.GB29508@ziepe.ca>
 <20190813174142.GB11882@iweiny-DESK2.sc.intel.com>
 <20190813180022.GF29508@ziepe.ca>
 <20190813203858.GA12695@iweiny-DESK2.sc.intel.com>
 <20190814122308.GB13770@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814122308.GB13770@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 09:23:08AM -0300, Jason Gunthorpe wrote:
> On Tue, Aug 13, 2019 at 01:38:59PM -0700, Ira Weiny wrote:
> > On Tue, Aug 13, 2019 at 03:00:22PM -0300, Jason Gunthorpe wrote:
> > > On Tue, Aug 13, 2019 at 10:41:42AM -0700, Ira Weiny wrote:
> > > 
> > > > And I was pretty sure uverbs_destroy_ufile_hw() would take care of (or ensure
> > > > that some other thread is) destroying all the MR's we have associated with this
> > > > FD.
> > > 
> > > fd's can't be revoked, so destroy_ufile_hw() can't touch them. It
> > > deletes any underlying HW resources, but the FD persists.
> > 
> > I misspoke.  I should have said associated with this "context".  And of course
> > uverbs_destroy_ufile_hw() does not touch the FD.  What I mean is that the
> > struct file which had file_pins hanging off of it would be getting its file
> > pins destroyed by uverbs_destroy_ufile_hw().  Therefore we don't need the FD
> > after uverbs_destroy_ufile_hw() is done.
> > 
> > But since it does not block it may be that the struct file is gone before the
> > MR is actually destroyed.  Which means I think the GUP code would blow up in
> > that case...  :-(
> 
> Oh, yes, that is true, you also can't rely on the struct file living
> longer than the HW objects either, that isn't how the lifetime model
> works.

Reviewing all these old threads...  And this made me think.  While the HW
objects may out live the struct file.

They _are_ going away in a finite amount of time right?  It is not like they
could be held forever right?

Ira

> 
> If GUP consumes the struct file it must allow the struct file to be
> deleted before the GUP pin is released.
> 
> > The drivers could provide some generic object (in RDMA this could be the
> > uverbs_attr_bundle) which represents their "context".
> 
> For RDMA the obvious context is the struct ib_mr *
> 
> > But for the procfs interface, that context then needs to be associated with any
> > file which points to it...  For RDMA, or any other "FD based pin mechanism", it
> > would be up to the driver to "install" a procfs handler into any struct file
> > which _may_ point to this context.  (before _or_ after memory pins).
> 
> Is this all just for debugging? Seems like a lot of complication just
> to print a string
> 
> Generally, I think you'd be better to associate things with the
> mm_struct not some struct file... The whole design is simpler as GUP
> already has the mm_struct.
> 
> Jason

