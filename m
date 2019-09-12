Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_2 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7903BC4CEC5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 13:16:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2162A2084D
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 13:16:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2162A2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C1DD6B0005; Thu, 12 Sep 2019 09:16:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 771A16B0006; Thu, 12 Sep 2019 09:16:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 687D16B0007; Thu, 12 Sep 2019 09:16:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0039.hostedemail.com [216.40.44.39])
	by kanga.kvack.org (Postfix) with ESMTP id 4487E6B0005
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 09:16:56 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C6333180AD804
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 13:16:55 +0000 (UTC)
X-FDA: 75926318790.13.key20_1f57510053f57
X-HE-Tag: key20_1f57510053f57
X-Filterd-Recvd-Size: 2631
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 13:16:55 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8D424AFFE;
	Thu, 12 Sep 2019 13:16:53 +0000 (UTC)
Message-ID: <1568294211.2993.0.camel@suse.de>
Subject: Re: [PATCH 00/10] Hwpoison soft-offline rework
From: Oscar Salvador <osalvador@suse.de>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "mhocko@kernel.org" <mhocko@kernel.org>, "mike.kravetz@oracle.com"
	 <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>
Date: Thu, 12 Sep 2019 15:16:51 +0200
In-Reply-To: <20190911072112.GA12499@hori.linux.bs1.fc.nec.co.jp>
References: <20190910103016.14290-1-osalvador@suse.de>
	 <20190911052956.GA9729@hori.linux.bs1.fc.nec.co.jp>
	 <20190911062246.GA31960@hori.linux.bs1.fc.nec.co.jp>
	 <59dce1bc205b10f67f17cf9d2e1e7a04@suse.de>
	 <20190911072112.GA12499@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> It's available on https://github.com/Naoya-Horiguchi/mm_regression.
> The README is a bit obsolete (sorry about that ...,) but you can run
> the testcase like below:
> 
>   $ git clone https://github.com/Naoya-Horiguchi/mm_regression
>   $ cd mm_regression
>   mm_regression $ git clone https://github.com/Naoya-Horiguchi/test_c
> ore 
>   mm_regression $ make
>   // you might need to install some dependencies like numa library
> and mce-inject tool
>   mm_regression $ make update_recipes
> 
> To run the single testcase, run the commands like below:
> 
>   mm_regression $
> RECIPEFILES=cases/page_migration/hugetlb_migratepages_allocate1_noove
> rcommit.auto2 bash run.sh
>   mm_regression $ RECIPEFILES=cases/cases/mce_ksm_soft-
> offline_avoid_access.auto2 bash run.sh
>   
> You can run a set of many testcases with the commands like below:
> 
>   mm_regression $ RECIPEFILES=cases/cases/mce_ksm_* bash run.sh
>   // run all ksm related testcases. I reproduced the panic with this
> command.
> 
>   mm_regression $ run_class=simple bash run.sh
>   // run the set of minimum testcases I run for each releases.
> 
> Hopefully this will help you.

Great, I was able to reproduce it.

I will be working on solving it.

Thanks Naoya!

> 
> Thanks,
> Naoya Horiguchi
> 
-- 
Oscar Salvador
SUSE L3

