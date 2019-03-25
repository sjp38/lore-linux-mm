Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24152C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 20:05:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFE192087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 20:05:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFE192087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EFFB6B0003; Mon, 25 Mar 2019 16:05:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C5856B0006; Mon, 25 Mar 2019 16:05:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DCCE6B0007; Mon, 25 Mar 2019 16:05:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 34BFA6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 16:05:11 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e12so6069584pgh.2
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 13:05:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=6FyGxE3poJIGNfRgxd+lAh+X99bmKxFYldRDglir87o=;
        b=Y0DH4U413y7wYY2fd8vkMkCHFj6VzpRJTvGvuXXbEIvD7oUoIIb6IIsSj5HMpSOb+/
         luJbVPUsXzVr5rQcInxQV5z3Mtn0yxndT3aaAaqYgzx1bTHRjMmddt6tiJVZUTN3jYhS
         OayQBsyMPGo06HcKbETVE1MBvKpFM9hcCsp33deyqn4BoRhTni+26bXaZKnlGjxUQ2Rr
         FGvFeyQDxEY6tmVWmXcWHcoc548ybnXFWdtXayLFzS55rjvAtxlZCVmkOJYdsD+alZtC
         6VUY4nHtZhXRlG4PbSetrGKqrBwfrGTrkE/28UppMxsbgsV2p51mGTq2n79TIFT7NFU7
         27Sw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXm63L5Mo44+gcgS1NTtwH1QYUBS/8xCCUDzvCAZm+2+ssuUimi
	azq//Had9iyu/0I0nWzQbdaQ+FOuceWkJQzxhsv9iI5mac2RJsn7jicBJxSEGpo0rLgips7T5A1
	ezS+BcokiAP+9Cv1+uytcllLY5KpmDnGlzt5YpNEkGtRP1BvSgP7IABoeyN7d2e+3Uw==
X-Received: by 2002:a17:902:bd90:: with SMTP id q16mr20925066pls.162.1553544310875;
        Mon, 25 Mar 2019 13:05:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+ukMhVk+O4tVya7MIzosyBVBwSQJ0C6hru50laPpFCBCTrNfpPOfGxH5pOo+U30z/MKsV
X-Received: by 2002:a17:902:bd90:: with SMTP id q16mr20925002pls.162.1553544310098;
        Mon, 25 Mar 2019 13:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553544310; cv=none;
        d=google.com; s=arc-20160816;
        b=S8gUO2eITB7CH+ykOJ8Px/Urrdjj2MqwY7oO8aL4GcgQ27b1rU0XJ/d6XTDiEmnWYx
         lE8dfDm3AX1yhS1QzJ3NdWideDngyOEi6UZht1hpjsKa8Q65XMEfsRRVrXuCysD108rP
         ZCYUe4bnfxuGgUI2/mFOKoLuDJyvdVe/Ivge2ndH7W1nyVbzH2V3NV1d0i289J/ijbHv
         qBZ520Z/NOcxcnpIw2Mtt57EJrMtD2a39w6SqfXSBV5EDShv6TlLDYy2h9uX/MjO6jEH
         brvlUkb3nwBxmg45VqU8vqmap8cCaGQRsUEYeLGeQtEdfsLvTfC8Cp/KIKAwhZz9Nh1R
         BDeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6FyGxE3poJIGNfRgxd+lAh+X99bmKxFYldRDglir87o=;
        b=eP++pgj+gTXt8egeNLZa/FczXm3/YQe7/VPRUcptTzVg7oRNm19Q1uotM1/jEBjhE7
         iDL6IlpbkhK2XhFR8+Uwatt/JIVSPPe9XauoYkKfI22W29Os6gy8oiGfjsjMz5wsmlcq
         d39KIbsYzGEl1hyp0ltG8VYByJq/x+HuHWev3xupUK5RaUjiySQ52el1vgW/PTLr9a5o
         gpC6D5j2TjvUqCc/mvsR2xd4zRQvoBVWjzxHqBz4JhMpMIqwYnl+yyc3MCROVWXNmK+6
         C+GuZ8r9Hd24gJiMzu+0lyz7a4HvSDqnB0nllSqQb2lmRnzZ+NW2w9pYN4BIZMhpAZHe
         Ugpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id g4si14376139plt.215.2019.03.25.13.05.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 13:05:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04389;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNeJAtn_1553544298;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNeJAtn_1553544298)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 26 Mar 2019 04:05:05 +0800
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Brice Goglin <Brice.Goglin@inria.fr>, mhocko@suse.com,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, dave.hansen@intel.com, keith.busch@intel.com,
 dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
 ying.huang@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <cc6f44e2-48b5-067f-9685-99d8ae470b50@inria.fr>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <33b4d3ff-3a8d-d565-53b6-cde6310ddbef@linux.alibaba.com>
Date: Mon, 25 Mar 2019 13:04:57 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <cc6f44e2-48b5-067f-9685-99d8ae470b50@inria.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/25/19 9:15 AM, Brice Goglin wrote:
> Le 23/03/2019 à 05:44, Yang Shi a écrit :
>> With Dave Hansen's patches merged into Linus's tree
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4
>>
>> PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUMA node
>> effectively and efficiently is still a question.
>>
>> There have been a couple of proposals posted on the mailing list [1] [2].
>>
>> The patchset is aimed to try a different approach from this proposal [1]
>> to use PMEM as NUMA nodes.
>>
>> The approach is designed to follow the below principles:
>>
>> 1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, etc.
>>
>> 2. DRAM first/by default. No surprise to existing applications and default
>> running. PMEM will not be allocated unless its node is specified explicitly
>> by NUMA policy. Some applications may be not very sensitive to memory latency,
>> so they could be placed on PMEM nodes then have hot pages promote to DRAM
>> gradually.
>
> I am not against the approach for some workloads. However, many HPC
> people would rather do this manually. But there's currently no easy way
> to find out from userspace whether a given NUMA node is DDR or PMEM*. We
> have to assume HMAT is available (and correct) and look at performance
> attributes. When talking to humans, it would be better to say "I
> allocated on the local DDR NUMA node" rather than "I allocated on the
> fastest node according to HMAT latency".

Yes, I agree to have some information exposed to kernel or userspace to 
tell what nodes are DRAM nodes what nodes are not (maybe HBM or PMEM). I 
assume the default allocation should end up on DRAM nodes for the most 
workloads. If someone would like to control this manually other than 
mempolicy, the default allocation node mask may be exported to user 
space by sysfs so that it can be changed on demand.

>
> Also, when we'll have HBM+DDR, some applications may want to use DDR by
> default, which means they want the *slowest* node according to HMAT (by
> the way, will your hybrid policy work if we ever have HBM+DDR+PMEM?).
> Performance attributes could help, but how does user-space know for sure
> that X>Y will still mean HBM>DDR and not DDR>PMEM in 5 years?

This is what I mentioned above we need the information exported from 
HMAT or anything similar to tell us what nodes are DRAM nodes since DRAM 
may be the lowest tier memory.

Or we may be able to assume the nodes associated with CPUs are DRAM 
nodes by assuming both HBM and PMEM is CPU less node.

Thanks,
Yang

>
> It seems to me that exporting a flag in sysfs saying whether a node is
> PMEM could be convenient. Patch series [1] exported a "type" in sysfs
> node directories ("pmem" or "dram"). I don't know how if there's an easy
> way to define what HBM is and expose that type too.
>
> Brice
>
> * As far as I know, the only way is to look at all DAX devices until you
> find the given NUMA node in the "target_node" attribute. If none, you're
> likely not PMEM-backed.
>
>
>> [1]: https://lore.kernel.org/linux-mm/20181226131446.330864849@intel.com/

