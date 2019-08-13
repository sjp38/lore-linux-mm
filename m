Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE3B3C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:09:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80C75206C2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:09:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80C75206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3149E6B0008; Tue, 13 Aug 2019 17:09:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29E376B0010; Tue, 13 Aug 2019 17:09:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 191E86B02AF; Tue, 13 Aug 2019 17:09:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id E440C6B0008
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:09:01 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 884AE181AC9B4
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:09:01 +0000 (UTC)
X-FDA: 75818644482.16.step94_4eb5a2aa2b739
X-HE-Tag: step94_4eb5a2aa2b739
X-Filterd-Recvd-Size: 5111
Received: from mga06.intel.com (mga06.intel.com [134.134.136.31])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:09:00 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 14:08:58 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="167177095"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga007.jf.intel.com with ESMTP; 13 Aug 2019 14:08:57 -0700
Date: Tue, 13 Aug 2019 14:08:57 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
Message-ID: <20190813210857.GB12695@iweiny-DESK2.sc.intel.com>
References: <20190812015044.26176-1-jhubbard@nvidia.com>
 <20190812015044.26176-3-jhubbard@nvidia.com>
 <20190812234950.GA6455@iweiny-DESK2.sc.intel.com>
 <38d2ff2f-4a69-e8bd-8f7c-41f1dbd80fae@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <38d2ff2f-4a69-e8bd-8f7c-41f1dbd80fae@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 05:07:32PM -0700, John Hubbard wrote:
> On 8/12/19 4:49 PM, Ira Weiny wrote:
> > On Sun, Aug 11, 2019 at 06:50:44PM -0700, john.hubbard@gmail.com wrote:
> > > From: John Hubbard <jhubbard@nvidia.com>
> ...
> > > diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
> > > index 53085896d718..fdff034a8a30 100644
> > > --- a/drivers/infiniband/core/umem_odp.c
> > > +++ b/drivers/infiniband/core/umem_odp.c
> > > @@ -534,7 +534,7 @@ static int ib_umem_odp_map_dma_single_page(
> > >   	}
> > >   out:
> > > -	put_user_page(page);
> > > +	vaddr_unpin_pages(&page, 1, &umem_odp->umem.vaddr_pin);
> > >   	if (remove_existing_mapping) {
> > >   		ib_umem_notifier_start_account(umem_odp);
> > > @@ -635,9 +635,10 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
> > >   		 * complex (and doesn't gain us much performance in most use
> > >   		 * cases).
> > >   		 */
> > > -		npages = get_user_pages_remote(owning_process, owning_mm,
> > > +		npages = vaddr_pin_pages_remote(owning_process, owning_mm,
> > >   				user_virt, gup_num_pages,
> > > -				flags, local_page_list, NULL, NULL);
> > > +				flags, local_page_list, NULL, NULL,
> > > +				&umem_odp->umem.vaddr_pin);
> > 
> > Thinking about this part of the patch... is this pin really necessary?  This
> > code is not doing a long term pin.  The page just needs a reference while we
> > map it into the devices page tables.  Once that is done we should get notifiers
> > if anything changes and we can adjust.  right?
> > 
> 
> OK, now it's a little interesting: the FOLL_PIN is necessary, but maybe not
> FOLL_LONGTERM. Illustrating once again that it's actually necessary to allow
> these flags to vary independently.

Why is PIN necessary?  I think we do want all drivers to use the new
user_uaddr_vaddr_pin_user_pages() call...  :-P  But in this case I think a
simple "get" reference is enough to reference the page while we are using it.
If it changes after the "put/unpin" we get a fault which should handle the
change right?

The other issue I have with FOLL_PIN is what does it mean to call "...pin...()"
without FOLL_PIN?

This is another confusion of get_user_pages()...  you can actually call it
without FOLL_GET...  :-/  And you just don't get pages back.  I've never really
dug into how (or if) you "put" them later...

> 
> And that leads to another API refinement idea: let's set FOLL_PIN within the
> vaddr_pin_pages*() wrappers, and set FOLL_LONGTER in the *callers* of those
> wrappers, yes?

I've thought about this before and I think any default flags should simply
define what we want follow_pages to do.

Also, the addition of vaddr_pin information creates an implicit flag which if
not there disallows any file pages from being pinned.  It becomes our new
"longterm" flag.  FOLL_PIN _could_ be what we should use "internally".  But we
could also just use this implicit vaddr_pin flag and not add a new flag.

Finally, I struggle with converting everyone to a new call.  It is more
overhead to use vaddr_pin in the call above because now the GUP code is going
to associate a file pin object with that file when in ODP we don't need that
because the pages can move around.

This overhead may be fine, not sure in this case, but I don't see everyone
wanting it.

Ira


