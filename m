Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CDCAC46470
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:55:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9FAC24DFC
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:55:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9FAC24DFC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6190C6B0266; Tue,  4 Jun 2019 02:55:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C30D6B0269; Tue,  4 Jun 2019 02:55:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 492726B026A; Tue,  4 Jun 2019 02:55:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF0FB6B0266
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:55:43 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a21so16053420edt.23
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:55:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kB1owiAwkJzggebCYwkxBdcvv4EURqFgI7XX/RJAY8o=;
        b=fBz8azeDenGn4gJZSSyj+L4DHdtL3MMRatG4F+DpQMhNzHg5+vQ/1K3WSG83+M/AE5
         lO0sd0viDzulmR7RD3bDwgPGKmCcmN5XMxgvYHQsH/5WM4WBQ8EY3WeAVBYV9pzA2vmp
         26QObHdT1FbZSr35wPLE1XW4yYvMuarg/3/52e58w/ETBFePUUWRWADZGLPK1JNTQ7Q5
         9yJOgBEhzDOLkqXWisl/LUzAFTlUFlGjLJvsnaER9zaZBUkys6j+oTFJTXCcPrviH5oz
         JlVtQtczw5ETuq6ltUVvB8kwuMV8j50B8BS7JHH9IV80JwXxIu6LTuT47+DCagTeifwW
         fUoQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUw8wKuqNdK1QzOPShKa2Gu84uoNKRkwHnjNNOwQ7RgU9mFqBuN
	al/2DJf0zRQ3ZinQKkzrOA1WZMM8q9aC3FetXV4hDLuEwzxGyrlEeOt3yk+HG9ceuMGy8SbOb+y
	ZtgJTSuTDjnqPOgIpjfCF5VHp+KYjTw1ZQ/a4KfK/SvhP5tzUL33AwMw99V6DCjA=
X-Received: by 2002:a17:906:b786:: with SMTP id dt6mr27659910ejb.307.1559631343506;
        Mon, 03 Jun 2019 23:55:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7eEmagwig8TaSI37pEKkpLD9GtrC7+q8Izco/XYRildtMMzkx3z/JVwd63Xf8UJSTvKKF
X-Received: by 2002:a17:906:b786:: with SMTP id dt6mr27659846ejb.307.1559631342338;
        Mon, 03 Jun 2019 23:55:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631342; cv=none;
        d=google.com; s=arc-20160816;
        b=EJ0i6znPym++RHUluRfTWcsJ9SbRm56vpoKWRKxeIw33MrsUSOEkiJA6W8/hd8bgKx
         e7vWq5NMlnkEjqTieGTti3PN7K4PL+dRlN4N4WaYV2+R0b/PwgzEjjue4KPSQ0cWuWDP
         kRxgQWa/UlReDj7BdhgkaTMW86Tui7LwTKRG5viiOgfBmB3gvVCPQ5/n6EChhKmNlic3
         Qq1+TFu6hEePHS45Vm8qAjVB7l9KQnuL5Qhr4I/dwR9OYRYN8ib43MiAbJ15Azl7NcT5
         jS9I+snDOGimm0JCRfJKYDvcwWiqtwAcncB99Vg3LuhKDMb0oPlTZS6mjluhsnc/k9Vc
         lppw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kB1owiAwkJzggebCYwkxBdcvv4EURqFgI7XX/RJAY8o=;
        b=LSKg/kVBjQdl1lzk9HgrEE5qo8ummeSf3DQkW8eaGY+QFhj3QB/9qlZcdq8/iIEKcL
         fa0J427h1n2a4+1Pq7uA68YCkDEdlzjCIbfwJAMIgw7tXDO3dNOM0dPf2XNUTENx4yMZ
         UxaS2HDf3gaz9ufZd26hL3uE6jGe5P7rPDNUaGqKlkXtAlznUXvfEXxXa1AznqELipWF
         6mUPBLDWzjuHdLtbaYqqalIFY6Wq/pvSUxDna4CaEOGuiKcAIUxbKYwpKYJ6i9JuofL6
         68+6peJhr2FAXP+8BCPkoEWngIwmDs9KkwpxoUGS21qe1vqZjUDLUjcwexnWHFFsZAnS
         eTSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y11si7076153ejb.192.2019.06.03.23.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 23:55:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 76144AD51;
	Tue,  4 Jun 2019 06:55:41 +0000 (UTC)
Date: Tue, 4 Jun 2019 08:55:39 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
Message-ID: <20190604065539.GB4669@dhcp22.suse.cz>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
 <20190531133904.GC195463@google.com>
 <20190531140332.GT6896@dhcp22.suse.cz>
 <20190531143407.GB216592@google.com>
 <20190603071607.GB4531@dhcp22.suse.cz>
 <20190603172717.GA30363@cmpxchg.org>
 <20190603203230.GB22799@dhcp22.suse.cz>
 <20190603215059.GA16824@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603215059.GA16824@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 03-06-19 17:50:59, Johannes Weiner wrote:
> On Mon, Jun 03, 2019 at 10:32:30PM +0200, Michal Hocko wrote:
> > On Mon 03-06-19 13:27:17, Johannes Weiner wrote:
> > > On Mon, Jun 03, 2019 at 09:16:07AM +0200, Michal Hocko wrote:
> > > > On Fri 31-05-19 23:34:07, Minchan Kim wrote:
> > > > > On Fri, May 31, 2019 at 04:03:32PM +0200, Michal Hocko wrote:
> > > > > > On Fri 31-05-19 22:39:04, Minchan Kim wrote:
> > > > > > > On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> > > > > > > > On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > > > > > > > > When a process expects no accesses to a certain memory range, it could
> > > > > > > > > give a hint to kernel that the pages can be reclaimed when memory pressure
> > > > > > > > > happens but data should be preserved for future use.  This could reduce
> > > > > > > > > workingset eviction so it ends up increasing performance.
> > > > > > > > > 
> > > > > > > > > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > > > > > > > > MADV_COLD can be used by a process to mark a memory range as not expected
> > > > > > > > > to be used in the near future. The hint can help kernel in deciding which
> > > > > > > > > pages to evict early during memory pressure.
> > > > > > > > > 
> > > > > > > > > Internally, it works via deactivating pages from active list to inactive's
> > > > > > > > > head if the page is private because inactive list could be full of
> > > > > > > > > used-once pages which are first candidate for the reclaiming and that's a
> > > > > > > > > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > > > > > > > > if the memory pressure happens, they will be reclaimed earlier than other
> > > > > > > > > active pages unless there is no access until the time.
> > > > > > > > 
> > > > > > > > [I am intentionally not looking at the implementation because below
> > > > > > > > points should be clear from the changelog - sorry about nagging ;)]
> > > > > > > > 
> > > > > > > > What kind of pages can be deactivated? Anonymous/File backed.
> > > > > > > > Private/shared? If shared, are there any restrictions?
> > > > > > > 
> > > > > > > Both file and private pages could be deactived from each active LRU
> > > > > > > to each inactive LRU if the page has one map_count. In other words,
> > > > > > > 
> > > > > > >     if (page_mapcount(page) <= 1)
> > > > > > >         deactivate_page(page);
> > > > > > 
> > > > > > Why do we restrict to pages that are single mapped?
> > > > > 
> > > > > Because page table in one of process shared the page would have access bit
> > > > > so finally we couldn't reclaim the page. The more process it is shared,
> > > > > the more fail to reclaim.
> > > > 
> > > > So what? In other words why should it be restricted solely based on the
> > > > map count. I can see a reason to restrict based on the access
> > > > permissions because we do not want to simplify all sorts of side channel
> > > > attacks but memory reclaim is capable of reclaiming shared pages and so
> > > > far I haven't heard any sound argument why madvise should skip those.
> > > > Again if there are any reasons, then document them in the changelog.
> > > 
> > > I think it makes sense. It could be explained, but it also follows
> > > established madvise semantics, and I'm not sure it's necessarily
> > > Minchan's job to re-iterate those.
> > > 
> > > Sharing isn't exactly transparent to userspace. The kernel does COW,
> > > ksm etc. When you madvise, you can really only speak for your own
> > > reference to that memory - "*I* am not using this."
> > > 
> > > This is in line with other madvise calls: MADV_DONTNEED clears the
> > > local page table entries and drops the corresponding references, so
> > > shared pages won't get freed. MADV_FREE clears the pte dirty bit and
> > > also has explicit mapcount checks before clearing PG_dirty, so again
> > > shared pages don't get freed.
> > 
> > Right, being consistent with other madvise syscalls is certainly a way
> > to go. And I am not pushing one way or another, I just want this to be
> > documented with a reasoning behind. Consistency is certainly an argument
> > to use.
> > 
> > On the other hand these non-destructive madvise operations are quite
> > different and the shared policy might differ as a result as well. We are
> > aging objects rather than destroying them after all. Being able to age
> > a pagecache with a sufficient privileges sounds like a useful usecase to
> > me. In other words you are able to cause the same effect indirectly
> > without the madvise operation so it kinda makes sense to allow it in a
> > more sophisticated way.
> 
> Right, I don't think it's about permission - as you say, you can do
> this indirectly. Page reclaim is all about relative page order, so if
> we thwarted you from demoting some pages, you could instead promote
> other pages to cause a similar end result.

There is one notable difference. If we allow an easy way to demote a
shared resource _easily_ then we have to think about potential side
channel attacks. Sure you can generate a memory pressure to cause the
same but that is much harder and impractical in many cases.

> I think it's about intent. You're advising the kernel that *you're*
> not using this memory and would like to have it cleared out based on
> that knowledge. You could do the same by simply allocating the new
> pages and have the kernel sort it out. However, if the kernel sorts it
> out, it *will* look at other users of the page, and it might decide
> that other pages are actually colder when considering all users.
> 
> When you ignore shared state, on the other hand, the pages you advise
> out could refault right after. And then, not only did you not free up
> the memory, but you also caused IO that may interfere with bringing in
> the new data for which you tried to create room in the first place.

That is a fair argument and I would tend to agree. On the other hand we
are talking about potential usecases which tend to _know_ what they are
doing and removing the possibility completely sounds like they will not
exploit the existing interface to the maximum. But as already mentioned
starting simpler and more restricted is usually a better choice when
the semantic is not carved in stone from the very beginning and
documented that way.

> So I don't think it ever makes sense to override it.
> 
> But it might be better to drop the explicit mapcount check and instead
> make the local pte young and call shrink_page_list() without the
> TTU_IGNORE_ACCESS, ignore_references flags - leave it to reclaim code
> to handle references and shared pages exactly the same way it would if
> those pages came fresh off the LRU tail, excluding only the reference
> from the mapping that we're madvising.

Yeah that makes sense to me.

-- 
Michal Hocko
SUSE Labs

