Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CD8EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 03:41:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 280562075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 03:41:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 280562075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 964CE6B0003; Tue, 26 Mar 2019 23:41:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 914586B0006; Tue, 26 Mar 2019 23:41:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82A686B0007; Tue, 26 Mar 2019 23:41:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6D36B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 23:41:23 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x5so3481408pll.2
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 20:41:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=VdT375e6UgKXAkisZksuxeWeA1N2Js5PL7YlBEJx1aA=;
        b=qq9Bg/xp0N6sXfYqw/LJEeWR/mvOKqPBfmMwfSy7GOKcLb5dM/05+/D0JwKVX5aO72
         v8ktf/KfvHbynL12x2YIg/vioO/pgnj/neCQJvdwGpMwYG8y4VY8rTZLmrWh8jet7oZc
         1hAW8GDZWBsXCOAQs7dcsaMhxAM/GsTb3Ua6gsU33Me/tMHGwH8tmlBZza242z78O8U/
         ZQUueTPoaAsyaiygHLu2iVrT+XtMEmu/1yR4n9RZlX5D94m3TmtD1BU/haGhqOZI1Q7h
         8G7PZsHfNOPcEYPC4h/4fe7iyU1gP+jdZXxb3R4X8OJmojgFCAk9ZoBl2QQxQ3GS7x66
         eWEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWI2TF9BWBBex37S/3fcRfmKug7TBBBQSh4ysrbCVeiMgCJ9Vo6
	VAHyQhWtXfQtV+cK3ucjZURtlLL3sTY9k0kGLM91dyenqWJeMt5F27/f/Ek68jFVv891eKN60JL
	bguSwdwK0GqMVhdd4DAyAdOZLNm4Gq7GAXpHaCjrowjmqOphJ4nsB4gL3B5NsMyjklQ==
X-Received: by 2002:a62:e411:: with SMTP id r17mr33006963pfh.127.1553658082957;
        Tue, 26 Mar 2019 20:41:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybhGb6TsuZ18SQnQNoDLcQ5d6xsiIPSkYY5SvuhdlRXCqyIO4O8w/5KDRwNSRgQmKcKpZN
X-Received: by 2002:a62:e411:: with SMTP id r17mr33006918pfh.127.1553658082119;
        Tue, 26 Mar 2019 20:41:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553658082; cv=none;
        d=google.com; s=arc-20160816;
        b=QXXFOlwx3iwUJCTr7MhnKWRwlbRn5cT2dx8/mw4z9SjNSOTpewY1yvLe0HQgKagVvQ
         HolWT9ZmjwbsrCaTl/1SrwoBKrq8aU3ynOWE7xY6g9INaZNMqttfM59vVXRrX3jxhf5i
         JYM0OFKN5nCh9Uv99RHrm3q2pm0NoJjJ/RnNqiXvERcveZkdH7iyKgdePTYGKuLwUr7b
         oanNPS1EBXUEPLE8QrLZ0G80CdSNfJvWSmSoPrQCdXDL7UxCdKCQ1EN+Dhw9I4Jlr6Cq
         CjrgVTdycusw+GVz3Q8HyP8A5zM9727x9kB5GbxUD9BXE2UEA/1tHXM/VsnfXDBcx77K
         J9+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=VdT375e6UgKXAkisZksuxeWeA1N2Js5PL7YlBEJx1aA=;
        b=v5czRuxFwP11IAP8e1te8A4UXIRu8tUnJnnKIhX9G0WBCZSVecY+LrS+UBzw7jjQWW
         2jtklPZqqgeEabJvCxrJ9nRU0JR+fKtAAOwy6982JSzV6PypF81mtUWYVpe/Ze2H0GHK
         wES2UHU8XtAGA+40dbCDVh9LD6CWJr5lOtNHEPhaYbnfX/kDHCZfM4V/jIexAJ7GCHcS
         76vV9b43Dj5xlKLNBHSCDO8NBqlAcm7zSJ7S0YtRJ1sCbngFBEEIGMmvmV/RFdQqWi/g
         P4zykULQN43SLfpqLOcStSMSYRTAkW/lvrtfTORQ3bNoId3msNZOpMjUwCfb/q+hfSeV
         aSnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id a13si4846751pfn.70.2019.03.26.20.41.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 20:41:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04392;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNkXKFO_1553658075;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNkXKFO_1553658075)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 27 Mar 2019 11:41:19 +0800
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
 <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
 <20190327003541.GE4328@localhost.localdomain>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <39d8fb56-df60-9382-9b47-59081d823c3c@linux.alibaba.com>
Date: Tue, 26 Mar 2019 20:41:15 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190327003541.GE4328@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/26/19 5:35 PM, Keith Busch wrote:
> On Mon, Mar 25, 2019 at 12:49:21PM -0700, Yang Shi wrote:
>> On 3/24/19 3:20 PM, Keith Busch wrote:
>>> How do these pages eventually get to swap when migration fails? Looks
>>> like that's skipped.
>> Yes, they will be just put back to LRU. Actually, I don't expect it would be
>> very often to have migration fail at this stage (but I have no test data to
>> support this hypothesis) since the pages have been isolated from LRU, so
>> other reclaim path should not find them anymore.
>>
>> If it is locked by someone else right before migration, it is likely
>> referenced again, so putting back to LRU sounds not bad.
>>
>> A potential improvement is to have sync migration for kswapd.
> Well, it's not that migration fails only if the page is recently
> referenced. Migration would fail if there isn't available memory in
> the migration node, so this implementation carries an expectation that
> migration nodes have higher free capacity than source nodes. And since
> your attempting THP's without ever splitting them, that also requires
> lower fragmentation for a successful migration.

Yes, it is possible. However, migrate_pages() already has logic to 
handle such case. If the target node has not enough space for migrating 
THP in a whole, it would split THP then retry with base pages.

Swapping THP has been optimized to swap in a whole too. It would try to 
add THP into swap cache in a whole, split THP if the attempt fails, then 
add base pages into swap cache.

So, I think we can leave this to migrate_pages() without splitting in 
advance all the time.

Thanks,
Yang

>
> Applications, however, may allocate and pin pages directly out of that
> migration node to the point it does not have so much free capacity or
> physical continuity, so we probably shouldn't assume it's the only way
> to reclaim pages.

