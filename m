Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD99CC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:27:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A040420882
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:27:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="ZohvWTSu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A040420882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EC898E0014; Wed, 30 Jan 2019 14:27:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39C998E0001; Wed, 30 Jan 2019 14:27:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28B488E0014; Wed, 30 Jan 2019 14:27:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id F16408E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:27:14 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id y3so341436ybp.14
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:27:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lCaOFzEC9GUOriuVkX8NdFG1tjkodE5DqXV/LschmsI=;
        b=mbrFEKQhZSv8nysKO4/1lfZp5EmrDFsqwt9E4Sg/0157YPXEIPbkq9B3moiuT+wpb2
         5ND4EtuZOA461vz124/dEbyu1b5/n6V0zhb76q/Nhczu7PMeJBVdqnqaTc2456LnRpQq
         dK/qz78/f9jOiCdVW01oKqofmQPJIIKypON7ppNOeG2yZR3d/Dad8yd2JLQcKGR/HFEM
         LG1ZG6vDCeXVPQD5tday3oL6RINUfYm+tvn1eg4tE8a8AdmBuRI5+jB9CftMDPg5Edu8
         rJGc7tPH5/cTtE4cgVBDSgNi9DDinP/T+fjfVL6kMYG//ScccyxHDR6C077hhVQ4y3Fg
         9Khg==
X-Gm-Message-State: AJcUukc3oku8M90SGfJ4B9FdUC8Vmyaqlw9zYNXVxaj7bIwprVVrEP7R
	ZdxTTveBEJ2rZnZwI8+fHUr3Zb5zT4YTQDxrp+sIEnTznZPNWaZgQBH9tD0jpc8eOIxhNYSJ54j
	YCYEo5eWv9relpZ/aytWEpAooUa+x6YoahG6KiWn7fd+9GXZuFhM18bvobC7YuQCNGtnoH28DdQ
	zy3hXLbnktjZd01uWwCNPMztr0rnY6mwb6ANsbC3V0froyVKu/SA5p6YilN4dq/AMVcvRK4btj7
	LByXGpyjfNeUAzvzc3gVf2ljnLsKrM43srpEtLp2YdU+UG0dmFKab+QwpHikOuRLoKHmxV/STFY
	agS0ua+ibwASCKHsqTFGbhnFN476liQ5HGJRBAGoOASbjXiHckjseqMdPSg+j3cDOCjiOsQKh0F
	r
X-Received: by 2002:a0d:dbc5:: with SMTP id d188mr30015818ywe.402.1548876434666;
        Wed, 30 Jan 2019 11:27:14 -0800 (PST)
X-Received: by 2002:a0d:dbc5:: with SMTP id d188mr30015796ywe.402.1548876434220;
        Wed, 30 Jan 2019 11:27:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548876434; cv=none;
        d=google.com; s=arc-20160816;
        b=hnVC4QQcHcFLIhmX6svJvu+PXsz2180c5Ul9mlOjvZkWD77Y4RF1SIMOpPlYdL1q4R
         gvbyOle8G2RVUwRV+A612t0QV0xHrPrMA+0PaZUwTfUaLKP43NKmvMhahoAUd2v+gvJV
         2dYTVHqLyueEK/Le0dwtWKTqk8dQZ2yhTG7le2bbHnc4EZi53YhlZrmQanBPR5+WAz93
         yDnWN9J1dB1Y6JeRR80uju3jGUfBfqSxHDd0mYKoTcLS30v8iL77vu/vtgP/NrckR7kO
         a/dtWlYb32O5K750YTf5rNGyFZ2Bq7D8nz2Y4lfi9lcKSqmWvLuA96bwt8F39UMCNMii
         VFwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lCaOFzEC9GUOriuVkX8NdFG1tjkodE5DqXV/LschmsI=;
        b=kWH0PHzimNgKHXU9FNoFmKkTLPbOOkAOgXjUnIlgjAObiF/HucViL6UsZMHGwXejTi
         73rd8zDrksThiVbLyqg422fpkttJhfG5x8dvGk1j9fUh22reZJh4ojRMlLA/KLe6CGog
         uoA9itxhmk2dPSOZkmCJypWj4k1gCv83jtY6Oz9AY1LdISWsS/EYnKiGmVRjCM1cZ46d
         YRAKazM4999IGSFbwihcfk0rfNbdP5TaZRJwun+EZnYO/EXZoyUghxxf3b/WigcIQbxx
         xbQdvry+EiN9LgIJ/RwgP2idX7SR3oynGEhKcv/sKg/9YI1S5rpJZL0nTbBtXO7NyonO
         z5bA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ZohvWTSu;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b16sor960534ybm.80.2019.01.30.11.27.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 11:27:14 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ZohvWTSu;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lCaOFzEC9GUOriuVkX8NdFG1tjkodE5DqXV/LschmsI=;
        b=ZohvWTSuJ0FjLHNrBU/NhCidpuP6uTp++17i5m8r0Y4BdXn5gysuarYBmwXmDnXh2E
         5q1Zg6iKy575V4xaQ+3m+w3YaXK2epGUUWapRT4Qk1pYbJ8e24CWTlXowEvP0d0EY1gj
         VGdefopA01lh0af6fU5Lw/yDe5q6HouSDwamc8EyJLf8rHD0F+4MvHD+Rji3pspKlXkr
         R6EGixTm/VAe72WpuMNrIokMPUZJvqGh3qMbrMlYCi/rzPY0ozgqJnu4a8UmGQDrTYkI
         couibxZPlwtjEDeLQU1PlYXif1ZmmnuJtzPzfiRz4zqRA+irU0fT/tlOc4Upb6sHSWXJ
         0PAw==
X-Google-Smtp-Source: ALg8bN4HOZ2BceRWudY9fcvRQQG06wEy+HZBcWR1nYVuLTVCr2JVnKVx5gChDjnH9Skuez+BhBA8lQ==
X-Received: by 2002:a25:5e03:: with SMTP id s3mr29744932ybb.8.1548876433952;
        Wed, 30 Jan 2019 11:27:13 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:6c95])
        by smtp.gmail.com with ESMTPSA id k83sm781960ywe.90.2019.01.30.11.27.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 11:27:13 -0800 (PST)
Date: Wed, 30 Jan 2019 14:27:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>,
	Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190130192712.GA21279@cmpxchg.org>
References: <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
 <20190128174905.GU50184@devbig004.ftw2.facebook.com>
 <20190129144306.GO18811@dhcp22.suse.cz>
 <20190129145240.GX50184@devbig004.ftw2.facebook.com>
 <20190130165058.GA18811@dhcp22.suse.cz>
 <20190130170658.GY50184@devbig004.ftw2.facebook.com>
 <CALvZod5ma62fRKqrAhMcuNT3GYT3FpRX+DCmeVr2nDg1u=9T8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5ma62fRKqrAhMcuNT3GYT3FpRX+DCmeVr2nDg1u=9T8w@mail.gmail.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 11:11:44AM -0800, Shakeel Butt wrote:
> Hi Tejun,
> 
> On Wed, Jan 30, 2019 at 9:07 AM Tejun Heo <tj@kernel.org> wrote:
> >
> > Hello, Michal.
> >
> > On Wed, Jan 30, 2019 at 05:50:58PM +0100, Michal Hocko wrote:
> > > > Yeah, cgroup.events and .stat files as some of the local stats would
> > > > be useful too, so if we don't flip memory.events we'll end up with sth
> > > > like cgroup.events.local, memory.events.tree and memory.stats.local,
> > > > which is gonna be hilarious.
> > >
> > > Why cannot we simply have memory.events_tree and be done with it? Sure
> > > the file names are not goin to be consistent which is a minus but that
> > > ship has already sailed some time ago.
> >
> > Because the overall cost of shitty interface will be way higher in the
> > longer term.  cgroup2 interface is far from perfect but is way better
> > than cgroup1 especially for the memory controller.  Why do you think
> > that is?
> >
> 
> I thought you are fine with the separate interface for the hierarchical events.

Every other file in cgroup2 is hierarchical, but for recursive
memory.events you'd need to read memory.events_tree?

Do we hate our users that much? :(

