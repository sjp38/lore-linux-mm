Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD91FC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:26:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89057206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:26:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89057206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A0666B0005; Wed, 17 Apr 2019 13:26:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04F496B0006; Wed, 17 Apr 2019 13:26:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7F596B0007; Wed, 17 Apr 2019 13:26:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE2376B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:26:18 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z12so15058287pgs.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:26:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=IKTHXir5V+OIhijl27+4UqokqUeuGrvaO0fmq8V+od8=;
        b=lPNrwOAbpdRyp5VoIgA6g8qjxESgRCLoKj6epetTpAPzLMZX3l1GXP8Kwe2Cvs1xbh
         GE2e6PYJx05dUs5pOzPCEHRvCzgz2hYr1Pex7opMPLhrhF5EJ2bjhX+jvck6xoUg4WPq
         6V4sUcI14C+VxKRGi4mQ6sn6LQ6dfc03AV8ppEYflTF4hQNZ/aJyMgHPJZLC0uVBgtAO
         Yt3M2Az3M0KXHoM/MANy3jurIXi7Ap4AOY5D1+2y8gRV3FV7LybU0I+sIvSIhg7Bn9qP
         BZ8xyh716LJjbR+wjXbF/Om2VQSFoon+Vy+suuHJI0aCU3HMiWKxX1v14ezTZsA37/kL
         Vn5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWylMD7smca2Yq8XrjYc61bUD8yqOiwq5qjgUUZXk/r5CMKUq/P
	pTTWvD+XhXieyoPpa6L+tdwOMlaTpAe2bWwK5o9/Nni6YkeuQG6x+hcbm4LRvoWnrKR/8qGF0Df
	1NhO++krD5jIVXu/8n+KLOeg/Bw/uASjetPrlRnhXbm1rJWIDYsPLn4s15bCGqE8chg==
X-Received: by 2002:a63:8848:: with SMTP id l69mr79653128pgd.137.1555521978125;
        Wed, 17 Apr 2019 10:26:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8M78ELym3VhwcgQ8E4KulIJ8arpBs4yMm9Ajr8EVWT2b47q+CEzNRez8o5sdmbFzeTx+c
X-Received: by 2002:a63:8848:: with SMTP id l69mr79653070pgd.137.1555521977352;
        Wed, 17 Apr 2019 10:26:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555521977; cv=none;
        d=google.com; s=arc-20160816;
        b=u2Rlr8QrX3ddDWsoWwMOGc8ph5kxrO3+W5Cc9W1mpM9ilRDp8/hezmaSGnDGmWxNwi
         PpeWlNqDhHOOm7+II17F5dxP1ngkcv96GnwN53Xqo69nsP41gkoSvY6kNehAO5ky3b0O
         jedAKtGkzD4HtYPhG2LC3b74zEe69WJsmrVAnyYJZRIHo8aVsgl9lAx0ryN2vVWfoAGA
         5S1n4LzliCtNHxtlFO2HWxaKNrtvXijgLvj6rpM+juThP/6J81rUwf2JkoGiiWPya5PY
         w1PZgOdCUzYzmi3dBVHQHLtJLqrjnUYYe/NLY+K7xmIJUvf6++xA+X4mW7y8Gyq5SBog
         b4AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=IKTHXir5V+OIhijl27+4UqokqUeuGrvaO0fmq8V+od8=;
        b=iEU1t7RhZnGDaa2MIj8OV1tv/9NaDWd8GmbFhKGh6lmL2kagOYbXeujrds6lTQHovz
         gef9HlQsWlFwaJH8nLGTLhcqfAMUmiYlFF+ZiE9bWbWi/swKp1YOjEWciAquJVgpogD2
         RvlD9QhEHjlTz5MWx+U3zVh3I1T/1R6znqJz369rEQc83NECPZPfeVTOyeDoQEaIzVf1
         79KJyLs7sX0IcKFvLTKmSFT2peVGs7j/EXCI/PmiK8g1LCXKqzfaczflLOroeFPqBb3v
         1eNnp2FcVTi2gJq2z/iifb4D0GREp1VpP5fNl9jInThGSqWFKrix+47S5tjLUqwGGIZl
         +dQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id x7si21732784plr.247.2019.04.17.10.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 10:26:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPa6XZW_1555521966;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPa6XZW_1555521966)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Apr 2019 01:26:12 +0800
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
To: Michal Hocko <mhocko@kernel.org>, Keith Busch <keith.busch@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, mgorman@techsingularity.net,
 riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
 dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
 ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
 <20190417152345.GB4786@localhost.localdomain>
 <20190417153923.GO5878@dhcp22.suse.cz>
 <20190417153739.GD4786@localhost.localdomain>
 <20190417163911.GA9523@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <fcb30853-8039-8154-7ae0-706930642576@linux.alibaba.com>
Date: Wed, 17 Apr 2019 10:26:05 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190417163911.GA9523@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/17/19 9:39 AM, Michal Hocko wrote:
> On Wed 17-04-19 09:37:39, Keith Busch wrote:
>> On Wed, Apr 17, 2019 at 05:39:23PM +0200, Michal Hocko wrote:
>>> On Wed 17-04-19 09:23:46, Keith Busch wrote:
>>>> On Wed, Apr 17, 2019 at 11:23:18AM +0200, Michal Hocko wrote:
>>>>> On Tue 16-04-19 14:22:33, Dave Hansen wrote:
>>>>>> Keith Busch had a set of patches to let you specify the demotion order
>>>>>> via sysfs for fun.  The rules we came up with were:
>>>>> I am not a fan of any sysfs "fun"
>>>> I'm hung up on the user facing interface, but there should be some way a
>>>> user decides if a memory node is or is not a migrate target, right?
>>> Why? Or to put it differently, why do we have to start with a user
>>> interface at this stage when we actually barely have any real usecases
>>> out there?
>> The use case is an alternative to swap, right? The user has to decide
>> which storage is the swap target, so operating in the same spirit.
> I do not follow. If you use rebalancing you can still deplete the memory
> and end up in a swap storage. If you want to reclaim/swap rather than
> rebalance then you do not enable rebalancing (by node_reclaim or similar
> mechanism).

I'm a little bit confused. Do you mean just do *not* do reclaim/swap in 
rebalancing mode? If rebalancing is on, then node_reclaim just move the 
pages around nodes, then kswapd or direct reclaim would take care of swap?

If so the node reclaim on PMEM node may rebalance the pages to DRAM 
node? Should this be allowed?

I think both I and Keith was supposed to treat PMEM as a tier in the 
reclaim hierarchy. The reclaim should push inactive pages down to PMEM, 
then swap. So, PMEM is kind of a "terminal" node. So, he introduced 
sysfs defined target node, I introduced N_CPU_MEM.

>

