Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 582CAC3A5A4
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 19:39:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E931820673
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 19:39:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="jY1JCn+l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E931820673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 585816B0510; Sun, 25 Aug 2019 15:39:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 536816B0511; Sun, 25 Aug 2019 15:39:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 424FD6B0512; Sun, 25 Aug 2019 15:39:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3A56B0510
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 15:39:04 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 88FC2824CA2F
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 19:39:03 +0000 (UTC)
X-FDA: 75861963366.13.soap24_8941eb3f00210
X-HE-Tag: soap24_8941eb3f00210
X-Filterd-Recvd-Size: 6035
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 19:39:03 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id q64so4344143qtd.5
        for <linux-mm@kvack.org>; Sun, 25 Aug 2019 12:39:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IcftYbtF8hmiS81ypdWg52goznYue2k46OBNV8xIDyo=;
        b=jY1JCn+ldE3+NTo3VG4D8ssjZZ/12uHiNC485pYaAlQaG8pq2px0AOjE6MH3L2daUE
         OBQQMbkBAQx1ajmooyQh4PWVjIdt6ikqEPLDm20L670hA8QUe1IDUU8Cq7RXHKvaCJs6
         htKXA0TQcvkuZNBGS9+1p2d+L62V+4CGU22UmkrAkD8MZulxOHzPTTFZ136Y5UdWTW5x
         idbHVJEbZfo8m9QYHUrZMB8nBu9bO4c81G3htyFqwzCZfcFCkUU0+OO9AT3zsqJ59i9L
         HxpSOEcHwKnDcvmLtQNemKrtsmfjrFYpGaWhT4ebFkdejRPPm33Mc2qKmXCed7vAMCi4
         f5sw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=IcftYbtF8hmiS81ypdWg52goznYue2k46OBNV8xIDyo=;
        b=dINHi2AIqgnBslUmR8B1o68oEvJnpe3QrnsNxpz6Ddh4b5NL00fztOX+yeT7Zt1dL0
         inr8jxea5/Y2najsduXSGMRwfbI+mpOmMpZdcYN7FBakGymDEKpSkgLgSxylMw1wGUB8
         KuwdcbWfFkGDEo9d29+GEGCiZO+DBXE2u+rjnnFXO/MZ6nYfLpPYD5dcP1D0/ckgleB3
         FuNqsqLMlQQnVgurFkO9i4LkREs7MnbG1iqCdV4YRwyXVQ9oHxLmitnXbszICiRhBTqX
         Mj/T0aK2O2N4f5i8tNJrXm1w0WyfZjHJEq1HXbq5A7oxE+LoQORRmH5Frhzfl8QiPshJ
         pIgg==
X-Gm-Message-State: APjAAAVakYJl/ReQf+1sZcUuImV0cYcpT5yNYh5H5BF83B7FIXhJO0Y4
	r8AYwltMgA4UkunwaQemN3QtKA==
X-Google-Smtp-Source: APXvYqxGjNntfiQL8TISYg5BInHS+cQ0ODQq/4ockdGbt/O3U8AzybLVwFgyx4YCA0QWh5oy2S8plQ==
X-Received: by 2002:ac8:450c:: with SMTP id q12mr14722642qtn.298.1566761942403;
        Sun, 25 Aug 2019 12:39:02 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-142-167-216-168.dhcp-dynamic.fibreop.ns.bellaliant.net. [142.167.216.168])
        by smtp.gmail.com with ESMTPSA id m10sm4699826qka.43.2019.08.25.12.39.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 25 Aug 2019 12:39:01 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i1yLs-0005oN-Oc; Sun, 25 Aug 2019 16:39:00 -0300
Date: Sun, 25 Aug 2019 16:39:00 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Theodore Ts'o <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
Message-ID: <20190825193900.GA21239@ziepe.ca>
References: <20190820011210.GP7777@dread.disaster.area>
 <20190820115515.GA29246@ziepe.ca>
 <20190821180200.GA5965@iweiny-DESK2.sc.intel.com>
 <20190821181343.GH8653@ziepe.ca>
 <20190821185703.GB5965@iweiny-DESK2.sc.intel.com>
 <20190821194810.GI8653@ziepe.ca>
 <20190821204421.GE5965@iweiny-DESK2.sc.intel.com>
 <20190823032345.GG1119@dread.disaster.area>
 <20190823120428.GA12968@ziepe.ca>
 <20190824001124.GI1119@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190824001124.GI1119@dread.disaster.area>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 24, 2019 at 10:11:24AM +1000, Dave Chinner wrote:
> On Fri, Aug 23, 2019 at 09:04:29AM -0300, Jason Gunthorpe wrote:
> > On Fri, Aug 23, 2019 at 01:23:45PM +1000, Dave Chinner wrote:
> > 
> > > > But the fact that RDMA, and potentially others, can "pass the
> > > > pins" to other processes is something I spent a lot of time trying to work out.
> > > 
> > > There's nothing in file layout lease architecture that says you
> > > can't "pass the pins" to another process.  All the file layout lease
> > > requirements say is that if you are going to pass a resource for
> > > which the layout lease guarantees access for to another process,
> > > then the destination process already have a valid, active layout
> > > lease that covers the range of the pins being passed to it via the
> > > RDMA handle.
> > 
> > How would the kernel detect and enforce this? There are many ways to
> > pass a FD.
> 
> AFAIC, that's not really a kernel problem. It's more of an
> application design constraint than anything else. i.e. if the app
> passes the IB context to another process without a lease, then the
> original process is still responsible for recalling the lease and
> has to tell that other process to release the IB handle and it's
> resources.

It is a kernel problem, the MR exists and is doing DMA. That relies on
the lease to prevent data corruption.

The sanest outcome I could suggest is that when the kernel detects the
MR has outlived the lease it needs then we forcibly abort the entire
RDMA state. Ie the application has malfunctioned and gets wacked with
a very big hammer.

> That still doesn't work. Leases are not individually trackable or
> reference counted objects objects - they are attached to a struct
> file bUt, in reality, they are far more restricted than a struct
> file.

This is the problem. How to link something that is not refcounted to
the refcounted world of file descriptors does not seem very obvious.

There are too many places where struct file relies on its refcounting
to try to and plug them.

Jason

