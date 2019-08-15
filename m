Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 974AEC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 21:26:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50C33205F4
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 21:26:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vgofVdxY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50C33205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD31E6B0003; Thu, 15 Aug 2019 17:26:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D83F86B0005; Thu, 15 Aug 2019 17:26:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C71FD6B0006; Thu, 15 Aug 2019 17:26:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id A51B46B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:26:19 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 49BE48248ABD
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 21:26:19 +0000 (UTC)
X-FDA: 75825945678.10.skin25_3723d14609052
X-HE-Tag: skin25_3723d14609052
X-Filterd-Recvd-Size: 2274
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 21:26:18 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 95348205F4;
	Thu, 15 Aug 2019 21:26:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565904363;
	bh=5Ugqec8YhmCnrPP32IJ/uvLwQWW92jUjH6BSVw/2Cgk=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=vgofVdxYzsfoQkF8U6ffc2JgVmgrzu1zI+UgfLegltxwbMKjtbCQK6ZUAW3SBNTzO
	 K8//ihIQdaYsxDFhpb8cIGKfdJfZ/EyrSoi3bT7tR0SXLQufSLefkVbCN2U4pkRo6Q
	 PwzLBT5iSvICmjCoo7a0i+OOHz0YYqXbh4v2pmC0=
Date: Thu, 15 Aug 2019 14:26:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: hch@infradead.org, tytso@mit.edu, viro@zeniv.linux.org.uk,
 linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, fstests
 <fstests@vger.kernel.org>
Subject: Re: [PATCH RFC 3/2] fstests: check that we can't write to swap
 files
Message-Id: <20190815142603.de9f1c0d9fcc017f3237708d@linux-foundation.org>
In-Reply-To: <20190815163434.GA15186@magnolia>
References: <156588514105.111054.13645634739408399209.stgit@magnolia>
	<20190815163434.GA15186@magnolia>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Aug 2019 09:34:34 -0700 "Darrick J. Wong" <darrick.wong@oracle.com> wrote:

> While active, the media backing a swap file is leased to the kernel.
> Userspace has no business writing to it.  Make sure we can't do this.

I don't think this tests the case where a file was already open for
writing and someone does swapon(that file)?

And then does swapoff(that file), when writes should start working again?

Ditto all the above, with s/open/mmap/.


Do we handle (and test!) the case where there's unwritten dirty
pagecache at the time of swapon()?  Ditto pte-dirty MAP_SHARED pages?

