Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FBB2C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 02:59:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FFCD2082F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 02:59:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FFCD2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A970B6B0003; Tue, 26 Mar 2019 22:59:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A47886B0006; Tue, 26 Mar 2019 22:59:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 934706B0007; Tue, 26 Mar 2019 22:59:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5C56B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 22:59:07 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n5so6534847pgk.9
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 19:59:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=8nM1lV2mgVcr4aDN4NQKOwpY5Vtqb2oMTpVw5jDVZHQ=;
        b=tapUPizIOqpzdczrTr798p/RqAEGDIwmE0yhqlrimp91KwQiJhcUaP8vCG6+dKwOCL
         myP0P0rM6QheP1rc7+aNYHQEJvWGvgZqNKeyOALN/VLxrYUPKTklv4Li6nbxGYROcnuJ
         g77iyWfVNh5bBxihzuc9RHng5M7yIEmO5J3KjuRsSxhqX7MLBgCw12/Dc//0qJdvEk74
         pNbJZEaj47c616nR+hdZUZPnuXuEt0LalgS2zrTSuIeD1ENT+DQPfUN4WtTb/ftd9rui
         142BJVc25fQHIcUHvrxl6oFkApNiiCHZDDCcBqnZtEjd81FB8llLNsfTLUIE9IAOXH1C
         EIUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWjRVrBTGexXeIN33JR2OkSJWJet5Ix1vfu4xb+hKGC46UXp3Jb
	+6cQtm8elKb2u2toJ0JuXSpdW3wl+VCaLcTpoMceoW+zdPQkjdjIMBNPpFYcciWKOq5qtgf0pcw
	vjj1M0sbCoO8o68TTQdPbaKc+a9peoaCapOM3aUAOQVdxGahgyGb7XTWLbDRKgYcuAg==
X-Received: by 2002:a63:da56:: with SMTP id l22mr32741229pgj.127.1553655546970;
        Tue, 26 Mar 2019 19:59:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPDfgvWaL3+Sd+vAGr52rQfftAhCpzM/xC4RupSK6fZUZKdNMiNxBpMWWgwR4/2Vw3HgXY
X-Received: by 2002:a63:da56:: with SMTP id l22mr32741190pgj.127.1553655546058;
        Tue, 26 Mar 2019 19:59:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553655546; cv=none;
        d=google.com; s=arc-20160816;
        b=kzr+hPqUbCrLny/7k8dlwIeuxKNJ4GX5IjoVb26f8530DNWC7oAsZRkCJUMW1EdFFA
         h3jbQquo52IUrgqz0qoDjd7AVy2UVFZ1EgDMh0dE8xamPSbMRlsEaMztAe+uv8CnYZHa
         2fCMALZuhgBMvdl3TSlZtD2NNbaslgMUh0I/B6uEog5m4EdNdhirjj+U4ztz3POC1JEL
         35rZcoqOFWUWN+0Kxvuawu6PYRsmTWIeNa8d8b7/SHiwUscBzjLs9UjbkB8XSJSW1/1m
         XwizGkHJfaiP2E+z0A/pZSl+I3MHNVIbKQRAe7Fkeo90w32U2T5Synpgl5YTgd8j7wcG
         usXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8nM1lV2mgVcr4aDN4NQKOwpY5Vtqb2oMTpVw5jDVZHQ=;
        b=Ks01bHZEy8M2MagqSzzDE2q5fBwlZ8IosPnDNVki4VSlqSXzBgg6swirNX2oBZQskW
         mzLUhYDCRdy9RVA5+fIOriETgmSdj38jWyvbQmGbtTeRHxNwnpx+5Ax35pf2xZead5m+
         01vy9GkrtFDrFQD3CrQO7B+bR73Vwoa0QFNHCIgO/DtjsdnJOgIKz1hnyuRFZeApPjsX
         A2mvuxiLTVZQurhTobFPmFBlhnWgBXmp/1EK8nlr6SjZNqPtJSylcKNSImvS9EvV8L5T
         xyUcwKRC1jgS+CM1aDJHB9lZ8V6juX0m5j6E698HgWpIvdC7N9/rQbrtZGLTFFgTeMh2
         19Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id d14si10908074pgb.26.2019.03.26.19.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 19:59:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04452;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TNk2xdD_1553655539;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNk2xdD_1553655539)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 27 Mar 2019 10:59:03 +0800
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, dave.hansen@intel.com, keith.busch@intel.com,
 dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
 ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz>
 <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
Date: Tue, 26 Mar 2019 19:58:56 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190326183731.GV28406@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/26/19 11:37 AM, Michal Hocko wrote:
> On Tue 26-03-19 11:33:17, Yang Shi wrote:
>>
>> On 3/26/19 6:58 AM, Michal Hocko wrote:
>>> On Sat 23-03-19 12:44:25, Yang Shi wrote:
>>>> With Dave Hansen's patches merged into Linus's tree
>>>>
>>>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4
>>>>
>>>> PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUMA node
>>>> effectively and efficiently is still a question.
>>>>
>>>> There have been a couple of proposals posted on the mailing list [1] [2].
>>>>
>>>> The patchset is aimed to try a different approach from this proposal [1]
>>>> to use PMEM as NUMA nodes.
>>>>
>>>> The approach is designed to follow the below principles:
>>>>
>>>> 1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, etc.
>>>>
>>>> 2. DRAM first/by default. No surprise to existing applications and default
>>>> running. PMEM will not be allocated unless its node is specified explicitly
>>>> by NUMA policy. Some applications may be not very sensitive to memory latency,
>>>> so they could be placed on PMEM nodes then have hot pages promote to DRAM
>>>> gradually.
>>> Why are you pushing yourself into the corner right at the beginning? If
>>> the PMEM is exported as a regular NUMA node then the only difference
>>> should be performance characteristics (module durability which shouldn't
>>> play any role in this particular case, right?). Applications which are
>>> already sensitive to memory access should better use proper binding already.
>>> Some NUMA topologies might have quite a large interconnect penalties
>>> already. So this doesn't sound like an argument to me, TBH.
>> The major rationale behind this is we assume the most applications should be
>> sensitive to memory access, particularly for meeting the SLA. The
>> applications run on the machine may be agnostic to us, they may be sensitive
>> or non-sensitive. But, assuming they are sensitive to memory access sounds
>> safer from SLA point of view. Then the "cold" pages could be demoted to PMEM
>> nodes by kernel's memory reclaim or other tools without impairing the SLA.
>>
>> If the applications are not sensitive to memory access, they could be bound
>> to PMEM or allowed to use PMEM (nice to have allocation on DRAM) explicitly,
>> then the "hot" pages could be promoted to DRAM.
> Again, how is this different from NUMA in general?

It is still NUMA, users still can see all the NUMA nodes.

Introduced default allocation node mask (please refer to patch #1) to 
control the memory placement. Typically, the node mask just includes 
DRAM nodes. PMEM nodes are excluded by the node mask for memory allocation.

The node mask could be override by user per the discussion with Dan.

Thanks,
Yang


