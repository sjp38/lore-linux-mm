Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ECEDC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:18:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C9E721773
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:18:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C9E721773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C32AD6B0010; Tue, 16 Apr 2019 19:18:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBBED6B0266; Tue, 16 Apr 2019 19:18:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A36B66B0269; Tue, 16 Apr 2019 19:18:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6080C6B0010
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 19:18:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2so13435650pge.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 16:18:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=01b00K5G4kWV9TWBe+mmSt1tt+Co/sL/lLHLBrjLBHw=;
        b=mIGbNBucsUoyGVp6hdAsD6cr3zTkoWBWuMCvS3fziJZzicjwFTEY++rxWbTp/2UCmF
         ctZRATWFSqG4dVGLlu7nKzkGI11rEm9IwcJZfiRcBzP3icJZrNPvZUa31LsrJIUISNyC
         xY+jXGkIGOOHt2KtQHFAj+u2xt6P+Ur/3bPSnrqppqp7fq3MrkriqcJgsyyEVDBBkYpI
         Y5F6UAz6mIOCZ9fa08nv5oRKHYke9mo8CJKOO6Z/aJvgXs2cVAYmhc4gSrVYZ/PE31PV
         hWfyzzT8NQEz8VzqMu9Smb/XMw3nmvOD03v5orteX/YWM3VOnodmkjIFiZFhKM5ZPCf1
         lvzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU4byy+Td8W/xzxCtfjjukc4fb/213k1lM5FeYKeVOaXqQp7KFD
	d8WyNXPENsOjnfnu8Dmvt048w8nGvCZdnkcRHguiMJGWxjEhTFdgCmW7jjSOE8yK+U1tL0Wr+Sn
	v2SGho73eIzX6X3pD1e/OXGK3TEscTiItzxNzKyE4+dufgdXvliB9jjJweaaq4P4nqg==
X-Received: by 2002:a17:902:e109:: with SMTP id cc9mr86947916plb.148.1555456725061;
        Tue, 16 Apr 2019 16:18:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSuiU2/JV9qp/wkMrjRK6Hs10C00Ca10FZzlHUrbPrhcRG66bhyRBjHrdbirUrZOlA8qOH
X-Received: by 2002:a17:902:e109:: with SMTP id cc9mr86947865plb.148.1555456724439;
        Tue, 16 Apr 2019 16:18:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555456724; cv=none;
        d=google.com; s=arc-20160816;
        b=VX8YJeZheps5rcBsK3A2T0xk++Abw43GUjf1PzYdjUvyLfszGE0cpnUM0b92HqNYMN
         N2ujZeOsDCY+xhiZ/FamxLp+8wHsbTkqhqPrOBIJQ5pVgF91Ym0lyICrtQr2cJMOGgcM
         oJRviT78OTfnw/CSgekTDjLoDmbLUk4DKl6bFy+oLlww5KkZ3UuSJV66T44V5zCWygss
         X2+YPqPLIHqRdtOwfVdQTnIx3LdppKFUDD3ruNxxW/kKXcIOJalDgQ4pY5glSlXyqjMK
         IngRQRl6DV6ZoZ2JfG0XN4sXqng/o2o5N8o3/Ymgm7YSliIYhmlzVUMM5Egi/0fv2Hwk
         Ogeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=01b00K5G4kWV9TWBe+mmSt1tt+Co/sL/lLHLBrjLBHw=;
        b=x2wFOh9PBXUloEdU+kqBwM2i0PeOyfb3HFLy+rmTJMlVGdkUxJ6heFfNnc07v5a8cJ
         vWWJLhcFfnDKTob7yKjzYEgHoQEGnyTbXM1oTKo8ftnd5pH9B2FoPtfctVnEeEdg3Wl0
         sBLEd3UI9pZqS1XkmWabibhfj2TpS6U37LOwnMbRv9qa+d8aABBTTBqIE5uwrBbzt6qO
         4tc92lpfg0ZCNhwDYPcB0JHWgUlHJs/O/JnNJrK6h7L2+DssRTsVn+V1cLjQsdNn4gOH
         0Sxshh6TIDQdZzn3b+qc6tuWHQNjh1bK6IXkPPQumCEzt3ZQhgM5tOfg6cy4yRt6auUb
         Tlpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id z70si48552708pgd.86.2019.04.16.16.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 16:18:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R331e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPV9h2n_1555456718;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPV9h2n_1555456718)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 17 Apr 2019 07:18:41 +0800
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, dave.hansen@intel.com, keith.busch@intel.com,
 dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
 ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
Message-ID: <fe21be04-88a4-b2f6-0fa6-24776ac4d7dd@linux.alibaba.com>
Date: Tue, 16 Apr 2019 16:18:37 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


>>>> Why cannot we start simple and build from there? In other words I 
>>>> do not
>>>> think we really need anything like N_CPU_MEM at all.
>>> In this patchset N_CPU_MEM is used to tell us what nodes are cpuless 
>>> nodes.
>>> They would be the preferred demotion target.  Of course, we could 
>>> rely on
>>> firmware to just demote to the next best node, but it may be a 
>>> "preferred"
>>> node, if so I don't see too much benefit achieved by demotion. Am I 
>>> missing
>>> anything?
>> Why cannot we simply demote in the proximity order? Why do you make
>> cpuless nodes so special? If other close nodes are vacant then just use
>> them.

And, I'm supposed we agree to *not* migrate from PMEM node (cpuless 
node) to any other node on reclaim path, right? If so we need know if 
the current node is DRAM node or PMEM node. If DRAM node, do demotion; 
if PMEM node, do swap. So, using N_CPU_MEM to tell us if the current 
node is DRAM node or not.

> We could. But, this raises another question, would we prefer to just 
> demote to the next fallback node (just try once), if it is contended, 
> then just swap (i.e. DRAM0 -> PMEM0 -> Swap); or would we prefer to 
> try all the nodes in the fallback order to find the first less 
> contended one (i.e. DRAM0 -> PMEM0 -> DRAM1 -> PMEM1 -> Swap)?
>
>
> |------|     |------| |------|        |------|
> |PMEM0|---|DRAM0| --- CPU0 --- CPU1 --- |DRAM1| --- |PMEM1|
> |------|     |------| |------|       |------|
>
> The first one sounds simpler, and the current implementation does so 
> and this needs find out the closest PMEM node by recognizing cpuless 
> node.
>
> If we prefer go with the second option, it is definitely unnecessary 
> to specialize any node.
>

