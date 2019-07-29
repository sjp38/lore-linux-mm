Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48248C7618E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:27:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19C59206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:27:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19C59206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAD4A8E0006; Mon, 29 Jul 2019 11:27:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5C968E0002; Mon, 29 Jul 2019 11:27:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4CA08E0006; Mon, 29 Jul 2019 11:27:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8191B8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:27:38 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id m1so26580011vkl.11
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:27:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=8xbb/FjrwKKI0IQkehdSVj7NRbt4D1OnqJy1F4uBWaU=;
        b=AUoJ305Uzw1p2J/qEo1NC5TTZDf4TBXwCShfGoURoWRqJr8BM97jbR8ydflKVsCYRT
         TYWltOop+kgARpwWAq1vkHm/bs+2DAAHFuN4U1tnDU1elH5NaxdunlGSsUPh7RSWOG0M
         Rs2Rf5T8wKp80/1y19ZMu5Xeb2t0Gr1Bqaj0b2HlRRVL3OQkXqlG59oWzO4LxH4/Sdif
         VT8CnS78ReTrtZ4fBHhMCrHa7xYGBWs/IvtPWbHSZzowgzeXf9icFKbd3oLv05qdmhGC
         giOia1/SRZS13pTXtj6CU14jgo36hpl2+BUTWI12oSBcUWeqVko6EDQ7ESpwHrXmwORG
         VK9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXAArxmGbsRZGyQKzYshySldaW6hAq4gQp2eR8xZh8K634Gd0dg
	8CMGzDQljJAXTzvG/Hcot2YrFSdvoZWedn0S8K9KRC35oJON9+Sew8L+H2Ge465TDMmA7CHXZk0
	XIw4RXg8s2XdSqKCY5RtsisQKjxfgNfrEeLZP0U/YCd4tYaam/UC3GLanizBs7IB5VQ==
X-Received: by 2002:a67:f355:: with SMTP id p21mr70036443vsm.204.1564414058217;
        Mon, 29 Jul 2019 08:27:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/ih4FQ4n6PdTgheziKLjImaGenBRyIXC18OvXYylfKIjo5g3MxaLWVXiUabBOsY+36j5U
X-Received: by 2002:a67:f355:: with SMTP id p21mr70036391vsm.204.1564414057613;
        Mon, 29 Jul 2019 08:27:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564414057; cv=none;
        d=google.com; s=arc-20160816;
        b=nAMDSYqA3vBMxNaWr/sw6lBAzNZfkVCF716V+j2F12LXSKQKKi0zlF/mvl0V202z19
         ihCJHtssR+FYT60po+F3MB6+gFrlGB6oj3s+OfyWHKyUjJpgmFJvv6I/MFQla/brV08p
         5liTq2zMeGB7rfmKopCpHKiU6IxGdsLAzw7SocZbzAcTTTXqFBdyQcRYgbnFlMiGn9rR
         39mUgaII3+2kxVn2YcEKzBP855PPN+xgdFxkS17qUPRXLPfVCDskPB+qg+cW7q0uf78c
         HUWl24VUwGnXstr3hRRhOt3oKNwVFixE92TrnhzLNb7UZZ6ae8bEWz4BfNjpD2+SmSiY
         jccA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=8xbb/FjrwKKI0IQkehdSVj7NRbt4D1OnqJy1F4uBWaU=;
        b=uU3MXXPg51FlamChHrSKEf931yCWnycR58rWKeTrUGZusJaPk9frSrpikMvjCMAcl8
         1oW+f3YSVbbCgl2hG0mTYMZvsv5UkilInmGfgOsMUFEXHMc4jzPlp2KmI0IBV5W//H1s
         KkpZ0Md7eh8VlnjexGeplpt1qC2KDyqJMTcpRVs8qkBcyQBY2VeioZJr/dYaMbyW/l9o
         QMH5OR071dIGCxIWrNBwfUgeN6n4HOnWJTpeOUdYidj0jSy/ifnMriKCny+HO7gDNygc
         SUaNMhx9rulkLHlAcQennGdYMSpwVza5FELb7LKru0npmOhPOUimmeDTykf06JgTWazg
         3/WA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u7si13711945uah.1.2019.07.29.08.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 08:27:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A19BE8E22B;
	Mon, 29 Jul 2019 15:27:36 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DF0C510016E9;
	Mon, 29 Jul 2019 15:27:35 +0000 (UTC)
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729091249.GE9330@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <556445a2-8912-c017-413c-7a4f36c4b89e@redhat.com>
Date: Mon, 29 Jul 2019 11:27:35 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190729091249.GE9330@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 29 Jul 2019 15:27:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 5:12 AM, Michal Hocko wrote:
> On Sat 27-07-19 13:10:47, Waiman Long wrote:
>> It was found that a dying mm_struct where the owning task has exited
>> can stay on as active_mm of kernel threads as long as no other user
>> tasks run on those CPUs that use it as active_mm. This prolongs the
>> life time of dying mm holding up memory and other resources like swap
>> space that cannot be freed.
> IIRC use_mm doesn't pin the address space. It only pins the mm_struct
> itself. So what exactly is the problem here?

As explained in my response to Peter, I found that resource like swap
space were depleted even after the exit of the offending program in a
mostly idle system. This patch is to make sure that those resources get
freed after program exit ASAP.

>> Fix that by forcing the kernel threads to use init_mm as the active_mm
>> if the previous active_mm is dying.
>>
>> The determination of a dying mm is based on the absence of an owning
>> task. The selection of the owning task only happens with the CONFIG_MEMCG
>> option. Without that, there is no simple way to determine the life span
>> of a given mm. So it falls back to the old behavior.
> Please don't. We really wont to remove mm->owner long term.

OK, if that is the case, I will need to find an alternative way to
determine if an mm is to be freed soon and perhaps set a flag to
indicate that.

Thanks,
Longman

