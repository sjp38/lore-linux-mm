Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D02AC04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 16:07:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4447206E0
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 16:07:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4447206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52D6D6B0276; Tue, 28 May 2019 12:07:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DE316B0279; Tue, 28 May 2019 12:07:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CC446B027A; Tue, 28 May 2019 12:07:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id E83156B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 12:07:46 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id y2so503397lfh.23
        for <linux-mm@kvack.org>; Tue, 28 May 2019 09:07:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DG8xV0grffTiWUQ6ZgEKPJ31mVWlpo+pKVsQ5e9lS30=;
        b=VD52GKl4XvNJZHa9iKX0F75Sk5MAA+/B0Ui4E5NL3itdnhoSCZGoqLF+wFgx8z7Y3T
         vH0Q/ZqpWpJq+tviOzymdyVobKg94EVJnZUR72YWPqudrWhhNBJOHHrG77sVpqXYod3K
         x7bFyvNbxknuwHuOqqZE/dKERNCZ4cUgP2efY3dKegkFNMry0ozKQvJszxYGDBbC5Iyg
         YEWIYPf+ukSRxJAQQRb1/DA6NRSmgUftdSTCwRSk6oWkP+EZ42MJJiJSUTQwhA86xomZ
         yoeHZeX8icqeLd30JtR7zhenlkzy1E48bW9CrCAKLazSnPCZ+9EsEduNLpP65zKG3APS
         QCgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUBujeK8yGroeKRf1GJ6t18Y8J4OYy+GH6fi419SigESdQbr1gZ
	yjshXPR+iqdUnLAfjyws7Wm0TpjY/Fs9eXqaGr5syjOMI0MQFMqS/+EqHtD3mQvcwAIinb6ulDY
	JU1wF0U6VqnfC6ICbcZbnjTPfhbc8nnMVNiW8NAc8XdHyTemZExZ4tRkDey5tMxXlqg==
X-Received: by 2002:ac2:5383:: with SMTP id g3mr6086341lfh.107.1559059666218;
        Tue, 28 May 2019 09:07:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgT5z9Jn6zoPLG6GCcYtu2lDSLwVWQZcNVH/qvD2lkOs8Zj5IwfjzZ7JvOzd1tsgkjBqYV
X-Received: by 2002:ac2:5383:: with SMTP id g3mr6086302lfh.107.1559059665443;
        Tue, 28 May 2019 09:07:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559059665; cv=none;
        d=google.com; s=arc-20160816;
        b=ySIfJyInNix819jHdudOp7qEJz/wNyY8oBgNaHxXfie3wOqmhIN3rnPstYeREgsYep
         oAog0HBEfgIYvnspfdNcs9818Em+G4FT6L70bv+co5Is5KxLCMEs3BKCtm/POm7kaJ/z
         WbgW6UyKUWQYUY/ysYFqMz5OcyFSc1HV8wMpppR5fHP2Z/ZIP3OYKa6oF2Jpp7hzAWIp
         UaPMgFdZ2xAMAiX0BK++1VOMsOZbzKKZOKicGnUEneXf6ARnvF5rDjUKC1WK73ML0rXi
         mcTERSyrgr2Xm4abcGstW68LQxLlbLgmUr4YPklF3fKAxSpJ1ZxBNklU/qxoRBoObRk4
         KSAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DG8xV0grffTiWUQ6ZgEKPJ31mVWlpo+pKVsQ5e9lS30=;
        b=mEn4TJkExrCrWDyUcqtq/yk/iy+v4mZK10+rIgWXrpeyZL9Q7Itn0tgN4DanXH1G/0
         YMEKCHR+PrfNmMt447ZKBOEuCSdxYuqMHozNqE8H0yLZ2n4aQwC0pOJZWvrOEL/mO5HC
         GGe1KzWOInLndZ3x2NIgzkiW0qcmCXAZfb4dF4YzRsWo1Oa69sdD2Rdn9n9BFcYzzCnk
         20NIldyGmeiRrdS2JOz1dbVtRcXE/EaYhJnj8EdXrcaVnL5bOCNBRyDI7j2qKSH0r5ZT
         E5xQ24BjCn5/0USIe7a8VAdMXt3NMteNSUUMS649Mvvzp1/dCAcYFlvEeR4vxR4Ia7tj
         ybYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id i12si13101722lfo.62.2019.05.28.09.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 09:07:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hVedY-0005la-Dm; Tue, 28 May 2019 19:07:40 +0300
Subject: Re: [PATCH REBASED 1/4] mm: Move recent_rotated pages calculation to
 shrink_inactive_list()
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <155290113594.31489.16711525148390601318.stgit@localhost.localdomain>
 <155290127956.31489.3393586616054413298.stgit@localhost.localdomain>
 <20190528155134.GA14663@cmpxchg.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <3c081218-0dc9-54f2-839e-00adca089831@virtuozzo.com>
Date: Tue, 28 May 2019 19:07:40 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190528155134.GA14663@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.05.2019 18:51, Johannes Weiner wrote:
> On Mon, Mar 18, 2019 at 12:27:59PM +0300, Kirill Tkhai wrote:
>> @@ -1945,6 +1942,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>>  		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
>>  				   nr_reclaimed);
>>  	}
>> +	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
>> +	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
> 
> Surely this should be +=, right?
> 
> Otherwise we maintain essentially no history of page rotations and
> that wreaks havoc on the page cache vs. swapping reclaim balance.

Sure, thanks.

Kirill

