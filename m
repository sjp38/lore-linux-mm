Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EFF5C3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 11:25:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E5E122CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 11:25:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E5E122CED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A40226B0003; Wed,  4 Sep 2019 07:25:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F0B16B0006; Wed,  4 Sep 2019 07:25:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 905986B0007; Wed,  4 Sep 2019 07:25:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0177.hostedemail.com [216.40.44.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB736B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:25:02 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CC81C40EE
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:25:01 +0000 (UTC)
X-FDA: 75897006402.26.girl89_2bdaa37b10105
X-HE-Tag: girl89_2bdaa37b10105
X-Filterd-Recvd-Size: 2445
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:25:01 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9693EB049;
	Wed,  4 Sep 2019 11:24:59 +0000 (UTC)
Subject: Re: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
To: zhong jiang <zhongjiang@huawei.com>, akpm@linux-foundation.org,
 mhocko@kernel.org
Cc: anshuman.khandual@arm.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Ira Weiny <ira.weiny@intel.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
References: <1567592763-25282-1-git-send-email-zhongjiang@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5505fa16-117e-8890-0f48-38555a61a036@suse.cz>
Date: Wed, 4 Sep 2019 13:24:58 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1567592763-25282-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/4/19 12:26 PM, zhong jiang wrote:
> With the help of unsigned_lesser_than_zero.cocci. Unsigned 'nr_pages"'
> compare with zero. And __get_user_pages_locked will return an long value.
> Hence, Convert the long to compare with zero is feasible.

It would be nicer if the parameter nr_pages was long again instead of unsigned
long (note there are two variants of the function, so both should be changed).

> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

Fixes: 932f4a630a69 ("mm/gup: replace get_user_pages_longterm() with FOLL_LONGTERM")

(which changed long to unsigned long)

AFAICS... stable shouldn't be needed as the only "risk" is that we goto
check_again even when we fail, which should be harmless.

Vlastimil

> ---
>  mm/gup.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 23a9f9c..956d5a1 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1508,7 +1508,7 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  						   pages, vmas, NULL,
>  						   gup_flags);
>  
> -		if ((nr_pages > 0) && migrate_allow) {
> +		if (((long)nr_pages > 0) && migrate_allow) {
>  			drain_allow = true;
>  			goto check_again;
>  		}
> 


