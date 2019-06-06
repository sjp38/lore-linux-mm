Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 476E0C28EB8
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:02:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFF3B204FD
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:02:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFF3B204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 897376B02EA; Thu,  6 Jun 2019 18:02:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 846576B02EC; Thu,  6 Jun 2019 18:02:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75CC96B02ED; Thu,  6 Jun 2019 18:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3994F6B02EA
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 18:02:21 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s195so2474202pgs.13
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 15:02:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=p/U2PU5CbSNfMWju+254vBGEY2P1ZXDBc90DlbD+Iio=;
        b=f2iuPSKidZKSGl5Yobz1AID1UxRu4/TuuD6xUnntzrWr9gaHa7UM38mdpEzzcypBkZ
         KAGk7KxUO5PaDS5nmyvwhTHFC89ml6e+XrR6W1LXHfCK1Fz1ny9L5KgPWKBL9w/I146V
         N5M3rmjlFgwwzxbKGi92zIIr2Zo3YYl451AKdhFNKI5SLQSmXdCSIndEMY3RWA8kYNTe
         9xTuADLC2pNuyjTlfwEUrKryjDIM2iHQfzrtY4CgEPtyBqa4E7cTPWWZzRQHbFtadYYm
         rT8tWu54Tbay5Tq9ZGYmrFZXY/NbpiwQn+uGKsmaqwCKavvtjpXlPwAEt/jboW2NSXJI
         wF5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVgrIkIOz5fpo8YxWEpvtX6KiN4pxqtjA2ZnMlPaAMuDP5jz7TN
	CQXzAbnb+3UOqrHsPImBNOw3rAP3R4cHMR13PQj6eEv8D2m9cm3ugdSSrSGuaxaya+7x30HMwae
	k0Uwx5rOB7/N/7HH994Cx6vIFaJ20ElsDgZ8OVewW54ZQazQbvjElGNEb64aJiQQMkA==
X-Received: by 2002:a62:4d04:: with SMTP id a4mr55109172pfb.177.1559858540725;
        Thu, 06 Jun 2019 15:02:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqze+TBCGB1AquSKf3Es2rbvB53ZFAMrptntOIbLXe7yfMk/epA5YcYHQx5Z+h9FVTc3Mq6K
X-Received: by 2002:a62:4d04:: with SMTP id a4mr55109082pfb.177.1559858539414;
        Thu, 06 Jun 2019 15:02:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559858539; cv=none;
        d=google.com; s=arc-20160816;
        b=xuXIevyRsRaUSA6X0CIfdYqEDD0n0eAU5xZuv83D3+6tKSY35PaaSPXSGpKAqomO3h
         hg6gYI6iTT86Hw7o82uUmYg9eoOclyN30ZB2e63F9UucnOgiHXg4TnojDjDki+rdCTGf
         24AOigd9gUPTgFqysGxgUYOArvr5o14CFGGcIgaq/le0tTI+a4azFB4j8gIw673u98nD
         aEAqSz2FzMEqzGlatQuv/pjBoR6aEQBLSbRr1LHqqZ0NxpBxfz3f/o6txdIA+atyQLLw
         x2Ho8VdUkRZbwe9JSW4KYOHZEPmg//iwN+Nao16wSynXNtd5LUnQ1sbu8FpFG2qZkXmz
         z0BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=p/U2PU5CbSNfMWju+254vBGEY2P1ZXDBc90DlbD+Iio=;
        b=s7XJ6HTdwlYhbPrV9gxFgOw8r1ejBSNlnXYuvtrna1g867bm/q+lbdePCJ90rISozA
         laEOEYzfoz94bUw/HQyYhr6vopRD+iJo82o3hVMVnVuOKjxR55ExpLVG0jBmSMiKn8tL
         swYw/KSaSS8hp04GyIciAbViVLaTpaDck9V8IsUswql3Y47WcoPibjtCzvHeAFnvsgjo
         9psbPB/LQhow1M6WcY0I6JkAhJzrJMEHZlSQvGwwmQMNxOy/VPcNWIpaNo/CB5lNhV4m
         EKkzrqKFJbiAYHa39Nhx0wZKViTOB24wQ0iQEjTtQUteMFofNlxxLA53xaPOSb7SqI7t
         Upkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y19si198675pgi.587.2019.06.06.15.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 15:02:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 15:02:18 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 06 Jun 2019 15:02:17 -0700
Date: Thu, 6 Jun 2019 15:03:30 -0700
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
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606104203.GF7433@quack2.suse.cz>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 12:42:03PM +0200, Jan Kara wrote:
> On Wed 05-06-19 18:45:33, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > ... V1,000,000   ;-)
> > 
> > Pre-requisites:
> > 	John Hubbard's put_user_pages() patch series.[1]
> > 	Jan Kara's ext4_break_layouts() fixes[2]
> > 
> > Based on the feedback from LSFmm and the LWN article which resulted.  I've
> > decided to take a slightly different tack on this problem.
> > 
> > The real issue is that there is no use case for a user to have RDMA pinn'ed
> > memory which is then truncated.  So really any solution we present which:
> > 
> > A) Prevents file system corruption or data leaks
> > ...and...
> > B) Informs the user that they did something wrong
> > 
> > Should be an acceptable solution.
> > 
> > Because this is slightly new behavior.  And because this is gonig to be
> > specific to DAX (because of the lack of a page cache) we have made the user
> > "opt in" to this behavior.
> > 
> > The following patches implement the following solution.
> > 
> > 1) The user has to opt in to allowing GUP pins on a file with a layout lease
> >    (now made visible).
> > 2) GUP will fail (EPERM) if a layout lease is not taken
> > 3) Any truncate or hole punch operation on a GUP'ed DAX page will fail.
> > 4) The user has the option of holding the layout lease to receive a SIGIO for
> >    notification to the original thread that another thread has tried to delete
> >    their data.  Furthermore this indicates that if the user needs to GUP the
> >    file again they will need to retake the Layout lease before doing so.
> > 
> > 
> > NOTE: If the user releases the layout lease or if it has been broken by
> > another operation further GUP operations on the file will fail without
> > re-taking the lease.  This means that if a user would like to register
> > pieces of a file and continue to register other pieces later they would
> > be advised to keep the layout lease, get a SIGIO notification, and retake
> > the lease.
> > 
> > NOTE2: Truncation of pages which are not actively pinned will succeed.
> > Similar to accessing an mmap to this area GUP pins of that memory may
> > fail.
> 
> So after some through I'm willing accept the fact that pinned DAX pages
> will just make truncate / hole punch fail and shove it into a same bucket
> of situations like "user can open a file and unlink won't delete it" or
> "ETXTBUSY when user is executing a file being truncated".  The problem I
> have with this proposal is a lack of visibility from sysadmin POV. For
> ETXTBUSY or "unlinked but open file" sysadmin can just do lsof, find the
> problematic process and kill it. There's nothing like that with your
> proposal since currently once you hold page reference, you can unmap the
> file, drop layout lease, close the file, and there's no trace that you're
> responsible for the pinned page anymore.

Agreed.  For some "GUP interfaces" one may be able to figure this out but I'm
not familiar with any.  For RDMA there has been some additions for tracking
resources but I don't think any of that is useful here.  Regardless from a FS
POV this is awkward to have to understand all the independent interfaces, so I
agree.

> 
> So I'd like to actually mandate that you *must* hold the file lease until
> you unpin all pages in the given range (not just that you have an option to
> hold a lease). And I believe the kernel should actually enforce this. That
> way we maintain a sane state that if someone uses a physical location of
> logical file offset on disk, he has a layout lease. Also once this is done,
> sysadmin has a reasonably easy way to discover run-away RDMA application
> and kill it if he wishes so.

Fair enough.

I was kind of heading that direction but had not thought this far forward.  I
was exploring how to have a lease remain on the file even after a "lease
break".  But that is incompatible with the current semantics of a "layout"
lease (as currently defined in the kernel).  [In the end I wanted to get an RFC
out to see what people think of this idea so I did not look at keeping the
lease.]

Also hitch is that currently a lease is forcefully broken after
<sysfs>/lease-break-time.  To do what you suggest I think we would need a new
lease type with the semantics you describe.

Previously I had thought this would be a good idea (for other reasons).  But
what does everyone think about using a "longterm lease" similar to [1] which
has the semantics you proppose?  In [1] I was not sure "longterm" was a good
name but with your proposal I think it makes more sense.

> 
> The question is on how to exactly enforce that lease is taken until all
> pages are unpinned. I belive it could be done by tracking number of
> long-term pinned pages within a lease. Gup_longterm could easily increment
> the count when verifying the lease exists, gup_longterm users will somehow
> need to propagate corresponding 'filp' (struct file pointer) to
> put_user_pages_longterm() callsites so that they can look up appropriate
> lease to drop reference

I actually think that might be pretty easy.  I actually added a ref count to
the longterm lease before.[2]  This was done to be able to take the lease
within the GUP code.  We don't need that functionality exactly but that patch
implements some of what you propose.  With a ref count on the lease we can
refuse to release it until all GUP users have released it.

>
> - probably I'd just transition all gup_longterm()
> users to a saner API similar to the one we have in mm/frame_vector.c where
> we don't hand out page pointers but an encapsulating structure that does
> all the necessary tracking.

I'll take a look at that code.  But that seems like a pretty big change.

>
> Removing a lease would need to block until all
> pins are released - this is probably the most hairy part since we need to
> handle a case if application just closes the file descriptor which would
> release the lease but OTOH we need to make sure task exit does not deadlock.
> Maybe we could block only on explicit lease unlock and just drop the layout
> lease on file close and if there are still pinned pages, send SIGKILL to an
> application as a reminder it did something stupid...

As presented at LSFmm I'm not opposed to killing a process which does not
"follow the rules".  But I'm concerned about how to handle this across a fork.

Limiting the open()/LEASE/GUP/close()/SIGKILL to a specific pid "leak"'s pins
to a child through the RDMA context.  This was the major issue Jason had with
the SIGBUS proposal.

Always sending a SIGKILL would prevent an RDMA process from doing something
like system("ls") (would kill the child unnecessarily).  Are we ok with that?

> 
> What do people think about this?

But generally I like the idea of the leases being sticky.  Not sure about the
SIGKILL.

Thanks for the review,
Ira

[1] https://patchwork.kernel.org/patch/10921171/
[2] https://patchwork.kernel.org/patch/10921177/

> 
> 								Honza
> > 
> > 
> > A general overview follows for background.
> > 
> > It should be noted that one solution for this problem is to use RDMA's On
> > Demand Paging (ODP).  There are 2 big reasons this may not work.
> > 
> > 	1) The hardware being used for RDMA may not support ODP
> > 	2) ODP may be detrimental to the over all network (cluster or cloud)
> > 	   performance
> > 
> > Therefore, in order to support RDMA to File system pages without On Demand
> > Paging (ODP) a number of things need to be done.
> > 
> > 1) GUP "longterm" users need to inform the other subsystems that they have
> >    taken a pin on a page which may remain pinned for a very "long time".[3]
> > 
> > 2) Any page which is "controlled" by a file system needs to have special
> >    handling.  The details of the handling depends on if the page is page cache
> >    fronted or not.
> > 
> >    2a) A page cache fronted page which has been pinned by GUP long term can use a
> >    bounce buffer to allow the file system to write back snap shots of the page.
> >    This is handled by the FS recognizing the GUP long term pin and making a copy
> >    of the page to be written back.
> > 	NOTE: this patch set does not address this path.
> > 
> >    2b) A FS "controlled" page which is not page cache fronted is either easier
> >    to deal with or harder depending on the operation the filesystem is trying
> >    to do.
> > 
> > 	2ba) [Hard case] If the FS operation _is_ a truncate or hole punch the
> > 	FS can no longer use the pages in question until the pin has been
> > 	removed.  This patch set presents a solution to this by introducing
> > 	some reasonable restrictions on user space applications.
> > 
> > 	2bb) [Easy case] If the FS operation is _not_ a truncate or hole punch
> > 	then there is nothing which need be done.  Data is Read or Written
> > 	directly to the page.  This is an easy case which would currently work
> > 	if not for GUP long term pins being disabled.  Therefore this patch set
> > 	need not change access to the file data but does allow for GUP pins
> > 	after 2ba above is dealt with.
> > 
> > 
> > This patch series and presents a solution for problem 2ba)
> > 
> > [1] https://github.com/johnhubbard/linux/tree/gup_dma_core
> > 
> > [2] ext4/dev branch:
> > 
> > - https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/log/?h=dev
> > 
> > 	Specific patches:
> > 
> > 	[2a] ext4: wait for outstanding dio during truncate in nojournal mode
> > 
> > 	- https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/commit/?h=dev&id=82a25b027ca48d7ef197295846b352345853dfa8
> > 
> > 	[2b] ext4: do not delete unlinked inode from orphan list on failed truncate
> > 
> > 	- https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/commit/?h=dev&id=ee0ed02ca93ef1ecf8963ad96638795d55af2c14
> > 
> > 	[2c] ext4: gracefully handle ext4_break_layouts() failure during truncate
> > 
> > 	- https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/commit/?h=dev&id=b9c1c26739ec2d4b4fb70207a0a9ad6747e43f4c
> > 
> > [3] The definition of long time is debatable but it has been established
> > that RDMAs use of pages, minutes or hours after the pin is the extreme case
> > which makes this problem most severe.
> > 
> > 
> > Ira Weiny (10):
> >   fs/locks: Add trace_leases_conflict
> >   fs/locks: Export F_LAYOUT lease to user space
> >   mm/gup: Pass flags down to __gup_device_huge* calls
> >   mm/gup: Ensure F_LAYOUT lease is held prior to GUP'ing pages
> >   fs/ext4: Teach ext4 to break layout leases
> >   fs/ext4: Teach dax_layout_busy_page() to operate on a sub-range
> >   fs/ext4: Fail truncate if pages are GUP pinned
> >   fs/xfs: Teach xfs to use new dax_layout_busy_page()
> >   fs/xfs: Fail truncate if pages are GUP pinned
> >   mm/gup: Remove FOLL_LONGTERM DAX exclusion
> > 
> >  fs/Kconfig                       |   1 +
> >  fs/dax.c                         |  38 ++++++---
> >  fs/ext4/ext4.h                   |   2 +-
> >  fs/ext4/extents.c                |   6 +-
> >  fs/ext4/inode.c                  |  26 +++++--
> >  fs/locks.c                       |  97 ++++++++++++++++++++---
> >  fs/xfs/xfs_file.c                |  24 ++++--
> >  fs/xfs/xfs_inode.h               |   5 +-
> >  fs/xfs/xfs_ioctl.c               |  15 +++-
> >  fs/xfs/xfs_iops.c                |  14 +++-
> >  fs/xfs/xfs_pnfs.c                |  14 ++--
> >  include/linux/dax.h              |   9 ++-
> >  include/linux/fs.h               |   2 +-
> >  include/linux/mm.h               |   2 +
> >  include/trace/events/filelock.h  |  35 +++++++++
> >  include/uapi/asm-generic/fcntl.h |   3 +
> >  mm/gup.c                         | 129 ++++++++++++-------------------
> >  mm/huge_memory.c                 |  12 +++
> >  18 files changed, 299 insertions(+), 135 deletions(-)
> > 
> > -- 
> > 2.20.1
> > 
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

