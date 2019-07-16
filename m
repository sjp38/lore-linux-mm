Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42A3BC76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:29:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 055B22173E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:28:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 055B22173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 631DB6B026A; Tue, 16 Jul 2019 13:28:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BBE78E0005; Tue, 16 Jul 2019 13:28:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45C6F8E0003; Tue, 16 Jul 2019 13:28:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B16F6B026A
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 13:28:59 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a20so12748646pfn.19
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:28:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=ZiRPJ1odE/yKUkNH9jgmHyy2GXLGe0eNdX9dEhXVEKY=;
        b=lvmGS1/s3CK3OkXMqh8SvOhvx/abi2hIpOUlhz1MK9A5Zc5rzM3/6ZF3j8fLPlZpfD
         EEQnmHOCeF+J6QUxdOR/UD+msH82e8hd/OeQGmqZ1LrbmeD+z595vZrAiKjVLGnD/dnF
         kcD3Ffx0BnmwMuK1dvE+vwMJKtPREhrpDFrx3EIoZY2g0IrCSIW71i5NzoIMnBw2DrCj
         mY5AdrauNxtgRg1+b4QnOd5EKRf6kRyzAhkXH9Ty8LNBKPxL8PS+ldVvopfAHpCKVNYW
         ok//PtUldtnJHBHYs8zMVyFF1MEYSGi5+D3cecAWQRidckMGpn2T+m4EJ5O5+OmMNXOn
         yeAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXvcRq/PBie3aHfa89MoFkN905bNKzh0kZUqBpsvBGzGiTMcUoc
	LidN4C/+Un4UbZxncdwTzIqgOJSflchuQdcHub++Ftwf4s8dvncEskse/4He0vso0fRcBXy8EpJ
	PBw7yqbQzIxUigy+qXtUJW+WtqFI3eOa6KwiH3wzpbdjhu5DjtTNBHby9ZXNBOUJRJA==
X-Received: by 2002:a17:902:b70c:: with SMTP id d12mr35906845pls.314.1563298138384;
        Tue, 16 Jul 2019 10:28:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUdn49Z0RTItRHqKvFqYZS+JV/oI2EV7k3g/4byJNL1haAp4rlnawTRCFYrRENb7+yIjfP
X-Received: by 2002:a17:902:b70c:: with SMTP id d12mr35906773pls.314.1563298137675;
        Tue, 16 Jul 2019 10:28:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563298137; cv=none;
        d=google.com; s=arc-20160816;
        b=rvPEA++qH/WrYXdoy6rO9QqRtjDG+nIghF+iYRvE0sYMv1Cjjq0kegVV/bfMiSIgDQ
         YJwCXtWaKdHaCx0q+OkKG54hwhINUArPwRb2S8Qa4vuGtQtCw82wlhOUgyKI8UTi+1So
         Nu+mvAhSjC+GAI3l3/VodJn/QsgFwHX38vnRKDENkLyf2bdhCA1mX3eINOssNrEoF9us
         HwSdCtaO07vntQntBiZBfmRxcfkNLRArKTROHiyBbPlw2NYdecyIynyjVl/z/e7R7HU6
         r+7nXOWtEYocf3v1Cqk9OXX2vcsP0BUNPDGDd+bubIyTF0isc+uVshO5bOKTVL61fCNc
         sfkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ZiRPJ1odE/yKUkNH9jgmHyy2GXLGe0eNdX9dEhXVEKY=;
        b=Cwu2s8VtJCykg33AWQDTBVYhrPxJbclz2LsY6xKT43IsW7PisT0n1xSPbCwfndzBwf
         jZ1C55gsSGcoRXsfNCgQJFlOQnD/VeJ66wN532K4mI99qws2dAIXaWoL/4mAkfEOydIA
         EgnDW9+SgM+3LgZbSHZbIMX2xLyxf4+UB++Yt9sh3eg8EsAnvfSMxr3OF8VtLZ/QEC97
         0JIadbtLqb6Oqh1e5z2oEk+pNLdlGwrLlQKMNK3DEu0iDneuwitgp8MzGwNpcz8/VZGG
         d5X01v93mai5kKgDxw8liZe8mpps+2Pl7EgVvSXID6b5Hmii6Km4fUr73+TpTpBIA5/W
         s41A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id f10si15763662pfq.194.2019.07.16.10.28.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 10:28:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TX4BEhE_1563298132;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX4BEhE_1563298132)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 17 Jul 2019 01:28:55 +0800
Subject: Re: [v2 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages
 mapped correctly in mbind
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <1561162809-59140-3-git-send-email-yang.shi@linux.alibaba.com>
 <0cbc99f6-76a9-7357-efa7-a2d551b3cd12@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <9defdc16-c825-05b7-b394-abdf39000220@linux.alibaba.com>
Date: Tue, 16 Jul 2019 10:28:51 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <0cbc99f6-76a9-7357-efa7-a2d551b3cd12@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/16/19 5:07 AM, Vlastimil Babka wrote:
> On 6/22/19 2:20 AM, Yang Shi wrote:
>> @@ -969,10 +975,21 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>>   /*
>>    * page migration, thp tail pages can be passed.
>>    */
>> -static void migrate_page_add(struct page *page, struct list_head *pagelist,
>> +static int migrate_page_add(struct page *page, struct list_head *pagelist,
>>   				unsigned long flags)
>>   {
>>   	struct page *head = compound_head(page);
>> +
>> +	/*
>> +	 * Non-movable page may reach here.  And, there may be
>> +	 * temporaty off LRU pages or non-LRU movable pages.
>> +	 * Treat them as unmovable pages since they can't be
>> +	 * isolated, so they can't be moved at the moment.  It
>> +	 * should return -EIO for this case too.
>> +	 */
>> +	if (!PageLRU(head) && (flags & MPOL_MF_STRICT))
>> +		return -EIO;
>> +
> Hm but !PageLRU() is not the only way why queueing for migration can
> fail, as can be seen from the rest of the function. Shouldn't all cases
> be reported?

Do you mean the shared pages and isolation failed pages? I'm not sure 
whether we should consider these cases break the semantics or not, so I 
leave them as they are. But, strictly speaking they should be reported 
too, at least for the isolation failed page.

Thanks,
Yang

>
>>   	/*
>>   	 * Avoid migrating a page that is shared with others.
>>   	 */
>> @@ -984,6 +1001,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>>   				hpage_nr_pages(head));
>>   		}
>>   	}
>> +
>> +	return 0;
>>   }
>>   
>>   /* page allocation callback for NUMA node migration */
>> @@ -1186,9 +1205,10 @@ static struct page *new_page(struct page *page, unsigned long start)
>>   }
>>   #else
>>   
>> -static void migrate_page_add(struct page *page, struct list_head *pagelist,
>> +static int migrate_page_add(struct page *page, struct list_head *pagelist,
>>   				unsigned long flags)
>>   {
>> +	return -EIO;
>>   }
>>   
>>   int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
>>

