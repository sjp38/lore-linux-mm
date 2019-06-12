Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55DE9C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:38:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F974208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:38:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LcKAST6B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F974208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F6A76B000A; Wed, 12 Jun 2019 08:38:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A7F36B026C; Wed, 12 Jun 2019 08:38:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 697366B026D; Wed, 12 Jun 2019 08:38:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 361406B000A
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:38:00 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i26so11901863pfo.22
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:38:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=l/g0KnT/EyAvMoDe4YYe+/hlvBi7vzZDEnk1KrMoaBA=;
        b=Y26jcfSLHYwtDosLjWHfrhxNAV2b6jdWFgG0kq6uTaFAh2L2CYGhatNoAX6Kde5TpJ
         ZXjKPJTRFoqbSfopx6HIIfvYLpQZWkKCxUBE8Ip5qVCi9kv+nqfCGfmh42+NOTFx7AtK
         2fWaRW5E5mS6iF6X3HC87939BROfWQBDU1z7+ywutL13+MAMwg+TgwWwbtsZYr0Ffb4U
         V9JDs2laPU1Yfkzj4Lr9ezCSwhWze9wnVsgLYK27RLgdIFVlCMI917HvWcPaUex0m2K2
         1inPlISuZe0hZPu0oFdTzilDe5CkSI9Ld1jks3Roj3k8YHjXVILxLO9VdDx+pVZ7Bp5j
         w5lw==
X-Gm-Message-State: APjAAAXT+/THx4KgB7KU+PeomvgryiXzPb1318F5Aps0A+9LIqHC2gG2
	BMszpf6GuwjfAH2exqQNAtlwAqimXX5sdFYkiuOM5eWKu98ezECcSVGIzx6KDUFZVYps8ddueSG
	NFtAvDIbOExqP0SSjDOxdeuRdG2YfBQpBrcguFlwRrUkSRGm6Oa5GQ0uQ7i+3MD4vEQ==
X-Received: by 2002:a62:d149:: with SMTP id t9mr65584183pfl.173.1560343079828;
        Wed, 12 Jun 2019 05:37:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwp+6UANLDSWkU00YeX4zcDNOyqnk8NyLqLny0GHuPdGjj5UQrZnza02P0Esn/+tuPE934v
X-Received: by 2002:a62:d149:: with SMTP id t9mr65584123pfl.173.1560343078980;
        Wed, 12 Jun 2019 05:37:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560343078; cv=none;
        d=google.com; s=arc-20160816;
        b=Lt/AZGupEbz/3hnzMdEWDixAnfRHhPgs/F58GkbIWM3vEDIUSHKlw5c3c3y4eTf6yh
         370glyzIwk66UOyIOvVEtoK6u1+HtCcTIp7Wjtk0pToxG63AFwxQO2D2DfBvYyt/WlU5
         DgzqFuQKnc4q+M4Y7S3RSE1fSRJEBdgqMZcpMUnzc6c8jRAY82dXzG1VqOI3j+ou0gNv
         2vhDNriXoI05jORuGiChqMk769Au5Yshmjb/JrJT/NSaoaVyqyHMf/5rrHsrhmUgyNCD
         C2UtcUQvISgYKz5+RJfwVrnmREE/dUkS9eVzH8dYHSySKTFTRotmWybjt3jBxxDQaKJJ
         +tjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=l/g0KnT/EyAvMoDe4YYe+/hlvBi7vzZDEnk1KrMoaBA=;
        b=frmHFaH/7KjwzHd76dxxFtjqC38nBVMj054QKNi7MtF001xjWw2Q1AWE//fOWny2fS
         nNJePEkQtoMPOX9oPkgopmPx24YD7bhadFhf5eKkU7woFS8xmmoPk8OrVcEVP2FqP5XJ
         y3cyB7PEKGEujhNvrHlKn60UNyhF6CxddPMXR8+/coUTM4S/+Ke9w6zswHeAsDjSvtYr
         uJcq4TbmZyqvHBTwjQLpocJYXp2dIC2qUT8CPVYvFf8P+b37cQPKUnRGG9mFM3QNmQuc
         9+oMbjFtSWNhvdV74xmuyMbC5lGF5uE9LpVGGM5VTslnfPJAmKT1sM/Tsmle1V4yzLzc
         rcog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LcKAST6B;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t24si15182648plr.56.2019.06.12.05.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 05:37:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LcKAST6B;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=l/g0KnT/EyAvMoDe4YYe+/hlvBi7vzZDEnk1KrMoaBA=; b=LcKAST6BxZ0yaOkpMIf7Enjfj
	6c1UeC9+DtFiAG+4D1XV7S0v/ELkcMzkURVHfKUblrSfnsOxjaT7amrayTl8QE7Smq9tJEjwDCWRd
	cPbbPfreHmLvxItzPtzj01TyLpkUqy/kyuWCUwt7PAmxBBWhSBNFS/O2Q9nWYMpVJEIh8LvtVttjd
	3KNMNDefD5IFT6bWTwg5AiN9UAusMV0sJPpB8YYd7y3pqpMB8efSmNBLxM2eJ58kVJO5XNksaSM2O
	FqwQN4iCqdirubzy0TOiW6r/sZA9NbDScogy2w/raTG/y8nZlf2j6YFQA1y/4Snew3ovKOI6jiSdf
	lwADVwjOA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hb2Vl-00060B-5I; Wed, 12 Jun 2019 12:37:53 +0000
Date: Wed, 12 Jun 2019 05:37:53 -0700
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
Message-ID: <20190612123751.GD32656@bombadil.infradead.org>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190608001036.GF14308@dread.disaster.area>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 08, 2019 at 10:10:36AM +1000, Dave Chinner wrote:
> On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:
> > Are you suggesting that we have something like this from user space?
> > 
> > 	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);
> 
> Rather than "unbreakable", perhaps a clearer description of the
> policy it entails is "exclusive"?
> 
> i.e. what we are talking about here is an exclusive lease that
> prevents other processes from changing the layout. i.e. the
> mechanism used to guarantee a lease is exclusive is that the layout
> becomes "unbreakable" at the filesystem level, but the policy we are
> actually presenting to uses is "exclusive access"...

That's rather different from the normal meaning of 'exclusive' in the
context of locks, which is "only one user can have access to this at
a time".  As I understand it, this is rather more like a 'shared' or
'read' lock.  The filesystem would be the one which wants an exclusive
lock, so it can modify the mapping of logical to physical blocks.

The complication being that by default the filesystem has an exclusive
lock on the mapping, and what we're trying to add is the ability for
readers to ask the filesystem to give up its exclusive lock.

