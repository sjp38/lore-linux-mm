Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08BB3C3A5A2
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:26:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDFB8233FC
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:26:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDFB8233FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4980F6B0320; Thu, 22 Aug 2019 10:26:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4483F6B0321; Thu, 22 Aug 2019 10:26:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35E506B0322; Thu, 22 Aug 2019 10:26:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0093.hostedemail.com [216.40.44.93])
	by kanga.kvack.org (Postfix) with ESMTP id 154116B0320
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:26:45 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9B84A6D91
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:26:44 +0000 (UTC)
X-FDA: 75850289928.12.metal08_9f2fccb1c29
X-HE-Tag: metal08_9f2fccb1c29
X-Filterd-Recvd-Size: 4181
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:26:44 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 03D13AC47;
	Thu, 22 Aug 2019 14:26:42 +0000 (UTC)
Subject: Re: [PATCH 2/3] xfs: add kmem_alloc_io()
To: Dave Chinner <david@fromorbit.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
 Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org,
 Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 penguin-kernel@I-love.SAKURA.ne.jp
References: <20190821083820.11725-3-david@fromorbit.com>
 <20190821232440.GB24904@infradead.org>
 <20190822003131.GR1119@dread.disaster.area>
 <20190822075948.GA31346@infradead.org>
 <20190822085130.GI2349@hirez.programming.kicks-ass.net>
 <20190822091057.GK2386@hirez.programming.kicks-ass.net>
 <20190822101441.GY1119@dread.disaster.area>
 <ddcdc274-be61-6e40-5a14-a4faa954f090@suse.cz>
 <20190822120725.GA1119@dread.disaster.area>
 <ad8037c8-d1af-fb4f-1226-af585df492d3@suse.cz>
 <20190822131739.GB1119@dread.disaster.area>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <db4a1dae-d69a-0df4-4a71-02c2954ecd75@suse.cz>
Date: Thu, 22 Aug 2019 16:26:42 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190822131739.GB1119@dread.disaster.area>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/22/19 3:17 PM, Dave Chinner wrote:
> On Thu, Aug 22, 2019 at 02:19:04PM +0200, Vlastimil Babka wrote:
>> On 8/22/19 2:07 PM, Dave Chinner wrote:
>> > On Thu, Aug 22, 2019 at 01:14:30PM +0200, Vlastimil Babka wrote:
>> > 
>> > No, the problem is this (using kmalloc as a general term for
>> > allocation, whether it be kmalloc, kmem_cache_alloc, alloc_page, etc)
>> > 
>> >    some random kernel code
>> >     kmalloc(GFP_KERNEL)
>> >      reclaim
>> >      PF_MEMALLOC
>> >      shrink_slab
>> >       xfs_inode_shrink
>> >        XFS_ILOCK
>> >         xfs_buf_allocate_memory()
>> >          kmalloc(GFP_KERNEL)
>> > 
>> > And so locks on inodes in reclaim are seen below reclaim. Then
>> > somewhere else we have:
>> > 
>> >    some high level read-only xfs code like readdir
>> >     XFS_ILOCK
>> >      xfs_buf_allocate_memory()
>> >       kmalloc(GFP_KERNEL)
>> >        reclaim
>> > 
>> > And this one throws false positive lockdep warnings because we
>> > called into reclaim with XFS_ILOCK held and GFP_KERNEL alloc
>> 
>> OK, and what exactly makes this positive a false one? Why can't it continue like
>> the first example where reclaim leads to another XFS_ILOCK, thus deadlock?
> 
> Because above reclaim we only have operations being done on
> referenced inodes, and below reclaim we only have unreferenced
> inodes. We never lock the same inode both above and below reclaim
> at the same time.
> 
> IOWs, an operation above reclaim cannot see, access or lock
> unreferenced inodes, except in inode write clustering, and that uses
> trylocks so cannot deadlock with reclaim.
> 
> An operation below reclaim cannot see, access or lock referenced
> inodes except during inode write clustering, and that uses trylocks
> so cannot deadlock with code above reclaim.

Thanks for elaborating. Perhaps lockdep experts (not me) would know how to
express that. If not possible, then replacing GFP_NOFS with __GFP_NOLOCKDEP
should indeed suppress the warning, while allowing FS reclaim.

> FWIW, I'm trying to make the inode writeback clustering go away from
> reclaim at the moment, so even that possibility is going away soon.
> That will change everything to trylocks in reclaim context, so
> lockdep is going to stop tracking it entirely.

That's also a nice solution :)

> Hmmm - maybe we're getting to the point where we actually
> don't need GFP_NOFS/PF_MEMALLOC_NOFS at all in XFS anymore.....
> 
> Cheers,
> 
> Dave.
> 


