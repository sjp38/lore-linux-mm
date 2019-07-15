Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEC70C76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 23:51:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF57821721
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 23:51:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF57821721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B6686B0005; Mon, 15 Jul 2019 19:51:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 467F86B0006; Mon, 15 Jul 2019 19:51:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 356FF6B0007; Mon, 15 Jul 2019 19:51:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00F596B0005
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 19:51:47 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so11179744pfd.3
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 16:51:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=yMGR3oF0jyG+U0bKWCJNsf0IR+FGc12L4n3CVcEmVk4=;
        b=jDnDSGotPL0mNJXOuKipqj/Ig8/wISi6xajfMyZKIqB7aBxNY/E0L3uyeRYg3ttAO7
         k7LlQ+Z+Q9lgU2IL9qsjKpA2SfIQTvDt9Qa6nggngxra+5iWvU/qS+vEsvfnGEsdwLUG
         RuRjlCvOHpZPrz/vbO19In5QDDqN9axBUuvzxLxz1seC5GYVUWp/bUTX7p8gCjUPD5oD
         4l4byfe7DBv4ad2LqqXggQ9/SKivpsWI5FS4Cl299YOdxOwyQzmAm8/lcRUhWu+d2NEY
         Kn43oYnw4PMHYBfRgtfCXryudOCQleGre9jH7AJR5WcE0HZ3DBhJdVHefgjgVuR8dQyx
         qAFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWS+XqWOggo+0UuB4ELPgmcOfLlNUWlE4z6KxgI918KPVNJeImg
	EFFLs1kEuFsEtCgFJnH47I8aFbyQu1fscfpty/QElOHK7gA8Nn0V12EV3LCTEIKPE5NZs9LmC0/
	Mvar6kvQxlHT0ynb4QFyyYmuWvTW0ADSku62nS658wSN2XdQn+U0K+ETCrCfwGGFffg==
X-Received: by 2002:a17:90a:214e:: with SMTP id a72mr33170466pje.0.1563234706661;
        Mon, 15 Jul 2019 16:51:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy27//HtToVzaoZsZ9ALPY4RCEF3MPoITD16CU+sd862HsoHSnRoGF3zY37s0ykT8Iykt1m
X-Received: by 2002:a17:90a:214e:: with SMTP id a72mr33170394pje.0.1563234705618;
        Mon, 15 Jul 2019 16:51:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563234705; cv=none;
        d=google.com; s=arc-20160816;
        b=rkkkCPAxCdyrur3jCU1nQEmkxYSK2nXBV6ax0Kk4/UKb8IDbn++YQ1E1uTBaz4ydBn
         uzvFymQ9coZhVe5+ynujPJGkpW+Zfyj7qaMVj5G3RMNnRzmqwQvt7I17XOaMU6WtY8pJ
         KOn3j+pcgdDvlXoCYVXFy2+2Dc5hFBsK8vIHf18rGcusElYIsr+d3alGeYz70lKBagUg
         ycajosVSXsqtGacRqWBv82Isn52PtW8LRY3YVnjeFwbl/JmfIJ5nscThH+BDtRtsACeh
         L8JFxcStvAVhvFyWz6Mp2ePDE3x7CYNWheEeEO0ZFGFZH+i8AAUVCJKUdBGWFWAOTMnG
         M7tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=yMGR3oF0jyG+U0bKWCJNsf0IR+FGc12L4n3CVcEmVk4=;
        b=nP7lBlp3C6Fyu5eg4KH8fRpFOGpvRnvh9omQwEsOH3/LXMerhHupKu/WRFrpwqviCr
         5SZhMTArsDJj3XxzqcPhMlnNaP2Xq2PIjVor3bylbseOVDSSg2sOG7JTQcdgjzHcMMEo
         bukxsYrulumwDOulRnzaxNugMLVo9U/IxXVofE9Z80XaIhUsOOfO2yArkLrG8L2sYgO/
         x6n9RTgZby7Ugp+b0U3GUY/wFjb7OTKmwbLuLNIw3d4w+YFKNm6KhyX0CiJdcqAqpCZu
         1peujyUpJvY/+m5AA0Be1ciInzf7XlanTKQECvy4nfXBOYqRA+foWbMHb229/T2+8VIp
         1ETw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id p44si20985523pjp.0.2019.07.15.16.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 16:51:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TX0PJ-d_1563234700;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX0PJ-d_1563234700)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Jul 2019 07:51:42 +0800
Subject: Re: [v2 PATCH 0/2] mm: mempolicy: fix mbind()'s inconsistent behavior
 for unmovable pages
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vbabka@suse.cz, mhocko@kernel.org, mgorman@techsingularity.net,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190715152255.027e2e368e16eb0a862eb9df@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <600c7713-2a6a-efce-69e6-9519d6aafaf1@linux.alibaba.com>
Date: Mon, 15 Jul 2019 16:51:40 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190715152255.027e2e368e16eb0a862eb9df@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/15/19 3:22 PM, Andrew Morton wrote:
> On Sat, 22 Jun 2019 08:20:07 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>> Changelog
>> v2: * Fixed the inconsistent behavior by not aborting !vma_migratable()
>>        immediately by a separate patch (patch 1/2), and this is also the
>>        preparation for patch 2/2. For the details please see the commit
>>        log.  Per Vlastimil.
>>      * Not abort immediately if unmovable page is met. This should handle
>>        non-LRU movable pages and temporary off-LRU pages more friendly.
>>        Per Vlastimil and Michal Hocko.
>>
>> Yang Shi (2):
>>        mm: mempolicy: make the behavior consistent when MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
>>        mm: mempolicy: handle vma with unmovable pages mapped correctly in mbind
>>
> I'm seeing no evidence of review on these two.  Could we please take a
> look?  2/2 fixes a kernel crash so let's please also think about the
> -stable situation.

Thanks for following up this. It seems I have a few patches stalled due 
to lack of review.

BTW, this would not crash post-4.9 kernel since that BUG_ON had been 
removed. But, that behavior is definitely problematic as the commit log 
elaborated.

>
> I have a note here that Vlastimil had an issue with [1/2] but I seem to
> hae misplaced that email :(

