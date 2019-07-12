Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EDB7C742A8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 05:29:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 442CC21537
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 05:29:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 442CC21537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD23D8E0117; Fri, 12 Jul 2019 01:29:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C81288E00DB; Fri, 12 Jul 2019 01:29:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B49238E0117; Fri, 12 Jul 2019 01:29:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 67D558E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 01:29:43 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so6737623edm.21
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 22:29:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VrKj7VyHdYByVeo3qaf1RrxhLwpK0iqUZrxIfi1yXqM=;
        b=TEoBuom3hZ21aJHIOEcCV2BWj6C5lmazmpFQH28MsMmnppZbqDbJzw7xNHp00tQLwn
         Z8Hr4f6I6Nv4FZUMQXJHWh9VGsN924DvD0URABiN1Qr9FTryaPLnO0NbM6jD57f8emKZ
         oAOWXxKb+CIw1bR4my1aMYI71lde9I/v0jdQBKZNt9I2MLV89p3G2FmmaQj7u4jRGmAS
         KKUd0RIN39mP+wvYfMAFk7XnvkXaLbadENCzA5DsaJFs1YQMiYfUBD/oDB9hJYUc5HtS
         A1kPtMxFeK3G/bQ/FeHXMzRgFGIRWBQmOkiAVq94UqsvuLC9keU4lHb7Kf6ZYNrZGJpk
         N0tg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUMX/M2PJmCZ3I99qQWzrnvehrJPzT9d4EZt4JyRW1LROOhZXWs
	dKbK3/X5ml4ApT8FK7zcwkCIrUJUdngUobUpM7Y5cwPO+XVgztcQRbdPt+UaFXuaZC0f77XIUtu
	3kfdQf09WN2a8SsFaLtW4ks7LHNHp9mGRnYZhGSqfHHi2kQEVhB+BLTk5Zh8SGt0=
X-Received: by 2002:a17:906:43c4:: with SMTP id j4mr6477972ejn.227.1562909382943;
        Thu, 11 Jul 2019 22:29:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQZBo2wBBmaQ5SM7YhbzTBk8SIZaj0AsWeOhc8mKbn9QNKXjI8J1MghFqgNLajGqLS6p6s
X-Received: by 2002:a17:906:43c4:: with SMTP id j4mr6477941ejn.227.1562909382203;
        Thu, 11 Jul 2019 22:29:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562909382; cv=none;
        d=google.com; s=arc-20160816;
        b=vW971ZJ8MWf4CzAKvcVJygoMXlikIMLbdj6BrsGjIEifD5t9fIdZK7M7uD3DbKSmn1
         tDDNzHM1BTdtoBvplhEA3wrPKihAqbNv9Xpr15BEyrZm9bMrLcAXS5LhUvRl+hnEnTBt
         PS1BVpEYiTWxMrXG2fEz6W6THdFDemnc3a8vNpz+GIdbsifdIIjjoP7NzCvDJtDf+Ujo
         imIfDjFlKcEOHeKBfpvvAdu7KKiIAVBWT7HnrhM6V5qQLlER8Jnpd+yYqkBL2zE7GJTi
         uXcRoUNd/Ke0WPwaVMVl5s+Ycf9MO1c/kwczrzmCLyuBk2cfZiDleMPt88rJc7dM/yn2
         3+Lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VrKj7VyHdYByVeo3qaf1RrxhLwpK0iqUZrxIfi1yXqM=;
        b=VAV+YQsfz9c2NBVhcMsDGqPZGpKRtgs+jJdxpHBJF3pMcdzlE0gchZZO0AVx+2aTOh
         HCWJxzkpuau607UWwyqXisAkWKGIjKL0Ze9YmVii76Pesj+gAkByBk8yzsrUcZCNyyde
         znMzARfFQoDHXEl1Wuj+FN5z34xfsqkOUh+5kaqwx48+yf9Fbo2kYJxQ7SobnBLVBtEK
         0WCbdMe0VIpeP9pV8ZKmZKbpy5xTkvr6SZqRXP1A8pgbfNZKxnHVyvBW7kcM2XHdF0pc
         jHtIb2CDbeq0WRFOy/B3lYnGacK6wPUaDF1jI5TG2oFfJEt4MYkci4xVNu32obUavg3x
         uHxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x32si5130463edx.397.2019.07.11.22.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 22:29:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6B144ACCA;
	Fri, 12 Jul 2019 05:29:40 +0000 (UTC)
Date: Fri, 12 Jul 2019 07:29:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/memcontrol: keep local VM counters in sync with
 the hierarchical ones
Message-ID: <20190712052938.GI29483@dhcp22.suse.cz>
References: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com>
 <20190711164215.7e8fdcf635ac29f2d2572438@linux-foundation.org>
 <CALOAHbDC+JWaXfMwG97PEsEB4f0vRkx7JsDRN8m47x1DMVuuFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbDC+JWaXfMwG97PEsEB4f0vRkx7JsDRN8m47x1DMVuuFg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-07-19 09:47:14, Yafang Shao wrote:
> On Fri, Jul 12, 2019 at 7:42 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Thu, 11 Jul 2019 09:32:59 -0400 Yafang Shao <laoar.shao@gmail.com> wrote:
> >
> > > After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
> > > the local VM counters is not in sync with the hierarchical ones.
> > >
> > > Bellow is one example in a leaf memcg on my server (with 8 CPUs),
> > >       inactive_file 3567570944
> > >       total_inactive_file 3568029696
> > > We can find that the deviation is very great, that is because the 'val' in
> > > __mod_memcg_state() is in pages while the effective value in
> > > memcg_stat_show() is in bytes.
> > > So the maximum of this deviation between local VM stats and total VM
> > > stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
> > > great value.
> > >
> > > We should keep the local VM stats in sync with the total stats.
> > > In order to keep this behavior the same across counters, this patch updates
> > > __mod_lruvec_state() and __count_memcg_events() as well.
> >
> > hm.
> >
> > So the local counters are presently more accurate than the hierarchical
> > ones because the hierarchical counters use batching.  And the proposal
> > is to make the local counters less accurate so that the inaccuracies
> > will match.
> >
> > It is a bit counter intuitive to hear than worsened accuracy is a good
> > thing!  We're told that the difference may be "unacceptably great" but
> > we aren't told why.  Some additional information to support this
> > surprising assertion would be useful, please.  What are the use-cases
> > which are harmed by this difference and how are they harmed?
> >
> 
> Hi Andrew,
> 
> Both local counter and the hierachical one are exposed to user.
> In a leaf memcg, the local counter should be equal with the hierarchical one,
> if they are different, the user may wondering what's wrong in this memcg.
> IOW, the difference makes these counters not reliable, if they are not
> reliable we can't use them to help us anylze issues.

But those numbers are in flight anyway. We do not stop updating them
while they are read so there is no guarantee they will be consistent
anyway, right?
-- 
Michal Hocko
SUSE Labs

