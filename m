Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1061BC04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:03:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D06C12446F
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:03:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D06C12446F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 515786B026F; Fri, 31 May 2019 10:03:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C6136B0272; Fri, 31 May 2019 10:03:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DD6A6B027A; Fri, 31 May 2019 10:03:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEF7F6B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 10:03:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f15so12358455ede.8
        for <linux-mm@kvack.org>; Fri, 31 May 2019 07:03:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P88sQ0EedyxZ1j8sjDczzolnTreW/zwi695NMfjN7iw=;
        b=XHAt4Q6UtDXro81/0Ri83mUmh/QvvDetp/m0TgWivDSxAd9s+CyQ+//iv90+cde7oK
         wM31mFdqEfxAXRwZl4J5lj2juQF1bqysr8j1nm9K/zsN5IZh9QRh6fzlvQBLCm5T9ooF
         JjajzWbNbCrZoxRNlS1b0lL80HJPyxX6Vgtznnykqj0sWgUt5REbFTQNGeChEWlG+o4Z
         nQXnv67GpZg4rcxcLupu5qW+239/PtABrcO7E1HJYQQwUgE2iuz8P8wGiJ8D3upV4dgr
         Zl8oqah1zHCpFuQIOeZ1DfB8cqS0Dy3HusbPFodzR4hV65MSh6drDEmID/vTMis0cfjg
         tnMw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWfQoXruQYkH36IZXkozU1I+X5gfXsuJ7KAAT8OKjVEtIIWCfjg
	H7xXbkB8CLKCatEZwzcE7viQVal2HCnwNl0fOZCe11t2CwHy7Lbzc8FAseORwEdhDvwxpSo34Ko
	UXYT91sr8ADYun7KtO7mcgSVggSRD4ZAk2y9TaLxVLGWtE9D9hZ39F0Dul2xNxkQ=
X-Received: by 2002:a17:906:b250:: with SMTP id ce16mr9041095ejb.99.1559311414428;
        Fri, 31 May 2019 07:03:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHC7NMHFZQP3ovHzcFAdV8W88TifXOzb2Z/UKdBQgWBL9YU0QCuOscUegiUpEYk1reFBMy
X-Received: by 2002:a17:906:b250:: with SMTP id ce16mr9041016ejb.99.1559311413610;
        Fri, 31 May 2019 07:03:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559311413; cv=none;
        d=google.com; s=arc-20160816;
        b=xlJQvkhixbAlTxp/wWMRuMafqM7AYyLiVEY6frdA2jx5n2a/CISY3kywAOvSoHUpS+
         8OdetI8BYY08zHIVjI/B0SSwP9TfS4k88kBg/T7lKFiHgSkH0yH29V7UF/CYp/3f4IIw
         MTAd+UsHvUIjwTyXjFskFysg2I21VkeQUC/to+bR9c8zlcY4uZFPWq627w4BEuh3l777
         pqzZDfzRL+C+DBpKiHmOJbzTsaFC8s14Qy8oBrl/kFeX1QJUpuSskkmYitrO/8uZajt0
         xCHc4H66EYJq1BZCSZKbA7xQkhndJ3b1xBdf3nxBk+B1CvfsK58ZoD3tTHUz9BRv/xS2
         ULxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P88sQ0EedyxZ1j8sjDczzolnTreW/zwi695NMfjN7iw=;
        b=05b5XCC2tb2UJz++L/ldOOfU4/GgxG113LXxdNmbHtoaJABqVaQbg+RqD2z6Lst1+r
         sEoy9GopG0gjsjR+sekQ0qXMI2xI+gTnrKs2bcMruxrix83CxuGHIdX8+YbRRRjdHoDY
         FLDGLP9HNCdkgwo0qUwB++1GnYd5RESspc/gR2BLlzS+H331hmN9kUQyyrxAqb5zj/8h
         44XqmYPDwCO5CLNGjDiZJMrvEQkQKvKcUrJgK/3dhI8MBqKknGcYJsfuqubhTbdCE4rr
         NPgF22erFSW/FFHgGBfQCz7Ww8gLsKQYdw5h49fwyRT0t9kwfOeW42kkqnnn/gYe5L+W
         LANg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gk15si3687315ejb.270.2019.05.31.07.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 07:03:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C57EDAF52;
	Fri, 31 May 2019 14:03:32 +0000 (UTC)
Date: Fri, 31 May 2019 16:03:32 +0200
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
Message-ID: <20190531140332.GT6896@dhcp22.suse.cz>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
 <20190531133904.GC195463@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531133904.GC195463@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 22:39:04, Minchan Kim wrote:
> On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> > On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > > When a process expects no accesses to a certain memory range, it could
> > > give a hint to kernel that the pages can be reclaimed when memory pressure
> > > happens but data should be preserved for future use.  This could reduce
> > > workingset eviction so it ends up increasing performance.
> > > 
> > > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > > MADV_COLD can be used by a process to mark a memory range as not expected
> > > to be used in the near future. The hint can help kernel in deciding which
> > > pages to evict early during memory pressure.
> > > 
> > > Internally, it works via deactivating pages from active list to inactive's
> > > head if the page is private because inactive list could be full of
> > > used-once pages which are first candidate for the reclaiming and that's a
> > > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > > if the memory pressure happens, they will be reclaimed earlier than other
> > > active pages unless there is no access until the time.
> > 
> > [I am intentionally not looking at the implementation because below
> > points should be clear from the changelog - sorry about nagging ;)]
> > 
> > What kind of pages can be deactivated? Anonymous/File backed.
> > Private/shared? If shared, are there any restrictions?
> 
> Both file and private pages could be deactived from each active LRU
> to each inactive LRU if the page has one map_count. In other words,
> 
>     if (page_mapcount(page) <= 1)
>         deactivate_page(page);

Why do we restrict to pages that are single mapped?

> > Are there any restrictions on mappings? E.g. what would be an effect of
> > this operation on hugetlbfs mapping?
> 
> VM_LOCKED|VM_HUGETLB|VM_PFNMAP vma will be skipped like MADV_FREE|DONTNEED

OK documenting that this is restricted to the same vmas as MADV_FREE|DONTNEED
is really useful to mention.

> 
> > 
> > Also you are talking about inactive LRU but what kind of LRU is that? Is
> > it the anonymous LRU? If yes, don't we have the same problem as with the
> 
> active file page -> inactive file LRU
> active anon page -> inacdtive anon LRU
> 
> > early MADV_FREE implementation when enough page cache causes that
> > deactivated anonymous memory doesn't get reclaimed anytime soon. Or
> > worse never when there is no swap available?
> 
> I think MADV_COLD is a little bit different symantic with MAVD_FREE.
> MADV_FREE means it's okay to discard when the memory pressure because
> the content of the page is *garbage*. Furthemore, freeing such pages is
> almost zero overhead since we don't need to swap out and access
> afterward causes minor fault. Thus, it would make sense to put those
> freeable pages in inactive file LRU to compete other used-once pages.
> 
> However, MADV_COLD doesn't means it's a garbage and freeing requires
> swap out/swap in afterward. So, it would be better to move inactive
> anon's LRU list, not file LRU. Furthermore, it would avoid unnecessary
> scanning of those cold anonymous if system doesn't have a swap device.

Please document this, if this is really a desirable semantic because
then you have the same set of problems as we've had with the early
MADV_FREE implementation mentioned above.

-- 
Michal Hocko
SUSE Labs

