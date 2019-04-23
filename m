Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 488A4C282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:59:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F03B206A3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:59:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F03B206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E56C6B0003; Tue, 23 Apr 2019 05:59:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 794086B0006; Tue, 23 Apr 2019 05:59:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 683726B000D; Tue, 23 Apr 2019 05:59:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 314146B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:59:08 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a3so9390892pfi.17
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:59:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Q6xP0I+RTcPqJ7+TL2OuanZ0VrbXEza/5u6BxTe+2y4=;
        b=iL04thvy1zxFr3O77FTHC7bJT0CrBPjxg8IN3Nb4KptTok7gkhw59Ti1zm2UtSWzaf
         87mRvKXSDv49UqCKMf0hX5n2ya6T+L8hefZ0It2ZKCdU0cU9FdwP35lHjvxyXphtCfRL
         UIOiVB1Ty8POLBubYW2587Gq/B2Y1mereVv14GkCyPzXxX3qRvAAgB/7/mC8GlWOOH7G
         YHynOwGhYoUb8zsqrnaERlupuTSqoNvK8Wbs9q+JydPpm8qmbmWhd0ZTeml0N0AeyqYa
         fkr1DRqhuvVgGrHF8hWtYcTDMLHcYTtPsT8J/oVC1blAR37InM0CUJTw++laHyRjcohO
         RuOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVnOObcuhEDdZPjED7ZfelOtihbGeSHLDNOLh8HLOZjZvdegAUr
	PXjXUgTQvmqHIOviAOSJoMmnyEXYOVdpkTQO6c21EEoxvWnAXAhNYcc7yvgZTTH+PIS7IQ7zRLX
	iGeDLtglxxomGos2zL3vZR5ZnTaFR1+/t5xul8wJLFO6gQRnSeSM5Ti6LmrqIxOoXsg==
X-Received: by 2002:a17:902:4681:: with SMTP id p1mr24438549pld.42.1556013547277;
        Tue, 23 Apr 2019 02:59:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzM3nmBAHTeFJSrtD8YUp96tw6f6/JV2sAoKLVZFTOsFBBKC/1XQCBhizMwNUMrK+TLav0N
X-Received: by 2002:a17:902:4681:: with SMTP id p1mr24438493pld.42.1556013546510;
        Tue, 23 Apr 2019 02:59:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556013546; cv=none;
        d=google.com; s=arc-20160816;
        b=RupnCxoWfpLAkhEM3xqxG0/Uj7/5vZv6snM/QBdnZOWS/OMiicMlx2zoYYO0p9ldyM
         IKYbHeSObx9Z+cgIELB2C3aWLxfU0q8Rr27xK8wVlHgJE6yYCQFW69iJOkM9QQmWS1xP
         VnycN7O8xebDsDhpGM/2XxCU2ikuCYZo4SANnMJvaT58dKnTxNiAENJUNhcLflbyBZE9
         blI59rfQ7/UnosSg5xBWXZZ7jmzQY+/YRkl9PXlWcPyfsekTAsVyA9SsJ7zly7hH612S
         LL5S9Sj4bVWKsLlO59LCCnWbYWfJSlxlNqfURqjsnnVIkSYtTvchdGqLVKCpiqQ+91Fg
         ACJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Q6xP0I+RTcPqJ7+TL2OuanZ0VrbXEza/5u6BxTe+2y4=;
        b=nSju/9241x2SW68Lw2r9b1NQic93zdY1IN3jgqlmQxMZxzJ49sjiMC7Lvdm6QyoNS5
         JxFljdJu+YJMqG3lPYp5M296l5r5tvumkZkc6ozyBh+shWCNOZdVPx7fs/tgZ2Wyb08t
         t64gZRlF0pNYz7Ss6/kEmekge7Ew03VWDq0fQJHhKvwiR+9v+f3wLg+1ZKKs2hSVW3Ly
         9T6o5e4NN3gAKN3+ntsG4yMxuwm1d3IQ9caGa3OZhCpSh7MmueSn0cntW5yZQUvt4DOo
         5cvMQjvGe2LlCwgw1pUKtJXIEYOH0s2TZY1FiFWIrXoddQCVXVIK06wSpyz58pOYiNtA
         4pCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id y3si5513911pgy.134.2019.04.23.02.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 02:59:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R421e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ1iUpX_1556013542;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TQ1iUpX_1556013542)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 23 Apr 2019 17:59:03 +0800
Subject: Re: [RFC PATCH 5/5] numa: numa balancer
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <85bcd381-ef27-ddda-6069-1f1d80cf296a@linux.alibaba.com>
 <20190423090505.GG11158@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <9c431cd5-bb9c-8f58-5f67-643b5bd21dd6@linux.alibaba.com>
Date: Tue, 23 Apr 2019 17:59:02 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423090505.GG11158@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/4/23 下午5:05, Peter Zijlstra wrote:
[snip]
>>
>> TODO:
>>   * improve the logical to address the regression cases
>>   * Find a way, maybe, to handle the page cache left on remote
>>   * find more scenery which could gain benefit
>>
>> Signed-off-by: Michael Wang <yun.wang@linux.alibaba.com>
>> ---
>>  drivers/Makefile             |   1 +
>>  drivers/numa/Makefile        |   1 +
>>  drivers/numa/numa_balancer.c | 715 +++++++++++++++++++++++++++++++++++++++++++
> 
> So I really think this is the wrong direction. Why introduce yet another
> balancer thingy and not extend the existing numa balancer with the
> additional information you got from the previous patches?
> 
> Also, this really should not be a module and not in drivers
The reason why we present the idea in the way of a module is that
it's not suitable for all the situations, a module could be clean
and easier for deploy on demands.

Besides, we assume someone may prefer to have their own logical
on how to do the numa balancer, thus the module give them the way
to DIY easily.

But there are no insist on the style, once the logical is mature
enough, we can merge the idea into CFS, per-cgroup switch could be
enough :-P

Regards,
Michael Wang

> 

