Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 316F8C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 09:27:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04D3220684
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 09:27:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04D3220684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 876456B000E; Wed,  5 Jun 2019 05:27:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8279A6B0010; Wed,  5 Jun 2019 05:27:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73D726B0266; Wed,  5 Jun 2019 05:27:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 26ED86B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 05:27:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so4868987ede.0
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 02:27:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nYMw2T4cHcKFpl3VBRUrIE9m+Z0UB6UWpDLaPpSv9/k=;
        b=J9DkUc5xCoUjRPEi4HEs8Bsip/m87zePWOYOdjrSAU7zAi8KikDsSJwTN/V/auCvBu
         g9F1uw3jasSoojJlCRJWvZBWZm4ISHZj8f6FBPkdVc2891ihM4B0vVbgzlUWClOMhzg5
         vt9Ep/Rh8lMDrijyjEMjhPQKdfBe2tk1uxgD91R968tiJo6V/8A7SDYBHtgHg6DsfwBJ
         VW8kPlHWav0FMoLKTpA+BAdxOp7UX9Ww3ACEIkdvoKQ6KUI+UXqPG9DFKFTtOv+2+JK4
         lm797txB3H6Gms2DYgCZo9B4xsSOleaJLDrwVBzCX2y+9H/3O+5S1TFYHys351+Gtplq
         v7hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAV/M7Kuj9ZIoo4RY3xubi9ghAwlMw3qe8ZLorBk/GRv3pN8YrTF
	pllQcBn8g0osgfl4xKQN1fJ0x9DO+wq9qr3SHp1CFEHwFrRENrAMQmreJMp8t6jUSQM2ZxNYR5d
	LtFZU/g183dJlyxHTSxcdP/farjn0178TIZxpotCwHpyTa/CLlMEIdzLS8ETOgoK4Gg==
X-Received: by 2002:a50:9965:: with SMTP id l34mr6389863edb.152.1559726850709;
        Wed, 05 Jun 2019 02:27:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx776bdLJ4UjVCT7aE+2067+YEn0hChrognovl2b2ajt15ELJeDhPyuzmTGichrQSwc1fLK
X-Received: by 2002:a50:9965:: with SMTP id l34mr6389778edb.152.1559726849669;
        Wed, 05 Jun 2019 02:27:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559726849; cv=none;
        d=google.com; s=arc-20160816;
        b=N7fLIghe3YN1VavFEL8UOmQVXDd2fmG7IwT7r0qWZtGEP+l489MrcBd6BbmWxQikmz
         fC2s1iGvXtAeqy/J/Rc39zI/Eekf0bFkn24SUpfCtJr5vvJp5iAK33WoaVhPyG0vbJTP
         KuhS7KZgESeUPW6BRIXcjDRoFytwSi98tQ/p4fMkMuyRwdA2eOQYm+cDX4knalAHu4Ws
         rLlwg7yWP4Vu48Giio0qNel1ObLLW73GCBAAVqQfGjApoMYRh9ZeZ9t1AfBeD+KSF6PP
         CCZDXRBa3An7bUGOlcLU6LQBho+4gin6NxO1Nw2uFsXFvTE1Ocxwt1oztD67c9R/r78j
         WiuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nYMw2T4cHcKFpl3VBRUrIE9m+Z0UB6UWpDLaPpSv9/k=;
        b=NWG2J9mRlJivkXOmLk58zQXlAEqcdESHVaAbSaaAAe3EYAXhViGPOR0y7f4kBEDn9r
         4GvBMJR0zbqUiJFiGu/PZjFD5V8rUlH2X6esU+JATJYQKyTAWPTMxNbmjwJ7Yj3LYuQr
         ganT40hORdJgMgDEEh89dQ7g9BTGP8zeEcRxW3FeXVBSFFQcb7MRRVhQJQb0JOrIoSZZ
         sQeix74d8EL6bIm5gZTuh6nr686BHSZZ8M4X8SoEy39mTRI+0e72Bao8TMf9i71fB1RM
         Cd8vNI+F5qV9XvA+pnK68XAkmyNUrTzPXbP2p7tpeA+KVlL/pFhmiWaETNgkQAHHoC97
         zGcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c62si4109233edd.451.2019.06.05.02.27.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 02:27:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 19441AEA3;
	Wed,  5 Jun 2019 09:27:29 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 556701E3C2F; Wed,  5 Jun 2019 11:27:28 +0200 (CEST)
Date: Wed, 5 Jun 2019 11:27:28 +0200
From: Jan Kara <jack@suse.cz>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org,
	Ted Tso <tytso@mit.edu>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH 2/2] ext4: Fix stale data exposure when read races with
 hole punch
Message-ID: <20190605092728.GB7433@quack2.suse.cz>
References: <20190603132155.20600-1-jack@suse.cz>
 <20190603132155.20600-3-jack@suse.cz>
 <20190605012551.GJ16786@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605012551.GJ16786@dread.disaster.area>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 05-06-19 11:25:51, Dave Chinner wrote:
> On Mon, Jun 03, 2019 at 03:21:55PM +0200, Jan Kara wrote:
> > Hole puching currently evicts pages from page cache and then goes on to
> > remove blocks from the inode. This happens under both i_mmap_sem and
> > i_rwsem held exclusively which provides appropriate serialization with
> > racing page faults. However there is currently nothing that prevents
> > ordinary read(2) from racing with the hole punch and instantiating page
> > cache page after hole punching has evicted page cache but before it has
> > removed blocks from the inode. This page cache page will be mapping soon
> > to be freed block and that can lead to returning stale data to userspace
> > or even filesystem corruption.
> > 
> > Fix the problem by protecting reads as well as readahead requests with
> > i_mmap_sem.
> > 
> > CC: stable@vger.kernel.org
> > Reported-by: Amir Goldstein <amir73il@gmail.com>
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/ext4/file.c | 35 +++++++++++++++++++++++++++++++----
> >  1 file changed, 31 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> > index 2c5baa5e8291..a21fa9f8fb5d 100644
> > --- a/fs/ext4/file.c
> > +++ b/fs/ext4/file.c
> > @@ -34,6 +34,17 @@
> >  #include "xattr.h"
> >  #include "acl.h"
> >  
> > +static ssize_t ext4_file_buffered_read(struct kiocb *iocb, struct iov_iter *to)
> > +{
> > +	ssize_t ret;
> > +	struct inode *inode = file_inode(iocb->ki_filp);
> > +
> > +	down_read(&EXT4_I(inode)->i_mmap_sem);
> > +	ret = generic_file_read_iter(iocb, to);
> > +	up_read(&EXT4_I(inode)->i_mmap_sem);
> > +	return ret;
> 
> Isn't i_mmap_sem taken in the page fault path? What makes it safe
> to take here both outside and inside the mmap_sem at the same time?
> I mean, the whole reason for i_mmap_sem existing is that the inode
> i_rwsem can't be taken both outside and inside the i_mmap_sem at the
> same time, so what makes the i_mmap_sem different?

Drat, you're right that read path may take page fault which will cause lock
inversion with mmap_sem. Just my xfstests run apparently didn't trigger
this as I didn't get any lockdep splat. Thanks for catching this!

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

