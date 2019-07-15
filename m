Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 911F2C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 23:54:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6149120866
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 23:54:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6149120866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 097046B0005; Mon, 15 Jul 2019 19:54:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0208B6B0006; Mon, 15 Jul 2019 19:54:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB5A26B0007; Mon, 15 Jul 2019 19:54:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A72606B0005
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 19:54:19 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n9so8018956pgq.4
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 16:54:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=CUw9J2bSKebJlQSDB9zUBHgSg9piR8cEAasHFCoJRmw=;
        b=XnxAb+Oeacj56KOan+/W53DWR+W/0mxdcZ1AyIU/3AwmlHBdyF2jh1wiRnyAenVRAB
         Rve53tB2iI1MaGibfF8pAZ1cY1MM98bveOlRqbZVhcYfOFWnF0r/08o/o5JuBWvc6TS3
         KELg/lx1n2g2x4Sybi97U6rDE5Dm914isYPgfnF3nYuOzUi90B5XDJruK98C+Yj35g87
         3hOCmc5INMHfHLstKNAc5c+ii5VOPOtaHut5ckVg7DQ+cpOpwn8nNGlzq6U0tIQOQ6BF
         fWIebz+fBaLTkDnN2KekfH4D1pQcGBMN7W3Y3gMmKcpwEm7NQ2wBKmio7Q8nUEQYb6RX
         5cXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWg3AMelLEkgnYrolHnr3UUlHN290bBUp24GNDg5sfusXK6xNSB
	JgS1Te+U1thIP2v3uadj95vDJgsYnuP8KzYn6DqTEWUUlYCf1DpfGwfG4mY4GsMFtxmXELiOCNe
	VItUIHRQEO/loMnfor84l6IQdK02v9rrm7o3X2g1URBGiabO8itxqEVC32ZmZ9SOYbg==
X-Received: by 2002:a63:ce01:: with SMTP id y1mr26540431pgf.389.1563234859217;
        Mon, 15 Jul 2019 16:54:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysym4XzCRcu2XMMr4bgFIGwZT+/O9SNeyan71wp8OlqTwXJLX8ovjxbdx4srLbh2Ck9PrN
X-Received: by 2002:a63:ce01:: with SMTP id y1mr26540386pgf.389.1563234858533;
        Mon, 15 Jul 2019 16:54:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563234858; cv=none;
        d=google.com; s=arc-20160816;
        b=BacIAKg10GtNnICHED/iMEI1XdjIA/OnPTsR+Io0j0zmdm2Amt8jq9q0Nke4T+ZhKU
         7YLyIhP6lNdcNopWjh+jfL0ZCyT+Pj7/SgxE4JZ8Itj0skg/FHB8R3KHDOaGw1Qv08Ec
         cduM7+XMV9x+pI7YvSqS/zO4RlxqByfAbO8jSwN2FdDgvD5fXy3FwEnGgoWNMh48adz6
         TyfYbn40lropCbd6IlWDgG8v0aAHApg7temrd2vZhAzSHnQM+IdPGV1E+r1Y00jdxfMO
         x6yISAlRrzT94pTDKiIvNIqEsLaCqGqsiVSMLXb2pvDrrxrziXgPkgPhqKHl3pqtmFvG
         NYVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=CUw9J2bSKebJlQSDB9zUBHgSg9piR8cEAasHFCoJRmw=;
        b=JwRbpf2MMwF0byDnRQgeixM4M3OCxDopkKrZV26mfLppjn25W/PYCOBendoyRrHqWu
         tUsTyZIXi/QnVbDPX+7T8CqxUeqBT+7chSlkxXdvl4lrvvlV6/ruDI84l0AA1YJK8WXF
         5H4sl/zZ2z7HGktoNG70DewYGBVGiLqIISZvj3ow7CUpkjBkNXz2aaED30T2xuaxYIar
         QbrRsI6tvQVVrEzeIRyzR2kEeWtbXhT/d1sBgjkVCCywZCAGHapf/tTYqkeskDgRwbBS
         0rsypRLRYMX1RowChqvw5esYur4H7QbWSPukVAQGpWdtN0zhBTjioV3ffGD5k+5DzZwN
         WwUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id f3si16634064plr.187.2019.07.15.16.54.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 16:54:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TX0LHkZ_1563234851;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX0LHkZ_1563234851)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Jul 2019 07:54:13 +0800
Subject: Re: [v2 PATCH 0/2] mm: mempolicy: fix mbind()'s inconsistent behavior
 for unmovable pages
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vbabka@suse.cz, mhocko@kernel.org, mgorman@techsingularity.net,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190715152255.027e2e368e16eb0a862eb9df@linux-foundation.org>
 <600c7713-2a6a-efce-69e6-9519d6aafaf1@linux.alibaba.com>
Message-ID: <ac6df169-84cd-b3e4-f1e4-b82b4cb60da3@linux.alibaba.com>
Date: Mon, 15 Jul 2019 16:54:11 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <600c7713-2a6a-efce-69e6-9519d6aafaf1@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/15/19 4:51 PM, Yang Shi wrote:
>
>
> On 7/15/19 3:22 PM, Andrew Morton wrote:
>> On Sat, 22 Jun 2019 08:20:07 +0800 Yang Shi 
>> <yang.shi@linux.alibaba.com> wrote:
>>
>>> Changelog
>>> v2: * Fixed the inconsistent behavior by not aborting !vma_migratable()
>>>        immediately by a separate patch (patch 1/2), and this is also 
>>> the
>>>        preparation for patch 2/2. For the details please see the commit
>>>        log.  Per Vlastimil.
>>>      * Not abort immediately if unmovable page is met. This should 
>>> handle
>>>        non-LRU movable pages and temporary off-LRU pages more friendly.
>>>        Per Vlastimil and Michal Hocko.
>>>
>>> Yang Shi (2):
>>>        mm: mempolicy: make the behavior consistent when 
>>> MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
>>>        mm: mempolicy: handle vma with unmovable pages mapped 
>>> correctly in mbind
>>>
>> I'm seeing no evidence of review on these two.  Could we please take a
>> look?  2/2 fixes a kernel crash so let's please also think about the
>> -stable situation.
>
> Thanks for following up this. It seems I have a few patches stalled 
> due to lack of review.
>
> BTW, this would not crash post-4.9 kernel since that BUG_ON had been 
> removed. But, that behavior is definitely problematic as the commit 
> log elaborated.
>
>>
>> I have a note here that Vlastimil had an issue with [1/2] but I seem to
>> hae misplaced that email :(

Vlastimil suggested something for v1, then I think his concern and 
suggestion have been solved in this version. But, the review was stalled.


