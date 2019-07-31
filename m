Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6D4AC41514
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7A25206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:17:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7A25206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 088D58E0003; Wed, 31 Jul 2019 04:17:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 013878E0001; Wed, 31 Jul 2019 04:17:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1F048E0003; Wed, 31 Jul 2019 04:17:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 904678E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:17:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so41843108ede.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:17:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vi26102hQzeCZgUc33Ta7ekhpZNwxbARwW9N1ofoWaw=;
        b=X84j8OKLGbB/CC2T1zxDxQF1KdRZtcE79MimFUhGaVhpp4vnNOWZgXQT6DHsAWf+EP
         GTKoZOtG88SRzIn8tXmPbl1tvzod22jAv79zlL4TPeG5bygHcWmd03GsUxjxQvLZw4DU
         zW0qOMrCFwHQSVJuSDSvZj2s09ubk3V+mm6OrhmJ8CBd6PUiDu5v6+6/EOdjEpo0KQHC
         WLmBu8cPpAXGuqdE7bl1gU3fARz0cO8Gc0erUut2fjg4AYnp/7qwaT7Z1Tx677tJ44VI
         a+axyhKn/p3CqyuTrX2fX+WWX1HvU66WunNtk0boWmB50aBMhVRJfmnP+mgvCbJ6BuEp
         uQqQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXSriwrFzNXyowe+vjq0sV90HDKaAet3Ra193ss42nZ3jonTMgo
	vmG/vnP99Fu1KXPzmYOQkBruGhC8mrN0JKmh3UrUeGsNHPSKgh9vTbBmlA8ZO9dfbWkXP6TIVhE
	U2sNfK+guDgVIBlKJQn/8Jji0PbE5qV6xoBh1MVBYPEkAeJ8ucbuK6d1Q2bYkFJA=
X-Received: by 2002:a17:906:5384:: with SMTP id g4mr91612753ejo.241.1564561049157;
        Wed, 31 Jul 2019 01:17:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4znJ+XgMzK+G+v+XvCRAIB0JsgmdMClXp7deW/wt2hqCB8D1T/6BL6dCtTjg5XmQbi5i8
X-Received: by 2002:a17:906:5384:: with SMTP id g4mr91612714ejo.241.1564561048412;
        Wed, 31 Jul 2019 01:17:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564561048; cv=none;
        d=google.com; s=arc-20160816;
        b=btrj0qxjlKxBKHiUQSV85TvK2t0yBsz/Lk0eJaRWVEfCYJTIdbuMwuIqs5jIKHnlVX
         nMFwqokCarrZtKS3h75MQI7hDdyZ25vYsv+41t1GugSjEKO79vf7fqViMnaevi/RcsO+
         99+e0Yj2gg4/9tov7SMV6Gr7cnuEm2sllMRwByExiA6+PSTKBWyem2a975Ou3UevUBy8
         x9vyU8ueLbanmBzQu3QfSaQRjvH68L/6o8wxp5n+9sJfevD7ecNyPWW8vVP2nrrK7r7C
         YfOoxv5AK1EOGxYCowxXwFyU4ceVboN/xWWcpkzUpNf7002ekg50ZW1dI6mFVVsnlgtH
         kYbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vi26102hQzeCZgUc33Ta7ekhpZNwxbARwW9N1ofoWaw=;
        b=nuhh+nsQIKFNBGxOp2sNKeNepdw0q8EOZe6hgAzkGS0dSE02HCUm+TBKqqenZT478D
         Ok2N94JBHQiSbRE7S1/Se2E1GXp2N0rgEDTTSI1p5oU1c9YaToiLP2pOlcUtGCCQ4wCj
         lILTCBc6rnNDyVHK9ODrA1cN4//ugnSNYjqPpNvFT7bw/2ScSnbJbzxRHerC8+4WOPU4
         MAqo7utiotiDck6THDV+RUTz1/wl8s+ip20S2hOwS62uyMgxjQP5fZUTdhCFBUFc7YZN
         JsrQk9BUblm7JBXeSLHRuD2kF0uTdfGCQn8P+s0wylv5ePxylS2Eunul9pvPXpQnHMGE
         vMrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k28si22958282ede.131.2019.07.31.01.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:17:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C289CAF54;
	Wed, 31 Jul 2019 08:17:27 +0000 (UTC)
Date: Wed, 31 Jul 2019 10:17:26 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
Message-ID: <20190731081726.GB9330@dhcp22.suse.cz>
References: <20190503223146.2312-1-aarcange@redhat.com>
 <20190503223146.2312-3-aarcange@redhat.com>
 <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
 <20190520153621.GL18914@techsingularity.net>
 <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
 <20190730131127.GT9330@dhcp22.suse.cz>
 <20190730110544.84d91ba80365cf35f5aae291@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730110544.84d91ba80365cf35f5aae291@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 30-07-19 11:05:44, Andrew Morton wrote:
> On Tue, 30 Jul 2019 15:11:27 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Thu 23-05-19 17:57:37, Andrew Morton wrote:
> > [...]
> > > It does appear to me that this patch does more good than harm for the
> > > totality of kernel users, so I'm inclined to push it through and to try
> > > to talk Linus out of reverting it again.  
> > 
> > What is the status here?
> 
> I doesn't seem that the mooted alternatives will be happening any time
> soon,
> 
> I would like a version of this patch which has a changelog which fully
> describes our reasons for reapplying the reverted revert.

http://lkml.kernel.org/r/20190503223146.2312-3-aarcange@redhat.com went
in great details IMHO about the previous decision as well as adverse
effect on swapout. Do you have any suggestions on what is missing there?

-- 
Michal Hocko
SUSE Labs

