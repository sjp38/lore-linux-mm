Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0077EC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FD7B22CF5
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FD7B22CF5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AFF56B000D; Thu, 29 Aug 2019 03:00:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 360E96B000E; Thu, 29 Aug 2019 03:00:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29E3C6B0010; Thu, 29 Aug 2019 03:00:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0185.hostedemail.com [216.40.44.185])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1826B000D
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:00:06 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 98310AF9F
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:05 +0000 (UTC)
X-FDA: 75874565970.17.queen44_bfa7e910a0e
X-HE-Tag: queen44_bfa7e910a0e
X-Filterd-Recvd-Size: 2073
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:04 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id D92A468C4E; Thu, 29 Aug 2019 08:59:59 +0200 (CEST)
Date: Thu, 29 Aug 2019 08:59:59 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Steven Price <steven.price@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Thomas Hellstrom <thellstrom@vmware.com>
Subject: Re: [PATCH 2/3] pagewalk: separate function pointers from iterator
 data
Message-ID: <20190829065959.GA11628@lst.de>
References: <20190828141955.22210-1-hch@lst.de> <20190828141955.22210-3-hch@lst.de> <20190828150514.GN914@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190828150514.GN914@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 03:05:19PM +0000, Jason Gunthorpe wrote:
> > @@ -1217,7 +1222,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
> >  						0, NULL, mm, 0, -1UL);
> >  			mmu_notifier_invalidate_range_start(&range);
> >  		}
> > -		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
> > +		walk_page_range(mm, 0, mm->highest_vm_end, &clear_refs_walk_ops,
> > +				&cp);
> 
> Is the difference between TASK_SIZE and 'highest_vm_end' deliberate,
> or should we add a 'walk_all_pages'() mini helper for this? I see most
> of the users are using one or the other variant.

I have no idea to be honest.  A walk_all_pages-like helper doesn't
seem like a bad idea, but the priority seems lower than cleaning up
all the callers using walk_page_range on a vma..

