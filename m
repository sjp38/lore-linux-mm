Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CAE2C282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:52:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4858F206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:52:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="UeDKl0Kc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4858F206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF2D28E00ED; Wed,  6 Feb 2019 13:52:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7C158E00E8; Wed,  6 Feb 2019 13:52:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1ED08E00ED; Wed,  6 Feb 2019 13:52:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7CF8E00E8
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:52:36 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id f69so5906155pff.5
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:52:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7kkFe7VdBrYTS6xqWBGiPDeMMQbpDhl/VS6LUReyUBQ=;
        b=DfMiFpV1SNDr8ahSRfi7wdWkWHBOTIhtBofxWygvOuPGQB1DKWGeECwfXQV9MJ084r
         5+TiYMTZZuAcHPz5JoYCbpjw+CyHECHXXO5aRViHsQk3vu78jEcWhmCm2d6nB72gKJAH
         9L0iwLNcua1rpiiGxvcHDkbOMx2/8Kt4vuw7ZwEMNVNWZZWhJZDucCunM2UpVqEwSJNK
         qej1hwF1iwkp14/YD6ANMpBkMlLgT+q+PgopVLwsNU/SyQ1nYNF4IfqcpHywfWkt+by0
         EzB35kLuzsOnONJz/uSL93DqBohpk8HlogvqYLsTD6ynywjPKrf2K49QuBWxcLQ+cwuG
         zBIQ==
X-Gm-Message-State: AHQUAuYjkaxfTUR1PpT0Y74DOKTA4sGwM5/yPJ1x7ALhVVE/Ew082RwT
	h1R2xLVxsJ6pR9ZoImejLQ5UuOQm22RBK+Sm8mg7mioONE5L/0ExdUSi2Y07UH/TMx58RrlzoEF
	AQ9snkqrAS/3PKWQXAxwxFTjYM5a6WoVzf33c+eQtJ2zhhtX2QGHLD0DIrr3S144krEcp0KOQQG
	JCQGf+2Ks7eRvQJKFsGr1DbfrZetkl+g0As0vyJlNEXdllBL26f9TsV+qfUmp+feDwQrLpfr0Ie
	QyXgVq9jwTvm6ohrSyX38oJs2uG5uFWfUphXCSJ02/1kSKIJH+xdd5OMoYNxOEBMs+MacC8cRmk
	foDHTKqs0QcpkR3si6KSEHwsiNcOROJOa3N5w+9BsFm/4QgyMxM20MhShSkjchrtkdgzc7cSE0k
	h
X-Received: by 2002:a62:ea17:: with SMTP id t23mr3525293pfh.46.1549479156124;
        Wed, 06 Feb 2019 10:52:36 -0800 (PST)
X-Received: by 2002:a62:ea17:: with SMTP id t23mr3525263pfh.46.1549479155504;
        Wed, 06 Feb 2019 10:52:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549479155; cv=none;
        d=google.com; s=arc-20160816;
        b=uZfGCiSw7vvgxWnnltDGlHMALjG+Hjr0Gw1/7ORujggdTCyDeq6PRP0S3Zi4LJLY8V
         kHirL4nnrnZ5KYRAB2bYnSSeFHRBH+ZkfaNMOVJ485I9DgA+F166DPvev23BhFcRpbK5
         uk2ZVBw3F6Mm7HBcFeRQ1Q5eMzBHtePzeGUMgGmyjfJ2nO9LRkNiBOGqen6DACDGKt8g
         kQY1VysaAdodf/XgteLyJAfTshRueH3QyarFiwlHF+pJIQbyYKGcIX9T8YLlZQAaC9ac
         Fj0GRcYNiltL9D3YMmleYKolCcSOX6Mjv2WXwUEhW1Kod8pIVdv43uN7CVB1HV2zYSEt
         hYBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7kkFe7VdBrYTS6xqWBGiPDeMMQbpDhl/VS6LUReyUBQ=;
        b=g4hF/VE4V2ZiECwck4sRi2lUdOwsramxVqXbYGv/UHuDKQ3MvogcYzqJT9tyE2+Ng3
         gJhZJA2dKZhNdJmBWsZOraAAl5yFLBY7nIRBPYYZz66Mj8IHD8CWgAlKb9ydCX/qqBQT
         xkxsYVsn3KUwcq8jTgBf6G4xd6d174ePOkGnXli2zuWWT4brfJ0vnaTOZvdae47AdfTI
         kBikl1FjAAbS4pnA3RwLyjO/URTRSkGOnE719tIBgyoc+DoHnAadHWZfsgvIhHz2By88
         pYc+Oq3LHYZGkntDHVmxujnjAzXbAm+LZtle3AZpbXGNP+Wac5aNk4iCLh/WfQ8li46r
         rv3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UeDKl0Kc;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k19sor10396612pls.61.2019.02.06.10.52.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 10:52:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UeDKl0Kc;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7kkFe7VdBrYTS6xqWBGiPDeMMQbpDhl/VS6LUReyUBQ=;
        b=UeDKl0KcK9Kh84HZYa+Kne8AvZDEZqJjKRI+db+e6qNigCbKK9k11LicvJ+v6NwMTL
         ikRkpAlhvpX+VwaJ5A5gEjhJJXGFoq3jYEi61RKLq4bHORjLX84v80uvJkRxuk3lIuPg
         qFRlyaK6OFtCH5ONOXEE/30mb9WgiDfve0J3SRETcJD0rNpKRgy1TX2J5tsyhLk0h0VD
         E7PqtsWopoi/2QtU/oSqwAPBSJKr25LnINrMPtLfGvojjf3wUW76x/pbiHk+Ro2ikOTW
         J5/jh+VVhlV11sOMR+jf+9CM9/YgCQWiKt4POuKeRh6GzUWk0/q9DXC6VSo2sjfDS0zZ
         pBDQ==
X-Google-Smtp-Source: AHgI3IatX2FVUNy8ZnyYH2Fw5fpeSFfpCk+VVQB6B+D6cnVwuZwhknf53tZzWm/cIRrvMjAPeVeTaw==
X-Received: by 2002:a17:902:8497:: with SMTP id c23mr12071867plo.64.1549479155012;
        Wed, 06 Feb 2019 10:52:35 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id 64sm9553472pff.101.2019.02.06.10.52.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 10:52:34 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grSJF-0004c2-Pk; Wed, 06 Feb 2019 11:52:33 -0700
Date: Wed, 6 Feb 2019 11:52:33 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Matthew Wilcox <willy@infradead.org>
Cc: Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206185233.GE12227@ziepe.ca>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <20190206183503.GO21860@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206183503.GO21860@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 10:35:04AM -0800, Matthew Wilcox wrote:

> > Admittedly, I'm coming in late to this conversation, but did I miss the
> > portion where that alternative was ruled out?
> 
> That's my preferred option too, but the preponderance of opinion leans
> towards "We can't give people a way to make files un-truncatable".

I haven't heard an explanation why blocking ftruncate is worse than
giving people a way to break RDMA using process by calling ftruncate??

Isn't it exactly the same argument the other way?

Jason

