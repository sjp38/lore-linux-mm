Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2E65C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 12:52:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADFB523431
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 12:52:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADFB523431
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40B566B0003; Wed,  4 Sep 2019 08:52:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BB3E6B0006; Wed,  4 Sep 2019 08:52:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A9CF6B0007; Wed,  4 Sep 2019 08:52:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0239.hostedemail.com [216.40.44.239])
	by kanga.kvack.org (Postfix) with ESMTP id 039EA6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:52:28 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8AECE8125
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:52:28 +0000 (UTC)
X-FDA: 75897226776.07.idea01_4fc7a89065e24
X-HE-Tag: idea01_4fc7a89065e24
X-Filterd-Recvd-Size: 3111
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:52:28 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1084EAF47;
	Wed,  4 Sep 2019 12:52:27 +0000 (UTC)
Date: Wed, 4 Sep 2019 14:52:26 +0200
From: Michal Hocko <mhocko@kernel.org>
To: sunqiuyang <sunqiuyang@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Message-ID: <20190904125226.GV3838@dhcp22.suse.cz>
References: <20190903082746.20736-1-sunqiuyang@huawei.com>
 <20190903131737.GB18939@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C1B09@dggeml512-mbx.china.huawei.com>
 <20190904063836.GD3838@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C2EBD@dggeml512-mbx.china.huawei.com>
 <20190904081408.GF3838@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C3402@dggeml512-mbx.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <157FC541501A9C4C862B2F16FFE316DC190C3402@dggeml512-mbx.china.huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 04-09-19 12:19:11, sunqiuyang wrote:
> > Do not top post please
> > 
> > On Wed 04-09-19 07:27:25, sunqiuyang wrote:
> > > isolate_migratepages_block() from another thread may try to isolate the page again:
> > >
> > > for (; low_pfn < end_pfn; low_pfn++) {
> > >   /* ... */
> > >   page = pfn_to_page(low_pfn);
> > >  /* ... */
> > >   if (!PageLRU(page)) {
> > >     if (unlikely(__PageMovable(page)) && !PageIsolated(page)) {
> > >         /* ... */
> > >         if (!isolate_movable_page(page, isolate_mode))
> > >           goto isolate_success;
> > >       /*... */
> > > isolate_success:
> > >      list_add(&page->lru, &cc->migratepages);
> > >
> > > And this page will be added to another list.
> > > Or, do you see any reason that the page cannot go through this path?
> > 
> > The page shouldn't be __PageMovable after the migration is done. All the
> > state should have been transfered to the new page IIUC.
> > 
>
> I don't see where page->mapping is modified after the migration is done. 
> 
> Actually, the last comment in move_to_new_page() says,
> "Anonymous and movable page->mapping will be cleard by
> free_pages_prepare so don't reset it here for keeping
> the type to work PageAnon, for example. "
> 
> Or did I miss something? Thanks,

This talks about mapping rather than flags stored in the mapping.
I can see that in tree migration handlers (z3fold_page_migrate,
vmballoon_migratepage via balloon_page_delete, zs_page_migrate via
reset_page) all reset the movable flag. I am not sure whether that is a
documented requirement or just a coincidence. Maybe it should be
documented. I would like to hear from Minchan.

-- 
Michal Hocko
SUSE Labs

