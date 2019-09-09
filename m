Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 150CAC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:23:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4ABF2086D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:23:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4ABF2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CA766B0005; Mon,  9 Sep 2019 07:23:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57AD16B0006; Mon,  9 Sep 2019 07:23:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 491C26B0007; Mon,  9 Sep 2019 07:23:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0079.hostedemail.com [216.40.44.79])
	by kanga.kvack.org (Postfix) with ESMTP id 27A506B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:23:57 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BD99E181AC9B4
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:23:56 +0000 (UTC)
X-FDA: 75915147672.05.sheep83_226555add3435
X-HE-Tag: sheep83_226555add3435
X-Filterd-Recvd-Size: 4583
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:23:56 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7D4BDACD8;
	Mon,  9 Sep 2019 11:23:53 +0000 (UTC)
Date: Mon, 9 Sep 2019 13:23:52 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: minchan@kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
Message-ID: <20190909112352.GI27159@dhcp22.suse.cz>
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
 <20190902132104.GJ14028@dhcp22.suse.cz>
 <79303914-d6a6-011a-150f-74488c8e12f2@codeaurora.org>
 <20190903114109.GR14028@dhcp22.suse.cz>
 <07f908cb-af0d-0688-ad8b-d709c7d5691d@codeaurora.org>
 <8963939c-9e1d-8188-ce68-13fb82d82763@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8963939c-9e1d-8188-ce68-13fb82d82763@codeaurora.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 09-09-19 09:35:39, Vinayak Menon wrote:
> 
> On 9/3/2019 5:47 PM, Vinayak Menon wrote:
> > On 9/3/2019 5:11 PM, Michal Hocko wrote:
> >> On Tue 03-09-19 11:43:16, Vinayak Menon wrote:
> >>> Hi Michal,
> >>>
> >>> Thanks for reviewing this.
> >>>
> >>>
> >>> On 9/2/2019 6:51 PM, Michal Hocko wrote:
> >>>> On Fri 30-08-19 18:13:31, Vinayak Menon wrote:
> >>>>> The following race is observed due to which a processes faulting
> >>>>> on a swap entry, finds the page neither in swapcache nor swap. This
> >>>>> causes zram to give a zero filled page that gets mapped to the
> >>>>> process, resulting in a user space crash later.
> >>>>>
> >>>>> Consider parent and child processes Pa and Pb sharing the same swap
> >>>>> slot with swap_count 2. Swap is on zram with SWP_SYNCHRONOUS_IO set.
> >>>>> Virtual address 'VA' of Pa and Pb points to the shared swap entry.
> >>>>>
> >>>>> Pa                                       Pb
> >>>>>
> >>>>> fault on VA                              fault on VA
> >>>>> do_swap_page                             do_swap_page
> >>>>> lookup_swap_cache fails                  lookup_swap_cache fails
> >>>>>                                          Pb scheduled out
> >>>>> swapin_readahead (deletes zram entry)
> >>>>> swap_free (makes swap_count 1)
> >>>>>                                          Pb scheduled in
> >>>>>                                          swap_readpage (swap_count == 1)
> >>>>>                                          Takes SWP_SYNCHRONOUS_IO path
> >>>>>                                          zram enrty absent
> >>>>>                                          zram gives a zero filled page
> >>>> This sounds like a zram issue, right? Why is a generic swap path changed
> >>>> then?
> >>> I think zram entry being deleted by Pa and zram giving out a zeroed page to Pb is normal.
> >> Isn't that a data loss? The race you mentioned shouldn't be possible
> >> with the standard swap storage AFAIU. If that is really the case then
> >> the zram needs a fix rather than a generic path. Or at least a very good
> >> explanation why the generic path is a preferred way.
> >
> > AFAIK, there isn't a data loss because, before deleting the entry, swap_slot_free_notify makes sure that
> >
> > page is in swapcache and marks the page dirty to ensure a swap out before reclaim. I am referring to the
> >
> > comment about this in swap_slot_free_notify. In the case of this race too, the page brought to swapcache
> >
> > by Pa is still in swapcache. It is just that Pb failed to find it due to the race.
> >
> > Yes, this race will not happen for standard swap storage and only for those block devices that set
> >
> > disk->fops->swap_slot_free_notify and have SWP_SYNCHRONOUS_IO set (which seems to be only zram).
> >
> > Now considering that zram works as expected, the fix is in generic path because the race is due to the bug in
> >
> > SWP_SYNCHRONOUS_IO handling in do_swap_page. And it is only the SWP_SYNCHRONOUS_IO handling in
> >
> > generic path which is modified.
> >
> 
> Hi Michal,
> 
> Do you see any concerns with the patch or explanation of the problem ?

I am sorry, I didn't have time to give this a more serious thought. You
need somebody more familiar with the code and time to look into it.
-- 
Michal Hocko
SUSE Labs

