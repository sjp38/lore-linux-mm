Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB767C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 21:10:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 865AE2083B
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 21:10:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 865AE2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09BB86B0003; Thu,  1 Aug 2019 17:10:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 073956B0005; Thu,  1 Aug 2019 17:10:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECA7F6B0006; Thu,  1 Aug 2019 17:10:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B27C16B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 17:10:18 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n1so40274826plk.11
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 14:10:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=apKJ3lw3F5pljeh+RYLDWKCm1PCyFvCjUDneWAzUmR4=;
        b=E8azh+2ppGtXu+iEPBQgidLY3d5GQkcZMTQdBy8i0MdiwVWwka5KggZc7alLKMLJ0R
         FdvaD09bPZ/0M7AqfGpPUwWcDkoEhvfp8oPyEoBydMKLHTRxjwBaBTGnHXV02lFqLsD/
         w6x+v8oYhA4dxNDBJ+D++JaZIJ/64rRzqBbQ6peERVSPub8WJf2eTZPCj3hlrLCFg288
         VxlRf/44LHG8A59BGDp02m7NGfgtQnubpq0ZO5JWEtAYC7S9QSQ1zhJJq013r4QvSBoO
         97QMjiUteTMuT1bZAb0MQ+Rl4QorQDV15JSFYVu/J+gMxPR27//M5bKbf6v4q/EdoCRD
         zQ1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUb1li/uGv6JwbX+uEU9muvbSRlIiecohpFi6CJna7suDscSmAM
	38Ss+DUWMgoHk4tbeGdpt8TxRxs6mmyCB4De021vmYFPgGDnJxD/66UqskRYF4bQhmMJgI9n7hZ
	QZHaCPo3n5UI2NG0n+SaD0gQX/84sj50WUA+mXLISQogNXm6Sg0Al9NE0CbAWtfI/Pg==
X-Received: by 2002:a63:124a:: with SMTP id 10mr120432933pgs.254.1564693818202;
        Thu, 01 Aug 2019 14:10:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPudtiP9Vu/5z8Ll5PbqSxk68ATE8F/RHqcC0d1iMNm+/VxRT1f0BoWv0M88MQRG1mHQJA
X-Received: by 2002:a63:124a:: with SMTP id 10mr120432845pgs.254.1564693816935;
        Thu, 01 Aug 2019 14:10:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564693816; cv=none;
        d=google.com; s=arc-20160816;
        b=nT9wyLcsl4KR4hqbB0qNkHwFkpuh51mxQTGslP9AwN3u+6Ji1ZOz767/l9yT+9aO+Z
         5P2eCTcOqllebN8D9PJINImLUGaRhHbOCi5SdSL4j3vXgrjJGee9XDKY6FfHXvMGRDVL
         4Sa9P5Vk51PJt99jG62wxVvPLZuzCyDOO1XuB8ZEqr0M1NkE7yXWjCDoKy7d3WzOjiTk
         XfpNj5+9kyHkZuIx6JdEa7sf+RWyy2UfEIvOvdeGdHdQ9VpgsjT3eJuX4qMCEa9cwRaX
         sMYUBf4un4hjGUm5xu0TXRnu/ldvJblvwpJsr1Gaxznl3u/+lQEtPqPIH5N7Cj6ryMR1
         iIbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=apKJ3lw3F5pljeh+RYLDWKCm1PCyFvCjUDneWAzUmR4=;
        b=CoGYsOJtC/nHTckel8339ODsq4a9aEW6BAwEc56NJfm2KYOjLPg45iJ8OgbG7bsH1I
         a5nfYQNwyp19JRDWqNMW1XB4GgvatO/rk6XYpX2+5AQX0pcuIK3Ghcjid39DlPURQszr
         QuAefvL3kTlAyCzsUGtxLslu7VZd+QeCpu1VsgMUpds2zkhDTC2Do6jnsWUdJDtRrIM1
         yxUfjIDYT52kNWGIYGU9xuev+x3vh3AU1bmkWvACSwOWDawCkaXxvnOk++HXi0A8H2OF
         jsEuxwNx9Ep+8dDZ/9/FnCzN0J5zgTnXb1ROMTnz1yXVe2Xlcl8WhvL0tOu1BPZAPJoj
         FoeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id s13si39319489pfe.140.2019.08.01.14.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 14:10:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R761e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TYQEJnk_1564693809;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TYQEJnk_1564693809)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 02 Aug 2019 05:10:14 +0800
Subject: Re: [BUG]: mm/vmscan.c: shrink_slab does not work correctly with
 memcg disabled via commandline
To: Jan Hadrava <had@kam.mff.cuni.cz>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 wizards@kam.mff.cuni.cz, Kirill Tkhai <ktkhai@virtuozzo.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190801134250.scbfnjewahbt5zui@kam.mff.cuni.cz>
 <20190801140610.GM11627@dhcp22.suse.cz>
 <20190801155434.2dftso2wuggfuv7a@kam.mff.cuni.cz>
 <20190801163213.GO11627@dhcp22.suse.cz>
 <20190801174631.ulnlx3pi2g2rznzk@kam.mff.cuni.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <8db8ec82-5a66-a221-09f3-66d0b8b9a75f@linux.alibaba.com>
Date: Thu, 1 Aug 2019 14:10:05 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190801174631.ulnlx3pi2g2rznzk@kam.mff.cuni.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/1/19 10:46 AM, Jan Hadrava wrote:
> On Thu, Aug 01, 2019 at 06:32:13PM +0200, Michal Hocko wrote:
>> On Thu 01-08-19 17:54:34, Jan Hadrava wrote:
>>> Just to be sure, i run my tests and patch proposed in the original thread
>>> solves my issue in all four affected stable releases:
>> Cc Andrew.
> Are you sure? I can't see any change in e-mail headers.

Cc'ed Andrew.

>
>> I assume we can assume your Tested-by tag?
> Well, these test only checked, that bug is present without the patch
> and disappears after applying it. Anyway: I am ok with it.

Thanks for testing it. I think you ran into the similar pre-mature OOM 
issue as what Shakeel reported.

Andrew,

The patch has been in -mm tree 
(mm-vmscan-check-if-mem-cgroup-is-disabled-or-not-before-calling-memcg-slab-shrinker.patch), 
it seems we'd better to get this fix in the upcoming 5.3-rc so that it 
could get into stable release soon.

>
>

