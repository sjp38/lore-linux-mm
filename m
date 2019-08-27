Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7301C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 05:43:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C3FF20828
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 05:43:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C3FF20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D17B6B000A; Tue, 27 Aug 2019 01:43:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15C466B000C; Tue, 27 Aug 2019 01:43:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04A306B000D; Tue, 27 Aug 2019 01:43:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0075.hostedemail.com [216.40.44.75])
	by kanga.kvack.org (Postfix) with ESMTP id D68D76B000A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:43:42 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7F2A6824CA38
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 05:43:42 +0000 (UTC)
X-FDA: 75867115884.03.stew71_5a8b091cec02c
X-HE-Tag: stew71_5a8b091cec02c
X-Filterd-Recvd-Size: 4214
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 05:43:42 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 20079ACC2;
	Tue, 27 Aug 2019 05:43:38 +0000 (UTC)
Date: Tue, 27 Aug 2019 07:43:37 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>, pankaj.suryawanshi@einfochips.com
Subject: Re: PageBlocks and Migrate Types
Message-ID: <20190827054337.GK7538@dhcp22.suse.cz>
References: <CACDBo57u+sgordDvFpTzJ=U4mT8uVz7ZovJ3qSZQCrhdYQTw0A@mail.gmail.com>
 <20190822125231.GJ12785@dhcp22.suse.cz>
 <CACDBo57OkND1LCokPLfyR09+oRTbA6+GAPc90xAEF6AM_LmbyQ@mail.gmail.com>
 <20190826070436.GA7538@dhcp22.suse.cz>
 <CACDBo555_pxZjixThUZcqnADVVcmH1Qtfrr5H-2AR12L0=Rx3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACDBo555_pxZjixThUZcqnADVVcmH1Qtfrr5H-2AR12L0=Rx3A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 26-08-19 22:35:08, Pankaj Suryawanshi wrote:
> On Mon, Aug 26, 2019 at 12:34 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 22-08-19 23:54:19, Pankaj Suryawanshi wrote:
> > > On Thu, Aug 22, 2019 at 6:22 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Wed 21-08-19 22:23:44, Pankaj Suryawanshi wrote:
> > > > > Hello,
> > > > >
> > > > > 1. What are Pageblocks and migrate types(MIGRATE_CMA) in Linux
> memory ?
> > > >
> > > > Pageblocks are a simple grouping of physically contiguous pages with
> > > > common set of flags. I haven't checked closely recently so I might
> > > > misremember but my recollection is that only the migrate type is
> stored
> > > > there. Normally we would store that information into page flags but
> > > > there is not enough room there.
> > > >
> > > > MIGRATE_CMA represent pages allocated for the CMA allocator. There are
> > > > other migrate types denoting unmovable/movable allocations or pages
> that
> > > > are isolated from the page allocator.
> > > >
> > > > Very broadly speaking, the migrate type groups pages with similar
> > > > movability properties to reduce fragmentation that compaction cannot
> > > > do anything about because there are objects of different properti
> > > > around. Please note that pageblock might contain objects of a
> different
> > > > migrate type in some cases (e.g. low on memory).
> > > >
> > > > Have a look at gfpflags_to_migratetype and how the gfp mask is
> converted
> > > > to a migratetype for the allocation. Also follow different
> MIGRATE_$TYPE
> > > > to see how it is used in the code.
> > > >
> > > > > How many movable/unmovable pages are defined by default?
> > > >
> > > > There is nothing like that. It depends on how many objects of a
> specific
> > > > type are allocated.
> > >
> > >
> > > It means that it started creating pageblocks after allocation of
> > > different objects, but from which block it allocate initially when
> > > there is nothing like pageblocks ? (when memory subsystem up)
> >
> > Pageblocks are just a way to group physically contiguous pages. They
> > just exist along with the physically contiguous memory. The migrate type
> > for most of the memory is set to MIGRATE_MOVABLE. Portion of the memory
> > might be reserved by CMA then that memory has MIGRATE_CMA. Following
> > set_pageblock_migratetype call paths will give you a good picture.
> 
> it means if i have 4096 continuous pages = 1 pageblock
> then all the 4096 pages of same type. but if any one page is different than
> block type then ? it changed the block type or something else ?

That really depends on the specific migrate type. CMA, ISOLATE migrate
types are all or nothing IIRC. I would have to check the code to tell
exactly when MOVABLE/UNMOVABLE pageblocks transitions are done.
steal_suitable_fallback sounds like a good start to look at.
-- 
Michal Hocko
SUSE Labs

