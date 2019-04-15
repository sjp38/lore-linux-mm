Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E294C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:26:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B77020663
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:26:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B77020663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03CA16B0005; Mon, 15 Apr 2019 18:26:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F05F86B0006; Mon, 15 Apr 2019 18:26:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA6086B0007; Mon, 15 Apr 2019 18:26:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2976B0005
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 18:26:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w9so12089519plz.11
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 15:26:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=PM0dA4W0SaI2pjNagSolUyV+vwZzWJPKwFT2vd7LFNs=;
        b=a4zuUWN4hlkukdiJgAI3bybAjZg7Z/2KNYNH+UNT6q+w8VScdkhpw60Ea7C9bTeek+
         vdYTw6fKgP9Idj6J+Nyyo+Q8fO5VUpkoC0P3AGyycKkcTaVZ+XlzFoYKi5Vfd5GSMQr9
         2+7tF0yeSLXpSi/RsdfDjfxsQi356bTPImZWfMYQsE8GBL6B4PAX9BeFEg2ys08q/cWU
         7xRz1T7isYTqVatgQ22ZrP8orib3ayR+2qbD+ynznYUEklvSExt99GqEqvlei3d1UFgP
         Yeq11vmldDMVtBmo0ejMJgMuiA+o12sfM0c5TV5yDSH2h89o65wpgBW9MrVOXz1J2O/+
         +kQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXQ8yTgvDfP5cBuAA99dBkJxohfKrYvATRWlUhKjmY7gXuwBLl/
	ebMnk2bFhSxrOq/3JzVmxkkS0K4wui349OJfv7G39fyQLQyFZgJYNSBYIUJh9RPrkM+DfeQ3zcd
	S6MKW6JqiRY/l7lyfZWrps58D9SuugppdDDHUuf+S2B3NAjqsFq6RtSJuVbS4IutrGQ==
X-Received: by 2002:aa7:83ce:: with SMTP id j14mr49629299pfn.57.1555367205318;
        Mon, 15 Apr 2019 15:26:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGJ5Z2CDhgVQv21oqDZ6g66NEHIZGLKAtA7paBYIE97p97aZSGDGVsivxeIVzIydl5Uvg/
X-Received: by 2002:aa7:83ce:: with SMTP id j14mr49629254pfn.57.1555367204684;
        Mon, 15 Apr 2019 15:26:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555367204; cv=none;
        d=google.com; s=arc-20160816;
        b=L8JU1/VKr29gNVkmWiw6xxQ2OJOr7GjK0v/QU8NW1xFFBIGcwaNPDU9+TZ2acoCegn
         BRpKG21/Rptvol8+Wyd9cVLwT+MxY2QliHB03hneQcaxAI7LxJWe+xx6wKehHGJ8/dk4
         8DOtaMlUbsAqxwsPeISXc/eCWiz3Rcjrn9flN+oaDU6yd6alS/xpAEFnbdcq/r0QGZJo
         SpJansqMvANsuvI6QWlX8DpxNmLSOow0I3rv32q6uYLoRMKXLTEQgAMlvvwwuQRIDx4B
         uSy7MWL/9TfhMkcT26yFPY4NEABr+knbfcPrwlTL+wlM3ch+MBuaeBZ/s6jrrkMVQxlx
         noHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=PM0dA4W0SaI2pjNagSolUyV+vwZzWJPKwFT2vd7LFNs=;
        b=hPSXfnjXgT1NHJr+Ji06Zz5tEXkkpOhcxmOJnOVd08ybsk1zGQjt7+Rq1kV4XJLXG8
         C9ttKkkUdqxUJbq7pn0H0OkuOz23JqXyVE83Xpmv0KBeOoJ1k6YqbZczm7DfNNRQO+3e
         kwh/HPj+wKx5qyczkq/NWNLonHVHR4k+2751ZU+K1LEnqIrzjb2yLHGnEbMcCbDRZpMl
         5rQVhPaF1p4jylwQOKHx2txHN/Yk+DpewRPu3sb/zt74r4ehTr/JYvmcEhjAzdtlX9U2
         HC3JDKbe1RhcCCkaeEUbxFIHPT9loMUBaok1zNdeD6wdV86ygseRkfrLsgFMMNXGGBpA
         pAAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id o19si43924481pgv.355.2019.04.15.15.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 15:26:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPPhBLZ_1555367198;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPPhBLZ_1555367198)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Apr 2019 06:26:42 +0800
Subject: Re: [v2 PATCH 5/9] mm: vmscan: demote anon DRAM pages to PMEM node
To: Dave Hansen <dave.hansen@intel.com>, mhocko@suse.com,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <1554955019-29472-6-git-send-email-yang.shi@linux.alibaba.com>
 <bc4cd9b2-327d-199b-6de4-61561b45c661@intel.com>
 <0f4d092d-1421-7163-d937-f8aa681db594@linux.alibaba.com>
 <42f2a561-f675-14d7-8d4f-87acfe0a18e9@intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <745e396c-d9e0-b222-acd4-2a586832878b@linux.alibaba.com>
Date: Mon, 15 Apr 2019 15:26:33 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <42f2a561-f675-14d7-8d4f-87acfe0a18e9@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/15/19 3:14 PM, Dave Hansen wrote:
> On 4/15/19 3:10 PM, Yang Shi wrote:
>>> Also, I don't see anything in the code tying this to strictly demote
>>> from DRAM to PMEM.  Is that the end effect, or is it really implemented
>>> that way and I missed it?
>> No, not restrict to PMEM. It just tries to demote from "preferred node"
>> (or called compute node) to a memory-only node. In the hardware with
>> PMEM, PMEM would be the memory-only node.
> If that's the case, your patch subject is pretty criminal. :)

Aha, s/PMEM/cpuless would sound guiltless.


