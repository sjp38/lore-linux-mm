Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4060FC43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 22:16:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E84D220643
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 22:16:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E84D220643
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 716A18E0003; Tue,  5 Mar 2019 17:16:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69D248E0001; Tue,  5 Mar 2019 17:16:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 565508E0003; Tue,  5 Mar 2019 17:16:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 103B38E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 17:16:39 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 19so10964178pfo.10
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 14:16:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mKtgw3ilUJZ2R3ElZINuJN8AwBZAcecpPbnux5nTaiQ=;
        b=cFgDRdch+qyotvaLhBxm9lUkLaNHCMYp/4s3VQ64u176tHY8ibU+azSoCWouYoEBI7
         XUPS7GeDx4Q+cao3wK3a8He87Xhux5Rb3xo75s8sjITDA8wIF+MrBNU/nNhMpMDbSEWB
         pxU9TzqoMccExJtnGvfe33dXTkCU8NYHSE6sM+uKNljhhxEg0QneNdoTyl+jhb6IxoAH
         dVhNk3clrPNDEFs+SQFdjGsIvBJoxysUBcJkWURXFUi1uMc4f2dAM/0/6mY1djkTD3uf
         RwH+/FB5hyjA/Dwe9etKqKlnjzmW3knLVqho++koT7zl7WmRuaiom6FADhDQ68M3k5o7
         QUtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVfOAO0sasUIBUmrt5vt/LEcfK0Nbu/hlcSyJ8Rui1ww9RA21DB
	GIXBZw12WZEInAFzwSB5HcaK0sUKZvlMqiOjLYtVjkmFrOEsmO0e9AakuBSeSAHgh+GbsKeldNu
	NwyF4NHecZn2HkAaviuAbIKBMWxbHQPcq44yp0qzN08q4SXDh+RNaw7FwTRGxJflXfw==
X-Received: by 2002:aa7:9259:: with SMTP id 25mr3955226pfp.221.1551824198666;
        Tue, 05 Mar 2019 14:16:38 -0800 (PST)
X-Google-Smtp-Source: APXvYqzc/4YQJgoQ2zmbWXv5FrOIsH4p4GJ6BA/b4NQRyb9pPy+L7RCPkQw+Myu6oeef6bqluwBb
X-Received: by 2002:aa7:9259:: with SMTP id 25mr3955156pfp.221.1551824197538;
        Tue, 05 Mar 2019 14:16:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551824197; cv=none;
        d=google.com; s=arc-20160816;
        b=AScTEbO7dodATPk6nI0RORXXimQF+Xk+j0/+3QlrhSDU8yWvd3dwPgxKin4LFZWQ8u
         KYIsylp7UyCi2WzzTC/K67uDS10p8KwzH0nP3Rv5D3hALb7XMa+AgVXTesALORkc/seb
         xfQ1IhdngYyuUJxCmXYH9NXLZo3Cpko7GfLedigsPKdNyJRaNnBgv210FhufAZNAnOg6
         8+Uc2J2/8KtLrlsoiZavMff25HQFraVqSyjiTYjLqYcQSeeqa4nrOZm4oY8MrlFZiyxT
         rDaTvDUt0j+Q76kuctIqm7vuae3cxB/UC8j5BYLNcY5PyUigFWZkLp03q5miIsxQtjd5
         V9sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=mKtgw3ilUJZ2R3ElZINuJN8AwBZAcecpPbnux5nTaiQ=;
        b=xsRzETYqDGbQV5FqSXdQeo6LbFxKSxe64+65z+c5mELF4qXGmBv7TOaNCustuvg3Ae
         kJMzO8sgLBBWnJHgCapKcGfYWxA9cEByoJoe+Ks3x2FpRiEzdc6Rg5fhlsqsi3QfxTb9
         /cE2YyeI5mnGK0flH76m1TCw6LQDpor9okCj3/eOe6M2n668bNq1hQxXEAjkJFegoP7r
         cBUYyoHYe2/cAUzLONnuz932aSmMCUzOLEAgkW2QGp2sICN0LteHxg0vijLeLNLMyZAc
         L34/Lct0gq8pnLotCuCWpyPg80J82edBBE1eg2EulQuv9kwBdridwBUsY4QvbW3AlGio
         Z7mA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j70si8590989pge.271.2019.03.05.14.16.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 14:16:37 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id CF4F3102C5;
	Tue,  5 Mar 2019 22:16:36 +0000 (UTC)
Date: Tue, 5 Mar 2019 14:16:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell
 <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, linux-fsdevel
 <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-Id: <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
In-Reply-To: <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
References: <20190129165428.3931-10-jglisse@redhat.com>
	<CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
	<20190129193123.GF3176@redhat.com>
	<CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
	<20190129212150.GP3176@redhat.com>
	<CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
	<20190130030317.GC10462@redhat.com>
	<CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
	<20190130183616.GB5061@redhat.com>
	<CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
	<20190131041641.GK5061@redhat.com>
	<CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2019 21:44:46 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> >
> > > Another way to help allay these worries is commit to no new exports
> > > without in-tree users. In general, that should go without saying for
> > > any core changes for new or future hardware.
> >
> > I always intend to have an upstream user the issue is that the device
> > driver tree and the mm tree move a different pace and there is always
> > a chicken and egg problem. I do not think Andrew wants to have to
> > merge driver patches through its tree, nor Linus want to have to merge
> > drivers and mm trees in specific order. So it is easier to introduce
> > mm change in one release and driver change in the next. This is what
> > i am doing with ODP. Adding things necessary in 5.1 and working with
> > Mellanox to have the ODP HMM patch fully tested and ready to go in
> > 5.2 (the patch is available today and Mellanox have begin testing it
> > AFAIK). So this is the guideline i will be following. Post mm bits
> > with driver patches, push to merge mm bits one release and have the
> > driver bits in the next. I do hope this sound fine to everyone.
> 
> The track record to date has not been "merge HMM patch in one release
> and merge the driver updates the next". If that is the plan going
> forward that's great, and I do appreciate that this set came with
> driver changes, and maintain hope the existing exports don't go
> user-less for too much longer.

Decision time.  Jerome, how are things looking for getting these driver
changes merged in the next cycle?

Dan, what's your overall take on this series for a 5.1-rc1 merge?

Jerome, what would be the risks in skipping just this [09/10] patch?

