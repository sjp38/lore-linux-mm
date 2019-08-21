Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33A50C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 19:48:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9B4522DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 19:48:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="VF//ZkIg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9B4522DD3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A2BD6B02A1; Wed, 21 Aug 2019 15:48:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8540F6B02A2; Wed, 21 Aug 2019 15:48:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 769B76B02A3; Wed, 21 Aug 2019 15:48:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id 5645E6B02A1
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:48:13 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 164262C88
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:48:13 +0000 (UTC)
X-FDA: 75847471266.06.tramp38_81e3f9e9a5203
X-HE-Tag: tramp38_81e3f9e9a5203
X-Filterd-Recvd-Size: 4942
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:48:12 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id y26so4572351qto.4
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:48:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=RKaQWnWiA/zCcExfi75lqB9ALEnDHuRristulqneTd4=;
        b=VF//ZkIgb0ccMf/fYMR8ys1oZHmy5JRKO8S8IVnwY93iOCu/W7+tqrcWFw+5rldxNI
         aOtLu3PsXm0Him3edXbZNXCIhRk5dw4XYfKu4e3yv8iN/mxXDcev7A64Goh60uRoeToj
         KsbYARzI5dfW3WUW2nHR+o8WkktwHJGaehfIiJX8Npx8V5kKAL0zIUWne13iFi3yzfE0
         Mr3GgB9fCwjOgBICH92Ndb17k2AjhI3vfLJVcZ59QAI/xkGuigPoWEVo0xwQOrmHgZvG
         +llknKnaKUAXOzinx5ExtHyGDbPgE5bGB/pnb1FjLysYXUDhwnplOXXe90luAkrxNaEF
         /MsQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=RKaQWnWiA/zCcExfi75lqB9ALEnDHuRristulqneTd4=;
        b=nE5+VQAXlT4NVwz+FvS8oAFdKCamzOwOerFRa9bipzc0fVbd+NoldbEaB0SNnmM9td
         NEEe5XrfBlF37iVz7+4S1p0XfmhVsHc6eWDY7JPv5o5R3iXCki63XJMTdwYT8vJu+N36
         DNhbH4MK4TDQzMSMjApxVNf5LaTtIDjrVqENOOX4hsCgoKH0mSGTMHDYrfFuCZYezYwg
         kC8uF19geG+WhDdoj4/snsl1jVEUOMQsXO2BTf5bnFUG+bqmOsCyuEngZnx3ZSd42iTd
         Kus5ly5CFmy087G1MJvfWYMAk1OIHSByjcuR/BONAxKYTLomoz4LskAerK43/aWUx3Ou
         RxmQ==
X-Gm-Message-State: APjAAAVmjyhkEAGonB6+2jyu8Y4toEpY6pNKpWV395/0LWMntvx/TkDM
	S+pWQ74/8I6onniDccU5eBsEyg==
X-Google-Smtp-Source: APXvYqynnJZ0Zi7g4jGmr+xM0aj4NgAU3mYFQCm90qX+6uBLqZGFaKsA8ELnMbT3xzkDRjmj+/uCGg==
X-Received: by 2002:ac8:468f:: with SMTP id g15mr33328922qto.353.1566416891773;
        Wed, 21 Aug 2019 12:48:11 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id q62sm11253497qkb.69.2019.08.21.12.48.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Aug 2019 12:48:11 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i0WaY-0005kK-I1; Wed, 21 Aug 2019 16:48:10 -0300
Date: Wed, 21 Aug 2019 16:48:10 -0300
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
Message-ID: <20190821194810.GI8653@ziepe.ca>
References: <20190816190528.GB371@iweiny-DESK2.sc.intel.com>
 <20190817022603.GW6129@dread.disaster.area>
 <20190819063412.GA20455@quack2.suse.cz>
 <20190819092409.GM7777@dread.disaster.area>
 <20190819123841.GC5058@ziepe.ca>
 <20190820011210.GP7777@dread.disaster.area>
 <20190820115515.GA29246@ziepe.ca>
 <20190821180200.GA5965@iweiny-DESK2.sc.intel.com>
 <20190821181343.GH8653@ziepe.ca>
 <20190821185703.GB5965@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821185703.GB5965@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 11:57:03AM -0700, Ira Weiny wrote:

> > Oh, I didn't think we were talking about that. Hanging the close of
> > the datafile fd contingent on some other FD's closure is a recipe for
> > deadlock..
> 
> The discussion between Jan and Dave was concerning what happens when a user
> calls
> 
> fd = open()
> fnctl(...getlease...)
> addr = mmap(fd...)
> ib_reg_mr() <pin>
> munmap(addr...)
> close(fd)

I don't see how blocking close(fd) could work. Write it like this:

 fd = open()
 uverbs = open(/dev/uverbs)
 fnctl(...getlease...)
 addr = mmap(fd...)
 ib_reg_mr() <pin>
 munmap(addr...)
  <sigkill>

The order FD's are closed during sigkill is not deterministic, so when
all the fputs happen during a kill'd exit we could end up blocking in
close(fd) as close(uverbs) will come after in the close
list. close(uverbs) is the thing that does the dereg_mr and releases
the pin.

We don't need complexity with dup to create problems.

Jason

