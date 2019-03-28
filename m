Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88B27C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 02:09:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 454DC206C0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 02:09:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 454DC206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C03B36B0003; Wed, 27 Mar 2019 22:09:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8CCE6B0006; Wed, 27 Mar 2019 22:09:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A54446B0007; Wed, 27 Mar 2019 22:09:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA206B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 22:09:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d128so15345963pgc.8
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 19:09:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=OMTLa5Tx1CsKn9waJxBZ4nRZ3QlgPmvvZApjCAcqVB0=;
        b=CBzKCPd70HKoG8pS7Ol4xcFl/F9aUr01Z9d123eyvb1mR/FdU2VLfFq8O9V+5K40jK
         3zZHuJJIatxTCLcftMFCKurAZU4v9Dtibn+jNuvCFA84S7jwtq9OHyHslS9b8MBQkCto
         vhwKWxZah+Tcc1WfltZHteUmKB4qotLvNqeBpGQqQZIYfauerXXK/KSG1Km6jer/uLVa
         Nwmd4FLvoimA5cdzwcS+V8ZLBfwk6v50t6pC3eSl5yCxV0DAf7EWflj6we++PSFjGaVX
         q46F5wRinOSFLuiCjulmfpjP1EQvrekiYAJxN9hI18RdO2anWiAJSA2Ppv7R5FfvisX2
         BdSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUd9Pzbcv/ex36pBPO/rj7AEbHkTIkHB7qRvm+N+HlIqtjaqhAY
	TfS5gC9c20ghKSZTmnA55mJY6wr29CnPAGg2SWWJ51cn8htv2TCLfsddX/K58ItIv3y1Hom7Txa
	3BgLE8dpcq4fQsgWR+pgiJX6XATijQH++fQEFtz/q36NN3D7zwFTQgcdrwjXBErjYZg==
X-Received: by 2002:a63:88c3:: with SMTP id l186mr37936601pgd.148.1553738961003;
        Wed, 27 Mar 2019 19:09:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1j0b7U2bVA9a4WU05kUXFREbZ/Fq3uV8Vve8LwoFIXU3lg7F57PGiJ4X3QGwItTcRJ/mQ
X-Received: by 2002:a63:88c3:: with SMTP id l186mr37936542pgd.148.1553738960048;
        Wed, 27 Mar 2019 19:09:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553738960; cv=none;
        d=google.com; s=arc-20160816;
        b=e8vP7Y59yT0DjiYjJqINfCgbju3HWWqiHowdyJEPjp8XsPlVf8RbX7c5QFj++XeVXr
         7jtrcqv5yrs2G5+136DXGWkntSNSLASl5BefuZWkdy77WD73L1XAKofeNUS580tLaizw
         QS828359oF2xUY+15z/Stqn2n5OzJ0h9x5EgYE+9iRH15fe3x1nUVbJJZEvqU514sdlH
         a/l6IA3wn0WnjF3XHT/94ETz4fbwvSH5Mx+ldT3E9GOtsWEWDY7WPi2rXKDA0tPjnPM9
         brQXFwK1S4Y4kPJ5sXFO+2S3jEa10zXTWG0HAR+2xMi/Av4NX6zmCw0k7sa4Jj+uy1z7
         xa0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=OMTLa5Tx1CsKn9waJxBZ4nRZ3QlgPmvvZApjCAcqVB0=;
        b=d2nvMUUBfeplsVYK7Mc208AyQqWs2Txitcjnf0ERPW7Ei3mL2I77G9BaW3dAaU+fFh
         dPvP3KVBoA+6V9rGnVMvVVpJYLJb08yCQnvdlaB+bJL91oCqE2CTdNcxH3d50tMukuYY
         Sv7dWOnOalc8mm8Buf3pSJ26p3Obp+fLCnBe+IAoPFXnS9mHkhl9inDal96LymLcq2KW
         oAeelypPTgryZCmTrrsf/LSeK32NF9bRJNrHpcxWsqRSWRb5iw+mJ9dhJ5+ePQMe4UnL
         g9uURK0cur8bYHgWD0xxzhCyRlAodkKxDfFE3nAoG8WeR1E6ohjG0wQDqDOtUowheHkf
         vWHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id v131si17813885pgb.452.2019.03.27.19.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 19:09:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TNol2eC_1553738950;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNol2eC_1553738950)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 28 Mar 2019 10:09:17 +0800
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
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6f8b4c51-3f3c-16f9-ca2f-dbcd08ea23e6@linux.alibaba.com>
Date: Wed, 27 Mar 2019 19:09:10 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190327193918.GP11927@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/27/19 1:09 PM, Michal Hocko wrote:
> On Wed 27-03-19 11:59:28, Yang Shi wrote:
>>
>> On 3/27/19 10:34 AM, Dan Williams wrote:
>>> On Wed, Mar 27, 2019 at 2:01 AM Michal Hocko <mhocko@kernel.org> wrote:
>>>> On Tue 26-03-19 19:58:56, Yang Shi wrote:
> [...]
>>>>> It is still NUMA, users still can see all the NUMA nodes.
>>>> No, Linux NUMA implementation makes all numa nodes available by default
>>>> and provides an API to opt-in for more fine tuning. What you are
>>>> suggesting goes against that semantic and I am asking why. How is pmem
>>>> NUMA node any different from any any other distant node in principle?
>>> Agree. It's just another NUMA node and shouldn't be special cased.
>>> Userspace policy can choose to avoid it, but typical node distance
>>> preference should otherwise let the kernel fall back to it as
>>> additional memory pressure relief for "near" memory.
>> In ideal case, yes, I agree. However, in real life world the performance is
>> a concern. It is well-known that PMEM (not considering NVDIMM-F or HBM) has
>> higher latency and lower bandwidth. We observed much higher latency on PMEM
>> than DRAM with multi threads.
> One rule of thumb is: Do not design user visible interfaces based on the
> contemporary technology and its up/down sides. This will almost always
> fire back.

Thanks. It does make sense to me.

>
> Btw. if you keep arguing about performance without any numbers. Can you
> present something specific?

Yes, I did have some numbers. We did simple memory sequential rw latency 
test with a designed-in-house test program on PMEM (bind to PMEM) and 
DRAM (bind to DRAM). When running with 20 threads the result is as below:

              Threads          w/lat            r/lat
PMEM      20                537.15         68.06
DRAM      20                14.19           6.47

And, sysbench test with command: sysbench --time=600 memory 
--memory-block-size=8G --memory-total-size=1024T --memory-scope=global 
--memory-oper=read --memory-access-mode=rnd --rand-type=gaussian 
--rand-pareto-h=0.1 --threads=1 run

The result is:
                    lat/ms
PMEM      103766.09
DRAM      31946.30

>
>> In real production environment we don't know what kind of applications would
>> end up on PMEM (DRAM may be full, allocation fall back to PMEM) then have
>> unexpected performance degradation. I understand to have mempolicy to choose
>> to avoid it. But, there might be hundreds or thousands of applications
>> running on the machine, it sounds not that feasible to me to have each
>> single application set mempolicy to avoid it.
> we have cpuset cgroup controller to help here.
>
>> So, I think we still need a default allocation node mask. The default value
>> may include all nodes or just DRAM nodes. But, they should be able to be
>> override by user globally, not only per process basis.
>>
>> Due to the performance disparity, currently our usecases treat PMEM as
>> second tier memory for demoting cold page or binding to not memory access
>> sensitive applications (this is the reason for inventing a new mempolicy)
>> although it is a NUMA node.
> If the performance sucks that badly then do not use the pmem as NUMA,
> really. There are certainly other ways to export the pmem storage. Use
> it as a fast swap storage. Or try to work on a swap caching mechanism
> that still allows much faster access than a slow swap storage. But do
> not try to pretend to abuse the NUMA interface while you are breaking
> some of its long term established semantics.

Yes, we are looking into using it as a fast swap storage too and perhaps 
other usecases.

Anyway, though nobody thought it makes sense to restrict default 
allocation nodes, it sounds over-engineered. I'm going to drop it.

One question, when doing demote and promote we need define a path, for 
example, DRAM <-> PMEM (assume two tier memory). When determining what 
nodes are "DRAM" nodes, does it make sense to assume the nodes with both 
cpu and memory are DRAM nodes since PMEM nodes are typically cpuless nodes?

Thanks,
Yang


