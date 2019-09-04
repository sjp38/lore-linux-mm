Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E7F0C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 11:25:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D244722CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 11:25:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D244722CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FB736B0006; Wed,  4 Sep 2019 07:25:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55E786B0007; Wed,  4 Sep 2019 07:25:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 425B86B0008; Wed,  4 Sep 2019 07:25:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED116B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:25:04 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8176E99B2
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:25:03 +0000 (UTC)
X-FDA: 75897006486.28.pin23_2c19b4565692f
X-HE-Tag: pin23_2c19b4565692f
X-Filterd-Recvd-Size: 2726
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:25:02 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A3B9CAFDB;
	Wed,  4 Sep 2019 11:25:01 +0000 (UTC)
Date: Wed, 4 Sep 2019 13:25:00 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Thomas Lindroth <thomas.lindroth@gmail.com>, linux-mm@kvack.org
Subject: Re: [BUG] kmemcg limit defeats __GFP_NOFAIL allocation
Message-ID: <20190904112500.GO3838@dhcp22.suse.cz>
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <666dbcde-1b8a-9e2d-7d1f-48a117c78ae1@I-love.SAKURA.ne.jp>
 <ccf79dd9-b2e5-0d78-f520-164d198f9ca4@gmail.com>
 <4d0eda9a-319d-1a7d-1eed-71da90902367@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4d0eda9a-319d-1a7d-1eed-71da90902367@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 04-09-19 18:36:06, Tetsuo Handa wrote:
[...]
> The first bug is that __memcg_kmem_charge_memcg() in mm/memcontrol.c is
> failing to return 0 when it is a __GFP_NOFAIL allocation request.
> We should ignore limits when it is a __GFP_NOFAIL allocation request.

OK, fixing that sounds like a reasonable thing to do.
 
> If we force __memcg_kmem_charge_memcg() to return 0, then
> 
> ----------
>         struct page_counter *counter;
>         int ret;
> 
> +       if (gfp & __GFP_NOFAIL)
> +               return 0;
> +
>         ret = try_charge(memcg, gfp, nr_pages);
>         if (ret)
>                 return ret;
> ----------

This should be more likely something like

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9ec5e12486a7..05a4828edf9d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2820,7 +2820,8 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 		return ret;
 
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
-	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter)) {
+	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter) &&
+	    !(gfp_mask & __GFP_NOFAIL)) {
 		cancel_charge(memcg, nr_pages);
 		return -ENOMEM;
 	}

> the second bug that alloc_slabmgmt() in mm/slab.c is returning NULL
> when it is a __GFP_NOFAIL allocation request will appear.
> I don't know how to handle this.

I am sorry, I do not follow, why would alloc_slabmgmt return NULL
with forcing gfp_nofail charges?
-- 
Michal Hocko
SUSE Labs

