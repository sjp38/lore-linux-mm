Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C52BC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:24:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA73D206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:24:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA73D206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 657226B0005; Thu, 18 Apr 2019 12:24:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 607846B0006; Thu, 18 Apr 2019 12:24:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F78B6B0007; Thu, 18 Apr 2019 12:24:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 177AC6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:24:44 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e12so1659573pgh.2
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:24:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=vkp8/nosqCBb5BPnvaBjttnZMMkTP5Cb5apy9+F143E=;
        b=mEkxnyDSg97t4OKitnaYsJAYlJdV6uhHH7jYh5G0uf+AC2dDsVwfoYXlv0UhNfvLf/
         jVVe/5lGsVkLBLXOn83HvF4HuEWifL4a2vqbdZ0b/F6fXqd+TPknMx/hVE0V8H0bnaJK
         4UaFQxiJso2sKCMGGHES1bbhSwp8YuWraO4X8IqDx4VOkiYD9X/GyWa3HBYD207HwZ7T
         53E9/Xp/fsZ4cmtSdI0y1Jzg6OhUL4U2a+OD52KENO4hIz3L8i4uQEVALR7a8e9WESZK
         bDSVanHb7Tj3i4obJKB6jKrYhx3DiVPacOXx/YnnHCX/l1YGS/t882gWOW5uC+kNF1TP
         PMqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUizt8dmvURkwX0AhOdZR1kP6ewJY6GMXfnoLfy5zojTTFwxu65
	PI6f9NI5hCBgVG2app1XJMHshQNAxIuSXZe/Zsy59mrBuYbX94s0OUuzepof+1RgUL+367XcAlG
	fnqUcnQGEMxbQ8Hub+/Uc38hHYMBTZEnmNNUkLC5gzcOUdb8SeauxOQw0VlKz1tweIA==
X-Received: by 2002:aa7:8252:: with SMTP id e18mr96078812pfn.105.1555604683650;
        Thu, 18 Apr 2019 09:24:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHI6x3pX8/Dh5V/c+u/oi0pJXAu2VpvwHM334GowYfLXnpO2VHfgp1niMckyU/u0hXMhtS
X-Received: by 2002:aa7:8252:: with SMTP id e18mr96078709pfn.105.1555604682548;
        Thu, 18 Apr 2019 09:24:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555604682; cv=none;
        d=google.com; s=arc-20160816;
        b=lzjiU2/vAckeVh6khyyYfpY0C7RGtbpotibkYfXo9V1cF1tnOHiqYFSWm1bjdxq9Xx
         vtaql6VF1naYu9xLkkYZU83m5pwzHqx3wbKdWnKwlL6G3x3akzfNzBg3demzUz360BzA
         LaShY+lVql5YRJpj34nnr+S1NYRb5zjjlWTeACwx8Q53oa8XyHaTsQ6ppVqYpHaC73a2
         jOwZ7hbZKPE8S0ZKmCT5ThhoZiQ1L7B37jWYHoQd/T/g/FGa/KbM5s/nicxsfMhd/O3Q
         YgCOCCpPqWtG2/u3woEHQC1QE59IuEQTMp4pjIwkRXJ+VHwJ8QD3ed11LrHsjgY7r59s
         wDUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=vkp8/nosqCBb5BPnvaBjttnZMMkTP5Cb5apy9+F143E=;
        b=n+ysK19h1iO+Kwm9b0YV3na0rFx5JFh3xRCVMT2LKUtnKGGt/Etyn/DIiTskuGtWb4
         we5klz/uCPsTKKFNTByOb6+KrEaQ7c3Z7KXcH6AdnVMOrWY1KPqNOposkdUelYJuj9wk
         t9RrwtyU4T7UJacQ29+VreKXW58sqbIpn+yQOu7x4xs8VQxxf8C1JZ6RWL+e16R1+52t
         CLexo799oWF+eBxGRZyRNdFgIDgByM2TEEOW30PI5XKFMXck9uSVUFphMq/wRZdfrQaR
         AqHP6vj37ebXXeD04N2PGV1JfCDrlkQyk9x3TLNdLQgWYwtg95X3/jPv2vX4rT7Tb4Ti
         5BPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id h26si2274858pgl.21.2019.04.18.09.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 09:24:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPecSvf_1555604676;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPecSvf_1555604676)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 19 Apr 2019 00:24:40 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
To: Michal Hocko <mhocko@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>, Dave Hansen <dave.hansen@intel.com>,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, dan.j.williams@intel.com, fengguang.wu@intel.com,
 fan.du@intel.com, ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
 <20190417152345.GB4786@localhost.localdomain>
 <20190417153923.GO5878@dhcp22.suse.cz>
 <20190417153739.GD4786@localhost.localdomain>
 <20190417163911.GA9523@dhcp22.suse.cz>
 <fcb30853-8039-8154-7ae0-706930642576@linux.alibaba.com>
 <20190417175151.GB9523@dhcp22.suse.cz>
Message-ID: <bdc25ae2-bddd-1ecb-58b8-ce506274f1bb@linux.alibaba.com>
Date: Thu, 18 Apr 2019 09:24:35 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190417175151.GB9523@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/17/19 10:51 AM, Michal Hocko wrote:
> On Wed 17-04-19 10:26:05, Yang Shi wrote:
>> On 4/17/19 9:39 AM, Michal Hocko wrote:
>>> On Wed 17-04-19 09:37:39, Keith Busch wrote:
>>>> On Wed, Apr 17, 2019 at 05:39:23PM +0200, Michal Hocko wrote:
>>>>> On Wed 17-04-19 09:23:46, Keith Busch wrote:
>>>>>> On Wed, Apr 17, 2019 at 11:23:18AM +0200, Michal Hocko wrote:
>>>>>>> On Tue 16-04-19 14:22:33, Dave Hansen wrote:
>>>>>>>> Keith Busch had a set of patches to let you specify the demotion order
>>>>>>>> via sysfs for fun.  The rules we came up with were:
>>>>>>> I am not a fan of any sysfs "fun"
>>>>>> I'm hung up on the user facing interface, but there should be some way a
>>>>>> user decides if a memory node is or is not a migrate target, right?
>>>>> Why? Or to put it differently, why do we have to start with a user
>>>>> interface at this stage when we actually barely have any real usecases
>>>>> out there?
>>>> The use case is an alternative to swap, right? The user has to decide
>>>> which storage is the swap target, so operating in the same spirit.
>>> I do not follow. If you use rebalancing you can still deplete the memory
>>> and end up in a swap storage. If you want to reclaim/swap rather than
>>> rebalance then you do not enable rebalancing (by node_reclaim or similar
>>> mechanism).
>> I'm a little bit confused. Do you mean just do *not* do reclaim/swap in
>> rebalancing mode? If rebalancing is on, then node_reclaim just move the
>> pages around nodes, then kswapd or direct reclaim would take care of swap?
> Yes, that was the idea I wanted to get through. Sorry if that was not
> really clear.
>
>> If so the node reclaim on PMEM node may rebalance the pages to DRAM node?
>> Should this be allowed?
> Why it shouldn't? If there are other vacant Nodes to absorb that memory
> then why not use it?
>
>> I think both I and Keith was supposed to treat PMEM as a tier in the reclaim
>> hierarchy. The reclaim should push inactive pages down to PMEM, then swap.
>> So, PMEM is kind of a "terminal" node. So, he introduced sysfs defined
>> target node, I introduced N_CPU_MEM.
> I understand that. And I am trying to figure out whether we really have
> to tream PMEM specially here. Why is it any better than a generic NUMA
> rebalancing code that could be used for many other usecases which are
> not PMEM specific. If you present PMEM as a regular memory then also use
> it as a normal memory.

This also makes some sense. We just look at PMEM from different point of 
view. Taking into account the performance disparity may outweigh 
treating it as a normal memory in this patchset.

A ridiculous idea, may we have two modes? One for "rebalancing", the 
other for "demotion"?



