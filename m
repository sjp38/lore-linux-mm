Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A52ABC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:26:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDE912087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:26:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDE912087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DD6E8E0003; Wed, 30 Jan 2019 12:26:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 863998E0001; Wed, 30 Jan 2019 12:26:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DD1A8E0003; Wed, 30 Jan 2019 12:26:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3648E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:26:50 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id y2so196258plr.8
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:26:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :subject:message-id:date:user-agent:mime-version
         :content-transfer-encoding:content-language;
        bh=p3U12McyPESoHHoR9VoPpwo/YfaMFoOpw31ZFP6QhZE=;
        b=dkn3qdq7oUw9ws3gM61rQ083eXkcqPKzPxv4h5XHwiGUyLL0CoywDso6LaTo1zVCPp
         xdv6x5C47Ba2z2Bf29atDMJ/wBZHaju62gOhmtaiuJKbxr8iXoWh27gOeJ7LoO/y2q+J
         CCtxNomhyFbjoJMCZIVdTFvYjQkMKvTTfUWB997N2rprrMjnxScCy4mI7tr4Fpspsgvq
         5oK7yoV00bTmrpmp8scLoB+SbOCCSgZnkauJwfdplfJmyDMyB4GMTJ81w9DCUYVsNdf2
         7ULjJD829WEK/ulQGY2XyDf/L9y7YHLW2JZUoYoqd9PhVBPeewdNz39pDdxuaJHaKUZH
         P6ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AJcUukfwBLgrN+6+L6wH95MU5KZvNkNvijrl/WlCKpGWcO5EM8aE+/KV
	ogZuz/q/3P3CR6A6ZNu7RLVaL4TzEdbjGJQ8sJKYh5CbC8kbYRtCchQi8OtMfNU+7buB3tHw0qD
	orCOB95vyryVh3mkn5LeRU0SJqMh7UbRWqcXE0OEaEY+WMJkhXWdgEyGO2KZ7rJi6Hg==
X-Received: by 2002:a63:ed03:: with SMTP id d3mr28019523pgi.275.1548869209706;
        Wed, 30 Jan 2019 09:26:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6gDjShbuaWdXXeHlxaOLhqo//Q/m4ejF6emOINctATyeHNz87r2pUIJhop45G1IOB5HXdQ
X-Received: by 2002:a63:ed03:: with SMTP id d3mr28019477pgi.275.1548869208869;
        Wed, 30 Jan 2019 09:26:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548869208; cv=none;
        d=google.com; s=arc-20160816;
        b=vj5lgkWmmj9je0K0GgIdDqymqNejE/E0cxKg1sZOW5f2mqvcsvL8VwHSoRzPCsuyqM
         a1Vqr62yLFgth7yF0f3pRssRufprDOUQVSAZrPrvGpGmfpRmtmmWtnrMMD7MU09W+uGO
         e9wCQwv6uQdibCJO02gfuLJOse6ATBudaCaNfxBCvOgN0GcZqGbqquobXsiIGQ7OdHQ6
         lK/aHI2FIm3uob6Hksdv3wgVuz4q+f5OB2IqLzIQHMI7oUXQzWK27uWkzFB9x/mvcC5f
         VKiwMqlFH6/nvDpRwSlJSkf67qENthgXo5xSOTBHn9QJ/YrhbrE+kUeq97gBkmvOKmms
         K94Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:mime-version:user-agent
         :date:message-id:subject:from:cc:to;
        bh=p3U12McyPESoHHoR9VoPpwo/YfaMFoOpw31ZFP6QhZE=;
        b=LQROQV8T4Kabo4RfQVnAXp+4VIXB8R/d0oMviHCfmqalmM2yM7QkRd0NfkYIPaH61V
         Vo0za0SY7Q0R5dREtRX5kXptoUl6uHYeMMdBf+UsPwo+cZsgVWrUnGL+5v4QDflrOVUp
         Vn2vU+4ZzdHZlSFR9DExoDJ1tGg45AeTzMovlDqg6PuZFXVBzUu/VfvgMug/uw1GOxpp
         A33iCiAr5cNeo6S1FMYcXKit8tUjWsw+h3ttM/Uea/Yggrtccd1bONhmO2uqajK7WLbi
         vtwuXcVoUigUYcmflwN5AzGP4RbZ2Oh9wJ5U6GQt5/+4Vwus242zcHxfWtdRZyPaRB8G
         bEwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id a2si2028365pfb.166.2019.01.30.09.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 09:26:48 -0800 (PST)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TJHNjWk_1548869202;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TJHNjWk_1548869202)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 31 Jan 2019 01:26:46 +0800
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
 linux-kernel <linux-kernel@vger.kernel.org>
Cc: mhocko@suse.com, hannes@cmpxchg.org, dan.j.williams@intel.com,
 dave.hansen@linux.intel.com, fengguang.wu@intel.com,
 YangShi <yang.shi@linux.alibaba.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [LSF/MM TOPIC] Use NVDIMM as NUMA node and NUMA API
Message-ID: <f0d66b0c-c9b6-a040-c485-1606041a70a2@linux.alibaba.com>
Date: Wed, 30 Jan 2019 09:26:41 -0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks,


I would like to attend the LSF/MM Summit 2019. I'm interested in most MM 
topics, particularly the NUMA API topic proposed by Jerome since it is 
related to my below proposal.

I would like to share some our usecases, needs and approaches about 
using NVDIMM as a NUMA node.

We would like to provide NVDIMM to our cloud customers as some low cost 
memory.  Virtual machines could run with NVDIMM as backed memory.  Then 
we would like the below needs are met:

     * The ratio of DRAM vs NVDIMM is configurable per process, or even 
per VMA
     * The user VMs alway get DRAM first as long as the ratio is not 
reached
     * Migrate cold data to NVDIMM and keep hot data in DRAM dynamically 
and throughout the life time of VMs

To meet the needs we did some in-house implementation:
     * Provide madvise interface to configure the ratio
     * Put NVDIMM into a separate zonelist so that default allocation 
can't touch it as long as it is requested explicitly
     * A kernel thread scans cold pages

We tried to just use current NUMA APIs, but we realized they can't meet 
our needs.  For example, if we configure a VMA use 50% DRAM and 50% 
NVDIMM, mbind() could set preferred node policy (DRAM node or NVDIMM 
node) for this VMA, but it can't control how much DRAM or NVDIMM is used 
by this specific VMA to satisfy the ratio.

So, IMHO we definitely need more fine-grained APIs to control the NUMA 
behavior.

I'd like also to discuss about this topic with:
     Dave Hansen
     Dan Williams
     Fengguang Wu

Other than the above topic, I'd also like to meet other MM developers to 
discuss about some our usecases about memory cgroup (hallway 
conversation may be good enough).  I had submitted some RFC patches to 
the mailing list and they did incur some discussion, but we have not 
reached solid conclusion yet.

https://lore.kernel.org/lkml/1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com/


Thanks,

Yang

