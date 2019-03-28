Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27877C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 18:59:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9545C2173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 18:59:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9545C2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 207B76B026D; Thu, 28 Mar 2019 14:59:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E8586B026E; Thu, 28 Mar 2019 14:59:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CEDC6B026F; Thu, 28 Mar 2019 14:59:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8BF76B026D
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:59:08 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k185so10671854pga.5
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:59:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=1adDNexjjjpelc7IwKKEv8/QS8pCGJp6sA+YqsesiCU=;
        b=nOsALXzRm758xxt98aGQrnpTFSfqJLcnC09WZbX+8lgmxkVWwaSqRSbHmjISBUxWB1
         1itxwA5YxGiuQRTr+hHKeoAlMWcaK0LLykW2FHvZ/bRmsK0YVayCmaG6ZWqpq67DyWyb
         p23X7+yrMKm89c5nssdkaEg7JqeBu8qN8PZOBVZwJrafFPAMDln6PAg3R4h2Fc9M7X2G
         pW2wK6QQct4HMbkkjzdLb0JUPWyLH/1A1bgqXcwT6vsivCpru/M50+d0SOgsGd8Npvld
         IfhWNc20FGmbRUjlq0XKcH6n0yzpfcOJLDNj8kSo4thT+ffMA8aUX1aA+cDkl05vI+u+
         T7KA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUlik5iMdFBgePYS+zZczVFIUcHFW27P1fZAju7+SSyP5TC0cjf
	n/6w1h4G+EbzjqpO6qEt4U4uC0kLFpa3/24DgRxvdEQmOBfssnhyPhrFgEbRuKBovgwP2TMsZqe
	Mns+xX53g30UZjqRDrYfoJ6rO9l+UCQ0feIjNXEwkd/kMOk9CwbgGyXDARESUI6nimQ==
X-Received: by 2002:a17:902:9001:: with SMTP id a1mr14328721plp.96.1553799548448;
        Thu, 28 Mar 2019 11:59:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw41k9ITTkX9MQwvmKlSiS44XLSIqf4aWqhx3huHK4lNs8+NoWdvLgkSqSHRezCCYBvHG5q
X-Received: by 2002:a17:902:9001:: with SMTP id a1mr14328673plp.96.1553799547539;
        Thu, 28 Mar 2019 11:59:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553799547; cv=none;
        d=google.com; s=arc-20160816;
        b=qg6ZwQGy7dJHqw4U+ORg/aFh4VAFZm/nqR3yNsGONnfMi291WMX/au7bNwoPSItEhq
         1X3Gi9Fz457VK6EV7sE6NGUHdjvUXLznMduo0D5DjYF+XWqr/teFaL+hM5GbQSHnE1ME
         57ckyCmC78tvhh1OCe3AiStFX2/2xzn9SNHCai2q8ZVplGQ2F/6y1c99Xr+DuES3tGLT
         671N75AIHyECw32L7Sj3N2jkKHZwjZwBjExXmn0DXVi9db++A3alsOz87AEeAJm7nQu5
         Q5ZadPYn9shBzSaAKBQPYifdWPTX9ULNngvtGCf0btYRTan8j88jsOvENEGjoFvoRg3X
         YzhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1adDNexjjjpelc7IwKKEv8/QS8pCGJp6sA+YqsesiCU=;
        b=OE1JXwHQMebWflna3doD+dy7vJJ0msGPJ2x7m8ASnvGydBZGktNanZHjN3L2aoaJOg
         /0vx7JX2+ydcplLl8G3TenjtJPba97HYuZYtWpcNuO+G7xAxEJERQxSRlkQ4dS70mspi
         LJHvLiBxopxsXyY6V6LHQoeqH7mewDxTTDjClRPDUP/UN4aab3TKSzWBQI5t1/cnNUmz
         m0i/ZnfwBofozEP+uN4kcUSugb+yRwE4tddhjJ1BvC+7As68V+FSKwQQLNDctdySutje
         iiHtoT0mi17pjKFSoil0urAx9bDWfJopR5+fG3VoDsTWRpidobNbFx3ZAcQW1zfKV6A/
         yRuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id p90si13403169pfa.18.2019.03.28.11.59.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 11:59:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R281e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TNsklAz_1553799538;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNsklAz_1553799538)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 29 Mar 2019 02:59:04 +0800
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Michal Hocko <mhocko@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>,
 Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@surriel.com>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
 "Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz>
 <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz>
 <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz>
 <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
 <c3690a19-e2a6-7db7-b146-b08aa9b22854@linux.alibaba.com>
 <20190327193918.GP11927@dhcp22.suse.cz>
 <6f8b4c51-3f3c-16f9-ca2f-dbcd08ea23e6@linux.alibaba.com>
 <20190328065802.GQ11927@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6487e0f5-aee4-3fea-00f5-c12602b8ad2b@linux.alibaba.com>
Date: Thu, 28 Mar 2019 11:58:57 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190328065802.GQ11927@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/27/19 11:58 PM, Michal Hocko wrote:
> On Wed 27-03-19 19:09:10, Yang Shi wrote:
>> One question, when doing demote and promote we need define a path, for
>> example, DRAM <-> PMEM (assume two tier memory). When determining what nodes
>> are "DRAM" nodes, does it make sense to assume the nodes with both cpu and
>> memory are DRAM nodes since PMEM nodes are typically cpuless nodes?
> Do we really have to special case this for PMEM? Why cannot we simply go
> in the zonelist order? In other words why cannot we use the same logic
> for a larger NUMA machine and instead of swapping simply fallback to a
> less contended NUMA node? It can be a regular DRAM, PMEM or whatever
> other type of memory node.

Thanks for the suggestion. It makes sense. However, if we don't 
specialize a pmem node, its fallback node may be a DRAM node, then the 
memory reclaim may move the inactive page to the DRAM node, it sounds 
not make too much sense since memory reclaim would prefer to move 
downwards (DRAM -> PMEM -> Disk).

Yang


