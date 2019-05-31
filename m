Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC474C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 09:22:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD60E2654E
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 09:22:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD60E2654E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B0F86B0272; Fri, 31 May 2019 05:22:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 460E96B0274; Fri, 31 May 2019 05:22:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 350AA6B0276; Fri, 31 May 2019 05:22:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC20A6B0272
	for <linux-mm@kvack.org>; Fri, 31 May 2019 05:22:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r48so13052643eda.11
        for <linux-mm@kvack.org>; Fri, 31 May 2019 02:22:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AjUc2JjgHkJQyA4ngFyP96HTgVuQBQGRJBQ3Re4x6EQ=;
        b=LrFaJRRjg70M/dD3v8PHCf3aUYZonpI1JUoPld3A4z8gbg4IQmtGtsSNQKiqkGVmC/
         kPcQbOoR0szFlLYM0FpNMj++ME3xXFNj7fbUdQjPFqgmtsOPzxHi6FW6ye95ZvNfa5VD
         rEvKFNuMTxNrvNqUJz7wdGNDgMJef08Rn6fWRpX/t52FA9pT6owREITW6iDHjVl8OJYJ
         6hTFgwN9QXBLHLuzNWFnloNjCNhV9A36AvMlR4Cieg+1W2KUdi0ZZdOfQcSEksnJyXoe
         22z4YVGSJrOtmXkBqGI9lRm6XB9i28OzkQYlu++RVxTwv6Qasf8+zRNqf0eNOAH00sJt
         Ha/Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXmK2x4GZtDtgey6vQ745x8NLjaWJEHN+frM1M1cj5JcqK2i1uZ
	QRq7tOwqthUSnpJzPOe+oH0SMuBO3sLgUuitfm4VXmEUbR82rgqNYZsJAA/gcpK4lODOQpOArX1
	JTrRH9qI/MspEuzc2B2HKUnLm5/E/aDooXrDwxvLF0v+CefiC5xb+xQwFzmqZp90=
X-Received: by 2002:a50:bae4:: with SMTP id x91mr10166120ede.76.1559294559352;
        Fri, 31 May 2019 02:22:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrenWBHRZ76kYmWHyMjHdSjqJIUo44c185HBX+Hd9rvvmzM4WYqmLmZzCS2ZLHfIDYMClq
X-Received: by 2002:a50:bae4:: with SMTP id x91mr10166025ede.76.1559294558157;
        Fri, 31 May 2019 02:22:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559294558; cv=none;
        d=google.com; s=arc-20160816;
        b=j5QCDeN9aOaZwxi3+EYTfwlhBMaLCaqBFe4YAOkdnqKyCG7NI3KzLi98nhitnPy7Df
         bKY2u8z1leYY2s0m++yDPv1qqIwKmySlK762oOv/UGjUuqfT+BIpxMewUUv6R7b1ZARx
         wfJcbfqnYq7QZoueq8xpMWFhB4u0SCVRUb96kSDmZbUDYbNnRyi3Xk4bHKJqRt2bOVm4
         ZodbdRH5my9fc8dOlDWQapTKR6mUkpXBD8CMdZWV0d9317aPHMsF9LES3M6hSIOSxOQf
         FajyjlcWuCsM3LBKKDidBs+0jMHunmctOpTDXa8rJG8kLAl2Lt8aI6sjnR9MkPrM1rSm
         WWuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AjUc2JjgHkJQyA4ngFyP96HTgVuQBQGRJBQ3Re4x6EQ=;
        b=s45LYrhXAqTp0fTk/5XAVS87NUCuMS8x2flPd/z4o3Lr8A6/oQuHgQFwBBozUj9tZ3
         RmBWfAR1Ae6uJvHB9oG+rHFez0rwsCnLbN0moq/su4aJi1vTwB/YUJ/o/YJrkMlGXcfl
         yubaMwye3t2cSEccwVU6xuKvOyCXdduKVsebZnw4i5JeyqlRGhQ+/Eo1pPoSHaLLduSm
         rBzDmLetvgD5yzYWvaFwlTnxP3M6nOGYB0oOIYh7PMaRx+OkO/gSx3R5V6XbWeU3+zJZ
         +hs+K5XLX1UV7/Q72SkgBWzuRY8rmCB+gQ05uNUJgtysWPpfXorn45nwI9eO1a3VXGCv
         OXHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a10si577273ejr.87.2019.05.31.02.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 02:22:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 23EC6AFD2;
	Fri, 31 May 2019 09:22:37 +0000 (UTC)
Date: Fri, 31 May 2019 11:22:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
Message-ID: <20190531092236.GM6896@dhcp22.suse.cz>
References: <20190503223146.2312-1-aarcange@redhat.com>
 <20190503223146.2312-3-aarcange@redhat.com>
 <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
 <20190520153621.GL18914@techsingularity.net>
 <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
 <alpine.DEB.2.21.1905281907060.86034@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1905281907060.86034@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 29-05-19 14:24:33, David Rientjes wrote:
> On Thu, 23 May 2019, Andrew Morton wrote:
> 
> > > We are going in circles, *yes* there is a problem for potential swap 
> > > storms today because of the poor interaction between memory compaction and 
> > > directed reclaim but this is a result of a poor API that does not allow 
> > > userspace to specify that its workload really will span multiple sockets 
> > > so faulting remotely is the best course of action.  The fix is not to 
> > > cause regressions for others who have implemented a userspace stack that 
> > > is based on the past 3+ years of long standing behavior or for specialized 
> > > workloads where it is known that it spans multiple sockets so we want some 
> > > kind of different behavior.  We need to provide a clear and stable API to 
> > > define these terms for the page allocator that is independent of any 
> > > global setting of thp enabled, defrag, zone_reclaim_mode, etc.  It's 
> > > workload dependent.
> > 
> > um, who is going to do this work?
> > 
> > Implementing a new API doesn't help existing userspace which is hurting
> > from the problem which this patch addresses.
> > 
> 
> The problem which this patch addresses has apparently gone unreported for 
> 4+ years since

Can we finaly stop considering the time and focus on the what is the
most reasonable behavior in general case please? Conserving mistakes
based on an argument that we have them for many years is just not
productive. It is very well possible that workloads that suffer from
this simply run on older distribution kernels which are moving towards
newer kernels very slowly.

> commit 077fcf116c8c2bd7ee9487b645aa3b50368db7e1
> Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Date:   Wed Feb 11 15:27:12 2015 -0800
> 
>     mm/thp: allocate transparent hugepages on local node

Let me quote the commit message to the full lenght
"
    This make sure that we try to allocate hugepages from local node if
    allowed by mempolicy.  If we can't, we fallback to small page allocation
    based on mempolicy.  This is based on the observation that allocating
    pages on local node is more beneficial than allocating hugepages on remote
    node.

    With this patch applied we may find transparent huge page allocation
    failures if the current node doesn't have enough freee hugepages.  Before
    this patch such failures result in us retrying the allocation on other
    nodes in the numa node mask.
"

I do not see any single numbers backing those claims or any mention of a
workload that would benefit from the change. Besides that, we have seen
that THP on a remote (but close) node might be performing better per
Andrea's numbers. So those claims do not apply in general.

This is a general problem when making decisions on heuristics which are
not a clear cut. AFAICS there have been pretty good argments given that
_real_ workloads suffer from this change while a demonstration of a _real_
workload that is benefiting is still missing.

> My goal is to reach a solution that does not cause anybody to incur 
> performance penalties as a result of it.

That is certainly appreciated and I can offer my help there as well. But
I believe we should start with a code base that cannot generate a
swapping storm by a trivial code as demonstrated by Mel. A general idea
on how to approve the situation has been already outlined for a default
case and a new memory policy has been mentioned as well but we need
something to start with and neither of the two is compatible with the
__GFP_THISNODE behavior.

[...]

> The easiest solution would be to define the MADV_HUGEPAGE behavior 
> explicitly in sysfs: local or remote.  Defaut to local as the behavior 
> from the past four years and allow users to specify remote if their 
> workloads will span multiple sockets.  This is somewhat coarse but no more 
> than the thp defrag setting in sysfs today that defines defrag behavior 
> for everybody on the system.

This just makes the THP tunning even muddier. Really, can we start with
a code that doesn't blow up trivially and build on top? In other words
start with a less specialized usecase being covered and help more
specialized usecases to get what they need.

-- 
Michal Hocko
SUSE Labs

