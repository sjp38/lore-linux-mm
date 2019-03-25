Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F928C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 19:49:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05AA520848
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 19:49:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05AA520848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 821F06B0007; Mon, 25 Mar 2019 15:49:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D1A56B0008; Mon, 25 Mar 2019 15:49:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C1DE6B000A; Mon, 25 Mar 2019 15:49:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A16C6B0007
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:49:40 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 42so547999pld.8
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:49:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=XbPCvNQuU1zSl8Hx00bLUSHO+ifQ58ciliZlIcVN9Zg=;
        b=jNMzI4dSM1iSJ4/mYnNtTbFtMmEPq0m9GoXxOLGBPvp3cCTbVM6gLO04D9PWu8FK/O
         c+dlQuUJ3zkOwmNq6xu5V5NK8a4J0oQwcTDx8UX2CcrwiEHTBTWuz5JNJJQywSO1ilkQ
         VWKWTaV9cEiKfM9uMaAPFTbfYeZAFdDPs7K4tgOlSOvVRk5hQF1mfvkQUMO/T/ikMj5d
         sS+VrTgOFrqqbg1JQs1EvQXdG1N+b5CuuhtrxYYHpGh5hrXxr6m+kEuOi/SMOjlDcLfG
         wlbq7NdVavJLw+Rd8J+iaRWbUR/GPtkGj+8j+np+0tlvWkiQYvqPb9VT5c6PL0rHDwml
         4Mug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVuoxYnkWc7OpI1kojD+0x3xEPVpS6iTqCjHeDeolb1PQNh4ReI
	zMllB5sAENWjdGWeN6FLNeqSlsRjtdO3fD0LB17thJKqJcHy4rsxNUBFfvepwR9iyjefGVx5yJy
	sjuhm/1+GGHAktTiB7QhFzLyXd9eSQ4GHd5w5D1bkfNlnwnl/Q06YITEchdgUzVi98Q==
X-Received: by 2002:aa7:914f:: with SMTP id 15mr25581643pfi.49.1553543379827;
        Mon, 25 Mar 2019 12:49:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytiZAoIgqL0azPP6SWqmH9xz5UCTohFim1VBVWRHV5VToR0hWgiZ62kcywCfQlyyEGAEMI
X-Received: by 2002:aa7:914f:: with SMTP id 15mr25581568pfi.49.1553543378893;
        Mon, 25 Mar 2019 12:49:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553543378; cv=none;
        d=google.com; s=arc-20160816;
        b=LHu3gpgAypWXugYq1Kgqj6V5OUF8p6F69pwFMjyj7KXbjpW650tsM/LiQaFDV3AnF5
         bGsddwxeVUj1zdrhRmMMuUmdlQvgU2w2imVbkUtEsYJPknZ7BVra3P4W99TUW7qGPVIW
         KrynUsw+gNUu6fdykvaonow21Dwg77nH5IknCxbEFcirZBiS441lrQS44Edq+gM64pGU
         WPUQfGhUMPHFBKL9rmwAr4kl6f7cIevol0wHmGeeNuMAASmBzidybbC1DnhzhklvUqKm
         MJ1WahUHZ/bWf/9OPClK1OqAqXZoDrOjvVhS5Cj4BNZ/xgvAHH4oZyJMkH6bbViIRvYp
         38sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=XbPCvNQuU1zSl8Hx00bLUSHO+ifQ58ciliZlIcVN9Zg=;
        b=LpQ/g6zCMCUKi92FOMswWlYfsGon3nEJbZcbKyNsWYCjLaEtTjoB9kke2043ML3+xJ
         63rZWlJkmOAYOzTGQzGo2JqcG4NBhgg+hDE0qpyW3YvmzgocUFMqjGrQrIA7ZrwV93Ox
         3Zt9ERd+RlDx0aH01YaitBMTzAAUKS3Tr3Xaib1hDpRhMk5KbfWdLxghwemuDbAkeH8h
         WfiqXRT2XILfz2rqyJQdqYyT/JUftzhqQTqQfEce/1Ax/QpAPPBGG0oQ5zXNz7Af0YnR
         n6QJH0LGhrRp++cT/507O83Ug2HUq1tTh20J0oNalyLrnPGhl8TSJKiAEw9e/DyLYSXR
         x19g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id be8si14332512plb.72.2019.03.25.12.49.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 12:49:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04392;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNeJ9A9_1553543363;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNeJ9A9_1553543363)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 26 Mar 2019 03:49:33 +0800
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
To: Keith Busch <kbusch@kernel.org>
Cc: mhocko@suse.com, mgorman@techsingularity.net, riel@surriel.com,
 hannes@cmpxchg.org, akpm@linux-foundation.org, dave.hansen@intel.com,
 keith.busch@intel.com, dan.j.williams@intel.com, fengguang.wu@intel.com,
 fan.du@intel.com, ying.huang@intel.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
 <20190324222040.GE31194@localhost.localdomain>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
Date: Mon, 25 Mar 2019 12:49:21 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190324222040.GE31194@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/24/19 3:20 PM, Keith Busch wrote:
> On Sat, Mar 23, 2019 at 12:44:31PM +0800, Yang Shi wrote:
>>   		/*
>> +		 * Demote DRAM pages regardless the mempolicy.
>> +		 * Demot anonymous pages only for now and skip MADV_FREE
>> +		 * pages.
>> +		 */
>> +		if (PageAnon(page) && !PageSwapCache(page) &&
>> +		    (node_isset(page_to_nid(page), def_alloc_nodemask)) &&
>> +		    PageSwapBacked(page)) {
>> +
>> +			if (has_nonram_online()) {
>> +				list_add(&page->lru, &demote_pages);
>> +				unlock_page(page);
>> +				continue;
>> +			}
>> +		}
>> +
>> +		/*
>>   		 * Anonymous process memory has backing store?
>>   		 * Try to allocate it some swap space here.
>>   		 * Lazyfree page could be freed directly
>> @@ -1477,6 +1507,25 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>   		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
>>   	}
>>   
>> +	/* Demote pages to PMEM */
>> +	if (!list_empty(&demote_pages)) {
>> +		int err, target_nid;
>> +		nodemask_t used_mask;
>> +
>> +		nodes_clear(used_mask);
>> +		target_nid = find_next_best_node(pgdat->node_id, &used_mask,
>> +						 true);
>> +
>> +		err = migrate_pages(&demote_pages, alloc_new_node_page, NULL,
>> +				    target_nid, MIGRATE_ASYNC, MR_DEMOTE);
>> +
>> +		if (err) {
>> +			putback_movable_pages(&demote_pages);
>> +
>> +			list_splice(&ret_pages, &demote_pages);
>> +		}
>> +	}
>> +
>>   	mem_cgroup_uncharge_list(&free_pages);
>>   	try_to_unmap_flush();
>>   	free_unref_page_list(&free_pages);
> How do these pages eventually get to swap when migration fails? Looks
> like that's skipped.

Yes, they will be just put back to LRU. Actually, I don't expect it 
would be very often to have migration fail at this stage (but I have no 
test data to support this hypothesis) since the pages have been isolated 
from LRU, so other reclaim path should not find them anymore.

If it is locked by someone else right before migration, it is likely 
referenced again, so putting back to LRU sounds not bad.

A potential improvement is to have sync migration for kswapd.

>
> And page cache demotion is useful too, we shouldn't consider only
> anonymous for this feature.

Yes, definitely. I'm looking into the page cache case now. Any 
suggestion is welcome.

Thanks,
Yang


