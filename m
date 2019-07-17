Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D5CDC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 18:23:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08E5C217F4
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 18:23:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08E5C217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9980C6B0003; Wed, 17 Jul 2019 14:23:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 949626B0006; Wed, 17 Jul 2019 14:23:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 839028E0001; Wed, 17 Jul 2019 14:23:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE356B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:23:35 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so15132318pgk.16
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 11:23:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=LVkNM9KBxGs3gfer/i43OVLM53gtvQq7inPNEjJ40IE=;
        b=HMhzW+cDozpRHEzwKUvBprZWHx18PTcb259wFrTzM1auhuUFxOrxW6eBZYxHTIA6HZ
         qxLrt4q0GJll3jsBMhxttxoDLY5YV4HrEj4EOwkui6hXWROC4RPL+ubhmnGN8XLFuTlT
         MmuM8GdMsP5KaFiwms4XHE25Us7YvB0WUgOGJKCu7RZgnskm94oO7GF78ELslodbeuxK
         4i5I/oB47/up0WU+iAD7n+hg5SJVXZW2xgJsSWKf9apzR1yIks6tXdXnwyaRQphoEarJ
         3qX4qDJQKz6mnKurqB59abyKP4oyjty0NoPWwCQmY5DxUm8PAngcVZFF3P4w/mqCEbTd
         X2Ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX5JjWts7cBFOmGm306lEii8M33oUNDPMnRSN8RquMkk6JBpQGs
	0ilLOQkNCEVM2dqXBmuTf2icxwhxzO9/Dp3X4qk1aNfqt3/dbgrkPFyamjfsUzhukEhp/j4pe/S
	M7UEZpaRfFZngpAK/45bDnAga7wuHMKqQ39OgK/QeBK5igWESLqw/VtdBOnCj56hZaA==
X-Received: by 2002:a17:902:848b:: with SMTP id c11mr44654528plo.217.1563387814980;
        Wed, 17 Jul 2019 11:23:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgoE2ieMYqASKgY0+47JUgnZUFfoHm4CaagBVFlTEIBHquXZVcfrNFui3HtJqGMPoigZ1y
X-Received: by 2002:a17:902:848b:: with SMTP id c11mr44654466plo.217.1563387814133;
        Wed, 17 Jul 2019 11:23:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563387814; cv=none;
        d=google.com; s=arc-20160816;
        b=M3igxhqZ9vN4tZzB8/mUHNx5mg2mcLgBD03tC8c8TYSyXZK2K6LqmGywaYuG2VnEUH
         E/mFVnB/TlqOMUiiVN8gyZ3NmeZF021OcgFjkuWTL7+aLLdeEQiomoej49Ck/Xee+zoN
         +2dBR9XSZ9teQzNsxoQfJDAFc+mWO7P+v8PRQiS1wb7OSgfqBFJJQj3mSHCgHA92HrG3
         KZBXbCGPvPfrE/DVOtPQzMQAsaiLCrS6/ybr6s3eReU1vbIhzRobi2VLBJPLQV6kNLQg
         uq1BfyMIvh9yYHEDUZgo1a2QO6ZLcL9oO2a6VG5cW4J97dNQyeUORkE9NgMC3/iP7kVu
         ouRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=LVkNM9KBxGs3gfer/i43OVLM53gtvQq7inPNEjJ40IE=;
        b=BKQKf1KLvaSpHp4+I+ajQgLIyyE1mIeTbmaIltYjPRWN7/xStXVUxZtG0x4mQj08E4
         fQKeV1KhUjhX0rkdaj1P4Ui2OCJYkHzyVBbfy3OPy0cejA7aWTinTiEX7Wr9KMwZfukI
         Y9LbbWGwTkVuBelWE8a77YUfRJsFPi/mNq/Qm1euzt6YHG1j2V0Ab5MuKh8eEYVpkKfg
         9ULn7N4oIpPIQ1CqqeLfXaHkOzsu495718NzTxVY2IFNwpBPAkP8f/PSFxZmx/Jp366p
         EJtXCMAToOksM0Qa1Bc9VjQtz2hELHLL77DrlK4wp35kUQHEtGVJyGZpm8De6jN3SwbI
         Jr7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id q2si146055pjv.99.2019.07.17.11.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 11:23:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TX8swo._1563387797;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX8swo._1563387797)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Jul 2019 02:23:19 +0800
Subject: Re: [v2 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages
 mapped correctly in mbind
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <1561162809-59140-3-git-send-email-yang.shi@linux.alibaba.com>
 <0cbc99f6-76a9-7357-efa7-a2d551b3cd12@suse.cz>
 <9defdc16-c825-05b7-b394-abdf39000220@linux.alibaba.com>
Message-ID: <3197a7df-c7bc-2bac-3d40-dbfc97d4a909@linux.alibaba.com>
Date: Wed, 17 Jul 2019 11:23:16 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <9defdc16-c825-05b7-b394-abdf39000220@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/16/19 10:28 AM, Yang Shi wrote:
>
>
> On 7/16/19 5:07 AM, Vlastimil Babka wrote:
>> On 6/22/19 2:20 AM, Yang Shi wrote:
>>> @@ -969,10 +975,21 @@ static long do_get_mempolicy(int *policy, 
>>> nodemask_t *nmask,
>>>   /*
>>>    * page migration, thp tail pages can be passed.
>>>    */
>>> -static void migrate_page_add(struct page *page, struct list_head 
>>> *pagelist,
>>> +static int migrate_page_add(struct page *page, struct list_head 
>>> *pagelist,
>>>                   unsigned long flags)
>>>   {
>>>       struct page *head = compound_head(page);
>>> +
>>> +    /*
>>> +     * Non-movable page may reach here.  And, there may be
>>> +     * temporaty off LRU pages or non-LRU movable pages.
>>> +     * Treat them as unmovable pages since they can't be
>>> +     * isolated, so they can't be moved at the moment.  It
>>> +     * should return -EIO for this case too.
>>> +     */
>>> +    if (!PageLRU(head) && (flags & MPOL_MF_STRICT))
>>> +        return -EIO;
>>> +
>> Hm but !PageLRU() is not the only way why queueing for migration can
>> fail, as can be seen from the rest of the function. Shouldn't all cases
>> be reported?
>
> Do you mean the shared pages and isolation failed pages? I'm not sure 
> whether we should consider these cases break the semantics or not, so 
> I leave them as they are. But, strictly speaking they should be 
> reported too, at least for the isolation failed page.

By reading mbind man page, it says:

If MPOL_MF_MOVE is specified in flags, then the kernel will attempt to 
move all the existing pages in the memory range so that they follow the 
policy.  Pages that are shared with other processes will not be moved.  
If MPOL_MF_STRICT is also specified, then the call fails with the error 
EIO if some pages could not be moved.

It looks the code already handles shared page correctly, we just need 
return -EIO for isolation failed page if MPOL_MF_STRICT is specified.

>
> Thanks,
> Yang
>
>>
>>>       /*
>>>        * Avoid migrating a page that is shared with others.
>>>        */
>>> @@ -984,6 +1001,8 @@ static void migrate_page_add(struct page *page, 
>>> struct list_head *pagelist,
>>>                   hpage_nr_pages(head));
>>>           }
>>>       }
>>> +
>>> +    return 0;
>>>   }
>>>     /* page allocation callback for NUMA node migration */
>>> @@ -1186,9 +1205,10 @@ static struct page *new_page(struct page 
>>> *page, unsigned long start)
>>>   }
>>>   #else
>>>   -static void migrate_page_add(struct page *page, struct list_head 
>>> *pagelist,
>>> +static int migrate_page_add(struct page *page, struct list_head 
>>> *pagelist,
>>>                   unsigned long flags)
>>>   {
>>> +    return -EIO;
>>>   }
>>>     int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
>>>
>

