Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0619EC3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:38:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6A212339D
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:38:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6A212339D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71D566B0006; Wed,  4 Sep 2019 02:38:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CDFE6B0007; Wed,  4 Sep 2019 02:38:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3B16B000A; Wed,  4 Sep 2019 02:38:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6A16B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:38:40 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D130C824CA3F
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:38:39 +0000 (UTC)
X-FDA: 75896284758.29.fifth61_11650f51bb31b
X-HE-Tag: fifth61_11650f51bb31b
X-Filterd-Recvd-Size: 2062
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:38:39 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C3364ACE3;
	Wed,  4 Sep 2019 06:38:37 +0000 (UTC)
Date: Wed, 4 Sep 2019 08:38:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: sunqiuyang <sunqiuyang@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Message-ID: <20190904063836.GD3838@dhcp22.suse.cz>
References: <20190903082746.20736-1-sunqiuyang@huawei.com>
 <20190903131737.GB18939@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C1B09@dggeml512-mbx.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <157FC541501A9C4C862B2F16FFE316DC190C1B09@dggeml512-mbx.china.huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 04-09-19 02:18:38, sunqiuyang wrote:
> The isolate path of non-lru movable pages:
> 
> isolate_migratepages_block
> 	isolate_movable_page
> 		trylock_page
> 		// if PageIsolated, goto out_no_isolated
> 		a_ops->isolate_page
> 		__SetPageIsolated
> 		unlock_page
> 	list_add(&page->lru, &cc->migratepages)
> 
> The migration path:
> 
> unmap_and_move
> 	__unmap_and_move
> 		lock_page
> 		move_to_new_page
> 			a_ops->migratepage
> 			__ClearPageIsolated
> 		unlock_page
> 	/* here, the page could be isolated again by another thread, and added into another cc->migratepages,
> 	since PG_Isolated has been cleared, and not protected by page_lock */
> 	list_del(&page->lru)

But the page has been migrated already and not freed yet because there
is still a pin on it. So nobody should be touching it at this stage.
Or do I still miss something?
-- 
Michal Hocko
SUSE Labs

