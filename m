Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A235C742BB
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D6CC2166E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:00:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D6CC2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA81A8E013D; Fri, 12 Jul 2019 08:00:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D57B18E00DB; Fri, 12 Jul 2019 08:00:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C20018E013D; Fri, 12 Jul 2019 08:00:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 76DC48E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:00:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b21so7611308edt.18
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:00:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NyB2YVsqbEsNi8RJ9mW2FFLpWdsvFNEAzwh5YIwJ4Og=;
        b=PTWRb/IwVJMOFUxY+fp2WJGvrP5UDlfFxAdnWmCCJT3yaMAP0jW+gRORxZmcEZiqv8
         xg6qSTZgY/RLsz1e7n600EzJ5tbwm8Mmz/jzmpDabqGnc4Cw08PwLgB7d24ZuqhAP6cL
         FHihBfsjqrL5UU+sO+6r2TZfIrTjYdJz1+5CnPxJRk3/1uwWg6N/IRnP8/qTZWiFGIDV
         X9fRFOF7CQ8o7a7mo9CDdLzmq9CGKeM+fJV3UOBj1Xk0T1l51DuNmY7XE0lKga0RJ9Ux
         qNxTBfMIapfXai4M4EUiEqNbAeA1T+UCIuydRCX0JdKb0qGkNoOS2w7cP8Tv7TBB9Jbe
         sWRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUbzQmLwi8It534anHmTl9nITHjbimT2jd5NDswalJ6FfEyb0rT
	1qpxdJTva0Rb/+pfhEGel3RqT4zWVN8K25OuFBu+RdJyyBnQSKqw+tUCMgdoo6jIDd14186yUiS
	0Lu2lBg7D/FQs9yuJuuaONBvAd2SZzuJldC9YvsrSMflWH7A21Qr4tLJAb8eHFgTqLg==
X-Received: by 2002:a17:906:1292:: with SMTP id k18mr7946249ejb.146.1562932805978;
        Fri, 12 Jul 2019 05:00:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzujQ5ixSRssXRaDaumiyL3URKvBgaqKxR4OODDup5SPGz8OyFt4vzpvKsdKKBxFDbur+QQ
X-Received: by 2002:a17:906:1292:: with SMTP id k18mr7946172ejb.146.1562932805114;
        Fri, 12 Jul 2019 05:00:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562932805; cv=none;
        d=google.com; s=arc-20160816;
        b=eGO5DUGi0/5fNoJgOiGpm/8QhUxEm/0ASHdJhD7n6KM5xzUEa4nhBK186lY4p3Y3U2
         ooNY8tzr3BWKAwqk6qjSmt7e/MHGs1lZOcFirWzbNv0aPgGUyufACHbKnxArR90VoZOV
         rGPrEkS+O7NTfzSvG1o98BV2wTFcGEzDvEU6Pt8GLcQxImyxujQ71WmIrHCaLJvZYl2c
         Ce+n4NWBpzwzrL53uxUdRB9rYLgei5d9MFfeMuekGwaX5Pahou+xV+b8UjCbpOgbUE1f
         C5icuB4eJWRu7uDDtuRhUD/wx6ZBNmMJ9DFpjKon+eKHq6171WVp2czoy/es4YY0TlxR
         FK1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NyB2YVsqbEsNi8RJ9mW2FFLpWdsvFNEAzwh5YIwJ4Og=;
        b=087g1qBVyxJ+nE1PvzCFPuu6LRIkcq6lEv/lTmx/ke30Xb98l7c+msR5zl1j8gX0uS
         vg8lhJtuhXJBwYf/8AlMCXZ7fOkTCDpbCURjtpnne8apnz7T0mscovXgOdTF27+d8Hwy
         hT3iJ7COc1AnKEeGtmbI/KCNfHtHsYP6YwsCafWVLYZAje32oKyAOhrMNpKCB9mEk1O+
         D5+zVQ4R7k+3m2fdaxPqRejWO1F6vb46PYG8NHtJ3Sk/bclfpW3vI4qBIyOx/mO/m3SJ
         YuljP/4jvZJ4NgPfI+0fXp6OR23pYg6l6gZGMwV6nxnLKu/CCTBpo5dLnQWyp485gH54
         LfJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si4339441ejf.192.2019.07.12.05.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 05:00:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 73731AEAF;
	Fri, 12 Jul 2019 12:00:04 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 114EA1E4340; Fri, 12 Jul 2019 14:00:04 +0200 (CEST)
Date: Fri, 12 Jul 2019 14:00:04 +0200
From: Jan Kara <jack@suse.cz>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Amir Goldstein <amir73il@gmail.com>, Jan Kara <jack@suse.cz>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	linux-xfs <linux-xfs@vger.kernel.org>,
	Boaz Harrosh <boaz@plexistor.com>, stable <stable@vger.kernel.org>
Subject: Re: [PATCH 3/3] xfs: Fix stale data exposure when readahead races
 with hole punch
Message-ID: <20190712120004.GB24009@quack2.suse.cz>
References: <20190711140012.1671-1-jack@suse.cz>
 <20190711140012.1671-4-jack@suse.cz>
 <CAOQ4uxh-xpwgF-wQf1ozaZ3yg8nWuBvSyLr_ZFQpkA=coW1dxA@mail.gmail.com>
 <20190711154917.GW1404256@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190711154917.GW1404256@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-07-19 08:49:17, Darrick J. Wong wrote:
> On Thu, Jul 11, 2019 at 06:28:54PM +0300, Amir Goldstein wrote:
> > > +{
> > > +       struct xfs_inode *ip = XFS_I(file_inode(file));
> > > +       int ret;
> > > +
> > > +       /* Readahead needs protection from hole punching and similar ops */
> > > +       if (advice == POSIX_FADV_WILLNEED)
> > > +               xfs_ilock(ip, XFS_IOLOCK_SHARED);
> 
> It's good to fix this race, but at the same time I wonder what's the
> impact to processes writing to one part of a file waiting on IOLOCK_EXCL
> while readahead holds IOLOCK_SHARED?
> 
> (bluh bluh range locks ftw bluh bluh)

Yeah, with range locks this would have less impact. Also note that we hold
the lock only during page setup and IO submission. IO itself will already
happen without IOLOCK, only under page lock. But that's enough to stop the
race.

> Do we need a lock for DONTNEED?  I think the answer is that you have to
> lock the page to drop it and that will protect us from <myriad punch and
> truncate spaghetti> ... ?

Yeah, DONTNEED is just page writeback + invalidate. So page lock is enough
to protect from anything bad. Essentially we need IOLOCK only to protect
the places that creates new pages in page cache.

> > > +       ret = generic_fadvise(file, start, end, advice);
> > > +       if (advice == POSIX_FADV_WILLNEED)
> > > +               xfs_iunlock(ip, XFS_IOLOCK_SHARED);
> 
> Maybe it'd be better to do:
> 
> 	int	lockflags = 0;
> 
> 	if (advice == POSIX_FADV_WILLNEED) {
> 		lockflags = XFS_IOLOCK_SHARED;
> 		xfs_ilock(ip, lockflags);
> 	}
> 
> 	ret = generic_fadvise(file, start, end, advice);
> 
> 	if (lockflags)
> 		xfs_iunlock(ip, lockflags);
> 
> Just in case we some day want more or different types of inode locks?

OK, will do. Just I'll get to testing this only after I return from
vacation.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

