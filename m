Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D663C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 22:24:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 671D7217F5
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 22:24:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 671D7217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA8F96B0006; Wed, 28 Aug 2019 18:24:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E589C6B0008; Wed, 28 Aug 2019 18:24:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6E586B000D; Wed, 28 Aug 2019 18:24:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0114.hostedemail.com [216.40.44.114])
	by kanga.kvack.org (Postfix) with ESMTP id B4DDB6B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 18:24:30 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 5A654AC0D
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 22:24:30 +0000 (UTC)
X-FDA: 75873266700.09.maid06_a2a37ae0805c
X-HE-Tag: maid06_a2a37ae0805c
X-Filterd-Recvd-Size: 3547
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au [211.29.132.249])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 22:24:29 +0000 (UTC)
Received: from dread.disaster.area (pa49-181-255-194.pa.nsw.optusnet.com.au [49.181.255.194])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 0CD40361493;
	Thu, 29 Aug 2019 08:24:24 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1i36MY-0004x3-2B; Thu, 29 Aug 2019 08:24:22 +1000
Date: Thu, 29 Aug 2019 08:24:22 +1000
From: Dave Chinner <david@fromorbit.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Ming Lei <ming.lei@redhat.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-btrfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] mm, sl[aou]b: guarantee natural alignment for
 kmalloc(power-of-two)
Message-ID: <20190828222422.GL1119@dread.disaster.area>
References: <20190826111627.7505-1-vbabka@suse.cz>
 <20190826111627.7505-3-vbabka@suse.cz>
 <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com>
 <20190828194607.GB6590@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190828194607.GB6590@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0
	a=YO9NNpcXwc8z/SaoS+iAiA==:117 a=YO9NNpcXwc8z/SaoS+iAiA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=wUb5uO5YJnghlZLzW24A:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 12:46:08PM -0700, Matthew Wilcox wrote:
> On Wed, Aug 28, 2019 at 06:45:07PM +0000, Christopher Lameter wrote:
> > I still think implicit exceptions to alignments are a bad idea. Those need
> > to be explicity specified and that is possible using kmem_cache_create().
> 
> I swear we covered this last time the topic came up, but XFS would need
> to create special slab caches for each size between 512 and PAGE_SIZE.
> Potentially larger, depending on whether the MM developers are willing to
> guarantee that kmalloc(PAGE_SIZE * 2, GFP_KERNEL) will return a PAGE_SIZE
> aligned block of memory indefinitely.

Page size alignment of multi-page heap allocations is ncessary. The
current behaviour w/ KASAN is to offset so a 8KB allocation spans 3
pages and is not page aligned. That causes just as much in way
of alignment problems as unaligned objects in multi-object-per-page
slabs.

As I said in the lastest discussion of this problem on XFS (pmem
devices w/ KASAN enabled), all we -need- is a GFP flag that tells the
slab allocator to give us naturally aligned object or fail if it
can't. I don't care how that gets implemented (e.g. another set of
heap slabs like the -rcl slabs), I just don't want every high level
subsystem that allocates heap memory for IO buffers to have to
implement their own aligned slab caches.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

