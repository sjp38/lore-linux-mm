Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11452C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 00:09:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 870C92084B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 00:09:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 870C92084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25F786B0003; Mon, 15 Apr 2019 20:09:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20D6F6B0006; Mon, 15 Apr 2019 20:09:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FCC86B0007; Mon, 15 Apr 2019 20:09:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB8D16B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 20:09:16 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 18so11354477pgx.11
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 17:09:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=jj3rycQWqEPKkQaXLzt04Rn8sgRDzKZ7CFKFBpCkGEQ=;
        b=ZmmjDUrliJXDa6CptpTYV2yG2HO67tQ1DNmo6eiYtGDYAT0zW+CJrHbLUCEApu+aN7
         Kp4TWPfdWOGE+cbmIOTsVwMCPVCYZX5z7gLZ6B7ER62+CrSX4eQ4UDMvbWlQ+ZJa0J1E
         QxCIUkSjXe3gLzKBb7qPE3T8UxOHvOCtsKx4PbSYbbFEfB3w0Wibgj187bChcyuJpxR0
         volZIbsrvWnDq9TqkZpaeRCvE6656kaj56tPhz5cN1YDXaCM73/HGqoYH83KYqGNvKXb
         M7aVEi0SpWQkFbnyAdHGO0/VDlF3qxGEpzl1J1xVFGw/j+RfYSbX4f881PDkc44RVWEG
         8XYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVXmMHHW2hKq1UZ9LuT1tNCv1rvdhQISblG8gO5VU1cHGDe6Zns
	tPzN8Jv2/hKllAUVVx9v9W7GpRDTU0SwMS451ruKnSv6yeJdQQZi0U7OlO+ukxSy/+VV6yrEpfP
	1ylXzSxDKCG1zoeQ1Q0Yo+A1re5/jNIod4+zxinaA4A1EojqYIvxFm8VAqkp4K7SQLA==
X-Received: by 2002:a17:902:2a6a:: with SMTP id i97mr23703459plb.273.1555373356466;
        Mon, 15 Apr 2019 17:09:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVydYDO0pVwcEKP4PD7fBMIqVObEBlVXe1nzv4tUgt45rZ0huure9G8tIvVn6sErDt67oT
X-Received: by 2002:a17:902:2a6a:: with SMTP id i97mr23703367plb.273.1555373355411;
        Mon, 15 Apr 2019 17:09:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555373355; cv=none;
        d=google.com; s=arc-20160816;
        b=luWoCAQpcP0COKaO1GY9hz4nO+UYrkXZ8u3D25KYr8eq89OhZsqvnRa6KM6KULFvEK
         ToWEX/fPtZCM4JpmKOZ/u3n6XFjH4IH+dKkMM5lu0IwUB8bniMXoi9NfL8X/J3hbGMHT
         uVe7q8Zk3AjrFy5X3fyiV659Gfowi6keeNDzwVWD39yEgZBAlmd1hnCOBAX5DabrG4Ud
         G3FG874ZRJr1ovMW4aZofLefZcuflqG5E98t/FD5yItMdsqjwXT1bTBNl1kmpbgeU9Py
         uhIN9aJNvCxe5WPqlJMqW1qaUmTahWTbNw9xWLyywvQCpOVxZhT1NoAF78PdSlPZ5hlv
         v8tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jj3rycQWqEPKkQaXLzt04Rn8sgRDzKZ7CFKFBpCkGEQ=;
        b=b9bacf5KnIXHSuPq1uIS1iZMHWRco18up2cJGqliGvG2Bc940giNWU4w+XwUHjo08D
         mSSGFo1FNmN0HSBoPCnFxRA6onjGxR8rS6obhyMH+8kTGPwvf0bWdw/Tz0YEICgBw/ID
         DeRNPXlsIe7pK1p8y1LXFK8qIhTp3RAfoPY5zl3QhGUQ/AiNqELoM5pZrXKx2e81R3IN
         dBwwa4BOMUulnY7O3Ly4PdjZMaxgNcQQR1YZhbj/cArnzCZRV4RnHulVKAAz+DvL2lBL
         dtaDv5NUEmYto7Tj/2ffYZsa1Vkieana+3GsAx0VIBqrhycOpYXXF4jrCqEQnIksSl7s
         ipkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id e192si43031141pgc.222.2019.04.15.17.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 17:09:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R871e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPPwXuC_1555373347;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPPwXuC_1555373347)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Apr 2019 08:09:12 +0800
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
To: Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, dave.hansen@intel.com, keith.busch@intel.com,
 dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
 ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
Date: Mon, 15 Apr 2019 17:09:07 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190412084702.GD13373@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/12/19 1:47 AM, Michal Hocko wrote:
> On Thu 11-04-19 11:56:50, Yang Shi wrote:
> [...]
>> Design
>> ======
>> Basically, the approach is aimed to spread data from DRAM (closest to local
>> CPU) down further to PMEM and disk (typically assume the lower tier storage
>> is slower, larger and cheaper than the upper tier) by their hotness.  The
>> patchset tries to achieve this goal by doing memory promotion/demotion via
>> NUMA balancing and memory reclaim as what the below diagram shows:
>>
>>      DRAM <--> PMEM <--> Disk
>>        ^                   ^
>>        |-------------------|
>>                 swap
>>
>> When DRAM has memory pressure, demote pages to PMEM via page reclaim path.
>> Then NUMA balancing will promote pages to DRAM as long as the page is referenced
>> again.  The memory pressure on PMEM node would push the inactive pages of PMEM
>> to disk via swap.
>>
>> The promotion/demotion happens only between "primary" nodes (the nodes have
>> both CPU and memory) and PMEM nodes.  No promotion/demotion between PMEM nodes
>> and promotion from DRAM to PMEM and demotion from PMEM to DRAM.
>>
>> The HMAT is effectively going to enforce "cpu-less" nodes for any memory range
>> that has differentiated performance from the conventional memory pool, or
>> differentiated performance for a specific initiator, per Dan Williams.  So,
>> assuming PMEM nodes are cpuless nodes sounds reasonable.
>>
>> However, cpuless nodes might be not PMEM nodes.  But, actually, memory
>> promotion/demotion doesn't care what kind of memory will be the target nodes,
>> it could be DRAM, PMEM or something else, as long as they are the second tier
>> memory (slower, larger and cheaper than regular DRAM), otherwise it sounds
>> pointless to do such demotion.
>>
>> Defined "N_CPU_MEM" nodemask for the nodes which have both CPU and memory in
>> order to distinguish with cpuless nodes (memory only, i.e. PMEM nodes) and
>> memoryless nodes (some architectures, i.e. Power, may have memoryless nodes).
>> Typically, memory allocation would happen on such nodes by default unless
>> cpuless nodes are specified explicitly, cpuless nodes would be just fallback
>> nodes, so they are also as known as "primary" nodes in this patchset.  With
>> two tier memory system (i.e. DRAM + PMEM), this sounds good enough to
>> demonstrate the promotion/demotion approach for now, and this looks more
>> architecture-independent.  But it may be better to construct such node mask
>> by reading hardware information (i.e. HMAT), particularly for more complex
>> memory hierarchy.
> I still believe you are overcomplicating this without a strong reason.
> Why cannot we start simple and build from there? In other words I do not
> think we really need anything like N_CPU_MEM at all.

In this patchset N_CPU_MEM is used to tell us what nodes are cpuless 
nodes. They would be the preferred demotion target.  Of course, we could 
rely on firmware to just demote to the next best node, but it may be a 
"preferred" node, if so I don't see too much benefit achieved by 
demotion. Am I missing anything?

>
> I would expect that the very first attempt wouldn't do much more than
> migrate to-be-reclaimed pages (without an explicit binding) with a

Do you mean respect mempolicy or cpuset when doing demotion? I was 
wondering this, but I didn't do so in the current implementation since 
it may need walk the rmap to retrieve the mempolicy in the reclaim path. 
Is there any easier way to do so?

> very optimistic allocation strategy (effectivelly GFP_NOWAIT) and if

Yes, this has been done in this patchset.

> that fails then simply give up. All that hooked essentially to the
> node_reclaim path with a new node_reclaim mode so that the behavior
> would be opt-in. This should be the most simplistic way to start AFAICS
> and something people can play with without risking regressions.

I agree it is safer to start with node reclaim. Once it is stable enough 
and we are confident enough, it can be extended to global reclaim.

>
> Once we see how that behaves in the real world and what kind of corner
> case user are able to trigger then we can build on top. E.g. do we want
> to migrate from cpuless nodes as well? I am not really sure TBH. On one
> hand why not if other nodes are free to hold that memory? Swap out is
> more expensive. Anyway this is kind of decision which would rather be
> shaped on an existing experience rather than ad-hoc decistion right now.

I do agree.

>
> I would also not touch the numa balancing logic at this stage and rather
> see how the current implementation behaves.

I agree we would prefer start from something simpler and see how it works.

The "twice access" optimization is aimed to reduce the PMEM bandwidth 
burden since the bandwidth of PMEM is scarce resource. I did compare 
"twice access" to "no twice access", it does save a lot bandwidth for 
some once-off access pattern. For example, when running stress test with 
mmtest's usemem-stress-numa-compact. The kernel would promote ~600,000 
pages with "twice access" in 4 hours, but it would promote ~80,000,000 
pages without "twice access".

Thanks,
Yang


