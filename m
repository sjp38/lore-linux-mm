Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8165C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 00:59:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EE3920665
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 00:59:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EE3920665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFD266B0005; Thu, 18 Jul 2019 20:59:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DADDD6B0006; Thu, 18 Jul 2019 20:59:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9B698E0001; Thu, 18 Jul 2019 20:59:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 95BD46B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 20:59:57 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 8so12343536pgl.3
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 17:59:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=dXSpdNjsBaX2ezZ2/0hUVOxore8l0bG0I7XT6hh0+Hw=;
        b=GQfzq1BnhAZ7RMiHtsLAL597HlRzRStIVWEfRwPTHxBoRRUn2yj9XD7Nop4QAslWv4
         PCGPmqhRT6+/lSNU6IyZrot/Px+wtkDXxLoxuvp4T9EJZ73leuv15i3FWrtLm0lfz82b
         0TX1WAxCBUfDaF3kRypvPZtbFWD0PhJZUeIn+7xb5PllCSVnfUYF3yOzq3P4HjWQtvw7
         O22xybEg3EuwJpvkwUjjFfKcfPiSyy0KnGcZwjyN+gCFMDpd4mwiuPoOaKzHj0/XY473
         8WavggDKDOcwAEK1TrGCWmRxhD7+O0ozBNcAnxipRs1MKq04LzQMMLNUNe3u3XhzcV06
         OtUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWrNXlfHJfhA4mgCzQ/dneTMLuvYCv312+J0glMoLHxxH+qecsI
	lYhNQZY05FIpMvdvquQvCasas0BhmuU2t9nZzt0SKS6p+qIOg3qHh2V1ZT8okI0Ivx0H+iHHx51
	3wiAuX+vO6Rj5HWhbPHpKxZoREgZjE2WXLFnHfNf8r0NqGS2CG+vT7mrsCF9t/dv/8A==
X-Received: by 2002:a17:902:ac87:: with SMTP id h7mr55299634plr.36.1563497997205;
        Thu, 18 Jul 2019 17:59:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2QOP5erb5UQ0eqgPXaIIvUfuxuBUOQnGk4UEnkg+VsIzPYFspu5Oine3DVo0hJcSbZVUs
X-Received: by 2002:a17:902:ac87:: with SMTP id h7mr55299589plr.36.1563497996460;
        Thu, 18 Jul 2019 17:59:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563497996; cv=none;
        d=google.com; s=arc-20160816;
        b=os2NFRntJXu27pRrqLBivutMtIj/L3AcI+F+UhzVWT0Tu2HDhfwK+3vzxgJGvYkT4H
         8O+0Z9T/ale9DxbRJgFVfglQnMCK0A5oWqIDcpH5hsYjMHleJuRIpSmvFzWdSK7X9Ax6
         /vT8kQ5IjW6he48+dtW1Js/ROgA9c9s2sWDTy5F8oX/J1q93hLuPswwoN45mqDwEu318
         zVQwLE0fcWgQFA0tLO8ywHkXXObMf93vSV5dp3EH/rfUhVZ6lUJ+HwA7ICvQYzQU6BGo
         rNPesftDl2MlWB54t7qyr/kjFrJVZysFLZlZc7pjMwFPjwy07/FhicQXwF0GNa5dgrov
         3XEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=dXSpdNjsBaX2ezZ2/0hUVOxore8l0bG0I7XT6hh0+Hw=;
        b=Wmj5VnGWv+1wf+E21nneiI3uc8yyaB1tWRhnxLSHdxSr58qs/zDX/Jl9hWINh/FuaO
         m/dBYdlcCghNCD1LKFXounOpVzSTnNeIy4sjv7eKtxE2M8ouQUASig4Wdtk+ehhhAVAS
         qqtC61azu01ZwRZQD78Na/qJAFZAGXlAo5CEaGp3pTNPTPjb2SClRJ3dzbOkgxciaTAN
         Y2F7m/y8CVDo/pBD7urQYJChHl4E+cf5M6hPh0cliF0ayavC1DQ9v0pS/Qg25s+9tBGG
         BaM8Ca5vPfQuMmMz16SUksfwMMz+5vU21xSPLrjYONTsjom3fecgIsTxfjfMThe/XEud
         5kug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id d12si665020pla.121.2019.07.18.17.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 17:59:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R801e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TXEfKGN_1563497991;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TXEfKGN_1563497991)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 19 Jul 2019 08:59:53 +0800
Subject: Re: list corruption in deferred_split_scan()
To: Qian Cai <cai@lca.pw>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 linux-kernel@vger.kernel.org
References: <1562795006.8510.19.camel@lca.pw>
 <cd6e10bc-cb79-65c5-ff2b-4c244ae5eb1c@linux.alibaba.com>
 <1562879229.8510.24.camel@lca.pw>
 <b38ee633-f8e0-00ee-55ee-2f0aaea9ed6b@linux.alibaba.com>
 <9F50D703-FF08-44FA-B1E5-4F8A2F8C7061@lca.pw>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <7a0c0092-40d1-eede-14dd-3c4c052edf0c@linux.alibaba.com>
Date: Thu, 18 Jul 2019 17:59:50 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <9F50D703-FF08-44FA-B1E5-4F8A2F8C7061@lca.pw>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/18/19 5:54 PM, Qian Cai wrote:
>
>> On Jul 12, 2019, at 3:12 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>
>>
>>
>> On 7/11/19 2:07 PM, Qian Cai wrote:
>>> On Wed, 2019-07-10 at 17:16 -0700, Yang Shi wrote:
>>>> Hi Qian,
>>>>
>>>>
>>>> Thanks for reporting the issue. But, I can't reproduce it on my machine.
>>>> Could you please share more details about your test? How often did you
>>>> run into this problem?
>>> I can almost reproduce it every time on a HPE ProLiant DL385 Gen10 server. Here
>>> is some more information.
>>>
>>> # cat .config
>>>
>>> https://raw.githubusercontent.com/cailca/linux-mm/master/x86.config
>> I tried your kernel config, but I still can't reproduce it. My compiler doesn't have retpoline support, so CONFIG_RETPOLINE is disabled in my test, but I don't think this would make any difference for this case.
>>
>> According to the bug call trace in the earlier email, it looks deferred _split_scan lost race with put_compound_page. The put_compound_page would call free_transhuge_page() which delete the page from the deferred split queue, but it may still appear on the deferred list due to some reason.
>>
>> Would you please try the below patch?
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index b7f709d..66bd9db 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2765,7 +2765,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>          if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
>>                  if (!list_empty(page_deferred_list(head))) {
>>                          ds_queue->split_queue_len--;
>> -                       list_del(page_deferred_list(head));
>> +                       list_del_init(page_deferred_list(head));
>>                  }
>>                  if (mapping)
>>                          __dec_node_page_state(page, NR_SHMEM_THPS);
>> @@ -2814,7 +2814,7 @@ void free_transhuge_page(struct page *page)
>>          spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>>          if (!list_empty(page_deferred_list(page))) {
>>                  ds_queue->split_queue_len--;
>> -               list_del(page_deferred_list(page));
>> +               list_del_init(page_deferred_list(page));
>>          }
>>          spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>>          free_compound_page(page);
> Unfortunately, I am no longer be able to reproduce the original list corruption with today’s linux-next.

It is because the patches have been dropped from -mm tree by Andrew due 
to this problem I guess. You have to use next-20190711, or apply the 
patches on today's linux-next.


