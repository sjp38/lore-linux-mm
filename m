Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70AE3C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 21:39:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D55D21A4C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 21:39:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="twaohtH3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D55D21A4C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C8486B0003; Mon,  9 Sep 2019 17:39:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9791C6B0006; Mon,  9 Sep 2019 17:39:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 867A26B0007; Mon,  9 Sep 2019 17:39:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0075.hostedemail.com [216.40.44.75])
	by kanga.kvack.org (Postfix) with ESMTP id 67E246B0003
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:39:43 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1BAACAF8F
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 21:39:43 +0000 (UTC)
X-FDA: 75916699446.17.robin43_1a957bbe00906
X-HE-Tag: robin43_1a957bbe00906
X-Filterd-Recvd-Size: 2491
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 21:39:42 +0000 (UTC)
Received: from gmail.com (unknown [104.132.1.77])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 272BD21924;
	Mon,  9 Sep 2019 21:39:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1568065181;
	bh=+nUsbZO4jDJQKcj0U8bhaPUEL9Ppt9f9/QlIFDNBlZo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=twaohtH3xoKch2HMq/i9HVENozwbITC9sJ5WAC3reHThd59txrZjOMIerExBu/7lH
	 /HgH1sJXxuUEdsP07RzvjWwjSJETSWH2zvTKHSYF0vpC6JlCf9IULO11R0YtGM6IDg
	 AoFd4c7VbvrhRjQ7ONfdhd7hLZEIgVn9KCXA+JbA=
Date: Mon, 9 Sep 2019 14:39:39 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Janne Karhunen <janne.karhunen@gmail.com>
Cc: linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org,
	zohar@linux.ibm.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk,
	Konsta Karsisto <konsta.karsisto@gmail.com>
Subject: Re: [PATCH 1/3] ima: keep the integrity state of open files up to
 date
Message-ID: <20190909213938.GA105935@gmail.com>
Mail-Followup-To: Janne Karhunen <janne.karhunen@gmail.com>,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, zohar@linux.ibm.com,
	linux-mm@kvack.org, viro@zeniv.linux.org.uk,
	Konsta Karsisto <konsta.karsisto@gmail.com>
References: <20190902094540.12786-1-janne.karhunen@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190902094540.12786-1-janne.karhunen@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 12:45:38PM +0300, Janne Karhunen wrote:
> When a file is open for writing, kernel crash or power outage
> is guaranteed to corrupt the inode integrity state leading to
> file appraisal failure on the subsequent boot. Add some basic
> infrastructure to keep the integrity measurements up to date
> as the files are written to.
> 
> Core file operations (open, close, sync, msync, truncate) are
> now allowed to update the measurement immediately. In order
> to maintain sufficient write performance for writes, add a
> latency tunable delayed work workqueue for computing the
> measurements.
> 

This still doesn't make it crash-safe.  So why is it okay?

- Eric

