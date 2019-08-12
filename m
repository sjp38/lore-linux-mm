Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58E4FC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 17:36:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 117D82067D
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 17:36:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 117D82067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 901376B0006; Mon, 12 Aug 2019 13:36:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B17F6B0007; Mon, 12 Aug 2019 13:36:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C68E6B0008; Mon, 12 Aug 2019 13:36:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0111.hostedemail.com [216.40.44.111])
	by kanga.kvack.org (Postfix) with ESMTP id 56EE76B0006
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:36:29 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E7B1C34A3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:36:28 +0000 (UTC)
X-FDA: 75814480056.24.apple23_3878a7965872f
X-HE-Tag: apple23_3878a7965872f
X-Filterd-Recvd-Size: 6342
Received: from mga01.intel.com (mga01.intel.com [192.55.52.88])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:36:27 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Aug 2019 10:36:26 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,378,1559545200"; 
   d="scan'208";a="194012289"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 12 Aug 2019 10:36:26 -0700
Date: Mon, 12 Aug 2019 10:36:26 -0700
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
Subject: Re: [RFC PATCH v2 01/19] fs/locks: Export F_LAYOUT lease to user
 space
Message-ID: <20190812173626.GB19746@iweiny-DESK2.sc.intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-2-ira.weiny@intel.com>
 <20190809235231.GC7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809235231.GC7777@dread.disaster.area>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 10, 2019 at 09:52:31AM +1000, Dave Chinner wrote:
> On Fri, Aug 09, 2019 at 03:58:15PM -0700, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > In order to support an opt-in policy for users to allow long term pins
> > of FS DAX pages we need to export the LAYOUT lease to user space.
> > 
> > This is the first of 2 new lease flags which must be used to allow a
> > long term pin to be made on a file.
> > 
> > After the complete series:
> > 
> > 0) Registrations to Device DAX char devs are not affected
> > 
> > 1) The user has to opt in to allowing page pins on a file with an exclusive
> >    layout lease.  Both exclusive and layout lease flags are user visible now.
> > 
> > 2) page pins will fail if the lease is not active when the file back page is
> >    encountered.
> > 
> > 3) Any truncate or hole punch operation on a pinned DAX page will fail.
> > 
> > 4) The user has the option of holding the lease or releasing it.  If they
> >    release it no other pin calls will work on the file.
> > 
> > 5) Closing the file is ok.
> > 
> > 6) Unmapping the file is ok
> > 
> > 7) Pins against the files are tracked back to an owning file or an owning mm
> >    depending on the internal subsystem needs.  With RDMA there is an owning
> >    file which is related to the pined file.
> > 
> > 8) Only RDMA is currently supported
> > 
> > 9) Truncation of pages which are not actively pinned nor covered by a lease
> >    will succeed.
> 
> This has nothing to do with layout leases or what they provide
> access arbitration over. Layout leases have _nothing_ to do with
> page pinning or RDMA - they arbitrate behaviour the file offset ->
> physical block device mapping within the filesystem and the
> behaviour that will occur when a specific lease is held.
> 
> The commit descripting needs to describe what F_LAYOUT actually
> protects, when they'll get broken, etc, not how RDMA is going to use
> it.

Ok yes I've been lax in mixing the cover letter for the series and this first
commit message.  My apologies.

> 
> > @@ -2022,8 +2030,26 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
> >  	struct file_lock *fl;
> >  	struct fasync_struct *new;
> >  	int error;
> > +	unsigned int flags = 0;
> > +
> > +	/*
> > +	 * NOTE on F_LAYOUT lease
> > +	 *
> > +	 * LAYOUT lease types are taken on files which the user knows that
> > +	 * they will be pinning in memory for some indeterminate amount of
> > +	 * time.
> 
> Indeed, layout leases have nothing to do with pinning of memory.

Yep, Fair enough.  I'll rework the comment.

> That's something an application taht uses layout leases might do,
> but it largely irrelevant to the functionality layout leases
> provide. What needs to be done here is explain what the layout lease
> API actually guarantees w.r.t. the physical file layout, not what
> some application is going to do with a lease. e.g.
> 
> 	The layout lease F_RDLCK guarantees that the holder will be
> 	notified that the physical file layout is about to be
> 	changed, and that it needs to release any resources it has
> 	over the range of this lease, drop the lease and then
> 	request it again to wait for the kernel to finish whatever
> 	it is doing on that range.
> 
> 	The layout lease F_RDLCK also allows the holder to modify
> 	the physical layout of the file. If an operation from the
> 	lease holder occurs that would modify the layout, that lease
> 	holder does not get notification that a change will occur,
> 	but it will block until all other F_RDLCK leases have been
> 	released by their holders before going ahead.
> 
> 	If there is a F_WRLCK lease held on the file, then a F_RDLCK
> 	holder will fail any operation that may modify the physical
> 	layout of the file. F_WRLCK provides exclusive physical
> 	modification access to the holder, guaranteeing nothing else
> 	will change the layout of the file while it holds the lease.
> 
> 	The F_WRLCK holder can change the physical layout of the
> 	file if it so desires, this will block while F_RDLCK holders
> 	are notified and release their leases before the
> 	modification will take place.
> 
> We need to define the semantics we expose to userspace first.....

Agreed.  I believe I have implemented the semantics you describe above.  Do I
have your permission to use your verbiage as part of reworking the comment and
commit message?

Thanks,
Ira

> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 

