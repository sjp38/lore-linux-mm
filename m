Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB28CC3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 11:14:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89DC023401
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 11:14:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89DC023401
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54EAE6B0307; Thu, 22 Aug 2019 07:14:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 501426B0308; Thu, 22 Aug 2019 07:14:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EEDC6B0309; Thu, 22 Aug 2019 07:14:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id 206876B0307
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:14:34 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BB357181AC9BA
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:14:33 +0000 (UTC)
X-FDA: 75849805626.26.front39_44decb160e601
X-HE-Tag: front39_44decb160e601
X-Filterd-Recvd-Size: 3619
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:14:33 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7E2A6AF11;
	Thu, 22 Aug 2019 11:14:31 +0000 (UTC)
Subject: Re: [PATCH 2/3] xfs: add kmem_alloc_io()
To: Dave Chinner <david@fromorbit.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org,
 Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 penguin-kernel@I-love.SAKURA.ne.jp
References: <20190821083820.11725-1-david@fromorbit.com>
 <20190821083820.11725-3-david@fromorbit.com>
 <20190821232440.GB24904@infradead.org>
 <20190822003131.GR1119@dread.disaster.area>
 <20190822075948.GA31346@infradead.org>
 <20190822085130.GI2349@hirez.programming.kicks-ass.net>
 <20190822091057.GK2386@hirez.programming.kicks-ass.net>
 <20190822101441.GY1119@dread.disaster.area>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ddcdc274-be61-6e40-5a14-a4faa954f090@suse.cz>
Date: Thu, 22 Aug 2019 13:14:30 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190822101441.GY1119@dread.disaster.area>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/22/19 12:14 PM, Dave Chinner wrote:
> On Thu, Aug 22, 2019 at 11:10:57AM +0200, Peter Zijlstra wrote:
>> 
>> Ah, current_gfp_context() already seems to transfer PF_MEMALLOC_NOFS
>> into the GFP flags.
>> 
>> So are we sure it is broken and needs mending?
> 
> Well, that's what we are trying to work out. The problem is that we
> have code that takes locks and does allocations that is called both
> above and below the reclaim "lock" context. Once it's been seen
> below the reclaim lock context, calling it with GFP_KERNEL context
> above the reclaim lock context throws a deadlock warning.
> 
> The only way around that was to mark these allocation sites as
> GFP_NOFS so lockdep is never allowed to see that recursion through
> reclaim occur. Even though it isn't a deadlock vector.
> 
> What we're looking at is whether PF_MEMALLOC_NOFS changes this - I
> don't think it does solve this problem. i.e. if we define the
> allocation as GFP_KERNEL and then use PF_MEMALLOC_NOFS where reclaim
> is not allowed, we still have GFP_KERNEL allocations in code above
> reclaim that has also been seen below relcaim. And so we'll get
> false positive warnings again.

If I understand both you and the code directly, the code sites won't call
__fs_reclaim_acquire when called with current->flags including PF_MEMALLOC_NOFS.
So that would mean they "won't be seen below the reclaim" and all would be fine,
right?

> What I think we are going to have to do here is manually audit
> each of the KM_NOFS call sites as we remove the NOFS from them and
> determine if ___GFP_NOLOCKDEP is needed to stop lockdep from trying
> to track these allocation sites. We've never used this tag because
> we'd already fixed most of these false positives with explicit
> GFP_NOFS tags long before ___GFP_NOLOCKDEP was created.
> 
> But until someone starts doing the work, I don't know if it will
> work or even whether conversion PF_MEMALLOC_NOFS is going to
> introduce a bunch of new ways to get false positives from lockdep...
> 
> Cheers,
> 
> Dave.
> 


