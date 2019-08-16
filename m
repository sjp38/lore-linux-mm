Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0470C3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:41:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 993C42086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:41:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 993C42086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 213CD6B0007; Fri, 16 Aug 2019 11:41:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C41C6B0008; Fri, 16 Aug 2019 11:41:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DB6B6B000A; Fri, 16 Aug 2019 11:41:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0093.hostedemail.com [216.40.44.93])
	by kanga.kvack.org (Postfix) with ESMTP id DEE3F6B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:41:11 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 73BB0181AC9AE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:41:11 +0000 (UTC)
X-FDA: 75828704742.04.coat16_a59507cbdf14
X-HE-Tag: coat16_a59507cbdf14
X-Filterd-Recvd-Size: 3629
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:41:11 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5584DAD0F;
	Fri, 16 Aug 2019 15:41:09 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id B6F151E4009; Fri, 16 Aug 2019 17:41:08 +0200 (CEST)
Date: Fri, 16 Aug 2019 17:41:08 +0200
From: Jan Kara <jack@suse.cz>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
Message-ID: <20190816154108.GE3041@quack2.suse.cz>
References: <a1044a0d-059c-f347-bd68-38be8478bf20@nvidia.com>
 <90e5cd11-fb34-6913-351b-a5cc6e24d85d@nvidia.com>
 <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
 <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
 <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
 <20190815132622.GG14313@quack2.suse.cz>
 <20190815133510.GA21302@quack2.suse.cz>
 <20190815173237.GA30924@iweiny-DESK2.sc.intel.com>
 <b378a363-f523-518d-9864-e2f8e5bd0c34@nvidia.com>
 <58b75fa9-1272-b683-cb9f-722cc316bf8f@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58b75fa9-1272-b683-cb9f-722cc316bf8f@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 19:14:08, John Hubbard wrote:
> On 8/15/19 10:41 AM, John Hubbard wrote:
> > On 8/15/19 10:32 AM, Ira Weiny wrote:
> >> On Thu, Aug 15, 2019 at 03:35:10PM +0200, Jan Kara wrote:
> >>> On Thu 15-08-19 15:26:22, Jan Kara wrote:
> >>>> On Wed 14-08-19 20:01:07, John Hubbard wrote:
> >>>>> On 8/14/19 5:02 PM, John Hubbard wrote:
> ...
> >> Ok just to make this clear I threw up my current tree with your patches here:
> >>
> >> https://github.com/weiny2/linux-kernel/commits/mmotm-rdmafsdax-b0-v4
> >>
> >> I'm talking about dropping the final patch:
> >> 05fd2d3afa6b rdma/umem_odp: Use vaddr_pin_pages_remote() in ODP
> >>
> >> The other 2 can stay.  I split out the *_remote() call.  We don't have a user
> >> but I'll keep it around for a bit.
> >>
> >> This tree is still WIP as I work through all the comments.  So I've not changed
> >> names or variable types etc...  Just wanted to settle this.
> >>
> > 
> > Right. And now that ODP is not a user, I'll take a quick look through my other
> > call site conversions and see if I can find an easy one, to include here as
> > the first user of vaddr_pin_pages_remote(). I'll send it your way if that
> > works out.
> > 
> 
> OK, there was only process_vm_access.c, plus (sort of) Bharath's sgi-gru
> patch, maybe eventually [1].  But looking at process_vm_access.c, I think 
> it is one of the patches that is no longer applicable, and I can just
> drop it entirely...I'd welcome a second opinion on that...

I don't think you can drop the patch. process_vm_rw_pages() clearly touches
page contents and does not synchronize with page_mkclean(). So it is case
1) and needs FOLL_PIN semantics.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

