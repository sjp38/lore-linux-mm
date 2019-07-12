Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEE8DC742B0
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:11:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACD9821537
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:11:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACD9821537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DE738E012E; Fri, 12 Jul 2019 05:11:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28E718E00DB; Fri, 12 Jul 2019 05:11:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17F4E8E012E; Fri, 12 Jul 2019 05:11:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7B7A8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:11:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id t2so5357348pgs.21
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 02:11:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jcceaML/n0gsbJdlAi/GRuCQT0aw8Kc8cBnjHGwhfgQ=;
        b=OB74Ab0090e8NU1S4mIPzCE2/huLGmJrWtHKVRrhyCXe0E4XTP8nGSsMqwUH+uUQ8p
         CSB7uvj3/K+8yTmfS3O/23IcXzHYXjpxlXwFh7y5I6E991xS1j4gfx8rkyqu9Ppstr93
         YPNcRIczzR1DfK/ZryHsrEA1/bLibXly2+mb3uwW1OmCNkdVDjEclfz/R0XioDY6Ma73
         6sN58EJgdTg9MxAQ0TFXK7Q5Y1qmshqRuxIuMD8X9lPf3PVj+PzPFB2/PtIj9pRbGa94
         R41iNw2qU2pRh6oVgoOJh+ZG7C5YVUHwgR8xJKVxYNuU7ZfXnxoGSrTJ8GIiVPKnYhh6
         ggwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUgNTCg5jblYVlzgogSk5VQMgRPCEeLRdW1e1tnySskWZj/lo1d
	S2kJGORzlKHL/39VjJeE+pad+NqZhapUzFS2IT3zH9c+w/oj+Ls1tHCS92aWvDui7OEc5tJD3dq
	HeDXlUCAsmsf2XiM40LeGgRhm4NZEf6C7mJ4CG1rtrGNeDLVQ0CUq1/SyKpKqX+dzeA==
X-Received: by 2002:a63:eb56:: with SMTP id b22mr9614517pgk.355.1562922689503;
        Fri, 12 Jul 2019 02:11:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwM5gC1d3t+jVNV5y4OesN8M5Bk/5cZEx5u7xfzRTn5K2ZreG5KE21SNQxk1PNfWryl4VAq
X-Received: by 2002:a63:eb56:: with SMTP id b22mr9614462pgk.355.1562922688841;
        Fri, 12 Jul 2019 02:11:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562922688; cv=none;
        d=google.com; s=arc-20160816;
        b=AlQ6PGYN8CUfscOHXVXzmVmE0wrfJQR36NKQ4Z0y++WmF/HVWKqAC2rufkTCZr+Q0r
         /GWBvAkpUXFyu/GIT3TpnV1jkKYqneIoA6DOAxfBzZvgSxGKuvcLksDq9trfZcAdGNH+
         lQYuhRb/OX7AW39zBLmuGphPmDeY1QL0linoScA2kFI/yEVdHjNO9uvuyQbuG2K+Y7Eq
         /XgPzSUomHjxt57mN6naHMZIIVrNPru4WxRv9vYumOLjKhODDoE+Z8bS18Bm5YSgBM0L
         w3McWGb//dGMrqWT5n1FxQ6Nr+93RoVBmVp7EbkZkoNi3sWhjmnxkSTp5U2ZMJoaUmFB
         K5cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jcceaML/n0gsbJdlAi/GRuCQT0aw8Kc8cBnjHGwhfgQ=;
        b=gf8dWT/5vQtHt6K0ZzahK4M90e5CNPFyzK0Uj7yDjm9jleEGUsYbD23LnTOnK1w4tO
         62YztBxt0Ii1OpYFAIHIiQ8onCfjuoyF03qM9JaQqQD9EfpmbcfFxp7mdsT6BtGG8BAZ
         aulVsWRkZWw84munvNSf4l+Cg4hepnPVAO9bTmeC/mXJ3qv4sprpk4eatJNwJ23oBhos
         u9KyZzofAY/VtdqXA+DnzWXjjrdzqPrKmFmedv9+R3NRS0x6Yq7p6TnT5pB6Kmk9yuQ5
         tpLeFRRAAmwjGy6VQ8aNcZSWcsDexnUhw/H18zJNhzhqr9U1YQ4gZhQzY3iTX6mzxabK
         22zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id be3si6999858plb.383.2019.07.12.02.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 02:11:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R621e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TWh00oy_1562922685;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TWh00oy_1562922685)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 12 Jul 2019 17:11:25 +0800
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
 linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
 Mel Gorman <mgorman@suse.de>, riel@surriel.com
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
 <20190711134754.GD3402@hirez.programming.kicks-ass.net>
 <b027f9cc-edd2-840c-3829-176a1e298446@linux.alibaba.com>
 <20190712075815.GN3402@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <37474414-1a54-8e3a-60df-eb7e5e1cc1ed@linux.alibaba.com>
Date: Fri, 12 Jul 2019 17:11:25 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190712075815.GN3402@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/12 下午3:58, Peter Zijlstra wrote:
[snip]
>>>
>>> Then our task t1 should be accounted to B (as you do), but also to A and
>>> R.
>>
>> I get the point but not quite sure about this...
>>
>> Not like pages there are no hierarchical limitation on locality, also tasks
> 
> You can use cpusets to affect that.

Could you please give more detail on this?

> 
>> running in a particular group have no influence to others, not to mention the
>> extra overhead, does it really meaningful to account the stuff hierarchically?
> 
> AFAIU it's a requirement of cgroups to be hierarchical. All our other
> cgroup accounting is like that.

Ok, should respect the convention :-)

Regards,
Michael Wang

> 

