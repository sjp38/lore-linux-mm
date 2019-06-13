Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 792E5C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:47:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31002208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:47:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="iMC2hvEI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31002208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC75F6B026C; Thu, 13 Jun 2019 06:47:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9E3B6B026E; Thu, 13 Jun 2019 06:47:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8D616B026F; Thu, 13 Jun 2019 06:47:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 819FE6B026C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:47:50 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b24so11702868plz.20
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:47:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GEs9TuIKz96lXRS7FnLGyqSMFlOm6a6Nuvp5RkrDbpg=;
        b=aAuQAKYd0Nhgeu6bJB9AAAf6OzhsREWyeKf4Ml4ZeB3uxs63mm92SBJiEOo8cFWmy9
         pppeMFoE7lN9Kaat9GAqhY1c1PIJFecpFph6q6AwpZKo8lQxFRGl9rSMaG/GczfyP6BK
         ac0LKBA0flyXSt/nn+AN57Glf6V0s2wRoBDy67gRoTyTtet0+7dOMHlPiF3VL3WyNUWe
         E7F+Sci6cQm4bkhbMnQplFL+sGQs0Po+8ajSxHl+EkYjXtN46pkfHMifMe75Kc5Zn5x/
         ZTlqXV8QrUP9nz2PL16TI4nPdBY8pHW25jM5jQX8g/Gsy/j7+mmxnPWVQSF0lzZVZ0El
         wdkQ==
X-Gm-Message-State: APjAAAUbvPOdv4Dzc0aFFyzsthdRJtKY9JAJV8rLQZoB8du3EQwEDNwn
	iU2P7TKArtt9bowRC2zp8FY8YID41KW77wrd+1AuRsDb0cjpVSXQYOm1kC70Jo9e+zQQFxWo8xC
	UHLFUfCkgUg7+oNSt9r5eBpspo+WdRb0ep1qjN9HfBkCPsKXpw0qEFksve7PFz7ue3A==
X-Received: by 2002:a17:90a:ca11:: with SMTP id x17mr4900241pjt.107.1560422870209;
        Thu, 13 Jun 2019 03:47:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwH5R22P3Bfndwlv12+EUpCV8n0dIyWRx6rD3osMtiGOXfXhqmoyPHTQgVYHuyzSCaNcYh9
X-Received: by 2002:a17:90a:ca11:: with SMTP id x17mr4900147pjt.107.1560422869353;
        Thu, 13 Jun 2019 03:47:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560422869; cv=none;
        d=google.com; s=arc-20160816;
        b=Oj8VkvbYGVKycRU6BBlV2MSzZ3DRIljMZN7pzb41ZIvCZiBNCICaiQ2hzDyZbUOEOb
         zrPwwJOKuX5Hp0zhFb2pd04BTKRavJblIrN9L4HNWfvcaWLvhXn5nv6AagvCS076udoS
         RuuKJYkcEpU2ssN3/LjWrlNGeUhlTGAErqAZdDUxgVQuEh1ZNciOvLQF+QVwelpDeKpX
         ceqY8uPadDQhGGxCmKWaQSth+b3BktokWUtQDD5bSkld2LSTmtfVX+6TV3BSzMo/9ajK
         KzPL/+Eilaed/NkjaXH1o6dYJMR/a5hHRQVXqfPfhkLKjau5886oc+L78lnFNbJ2U+Sc
         Oifg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GEs9TuIKz96lXRS7FnLGyqSMFlOm6a6Nuvp5RkrDbpg=;
        b=ZAUnECH2XSwoD2gpInTkpJ1BIcZA0auh3U3/A4Ry9vLY4Xah2PEORPaw4aV+WoZScU
         nAHdugFWfQ3t4V26lI2mmVtcS3TRIZRuJu//ZOPPbtcM8KJ30ZduPSFnYvVquoPaTQus
         c8ijiQfpQKoqn0zQWgXsymK5oZXryg40fKxRLseZ1LJuFWHRD7Wlk7scf3L6LPsa92Ou
         4wXJ8AWxtiJoN8LySULkrLJYaxNrdAwtcyyykRNvmDWV744sv/7eQqYhS+0+T2sZWKtu
         Qd3nV7ZsV/sAbJ00wiFG6NYj178W+3HT7PEgaHRp51mJXQz4yYlQEoRxOJI32Ri+Q9u2
         Z3TA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=iMC2hvEI;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f26si3109934pfd.193.2019.06.13.03.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 03:47:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=iMC2hvEI;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=GEs9TuIKz96lXRS7FnLGyqSMFlOm6a6Nuvp5RkrDbpg=; b=iMC2hvEIOcyryH8ttvBTFCIwJ
	+/UTOZxleRRIx/Qk3yqPfUzPCOda7GErke13ZzFQak5ewSoRm8WulpfqNH7Zcz8Q/4E8j/T6eNEmH
	zqn/a0VQTD+joB/VdqCU1xYbOG/t0Yt1iH7D4MVcM+JnmapUwUFZ9n9jOt8V0iESGcP+afyjOL9pH
	+Z800XzTY/YS/+CM4flrqhchMwkDHfagPOomV5WMld5ChIy1boYvTjVntNNzTcy5LKpr/Bsx2mf7S
	S446zK0y8A3V0fwGhTmnFSvXqbCAHfkut7f3C9ZExu7tOQe+5MbplKDwi6MAkqGaZIAtnEYCa3p8M
	bMZjvH0qQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hbNGh-0007DC-6o; Thu, 13 Jun 2019 10:47:43 +0000
Date: Thu, 13 Jun 2019 03:47:43 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
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
Message-ID: <20190613104743.GH32656@bombadil.infradead.org>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
 <20190613032320.GG32656@bombadil.infradead.org>
 <20190613043649.GJ14363@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613043649.GJ14363@dread.disaster.area>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 02:36:49PM +1000, Dave Chinner wrote:
> On Wed, Jun 12, 2019 at 08:23:20PM -0700, Matthew Wilcox wrote:
> > On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> > > On Wed, Jun 12, 2019 at 05:37:53AM -0700, Matthew Wilcox wrote:
> > > > That's rather different from the normal meaning of 'exclusive' in the
> > > > context of locks, which is "only one user can have access to this at
> > > > a time".
> > > 
> > > Layout leases are not locks, they are a user access policy object.
> > > It is the process/fd which holds the lease and it's the process/fd
> > > that is granted exclusive access.  This is exactly the same semantic
> > > as O_EXCL provides for granting exclusive access to a block device
> > > via open(), yes?
> > 
> > This isn't my understanding of how RDMA wants this to work, so we should
> > probably clear that up before we get too far down deciding what name to
> > give it.
> > 
> > For the RDMA usage case, it is entirely possible that both process A
> > and process B which don't know about each other want to perform RDMA to
> > file F.  So there will be two layout leases active on this file at the
> > same time.  It's fine for IOs to simultaneously be active to both leases.
> 
> Yes, it is.
> 
> > But if the filesystem wants to move blocks around, it has to break
> > both leases.
> 
> No, the _lease layer_ needs to break both leases when the filesystem
> calls break_layout().

That's a distinction without a difference as far as userspace is
concerned.  If process A asks for an exclusive lease (and gets it),
then process B asks for an exclusive lease (and gets it), that lease
isn't exclusive!  It's shared.

I think the example you give of O_EXCL is more of a historical accident.
It's a relatively recent Linuxism that O_EXCL on a block device means
"this block device is not part of a filesystem", and I don't think
most userspace programmers are aware of what it means when not paired
with O_CREAT.

> > If Process C tries to do a write to file F without a lease, there's no
> > problem, unless a side-effect of the write would be to change the block
> > mapping,
> 
> That's a side effect we cannot predict ahead of time. But it's
> also _completely irrelevant_ to the layout lease layer API and
> implementation.(*)

It's irrelevant to the naming, but you brought it up as part of the
semantics.

