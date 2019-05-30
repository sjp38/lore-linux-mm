Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3F5CC072B1
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:58:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75D2D247CE
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:58:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75D2D247CE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED37A6B028A; Thu, 30 May 2019 02:57:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E848D6B028B; Thu, 30 May 2019 02:57:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D73406B028C; Thu, 30 May 2019 02:57:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B14A6B028A
	for <linux-mm@kvack.org>; Thu, 30 May 2019 02:57:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so7109564edb.1
        for <linux-mm@kvack.org>; Wed, 29 May 2019 23:57:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BDzlDGwVjUf9yU8ZGzQUMJXdFZlPVAg5rc69GOa9qEs=;
        b=TUJGcTVUoyP65bXaTV+Z5b2tUbfAfxzEwpP8KuPEU7jNYAm6eJ7k/ldGVU4WVbPNak
         fLIds7Vk9E0IsT3ETXcVtyeFtbb+S+qjzEfOqePWSuhym0efHS3zc2WouJZm/z7/yDgu
         dLpA5iap3ujHN4catqWZsimZxDzqpR/awwkBv/IEdidMGAkjGI6iW4UgzgtUphqSNbYg
         8Se9DsM+ZBpO3Z0JxiH3MOAzneM+hZRumzfs3w5dS1pxsSVwkHl/phIc4yWpNsiBZSaj
         7w0ul8qqMCyuuLdUDQbsS+K5ZhRwAtqxN1xcLSkazgJTTjExN86qamLLkOfDrag3id9N
         uTzw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXoXuScHUF3BpD7Vs6MjQ1OClsYD8m8CNg89pEDdKvwWoeq6VFJ
	gLt6pBWrjWezq5VNUZuIKzpJakJyh6Du6eUD3RHnNZJoXlkh9RIgtEnooPYjofkguFvk5xU3KLi
	YXko+QDMBrOj5z4VnSBRtjDniAaOgm3BNXtBp1NbyUZHg71XiZB9UPVZ2X8kTCKg=
X-Received: by 2002:a17:906:448d:: with SMTP id y13mr1952743ejo.262.1559199479105;
        Wed, 29 May 2019 23:57:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOHF3eHvDla+X0dPo6kCOOt1B/lfvqBMgrjzMQli0SPA3vCxUHjDHWVpiRVIdkx2hcWLRv
X-Received: by 2002:a17:906:448d:: with SMTP id y13mr1952695ejo.262.1559199478127;
        Wed, 29 May 2019 23:57:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559199478; cv=none;
        d=google.com; s=arc-20160816;
        b=s22Fm+7TdEji0zDNOYfl/wAHU8Cnou8PZD1Fdor2t+y8PAUgxzM6hIS7AzGRHlfAOz
         H/vcc3+ieMqj22EHTJRREAYrhO5gxntRxRkPkBouDjARKCz+ypsIap+YmAj9VlrNcGcV
         Vwcq24Gzb2kBCl3hMPaE3bvlTINKxQQsXjnCpIWYL6pH6eXZUy93s6P6I7VNhY0lsbHQ
         1ODsdtFSpiBgr+2xk2y9sQzJbrRlDECxEggh1v9T9pQfy0k/8lYrioGln9xQt0JPVw0N
         WmWClecMVYrRqJ+Trs5M5NaGdWZ73UVcg1yOcOs6IuC/fy8yixGDhKhPqFYqBQskvKl+
         eQIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BDzlDGwVjUf9yU8ZGzQUMJXdFZlPVAg5rc69GOa9qEs=;
        b=feKsuvA+gRNLfFK+QEATbes2JwoGq8KuXO69eioip9abR42Y6t1RtG1k5o6qbjZYVe
         D03QAadu3l9tyXCCP53hJqm8wY7C+GRzm/3jvIcYwUeLeEhmByGpJlt40t7t4qym01bq
         uMKnWhLkLCGeYz0dWFwuE1CMgJT9SYmweq32cYF7h5RrVdw9EfsDbADC2O2+8Mi6ky/U
         jXsNHpXGBegpk18M2jWwJ0En058DZGZV5tXScyRxUWmjRhAF/wKoxYA5eO7eggGs2nfg
         kTY/H2RDf5jbHURmU8nCO1tLlMld17wOpcEaG4GzfMnsGiESvf4WQLG7MxEC/NH09aRt
         0tkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x20si487375edm.69.2019.05.29.23.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 23:57:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3B51BAF48;
	Thu, 30 May 2019 06:57:57 +0000 (UTC)
Date: Thu, 30 May 2019 08:57:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Daniel Colascione <dancol@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190530065755.GD6703@dhcp22.suse.cz>
References: <20190520035254.57579-7-minchan@kernel.org>
 <20190520092258.GZ6836@dhcp22.suse.cz>
 <20190521024820.GG10039@google.com>
 <20190521062421.GD32329@dhcp22.suse.cz>
 <20190521102613.GC219653@google.com>
 <20190521103726.GM32329@dhcp22.suse.cz>
 <20190527074940.GB6879@google.com>
 <CAKOZuesK-8zrm1zua4dzqh4TEMivsZKiccySMvfBjOyDkg-MEw@mail.gmail.com>
 <20190529103352.GD18589@dhcp22.suse.cz>
 <20190530021748.GE229459@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530021748.GE229459@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 30-05-19 11:17:48, Minchan Kim wrote:
> On Wed, May 29, 2019 at 12:33:52PM +0200, Michal Hocko wrote:
> > On Wed 29-05-19 03:08:32, Daniel Colascione wrote:
> > > On Mon, May 27, 2019 at 12:49 AM Minchan Kim <minchan@kernel.org> wrote:
> > > >
> > > > On Tue, May 21, 2019 at 12:37:26PM +0200, Michal Hocko wrote:
> > > > > On Tue 21-05-19 19:26:13, Minchan Kim wrote:
> > > > > > On Tue, May 21, 2019 at 08:24:21AM +0200, Michal Hocko wrote:
> > > > > > > On Tue 21-05-19 11:48:20, Minchan Kim wrote:
> > > > > > > > On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> > > > > > > > > [Cc linux-api]
> > > > > > > > >
> > > > > > > > > On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > > > > > > > > > Currently, process_madvise syscall works for only one address range
> > > > > > > > > > so user should call the syscall several times to give hints to
> > > > > > > > > > multiple address range.
> > > > > > > > >
> > > > > > > > > Is that a problem? How big of a problem? Any numbers?
> > > > > > > >
> > > > > > > > We easily have 2000+ vma so it's not trivial overhead. I will come up
> > > > > > > > with number in the description at respin.
> > > > > > >
> > > > > > > Does this really have to be a fast operation? I would expect the monitor
> > > > > > > is by no means a fast path. The system call overhead is not what it used
> > > > > > > to be, sigh, but still for something that is not a hot path it should be
> > > > > > > tolerable, especially when the whole operation is quite expensive on its
> > > > > > > own (wrt. the syscall entry/exit).
> > > > > >
> > > > > > What's different with process_vm_[readv|writev] and vmsplice?
> > > > > > If the range needed to be covered is a lot, vector operation makes senese
> > > > > > to me.
> > > > >
> > > > > I am not saying that the vector API is wrong. All I am trying to say is
> > > > > that the benefit is not really clear so far. If you want to push it
> > > > > through then you should better get some supporting data.
> > > >
> > > > I measured 1000 madvise syscall vs. a vector range syscall with 1000
> > > > ranges on ARM64 mordern device. Even though I saw 15% improvement but
> > > > absoluate gain is just 1ms so I don't think it's worth to support.
> > > > I will drop vector support at next revision.
> > > 
> > > Please do keep the vector support. Absolute timing is misleading,
> > > since in a tight loop, you're not going to contend on mmap_sem. We've
> > > seen tons of improvements in things like camera start come from
> > > coalescing mprotect calls, with the gains coming from taking and
> > > releasing various locks a lot less often and bouncing around less on
> > > the contended lock paths. Raw throughput doesn't tell the whole story,
> > > especially on mobile.
> > 
> > This will always be a double edge sword. Taking a lock for longer can
> > improve a throughput of a single call but it would make a latency for
> > anybody contending on the lock much worse.
> > 
> > Besides that, please do not overcomplicate the thing from the early
> > beginning please. Let's start with a simple and well defined remote
> > madvise alternative first and build a vector API on top with some
> > numbers based on _real_ workloads.
> 
> First time, I didn't think about atomicity about address range race
> because MADV_COLD/PAGEOUT is not critical for the race.
> However you raised the atomicity issue because people would extend
> hints to destructive ones easily. I agree with that and that's why
> we discussed how to guarantee the race and Daniel comes up with good idea.

Just for the clarification, I didn't really mean atomicity but rather a
_consistency_ (essentially time to check to time to use consistency).
 
>   - vma configuration seq number via process_getinfo(2).
> 
> We discussed the race issue without _read_ workloads/requests because
> it's common sense that people might extend the syscall later.
> 
> Here is same. For current workload, we don't need to support vector
> for perfomance point of view based on my experiment. However, it's
> rather limited experiment. Some configuration might have 10000+ vmas
> or really slow CPU. 
> 
> Furthermore, I want to have vector support due to atomicity issue
> if it's really the one we should consider.
> With vector support of the API and vma configuration sequence number
> from Daniel, we could support address ranges operations's atomicity.

I am not sure what do you mean here. Perform all ranges atomicaly wrt.
other address space modifications? If yes I am not sure we want that
semantic because it can cause really long stalls for other operations
but that is a discussion on its own and I would rather focus on a simple
interface first.

> However, since we don't introduce vector at this moment, we need to
> introduce *another syscall* later to be able to handle multile ranges
> all at once atomically if it's okay.

Agreed.

> Other thought:
> Maybe we could extend address range batch syscall covers other MM
> syscall like mmap/munmap/madvise/mprotect and so on because there
> are multiple users that would benefit from this general batching
> mechanism.

Again a discussion on its own ;)

-- 
Michal Hocko
SUSE Labs

