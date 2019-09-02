Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47751C3A59E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 13:21:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09FA9208CB
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 13:21:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09FA9208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F44F6B0007; Mon,  2 Sep 2019 09:21:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A4186B0008; Mon,  2 Sep 2019 09:21:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B9176B000A; Mon,  2 Sep 2019 09:21:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0099.hostedemail.com [216.40.44.99])
	by kanga.kvack.org (Postfix) with ESMTP id 69E4A6B0007
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:21:07 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8DEB23D01
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 13:21:06 +0000 (UTC)
X-FDA: 75890041332.24.anger92_43d84ed47a246
X-HE-Tag: anger92_43d84ed47a246
X-Filterd-Recvd-Size: 2685
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 13:21:06 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A855BADF1;
	Mon,  2 Sep 2019 13:21:04 +0000 (UTC)
Date: Mon, 2 Sep 2019 15:21:04 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: minchan@kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
Message-ID: <20190902132104.GJ14028@dhcp22.suse.cz>
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 30-08-19 18:13:31, Vinayak Menon wrote:
> The following race is observed due to which a processes faulting
> on a swap entry, finds the page neither in swapcache nor swap. This
> causes zram to give a zero filled page that gets mapped to the
> process, resulting in a user space crash later.
> 
> Consider parent and child processes Pa and Pb sharing the same swap
> slot with swap_count 2. Swap is on zram with SWP_SYNCHRONOUS_IO set.
> Virtual address 'VA' of Pa and Pb points to the shared swap entry.
> 
> Pa                                       Pb
> 
> fault on VA                              fault on VA
> do_swap_page                             do_swap_page
> lookup_swap_cache fails                  lookup_swap_cache fails
>                                          Pb scheduled out
> swapin_readahead (deletes zram entry)
> swap_free (makes swap_count 1)
>                                          Pb scheduled in
>                                          swap_readpage (swap_count == 1)
>                                          Takes SWP_SYNCHRONOUS_IO path
>                                          zram enrty absent
>                                          zram gives a zero filled page

This sounds like a zram issue, right? Why is a generic swap path changed
then?

> 
> Fix this by reading the swap_count before lookup_swap_cache, which conforms
> with the order in which page is added to swap cache and swap count is
> decremented in do_swap_page. In the race case above, this will let Pb take
> the readahead path and thus pick the proper page from swapcache.
> 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
-- 
Michal Hocko
SUSE Labs

