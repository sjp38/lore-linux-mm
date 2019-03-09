Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 716CEC43381
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 06:23:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFFAB20866
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 06:23:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFFAB20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50C788E0004; Sat,  9 Mar 2019 01:23:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BBE98E0002; Sat,  9 Mar 2019 01:23:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AB0E8E0004; Sat,  9 Mar 2019 01:23:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA6E8E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 01:23:10 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id k198so22661600pgc.20
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 22:23:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :subject:message-id:date:user-agent:mime-version
         :content-transfer-encoding:content-language;
        bh=zY49DCIHgh9QItw2y0RB0JI8/9cUfABZiqrdlxdYWeU=;
        b=EcTF9qfl3jGbAtMUNM7G1/yDCiwWGlIMNst6mYkFcFY9LnkaXF3V8pqTHPzhNuD5lt
         IZMxCIgxE7+INq5pEGTxAgGHRgmpt6KfVdBjsozssFECC/M6HDWT3G0IZLuynEOPkvhq
         5KIQS4RsTlsBd7sZVf74451FzhvtktDvFNqSYFvx/7l4uzllUZ8UGGVuawoJcOV1h5xH
         yWJ1xLXVRpUrcTYDZTMZGMG5eGVNLKkqY1mjGW39gDAWlL8CBY4F/IMSXRRcFU8ehhAD
         FSsP+8P/Wuue0cCvIJVvx1MfAiNU+z6UwPTPrtuyqKd73r2QBwRYPOqcn4csbIT3NDOV
         +OeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVOwJxYKe1IKJRAIZ+/K8yZi87V3acNi+KBY9reVfmzcxaGUFPF
	YcM1Jaw89RWf6LsM+cQQcIjwAbFISqWkRgYnooSLVugFHL1gFfDULD8u9bV49zCHnft+V/oO+2e
	205rbWZWqDfSXz9xKD8+dqrzCNU9bC0Ck2ZPu+i9WoVZzPUqsDvGY0jIFiu9FiE3vXg==
X-Received: by 2002:a62:3990:: with SMTP id u16mr22348563pfj.80.1552112589662;
        Fri, 08 Mar 2019 22:23:09 -0800 (PST)
X-Google-Smtp-Source: APXvYqxJYZpVBx5iiX6LanlfOwqbYOh0FnGtuHTBpvVaZBLWy8Y6S9n8HoZGAztOqowOop3YMmQ0
X-Received: by 2002:a62:3990:: with SMTP id u16mr22348486pfj.80.1552112588434;
        Fri, 08 Mar 2019 22:23:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552112588; cv=none;
        d=google.com; s=arc-20160816;
        b=qtuNdi6F9jr9I56uzaOTzJ3x1Wr+R55ekHn/6IjhjTaB6LfUpX/lGRsRUlHhrVCX35
         zCBPj8J5pl0/kpn2kZucfbEFty3/qwawld+LxxKR6GG4GKkIkkFhdjKwTCELdjEhkBMM
         wEWEbK4eYbRPoQjUzLxEVhVbLU9H8dIiq8kVlFm/ocX5p4KL5jBYGKgoBbRcNZbGmUUz
         Q1nMXSpM9RGy7+TdSHqo6jSz1sbb3DPmKk2naUEtAQ8ru0xlzkkcwT9O3kYAEljIA/HS
         2J3iUQvtZ7vtKB5IGvwrARzb3cYHyjfJH4n25P3JjjOz5C7xjKZnzIUmIxliPbkpC/G6
         9oNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:mime-version:user-agent
         :date:message-id:subject:from:cc:to;
        bh=zY49DCIHgh9QItw2y0RB0JI8/9cUfABZiqrdlxdYWeU=;
        b=YeleMb3lSv3nk9EsxBa98uQUdsVS4zWtPRxxEU/QdFQFL9uSrUzwpMez4C1oCyP4kW
         jTQXIiLR8r4LAVABQLoa7FXyH49JNCCAcRnYzIufbNjAltix69Hn0AkcpaXiecDSQv44
         iRPsxuhTE3KnQ8aMJ19A7Sk+YtBDYI2kNmiGMrqm+DNp7rqROOn61hFTAJ8ahKWlTSd7
         opjH3zanKYxIPst1MKeSD4W1+DVzl9sA+qlsHtsMgCi1LISrHyPP9+MN9WiagZK/1aYc
         SlWnQ8+0IXXYrdb99FvvhtikRQNzvdhHdkq5n0u81TnHXW/+hd55c7JDVbAAoNON00mn
         g0dA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id 59si4384604plp.100.2019.03.08.22.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 22:23:08 -0800 (PST)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04389;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0TMJndTn_1552112580;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TMJndTn_1552112580)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 09 Mar 2019 14:23:04 +0800
To: mgorman@techsingularity.net, Michal Hocko <mhocko@suse.com>,
 Vlastimil Babka <vbabka@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [QUESTION] Is MPOL_F_MOF user visible?
Message-ID: <3f1f8f38-71fa-7a12-92cd-c3ad552518ff@linux.alibaba.com>
Date: Fri, 8 Mar 2019 22:22:59 -0800
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


When reading the mempolicy code, I got confused by MPOL_F_MOF flag. It 
is defined in include/uapi/linux/mempolicy.h, so it looks visible to the 
users. But, man page doesn't mention it at all. And, the code in 
do_set_mempolicy() -> mpol_new() doesn't set it. It looks it is just set 
by two places:

     - NUMA default policy (preferred_node_policy)

     - When MPOL_MF_LAZY is passed in. But, it is not configurable from 
user since it is not valid MF


So, actually it can't be set by user with set_mempolicy()/mbind() APIs, 
right? As long as the process' or vmas' policy is changed to non-default 
one (i.e. MPOL_BIND), those processes or vmas are *not* eligible for 
migrating with NUMA balancing anymore?


Thanks,

Yang

