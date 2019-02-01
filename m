Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76CD6C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 11:59:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEEED218AC
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 11:59:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEEED218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 493128E0003; Fri,  1 Feb 2019 06:59:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4443D8E0001; Fri,  1 Feb 2019 06:59:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30DAE8E0003; Fri,  1 Feb 2019 06:59:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id AEB228E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 06:59:14 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id d6so1097148lfk.1
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 03:59:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=e2ZpZnoyiJ9xQHaiUi+JenpaminNzWJXeWGtKVzyXBQ=;
        b=GbtlFMKeGDZIaobZAom1Er0ww5DSpL2998muWr7W9AXWvCJWz9zC7yeTrqqtnGnQqQ
         RbYUR1SXkDwMBscJy57+EgD3SWm568wVdPAmTNfFeeD4YE56dqMVWr4qe1pC9x/08ucX
         iAK7xomj4ahGbVCwv1ZhvN0Pumj/ZONrEn7vFW9jz8ea2iqhzcXz1cFtFcf68RMOHdL5
         mZ7auZRvsXkuV1530rtt8fsCJ/HZ0CYUcHaKwM1SDm/IWqjWWKDFHCcv7f0uP8oszVn0
         po2IvfERhuHqODZkysrP/gaFues4L5w5Zci5gUd1OiNXyf92E25hVGKdP1GrFbf/7UQ4
         U/qQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AJcUukdQqEI69QgHvP/WiepUL0aHSOMuiNV35jncAC08DyzRaU2PCIp8
	XJurX0ZaObCyWZp3H87I2HpRyP/kH1YqbSiwPDF8N7GlK33lXaigxbGTrqLdq7sGJ/9wGb+aiHj
	TixFfZUKcEQCGwnRJ+U0xTtP6yuKg+f0wENT8I+Hfeh6KMWWB8b8Yw6gkYmn6h/YojA==
X-Received: by 2002:a19:a9d2:: with SMTP id s201mr25433908lfe.154.1549022353950;
        Fri, 01 Feb 2019 03:59:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN63wBybH7y0d882uuAL9h8piu2LWfgrChfzGTwaNMCcfdpFcEJTE4+wCRDExe8OMSLC6iE5
X-Received: by 2002:a19:a9d2:: with SMTP id s201mr25433859lfe.154.1549022352600;
        Fri, 01 Feb 2019 03:59:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549022352; cv=none;
        d=google.com; s=arc-20160816;
        b=uRwEJ5qpJN25gDuUYauykZW7HI8AFMKHRw3TpwMdVvVlm+Ka7vFItVb4K2nWWpX8DV
         MYvBPXajYTeUrK1/+KCTIbNuGCSnGFMlL1JoB4vlMg/d6zu0Qt57zDic/DpTDpJUgjL+
         UmSysM7YFY1tuGzeu+X3arrEoFTg1jCsZ022ZLQN6pqyb0VDi4D1N5W+NpHU76+Z5pf/
         ECeycw1Gk/nr+TEIO0OIC6shpjnnVwb4dChDuBzgodwS4TLTCiPhLDsj4Um2yi5vHqRy
         L8suZXMBp5TMF0kDjk78NaNnlKRKUDQiYELNYoLQnu7Cc/+aiWgXUOfsfg8EmF+MmEMa
         7lgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=e2ZpZnoyiJ9xQHaiUi+JenpaminNzWJXeWGtKVzyXBQ=;
        b=cIWjzjHYmhzRYbu/uzAhK15djnmZ/eCS50oJ4ABfiDVoVpFOMwJjWerH+C+c9fR4N6
         dp8144/0dRkS+Av5KSRXf+XRgzy4wJkPPqYG1y4CtPklO4NtNC+MK3VyR19GWAKPxudB
         zJBtqSv3pBw8hquVX2/RpUMFx9YvV340qpfaHPVLlLntQfXaLtoVxCCiXsaZx1y1Fqet
         mui9tXXWeDKpKx04YBko/SH9QT4XSy688+hxhA0lloyzzQZQYLg+x6gpn/lS/YLd5Ji6
         nAsoHgMvX1l0EcGP9hn/ZsO92UqL4C0lgRzN+FGAvlMCN8+OBU7M8GZyD3PhDWq5vwBy
         sqmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id e16-v6si6892252ljh.218.2019.02.01.03.59.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 03:59:12 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gpXTT-0000tj-3W; Fri, 01 Feb 2019 14:59:11 +0300
Subject: Re: [PATCH] mm: Do not allocate duplicate stack variables in
 shrink_page_list()
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <154894900030.5211.12104993874109647641.stgit@localhost.localdomain>
 <20190201112644.GM11599@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <e61efd8b-2a27-d83f-0568-1d16e0321417@virtuozzo.com>
Date: Fri, 1 Feb 2019 14:59:10 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190201112644.GM11599@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.02.2019 14:26, Michal Hocko wrote:
> On Thu 31-01-19 18:37:02, Kirill Tkhai wrote:
>> On path shrink_inactive_list() ---> shrink_page_list()
>> we allocate stack variables for the statistics twice.
>> This is completely useless, and this just consumes stack
>> much more, then we really need.
>>
>> The patch kills duplicate stack variables from shrink_page_list(),
>> and this reduce stack usage and object file size significantly:
> 
> significantly is a bit of an overstatement for 32B saved...

32/648*100 = 4.93827160493827160400

Almost 5%. I think it's not so bad...

>> Stack usage:
>> Before: vmscan.c:1122:22:shrink_page_list	648	static
>> After:  vmscan.c:1122:22:shrink_page_list	616	static
>>
>> Size of vmscan.o:
>>          text	   data	    bss	    dec	    hex	filename
>> Before: 56866	   4720	    128	  61714	   f112	mm/vmscan.o
>> After:  56770	   4720	    128	  61618	   f0b2	mm/vmscan.o
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
>> ---
>>  mm/vmscan.c |   44 ++++++++++++++------------------------------
>>  1 file changed, 14 insertions(+), 30 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index dd9554f5d788..54a389fd91e2 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1128,16 +1128,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  {
>>  	LIST_HEAD(ret_pages);
>>  	LIST_HEAD(free_pages);
>> -	int pgactivate = 0;
>> -	unsigned nr_unqueued_dirty = 0;
>> -	unsigned nr_dirty = 0;
>> -	unsigned nr_congested = 0;
>>  	unsigned nr_reclaimed = 0;
>> -	unsigned nr_writeback = 0;
>> -	unsigned nr_immediate = 0;
>> -	unsigned nr_ref_keep = 0;
>> -	unsigned nr_unmap_fail = 0;
>>  
>> +	memset(stat, 0, sizeof(*stat));
>>  	cond_resched();
>>  
>>  	while (!list_empty(page_list)) {
>> @@ -1181,10 +1174,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  		 */
>>  		page_check_dirty_writeback(page, &dirty, &writeback);
>>  		if (dirty || writeback)
>> -			nr_dirty++;
>> +			stat->nr_dirty++;
>>  
>>  		if (dirty && !writeback)
>> -			nr_unqueued_dirty++;
>> +			stat->nr_unqueued_dirty++;
>>  
>>  		/*
>>  		 * Treat this page as congested if the underlying BDI is or if
>> @@ -1196,7 +1189,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  		if (((dirty || writeback) && mapping &&
>>  		     inode_write_congested(mapping->host)) ||
>>  		    (writeback && PageReclaim(page)))
>> -			nr_congested++;
>> +			stat->nr_congested++;
>>  
>>  		/*
>>  		 * If a page at the tail of the LRU is under writeback, there
>> @@ -1245,7 +1238,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  			if (current_is_kswapd() &&
>>  			    PageReclaim(page) &&
>>  			    test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
>> -				nr_immediate++;
>> +				stat->nr_immediate++;
>>  				goto activate_locked;
>>  
>>  			/* Case 2 above */
>> @@ -1263,7 +1256,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  				 * and it's also appropriate in global reclaim.
>>  				 */
>>  				SetPageReclaim(page);
>> -				nr_writeback++;
>> +				stat->nr_writeback++;
>>  				goto activate_locked;
>>  
>>  			/* Case 3 above */
>> @@ -1283,7 +1276,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  		case PAGEREF_ACTIVATE:
>>  			goto activate_locked;
>>  		case PAGEREF_KEEP:
>> -			nr_ref_keep++;
>> +			stat->nr_ref_keep++;
>>  			goto keep_locked;
>>  		case PAGEREF_RECLAIM:
>>  		case PAGEREF_RECLAIM_CLEAN:
>> @@ -1348,7 +1341,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  			if (unlikely(PageTransHuge(page)))
>>  				flags |= TTU_SPLIT_HUGE_PMD;
>>  			if (!try_to_unmap(page, flags)) {
>> -				nr_unmap_fail++;
>> +				stat->nr_unmap_fail++;
>>  				goto activate_locked;
>>  			}
>>  		}
>> @@ -1496,7 +1489,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  		VM_BUG_ON_PAGE(PageActive(page), page);
>>  		if (!PageMlocked(page)) {
>>  			SetPageActive(page);
>> -			pgactivate++;
>> +			stat->nr_activate++;
>>  			count_memcg_page_event(page, PGACTIVATE);
>>  		}
>>  keep_locked:
>> @@ -1511,18 +1504,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  	free_unref_page_list(&free_pages);
>>  
>>  	list_splice(&ret_pages, page_list);
>> -	count_vm_events(PGACTIVATE, pgactivate);
>> -
>> -	if (stat) {
>> -		stat->nr_dirty = nr_dirty;
>> -		stat->nr_congested = nr_congested;
>> -		stat->nr_unqueued_dirty = nr_unqueued_dirty;
>> -		stat->nr_writeback = nr_writeback;
>> -		stat->nr_immediate = nr_immediate;
>> -		stat->nr_activate = pgactivate;
>> -		stat->nr_ref_keep = nr_ref_keep;
>> -		stat->nr_unmap_fail = nr_unmap_fail;
>> -	}
>> +	count_vm_events(PGACTIVATE, stat->nr_activate);
>> +
>>  	return nr_reclaimed;
>>  }
>>  
>> @@ -1534,6 +1517,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>>  		.priority = DEF_PRIORITY,
>>  		.may_unmap = 1,
>>  	};
>> +	struct reclaim_stat dummy_stat;
>>  	unsigned long ret;
>>  	struct page *page, *next;
>>  	LIST_HEAD(clean_pages);
>> @@ -1547,7 +1531,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>>  	}
>>  
>>  	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
>> -			TTU_IGNORE_ACCESS, NULL, true);
>> +			TTU_IGNORE_ACCESS, &dummy_stat, true);
>>  	list_splice(&clean_pages, page_list);
>>  	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
>>  	return ret;
>> @@ -1922,7 +1906,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>>  	unsigned long nr_scanned;
>>  	unsigned long nr_reclaimed = 0;
>>  	unsigned long nr_taken;
>> -	struct reclaim_stat stat = {};
>> +	struct reclaim_stat stat;
>>  	int file = is_file_lru(lru);
>>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>>
> 

