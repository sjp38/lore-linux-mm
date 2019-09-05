Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6665C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 06:18:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ADA0217D7
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 06:18:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ADA0217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6F6D6B0006; Thu,  5 Sep 2019 02:18:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A22616B0007; Thu,  5 Sep 2019 02:18:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 936766B0008; Thu,  5 Sep 2019 02:18:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0170.hostedemail.com [216.40.44.170])
	by kanga.kvack.org (Postfix) with ESMTP id 741816B0006
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 02:18:18 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 14DA5181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:18:18 +0000 (UTC)
X-FDA: 75899862276.17.hour31_2b4fb2e8dcf5b
X-HE-Tag: hour31_2b4fb2e8dcf5b
X-Filterd-Recvd-Size: 3523
Received: from huawei.com (szxga04-in.huawei.com [45.249.212.190])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:18:17 +0000 (UTC)
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id EA4B7F2C9DDCA2E5A9B3;
	Thu,  5 Sep 2019 14:18:12 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.439.0; Thu, 5 Sep 2019
 14:18:11 +0800
Message-ID: <5D70A8A2.3040701@huawei.com>
Date: Thu, 5 Sep 2019 14:18:10 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>
CC: Vlastimil Babka <vbabka@suse.cz>, <mhocko@kernel.org>,
	<anshuman.khandual@arm.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Ira Weiny <ira.weiny@intel.com>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
References: <1567592763-25282-1-git-send-email-zhongjiang@huawei.com> <5505fa16-117e-8890-0f48-38555a61a036@suse.cz> <20190904114820.42d9c4daf445ded3d0da52ab@linux-foundation.org>
In-Reply-To: <20190904114820.42d9c4daf445ded3d0da52ab@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/9/5 2:48, Andrew Morton wrote:
> On Wed, 4 Sep 2019 13:24:58 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>
>> On 9/4/19 12:26 PM, zhong jiang wrote:
>>> With the help of unsigned_lesser_than_zero.cocci. Unsigned 'nr_pages"'
>>> compare with zero. And __get_user_pages_locked will return an long value.
>>> Hence, Convert the long to compare with zero is feasible.
>> It would be nicer if the parameter nr_pages was long again instead of unsigned
>> long (note there are two variants of the function, so both should be changed).
> nr_pages should be unsigned - it's a count of pages!
>
> The bug is that __get_user_pages_locked() returns a signed long which
> can be a -ve errno.
>
> I think it's best if __get_user_pages_locked() is to get itself a new
> local with the same type as its return value.  Something like:
>
> --- a/mm/gup.c~a
> +++ a/mm/gup.c
> @@ -1450,6 +1450,7 @@ static long check_and_migrate_cma_pages(
>  	bool drain_allow = true;
>  	bool migrate_allow = true;
>  	LIST_HEAD(cma_page_list);
> +	long ret;
>  
>  check_again:
>  	for (i = 0; i < nr_pages;) {
> @@ -1511,17 +1512,18 @@ check_again:
>  		 * again migrating any new CMA pages which we failed to isolate
>  		 * earlier.
>  		 */
> -		nr_pages = __get_user_pages_locked(tsk, mm, start, nr_pages,
> +		ret = __get_user_pages_locked(tsk, mm, start, nr_pages,
>  						   pages, vmas, NULL,
>  						   gup_flags);
>  
> -		if ((nr_pages > 0) && migrate_allow) {
> +		nr_pages = ret;
> +		if (ret > 0 && migrate_allow) {
>  			drain_allow = true;
>  			goto check_again;
>  		}
>  	}
>  
> -	return nr_pages;
> +	return ret;
>  }
>  #else
>  static long check_and_migrate_cma_pages(struct task_struct *tsk,
Firstly,  I consider the some modified method as you has writen down above.  It seems to work well.
According to Vlastimil's feedback,   I repost the patch in v2,   changing the parameter to long to fix
the issue.  which one do you prefer?

Thanks,
zhong jiang


