Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2832C28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:06:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B8A3249EF
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:06:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="jObHag2R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B8A3249EF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09C446B0008; Tue,  4 Jun 2019 08:06:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 027416B0277; Tue,  4 Jun 2019 08:06:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E09BB6B0278; Tue,  4 Jun 2019 08:06:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A9FB66B0008
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:06:32 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k13so3375714qkj.4
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:06:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CSGvUx9GojQFsA0lbdZ+SFaekbPmlUjrQKgejokKg+k=;
        b=U9To+cbhF567sRpwY543l3JYmvDWtFBZbC4N+vExLMQig5jYzhvmOMCT3btjoWMTMC
         r9+zZyDHjiPSJaQkNs+xpZWb6WCR+gvKh82mrXE5IyF7AceQ07B/9wPatM7IrO5AFqGW
         q6dIMrHzY8XAqVxaJx7LbeyJhTGVB+TfPlT4cA7KG6Q0ZaiUz2Ni9Ygt26Ms0aRN/5LE
         xmtNCY0C2ahp3LFJ9il8tUSSJf4zINo1aQ9anDOcOF17txQGVZzyDWjP1J7YECBn1jb/
         T3LH0c66nChE10pz+t+ys+in5QEs93SumiRxVBqV1yc+cA2R4ceC2sA+PskTULXOWUSp
         AY4w==
X-Gm-Message-State: APjAAAVJrfXVlFGqhxf9TEvCknWEq61r/KodXx/0F6xPdeaMuWgR2bRA
	Jlyn65WN4oFzV7eL80scXbiqAxqCDAylbgyqKCMAr8B4arftJ2upSCkDoDXwGZEBuYYDUlKdbaP
	I8uKP20NWxJZpkeHk8Q4dim45lC/Qgs1ebQlKkeo2l7zbBOFW+M9nkrt44wWtW9yuKQ==
X-Received: by 2002:a0c:9b94:: with SMTP id o20mr26697033qve.56.1559649992362;
        Tue, 04 Jun 2019 05:06:32 -0700 (PDT)
X-Received: by 2002:a0c:9b94:: with SMTP id o20mr26696952qve.56.1559649991387;
        Tue, 04 Jun 2019 05:06:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559649991; cv=none;
        d=google.com; s=arc-20160816;
        b=i4DFAEyfqjstEze611vp6QnnGUdMAAgYfhQhQL+Fj8PMuKkO8cD2zWhqGZVPimbSGM
         d+S1X3KYZUnhBv7LPjwreMnT/iPfxTp2GsOiCLvNQepe9Lgqyyv+wwef3jrZWjIp3CuW
         ARcc5bxxxeLMyIiNrjmc9SwpK2cLbDt2wsjOoRs7to7Z5ry3go2W7YvseCDHz0ynDAVQ
         FWZSlsLI31XhuHrwh5x8pxiNuF+bKfkOF1Js0xiUoA7eStHh6NgDnsWIATiSNnTMMXqt
         w52f5aQER/iuHQX5KsbTmL6Zjaz0V2/gciA59scyCGqXMlzB+Gi732q5Ph804cBwwufF
         ElTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CSGvUx9GojQFsA0lbdZ+SFaekbPmlUjrQKgejokKg+k=;
        b=AlDZZMJIzaUz0xK3x1R/FmcCJX93oyWaq3vs2Av5ZnD/SVNwZP93CNPm+qlxkER1rU
         /jhiYx7QlgIBsqMHZHrHo8UK086/mH/KMPBxPwtVyQ1INX7M09BaFxLV1cyJrundmAX0
         sAchp4+Fc+Cg66pIAtFmACTDETHp5iN/OKd2FRzBhiwTaovSBlJSzw5PVzipyvCzxSys
         LKCy90rvMzA32swB7rUwqeHePQaYqGcatjlILzf5M913NJAxxTH7dbkBdOQPeFi0LRwC
         8Q3BBcSprGW+W3DsHL+um4wECInGV/uc6QCSyWi55PLaFtxwCONuLhJBuO1h+pJgn7jL
         VHeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=jObHag2R;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b23sor5762710qte.55.2019.06.04.05.06.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 05:06:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=jObHag2R;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CSGvUx9GojQFsA0lbdZ+SFaekbPmlUjrQKgejokKg+k=;
        b=jObHag2Re1OQBRiPMD98LKrbSNXBg6U1V1ih7Z8e/sxI0KtTI0tlLleyPBg6b6FPuO
         4YXwRYrtOUdO4UAhu79DSk/AxeS5fDUnFzQ0vy/akFx/lrL6FcLkBvQZGnwMlQxnhht4
         2dHeiTo01NzbeHT09DkNC5BoCsfuAVLi/FWfVcl41TSQYyN0IQoDOxRfutLoa6xczt5s
         PuyuQAjPEbDZ6j0gBzX1DbBrWXUA30LxltDBBKb7rf+VP1I91vFD8byta9GSVgC9zQtS
         ti259Z2ipr20LdJJEmD3lLEQgQvhTFr3QlySJCsBJlA34Jk+eeVrKR7peB1o5cd18wq5
         jJ9g==
X-Google-Smtp-Source: APXvYqzREUMVRw04rOCmkwg6WVeALFec0tCWaO0n3ko0P3uVHl4IzYBAnV0CskTwR8PG+uweBo7Y9w==
X-Received: by 2002:ac8:2a63:: with SMTP id l32mr8071637qtl.117.1559649988572;
        Tue, 04 Jun 2019 05:06:28 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id t189sm615951qkd.54.2019.06.04.05.06.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 05:06:27 -0700 (PDT)
Date: Tue, 4 Jun 2019 08:06:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>,
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
Message-ID: <20190604120626.GB18545@cmpxchg.org>
References: <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
 <20190531133904.GC195463@google.com>
 <20190531140332.GT6896@dhcp22.suse.cz>
 <20190531143407.GB216592@google.com>
 <20190603071607.GB4531@dhcp22.suse.cz>
 <20190603172717.GA30363@cmpxchg.org>
 <20190603203230.GB22799@dhcp22.suse.cz>
 <20190603215059.GA16824@cmpxchg.org>
 <20190603230205.GA43390@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603230205.GA43390@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 08:02:05AM +0900, Minchan Kim wrote:
> Hi Johannes,
> 
> On Mon, Jun 03, 2019 at 05:50:59PM -0400, Johannes Weiner wrote:
> > On Mon, Jun 03, 2019 at 10:32:30PM +0200, Michal Hocko wrote:
> > > On Mon 03-06-19 13:27:17, Johannes Weiner wrote:
> > > > On Mon, Jun 03, 2019 at 09:16:07AM +0200, Michal Hocko wrote:
> > > > > On Fri 31-05-19 23:34:07, Minchan Kim wrote:
> > > > > > On Fri, May 31, 2019 at 04:03:32PM +0200, Michal Hocko wrote:
> > > > > > > On Fri 31-05-19 22:39:04, Minchan Kim wrote:
> > > > > > > > On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> > > > > > > > > On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > > > > > > > > > When a process expects no accesses to a certain memory range, it could
> > > > > > > > > > give a hint to kernel that the pages can be reclaimed when memory pressure
> > > > > > > > > > happens but data should be preserved for future use.  This could reduce
> > > > > > > > > > workingset eviction so it ends up increasing performance.
> > > > > > > > > > 
> > > > > > > > > > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > > > > > > > > > MADV_COLD can be used by a process to mark a memory range as not expected
> > > > > > > > > > to be used in the near future. The hint can help kernel in deciding which
> > > > > > > > > > pages to evict early during memory pressure.
> > > > > > > > > > 
> > > > > > > > > > Internally, it works via deactivating pages from active list to inactive's
> > > > > > > > > > head if the page is private because inactive list could be full of
> > > > > > > > > > used-once pages which are first candidate for the reclaiming and that's a
> > > > > > > > > > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > > > > > > > > > if the memory pressure happens, they will be reclaimed earlier than other
> > > > > > > > > > active pages unless there is no access until the time.
> > > > > > > > > 
> > > > > > > > > [I am intentionally not looking at the implementation because below
> > > > > > > > > points should be clear from the changelog - sorry about nagging ;)]
> > > > > > > > > 
> > > > > > > > > What kind of pages can be deactivated? Anonymous/File backed.
> > > > > > > > > Private/shared? If shared, are there any restrictions?
> > > > > > > > 
> > > > > > > > Both file and private pages could be deactived from each active LRU
> > > > > > > > to each inactive LRU if the page has one map_count. In other words,
> > > > > > > > 
> > > > > > > >     if (page_mapcount(page) <= 1)
> > > > > > > >         deactivate_page(page);
> > > > > > > 
> > > > > > > Why do we restrict to pages that are single mapped?
> > > > > > 
> > > > > > Because page table in one of process shared the page would have access bit
> > > > > > so finally we couldn't reclaim the page. The more process it is shared,
> > > > > > the more fail to reclaim.
> > > > > 
> > > > > So what? In other words why should it be restricted solely based on the
> > > > > map count. I can see a reason to restrict based on the access
> > > > > permissions because we do not want to simplify all sorts of side channel
> > > > > attacks but memory reclaim is capable of reclaiming shared pages and so
> > > > > far I haven't heard any sound argument why madvise should skip those.
> > > > > Again if there are any reasons, then document them in the changelog.
> > > > 
> > > > I think it makes sense. It could be explained, but it also follows
> > > > established madvise semantics, and I'm not sure it's necessarily
> > > > Minchan's job to re-iterate those.
> > > > 
> > > > Sharing isn't exactly transparent to userspace. The kernel does COW,
> > > > ksm etc. When you madvise, you can really only speak for your own
> > > > reference to that memory - "*I* am not using this."
> > > > 
> > > > This is in line with other madvise calls: MADV_DONTNEED clears the
> > > > local page table entries and drops the corresponding references, so
> > > > shared pages won't get freed. MADV_FREE clears the pte dirty bit and
> > > > also has explicit mapcount checks before clearing PG_dirty, so again
> > > > shared pages don't get freed.
> > > 
> > > Right, being consistent with other madvise syscalls is certainly a way
> > > to go. And I am not pushing one way or another, I just want this to be
> > > documented with a reasoning behind. Consistency is certainly an argument
> > > to use.
> > > 
> > > On the other hand these non-destructive madvise operations are quite
> > > different and the shared policy might differ as a result as well. We are
> > > aging objects rather than destroying them after all. Being able to age
> > > a pagecache with a sufficient privileges sounds like a useful usecase to
> > > me. In other words you are able to cause the same effect indirectly
> > > without the madvise operation so it kinda makes sense to allow it in a
> > > more sophisticated way.
> > 
> > Right, I don't think it's about permission - as you say, you can do
> > this indirectly. Page reclaim is all about relative page order, so if
> > we thwarted you from demoting some pages, you could instead promote
> > other pages to cause a similar end result.
> > 
> > I think it's about intent. You're advising the kernel that *you're*
> > not using this memory and would like to have it cleared out based on
> > that knowledge. You could do the same by simply allocating the new
> > pages and have the kernel sort it out. However, if the kernel sorts it
> > out, it *will* look at other users of the page, and it might decide
> > that other pages are actually colder when considering all users.
> > 
> > When you ignore shared state, on the other hand, the pages you advise
> > out could refault right after. And then, not only did you not free up
> > the memory, but you also caused IO that may interfere with bringing in
> > the new data for which you tried to create room in the first place.
> > 
> > So I don't think it ever makes sense to override it.
> > 
> > But it might be better to drop the explicit mapcount check and instead
> > make the local pte young and call shrink_page_list() without the
>                      ^
>                      old?

Ah yes, of course. Clear the reference bit.

> > TTU_IGNORE_ACCESS, ignore_references flags - leave it to reclaim code
> > to handle references and shared pages exactly the same way it would if
> > those pages came fresh off the LRU tail, excluding only the reference
> > from the mapping that we're madvising.
> 
> You are confused from the name change. Here, MADV_COLD is deactivating
> , not pageing out. Therefore, shrink_page_list doesn't matter.
> And madvise_cold_pte_range already makes the local pte *old*(I guess
> your saying was typo).
> I guess that's exactly what Michal wanted: just removing page_mapcount
> check and defers to decision on normal page reclaim policy:
> If I didn't miss your intention, it seems you and Michal are on same page.
> (Please correct me if you want to say something other)
> I could drop the page_mapcount check at next revision.

Sorry, I was actually talking about the MADV_PAGEOUT patch in this
case, since this turned into a general discussion about how shared
pages should be handled, which applies to both operations.

My argument was for removing the check in both patches, yes, but to
additionally change the pageout patch to 1) make the advised pte old
and then 2) call shrink_page_list() WITHOUT ignore_access/references
so that it respects references from other mappings, if any.

