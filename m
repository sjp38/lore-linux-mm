Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A8C8C3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 13:02:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D08BC2173E
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 13:02:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D08BC2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2677B6B0318; Thu, 22 Aug 2019 09:02:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23EAF6B0319; Thu, 22 Aug 2019 09:02:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 156296B031A; Thu, 22 Aug 2019 09:02:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id E6B3F6B0318
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:02:23 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 56FC7180AD83C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 13:02:23 +0000 (UTC)
X-FDA: 75850077366.23.road95_892f209dfb527
X-HE-Tag: road95_892f209dfb527
X-Filterd-Recvd-Size: 2948
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 13:02:22 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 07064ADBB;
	Thu, 22 Aug 2019 13:02:20 +0000 (UTC)
Date: Thu, 22 Aug 2019 15:02:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>, pankaj.suryawanshi@einfochips.com
Subject: Re: How cma allocation works ?
Message-ID: <20190822130219.GK12785@dhcp22.suse.cz>
References: <CACDBo56W1JGOc6w-NAf-hyWwJQ=vEDsAVAkO8MLLJBpQ0FTAcA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACDBo56W1JGOc6w-NAf-hyWwJQ=vEDsAVAkO8MLLJBpQ0FTAcA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 21-08-19 22:58:03, Pankaj Suryawanshi wrote:
> Hello,
> 
> Hard time to understand cma allocation how differs from normal allocation ?

The buddy allocator which is built for order-N sized allocations and it
is highly optimized because it used from really hot paths. The allocator
also involves memory reclaim to get memory when there is none
immediatelly available.

CMA allocator operates on a pre reserved physical memory range(s) and
focuses on allocating areas that require physically contigous memory of
larger sizes. Very broadly speaking. LWN usually contains nice writeups
for many kernel internals. E.g. quick googling pointed to https://lwn.net/Articles/486301/

> I know theoretically how cma works.
> 
> 1. How it reserved the memory (start pfn to end pfn) ? what is bitmap_*
> functions ?

Not sure what you are asking here TBH

> 2. How alloc_contig_range() works ? it isolate all the pages including
> unevictable pages, what is the practical work flow ? all this works with
> virtual pages or physical pages ?

Yes it isolates a specific physical contiguous (pfn) range, tries to
move any used memory within that range and make it available for the
caller.

> 3.what start_isolate_page_range() does ?

There is some documentation for that function. Which part is not clear?

> 4. what alloc_contig_migrate_range does() ?

Have you checked the code? It simply tries to reclaim and/or migrate
pages off the pfn range.

> 5.what isolate_migratepages_range(), reclaim_clean_pages_from_list(),
>  migrate_pages() and shrink_page_list() is doing ?

Again, have you checked the code/comments? What exactly is not clear?
 
> Please let me know the flow with simple example.

Look at alloc_gigantic_page which is using the contiguous allocator to
get 1GB physically contiguous memory ranges to be used for hugetlb
pages.

HTH
-- 
Michal Hocko
SUSE Labs

