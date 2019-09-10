Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A190EC49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 19:31:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7925821D6C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 19:31:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7925821D6C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1846C6B0007; Tue, 10 Sep 2019 15:31:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 134EC6B0008; Tue, 10 Sep 2019 15:31:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04B256B000A; Tue, 10 Sep 2019 15:31:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0108.hostedemail.com [216.40.44.108])
	by kanga.kvack.org (Postfix) with ESMTP id D5C956B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 15:31:23 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5F7D7181AC9C6
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 19:31:23 +0000 (UTC)
X-FDA: 75920004846.30.self97_807cf53a5df22
X-HE-Tag: self97_807cf53a5df22
X-Filterd-Recvd-Size: 1967
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 19:31:22 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6ED4FAE68;
	Tue, 10 Sep 2019 19:31:21 +0000 (UTC)
Date: Tue, 10 Sep 2019 21:31:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: sunqiuyang <sunqiuyang@huawei.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Message-ID: <20190910193120.GF4023@dhcp22.suse.cz>
References: <20190903082746.20736-1-sunqiuyang@huawei.com>
 <20190910192304.GA220078@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190910192304.GA220078@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 10-09-19 12:23:04, Minchan Kim wrote:
> On Tue, Sep 03, 2019 at 04:27:46PM +0800, sunqiuyang wrote:
> > From: Qiuyang Sun <sunqiuyang@huawei.com>
> > 
> > Currently, after a page is migrated, it
> > 1) has its PG_isolated flag cleared in move_to_new_page(), and
> > 2) is deleted from its LRU list (cc->migratepages) in unmap_and_move().
> > However, between steps 1) and 2), the page could be isolated by another
> > thread in isolate_movable_page(), and added to another LRU list, leading
> > to list_del corruption later.
> 
> Once non-LRU page is migrated out successfully, driver should clear
> the movable flag in the page. Look at reset_page in zs_page_migrate.
> So, other thread couldn't isolate the page during the window.
> 
> If I miss something, let me know it.

Please have a look at http://lkml.kernel.org/r/157FC541501A9C4C862B2F16FFE316DC190C5990@dggeml512-mbx.china.huawei.com
-- 
Michal Hocko
SUSE Labs

