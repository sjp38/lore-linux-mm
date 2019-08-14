Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 586F1C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 10:17:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A9362067D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 10:17:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A9362067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 952486B0005; Wed, 14 Aug 2019 06:17:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9030B6B0006; Wed, 14 Aug 2019 06:17:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F16C6B0007; Wed, 14 Aug 2019 06:17:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0117.hostedemail.com [216.40.44.117])
	by kanga.kvack.org (Postfix) with ESMTP id 55AA76B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 06:17:18 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B9BC834A1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:17:17 +0000 (UTC)
X-FDA: 75820630914.06.geese80_79d8b70b3fb37
X-HE-Tag: geese80_79d8b70b3fb37
X-Filterd-Recvd-Size: 4455
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:17:17 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6A4C8AC8C;
	Wed, 14 Aug 2019 10:17:15 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id B08BB1E4200; Wed, 14 Aug 2019 12:17:14 +0200 (CEST)
Date: Wed, 14 Aug 2019 12:17:14 +0200
From: Jan Kara <jack@suse.cz>
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
Message-ID: <20190814101714.GA26273@quack2.suse.cz>
References: <20190809225833.6657-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809225833.6657-1-ira.weiny@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello!

On Fri 09-08-19 15:58:14, ira.weiny@intel.com wrote:
> Pre-requisites
> ==============
> 	Based on mmotm tree.
> 
> Based on the feedback from LSFmm, the LWN article, the RFC series since
> then, and a ton of scenarios I've worked in my mind and/or tested...[1]
> 
> Solution summary
> ================
> 
> The real issue is that there is no use case for a user to have RDMA pinn'ed
> memory which is then truncated.  So really any solution we present which:
> 
> A) Prevents file system corruption or data leaks
> ...and...
> B) Informs the user that they did something wrong
> 
> Should be an acceptable solution.
> 
> Because this is slightly new behavior.  And because this is going to be
> specific to DAX (because of the lack of a page cache) we have made the user
> "opt in" to this behavior.
> 
> The following patches implement the following solution.
> 
> 0) Registrations to Device DAX char devs are not affected
> 
> 1) The user has to opt in to allowing page pins on a file with an exclusive
>    layout lease.  Both exclusive and layout lease flags are user visible now.
> 
> 2) page pins will fail if the lease is not active when the file back page is
>    encountered.
> 
> 3) Any truncate or hole punch operation on a pinned DAX page will fail.

So I didn't fully grok the patch set yet but by "pinned DAX page" do you
mean a page which has corresponding file_pin covering it? Or do you mean a
page which has pincount increased? If the first then I'd rephrase this to
be less ambiguous, if the second then I think it is wrong. 

> 4) The user has the option of holding the lease or releasing it.  If they
>    release it no other pin calls will work on the file.

Last time we spoke the plan was that the lease is kept while the pages are
pinned (and an attempt to release the lease would block until the pages are
unpinned). That also makes it clear that the *lease* is what is making
truncate and hole punch fail with ETXTBUSY and the file_pin structure is
just an implementation detail how the existence is efficiently tracked (and
what keeps the backing file for the pages open so that the lease does not
get auto-destroyed). Why did you change this?

> 5) Closing the file is ok.
> 
> 6) Unmapping the file is ok
> 
> 7) Pins against the files are tracked back to an owning file or an owning mm
>    depending on the internal subsystem needs.  With RDMA there is an owning
>    file which is related to the pined file.
> 
> 8) Only RDMA is currently supported

If you currently only need "owning file" variant in your patch set, then
I'd just implement that and leave "owning mm" variant for later if it
proves to be necessary. The things are complex enough as is...

> 9) Truncation of pages which are not actively pinned nor covered by a lease
>    will succeed.

Otherwise I like the design.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

