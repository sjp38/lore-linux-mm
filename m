Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC33FC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:18:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA02123AA7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:18:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA02123AA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DF9C6B0007; Tue, 20 Aug 2019 04:18:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 590ED6B0008; Tue, 20 Aug 2019 04:18:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CCB66B000D; Tue, 20 Aug 2019 04:18:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0239.hostedemail.com [216.40.44.239])
	by kanga.kvack.org (Postfix) with ESMTP id 29F006B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:18:24 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C7A592C9D
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:18:23 +0000 (UTC)
X-FDA: 75842104086.19.tiger30_f0bc94a96541
X-HE-Tag: tiger30_f0bc94a96541
X-Filterd-Recvd-Size: 3230
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:18:23 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 956A7AEA1;
	Tue, 20 Aug 2019 08:18:21 +0000 (UTC)
Date: Tue, 20 Aug 2019 10:18:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Bharath Vedartham <linux.bhar@gmail.com>,
	Dimitri Sivanich <sivanich@hpe.com>,
	Andrew Morton <akpm@linux-foundation.org>, jglisse@redhat.com,
	ira.weiny@intel.com, gregkh@linuxfoundation.org, arnd@arndb.de,
	william.kucharski@oracle.com, hch@lst.de,
	inux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	linux-kernel@vger.kernel.org
Subject: Re: [Linux-kernel-mentees][PATCH v6 1/2] sgi-gru: Convert put_page()
 to put_user_page*()
Message-ID: <20190820081820.GI3111@dhcp22.suse.cz>
References: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
 <1566157135-9423-2-git-send-email-linux.bhar@gmail.com>
 <20190819125611.GA5808@hpe.com>
 <20190819190647.GA6261@bharath12345-Inspiron-5559>
 <0c2ad29b-934c-ec30-66c3-b153baf1fba5@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c2ad29b-934c-ec30-66c3-b153baf1fba5@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 19-08-19 12:30:18, John Hubbard wrote:
> On 8/19/19 12:06 PM, Bharath Vedartham wrote:
> > On Mon, Aug 19, 2019 at 07:56:11AM -0500, Dimitri Sivanich wrote:
> > > Reviewed-by: Dimitri Sivanich <sivanich@hpe.com>
> > Thanks!
> > 
> > John, would you like to take this patch into your miscellaneous
> > conversions patch set?
> > 
> 
> (+Andrew and Michal, so they know where all this is going.)
> 
> Sure, although that conversion series [1] is on a brief hold, because
> there are additional conversions desired, and the API is still under
> discussion. Also, reading between the lines of Michal's response [2]
> about it, I think people would prefer that the next revision include
> the following, for each conversion site:
> 
> Conversion of gup/put_page sites:
> 
> Before:
> 
> 	get_user_pages(...);
> 	...
> 	for each page:
> 		put_page();
> 
> After:
> 	
> 	gup_flags |= FOLL_PIN; (maybe FOLL_LONGTERM in some cases)
> 	vaddr_pin_user_pages(...gup_flags...)

I was hoping that FOLL_PIN would be handled by vaddr_pin_user_pages.

> 	...
> 	vaddr_unpin_user_pages(); /* which invokes put_user_page() */
> 
> Fortunately, it's not harmful for the simpler conversion from put_page()
> to put_user_page() to happen first, and in fact those have usually led
> to simplifications, paving the way to make it easier to call
> vaddr_unpin_user_pages(), once it's ready. (And showing exactly what
> to convert, too.)

If that makes the later conversion easier then no real objections from
me. Assuming that the current put_user_page conversions are correct of
course (I have the mlock one and potentials that falls into the same
category in mind).
-- 
Michal Hocko
SUSE Labs

