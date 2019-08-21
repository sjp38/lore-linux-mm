Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF811C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 23:49:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B9F02339F
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 23:49:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="gPyjbbOl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B9F02339F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A7DF6B02BD; Wed, 21 Aug 2019 19:49:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 358396B02BE; Wed, 21 Aug 2019 19:49:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 246E06B02BF; Wed, 21 Aug 2019 19:49:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0033.hostedemail.com [216.40.44.33])
	by kanga.kvack.org (Postfix) with ESMTP id 00AB36B02BD
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:49:47 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A7E87181AC9B4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:49:47 +0000 (UTC)
X-FDA: 75848080014.23.mark78_385ef8c1c1e19
X-HE-Tag: mark78_385ef8c1c1e19
X-Filterd-Recvd-Size: 4786
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:49:47 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id v38so5390288qtb.0
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:49:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=8Dz6lpgjK94wsk5MHL4jboQE1NnpsCOBFBvUAahO07A=;
        b=gPyjbbOlWbFMNLNEHlm3dVB7Uzz3AKtizx4gilO4AsJS5UDSi7tKtuKLliMJh4+rPu
         1Jf/sMigbAhn4QGVmiCQ6jvV0hXBmnUimeqP0xUMpcAFxLHy5mSvYZ2fitBb6fMv1QEd
         cZ2rJhYAzO91SSmOVmphbBBxbh+HSxrYlvJ3tgnRnP1JDEhZkz5GiMo9UEiNo9GyVRUF
         8WnH6kAl7p/wnpPhgEWF5q/2JAvm1wPyF94nsUIZ3Nn/qacJn/LeA6n513wpAcQCJroq
         gRk02pguSic3ESpZjlGMGpJT0L4SvQqRx3eSvDn9QgwMdBegopEE9vJkJ6UvTjj8CtPC
         e/+g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=8Dz6lpgjK94wsk5MHL4jboQE1NnpsCOBFBvUAahO07A=;
        b=VKUjDtX3MWdwB3yjrHXU+v4SBvL2JGr7BheLtbgbXeZU7TIrBqBSnlBNcull8fh+bC
         N6116bppt5G7+RJRxm1kB4Z7pgEKJh40USF3JRdVL/H6ZKtsFncbgNoGSLcE7UtSb+/c
         nZt//vlsssnowi6h0+ljwAbh93D3iNQ1WlRqRiHBiw9YkPgQqhzxwEF3C2fCCn3ShpbH
         Vmum7eU9M19rkZKY+8fm2yFkDhRG/z6kfBcTfdU+JHg1/p+21HSa6I2VO3rJJ0CVjZ5D
         P8rvQicdPpAAc/vYCtyWVRKyrTetcEX1+5HA6sVpCGEB9XBc83Tj2c4Jx0GcRRTfbPaA
         orIQ==
X-Gm-Message-State: APjAAAXye7X9TaqZZiiAQ7ZJkeJ/aI4m1pTOlUYBdiV5z5irdTETDVjN
	f2tQZxt7idpQjTH+B2i0E1qMxw==
X-Google-Smtp-Source: APXvYqydXtesxNmJNprP51Mg7fYbplLAQObHr5i5Uy4KKN0cJaAIkir0EBD/uw5rTQeKc1g+BuOcEQ==
X-Received: by 2002:ac8:22ac:: with SMTP id f41mr33955957qta.362.1566431386704;
        Wed, 21 Aug 2019 16:49:46 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 125sm11156870qkl.36.2019.08.21.16.49.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Aug 2019 16:49:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i0aML-0008RC-Ks; Wed, 21 Aug 2019 20:49:45 -0300
Date: Wed, 21 Aug 2019 20:49:45 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
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
Message-ID: <20190821234945.GA31944@ziepe.ca>
References: <20190819063412.GA20455@quack2.suse.cz>
 <20190819092409.GM7777@dread.disaster.area>
 <20190819123841.GC5058@ziepe.ca>
 <20190820011210.GP7777@dread.disaster.area>
 <20190820115515.GA29246@ziepe.ca>
 <20190821180200.GA5965@iweiny-DESK2.sc.intel.com>
 <20190821181343.GH8653@ziepe.ca>
 <20190821185703.GB5965@iweiny-DESK2.sc.intel.com>
 <20190821194810.GI8653@ziepe.ca>
 <20190821204421.GE5965@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821204421.GE5965@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 01:44:21PM -0700, Ira Weiny wrote:

> > The order FD's are closed during sigkill is not deterministic, so when
> > all the fputs happen during a kill'd exit we could end up blocking in
> > close(fd) as close(uverbs) will come after in the close
> > list. close(uverbs) is the thing that does the dereg_mr and releases
> > the pin.
> 
> Of course, that is a different scenario which needs to be fixed in my patch
> set.  Now that my servers are back up I can hopefully make progress.  (Power
> was down for them yesterday).

It isn't really a different scenario, the problem is that the
filesystem fd must be closable independenly of fencing the MR to avoid
deadlock cycles. Once you resolve that the issue of the uverbs FD out
living it won't matter one bit if it is in the same process or
another.

Jason

