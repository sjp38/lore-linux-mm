Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6989AC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 19:09:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F0252080A
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 19:09:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FGUGQXDg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F0252080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5B838E0057; Mon,  4 Feb 2019 14:09:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E2628E001C; Mon,  4 Feb 2019 14:09:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 884888E0057; Mon,  4 Feb 2019 14:09:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 431158E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 14:09:38 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id l9so560459plt.7
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 11:09:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MtMB9MTpgmr1BCRNMWDvA5NXWtOVSM9dan7iTMIlXJQ=;
        b=HKW1LfkrTzHFf306yiCUAsUy2ww7QpN0CSFECVj5DZE743fuofCZ4KDOj4vvTucFwM
         SlDOit6urrbbRQD5uO4yDTGYWO5CbNnNKuD9ZbIaaQpdIwN74FuOXZckcyso/W5rSuUd
         3zQfNz2txYJBQs9+Io/6FrGsBVAz4Ivudf8dmm+hO+FK2nXKzCKF470ku0J+cHcrQerm
         mZDei8yUEj0wzWpW61KKZQrSPBcnYVmIr4p44qjTYGil3+VOzhjrVQTEIoWn4FbQPV6O
         7ZeKIOSoCQt9ej2N2BnxXshWYwE7QZyJ4x0p3rvxvX/gLPV4q0WtKomH5EEHaQiVw8JQ
         3yyA==
X-Gm-Message-State: AHQUAuYDDaRTGukaKL//y12zD78ous7cItvXoliL2ra59ReZDxrMCjyZ
	G/luK4lWt/zQ9Y83HAeN2IIvyiDAGjAuRbY+AN3dZrEBABaecBFJK6KkMc9mjdZmjv/zw4r9SJh
	yR67gI8vWh49wo36CEmltlnesXvs9uUu+rxK6IKWew3lob7iE+jT8e8OPsQNzFqkbYg==
X-Received: by 2002:a63:d747:: with SMTP id w7mr811983pgi.360.1549307377849;
        Mon, 04 Feb 2019 11:09:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZkznOIRyAUlUouhz+q5eDTixCP0RR4WpT06tczXwAjfnPNQypQGa941exhyTw0hBply3kf
X-Received: by 2002:a63:d747:: with SMTP id w7mr811934pgi.360.1549307377069;
        Mon, 04 Feb 2019 11:09:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549307377; cv=none;
        d=google.com; s=arc-20160816;
        b=SB+6yUe9VfJGqeEmQ7zL65g6u8Y5AcYITU0Ns43TYhiVUSFXzVuf4aBl+bOZtCoypB
         y1M3ajs7LzvV2hXrL1/GND4qUNV1vQ5eC1IXLzXco3+x0dGkDKaZFCLMvTw3z+Oj5fp8
         vAT+9Rn0dbwMtp7RlfRmSvk5uqP32iMZyRSqEK5Khdpg0Z5xMtpYX3WnJBz8PTendptM
         3MXV+PSk7ciceSXfKX1hnuARLaSaDOuV6fsXf2sP+PSPO8rUkAMLzPTaJQxYX4AZMSOD
         3lBzmd6lhnVeYC8bdyK4nzMmj+9n1rSg9R7sB2dALKjGfGYEl7Z+pz2nRX0kxbZ5Lqgn
         N9iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MtMB9MTpgmr1BCRNMWDvA5NXWtOVSM9dan7iTMIlXJQ=;
        b=orF9/OJ4C42KlIo2SZWMpWkheDWdKaAGNTAuXzM5vDgHjtPmpKvN0APMcyZk8lxnOY
         vOKCiZuTs1FlJTq9cFosRjkKvaFa/w5dscTccCJ28fgjYOAD/sOqpP66qMngMwAleuRk
         VeQ8MSaOhyNfogAwz3T6t4w7FJ2Bg0PnCeogFhCJ4XRf5732y9esoZBVr6in31aCEayL
         6iyNe+fYTCIBPhyMXsF6YapI+RG44HWltKNM+H/2M52/T2ADpvdKiK4qTB33ijVm7Yhy
         PUY6nT7icG0TWNbLa78l7ImdethmHw62iDZlf4R0iMg1M1psNAJ8U39e3BRy+5rXYyPK
         D5rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FGUGQXDg;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d34si824268pla.80.2019.02.04.11.09.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 11:09:37 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FGUGQXDg;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=MtMB9MTpgmr1BCRNMWDvA5NXWtOVSM9dan7iTMIlXJQ=; b=FGUGQXDgOr8ZcEZwwE4Ok29No
	isAsaok6MHTNDkHfzs+oKLY+BVx4RxoDnK2NdDOUUlXrq0Dp0wpCbo+mFCPoGsI7Ht3QfesusXvSd
	Gb1R2G80avdRDh4s8V71Ge1MGJ7Y+G5JYyvNP7/4UKiEoTAS243rvxCxl24o4639/aisINDjmQH/8
	3IPLiJ+8dM5eUIHJ21yBvcUI8lmF6Sc13jjKROMJz8vBZ3ZVMjlUG4RnP1ft7CP8X9niJG2iCE6aj
	C3E+Gr341sVnU6Awoyea9ahuSMzyPFV0p8gMMJSFTN3ZuVwWlwW3QX3kpfqkH3T3NenVu9AsyFgJq
	SAPhH+2XA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gqjcc-0008F9-Bv; Mon, 04 Feb 2019 19:09:34 +0000
Date: Mon, 4 Feb 2019 11:09:34 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Christopher Lameter <cl@linux.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
Message-ID: <20190204190934.GE21860@bombadil.infradead.org>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@email.amazonses.com>
 <20190204175110.GA10237@ziepe.ca>
 <01000168b9be8b5a-3b4f8036-50c8-4180-b39f-9ef28cb60cce-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168b9be8b5a-3b4f8036-50c8-4180-b39f-9ef28cb60cce-000000@email.amazonses.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 06:21:39PM +0000, Christopher Lameter wrote:
> On Mon, 4 Feb 2019, Jason Gunthorpe wrote:
> 
> > On Mon, Feb 04, 2019 at 05:14:19PM +0000, Christopher Lameter wrote:
> > > Frankly I still think this does not solve anything.
> > >
> > > Concurrent write access from two sources to a single page is simply wrong.
> > > You cannot make this right by allowing long term RDMA pins in a filesystem
> > > and thus the filesystem can never update part of its files on disk.
> >
> > Fundamentally this patch series is fixing O_DIRECT to not crash the
> > kernel in extreme cases.. RDMA has the same problem, but it is much
> > easier to hit.
> 
> O_DIRECT is the same issue. O_DIRECT addresses always have been in
> anonymous memory or special file systems.

That's never been a constraint that's existed.

