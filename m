Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC1E8C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 15:36:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E34521479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 15:36:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E34521479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAE146B0005; Mon, 20 May 2019 11:36:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5DC26B0006; Mon, 20 May 2019 11:36:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C25226B0007; Mon, 20 May 2019 11:36:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 73B7A6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 11:36:54 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f41so25810073ede.1
        for <linux-mm@kvack.org>; Mon, 20 May 2019 08:36:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dKtnnR220p1pBgaJmzWJIH9NsEwrV+GpaoDkpEPAbls=;
        b=I63pE9YAHpi1QxeAeMJjAUMuB5JxQGsuXlNz5unxdE4xkgsN1t5v7rxoWnZadxwNaT
         z9p2wB1ymOmexiwDfgvyGNBr95jtxPmyiLtaqNHPltGaq2JYcCdbh4nRLM7zy37DnyBi
         2Z2lW4/vvn97qBVM/a8rAS8pviJ/T9vCFz1t99o5lVcbNrV2x/CCwa0cH8vCFs2fA9VN
         pX/NnxCIFkiUwYfNhgYGvU2uvmP+fZtL9BoiD2cUgHZYP7ZaWzmguv3W9yZ5mEw6vuTQ
         Ja36J6bkNx8AUYWwoh0vV5qEGqE9tjJtstBQUjKYLMgOfBxvoKWbIfu2sqAsDtsuLVa/
         WfMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAU/PVEAqT7KTld2mgSjdfRtd3i4KuXlt9marISCpIUtCcqLxavW
	FvxnWBtAsk2na9tJcnkyKCvGZaRz4y6VDgKLvRyeJYOJpb8Oi4ZN00Z7zY2XcbHTkZs/JQp8Y3O
	LQ+HmSyEHoUnssgxlIY75sofUPUfE8mAsl7OUCxTTQ3Umpond/ZdK1HSTKot1IcHcew==
X-Received: by 2002:a50:abe5:: with SMTP id u92mr71631739edc.164.1558366613947;
        Mon, 20 May 2019 08:36:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0LCdXfhdnD1yjVnrUK7XChaOISgUassmjfEheuchG2y0maIKxY4iLyGvicsKqzL15jvCp
X-Received: by 2002:a50:abe5:: with SMTP id u92mr71631625edc.164.1558366612642;
        Mon, 20 May 2019 08:36:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558366612; cv=none;
        d=google.com; s=arc-20160816;
        b=QUu2Cjye/woW2Hmxigzeqvb5rP5fxyeJG80GWFTKmuqqYdXxxq4mWBebHNw2E//BHU
         brVPriQ5Ey7GWss+bSeRb2gPFhkY3BHDgpfWZWmg8KQ7B5IkztlRJ8Ey5mOEn/N9Ql6k
         9wfDpreYypgHPGGlt5FkppYrq79AKgC/hTN1fvJ7VvR/w1O6xRlVNwCeOyVoiKqiR26r
         BU+bE6JqGHhPs+d4g66o0eCSv+GElMC04T95Zw/j0X/HE7oTVB59eXd6J8iuxSTQye3b
         u4CwDsdvAWtyC6lHK1W3HeBuwyUiLnYltTWc7sv42HIiPemw/WcFh9+sEYKRXYMKBZsi
         tU3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dKtnnR220p1pBgaJmzWJIH9NsEwrV+GpaoDkpEPAbls=;
        b=w9loOviZkqEoPYGvwECueMQB5xLbIVktI8AXXI9RDuq9JxJFuXGuqvDp+ltZGtYBee
         JFLwnayJCcqyAhFxAoAeXLpzH5jQWchmPYA97+c8Heep/lDojpPpTwDXvZAuK6fcl/t4
         PqlutJZhMQYkkiXst5pVCzwJ9GoVxpWEcrRkp+k+o5ts61hZbDXdUB0UJGe3fxzI3+X6
         auNmMAGpdahCkut+qSxt/jHhfcSpiF3Tw4ey+HEDyZQuw/aWQWwvprDJ7ZwdNgH1IclX
         b3ryM7dOnIY7Jl16TlHjE2KhJh0LokeA1htbqNCWl+eSm79YypjWW2NR2MSe0nTTIaC/
         w9CQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e47si9247706edd.43.2019.05.20.08.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 08:36:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B48F6AFE3;
	Mon, 20 May 2019 15:36:51 +0000 (UTC)
Date: Mon, 20 May 2019 16:36:48 +0100
From: Mel Gorman <mgorman@suse.de>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
Message-ID: <20190520153621.GL18914@techsingularity.net>
References: <20190503223146.2312-1-aarcange@redhat.com>
 <20190503223146.2312-3-aarcange@redhat.com>
 <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 01:26:26PM -0700, David Rientjes wrote:
> On Fri, 3 May 2019, Andrea Arcangeli wrote:
> 
> > This reverts commit 2f0799a0ffc033bf3cc82d5032acc3ec633464c2.
> > 
> > commit 2f0799a0ffc033bf3cc82d5032acc3ec633464c2 was rightfully applied
> > to avoid the risk of a severe regression that was reported by the
> > kernel test robot at the end of the merge window. Now we understood
> > the regression was a false positive and was caused by a significant
> > increase in fairness during a swap trashing benchmark. So it's safe to
> > re-apply the fix and continue improving the code from there. The
> > benchmark that reported the regression is very useful, but it provides
> > a meaningful result only when there is no significant alteration in
> > fairness during the workload. The removal of __GFP_THISNODE increased
> > fairness.
> > 
> 
> Hi Andrea,
> 
> There was exhausting discussion subsequent to this that caused Linus to 
> have to revert the offending commit late in an rc series that is not 
> described here. 

Yes, at the crux of that matter was which regression introduced was more
important -- the one causing swap storms which Andrea is trying to address
or a latency issue due to assumptions of locality when MADV_HUGEPAGE
is used.

More people are affected by swap storms and distributions are carrying
out-of-tree patches to address it. Furthermore, multiple people unrelated
to each other can trivially reproduce the problem with test cases and
experience the problem with real workloads. Only you has a realistic
workload sensitive to the latency issue and we've asked repeatedly for
a test case (most recently Michal Hocko on May 4th) which is still not
available.

Currently the revert has to be carried out of tree for at least some
distributions which means any mainline users will have very different
experiences to distro users. Normally this is true anyway, but this is
an extreme example. The most important point is that the latency
problems are relatively difficult for a normal user to detect but a swap
storm is extremely easy to detect. We should be defaulting to the
behaviour that causes the least overall harm.

> This was after the offending commit, which this commit 
> now reintroduces, was described as causing user facing access latency 
> regressions and nacked.  The same objection is obviously going to be made 
> here and I'd really prefer if this could be worked out without yet another 
> merge into -mm, push to Linus, and revert by Linus.  There are solutions 
> to this issue that does not cause anybody to have performance regressions 
> rather than reintroducing them for a class of users that use the 
> overloaded MADV_HUGEPAGE for the purposes it has provided them over the 
> past three years.
> 

There are no solutions implemented although there are solutions possible --
however, forcing zone_reclaim_mode like behaviour when zone_reclaim_mode
is disabled makes the path forward hazardous.

> > __GFP_THISNODE cannot be used in the generic page faults path for new
> > memory allocations under the MPOL_DEFAULT mempolicy, or the allocation
> > behavior significantly deviates from what the MPOL_DEFAULT semantics
> > are supposed to be for THP and 4k allocations alike.
> > 
> 
> This isn't an argument in support of this patch, there is a difference 
> between (1) pages of the native page size being faulted first locally
> falling back remotely and (2) hugepages being faulted first locally and 
> falling back to native pages locally because it has better access latency 
> on most platforms for workloads that do not span multiple nodes.  Note 
> that the page allocator is unaware whether the workload spans multiple 
> nodes so it cannot make this distinction today, and that's what I'd prefer 
> to focus on rather than changing an overall policy for everybody.
> 

Overall, I think it would be ok to have behaviour whereby local THP is
allocated if cheaply, followed by base pages local followed by the remote
options. However, __GFP_THISNODE removes the possibility of allowing
remote fallback and instead causing a swap storm and swap storms are
trivial to generate on NUMA machine running a mainline kernel today.

If a workload really prefers local huge pages even if that incurs
reclaim, it should be a deliberate choice.

> > Setting THP defrag to "always" or using MADV_HUGEPAGE (with THP defrag
> > set to "madvise") has never meant to provide an implicit MPOL_BIND on
> > the "current" node the task is running on, causing swap storms and
> > providing a much more aggressive behavior than even zone_reclaim_node
> > = 3.
> > 
> 
> It may not have been meant to provide this, but when IBM changed this 
> three years ago because of performance regressions and others have started 
> to use MADV_HUGEPAGE with that policy in mind, it is the reality of what 
> the madvise advice has provided.  What was meant to be semantics of 
> MADV_HUGEPAGE three years ago is irrelevant today if it introduces 
> performance regressions for users who have used the advice mode during 
> that past three years.
> 

Incurring swap storms when there is plenty of free memory available is
terrible. If the working set size is larger than a node, the swap storm
may even persist indefinitely.

> > Any workload who could have benefited from __GFP_THISNODE has now to
> > enable zone_reclaim_mode=1||2||3. __GFP_THISNODE implicitly provided
> > the zone_reclaim_mode behavior, but it only did so if THP was enabled:
> > if THP was disabled, there would have been no chance to get any 4k
> > page from the current node if the current node was full of pagecache,
> > which further shows how this __GFP_THISNODE was misplaced in
> > MADV_HUGEPAGE. MADV_HUGEPAGE has never been intended to provide any
> > zone_reclaim_mode semantics, in fact the two are orthogonal,
> > zone_reclaim_mode = 1|2|3 must work exactly the same with
> > MADV_HUGEPAGE set or not.
> > 
> > The performance characteristic of memory depends on the hardware
> > details. The numbers below are obtained on Naples/EPYC architecture
> > and the N/A projection extends them to show what we should aim for in
> > the future as a good THP NUMA locality default. The benchmark used
> > exercises random memory seeks (note: the cost of the page faults is
> > not part of the measurement).
> > 
> > D0 THP | D0 4k | D1 THP | D1 4k | D2 THP | D2 4k | D3 THP | D3 4k | ...
> > 0%     | +43%  | +45%   | +106% | +131%  | +224% | N/A    | N/A
> > 
> 
> The performance measurements that we have on Naples shows a more 
> significant change between D0 4k and D1 THP: it certainly is not 2% worse 
> access latency to a remote hugepage compared to local native pages.
> 

Please share the workload in question so there is at least some chance
of developing a series that allocates locally (regardless of page size)
as much as possible without incurring swap storms.

> > D0 means distance zero (i.e. local memory), D1 means distance
> > one (i.e. intra socket memory), D2 means distance two (i.e. inter
> > socket memory), etc...
> > 
> > For the guest physical memory allocated by qemu and for guest mode kernel
> > the performance characteristic of RAM is more complex and an ideal
> > default could be:
> > 
> > D0 THP | D1 THP | D0 4k | D2 THP | D1 4k | D3 THP | D2 4k | D3 4k | ...
> > 0%     | +58%   | +101% | N/A    | +222% | N/A    | N/A   | N/A
> > 
> > NOTE: the N/A are projections and haven't been measured yet, the
> > measurement in this case is done on a 1950x with only two NUMA nodes.
> > The THP case here means THP was used both in the host and in the
> > guest.
> > 
> 
> Yes, this is clearly understood and was never objected to when this first 
> came up in the thread where __GFP_THISNODE was removed or when Linus 
> reverted the patch.
> 
> The issue being discussed here is a result of MADV_HUGEPAGE being 
> overloaded: it cannot mean to control (1) how much compaction/reclaim is 
> done for page allocation, (2) the NUMA locality of those hugepages, and 
> (3) the eligibility of the memory to be collapsed into hugepages by 
> khugepaged all at the same time.
> 
> I suggested then that we actually define (2) concretely specifically for 
> the usecase that you mention.  Changing the behavior of MADV_HUGEPAGE for 
> the past three years, however, and introducing performance regressions for 
> those users is not an option regardless of the intent that it had when 
> developed.
> 

The current behaviour is potential swap storms that are difficult to
avoid because the behaviour is hard-wired into the kernel internals.
Only disabling THP, either on a task or global basis, avoids it when
encountered.

> I suggested two options: (1) __MPOL_F_HUGE flag to set a mempolicy for 
> specific memory ranges so that you can define thp specific mempolicies 
> (Vlastimil considered this to be a lot of work, which I agreed) or (2) a 
> prctl() mode to specify that a workload will span multiple sockets and 
> benefits from remote hugepage allocation over local native pages (or 
> because it is faulting memory remotely that it will access locally at some 
> point in the future depending on cpu binding).  Any prctl() mode can be 
> inherited across fork so it can be used for the qemu case that you suggest 
> and is a very simple change to make compared with (1).
> 

The prctl should be the other way around -- use prctl if THP trumps all
else even if that means reclaiming a large amount of memory or swapping.

> Please consider methods to accomplish this goal that will not cause 
> existing users of MADV_HUGEPAGE to incur 13.9% access latency regressions 
> and have no way to workaround without MPOL_BIND that will introduce 
> undeserved and unnecessary oom kills because we can't specify native page 
> vs hugepage mempolicies independently.
> 
> I'm confident that everybody on this cc list is well aware of both sides 
> of this discussion and I hope that we can work together to address it to 
> achieve the goals of both.
> 

Please start by sharing the workload in question. However, I'm still
willing to bet that a swap storm causes significantly more harm for more
users than a latency penalty for a workload that is extremely latency
sensitive. The latency of a swap out/in is far more than a 13.9% access
latency.

-- 
Mel Gorman
SUSE Labs

