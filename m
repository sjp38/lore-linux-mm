Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1940C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:32:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9817420B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:32:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9817420B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B8896B000A; Thu, 13 Jun 2019 16:32:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36C1E8E0002; Thu, 13 Jun 2019 16:32:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20AB96B000D; Thu, 13 Jun 2019 16:32:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC3AC6B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:32:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 140so73920pfa.23
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:32:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rhBTbX1x87GhNEDzGPpuC7RZ/QM62lFwT//Zml2BFNY=;
        b=fcCSWkQAFMFSejbdc3OjtQnJKyG04lqZHymql5wtksfSDTTcakXYywKeQemLOOTwcz
         +ul7Jg8FmFlb7EISiUEdjI64UcZnQFtOrpFJhw5xWlrn9FPu+sb3e3KQ23MNV+/fj5mi
         MoIIZimQHoWhEE1sBInkejY5HxaziznnnDwadK+luGhoY2n96rNWukAZCq5CYdRH8f8c
         nq8XgRGgmK6WxMGd5OQkEI7qkZ4yiFmfimhanxygXkNd1wodXMaoU6NMXGQsH1sYXI4d
         dntdhvAVkhTo4BAVNDuskhQm076YXW5y0t7Y88XxKf+dbQIQRjDv4X/2kIcBKr014zOj
         Qerw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX24hb8mhvblrkrXa5xvutxe+AOHrDtagVgg8mxYoNnHUy9lcNg
	KbFwUuekGG32vG0eXIPyUibW9ms+KFEu37t6RHiQUaoOwP/VOHS0jFgWvnPjFB7B590EOWqXWjc
	7WlEtEWVem1nNp1FVjFMoAHpGeu5nukniGlfuy0i0EFLAj4OEZdADO9H+vv1b3qu/JA==
X-Received: by 2002:a17:902:830c:: with SMTP id bd12mr11735843plb.237.1560457965518;
        Thu, 13 Jun 2019 13:32:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxON9D4d5QBtDkucM4Uy5s2eoMLQt+y8OEDJ8r8QyOSPyK5uUdWPrZ1W1ZqDUOIefnKs9B
X-Received: by 2002:a17:902:830c:: with SMTP id bd12mr11735785plb.237.1560457964527;
        Thu, 13 Jun 2019 13:32:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560457964; cv=none;
        d=google.com; s=arc-20160816;
        b=pjYBSKPwhzbUzo4WKYQ5NiMxsdrzTURcbBdDx8Ac2syWMdXAO9w0flqPLjQtAqJAgm
         HdQZaIACwCe2fDdXSh9QIzHRa4sfW6VOos3kRxsWQERtT+eEdgrkYqdSeWxKJJDjaDui
         +jKjqKh/61y+b9LlQObDNs+uSuNu97leDzEOwuktSgtJQ0lUL9Yq8vJN+vK/Rv20YHLN
         jNW8IroW9RvMYnmVJUMfhkWuyHtOZTWufiqJ9JDKTGDB8DtxRhDL/6muA4RsmxPms4+k
         Qasz71GdJtbBUpNaMCEeojUhrwQxXBU0krblQ5VaLfSTdBC675mKbO5DixuCRvYCAlpX
         GloA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rhBTbX1x87GhNEDzGPpuC7RZ/QM62lFwT//Zml2BFNY=;
        b=FBBUa7khuObSCCL/6uEXp/ixUJk7JS3MZJtYInMPhcxdOrwN44hB6vqulSCnXLaJGo
         EM2PgzYnGl5nY9E00nqleyMJ6k7zXdiELl65S/b1DrJ7eNncbSoCfn+06kJ7T0NnEkUH
         2652yEfMLTdgYFOo3ZGs4pHf8bT2IOrDRfkI4zC6tOJ7YMAIwtsTDHXw8ySPuyXiF9QF
         3fFvxp3ErKTxw0YeqtAgLW+1FbfFW+ZdCes+BO9hOrNcC6h6SWi/bCQWURUa/7zjLyGA
         m4U0JR2e8nc+VkyI5TRXJojZWdQ7cdvL+bpS90EDCIt/uQyAWexJZhx74XrQH4obFQfC
         V7Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id f1si590395pgi.432.2019.06.13.13.32.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 13:32:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 13:32:43 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 13 Jun 2019 13:32:43 -0700
Date: Thu, 13 Jun 2019 13:34:05 -0700
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
Message-ID: <20190613203404.GA30404@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613002555.GH14363@dread.disaster.area>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> On Wed, Jun 12, 2019 at 05:37:53AM -0700, Matthew Wilcox wrote:
> > On Sat, Jun 08, 2019 at 10:10:36AM +1000, Dave Chinner wrote:
> > > On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:
> > > > Are you suggesting that we have something like this from user space?
> > > > 
> > > > 	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);
> > > 
> > > Rather than "unbreakable", perhaps a clearer description of the
> > > policy it entails is "exclusive"?
> > > 
> > > i.e. what we are talking about here is an exclusive lease that
> > > prevents other processes from changing the layout. i.e. the
> > > mechanism used to guarantee a lease is exclusive is that the layout
> > > becomes "unbreakable" at the filesystem level, but the policy we are
> > > actually presenting to uses is "exclusive access"...
> > 
> > That's rather different from the normal meaning of 'exclusive' in the
> > context of locks, which is "only one user can have access to this at
> > a time".
> 
> 
> Layout leases are not locks, they are a user access policy object.
> It is the process/fd which holds the lease and it's the process/fd
> that is granted exclusive access.  This is exactly the same semantic
> as O_EXCL provides for granting exclusive access to a block device
> via open(), yes?
> 
> > As I understand it, this is rather more like a 'shared' or
> > 'read' lock.  The filesystem would be the one which wants an exclusive
> > lock, so it can modify the mapping of logical to physical blocks.
> 
> ISTM that you're conflating internal filesystem implementation with
> application visible semantics. Yes, the filesystem uses internal
> locks to serialise the modification of the things the lease manages
> access too, but that has nothing to do with the access policy the
> lease provides to users.
> 
> e.g. Process A has an exclusive layout lease on file F. It does an
> IO to file F. The filesystem IO path checks that Process A owns the
> lease on the file and so skips straight through layout breaking
> because it owns the lease and is allowed to modify the layout. It
> then takes the inode metadata locks to allocate new space and write
> new data.
> 
> Process B now tries to write to file F. The FS checks whether
> Process B owns a layout lease on file F. It doesn't, so then it
> tries to break the layout lease so the IO can proceed. The layout
> breaking code sees that process A has an exclusive layout lease
> granted, and so returns -ETXTBSY to process B - it is not allowed to
> break the lease and so the IO fails with -ETXTBSY.
> 
> i.e. the exclusive layout lease prevents other processes from
> performing operations that may need to modify the layout from
> performing those operations. It does not "lock" the file/inode in
> any way, it just changes how the layout lease breaking behaves.

Question: Do we expect Process A to get notified that Process B was attempting
to change the layout?

This changes the exclusivity semantics.  While Process A has an exclusive lease
it could release it if notified to allow process B temporary exclusivity.

Question 2: Do we expect other process' (say Process C) to also be able to map
and pin the file?  I believe users will need this and for layout purposes it is
ok to do so.  But this means that Process A does not have "exclusive" access to
the lease.

So given Process C has also placed a layout lease on the file.  Indicating
that it does not want the layout to change.  Both A and C need to be "broken"
by Process B to change the layout.  If there is no Process B; A and C can run
just fine with a "locked" layout.

Ira

> 
> Further, the "exclusiveness" of a layout lease is completely
> irrelevant to the filesystem that is indicating that an operation
> that may need to modify the layout is about to be performed. All the
> filesystem has to do is handle failures to break the lease
> appropriately.  Yes, XFS serialises the layout lease validation
> against other IO to the same file via it's IO locks, but that's an
> internal data IO coherency requirement, not anything to do with
> layout lease management.
> 
> Note that I talk about /writes/ here. This is interchangable with
> any other operation that may need to modify the extent layout of the
> file, be it truncate, fallocate, etc: the attempt to break the
> layout lease by a non-owner should fail if the lease is "exclusive"
> to the owner.
> 
> > The complication being that by default the filesystem has an exclusive
> > lock on the mapping, and what we're trying to add is the ability for
> > readers to ask the filesystem to give up its exclusive lock.
> 
> The filesystem doesn't even lock the "mapping" until after the
> layout lease has been validated or broken.
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 

