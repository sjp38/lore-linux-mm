Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DE58C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 13:21:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3CDA21670
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 13:21:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3CDA21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24EEF6B0006; Fri, 30 Aug 2019 09:21:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FF4C6B0008; Fri, 30 Aug 2019 09:21:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 116826B000A; Fri, 30 Aug 2019 09:21:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id E699F6B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:21:55 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 92A9619B37
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 13:21:55 +0000 (UTC)
X-FDA: 75879156990.19.moon43_2dde3f8075b2e
X-HE-Tag: moon43_2dde3f8075b2e
X-Filterd-Recvd-Size: 4124
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 13:21:55 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 87AC4B653;
	Fri, 30 Aug 2019 13:21:53 +0000 (UTC)
Date: Fri, 30 Aug 2019 15:21:50 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	"mike.kravetz@oracle.com" <mike.kravetz@oracle.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"vbabka@suse.cz" <vbabka@suse.cz>
Subject: Re: poisoned pages do not play well in the buddy allocator
Message-ID: <20190830132146.GA31465@linux>
References: <20190826104144.GA7849@linux>
 <20190827013429.GA5125@hori.linux.bs1.fc.nec.co.jp>
 <20190827072808.GA17746@linux>
 <20190830104530.GA29647@linux>
 <20190830123656.GG28313@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190830123656.GG28313@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 30, 2019 at 02:36:56PM +0200, Michal Hocko wrote:
> > - Free page: remove it from the buddy allocator and set it as PageReserved|PageHWPoison.
> > - Used page: migrate it and do not release it (skip put_page in unmap_and_move for MR_MEMORY_FAILURE
> > 	     reason). Set it as PageReserved|PageHWPoison.
> 
> But this will only cover mapped pages. What about page cache in general?
> Any reason why this cannot be handled in __free_one_page and simply skip
> the whole freeing of the HWPoisoned parts of the freed page (in case of
> higher order).

I forgot to mention that part.
pages that are in the page cache and are not mapped are being handled in
invalidate_inode_page:


	/*
         * Try to invalidate first. This should work for
         * non dirty unmapped page cache pages.
         */
        ret = invalidate_inode_page(page);

Once done, we free the page to the buddy (which is wrong).

My approach would be as we do when migrate a poisoned page, simply not release
the page, so it does not end up in the buddy and we have full control of it.

I am still playing with the way to go here in general, to see which approach
is better and more simple.
The implementation I have right works well, but it is true that we could explore
a way to

1) Set PageHWPoison bit on the page
1) Hook into the free routine and ignore any poisoned page

so the overall code could be easier.

I just want to see both codes in place and decide which one feels better.

> > The routine that handles this also sets the refcount of these pages to 1, so the unpoison
> > machinery will only have to check for PageHWPoison and to a put_page() to send
> > the page to the buddy allocator.
> > 
> > The Reserved bit is used because these pages will now __only__ be accessible through
> > pfn walkers, and pfn walkers should respect Reserved pages.
> > The PageHWPoison bit is used to remember that this page is poisoned, so the unpoison
> > machinery knows that it is valid to unpoison it.
> 
> Do we really need both bits? pfn walkers in general shouldn't handle
> pages they do not know about.

Well, I went for setting the Reserved bit to just be overprotective here,
like a way of "stay away from this page", and most of the pfn walkers
skip over Reserved pages as these are not meant to be touched for anyone
but the owner.
Setting the Poison bit is just for the unpoison routine, to check that
the page we are asked to unpoison, was really poisoned in the first place.

So, if that goes as planned, PageHWPoison check should only be neded in the
hwpoison code.
Maybe in the free routine if we decide to hook into that.

All in all, it is something that we will have to discuss at the time I will
send the RFC, as I am pretty sure there will be things to polish and change.

-- 
Oscar Salvador
SUSE L3

