Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D36F1C004EF
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 11:16:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4FF72086D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 11:16:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4FF72086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 411DE8E0071; Wed, 10 Jul 2019 07:16:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C1388E0032; Wed, 10 Jul 2019 07:16:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 292418E0071; Wed, 10 Jul 2019 07:16:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC78B8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 07:16:25 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so1193036edr.13
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 04:16:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=y6g3+dd52BTPAo2tk+o5SZFkMGWj6ji2I7b++DaZ6Dk=;
        b=cgdju4nICS+p/Hy08m1CyOq0NFr9baP409d6VSeJBa6pK4OnBxvvuQeHAGXCOkN7P/
         LD7p8U+WUw2YUCTOYNKTnd7Ho6GzzwbUa85ZUX8OLJOKd5XFZH7pSFwwwM4GBFjNoS5N
         oG0fejVQqhbqqafjm+16KuDzNdQEpBAS6xcRKAouURwZ4fN6Q3q628ewAGDHA41svV4C
         lGfeRN5muW7waRxyycMbpuXcSSlnSS3kWHu6BqoYM0+4lhPYzjVzcgO8yDEuWB+3LVIE
         8xJw1fz0ogq+PBzVvKOP3F0FsVVVv//v7tQ0NVK41KZcQjlP1AMaJGvot5NICdZM12GM
         ScAQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXmXCuT+35ihwpKidDYEPmGLqWqIF0xNd5jfrT1mlA4FCeSgdqJ
	g5lc9TA9PmGfiRCBMxF/dM7UmLngnQZbhiTPx49MMP1zg0QG5zszUgULVchXGQtbJst3OVjJHdv
	wUBU2BTqwMBivOhvCjHuqFGF+kig5DuHXzuEwD3ojrDFOoSO4aeQbqXfoQS9edyo=
X-Received: by 2002:a17:906:f10d:: with SMTP id gv13mr25677925ejb.151.1562757385255;
        Wed, 10 Jul 2019 04:16:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQEv0Y8+x+pWVsfVd6lfbg67ij1MwvrzdWUGOJhiaBqe733JqW0hhXXRJqZck2WOkN+fFD
X-Received: by 2002:a17:906:f10d:: with SMTP id gv13mr25677868ejb.151.1562757384326;
        Wed, 10 Jul 2019 04:16:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562757384; cv=none;
        d=google.com; s=arc-20160816;
        b=jmmD7nrV/eerIJ/+9coxITTgSX1ijqM3Jm9LagN4yj5TTNsB+NgfqA/BD6jud6ThZa
         IafBOoD16Kpo6VQq1ZkD/7MxzGLOyxtd+vS8sWPGJ4cGvwgFrMrPZRIFu14BZ80SgWzL
         b+IEVtwg3XKMR/UzmZvzIjfLFXwEnx14vXM05c7hV7vnO9wioT7SY/bn4RX0Ldy+KB9Z
         r1PIwfeYX7bWy81VkKv8OxXMg9ISfTkfa3OjYlDclxZW2K20kOCUKeqMtnC1BBZti8jv
         hxKecKRX6bBRZTZ7NW2bD7Z2+FtyvYmFO/yAvEXP8IHx+T13KJNo4/zccjTaHIjQELZb
         u8iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=y6g3+dd52BTPAo2tk+o5SZFkMGWj6ji2I7b++DaZ6Dk=;
        b=oQCOQYTxs30EaFhdMiDwKcpI3WKjLYkEF8tu/bSgqzUuRjdthgVpxhn3/QMlyIv4bD
         papscB7faNqt4dpy3z96VzGdZafEHLh0BYf3bKQpJpa5BWvLMWEo0E4/SSMFbvMhDzdT
         PirnWsTqUdY1XBXpi+weamVgLoC0pphwYairJbd78ybXDoSlgxg5IRT0t2fG3FMwHFV7
         P9KH2OSOixZSr1jr789U7Fbn5/bKQH8VVvaocdP2Rc2UDOWjkJev8Rq9kCcH6i4gSO7a
         5m1b0cXLhUSdpF81fWuIA5icgJb9ltUAxRU28rhzq6YFaWlc+P+UfHaYooygVlTf5keA
         kZFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si1189333edr.60.2019.07.10.04.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 04:16:24 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 601B4AF05;
	Wed, 10 Jul 2019 11:16:23 +0000 (UTC)
Date: Wed, 10 Jul 2019 13:16:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 4/5] mm: introduce MADV_PAGEOUT
Message-ID: <20190710111622.GI29695@dhcp22.suse.cz>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-5-minchan@kernel.org>
 <20190709095518.GF26380@dhcp22.suse.cz>
 <20190710104809.GA186559@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190710104809.GA186559@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 10-07-19 19:48:09, Minchan Kim wrote:
> On Tue, Jul 09, 2019 at 11:55:19AM +0200, Michal Hocko wrote:
[...]
> > I am still not convinced about the SWAP_CLUSTER_MAX batching and the
> > udnerlying OOM argument. Is one pmd worth of pages really an OOM risk?
> > Sure you can have many invocations in parallel and that would add on
> > but the same might happen with SWAP_CLUSTER_MAX. So I would just remove
> > the batching for now and think of it only if we really see this being a
> > problem for real. Unless you feel really strong about this, of course.
> 
> I don't have the number to support SWAP_CLUSTER_MAX batching for hinting
> operations. However, I wanted to be consistent with other LRU batching
> logic so that it could affect altogether if someone try to increase
> SWAP_CLUSTER_MAX which is more efficienty for batching operation, later.
> (AFAIK, someone tried it a few years ago but rollback soon, I couldn't
> rebemeber what was the reason at that time, anyway).

Then please drop this part. It makes the code more complex while any
benefit is not demonstrated.

> > Anyway the patch looks ok to me otherwise.
> > 
> > Acked-by: Michal Hocko <mhocko@suse.co>
> 
> Thanks!

-- 
Michal Hocko
SUSE Labs

