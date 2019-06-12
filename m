Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26763C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 05:08:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E31082086A
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 05:08:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E31082086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 774A46B0006; Wed, 12 Jun 2019 01:08:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 725916B0007; Wed, 12 Jun 2019 01:08:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EC076B0008; Wed, 12 Jun 2019 01:08:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 275576B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 01:08:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id c18so3652886pgk.2
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 22:08:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Fcnrgtqo2h+X/1l7XGoG+o8FiUT4B3aDue4uMd/DDBg=;
        b=DAI5fmz240Od/D1dvB73MjhSiRPfHnPDQSRgIIwhGcMrWQogW4H+FDg0YXTVNW1jmO
         wrawhCcMGUa3/DFw4ZSmLI6bNrO1+2ZzvZsf8OGR8180CRKmDa7KaiG4fDiBUxFChj+s
         SiU+CeeNKAI/00t3AiuEIdoL5N/S9bjcBw8NkxBLEUWqoHGa+FpUfk1OVDcyhLoJlwqH
         wk1WNNIaYjVhU4KLVR4YmMVVQDOhrroM9BxMkiqr+Ydn6oBGkqqmu0+RTKxqyLPW5qM3
         8I/29MiZw/XV/qdC21xmQoA/E+03QDvXTcyu86NauELF5UFg3HH+Rm6d6WsHaMSLEXu2
         0gkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWcXOhYH7utLuaNfjYUINpxdADqgjoPhu89GWR0X64gg7hSofnr
	2fSe8MQe6oK+RbHPlvNF0P8+cbNiBKb/TJRbugQsqlpXsMgOWsuqlxkwgbDuOM0xkxVzvorY8Q2
	3nxeHlMbnCeaKvmbb7WiDIgg7RFi6rpQGseb3ppTod0Bz8oBez/PdO/C/oKutb6KBFw==
X-Received: by 2002:a17:902:7d86:: with SMTP id a6mr55377301plm.199.1560316081772;
        Tue, 11 Jun 2019 22:08:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFx5eav1Ad17U4hTuB64wW3GtzDqWJT2+u907KCIIFArIvWKgYeV2Tu/XhXJOTcThP3Ba8
X-Received: by 2002:a17:902:7d86:: with SMTP id a6mr55377253plm.199.1560316081094;
        Tue, 11 Jun 2019 22:08:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560316081; cv=none;
        d=google.com; s=arc-20160816;
        b=lPBOd9hNs/GB1D/CfnN7iTBrmZcr53hpGrWZchF/GZY49qbhRZ20a8/pgd1lrSXttF
         kpKBTDfN9pOIrrF8Zd9XiSVIrUqpHI/xKLe8xRWj8Z48xQKSOu/WW6uXazfUEDYIS0kZ
         87nZH6O3Sj6IvwYLoBp7cf+FxzmDfzQtuy2zICuhm78PqqlD2ZUMgnmJCndEO5pQIFMI
         7iRT6rPRcrzzMkEAvRo098HoAXcl8LB79EElo3WyUm7+7HBJrKZaqLqn+/eoGTr1mVzw
         y0dopXIIreC0RVcr4SOVpf85t2HJ1KbqkF+Y5rNhRHAYQk+U6D1G6VnrMWYMK10TDZ5F
         qe/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Fcnrgtqo2h+X/1l7XGoG+o8FiUT4B3aDue4uMd/DDBg=;
        b=1Kstc4JYNXQRWAJiB1qENDuAes56nlEQpBgvljoRjqjTGef9fJsIrwDghlBaAvKCRq
         cub+JmuuGva4vCB6w9PEfH9W+GzkZUuLrP62HQPr6Mc+QBLF7iPBH9JwslAIJxIINyBY
         1cTUlQgTek3PutcH2tdpAabNDLHYrGA8ZOJRzKsoO9RuL65HBXpWoafBJ5dd4mGoL9o9
         qqlHhwGMVw9U7j9zaRuSM8A9BB8ad8g6qApEd44Kn3c5hVYZjJSQy6AP5OKcoph/45ih
         WQTXIDsQP5+OpdOSJR07lo5++o/Yi5HdWMKFZPx+vZcTfyLfsRAwElAPtcM/wcZyGAdF
         CGuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id g12si15101319pla.322.2019.06.11.22.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 22:08:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R961e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TTyCGal_1560316075;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTyCGal_1560316075)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 12 Jun 2019 13:07:58 +0800
Subject: Re: [PATCH 4/4] mm: shrinker: make shrinker not depend on memcg kmem
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559887659-23121-5-git-send-email-yang.shi@linux.alibaba.com>
 <20190612025257.7fv55qmx6p45hz7o@box>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <a8f6f119-fd72-9a93-de99-fc7bea6404c0@linux.alibaba.com>
Date: Tue, 11 Jun 2019 22:07:54 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190612025257.7fv55qmx6p45hz7o@box>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/11/19 7:52 PM, Kirill A. Shutemov wrote:
> On Fri, Jun 07, 2019 at 02:07:39PM +0800, Yang Shi wrote:
>> Currently shrinker is just allocated and can work when memcg kmem is
>> enabled.  But, THP deferred split shrinker is not slab shrinker, it
>> doesn't make too much sense to have such shrinker depend on memcg kmem.
>> It should be able to reclaim THP even though memcg kmem is disabled.
>>
>> Introduce a new shrinker flag, SHRINKER_NONSLAB, for non-slab shrinker,
>> i.e. THP deferred split shrinker.  When memcg kmem is disabled, just
>> such shrinkers can be called in shrinking memcg slab.
> Looks like it breaks bisectability. It has to be done before makeing
> shrinker memcg-aware, hasn't it?

No, it doesn't break bisectability. But, THP shrinker just can be called 
with kmem charge enabled without this patch.

>

