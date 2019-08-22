Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0BE5C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 12:19:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E49B20870
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 12:19:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E49B20870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 100136B030D; Thu, 22 Aug 2019 08:19:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B13A6B030E; Thu, 22 Aug 2019 08:19:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F07F66B030F; Thu, 22 Aug 2019 08:19:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0182.hostedemail.com [216.40.44.182])
	by kanga.kvack.org (Postfix) with ESMTP id CA2E96B030D
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:19:08 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 600078248AA7
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 12:19:08 +0000 (UTC)
X-FDA: 75849968376.08.brain26_32a703e74eb39
X-HE-Tag: brain26_32a703e74eb39
X-Filterd-Recvd-Size: 3131
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 12:19:07 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 39D9CAFBE;
	Thu, 22 Aug 2019 12:19:05 +0000 (UTC)
Subject: Re: [PATCH 2/3] xfs: add kmem_alloc_io()
To: Dave Chinner <david@fromorbit.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
 Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org,
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
 <ddcdc274-be61-6e40-5a14-a4faa954f090@suse.cz>
 <20190822120725.GA1119@dread.disaster.area>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ad8037c8-d1af-fb4f-1226-af585df492d3@suse.cz>
Date: Thu, 22 Aug 2019 14:19:04 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190822120725.GA1119@dread.disaster.area>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/22/19 2:07 PM, Dave Chinner wrote:
> On Thu, Aug 22, 2019 at 01:14:30PM +0200, Vlastimil Babka wrote:
> 
> No, the problem is this (using kmalloc as a general term for
> allocation, whether it be kmalloc, kmem_cache_alloc, alloc_page, etc)
> 
>    some random kernel code
>     kmalloc(GFP_KERNEL)
>      reclaim
>      PF_MEMALLOC
>      shrink_slab
>       xfs_inode_shrink
>        XFS_ILOCK
>         xfs_buf_allocate_memory()
>          kmalloc(GFP_KERNEL)
> 
> And so locks on inodes in reclaim are seen below reclaim. Then
> somewhere else we have:
> 
>    some high level read-only xfs code like readdir
>     XFS_ILOCK
>      xfs_buf_allocate_memory()
>       kmalloc(GFP_KERNEL)
>        reclaim
> 
> And this one throws false positive lockdep warnings because we
> called into reclaim with XFS_ILOCK held and GFP_KERNEL alloc

OK, and what exactly makes this positive a false one? Why can't it continue like
the first example where reclaim leads to another XFS_ILOCK, thus deadlock?

> context. So the only solution we had at the tiem to shut it up was:
> 
>    some high level read-only xfs code like readdir
>     XFS_ILOCK
>      xfs_buf_allocate_memory()
>       kmalloc(GFP_NOFS)
> 
> So that lockdep sees it's not going to recurse into reclaim and
> doesn't throw a warning...

AFAICS that GFP_NOFS would fix not only a warning but also a real deadlock
(depending on the answer to my previous question).

> Cheers,
> 
> Dave.
> 


