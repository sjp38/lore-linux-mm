Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33AF9C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 19:28:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AECC520811
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 19:28:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AECC520811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 488666B0003; Mon, 25 Mar 2019 15:28:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 437406B0006; Mon, 25 Mar 2019 15:28:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DA496B0007; Mon, 25 Mar 2019 15:28:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE70F6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:28:20 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a72so10303519pfj.19
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:28:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=btV626X+QwJDSZBoS1Ce6ifVEcqCKLFjPzK5mh5VjT4=;
        b=sdGMAWE+hXriWq389jBDx3Tm4Uuz4WPZ0h1V7UqGlBBeowl7Nfdg4/H/Z773vidOC8
         rYFoSEeWuKzV1rM3SzW+++GSe9x6VJ8h8pYb2NZQqK3rAj7oRUAGVQIFdD6T56+lbq7s
         /daGHxxwrw1RsHQL64WxIRZZrYzrZUB8tvcNCHlctG277n/sDDesUZ0Jxf/Ny3iCdc7/
         foDb5mt3NuR+79opB9cXjkHNr0Z+nB7/6TQsvul+eIxhaBMhNREePvkKEDR+NP3tZw4I
         CfPvyS3ymPt5d7B7NaQQJKMBrrHUhpNfiqoKMbEpLVg1a2wgYPXsZT5U6XURWRuBYD1a
         K6AA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUOcMZRT8rvhzI8DtdctXTCmYW287yrXPmEBwZW3HSEwHZ0U05p
	aVlo08mcA4HdkEPrDfnlhYIxqMAa6jflzHR2L2w2AfZy7IJGGPVm8mpVjWYN0o4quxunR36T6ea
	dsIK/zYZaWjpWY7fX29e2KMGY9xsK/Jccjz5MfyQ1Ak+B8Q3YROlijhrWPsYdri1W9g==
X-Received: by 2002:a62:5687:: with SMTP id h7mr25522167pfj.198.1553542100457;
        Mon, 25 Mar 2019 12:28:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyKbWxRb7ZrQrfGuA+QGRqsiW7iNNdX51WwK9f9orpi2kXANo3vK+q3nbnM68+DWrLrBMT
X-Received: by 2002:a62:5687:: with SMTP id h7mr25522095pfj.198.1553542099419;
        Mon, 25 Mar 2019 12:28:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553542099; cv=none;
        d=google.com; s=arc-20160816;
        b=PN99k7teWprBEszyDB5GidElXIgfgW+7XA6n9KtZF0CvsebxT8Yt17i/scQLzvAvoE
         WSLZcC0X18+ho+Ayl+MA1EKCVgGaI882FU9YrJhUNR87ZS6ARjTs001xgy7LOv7SI66T
         V0cuT1zVG8pPKfpW5330+1gDlz8zQi3+8f4ZNJDj1XmhlcroAO6sSaT8cW1a8B/XfID/
         /e7rso59UvFftXZaJ+Rw5Kh3j1HccobQWYtyu/qxmlLqv6PNsTGq2ZyDrU0Do7aRrV/c
         rK6X/c8b9VR+ic7uTuygQC77JYtkss6HxPoXnsykAvnQPzbCa1IQ3Egl0CGB6pRLIZUe
         dpzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=btV626X+QwJDSZBoS1Ce6ifVEcqCKLFjPzK5mh5VjT4=;
        b=sNUD6Sej94/4W3Nx0FSTUnSyn7qZT7t+DvKc54/gtJgB/fAQyhvMn13gJlKH/6Dpap
         HlD2HjNrXyRC1OpvEc0E8fXdooJG3CQ6J06zUyC43Cju0T/0OqO27AoUW8fmZpiD79Ik
         ZWYlIyveRBjE08nz4TkGoZfxb7AWlLQ6/wtHPOethB2fxGzx7V4YqzqI37L5ZNn9DEN5
         4Ah0nVnMG++wepBGb8xAm0tM3cFOIymRU4TmHk81Ao+uFPYuN55Rykg420UID0XH8XiT
         KjFKtFu6r3IXAFffGLbv6Ma5gBBG7z5qFKNBKF31dFE8WuIhywovHJnG8hM9GoNBgL6M
         P2uA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id w9si15111115pll.389.2019.03.25.12.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 12:28:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04392;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TNeJ6Wf_1553542093;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNeJ6Wf_1553542093)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 26 Mar 2019 03:28:16 +0800
Subject: Re: [PATCH 01/10] mm: control memory placement by nodemask for two
 tier main memory
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>,
 Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
 "Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-2-git-send-email-yang.shi@linux.alibaba.com>
 <CAPcyv4g5RoHhXhkKQaYkqYLN1y3KavbGeM1zVus-3fY5Q+JdxA@mail.gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <688dffbc-2adc-005d-223e-fe488be8c5fc@linux.alibaba.com>
Date: Mon, 25 Mar 2019 12:28:13 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4g5RoHhXhkKQaYkqYLN1y3KavbGeM1zVus-3fY5Q+JdxA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/23/19 10:21 AM, Dan Williams wrote:
> On Fri, Mar 22, 2019 at 9:45 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>> When running applications on the machine with NVDIMM as NUMA node, the
>> memory allocation may end up on NVDIMM node.  This may result in silent
>> performance degradation and regression due to the difference of hardware
>> property.
>>
>> DRAM first should be obeyed to prevent from surprising regression.  Any
>> non-DRAM nodes should be excluded from default allocation.  Use nodemask
>> to control the memory placement.  Introduce def_alloc_nodemask which has
>> DRAM nodes set only.  Any non-DRAM allocation should be specified by
>> NUMA policy explicitly.
>>
>> In the future we may be able to extract the memory charasteristics from
>> HMAT or other source to build up the default allocation nodemask.
>> However, just distinguish DRAM and PMEM (non-DRAM) nodes by SRAT flag
>> for the time being.
>>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   arch/x86/mm/numa.c     |  1 +
>>   drivers/acpi/numa.c    |  8 ++++++++
>>   include/linux/mmzone.h |  3 +++
>>   mm/page_alloc.c        | 18 ++++++++++++++++--
>>   4 files changed, 28 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
>> index dfb6c4d..d9e0ca4 100644
>> --- a/arch/x86/mm/numa.c
>> +++ b/arch/x86/mm/numa.c
>> @@ -626,6 +626,7 @@ static int __init numa_init(int (*init_func)(void))
>>          nodes_clear(numa_nodes_parsed);
>>          nodes_clear(node_possible_map);
>>          nodes_clear(node_online_map);
>> +       nodes_clear(def_alloc_nodemask);
>>          memset(&numa_meminfo, 0, sizeof(numa_meminfo));
>>          WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.memory,
>>                                    MAX_NUMNODES));
>> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
>> index 867f6e3..79dfedf 100644
>> --- a/drivers/acpi/numa.c
>> +++ b/drivers/acpi/numa.c
>> @@ -296,6 +296,14 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
>>                  goto out_err_bad_srat;
>>          }
>>
>> +       /*
>> +        * Non volatile memory is excluded from zonelist by default.
>> +        * Only regular DRAM nodes are set in default allocation node
>> +        * mask.
>> +        */
>> +       if (!(ma->flags & ACPI_SRAT_MEM_NON_VOLATILE))
>> +               node_set(node, def_alloc_nodemask);
> Hmm, no, I don't think we should do this. Especially considering
> current generation NVDIMMs are energy backed DRAM there is no
> performance difference that should be assumed by the non-volatile
> flag.

Actually, here I would like to initialize a node mask for default 
allocation. Memory allocation should not end up on any nodes excluded by 
this node mask unless they are specified by mempolicy.

We may have a few different ways or criteria to initialize the node 
mask, for example, we can read from HMAT (when HMAT is ready in the 
future), and we definitely could have non-DRAM nodes set if they have no 
performance difference (I'm supposed you mean NVDIMM-F  or HBM).

As long as there are different tiers, distinguished by performance, for 
main memory, IMHO, there should be a defined default allocation node 
mask to control the memory placement no matter where we get the information.

But, for now we haven't had such information ready for such use yet, so 
the SRAT flag might be a choice.

>
> Why isn't default SLIT distance sufficient for ensuring a DRAM-first
> default policy?

"DRAM-first" may sound ambiguous, actually I mean "DRAM only by 
default". SLIT should just can tell us what node is local what node is 
remote, but can't tell us the performance difference.

Thanks,
Yang


