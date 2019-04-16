Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2751AC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:59:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0DA42173C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:59:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0DA42173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 408A46B0003; Tue, 16 Apr 2019 17:59:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3929C6B0006; Tue, 16 Apr 2019 17:59:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 235886B0007; Tue, 16 Apr 2019 17:59:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D478E6B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 17:59:19 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y10so14164746pll.14
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:59:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=xGQBUfRiIrm8nMo7bFfbSdzq1yF9X35BP39f6/YJ2p0=;
        b=LForcQEGUIMikMoSIrZRrwcsE9ZdXr3zVNXcSf2PsCrGCAXF7sqpoH+QUKCHIjDUp6
         heGNF79RxV7um3CKfEXomqoub33gTqDr165GwK6rEiJe2VIdF+5AtbnMtoLKB5VSw3ri
         vWbBWinHqdgAWuYVkDLtAmFJxBYncUgENleqIeEQm/w8N4msp3czBmWOC2ZmYPfDWS5d
         oF8nE+WVLzgNLm18/zYy/5IJFLntrlMIMMT46RKG0gxqWRSOJZSshHEVhjME4OpbppkZ
         4fgnr4OCxL2wIIwf6LwrP8gVT4XjiL7ZO+4IZcPfobY5nMM3VXTWyufc30qYzYbarsx6
         fEHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVagnQazfBaQfGXQXWHHIdIf2yW+iJOyHHtKZffWy+mCd771QGf
	zKN+Jb7uJP1GEomVO/YIKAF9fErYce1yCLfWAAKUjK0Pzc35k52DSH1sOK+v9V4oU5MF9uDD1/s
	dxtSxgDBrOI7FCi+WoUM0X0lf1AjQJsYQIt87rnVnLJThnVq5gy+ak7L+iziuMHsraQ==
X-Received: by 2002:a17:902:b713:: with SMTP id d19mr85667971pls.54.1555451959546;
        Tue, 16 Apr 2019 14:59:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrq+gO5bHZgQMVFcjPKIY5XNtsOFySFnef1NLfuZ2vSgDRg0ST8MENYwDRtDHEtxLXMqFz
X-Received: by 2002:a17:902:b713:: with SMTP id d19mr85667898pls.54.1555451958668;
        Tue, 16 Apr 2019 14:59:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555451958; cv=none;
        d=google.com; s=arc-20160816;
        b=fyZCCq1DaT3Y0iBkNUhu1IlfF71CgTdctruZFVDjROenDLcWeKgxzmHOAETnilE1Lf
         ElVHMNQL1SBw9UZm0FdKe5H2bDaPA83Fw0ho5hyYSLLaDDDMTS4ZImDQ+Y9V2EupAkfr
         1Pazb3w5A8vcbmcvMVzACy1kSt2c1F/R0NyUQs+lKoFGLfJV7NRrg0YU7CwDl/jT3u+K
         IT+SImD7Qzsj5Sl6lShNUJWkpxVlMpOuanKNY95xPY7GBL8UvarqPmAyYVBRGK6/0kAn
         nP9zqnTXvZrVsu+ATr8MsgUNNfRuAyf6OuT5qzMMzWtG0kctaTXInnzzY1Sq/bFLq+uI
         mR3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xGQBUfRiIrm8nMo7bFfbSdzq1yF9X35BP39f6/YJ2p0=;
        b=m20lDQeMuFcYrWTR1yX9rg20hDiPV5cwf8E0vgUJZ2uVU4OR8SDQg2ADCgJfiPQfcc
         abPuFwUrhsBHs0Rq0xMJKdu/lG31E2OBSx/4FHIPKzx+0BhGAQ6kEfYYgpgb0Kbl+7NZ
         0lXgcH1KfECQ9JYaMv8MTGExQ7Nn9hsNVbBrKVjGX16zjeYq+Pk0oA7c7KESXJgj9dSR
         znG9sjnVCK34SXteWXGICtl3FCvXyiFoNrFiZEj3wD6S3R6EFbSE6r0DnsMF7vqYHvCg
         Z3cX8ZbP4ZRfCTHIgCNq9sTJ6/1MDZQGxwE/wP6ix+a62cMrS6DpPEqIOMJj7zqXadEP
         QlvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id o82si40788117pfi.114.2019.04.16.14.59.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 14:59:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPUpGFx_1555451951;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPUpGFx_1555451951)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 17 Apr 2019 05:59:15 +0800
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <99320338-d9d3-74ca-5b07-6c3ca718800f@linux.alibaba.com>
Date: Tue, 16 Apr 2019 14:59:10 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/16/19 2:22 PM, Dave Hansen wrote:
> On 4/16/19 12:19 PM, Yang Shi wrote:
>> would we prefer to try all the nodes in the fallback order to find the
>> first less contended one (i.e. DRAM0 -> PMEM0 -> DRAM1 -> PMEM1 -> Swap)?
> Once a page went to DRAM1, how would we tell that it originated in DRAM0
> and is following the DRAM0 path rather than the DRAM1 path?
>
> Memory on DRAM0's path would be:
>
> 	DRAM0 -> PMEM0 -> DRAM1 -> PMEM1 -> Swap
>
> Memory on DRAM1's path would be:
>
> 	DRAM1 -> PMEM1 -> DRAM0 -> PMEM0 -> Swap
>
> Keith Busch had a set of patches to let you specify the demotion order
> via sysfs for fun.  The rules we came up with were:
> 1. Pages keep no history of where they have been
> 2. Each node can only demote to one other node

Does this mean any remote node? Or just DRAM to PMEM, but remote PMEM 
might be ok?

> 3. The demotion path can not have cycles

I agree with these rules, actually my implementation does imply the 
similar rule. I tried to understand what Michal means. My current 
implementation expects to have demotion happen from the initiator to the 
target in the same local pair. But, Michal may expect to be able to 
demote to remote initiator or target if the local target is contended.

IMHO, demotion in the local pair makes things much simpler.

>
> That ensures that we *can't* follow the paths you described above, if we
> follow those rules...

Yes, it might create a circle.


