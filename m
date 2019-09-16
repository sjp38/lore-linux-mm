Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BF8DC4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 11:11:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E33421848
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 11:11:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E33421848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEF966B0005; Mon, 16 Sep 2019 07:11:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7B946B0006; Mon, 16 Sep 2019 07:11:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98DE36B0007; Mon, 16 Sep 2019 07:11:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0154.hostedemail.com [216.40.44.154])
	by kanga.kvack.org (Postfix) with ESMTP id 70D4D6B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:11:42 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0F19A180AD802
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:11:42 +0000 (UTC)
X-FDA: 75940518444.18.patch11_2be1f31346425
X-HE-Tag: patch11_2be1f31346425
X-Filterd-Recvd-Size: 3029
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:11:41 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4D300AFF3;
	Mon, 16 Sep 2019 11:11:39 +0000 (UTC)
Subject: Re: [PATCH] mm, thp: Do not queue fully unmapped pages for deferred
 split
To: Michal Hocko <mhocko@kernel.org>,
 "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
References: <20190913091849.11151-1-kirill.shutemov@linux.intel.com>
 <20190916103602.GD10231@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5c946cd9-e17b-b184-37b7-250c6dfb977c@suse.cz>
Date: Mon, 16 Sep 2019 13:11:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190916103602.GD10231@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/16/19 12:36 PM, Michal Hocko wrote:
> On Fri 13-09-19 12:18:49, Kirill A. Shutemov wrote:
>> Adding fully unmapped pages into deferred split queue is not productive:
>> these pages are about to be freed or they are pinned and cannot be split
>> anyway.
>> 
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> ---
>>  mm/rmap.c | 14 ++++++++++----
>>  1 file changed, 10 insertions(+), 4 deletions(-)
>> 
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 003377e24232..45388f1bf317 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1271,12 +1271,20 @@ static void page_remove_anon_compound_rmap(struct page *page)
>>  	if (TestClearPageDoubleMap(page)) {
>>  		/*
>>  		 * Subpages can be mapped with PTEs too. Check how many of
>> -		 * themi are still mapped.
>> +		 * them are still mapped.
>>  		 */
>>  		for (i = 0, nr = 0; i < HPAGE_PMD_NR; i++) {
>>  			if (atomic_add_negative(-1, &page[i]._mapcount))
>>  				nr++;
>>  		}
>> +
>> +		/*
>> +		 * Queue the page for deferred split if at least one small
>> +		 * page of the compound page is unmapped, but at least one
>> +		 * small page is still mapped.
>> +		 */
>> +		if (nr && nr < HPAGE_PMD_NR)
>> +			deferred_split_huge_page(page);
> 
> You've set nr to zero in the for loop so this cannot work AFAICS.

The for loop then does nr++ for each subpage that's still mapped?


>>  	} else {
>>  		nr = HPAGE_PMD_NR;
>>  	}
>> @@ -1284,10 +1292,8 @@ static void page_remove_anon_compound_rmap(struct page *page)
>>  	if (unlikely(PageMlocked(page)))
>>  		clear_page_mlock(page);
>>  
>> -	if (nr) {
>> +	if (nr)
>>  		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
>> -		deferred_split_huge_page(page);
>> -	}
>>  }
>>  
>>  /**
>> -- 
>> 2.21.0
> 


