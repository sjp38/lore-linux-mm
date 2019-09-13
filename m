Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 569CDC4CEC6
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 01:50:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C87D206A4
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 01:50:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C87D206A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE33F6B0007; Thu, 12 Sep 2019 21:50:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A93D46B0008; Thu, 12 Sep 2019 21:50:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A98C6B000A; Thu, 12 Sep 2019 21:50:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0086.hostedemail.com [216.40.44.86])
	by kanga.kvack.org (Postfix) with ESMTP id 87B106B0007
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 21:50:51 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3922E1F239
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 01:50:51 +0000 (UTC)
X-FDA: 75928218702.05.news96_419656bd4c43b
X-HE-Tag: news96_419656bd4c43b
X-Filterd-Recvd-Size: 3092
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au [211.29.132.246])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 01:50:50 +0000 (UTC)
Received: from dread.disaster.area (pa49-181-255-194.pa.nsw.optusnet.com.au [49.181.255.194])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id B6C1643ECC3;
	Fri, 13 Sep 2019 11:50:45 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92.2)
	(envelope-from <david@fromorbit.com>)
	id 1i8ajT-0000Fl-KL; Fri, 13 Sep 2019 11:50:43 +1000
Date: Fri, 13 Sep 2019 11:50:43 +1000
From: Dave Chinner <david@fromorbit.com>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
	Will Deacon <will.deacon@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 0/5] hugetlbfs: Disable PMD sharing for large systems
Message-ID: <20190913015043.GF27547@dread.disaster.area>
References: <20190911150537.19527-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190911150537.19527-1-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0
	a=YO9NNpcXwc8z/SaoS+iAiA==:117 a=YO9NNpcXwc8z/SaoS+iAiA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=J70Eh1EUuV4A:10
	a=7-415B0cAAAA:8 a=n3o9mYiGlt67Pqr9hHAA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 04:05:32PM +0100, Waiman Long wrote:
> A customer with large SMP systems (up to 16 sockets) with application
> that uses large amount of static hugepages (~500-1500GB) are experiencing
> random multisecond delays. These delays was caused by the long time it
> took to scan the VMA interval tree with mmap_sem held.
> 
> To fix this problem while perserving existing behavior as much as
> possible, we need to allow timeout in down_write() and disabling PMD
> sharing when it is taking too long to do so. Since a transaction can
> involving touching multiple huge pages, timing out for each of the huge
> page interactions does not completely solve the problem. So a threshold
> is set to completely disable PMD sharing if too many timeouts happen.
> 
> The first 4 patches of this 5-patch series adds a new
> down_write_timedlock() API which accepts a timeout argument and return
> true is locking is successful or false otherwise. It works more or less
> than a down_write_trylock() but the calling thread may sleep.

Just on general principle, this is a non-starter. If a lock is being
held too long, then whatever the lock is protecting needs fixing.
Adding timeouts to locks and sysctls to tune them is not a viable
solution to address latencies caused by algorithm scalability
issues.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

