Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4257AC3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 12:21:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB0F9217F5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 12:21:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB0F9217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 490F06B0574; Mon, 26 Aug 2019 08:21:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 440A96B0575; Mon, 26 Aug 2019 08:21:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 357226B0576; Mon, 26 Aug 2019 08:21:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0027.hostedemail.com [216.40.44.27])
	by kanga.kvack.org (Postfix) with ESMTP id 142D36B0574
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 08:21:14 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B6EE6181AC9B4
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 12:21:13 +0000 (UTC)
X-FDA: 75864488826.15.cause21_aabfd5328726
X-HE-Tag: cause21_aabfd5328726
X-Filterd-Recvd-Size: 4166
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 12:21:13 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3982BAF03;
	Mon, 26 Aug 2019 12:21:11 +0000 (UTC)
Date: Mon, 26 Aug 2019 14:21:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	penguin-kernel@I-love.SAKURA.ne.jp
Subject: Re: [PATCH 2/3] xfs: add kmem_alloc_io()
Message-ID: <20190826122110.GB7659@dhcp22.suse.cz>
References: <20190822003131.GR1119@dread.disaster.area>
 <20190822075948.GA31346@infradead.org>
 <20190822085130.GI2349@hirez.programming.kicks-ass.net>
 <20190822091057.GK2386@hirez.programming.kicks-ass.net>
 <20190822101441.GY1119@dread.disaster.area>
 <ddcdc274-be61-6e40-5a14-a4faa954f090@suse.cz>
 <20190822120725.GA1119@dread.disaster.area>
 <ad8037c8-d1af-fb4f-1226-af585df492d3@suse.cz>
 <20190822131739.GB1119@dread.disaster.area>
 <db4a1dae-d69a-0df4-4a71-02c2954ecd75@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <db4a1dae-d69a-0df4-4a71-02c2954ecd75@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 22-08-19 16:26:42, Vlastimil Babka wrote:
> On 8/22/19 3:17 PM, Dave Chinner wrote:
> > On Thu, Aug 22, 2019 at 02:19:04PM +0200, Vlastimil Babka wrote:
> >> On 8/22/19 2:07 PM, Dave Chinner wrote:
> >> > On Thu, Aug 22, 2019 at 01:14:30PM +0200, Vlastimil Babka wrote:
> >> > 
> >> > No, the problem is this (using kmalloc as a general term for
> >> > allocation, whether it be kmalloc, kmem_cache_alloc, alloc_page, etc)
> >> > 
> >> >    some random kernel code
> >> >     kmalloc(GFP_KERNEL)
> >> >      reclaim
> >> >      PF_MEMALLOC
> >> >      shrink_slab
> >> >       xfs_inode_shrink
> >> >        XFS_ILOCK
> >> >         xfs_buf_allocate_memory()
> >> >          kmalloc(GFP_KERNEL)
> >> > 
> >> > And so locks on inodes in reclaim are seen below reclaim. Then
> >> > somewhere else we have:
> >> > 
> >> >    some high level read-only xfs code like readdir
> >> >     XFS_ILOCK
> >> >      xfs_buf_allocate_memory()
> >> >       kmalloc(GFP_KERNEL)
> >> >        reclaim
> >> > 
> >> > And this one throws false positive lockdep warnings because we
> >> > called into reclaim with XFS_ILOCK held and GFP_KERNEL alloc
> >> 
> >> OK, and what exactly makes this positive a false one? Why can't it continue like
> >> the first example where reclaim leads to another XFS_ILOCK, thus deadlock?
> > 
> > Because above reclaim we only have operations being done on
> > referenced inodes, and below reclaim we only have unreferenced
> > inodes. We never lock the same inode both above and below reclaim
> > at the same time.
> > 
> > IOWs, an operation above reclaim cannot see, access or lock
> > unreferenced inodes, except in inode write clustering, and that uses
> > trylocks so cannot deadlock with reclaim.
> > 
> > An operation below reclaim cannot see, access or lock referenced
> > inodes except during inode write clustering, and that uses trylocks
> > so cannot deadlock with code above reclaim.
> 
> Thanks for elaborating. Perhaps lockdep experts (not me) would know how to
> express that. If not possible, then replacing GFP_NOFS with __GFP_NOLOCKDEP
> should indeed suppress the warning, while allowing FS reclaim.

This was certainly my hope to happen when introducing __GFP_NOLOCKDEP.
I couldn't have done the second step because that requires a deep
understanding of the code in question which is beyond my capacity. It
seems we still haven't found a brave soul to start converting GFP_NOFS
to __GFP_NOLOCKDEP. And it would be really appreciated.

Thanks.
-- 
Michal Hocko
SUSE Labs

