Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F26F6C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:14:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF05A2086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:14:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF05A2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 507D66B0003; Fri, 16 Aug 2019 12:14:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 490C06B0005; Fri, 16 Aug 2019 12:14:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37EEA6B0008; Fri, 16 Aug 2019 12:14:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0090.hostedemail.com [216.40.44.90])
	by kanga.kvack.org (Postfix) with ESMTP id 101236B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:14:24 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A098F8248AD5
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:14:23 +0000 (UTC)
X-FDA: 75828788406.10.meal37_9325d5a47310
X-HE-Tag: meal37_9325d5a47310
X-Filterd-Recvd-Size: 4696
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:14:23 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BDA24ABF6;
	Fri, 16 Aug 2019 16:14:21 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id F03601E4009; Fri, 16 Aug 2019 18:13:55 +0200 (CEST)
Date: Fri, 16 Aug 2019 18:13:55 +0200
From: Jan Kara <jack@suse.cz>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
Message-ID: <20190816161355.GL3041@quack2.suse.cz>
References: <a1044a0d-059c-f347-bd68-38be8478bf20@nvidia.com>
 <90e5cd11-fb34-6913-351b-a5cc6e24d85d@nvidia.com>
 <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
 <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
 <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
 <20190815132622.GG14313@quack2.suse.cz>
 <20190815133510.GA21302@quack2.suse.cz>
 <0d6797d8-1e04-1ebe-80a7-3d6895fe71b0@suse.cz>
 <20190816154404.GF3041@quack2.suse.cz>
 <20190816155220.GC3149@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816155220.GC3149@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 16-08-19 11:52:20, Jerome Glisse wrote:
> On Fri, Aug 16, 2019 at 05:44:04PM +0200, Jan Kara wrote:
> > On Fri 16-08-19 10:47:21, Vlastimil Babka wrote:
> > > On 8/15/19 3:35 PM, Jan Kara wrote:
> > > >> 
> > > >> So when the GUP user uses MMU notifiers to stop writing to pages whenever
> > > >> they are writeprotected with page_mkclean(), they don't really need page
> > > >> pin - their access is then fully equivalent to any other mmap userspace
> > > >> access and filesystem knows how to deal with those. I forgot out this case
> > > >> when I wrote the above sentence.
> > > >> 
> > > >> So to sum up there are three cases:
> > > >> 1) DIO case - GUP references to pages serving as DIO buffers are needed for
> > > >>    relatively short time, no special synchronization with page_mkclean() or
> > > >>    munmap() => needs FOLL_PIN
> > > >> 2) RDMA case - GUP references to pages serving as DMA buffers needed for a
> > > >>    long time, no special synchronization with page_mkclean() or munmap()
> > > >>    => needs FOLL_PIN | FOLL_LONGTERM
> > > >>    This case has also a special case when the pages are actually DAX. Then
> > > >>    the caller additionally needs file lease and additional file_pin
> > > >>    structure is used for tracking this usage.
> > > >> 3) ODP case - GUP references to pages serving as DMA buffers, MMU notifiers
> > > >>    used to synchronize with page_mkclean() and munmap() => normal page
> > > >>    references are fine.
> > > 
> > > IMHO the munlock lesson told us about another one, that's in the end equivalent
> > > to 3)
> > > 
> > > 4) pinning for struct page manipulation only => normal page references
> > > are fine
> > 
> > Right, it's good to have this for clarity.
> > 
> > > > I want to add that I'd like to convert users in cases 1) and 2) from using
> > > > GUP to using differently named function. Users in case 3) can stay as they
> > > > are for now although ultimately I'd like to denote such use cases in a
> > > > special way as well...
> > > 
> > > So after 1/2/3 is renamed/specially denoted, only 4) keeps the current
> > > interface?
> > 
> > Well, munlock() code doesn't even use GUP, just follow_page(). I'd wait to
> > see what's left after handling cases 1), 2), and 3) to decide about the
> > interface for the remainder.
> > 
> 
> For 3 we do not need to take a reference at all :) So just forget about 3
> it does not exist. For 3 the reference is the reference the CPU page table
> has on the page and that's it. GUP is no longer involve in ODP or anything
> like that.

Yes, I understand. But the fact is that GUP calls are currently still there
e.g. in ODP code. If you can make the code work without taking a page
reference at all, I'm only happy :)

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

