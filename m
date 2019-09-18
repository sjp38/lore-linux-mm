Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA7ACC4CED0
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:31:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74097205F4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:31:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74097205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BEC26B0007; Wed, 18 Sep 2019 08:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06D2D6B029C; Wed, 18 Sep 2019 08:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC5656B029D; Wed, 18 Sep 2019 08:31:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0164.hostedemail.com [216.40.44.164])
	by kanga.kvack.org (Postfix) with ESMTP id CB5AD6B0007
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 08:31:16 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4DADA8243772
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:31:16 +0000 (UTC)
X-FDA: 75947976552.19.cook52_7f7237bebc01a
X-HE-Tag: cook52_7f7237bebc01a
X-Filterd-Recvd-Size: 2984
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:31:15 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ED106AD2B;
	Wed, 18 Sep 2019 12:31:13 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 07F751E4201; Wed, 18 Sep 2019 14:31:24 +0200 (CEST)
Date: Wed, 18 Sep 2019 14:31:24 +0200
From: Jan Kara <jack@suse.cz>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Jan Kara <jack@suse.cz>, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	Amir Goldstein <amir73il@gmail.com>,
	Boaz Harrosh <boaz@plexistor.com>, linux-fsdevel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH 3/3] xfs: Fix stale data exposure when readahead races
 with hole punch
Message-ID: <20190918123123.GC31891@quack2.suse.cz>
References: <20190829131034.10563-1-jack@suse.cz>
 <20190829131034.10563-4-jack@suse.cz>
 <20190829155204.GD5354@magnolia>
 <20190830152449.GA25069@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190830152449.GA25069@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 30-08-19 17:24:49, Jan Kara wrote:
> On Thu 29-08-19 08:52:04, Darrick J. Wong wrote:
> > On Thu, Aug 29, 2019 at 03:10:34PM +0200, Jan Kara wrote:
> > > Hole puching currently evicts pages from page cache and then goes on to
> > > remove blocks from the inode. This happens under both XFS_IOLOCK_EXCL
> > > and XFS_MMAPLOCK_EXCL which provides appropriate serialization with
> > > racing reads or page faults. However there is currently nothing that
> > > prevents readahead triggered by fadvise() or madvise() from racing with
> > > the hole punch and instantiating page cache page after hole punching has
> > > evicted page cache in xfs_flush_unmap_range() but before it has removed
> > > blocks from the inode. This page cache page will be mapping soon to be
> > > freed block and that can lead to returning stale data to userspace or
> > > even filesystem corruption.
> > > 
> > > Fix the problem by protecting handling of readahead requests by
> > > XFS_IOLOCK_SHARED similarly as we protect reads.
> > > 
> > > CC: stable@vger.kernel.org
> > > Link: https://lore.kernel.org/linux-fsdevel/CAOQ4uxjQNmxqmtA_VbYW0Su9rKRk2zobJmahcyeaEVOFKVQ5dw@mail.gmail.com/
> > > Reported-by: Amir Goldstein <amir73il@gmail.com>
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > 
> > Is there a test on xfstests to demonstrate this race?
> 
> No, but I can try to create one.

I was experimenting with this but I could not reproduce the issue in my
test VM without inserting artificial delay at appropriate place... So I
don't think there's much point in the fstest for this.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

