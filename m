Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 786BCECDE2C
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 08:20:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DA022168B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 08:20:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lzzM8L2D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DA022168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CB836B0005; Wed, 11 Sep 2019 04:20:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97B316B0006; Wed, 11 Sep 2019 04:20:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 869066B0007; Wed, 11 Sep 2019 04:20:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0145.hostedemail.com [216.40.44.145])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBFC6B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 04:20:04 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E5FBA180AD802
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:20:03 +0000 (UTC)
X-FDA: 75921941886.02.edge16_7abece33c26
X-HE-Tag: edge16_7abece33c26
X-Filterd-Recvd-Size: 5635
Received: from mail-wm1-f68.google.com (mail-wm1-f68.google.com [209.85.128.68])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:20:03 +0000 (UTC)
Received: by mail-wm1-f68.google.com with SMTP id t9so2359064wmi.5
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 01:20:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=73Mk7Z9yNYBR9L0eb9oAsrN33Ivf779654SN9226Yx0=;
        b=lzzM8L2DKputz7E8BnA9+EcELiqTMUGOY69T7jjCa9uf+uWvwuzpYYhL8Nv5LJzUtX
         pslPCUzteUedVsAO7Uh+akynz719MT5rU3CXAGnZCX0ho9qVu76a27TAVjsgM+zyeS0A
         ksacMXfdU7LVCHgRBpm9gajfZbu7oGrLchB/8Y3McmIxN2Ul3PI2FPJ6afqOio//N9LI
         ta5N/T+t0ETYEJ3C2risxGC6eu0pHf9Q4eQXPLAVzrsLwff2DyzqLQjOsshK+m9pnUg8
         AU6Bi9iICYiPINavXSkRjPjWy0lqtq5O3QvUmqqLA1ovJHhVXc3YwX7OtEYjLY+gIZdo
         OoQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=73Mk7Z9yNYBR9L0eb9oAsrN33Ivf779654SN9226Yx0=;
        b=gCXYa3kMqVg3UpEftPLTidmTj3eDtVZzGx6uPlbKNPN82hwVUJ0hEftysTf7qK3B36
         HGpeLSaJF9UI7zLXZEAG5CStqPgyGhPdR9vCX7g1gJCXWCHF2mRuCfxCP5nULZOJG+u2
         6XU9tElXeCBuvy0ItOLbk61EiMuwpKe3heohQOlZ+emYz3BnOtOkFJXrZWhte4dUGF/2
         tQtX5M3umFr7QCXFJtTZ9idicjjAJhdQrzxAiht9HWf5lHVtAdHtLoLJC8esKVJO6bwv
         CJrhzzh4du9018g3AWFE2MxzdCOhCmMmRTKEkChZWnF+x6gCf+93B0LSjSApgLKoDfyy
         gNMw==
X-Gm-Message-State: APjAAAUoQeoXmzD4nXYbprPIrhx5MY/wxF98x3sbd5+pIvEcUjCLN2/N
	wE6IHoxrIigWAcbfuOrUo49LMQ==
X-Google-Smtp-Source: APXvYqwuImgeWs/pa+4thE+4R4gw3Ydri3nAjPDaSD8LYzbWB31nR0x1yXh0fLg4sEsBe7+K+ixaIg==
X-Received: by 2002:a7b:c752:: with SMTP id w18mr2765612wmk.63.1568189997578;
        Wed, 11 Sep 2019 01:19:57 -0700 (PDT)
Received: from ziepe.ca ([148.69.85.38])
        by smtp.gmail.com with ESMTPSA id a13sm36163114wrf.73.2019.09.11.01.19.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Sep 2019 01:19:56 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i7xr1-0002Mq-Vn; Wed, 11 Sep 2019 05:19:55 -0300
Date: Wed, 11 Sep 2019 05:19:55 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
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
Message-ID: <20190911081955.GA9070@ziepe.ca>
References: <20190812130039.GD24457@ziepe.ca>
 <20190812172826.GA19746@iweiny-DESK2.sc.intel.com>
 <20190812175615.GI24457@ziepe.ca>
 <20190812211537.GE20634@iweiny-DESK2.sc.intel.com>
 <20190813114842.GB29508@ziepe.ca>
 <20190813174142.GB11882@iweiny-DESK2.sc.intel.com>
 <20190813180022.GF29508@ziepe.ca>
 <20190813203858.GA12695@iweiny-DESK2.sc.intel.com>
 <20190814122308.GB13770@ziepe.ca>
 <20190904222549.GC31319@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904222549.GC31319@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 04, 2019 at 03:25:50PM -0700, Ira Weiny wrote:
> On Wed, Aug 14, 2019 at 09:23:08AM -0300, Jason Gunthorpe wrote:
> > On Tue, Aug 13, 2019 at 01:38:59PM -0700, Ira Weiny wrote:
> > > On Tue, Aug 13, 2019 at 03:00:22PM -0300, Jason Gunthorpe wrote:
> > > > On Tue, Aug 13, 2019 at 10:41:42AM -0700, Ira Weiny wrote:
> > > > 
> > > > > And I was pretty sure uverbs_destroy_ufile_hw() would take care of (or ensure
> > > > > that some other thread is) destroying all the MR's we have associated with this
> > > > > FD.
> > > > 
> > > > fd's can't be revoked, so destroy_ufile_hw() can't touch them. It
> > > > deletes any underlying HW resources, but the FD persists.
> > > 
> > > I misspoke.  I should have said associated with this "context".  And of course
> > > uverbs_destroy_ufile_hw() does not touch the FD.  What I mean is that the
> > > struct file which had file_pins hanging off of it would be getting its file
> > > pins destroyed by uverbs_destroy_ufile_hw().  Therefore we don't need the FD
> > > after uverbs_destroy_ufile_hw() is done.
> > > 
> > > But since it does not block it may be that the struct file is gone before the
> > > MR is actually destroyed.  Which means I think the GUP code would blow up in
> > > that case...  :-(
> > 
> > Oh, yes, that is true, you also can't rely on the struct file living
> > longer than the HW objects either, that isn't how the lifetime model
> > works.
> 
> Reviewing all these old threads...  And this made me think.  While the HW
> objects may out live the struct file.
> 
> They _are_ going away in a finite amount of time right?  It is not like they
> could be held forever right?

Yes, at least until they become shared between FDs

Jason

