Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03058C3A5A1
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 21:53:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4B1C22CEC
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 21:53:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4B1C22CEC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6551B6B0005; Mon, 19 Aug 2019 17:53:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DE396B0006; Mon, 19 Aug 2019 17:53:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CC5D6B0007; Mon, 19 Aug 2019 17:53:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0220.hostedemail.com [216.40.44.220])
	by kanga.kvack.org (Postfix) with ESMTP id 2496F6B0005
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 17:53:28 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 91BF3181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:53:27 +0000 (UTC)
X-FDA: 75840529254.29.net37_5845d837b4d5e
X-HE-Tag: net37_5845d837b4d5e
X-Filterd-Recvd-Size: 3477
Received: from mga17.intel.com (mga17.intel.com [192.55.52.151])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:53:26 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Aug 2019 14:53:24 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,406,1559545200"; 
   d="scan'208";a="189658795"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 19 Aug 2019 14:53:23 -0700
Date: Mon, 19 Aug 2019 14:53:23 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Theodore Ts'o <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
Message-ID: <20190819215322.GA2839@iweiny-DESK2.sc.intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190814101714.GA26273@quack2.suse.cz>
 <20190814180848.GB31490@iweiny-DESK2.sc.intel.com>
 <20190815130558.GF14313@quack2.suse.cz>
 <20190816190528.GB371@iweiny-DESK2.sc.intel.com>
 <20190817022603.GW6129@dread.disaster.area>
 <20190819063412.GA20455@quack2.suse.cz>
 <20190819092409.GM7777@dread.disaster.area>
 <20190819123841.GC5058@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190819123841.GC5058@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 09:38:41AM -0300, Jason Gunthorpe wrote:
> On Mon, Aug 19, 2019 at 07:24:09PM +1000, Dave Chinner wrote:
> 
> > So that leaves just the normal close() syscall exit case, where the
> > application has full control of the order in which resources are
> > released. We've already established that we can block in this
> > context.  Blocking in an interruptible state will allow fatal signal
> > delivery to wake us, and then we fall into the
> > fatal_signal_pending() case if we get a SIGKILL while blocking.
> 
> The major problem with RDMA is that it doesn't always wait on close() for the
> MR holding the page pins to be destoyed. This is done to avoid a
> deadlock of the form:
> 
>    uverbs_destroy_ufile_hw()
>       mutex_lock()
>        [..]
>         mmput()
>          exit_mmap()
>           remove_vma()
>            fput();
>             file_operations->release()
>              ib_uverbs_close()
>               uverbs_destroy_ufile_hw()
>                mutex_lock()   <-- Deadlock
> 
> But, as I said to Ira earlier, I wonder if this is now impossible on
> modern kernels and we can switch to making the whole thing
> synchronous. That would resolve RDMA's main problem with this.

I'm still looking into this...  but my bigger concern is that the RDMA FD can
be passed to other processes via SCM_RIGHTS.  Which means the process holding
the pin may _not_ be the one with the open file and layout lease...

Ira


