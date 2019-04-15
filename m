Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C9B9C282DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:23:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6540420854
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:23:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6540420854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE18A6B0005; Mon, 15 Apr 2019 18:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E94996B0006; Mon, 15 Apr 2019 18:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D82C26B0007; Mon, 15 Apr 2019 18:23:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A28086B0005
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 18:23:54 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y2so12732565pfn.13
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 15:23:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=U8TY3oMt0a59WVcz9zJoEZ3/Cn5RPbJTBJxZwWbASXM=;
        b=iFHoFsx6zUztte2CO5yUm1viL/vUGXHENVPhotUIxx3/8NOrfw2pADwSIHLc+ZZ0Mk
         6oZPs+KlbBw0OSZZbhznXORXbKMQ6zSuinHFSkdji3cKik+wyR4RH0VlR8Ge+ecPtbIQ
         C3XjRN+wG3ka4MKvm3/C040PUUMUaFOcqlpffY0EgD+JhPyHmwRwivkHtohqltwCaz+7
         MWOZgTeGHKBZ0ioqxQyoBGqrDz9qocmlTLyz24FpltMuoG1a1HejmJs67nRrjFk6vslg
         2aNMgPTHY84UsXk3z1ET4HmtO4kQ96Df0gbHl5h/NvloN1u6T5o5cvJwA+BW6aCDEfXO
         efVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUs8dUUsOGnuII+0HlkW7JNqWhp8YRRTD6OifeYQTfuL+vD6Wmp
	O5ayFr1ybkgz7OZY8m89R2XO5COxXt98x6A6zT9tomkfomzI/Y8tj1xzeM/WsL6N/4OXGFWmWeW
	01Ik/+VRiaHpIXyJB1W9N7Ug3tWOXJkjq50A31M9/zFrHW5deZx/nEkSPSNlQlc+VEg==
X-Received: by 2002:a17:902:2aeb:: with SMTP id j98mr11473250plb.38.1555367034335;
        Mon, 15 Apr 2019 15:23:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhq6Q3T5zz+r/mf17HQ3mJk0DEF+GVuaRrNNdmgibnlXYjxKUPLWsLa2L1Dc+pqT1cruPD
X-Received: by 2002:a17:902:2aeb:: with SMTP id j98mr11473203plb.38.1555367033719;
        Mon, 15 Apr 2019 15:23:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555367033; cv=none;
        d=google.com; s=arc-20160816;
        b=XvEGuSYsE+0s+kHvWHsuHjHqNR0QWm2D14xYOATspaGG+GkOuLhRCeSP/Z4A/vLEU3
         C/G+MN7p9k6Ms2WqIdDkBCp89EDhFjvfzChcHLdttTWmXV9qEgbyi768r4qDokyw8t76
         6E8kJeU0CVyDTOb7g0+vzTAkUXe3c12vY6QjK5IoKo83lhJ8X5uLBL8zDr395MhggZhe
         fEpsxMrJapTARaXh5vtEnTO9PJZMpLwB/4oLBs13UgYHl91tVCa1xlMe+eNd56frs0Rc
         vlv8CRigXOuk8qcUP7nFn1Sw5dfDDVk9bJFtYkww7wrPHh1Kxc4K9YmgQvO1iOOBLNLx
         g75A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=U8TY3oMt0a59WVcz9zJoEZ3/Cn5RPbJTBJxZwWbASXM=;
        b=OGFLuL5OXJDTrn0fHEh6f8NJjwC38LzPc/jmPAb1yKckorKzjGQ9K17a/tElLe/u9K
         F1c0GKp5lI3p0KyupTa4qeSb0WhEsNCGlqRZ1lvR8Kx+baH7KCHlTVqpfCPOetnJCjKo
         fqO/Xo6UJ+RVcdrvOqLo0StpB8I2kMMDWtwSEI+9oHcdLxOx2CygWvi4nGu4lk8BaHRU
         MsvKqoelePf5aUv5lDF7KAoT2LQc5hwSMzX36X8khJgmc9eNp/Zw6Lg8K5Hy6IPmWSMs
         tQDG/h3A5VN+JT6klXqhvkBBU8PjQjBMnsnCP4fhkWoD4Th1t0+UkrjwuIig4uJM+4SJ
         6EdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id k9si45044293pgb.532.2019.04.15.15.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 15:23:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPPkBEu_1555367013;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPPkBEu_1555367013)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Apr 2019 06:23:36 +0800
Subject: Re: [v2 PATCH 7/9] mm: vmscan: check if the demote target node is
 contended or not
To: Dave Hansen <dave.hansen@intel.com>, mhocko@suse.com,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <1554955019-29472-8-git-send-email-yang.shi@linux.alibaba.com>
 <6d40d60e-dde4-7d70-c7a8-1a444c70c3ff@intel.com>
 <5082655c-6a24-a3d7-1b7d-bb256597890c@linux.alibaba.com>
 <9bcf765c-c051-9086-b3fe-679adbe239cb@intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <1b317d9a-406f-78c4-c2dd-d4c41eef8cc6@linux.alibaba.com>
Date: Mon, 15 Apr 2019 15:23:28 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <9bcf765c-c051-9086-b3fe-679adbe239cb@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/15/19 3:13 PM, Dave Hansen wrote:
> On 4/15/19 3:06 PM, Yang Shi wrote:
>>> This seems like an actively bad idea to me.
>>>
>>> Why do we need an *active* note to say the node is contended?  Why isn't
>>> just getting a failure back from migrate_pages() enough?  Have you
>>> observed this in practice?
>> The flag will be used to check if the target node is contended or not
>> before moving the page into the demotion list. If the target node is
>> contended (i.e. GFP_NOWAIT would likely fail), the page reclaim code
>> even won't scan anonymous page list on swapless system.
> That seems like the actual problem that needs to get fixed.
>
> On systems where we have demotions available, perhaps we need to start
> scanning anonymous pages again, at least for zones where we *can* demote
> from them.

But the problem is if we know the demotion would likely fail, why bother 
scanning anonymous pages again? The flag will be cleared by the target 
node's kswapd once it gets balanced again. Then the anonymous pages 
would get scanned next time.


