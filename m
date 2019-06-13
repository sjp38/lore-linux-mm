Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6985BC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:32:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FEE320B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:32:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FEE320B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5B038E0003; Thu, 13 Jun 2019 16:32:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABDF68E0002; Thu, 13 Jun 2019 16:32:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 939298E0003; Thu, 13 Jun 2019 16:32:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 541328E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:32:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so104899pfj.4
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:32:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zl/UA/QPYBw5r2Ettcv2SxxCFIZJZLqhjIW6qPVfYBg=;
        b=ReM88oo+nDGteKSagTPel1JssCOex0lLawb7Dj2nrIsN+aNnx0YUmx4LJS1bOsB81S
         1yVJ9DX6kc9q00eY1O5Y2kHSQ9Nnh3E+TVb1LIV+/TafiS9rNKQkM6lT9itdaoS/jheT
         7DZrjn9yKbo/ZTgrdEDYYfNI3zqa0c/xTOaWZaQiotXIlcRPPbgtdhvC+fRUYxsYD7X4
         bGXuyAvIk+vJInx5IjxDHou78+wL7Y5vHRJ2+XdATqWoau+LWRnL/bH8ZegAC9QFetSu
         slZN4Qw4dO7tYIHI6V9hJnu8hm56On1eJGv7k9PGpDtHol635jT+HLaPszeQq2QzaYhy
         adtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVjyITArRftJpwDziTuo/ADKb/owvi0MtIwwPTVBN+8gZAyCk0X
	OqlfdCkf42zFfekWNYh9LwmrUpmUC+2zzk5H1VzZ4Kz974enif2VsIwpf35T28Ap5XXxMgdTVIL
	EamC3iVLMdKI8SXX32hTnRYMyaDjFsQjqP5ihbUJrSBVvJKw8+Sn2JW9inW19282wuA==
X-Received: by 2002:a17:902:f204:: with SMTP id gn4mr71552578plb.3.1560457966975;
        Thu, 13 Jun 2019 13:32:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKciwGsH9u2eHv3XNsMuZt47wuvqA2AXfyqUEueoh5zoifQE+fm54WrrgFv00t+zfsKbcv
X-Received: by 2002:a17:902:f204:: with SMTP id gn4mr71552514plb.3.1560457966053;
        Thu, 13 Jun 2019 13:32:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560457966; cv=none;
        d=google.com; s=arc-20160816;
        b=cpdpBUJsjY0o9GSgg9NbNwStGyJwrO1HwdBYEQFsUftaTfGtSyheBki7a8h/trquNl
         WntwNJYqkhH1KFz0APa/SkYf0sH/iFIJxjcnPdIJAMp0CCq6dLNU+3NQOs0syssI6kYC
         K9hnv/V/ZexcWZnqPdvpnAvb/YuvVxg3h1D/5t9OPHmhhmtC4zyUKtXC3FOu7uVbAFK4
         1P8h/r3YUnuTeVJPwpEElZhrVGYUSTHX2EtcsmW8JuuN9v/Ae65DpXLagMb5KXZ9l74I
         /qwIJGyWoWFp1Co822Gz/IZMM7y7p8xxsccP2UVjZ/zKQlcHTB5PaJL8Nu9PzBIeAeV7
         IxeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zl/UA/QPYBw5r2Ettcv2SxxCFIZJZLqhjIW6qPVfYBg=;
        b=CF8GGA9oQikwV8B0Ve22/wWuSRrs+1/5mSgzqbraZu3aqmokf0+oEaAg0S7pnWdpbE
         r9/Q2y7tXF8UMaCD3osDyVwFn1bcF14URBBuyNoQW6tJQM3c+VBs6IYmEWlRxJDLOWAh
         7MtCW1/GcXqSsnEEorKtszE9R5HVmyQNNM8dwv+WrxmYBrKSKuaFFJI8NiDgeFDx/qWw
         eleFZEGHmsNx0salp12mqHJK6OC4ulRoTj717nkajEO6W739dy/bSSizHXqRP/eETEvB
         AWo1WP1f3wiQYrhAFyMtD9U3EizvSXi9FpGcjdLbxC9EAz6Js0jovDSfy7T2UOrCMrte
         SaIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h16si445670pfn.162.2019.06.13.13.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 13:32:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 13:32:46 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 13 Jun 2019 13:32:45 -0700
Date: Thu, 13 Jun 2019 13:34:06 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
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
Message-ID: <20190613203406.GB32404@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190612233024.GD14336@iweiny-DESK2.sc.intel.com>
 <20190613005552.GI14363@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613005552.GI14363@dread.disaster.area>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 10:55:52AM +1000, Dave Chinner wrote:
> On Wed, Jun 12, 2019 at 04:30:24PM -0700, Ira Weiny wrote:
> > On Wed, Jun 12, 2019 at 05:37:53AM -0700, Matthew Wilcox wrote:
> > > On Sat, Jun 08, 2019 at 10:10:36AM +1000, Dave Chinner wrote:
> > > > On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:
> > > > > Are you suggesting that we have something like this from user space?
> > > > > 
> > > > > 	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);
> > > > 
> > > > Rather than "unbreakable", perhaps a clearer description of the
> > > > policy it entails is "exclusive"?
> > > > 
> > > > i.e. what we are talking about here is an exclusive lease that
> > > > prevents other processes from changing the layout. i.e. the
> > > > mechanism used to guarantee a lease is exclusive is that the layout
> > > > becomes "unbreakable" at the filesystem level, but the policy we are
> > > > actually presenting to uses is "exclusive access"...
> > > 
> > > That's rather different from the normal meaning of 'exclusive' in the
> > > context of locks, which is "only one user can have access to this at
> > > a time".  As I understand it, this is rather more like a 'shared' or
> > > 'read' lock.  The filesystem would be the one which wants an exclusive
> > > lock, so it can modify the mapping of logical to physical blocks.
> > > 
> > > The complication being that by default the filesystem has an exclusive
> > > lock on the mapping, and what we're trying to add is the ability for
> > > readers to ask the filesystem to give up its exclusive lock.
> > 
> > This is an interesting view...
> > 
> > And after some more thought, exclusive does not seem like a good name for this
> > because technically F_WRLCK _is_ an exclusive lease...
> > 
> > In addition, the user does not need to take the "exclusive" write lease to be
> > notified of (broken by) an unexpected truncate.  A "read" lease is broken by
> > truncate.  (And "write" leases really don't do anything different WRT the
> > interaction of the FS and the user app.  Write leases control "exclusive"
> > access between other file descriptors.)
> 
> I've been assuming that there is only one type of layout lease -
> there is no use case I've heard of for read/write layout leases, and
> like you say there is zero difference in behaviour at the filesystem
> level - they all have to be broken to allow a non-lease truncate to
> proceed.
> 
> IMO, taking a "read lease" to be able to modify and write to the
> underlying mapping of a file makes absolutely no sense at all.
> IOWs, we're talking exaclty about a revokable layout lease vs an
> exclusive layout lease here, and so read/write really doesn't match
> the policy or semantics we are trying to provide.

I humbly disagree, at least depending on how you look at it...  :-D

The patches as they stand expect the user to take a "read" layout lease which
indicates they are currently using "reading" the layout as is.  They are not
changing ("writing" to) the layout.  They then pin pages which locks parts of
the layout and therefore they expect no "writers" to change the layout.

The "write" layout lease breaks the "read" layout lease indicating that the
layout is being written to.  Should the layout be pinned in such a way that the
layout can't be changed the "layout writer" (truncate) fails.

In fact, this is what NFS does right now.  The lease it puts on the file is of
"read" type.

nfs4layouts.c:
static int
nfsd4_layout_setlease(struct nfs4_layout_stateid *ls)
{
...
        fl->fl_flags = FL_LAYOUT;
        fl->fl_type = F_RDLCK;
...
}

I was not changing that much from the NFS patter which meant the break lease
code worked.

Jans proposal is solid but it means that there is no breaking of the lease.  I
tried to add an "exclusive" flag to the "write" lease but the __break_lease()
code gets weird.  I'm not saying it is not possible.  Just that I have not
seen a good way to do it.

> 
> > Another thing to consider is that this patch set _allows_ a truncate/hole punch
> > to proceed _if_ the pages being affected are not actually pinned.  So the
> > unbreakable/exclusive nature of the lease is not absolute.
> 
> If you're talking about the process that owns the layout lease
> running the truncate, then that is fine.
> 
> However, if you are talking about a process that does not own the
> layout lease being allowed to truncate a file without first breaking
> the layout lease, then that is fundamentally broken.

In both cases (local or remote process) the lease is broken prior to the
attempt to truncate.

> 
> i.e. If you don't own a layout lease, the layout leases must be
> broken before the truncate can proceed.

Agreed.

>
> If it's an exclusive lease,
> then you cannot break the lease and the truncate *must fail before
> it is started*. i.e.  the layout lease state must be correctly
> resolved before we start an operation that may modify a file layout.
> 
> Determining if we can actually do the truncate based on page state
> occurs /after/ the lease says the truncate can proceed....

That makes a lot of sense and that is the way the patch currently works.

I need to think on this some more.  Keeping the lease may not be critical.  As
discussed with Jan; dealing with close() is best dealt with by tracking the
actual pins on the file.  If that works then we could potentially keep the
lease semantics closer to what you and I are talking about here.

Ira

> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 

