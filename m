Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CBF6C468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 15:10:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E90742089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 15:10:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="WYsyLuJw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E90742089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98B556B0007; Fri,  7 Jun 2019 11:10:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 962236B000C; Fri,  7 Jun 2019 11:10:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 877B86B000E; Fri,  7 Jun 2019 11:10:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63A0D6B0007
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 11:10:17 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g30so2064337qtm.17
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 08:10:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mtF5cAWsrYgtNZcy7Xm0z7hOgyvsIAMepLY84jhBIIY=;
        b=hhsyBJ0nAG6stZtXNzGKMQuHwTZVb0TwRtQVaSmBIhbIoM4M28sF9FYolfdyqaiNxX
         Sh3j2yDPpwjd9OhTzvvyZrqQtC5DKHVHy+zyPJy/CG5j7WKh/dyaoTcUZu+32pjeW2i/
         AIndrIWBzDYmfq3Me3Zv2r4xAEe+g9tFtX7n8ZEujqzqfm2u5WqvyO3R9yUvVzZULdVk
         ECSJKpIXxMS/HWs9xp+6Rv3EzUTawj0OGI8I7gpBgnxqkt8nI5XciQ7zp8lAbJ+CuuvC
         SrD0JIaHeTolLRrVDyi46MejSGDjmahdsr8dRA+7lQzgWXH0b1iovdwNW+Y2rVJ1kCDE
         sfxg==
X-Gm-Message-State: APjAAAU9TrwIr6mITRe+WOTbvYO62nzQ9EWMVq82qBs4s7avg9KSFYJK
	aEbYvHnu+uQ+tZa0SD7zVFV1sODxFsaveHqcNkgwLMDUNsp8AlaR+nkLz7iyJn8zCJkNhuZgPFp
	O6/HnbAia/0YoPYSjyuC/3Tx99vqojUMmIu+kkAMnYsIi7zvK1dt3AXoyBvjhOK1zag==
X-Received: by 2002:a0c:9305:: with SMTP id d5mr28969819qvd.83.1559920217139;
        Fri, 07 Jun 2019 08:10:17 -0700 (PDT)
X-Received: by 2002:a0c:9305:: with SMTP id d5mr28969764qvd.83.1559920216463;
        Fri, 07 Jun 2019 08:10:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559920216; cv=none;
        d=google.com; s=arc-20160816;
        b=oahi0sFKKRRycx5DQ9B3ZfaZgbJYAKCwGjgv0+wnvMlr6F+q8Y2VFVcdKljhl2pQ3U
         Gz9s0PjErXEZgVx14Q2JmIpwOsWJiJn9QtC65glvLLE+Wo/gtewYVQOexb6bAbe0ja4k
         eGBCLZs7y5CfSp+biKEXMD7KRYdo0OPuFHCTWfOUmNVDNtSvC2lde4WoXrF0Xb9ryqe2
         QiPzeHtThcFazpTjwsodX/61FHX2xlVsW6GYrcEOntv3FXG5fqe4qKzMErQgvHfEwLjb
         jX/00zvAXGd301xFCXK9D4sl+hJ1eEWo3KNtOLDGkBwZLoQo3TFaT7udskAshGF70xrF
         fyRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mtF5cAWsrYgtNZcy7Xm0z7hOgyvsIAMepLY84jhBIIY=;
        b=h11yTCCBxZ+NIY3Xn6O2zCxFuFUZNODyEqEuWLQnWz9rgYWb0NjoKqR/CzADyGz0xL
         cpCReoHB8l9wZFgkhcCDU7qwDpdWp0OZCuMgzlJbSbANQ81Y8xZEWEP+O50M/PpZ7MYH
         R32NgrNCFkK51l4yacTUGBMdAe/HB71+6g9MqfQWqomfjBSagIaY4exf0A8IFmraOSO3
         kfx1gjXpQp+lOLlXNu2rQ6e5EEsdoPtVW+biRmo7U5Yu/aScdmjSDQDgpBvqEv5au/kc
         PV58t4GWpUt7D4akbbJr1auRTz74MwGO4x1vth7d1peJWoaaND14pH3l/Oi9gP7zxqGj
         SRGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=WYsyLuJw;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor2726182qte.6.2019.06.07.08.10.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 08:10:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=WYsyLuJw;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mtF5cAWsrYgtNZcy7Xm0z7hOgyvsIAMepLY84jhBIIY=;
        b=WYsyLuJwZJIQkQf8wUWCq+MKSRiYgAlB3cZg5uiR6sfXzmT5qRPbG9DhevssrlPWqT
         btVD4AS17pELyqwsgZDkQw2P7FuITtTVQMrN8ttsGMNW1xgfpIRPBVOa0vjh1b2Q1GR1
         KuOwYeQwWnuz6D+1FRguaiqcVs7bzdSKLArmkC9S3JiLqJpGoQtRUAt5WZRIgTPnLny4
         IKSY1gSwXGY6RvgI08IKQsXM6qG3PGhAf3b+OAJpaapDK96fRJ2kOM5Yvdls9VHMdofH
         LPFgCkV+imozC4VVLOAwHIKBZyqQ6Svl+UIUCGPXrQKi5OfcTa6MmnRnnxQ4x38JcA+k
         g4gw==
X-Google-Smtp-Source: APXvYqz98pAEW8JOYRDiw9EYF+WsmnpCH5t6BgflMJ4duW3xWG4TSqN3U+4KRrwB7XAG90R+0pkeHA==
X-Received: by 2002:ac8:4619:: with SMTP id p25mr14877922qtn.73.1559920216042;
        Fri, 07 Jun 2019 08:10:16 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a11sm1103592qkn.26.2019.06.07.08.10.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 08:10:15 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZGVT-0006TX-4L; Fri, 07 Jun 2019 12:10:15 -0300
Date: Fri, 7 Jun 2019 12:10:15 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190607151015.GJ14802@ziepe.ca>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 07:52:13AM -0700, Ira Weiny wrote:
> On Fri, Jun 07, 2019 at 09:17:29AM -0300, Jason Gunthorpe wrote:
> > On Fri, Jun 07, 2019 at 12:36:36PM +0200, Jan Kara wrote:
> > 
> > > Because the pins would be invisible to sysadmin from that point on. 
> > 
> > It is not invisible, it just shows up in a rdma specific kernel
> > interface. You have to use rdma netlink to see the kernel object
> > holding this pin.
> > 
> > If this visibility is the main sticking point I suggest just enhancing
> > the existing MR reporting to include the file info for current GUP
> > pins and teaching lsof to collect information from there as well so it
> > is easy to use.
> > 
> > If the ownership of the lease transfers to the MR, and we report that
> > ownership to userspace in a way lsof can find, then I think all the
> > concerns that have been raised are met, right?
> 
> I was contemplating some new lsof feature yesterday.  But what I don't think we
> want is sysadmins to have multiple tools for multiple subsystems.  Or even have
> to teach lsof something new for every potential new subsystem user of GUP pins.

Well.. it is a bit tricky, but you'd have to arrange for the lease
object to have a list of 'struct files' that are holding the
lease open. 

The first would be the file that did the fcntl, the next would be all
the files that did longterm GUP - which means longterm GUP has to have
a chardev file/etc as well (seems OK)

Then lsof could query the list of lease objects for each file it
encounters and print them out too.

Jason

