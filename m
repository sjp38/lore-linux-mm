Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73D1CC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:30:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4296021BF2
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:30:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4296021BF2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3D446B0003; Wed,  7 Aug 2019 07:30:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEDB56B0006; Wed,  7 Aug 2019 07:30:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B034E6B0007; Wed,  7 Aug 2019 07:30:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE9D6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 07:30:13 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n190so78842729qkd.5
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 04:30:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/fZp4EVn6s5246Ob0vkeGMjv7IVGqiYWKTpE2YsL29U=;
        b=NrcQrtsd0GG1YGIuGt2aUfy6dsXHNjHcnVTeZyS0qipB8UfRkQUOJ7g6zR9j3WvaX4
         H9FqnipM2zLcaa5QvSYNJtvmAjPraxB8kiPDRJsfRxoFNWIsmBmX3Qv9GXDQjM/7ksWc
         T+kk/tbHcf0V9gO05y1hkU6toZ18ROzN/5Q221t6nC3Zm9S63sVJMU5x/X2Jz55YO/TK
         B+wGK8Fspxk4/kAIEygzXVa8kCtLLprkh+5cwU97LxR0dfrbouZR1SA4l3216GZYhV1u
         S+Ci6q55AfJD6cMc5FfYMCdxkyRdz+AqsLiWCmG7k4UUXMUjrS6aN233hj55+qBALaAN
         /icw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUHaKGFeas42NdSNpI5+TZGBCwXrAaEdnNzuNJYvkAIV81zLUoK
	ag/meiesgQNda3jlDbb9e9ldnGxYiGHQatYiAXEK/S0DkVl+yA0fO94igQQFLsCyqg3BeUfvU7K
	Mg7B4R4eT+odkolRV8DyMEAbuT46ZYHnYMrP66EJjhduOWWWxt9TIcFAML6Kk+JTpiQ==
X-Received: by 2002:a37:8a81:: with SMTP id m123mr7543198qkd.360.1565177413342;
        Wed, 07 Aug 2019 04:30:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkQQtSEYK+BDYLULZOt/7BpCZKpA331IDgGwvyEYFagkalBpXSShF763FE0yRfjC2q36Oy
X-Received: by 2002:a37:8a81:: with SMTP id m123mr7543144qkd.360.1565177412642;
        Wed, 07 Aug 2019 04:30:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565177412; cv=none;
        d=google.com; s=arc-20160816;
        b=UpHkdANRb4SNHu45ZR3ox9rnp6fSdwc1QeTGoKv7KB9bTF4lMUy9gl3+LA8LC5WkQM
         vMtRGpgtuvHaY1HQYyyiJA6IPSD0EBWCaHg1W2zzOhtEDyBeMo6hNkhuuM/geaLeEsCv
         WPO6Kl2Rhy0l0lTurxrHHZv5PxhsP6JjECVOzvSaxVe35Jek/Akoo4H2pYNw2XkeCRxU
         4ocsQjnrqNTBtg/5AqJdl7dPvSW2ziqNBpkNS8wMmxOv+k0Q7DI/19AVyoHYFY1dFXVj
         6AUsMofkhn7Up1c2sR+i+A0Fwx0NJ7TPJBDtQW4RQwWibXXzpOgV1nsB1a0qdYQNZaha
         flIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/fZp4EVn6s5246Ob0vkeGMjv7IVGqiYWKTpE2YsL29U=;
        b=VsgfTgRPlRUdcF0JHC6mPyGafMg2ONt9FJgPIH4xrU7SZa3CLAy/mNS5NPthOj+Dlo
         0nz0DAa9odqi2pmwpqfQH4vQ+Ejv8ueL69Yi3D1YJAnBwopEkHpO79QD0JtRJIOxbiA/
         YfFcEvqm6Z4nxQdnygsvLJ5Q/B65XjMRdsP/CZbcMioL1q2WPVO2dmLjMfOJt/dzet3d
         w1IG/S+WdjL0639bxEkm4AAAiwbox/dKKZa+l6y54gHgDCpRHyfd3Nkc2R9Rd24MliEX
         ONtGuhQPrdzBj1OotS1kIdVaU++B3hNDSpEiF+4EJ8vO40HzvpYKNQBO1agtQ4JqaapX
         NW6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y18si34745989qvc.47.2019.08.07.04.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 04:30:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C30A28D5E1;
	Wed,  7 Aug 2019 11:30:11 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4133C19C5B;
	Wed,  7 Aug 2019 11:30:11 +0000 (UTC)
Date: Wed, 7 Aug 2019 07:30:09 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 18/24] xfs: reduce kswapd blocking on inode locking.
Message-ID: <20190807113009.GC19707@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-19-david@fromorbit.com>
 <20190806182213.GF2979@bfoster>
 <20190806213353.GJ7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806213353.GJ7777@dread.disaster.area>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 07 Aug 2019 11:30:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 07:33:53AM +1000, Dave Chinner wrote:
> On Tue, Aug 06, 2019 at 02:22:13PM -0400, Brian Foster wrote:
> > On Thu, Aug 01, 2019 at 12:17:46PM +1000, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > When doing async node reclaiming, we grab a batch of inodes that we
> > > are likely able to reclaim and ignore those that are already
> > > flushing. However, when we actually go to reclaim them, the first
> > > thing we do is lock the inode. If we are racing with something
> > > else reclaiming the inode or flushing it because it is dirty,
> > > we block on the inode lock. Hence we can still block kswapd here.
> > > 
> > > Further, if we flush an inode, we also cluster all the other dirty
> > > inodes in that cluster into the same IO, flush locking them all.
> > > However, if the workload is operating on sequential inodes (e.g.
> > > created by a tarball extraction) most of these inodes will be
> > > sequntial in the cache and so in the same batch
> > > we've already grabbed for reclaim scanning.
> > > 
> > > As a result, it is common for all the inodes in the batch to be
> > > dirty and it is common for the first inode flushed to also flush all
> > > the inodes in the reclaim batch. In which case, they are now all
> > > going to be flush locked and we do not want to block on them.
> > > 
> > 
> > Hmm... I think I'm missing something with this description. For dirty
> > inodes that are flushed in a cluster via reclaim as described, aren't we
> > already blocking on all of the flush locks by virtue of the synchronous
> > I/O associated with the flush of the first dirty inode in that
> > particular cluster?
> 
> Currently we end up issuing IO and waiting for it, so by the time we
> get to the next inode in the cluster, it's already been cleaned and
> unlocked.
> 

Right..

> However, as we go to non-blocking scanning, if we hit one
> flush-locked inode in a batch, it's entirely likely that the rest of
> the inodes in the batch are also flush locked, and so we should
> always try to skip over them in non-blocking reclaim.
> 

This makes more sense. Note that the description is confusing because it
assumes context that doesn't exist in the code as of yet (i.e., no
mention of the nonblocking mode) and so isn't clear to the reader. If
the purpose is preparation for a future change, please note that clearly
in the commit log.

Second (and not necessarily caused by this patch), the ireclaim flag
semantics are kind of a mess. As you've already noted, we currently
block on some locks even with SYNC_TRYLOCK, yet the cluster flushing
code has no concept of these flags (so we always trylock, never wait on
unpin, for some reason use the shared ilock vs. the exclusive ilock,
etc.). Further, with this patch TRYLOCK|WAIT basically means that if we
happen to get the lock, we flush and wait on I/O so we can free the
inode(s), but if somebody else has flushed the inode (we don't get the
flush lock) we decide not to wait on the I/O that might (or might not)
already be in progress. I find that a bit inconsistent. It also makes me
slightly concerned that we're (ab)using flag semantics for a bug fix
(waiting on inodes we've just flushed from the same task), but it looks
like this is all going to change quite a bit still so I'm not going to
worry too much about this mostly existing mess until I grok the bigger
picture changes... :P

Brian

> This is really just a stepping stone in the logic to the way the
> LRU isolation function works - it's entirely non-blocking and full
> of lock order inversions, so everything has to run under try-lock
> semantics. This is essentially starting that restructuring, based on
> the observation that sequential inodes are flushed in batches...
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

