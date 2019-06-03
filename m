Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FEFDC04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 07:16:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D640027C96
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 07:16:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D640027C96
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 672B86B026C; Mon,  3 Jun 2019 03:16:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 622626B026D; Mon,  3 Jun 2019 03:16:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EB8D6B026E; Mon,  3 Jun 2019 03:16:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 027BA6B026C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 03:16:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y12so26093829ede.19
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 00:16:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TcUfCOeJBJp9O+U5YdQywRi1GhSonhNYKIV+JErCtd4=;
        b=FLw5kjr2R8geWhwiIQalokGXdcrf6er5XXSel3ye9fXeZR3Pq1pMbCIzex527dgU0i
         SouJIWXBMtZCut9lEs8L6gPRqm0xWBe/5ea2zkM3CNRzFoVlgjQ5Bab1LNxp1Z8Gqs97
         2ztc4TBocm6bZqIAubie4GeQ/4YJr1YvdHiMd5XRx7UszW/4AKYhrNwV4eXmjx5nitMN
         gtdgYiWQQAiNlRL3fwhuPGPo3FBBaeferk3KHaIwKuJBB/LLvR4v0uPlAoYfkcT1lZic
         /yUHiDAI9oJfMYYY+yNUpKecVGAINz0GseJfF+jWGReHhcRXLTS9K/vFlp6WXUSce2Y/
         iJqg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUYtKxxAGrr4mLfsnkKUZ60ofsARcLz/bnm9P6PV9pd8Odb5g5i
	eI2+VUfbXPKASnaV0Xim6POD7aZetpX71YjOFvIxLqi9HQrTcOVhN9xV91GSLC6t9sfM2XPitRV
	ravVBgrUYR1sMUmz51gBEDpH62xVeAoX1np3QloiznryskpDIYgU/tEf5nehAAiA=
X-Received: by 2002:a50:e048:: with SMTP id g8mr26974939edl.26.1559546170564;
        Mon, 03 Jun 2019 00:16:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+A2uxHwVipmWPcljiURL1MyQFGuCVvE9ypckg9S4u1AqYNPQee71vquaYHJxCafXYrrPA
X-Received: by 2002:a50:e048:: with SMTP id g8mr26974857edl.26.1559546169497;
        Mon, 03 Jun 2019 00:16:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559546169; cv=none;
        d=google.com; s=arc-20160816;
        b=cTAma0y3zKI+sdk5B4LCE1dZW5OCeY/F7FXCUDU2m0jHeQT9M1g5p9wLfLbkO1L+RD
         hSeKeJOVTOVtVEe8bXHoVtfRhJGGs8JyvKDJ0qAoP5QuYojZw+AlsPT2htzowjKeP8Xj
         inRvDXhSwKqvcYOyNvcqOrUJRnfBBor43RojBDjgvUBHTeJ5eBWeW8m1naqMudrlUaQz
         gWeSotd7XvZR8BYowrzBs7sz/6QQ4eoIkSoF4eak9AjEbJ0t4JSIqaWljCLkXUY564wS
         F6B48T/XcJG48Z0zJvGsJxBHRlk0Xx7rKhzQK8BDdi9ydAuEXp2na7Q24molXgxH9YmQ
         S1TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TcUfCOeJBJp9O+U5YdQywRi1GhSonhNYKIV+JErCtd4=;
        b=qPPH3CL0e+1sgVYzij9i8n6b0AqKP4dx0XMkEt/9KqIh+g6bxm2Lv8rMdYNeQPGuXh
         pXF6k8eLfQ+a9rsf48VJfDEz0p0/xwBpAxV9TFzF1L71gosvke9vmHY50yiLjH8wIT2x
         gaUUPF+2q7JjOv1tB9OGk3IpG+7l7EtZ7VThItTNJZP03kqCq1jGPxwvyijzKFd3Tr6n
         nlSaC+EIABlNs6Ouur2djHs+7rsMaMZMZdvH2sEvkM8Q6mwpUY77NRDeqzdLT93J08d9
         piwGeZuXJVXMjOSQIrFpP+TtVYGIRE1Xcg9hz/0VDRdGCREwrC2flCVdM737jlzOSWdY
         UWuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a23si2238842eje.25.2019.06.03.00.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 00:16:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DA7AAADA2;
	Mon,  3 Jun 2019 07:16:08 +0000 (UTC)
Date: Mon, 3 Jun 2019 09:16:07 +0200
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
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
Message-ID: <20190603071607.GB4531@dhcp22.suse.cz>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
 <20190531133904.GC195463@google.com>
 <20190531140332.GT6896@dhcp22.suse.cz>
 <20190531143407.GB216592@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531143407.GB216592@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 23:34:07, Minchan Kim wrote:
> On Fri, May 31, 2019 at 04:03:32PM +0200, Michal Hocko wrote:
> > On Fri 31-05-19 22:39:04, Minchan Kim wrote:
> > > On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> > > > On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > > > > When a process expects no accesses to a certain memory range, it could
> > > > > give a hint to kernel that the pages can be reclaimed when memory pressure
> > > > > happens but data should be preserved for future use.  This could reduce
> > > > > workingset eviction so it ends up increasing performance.
> > > > > 
> > > > > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > > > > MADV_COLD can be used by a process to mark a memory range as not expected
> > > > > to be used in the near future. The hint can help kernel in deciding which
> > > > > pages to evict early during memory pressure.
> > > > > 
> > > > > Internally, it works via deactivating pages from active list to inactive's
> > > > > head if the page is private because inactive list could be full of
> > > > > used-once pages which are first candidate for the reclaiming and that's a
> > > > > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > > > > if the memory pressure happens, they will be reclaimed earlier than other
> > > > > active pages unless there is no access until the time.
> > > > 
> > > > [I am intentionally not looking at the implementation because below
> > > > points should be clear from the changelog - sorry about nagging ;)]
> > > > 
> > > > What kind of pages can be deactivated? Anonymous/File backed.
> > > > Private/shared? If shared, are there any restrictions?
> > > 
> > > Both file and private pages could be deactived from each active LRU
> > > to each inactive LRU if the page has one map_count. In other words,
> > > 
> > >     if (page_mapcount(page) <= 1)
> > >         deactivate_page(page);
> > 
> > Why do we restrict to pages that are single mapped?
> 
> Because page table in one of process shared the page would have access bit
> so finally we couldn't reclaim the page. The more process it is shared,
> the more fail to reclaim.

So what? In other words why should it be restricted solely based on the
map count. I can see a reason to restrict based on the access
permissions because we do not want to simplify all sorts of side channel
attacks but memory reclaim is capable of reclaiming shared pages and so
far I haven't heard any sound argument why madvise should skip those.
Again if there are any reasons, then document them in the changelog.
 
[...]

> > Please document this, if this is really a desirable semantic because
> > then you have the same set of problems as we've had with the early
> > MADV_FREE implementation mentioned above.
> 
> IIRC, the problem of MADV_FREE was that we couldn't discard freeable
> pages because VM never scan anonymous LRU with swapless system.
> However, it's not the our case because we should reclaim them, not
> discarding.

Right. But there is still the page cache reclaim. Is it expected that
an explicitly cold memory doesn't get reclaimed because we have a
sufficient amount of page cache (a very common case) and we never age
anonymous memory because of that?

-- 
Michal Hocko
SUSE Labs

