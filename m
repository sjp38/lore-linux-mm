Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C5F3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 19:40:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C14AA20823
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 19:40:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C14AA20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36EA26B0275; Thu, 28 Mar 2019 15:40:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31FAB6B0276; Thu, 28 Mar 2019 15:40:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 235696B0277; Thu, 28 Mar 2019 15:40:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E36146B0275
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:40:25 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n5so10373928pgk.9
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 12:40:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=5qPSSpaA0sfuIzyEg/e3rD70tix76EYCnAQgTf7koZA=;
        b=U846I3uMbxLBOJn200vJcPZ0UhU/eLCbrJGPs++3mLuFHdF+41fyYWeclm+T58DMOr
         fwHcvGNND6wOasDe0CYamB9cWWaATV9v24thXbEeKbDiETtqdcWZR1VfMAQh2vneJbCy
         /RHkPwDapjTW+ndQhEKbQlOumVKcVHwFYtIs6FtpOSYIhtKav0hweo2Zsy/puLOqebAm
         yH9CcUhbZg1FzYF7JqFBhwqH97v7dKvzwuhdx1kWyUK/v/6r6WROxFH/UxlKdWE92doC
         TZeMHGj9eftSRnVn1GtIOys1eHXBEdnIWAmYXb+zI3EZXSLTxn/2gfWgc/SNDIf/nnfT
         hR5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWgbepdok9YgGPEhPQtDL4/aCxm9cGzFUePUXO6201kJeEGOSRK
	WYZPS2+LGkOu1UNmqovwELEPub924fUnb6uP3z3dSsWVidMGsYFSXnRppwCzpAL+kd5eec48JNm
	Ri0dwSp4fRt1us5Eie8zGKnkJsq8nQMuV+5Pk2V3sdjVN71kDRuc4d6qQJk7wlgyd9A==
X-Received: by 2002:a63:525f:: with SMTP id s31mr40910348pgl.172.1553802025539;
        Thu, 28 Mar 2019 12:40:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyois2Z2O+ZW3C2i4nfClLWRinc4mg35CjaZqiLDfISixap0JOCDVf7F8ybJnAfhoxmk09m
X-Received: by 2002:a63:525f:: with SMTP id s31mr40910284pgl.172.1553802024363;
        Thu, 28 Mar 2019 12:40:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553802024; cv=none;
        d=google.com; s=arc-20160816;
        b=V15Elb9ztEZ0gO7NN3WBTNikFJHGFaJ+eQp7H9iGM6r1/Z7oxi5S4saFwM7XAJWhUj
         e2F8EQTKIrvijy6m/mSNFLAathtv4clfV1jmHXrJ/Zq3EEj2ZWGfpWXaRYs7uTysq5s/
         6R+pYmZWH6g0lkOOr2YuvVZramQDMWcEwCI9voGWC8VlLhCsN2KBtOgAxkGvn50wNBkf
         G1NY/jr7nfVjvJxKr7eo5jhj5RX5snZKTsd7NIeA3IsQBaZXOm4+zyvfTmzRXwfQgxJG
         8InpH3N7ciN2j3Ywz+o/82h3AN/48Fo8s7JZGEnMjliudx7cIahcPhseg6bK1r17p26w
         rFhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5qPSSpaA0sfuIzyEg/e3rD70tix76EYCnAQgTf7koZA=;
        b=rzh00WGQAumfbAWlo0POmSn+1jjUsdZgNriP8qYrkgQMb9U4f9FMWDLUHHuJXaDCjD
         UooMj0brNC9FN7MFjwLuL5HW9uHMOqI+uUmaLKMfhGF5dAfiyOZKjSeU5TylKiZTOiC/
         Mv0HTkbvAQuTiw6sE8vO3m8Nm90f61v24+zUjKky5CMpE3MQ53roVVXyV896C7M3GIbl
         porbnfBH1dWwewB7FvwsiV9OgViZDYDcFh/VfyL/ua4MkynTu//1tkA6oQZ1MBSqUQa8
         ahyjFO0PIKl/gsDWReZZITEEWnr9dgyGAUDCohVmqaWGZItFyCimTdvACVOdvTFpp0F6
         t4rA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id g40si23294247plb.146.2019.03.28.12.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 12:40:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R471e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TNrZtXd_1553802015;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNrZtXd_1553802015)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 29 Mar 2019 03:40:22 +0800
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
References: <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz>
 <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz>
 <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
 <c3690a19-e2a6-7db7-b146-b08aa9b22854@linux.alibaba.com>
 <20190327193918.GP11927@dhcp22.suse.cz>
 <6f8b4c51-3f3c-16f9-ca2f-dbcd08ea23e6@linux.alibaba.com>
 <20190328065802.GQ11927@dhcp22.suse.cz>
 <6487e0f5-aee4-3fea-00f5-c12602b8ad2b@linux.alibaba.com>
 <20190328191206.GC7155@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <5934ed42-c512-a4c7-cbed-9062065bf276@linux.alibaba.com>
Date: Thu, 28 Mar 2019 12:40:14 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190328191206.GC7155@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/28/19 12:12 PM, Michal Hocko wrote:
> On Thu 28-03-19 11:58:57, Yang Shi wrote:
>>
>> On 3/27/19 11:58 PM, Michal Hocko wrote:
>>> On Wed 27-03-19 19:09:10, Yang Shi wrote:
>>>> One question, when doing demote and promote we need define a path, for
>>>> example, DRAM <-> PMEM (assume two tier memory). When determining what nodes
>>>> are "DRAM" nodes, does it make sense to assume the nodes with both cpu and
>>>> memory are DRAM nodes since PMEM nodes are typically cpuless nodes?
>>> Do we really have to special case this for PMEM? Why cannot we simply go
>>> in the zonelist order? In other words why cannot we use the same logic
>>> for a larger NUMA machine and instead of swapping simply fallback to a
>>> less contended NUMA node? It can be a regular DRAM, PMEM or whatever
>>> other type of memory node.
>> Thanks for the suggestion. It makes sense. However, if we don't specialize a
>> pmem node, its fallback node may be a DRAM node, then the memory reclaim may
>> move the inactive page to the DRAM node, it sounds not make too much sense
>> since memory reclaim would prefer to move downwards (DRAM -> PMEM -> Disk).
> There are certainly many details to sort out. One thing is how to handle
> cpuless nodes (e.g. PMEM). Those shouldn't get any direct allocations
> without an explicit binding, right? My first naive idea would be to only

Wait a minute. I thought we were arguing about the default allocation 
node mask yesterday. And, the conclusion is PMEM node should not be 
excluded from the node mask. PMEM nodes are cpuless nodes. I think I 
should replace all "PMEM node" to "cpuless node" in the cover letter and 
commit logs to make it explicitly.

Quoted from Dan "For ACPI platforms the HMAT is effectively going to 
enforce "cpu-less" nodes for any memory range that has differentiated 
performance from the conventional memory pool, or differentiated 
performance for a specific initiator."

I apologize I didn't elaborate PMEM nodes are cpuless nodes at the first 
place. Of course, cpuless node may be not PMEM node.

To your question, yes, I do agree. Actually, this is what I mean about 
"DRAM only by default", or I should rephrase it to "exclude cpuless 
node", I thought they mean the same thing.

> migrate-on-reclaim only from the preferred node. We might need

If we exclude cpuless nodes, yes. The preferred node would be DRAM node 
only. Actually, the patchset does follow "migrate-on-reclaim only from 
the preferred node".

Thanks,
Yang

> additional heuristics but I wouldn't special case PMEM from other
> cpuless NUMA nodes.

