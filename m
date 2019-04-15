Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98085C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:06:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 390302075B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:06:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 390302075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5D256B0003; Mon, 15 Apr 2019 18:06:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0CC96B0006; Mon, 15 Apr 2019 18:06:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D3FF6B0007; Mon, 15 Apr 2019 18:06:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66D6F6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 18:06:50 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id c9so8778692oib.2
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 15:06:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=yi1hb0QSpiRsbPVKNnaHPa/zZN7ZBbOpc0clvUL0Uak=;
        b=joNitKKS4sak1BMt+zWFG2G5gusMEsxBfxLIuglnICs+D8yNS0AUDyRpkIwXN4G2lT
         aeSSkSPO0uB5ELXKsbYa4hNzP8YnuaZDwayqC3cUUUWfloukbSIvYpy2E6dgMBzyK5Yo
         pgZJ3iikoOwG+SthM2mKLbWo4RTFNHrsq8fORF0xczrp9M1yfZwRy4hMSrV8/zw+yl66
         9Wq/3LrllGDAcVlCjaktLl88h13hDc4dbH3AhYgdVVS/Syj2EkuoUTX/DkVQQT4l9bm3
         6D9k5W7U9mPdRHe5DC1v1xjr1/V/3V5Zg1KMqI5FuSBiO8yjpLkjknBpxxAJEda/4J9k
         LUTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXza1vME+KR9/wHokNfyy6uwl3oMf+KDSEtiEhKWiskGmSiTAha
	Px0KpHo7Zw66ZgMM16Y9YCc+EfeYA88K+DMzB33rfcn95Yv3hURk8lmvz+frQTGqaRYE6isKMhg
	Lqdt64a1eSUDOttP32kCDw7JqBx39RZV6pFkRO6BZAkd30gN+e6M+/sq0rIYo2Hrnpg==
X-Received: by 2002:aca:fd57:: with SMTP id b84mr20969255oii.137.1555366009937;
        Mon, 15 Apr 2019 15:06:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp0Fnk8cl+OD9MprL/ttIH4dUL+6uTQbbmeutz1nWoaTn5sYAqnkPIhY6+Y6hhnRSWKtEk
X-Received: by 2002:aca:fd57:: with SMTP id b84mr20969220oii.137.1555366009235;
        Mon, 15 Apr 2019 15:06:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555366009; cv=none;
        d=google.com; s=arc-20160816;
        b=UpHHokNL1LNII/rQk5wGruTgVFmSD7WTeWTpTZ3ItUf8gs25m1mP2TNtUZBX3YtKFS
         pYzgzozQd2CHtbI8yo9QA0cgNEaBDkStHVoKHZaagd0HawGTzuALGIKBkgLnyJhStIFy
         Ge4KJSVdA4FVHh6s1yXmZrmX/YjAGC6EoX/ld91elhXy0qfZxQMPS3z6J+AyTfR8TMgv
         sG7gaemCkik4abHaY3+UTORdSL8dliT1j3uTFNvIm0nihR2CW1ESIxNmEOccSJxChigm
         FRWaGb8TMvsw0KcvP5KZC6+cWk0zNyzK/3jYg/9vkt8Q8x7jijUnWCMA4jieMxBtisNH
         b8Tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=yi1hb0QSpiRsbPVKNnaHPa/zZN7ZBbOpc0clvUL0Uak=;
        b=UZcVyWNBi2vGby9psOfw/Hi68lk6iltGTw19Um7Gkg7oE5V7mvt069+J/LxN3zLVhF
         elBzfnUwoZKL6ulVVpnmDfyH78O4JaeB23py/DkRbxyLXwEKH7UAxjNFOsSZMD5RAFzl
         5gfYTj2OUK1+brywLH1tVzYpNpmrh0ktrVlJOnfCxNYspVnZe2AYdnGpLHus+hy6oqTa
         WNSexVM5UWRPINCoUoXixVna8ZmDgJZU3WiY7s0twvSAS91DhiczRCQN90GcrVmuSk6D
         UM6qhppoTDSqdA3/ik3RgwjPDI69gv4IacEwBTh2gy5fl9OwUpHjIvFB8QOeiK04JP1x
         4S6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id w26si24767986otk.37.2019.04.15.15.06.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 15:06:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R771e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPPk8ij_1555365992;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPPk8ij_1555365992)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Apr 2019 06:06:35 +0800
Subject: Re: [v2 PATCH 7/9] mm: vmscan: check if the demote target node is
 contended or not
To: Dave Hansen <dave.hansen@intel.com>, mhocko@suse.com,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <1554955019-29472-8-git-send-email-yang.shi@linux.alibaba.com>
 <6d40d60e-dde4-7d70-c7a8-1a444c70c3ff@intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <5082655c-6a24-a3d7-1b7d-bb256597890c@linux.alibaba.com>
Date: Mon, 15 Apr 2019 15:06:27 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <6d40d60e-dde4-7d70-c7a8-1a444c70c3ff@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/11/19 9:06 AM, Dave Hansen wrote:
> On 4/10/19 8:56 PM, Yang Shi wrote:
>> When demoting to PMEM node, the target node may have memory pressure,
>> then the memory pressure may cause migrate_pages() fail.
>>
>> If the failure is caused by memory pressure (i.e. returning -ENOMEM),
>> tag the node with PGDAT_CONTENDED.  The tag would be cleared once the
>> target node is balanced again.
>>
>> Check if the target node is PGDAT_CONTENDED or not, if it is just skip
>> demotion.
> This seems like an actively bad idea to me.
>
> Why do we need an *active* note to say the node is contended?  Why isn't
> just getting a failure back from migrate_pages() enough?  Have you
> observed this in practice?

The flag will be used to check if the target node is contended or not 
before moving the page into the demotion list. If the target node is 
contended (i.e. GFP_NOWAIT would likely fail), the page reclaim code 
even won't scan anonymous page list on swapless system. It will just try 
to reclaim page cache. This would save some scanning time.

Thanks,
Yang


