Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9E2FC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:13:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CE7120B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:13:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="SfHInPm3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CE7120B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 323016B026A; Thu, 13 Jun 2019 11:13:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D35F6B026B; Thu, 13 Jun 2019 11:13:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19BA46B026C; Thu, 13 Jun 2019 11:13:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECCF06B026A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:13:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l16so16926426qkk.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:13:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KkKhR2elMbqIQhtMNyRPKfFVISR0bn0T2g34f2r/Vr8=;
        b=cWkwQ3EOY/VAhQsyjiOMLZYGJoSKyOxjG1m51i7FdrWh1kX8TsNGAnjHRcCv+Z74W8
         a1PB9Yq2EGiLJoRKI/3ex3cyjVoBLZ5dMWGpzSSBeVMst26WSBrG2p7FXND9AR5ePnJf
         pAbU9DDJXoUbxH+sbaVtgroYlpm7f0oegmDl8dXC8mUrAZ6c0h5ZGPjXcdAbwqFy+/hV
         p2I/a+ZudP++muWZ6RJ7FRLnkYwIzNXu5HfL/9E8mRsR6cc5NDMaH00CWkUog4fzv9M2
         yCRQVHP9LsSfRR2NzM67Pt/wGpVDTkOUtj1KrTNqjBs75QLQjWU6M3lQU23l2LZoU3jI
         qrXw==
X-Gm-Message-State: APjAAAX9xQU/bv2rWxg0D7TKla9ILg04PeYWwMXnasFLDl6BHwLDikoT
	oAyrEe4lv6eYibAjRfMWwxpFxtT+K7a2QoHqe6kZvz3TVON89r23TP+t4AieK3FNsoAJkP+vCGd
	fAMpxwa/3GNImfPCGD3pgHKjPyJZggYiA7jAVmvSEo5LD0OVY/HivTRWCGchmgpwqrg==
X-Received: by 2002:a37:dc45:: with SMTP id v66mr13221265qki.24.1560438836697;
        Thu, 13 Jun 2019 08:13:56 -0700 (PDT)
X-Received: by 2002:a37:dc45:: with SMTP id v66mr13221219qki.24.1560438836108;
        Thu, 13 Jun 2019 08:13:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560438836; cv=none;
        d=google.com; s=arc-20160816;
        b=n5Z9hotJkvXETxfMCNmsbzQh6yCOvT/zakqDVHSPD15UgdmSSpg3m9+KLPftvyOeH2
         NwBWpnnreBbJACvptv/P/RMlR7RbSwvjYXcWJiy9anYR569+x03l0ipbP/LC4chrGCeW
         OkKegHTGV8Aal3Vmu1eY8V4iFDFDjCWYPnkNQZmkXz+fYrwwSqmwclyV8/hDxedFfS7f
         0impjOK9zIfb/na/UkMBgY5Cgis2kwPEGomuGjRlzCUwSK5Y/2FXcvynxdHhe0cGi4B+
         WoPuEk4l+mbKhaptGU40XTibR+6kq1LC6LHzNM1yc5eDJjJ7vKQ50Q4x/6iaDKe/6G0v
         Yuug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KkKhR2elMbqIQhtMNyRPKfFVISR0bn0T2g34f2r/Vr8=;
        b=HZl6lyEcv269TYBXyA2fRbKgtkYv31cVFXqNxyyGGcDZ+xzq3wxXtmaRSPc/MueSQT
         IRo1y2JdGmYsXsWFND5MrdTquF+5aJB/qSRaQFr0oxX5h5FEneFKU4Oje7vA611608Hl
         CEZfy5edvThWT7gPy4Wfyfh1WCmu6sKvQBofEV+lY3IcbkRrM3qtzoQPUIa+M8oGEP2O
         lhY5P09XjIysUeA3wxui5McrsGBMj93BST+prplb7qVe+mSRZ+OMQcmdeEzCzkAPaOqg
         l4TXpZ3cws+yyF1LB0eNRj+YKsq//QBWfqzTzHzZxPG5Vy/IfQN/A7CWxXQqhMv6l+q9
         t2yA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=SfHInPm3;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r21sor430293qtm.41.2019.06.13.08.13.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 08:13:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=SfHInPm3;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KkKhR2elMbqIQhtMNyRPKfFVISR0bn0T2g34f2r/Vr8=;
        b=SfHInPm3DzZYLPoEmUVQqUjB5LScF9DsUpJ4xj+NyGtlotEBCDOd7k0OAiLknLgpy1
         UwRMpQmGSzJF0gJD/kcFMjRmesoOZkKPKtk3EWMStIXtk1BSmgVZYNk1p6EKmXc4imPv
         1V1hEuNESlphnwH9Ffq42vPqvIo/88Zh85Tr1f4Tsa8YuL7Uls35977s64dpr/1WcL8J
         ZbYx/FYbcjhIEQbbmhQgdZInCU3g7QIDiBsNO/6qOPrD5yA2TBMRXmDe20WR5bhjdxVZ
         hMtmCv3lKFvdGH4OgmFjKOdFtkKSEmGywoQe1a2KSSYQTb19JMjkAlD66sOEA23ZLtm9
         d4ZA==
X-Google-Smtp-Source: APXvYqxrIgS7SEgThFO4xWkROTtAeKu9gS/7k/Y8mWYSTA6O8BjyUZUk4XGZHPcLg6c7oSu9BznGCA==
X-Received: by 2002:ac8:2f90:: with SMTP id l16mr60699198qta.12.1560438835818;
        Thu, 13 Jun 2019 08:13:55 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c18sm1546907qkk.73.2019.06.13.08.13.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 08:13:55 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbRQI-0001rX-U0; Thu, 13 Jun 2019 12:13:54 -0300
Date: Thu, 13 Jun 2019 12:13:54 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs <linux-xfs@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	linux-ext4 <linux-ext4@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190613151354.GC22901@ziepe.ca>
References: <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca>
 <20190612120907.GC14578@quack2.suse.cz>
 <20190612191421.GM3876@ziepe.ca>
 <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
 <CAPcyv4gkksnceCV-p70hkxAyEPJWFvpMezJA1rEj6TEhKAJ7qQ@mail.gmail.com>
 <20190612233324.GE14336@iweiny-DESK2.sc.intel.com>
 <CAPcyv4jf19CJbtXTp=ag7Ns=ZQtqeQd3C0XhV9FcFCwd9JCNtQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jf19CJbtXTp=ag7Ns=ZQtqeQd3C0XhV9FcFCwd9JCNtQ@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 06:14:46PM -0700, Dan Williams wrote:
> > Effectively, we would need a way for an admin to close a specific file
> > descriptor (or set of fds) which point to that file.  AFAIK there is no way to
> > do that at all, is there?
> 
> Even if there were that gets back to my other question, does RDMA
> teardown happen at close(fd), or at final fput() of the 'struct
> file'?

AFAIK there is no kernel side driver hook for close(fd). 

rdma uses a normal chardev so it's lifetime is linked to the file_ops
release, which is called on last fput. So all the mmaps, all the dups,
everything must go before it releases its resources.

Jason

