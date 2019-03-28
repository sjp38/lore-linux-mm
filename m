Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DDE0C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:59:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E72CC2075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:59:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E72CC2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 883DA6B0275; Thu, 28 Mar 2019 17:59:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85BBF6B027B; Thu, 28 Mar 2019 17:59:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 771C96B027C; Thu, 28 Mar 2019 17:59:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38C4B6B0275
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:59:38 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o4so159218pgl.6
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:59:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=DvN6rDzQNmvctrhrTQUKXRJtzBmGU5qKF4NmO7TPc9o=;
        b=lEfDsryhSXXnkGd0S1wHMvSK2dQGZgiwLkC8vUcED4GWzZNOQNcw01rdwqJjWvYkqM
         AUwmIOtBY1vJi+0v9p6uQsHcTB7UzG3oOxiVLYmmxFpy0WQ+af7zMZ8tXFe2Fpufn1qu
         pvYeru2zYW864Mjf/0KSNb+aUZUf5YVqwaGY0Lu3XN4ARSeP0yoANHsjpNun+gJ3s/Xj
         c/dWwlNf92SDztb+dJwZX4/kGmrFOQSEQiOgWWgsoaAUiZzGrRbBaobuVmg7UxmZyktT
         K+v8vnTG9niYtXCpARLR+y29VyAaC6P6NvXCBKAr10QIV190clU4rI9dfV/ih02NoJ50
         hAkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWYrCHBbIg3uVSTNpOKvFzEO8U//uM5oB62cURaaG0FIap2fdSZ
	qWD9+E/Tgck5Qqzz0kmixoK2TGqBLH8ECZJGT9xmAoznyiFgV4zQZSYrEEKheK5LYG0IkqFvYJK
	rzJ4bGPoM3Jof8auZfQ2dC35XjFMkAu/aRIR3ykzEWNgVHvlmI8BWJd/4582izHkMVg==
X-Received: by 2002:a17:902:7587:: with SMTP id j7mr26697872pll.304.1553810377895;
        Thu, 28 Mar 2019 14:59:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8KbBxN63+UE/OG3/r06iGJXK3EkfjuA9MUTLfzxC7ru4dbzifveHN6KYEQQb76rT0pGTn
X-Received: by 2002:a17:902:7587:: with SMTP id j7mr26697837pll.304.1553810377124;
        Thu, 28 Mar 2019 14:59:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553810377; cv=none;
        d=google.com; s=arc-20160816;
        b=RCNTPo4UxypujLaRggSrR3DE+IPXNl2grKu6BVkBNVdFydZjU7kgTOAAUrBPGvRXEn
         Q6GaO1VIQ9Inw3K0LryEb5AgZBOS3TZ7/qOPwbF5cAS0qmNAM5oeOnNPWBxhf8iWMvYn
         0uK+dxGY4FEZkRTmdO0ny3y/LzGWIwK0FKZKKHbUKimi+iOLIsz7NtQ8EQFIsQFK2IWU
         j2S055nRihZoOKyJl6SHbrFcNYQI+wNR8JSpBOeVFyr+/HqDhxcmSWxqV410Ru1poSrp
         y+ImyUCv2qezlJqmEw2Oh3nME+WlXuioVFj8vqmu7ys2fYKcfhux9D/t/K7arXCeglDg
         offg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DvN6rDzQNmvctrhrTQUKXRJtzBmGU5qKF4NmO7TPc9o=;
        b=STgxCQ03NUIORnZPCaILgeCXsf5V2X0W9HD50wRDpzAod0XQSDTHg88Pv9vsnrU9eS
         ui/Rrwa5TOnwoiMqGbmx9OvaOyLoeGOivCOCgWKlUQlGfcp7jAZ6RDbK0qmQMEd/gHI/
         ePB3Jjzo3dGSzGWRpeN6zx+k6yuYGvf6f8moU+4J8DYqwKUzOo4GxEAO1+3fBCtZDXh9
         OM9LDRc1O2qdel5I75gGzhF4C1bMkI3ZwL7+yacgseCBrhk+Z93vrY+ENsBWrXpVFxUR
         dzbuuf8qjoU7WIuBHQjRI+jlTOKnwjP1R86zCeBZxt0hLspdVPk6t/N8+v5Fubmz/GCM
         fUpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id az7si243901plb.21.2019.03.28.14.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 14:59:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R611e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04452;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNtCAaw_1553810371;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNtCAaw_1553810371)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 29 Mar 2019 05:59:35 +0800
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
To: Keith Busch <kbusch@kernel.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>,
 "mgorman@techsingularity.net" <mgorman@techsingularity.net>,
 "riel@surriel.com" <riel@surriel.com>,
 "hannes@cmpxchg.org" <hannes@cmpxchg.org>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "Hansen, Dave" <dave.hansen@intel.com>, "Busch, Keith"
 <keith.busch@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>,
 "Wu, Fengguang" <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
 "Huang, Ying" <ying.huang@intel.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
 <20190324222040.GE31194@localhost.localdomain>
 <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
 <20190327003541.GE4328@localhost.localdomain>
 <39d8fb56-df60-9382-9b47-59081d823c3c@linux.alibaba.com>
 <20190327130822.GD7389@localhost.localdomain>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <599849e6-05b6-1e4d-7578-5cf8825963d2@linux.alibaba.com>
Date: Thu, 28 Mar 2019 14:59:30 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190327130822.GD7389@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/27/19 6:08 AM, Keith Busch wrote:
> On Tue, Mar 26, 2019 at 08:41:15PM -0700, Yang Shi wrote:
>> On 3/26/19 5:35 PM, Keith Busch wrote:
>>> migration nodes have higher free capacity than source nodes. And since
>>> your attempting THP's without ever splitting them, that also requires
>>> lower fragmentation for a successful migration.
>> Yes, it is possible. However, migrate_pages() already has logic to
>> handle such case. If the target node has not enough space for migrating
>> THP in a whole, it would split THP then retry with base pages.
> Oh, you're right, my mistake on splitting. So you have a good best effort
> migrate, but I still think it can fail for legitimate reasons that should
> have a swap fallback.

Yes, it still could fail. I can't tell which way is better for now. I 
just thought scanning another round then migrating should be still 
faster than swapping off the top of my head.

Thanks,
Yang


