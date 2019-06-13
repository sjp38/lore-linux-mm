Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E7C7C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 03:23:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23B8C20684
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 03:23:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VCF/wqwv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23B8C20684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BC056B000D; Wed, 12 Jun 2019 23:23:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86C3A6B000E; Wed, 12 Jun 2019 23:23:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70D046B0010; Wed, 12 Jun 2019 23:23:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37FCA6B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 23:23:31 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j21so13459910pff.12
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 20:23:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QaIPZk5fG08PMipK2ZOjFgNMkP7/mE5EU+2hsa7y6lY=;
        b=b5d5Jw9HZu/6eQjrR9XDdOJPo/PQ9oAjW01VKcch425+/fJuji8fGuas47OGpSjcHO
         Sp+C89sHKnhR+Lr9jZ5aCDWXIVqKszAgo8/uM5eUVqGpkWpPY74/zqFyil/+bfSTnv53
         CLxCdgVomEo2mz/Plfqz2dXqyjeUa+KFJ8cKj0Z7WBBQRm4uBr+tEyLxRqa30+GBNQLy
         Sj1jkKk77M8cXSsbNulTfpdqwQyLVCSyoCV4xsDbJoXv7XF2uh4V0zioVovqs8rSoCCs
         VWj57BL/9dIwAQEbHx2WAP0Hsuik5PsP9U7iaij3uVqss18wZFXo+yYM7dE+zBFdwfaK
         wQGQ==
X-Gm-Message-State: APjAAAVrAqYJ59Z6DssJONKkER1QHa7VnFVXlrYhRy20Fj41UYjPSeAH
	6jm5MqdI2hKYN2kbm7xGfrxM9HZXRaXELEDtaMqKwpWZJoUWJkftpGoc1dl1ww1/CXj/zhsx1U6
	ognGemJ93RE615+1Y0rKphsH2EDMb+/8RpD8PTZVy3kGmZ+0WP3xHiP+B5Zz9vawJUw==
X-Received: by 2002:aa7:8013:: with SMTP id j19mr28341911pfi.212.1560396210811;
        Wed, 12 Jun 2019 20:23:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2QjtFWDxVP1sUlGBE1KrT7C5sEF8p0YiCXv7tempainuswmB+lABtT0M+dIpbtQpZIqMC
X-Received: by 2002:aa7:8013:: with SMTP id j19mr28341823pfi.212.1560396209943;
        Wed, 12 Jun 2019 20:23:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560396209; cv=none;
        d=google.com; s=arc-20160816;
        b=X0z0O4y2ulmRUQfFtUIj6vej4tP4rKpIrArsrC4MuJDyoscQAKRW0MLco0SM8uOJEI
         jMVaj3X/M4Ip8wu8tMkOzVPksZlzl50VKQdbJV52VILbXgdV3MZwK7pBhw1tr4m7rVxt
         F4GbpjPWHTzRxJ0elnrNVb9A37ZAI88HSWK0L/55Ifd96NH+wsGDYJem2u6c96zOazY7
         SfEx0HFmhRnQnTMl2RJyzmisDupWqAtCJbYzhtsIUY0bJPOFzUXrt21W24KSMtT05oh/
         D7tlR3SPHBg4yZ9rVs4HSGd68oY6vL2WW1eihEwE0vdJF7z7xgT6ra62LBIDk5OL2Y4A
         u7Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QaIPZk5fG08PMipK2ZOjFgNMkP7/mE5EU+2hsa7y6lY=;
        b=CslDBRHgkAsv2+rQwgeyvn5/E/dpxo4HGKO2ugZesKxG6RQ2b5IyGslew4moZ7nnPc
         B+HngkTLbNbIzl69IF/oO010VaKceBHwn8UTpvnF4F1ySTeZ5McHhORLN4ZgzoGArjG7
         9t4QG2pQ9Ai5DQDg9hdXZejwWRMMGRHTYx8gahr42U7onAb+UNfUXaw16e1NpexUhMS9
         Qh6hd/5dLS2bAeN0x+J0gI2tX+3jQ6uHBTxR1UhJKDpdQpJK8KKvxkevCAwo10ly9U83
         qgnYEXd59Y2jMA13AGYmQ6gBlS36jCNDmDzPNc6vaa4bgSxz2cUFgxiM5zkWn2zf8DcN
         RQ3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="VCF/wqwv";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g9si1357833plp.13.2019.06.12.20.23.29
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 20:23:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="VCF/wqwv";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=QaIPZk5fG08PMipK2ZOjFgNMkP7/mE5EU+2hsa7y6lY=; b=VCF/wqwvWCkPBIrvCaL/D3G8l
	tHqc/P5TR0jF4odv4tFa+eZycXtANJYw8npQGw1u7+6Uv8D3dPL6PSPWSss02vOD3RMl8SN9UE9tE
	pgdev89Cvk50mX8MdLQMFzWKjT9ybPnHlvymKlhrDcAdtq9BjKibIVkW+vernB9b/39/CVM/w8KPZ
	7eNO6yjjUerdEhluGAkQcubSLK9G/8N4d5w54XxHTAPHR/5HqmRB4lPvHLnyja2+Z1QV2Pr2MBWyz
	OHrDRVCwX8aCx5s1LcyskUetCbhRrlq1e3Hk4+o+Gp2Qi2Fokqvsf6H+CAZFG91Ylp4HPDaT6v01i
	r9dkL+CUQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hbGKe-0003os-RJ; Thu, 13 Jun 2019 03:23:20 +0000
Date: Wed, 12 Jun 2019 20:23:20 -0700
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
Message-ID: <20190613032320.GG32656@bombadil.infradead.org>
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
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> On Wed, Jun 12, 2019 at 05:37:53AM -0700, Matthew Wilcox wrote:
> > That's rather different from the normal meaning of 'exclusive' in the
> > context of locks, which is "only one user can have access to this at
> > a time".
> 
> Layout leases are not locks, they are a user access policy object.
> It is the process/fd which holds the lease and it's the process/fd
> that is granted exclusive access.  This is exactly the same semantic
> as O_EXCL provides for granting exclusive access to a block device
> via open(), yes?

This isn't my understanding of how RDMA wants this to work, so we should
probably clear that up before we get too far down deciding what name to
give it.

For the RDMA usage case, it is entirely possible that both process A
and process B which don't know about each other want to perform RDMA to
file F.  So there will be two layout leases active on this file at the
same time.  It's fine for IOs to simultaneously be active to both leases.
But if the filesystem wants to move blocks around, it has to break
both leases.

If Process C tries to do a write to file F without a lease, there's no
problem, unless a side-effect of the write would be to change the block
mapping, in which case either the leases must break first, or the write
must be denied.

Jason, please correct me if I've misunderstood the RDMA needs here.

