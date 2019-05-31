Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8108EC28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 13:39:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B5EF2133D
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 13:39:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IDKwcaOH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B5EF2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B42366B0007; Fri, 31 May 2019 09:39:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF3936B026A; Fri, 31 May 2019 09:39:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BB066B027A; Fri, 31 May 2019 09:39:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66EEE6B0007
	for <linux-mm@kvack.org>; Fri, 31 May 2019 09:39:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i123so7390900pfb.19
        for <linux-mm@kvack.org>; Fri, 31 May 2019 06:39:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=p2xs/JXfPoxuMW8YWnH2CaGd+XoTegPAh3+JTTCbB5s=;
        b=Itv1AO7pvrWuHZj0huKZ9kB5fdbjDlkG1RPySsNZ9homs9XnTUGeevELaz2FWX8Nih
         V9MnDhfBu9qS2ZyPZVTRoYxXDUK5C2K+1mmLLfCfKsYxQs2O4MckTpovCxbdFnI2ICYI
         sdpqcPaC7v8N9BinrPDW1cWAw+I2s9VqoNJTTZSjl7Ns9jWbHqYjDCfRfLXLcBempTZ8
         eQaTiOuR4hkD0oPfDfQdzz04YS58FLemXtZW3s+JIMz6QDqoUNSCIaogHxtY2nFw7hdO
         jAsIIcAjMsnkzlGGLJGwFQbfVJ06VTvENA/QKtkE+rHJwjN1MMP/hnhxB5jQ0K9M5z4A
         37sQ==
X-Gm-Message-State: APjAAAUeNRIqlt/wLXBBVYii8DXbc6JOivXPQoirctWZbTYLm3ulREu4
	uP5dx1wnnlfNZoGZWOcrcOXwWj30au8BEvMD94KhZsbK0gr10rRWymP+NqOXnAaiD9vV86SFqjs
	4LiZOYexUe9p+tyTXM9SV+TTqLQmykSmW5tlBreIa0+ZIcf7K/Ts96hXiSTU0Oek=
X-Received: by 2002:a17:90a:195e:: with SMTP id 30mr9606583pjh.116.1559309956008;
        Fri, 31 May 2019 06:39:16 -0700 (PDT)
X-Received: by 2002:a17:90a:195e:: with SMTP id 30mr9606469pjh.116.1559309954942;
        Fri, 31 May 2019 06:39:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559309954; cv=none;
        d=google.com; s=arc-20160816;
        b=vYt/0BMrjEvztYaiK2o/H5ghNzHm6p7ZxyE3bRN28oip1K+yRwRcWQuw1JzX0OlO9s
         8tvNxEGh1m2CpL5jKVxezra6vEn3ke3SUMwETKJO5BP6dbnsjftft/8Xqtc7aGghmvA2
         To1d+Jzjhom7TLtop3Z2M/3XM13lS1PB9eX5t9chAmrP2K+SzIZD7vEXrdx5o0e6k2TS
         h38LhAiZbScL4DS/zTVNGjdCq16TR7KY9BbMeNz+SoqZGLJzrflvyFchj7u6FcaV8yns
         sMI9LFa0P1S+ifPT0NEGgcCiWG4KE6aBlvxomCJuppiUgc5jNffo9+M3cJo+YgKTFs9J
         eaXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=p2xs/JXfPoxuMW8YWnH2CaGd+XoTegPAh3+JTTCbB5s=;
        b=JCYUh9AtXBMpUADTDVdUCMPBQu23oWkABUj3ioAC9iENwbRpH+KTvVLl5psMfLpusR
         0sHsgspE7Egs5h3VVX4eAM47CeFtye/XIQkdhMLZtdOJ56sZ8UD1GPbYYAqiR9h8wkjP
         UEkGGxz5G8RhlqxL9qg3RFHYFQsQYGf+KvzH2oslznDUUppdRNsx5j0kFlNxyzuEf2BP
         5eiYWtUWU+O84dEDyb4MJm7U6PZcgFulF7RkzMzyWXqGckY+1Mbrs2RT6SQwhCh+mPxU
         3wNoqK9TlviqnOTtn0AmspL0v3lPf6agJbpVhtzE4QsAMEsZGStzQ0Eqg6xD6MaB4U6Y
         9Rew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IDKwcaOH;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n1sor6341848pgh.2.2019.05.31.06.39.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 06:39:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IDKwcaOH;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=p2xs/JXfPoxuMW8YWnH2CaGd+XoTegPAh3+JTTCbB5s=;
        b=IDKwcaOHGadMB1TmLSObOSA0W/aGdtHDC0stKAbwq4TtKsZB6mhzcklZYmOzKQnzhq
         hxywSfajmRY5mDRpAvWBh1M3KgJKwf/zl9jOd1WGYj6UXQ2fSX3E1nhZkkIegcSHln1Z
         dOs3dg8Pt1GBE3ik7m7RbCDl9neE8lReHVYFYme1QyB0wwO829iUToFVHsE9Dm4FXoHq
         gzk7kwcDaPtxSBv+Lo75tbXdD+lu0qJyhYndZkyHayIjT+3oQ3oUFEBtO971zCVy2KXw
         du35CsPT0zBzdgBTKHgTqnxMc3iatZyQXdovcqC1wmgrge9T/uteTBvSpZeWOVZdU+7Z
         upLw==
X-Google-Smtp-Source: APXvYqwpn6INIam9Hj1iduhR8iI5bXQQTo7X1hltxvTWMZbD5dIKnXsGM8MX89DjI7uadV0NebmWCw==
X-Received: by 2002:a63:4714:: with SMTP id u20mr9412205pga.347.1559309954195;
        Fri, 31 May 2019 06:39:14 -0700 (PDT)
Received: from google.com ([122.38.223.241])
        by smtp.gmail.com with ESMTPSA id 128sm7105292pff.16.2019.05.31.06.39.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 31 May 2019 06:39:12 -0700 (PDT)
Date: Fri, 31 May 2019 22:39:04 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
Message-ID: <20190531133904.GC195463@google.com>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531084752.GI6896@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > When a process expects no accesses to a certain memory range, it could
> > give a hint to kernel that the pages can be reclaimed when memory pressure
> > happens but data should be preserved for future use.  This could reduce
> > workingset eviction so it ends up increasing performance.
> > 
> > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > MADV_COLD can be used by a process to mark a memory range as not expected
> > to be used in the near future. The hint can help kernel in deciding which
> > pages to evict early during memory pressure.
> > 
> > Internally, it works via deactivating pages from active list to inactive's
> > head if the page is private because inactive list could be full of
> > used-once pages which are first candidate for the reclaiming and that's a
> > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > if the memory pressure happens, they will be reclaimed earlier than other
> > active pages unless there is no access until the time.
> 
> [I am intentionally not looking at the implementation because below
> points should be clear from the changelog - sorry about nagging ;)]
> 
> What kind of pages can be deactivated? Anonymous/File backed.
> Private/shared? If shared, are there any restrictions?

Both file and private pages could be deactived from each active LRU
to each inactive LRU if the page has one map_count. In other words,

    if (page_mapcount(page) <= 1)
        deactivate_page(page);

> 
> Are there any restrictions on mappings? E.g. what would be an effect of
> this operation on hugetlbfs mapping?

VM_LOCKED|VM_HUGETLB|VM_PFNMAP vma will be skipped like MADV_FREE|DONTNEED

> 
> Also you are talking about inactive LRU but what kind of LRU is that? Is
> it the anonymous LRU? If yes, don't we have the same problem as with the

active file page -> inactive file LRU
active anon page -> inacdtive anon LRU

> early MADV_FREE implementation when enough page cache causes that
> deactivated anonymous memory doesn't get reclaimed anytime soon. Or
> worse never when there is no swap available?

I think MADV_COLD is a little bit different symantic with MAVD_FREE.
MADV_FREE means it's okay to discard when the memory pressure because
the content of the page is *garbage*. Furthemore, freeing such pages is
almost zero overhead since we don't need to swap out and access
afterward causes minor fault. Thus, it would make sense to put those
freeable pages in inactive file LRU to compete other used-once pages.

However, MADV_COLD doesn't means it's a garbage and freeing requires
swap out/swap in afterward. So, it would be better to move inactive
anon's LRU list, not file LRU. Furthermore, it would avoid unnecessary
scanning of those cold anonymous if system doesn't have a swap device.

