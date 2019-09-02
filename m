Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9F4AC3A59E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 22:26:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A528520828
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 22:26:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A528520828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39FF46B0003; Mon,  2 Sep 2019 18:26:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 329466B0005; Mon,  2 Sep 2019 18:26:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F0B46B0006; Mon,  2 Sep 2019 18:26:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id EB7866B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 18:26:27 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8FA952C34
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 22:26:27 +0000 (UTC)
X-FDA: 75891415614.27.low88_1b2d3770a9c2a
X-HE-Tag: low88_1b2d3770a9c2a
X-Filterd-Recvd-Size: 6095
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au [211.29.132.246])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 22:26:26 +0000 (UTC)
Received: from dread.disaster.area (pa49-181-255-194.pa.nsw.optusnet.com.au [49.181.255.194])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 16DDF43D911;
	Tue,  3 Sep 2019 08:26:19 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1i4umA-0003Ym-4t; Tue, 03 Sep 2019 08:26:18 +1000
Date: Tue, 3 Sep 2019 08:26:18 +1000
From: Dave Chinner <david@fromorbit.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Theodore Ts'o <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
Message-ID: <20190902222618.GR1119@dread.disaster.area>
References: <20190821181343.GH8653@ziepe.ca>
 <20190821185703.GB5965@iweiny-DESK2.sc.intel.com>
 <20190821194810.GI8653@ziepe.ca>
 <20190821204421.GE5965@iweiny-DESK2.sc.intel.com>
 <20190823032345.GG1119@dread.disaster.area>
 <20190823120428.GA12968@ziepe.ca>
 <20190824001124.GI1119@dread.disaster.area>
 <20190824050836.GC1092@iweiny-DESK2.sc.intel.com>
 <20190826055510.GL1119@dread.disaster.area>
 <20190829020230.GA18249@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190829020230.GA18249@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0
	a=YO9NNpcXwc8z/SaoS+iAiA==:117 a=YO9NNpcXwc8z/SaoS+iAiA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=J70Eh1EUuV4A:10
	a=7-415B0cAAAA:8 a=uquYBjWIGtznz3R1yhAA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 07:02:31PM -0700, Ira Weiny wrote:
> On Mon, Aug 26, 2019 at 03:55:10PM +1000, Dave Chinner wrote:
> > On Fri, Aug 23, 2019 at 10:08:36PM -0700, Ira Weiny wrote:
> > > On Sat, Aug 24, 2019 at 10:11:24AM +1000, Dave Chinner wrote:
> > > > On Fri, Aug 23, 2019 at 09:04:29AM -0300, Jason Gunthorpe wrote:
> > > "Leases are associated with an open file description (see open(2)).  This means
> > > that duplicate file descriptors (created by, for example, fork(2) or dup(2))
> > > refer to the same lease, and this lease may be modified or released using any
> > > of these descriptors.  Furthermore,  the lease is released by either an
> > > explicit F_UNLCK operation on any of these duplicate file descriptors, or when
> > > all such file descriptors have been closed."
> > 
> > Right, the lease is attached to the struct file, so it follows
> > where-ever the struct file goes. That doesn't mean it's actually
> > useful when the struct file is duplicated and/or passed to another
> > process. :/
> > 
> > AFAICT, the problem is that when we take another reference to the
> > struct file, or when the struct file is passed to a different
> > process, nothing updates the lease or lease state attached to that
> > struct file.
> 
> Ok, I probably should have made this more clear in the cover letter but _only_
> the process which took the lease can actually pin memory.

Sure, no question about that.

> That pinned memory _can_ be passed to another process but those sub-process' can
> _not_ use the original lease to pin _more_ of the file.  They would need to
> take their own lease to do that.

Yes, they would need a new lease to extend it. But that ignores the
fact they don't have a lease on the existing pins they are using and
have no control over the lease those pins originated under.  e.g.
the originating process dies (for whatever reason) and now we have
pins without a valid lease holder.

If something else now takes an exclusive lease on the file (because
the original exclusive lease no longer exists), it's not going to
work correctly because of the zombied page pins caused by closing
the exclusive lease they were gained under. IOWs, pages pinned under
an exclusive lease are no longer "exclusive" the moment the original
exclusive lease is dropped, and pins passed to another process are
no longer covered by the original lease they were created under.

> Sorry for not being clear on that.

I know exactly what you are saying. What I'm failing to get across
is that file layout leases don't actually allow the behaviour you
want to have.

> > As such, leases that require callbacks to userspace are currently
> > only valid within the process context the lease was taken in.
> 
> But for long term pins we are not requiring callbacks.

Regardless, we still require an active lease for long term pins so
that other lease holders fail operations appropriately. And that
exclusive lease must follow the process that pins the pages so that
the life cycle is the same...

> > Indeed, even closing the fd the lease was taken on without
> > F_UNLCKing it first doesn't mean the lease has been torn down if
> > there is some other reference to the struct file. That means the
> > original lease owner will still get SIGIO delivered to that fd on a
> > lease break regardless of whether it is open or not. ANd if we
> > implement "layout lease not released within SIGIO response timeout"
> > then that process will get killed, despite the fact it may not even
> > have a reference to that file anymore.
> 
> I'm not seeing that as a problem.  This is all a result of the application
> failing to do the right thing.

How is that not a problem?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

