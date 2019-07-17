Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6D67C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 19:25:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D05A21743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 19:25:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D05A21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A1AC6B0005; Wed, 17 Jul 2019 15:25:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 153F78E0003; Wed, 17 Jul 2019 15:25:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 041ED8E0001; Wed, 17 Jul 2019 15:25:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFC166B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 15:25:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e25so15065851pfn.5
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 12:25:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=U59K72pNk0kFFPXl2b8QZjxYzI68eAa8RQscUzqyoW4=;
        b=J+h5HAqxyJdrq7R+dJvxDj7BMNDEsnrms4S48l5YtFGNzPTqqJxxWy3uj0U739ajNL
         9emL/XVa6DfXUKQlr4zKfq1XqsfcdHoSc48/Do4Jz7XQ3JC0hWucFuY90Dc1sJ4PdmTR
         YMSWg7chfkmo0z3fsw2SBhfX1uOFFZThuva9lcyVbLwwRcwMwGzfvll9QfKB8gWU+aLy
         OUoiDMcHO8YK7JA+77F+y2OKPxfGQr2MGRcJrOn9lXO+rWOfYhmOdJrwx8OOlkGqouBi
         UL5x1MZOB7XIm5/nP0cUAl2MSG5TWGzmqr7CpszZ5OuCs9Zjmft1UOv8R1f1b4sQDY/h
         5jVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWhdUat57GUsVzKjhNqfjV6qwtNnE7S2FmRFU6e0reIFMLdv8QY
	5Ue00sNVfqjtuvN854zR5S3x1G3WQVX5g0futgKgpa2TBF8giczGbm5c8Epk+hGoN9kzQck/rjx
	myPMWQtx238R6IEA11npeKllZLVlh8P8ofeI77ZzxTLSbXEL8MITkbL8M795Rc7GmSQ==
X-Received: by 2002:a17:902:b20d:: with SMTP id t13mr43074189plr.229.1563391515296;
        Wed, 17 Jul 2019 12:25:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2kMlLIMJjTKHXlsUc+8yOIPg4noQ6MVQmBsS3WkMLjDo//38pI6mFoH/SdoqXHYpGxys8
X-Received: by 2002:a17:902:b20d:: with SMTP id t13mr43074072plr.229.1563391513589;
        Wed, 17 Jul 2019 12:25:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563391513; cv=none;
        d=google.com; s=arc-20160816;
        b=ES+kh9Mv7J4Kq+WlfSK89Ha3FK6xAXmz4ei2aWUjR3kgOAi6Welfd06ncQrBtO48bI
         2CLbEZQn9De5pkR4E4x0t4brWM9ivG1/L8+SHV26W876y5oGf+7N8bC+W9OE6KmZATXz
         oB0tn/uqJvy92qSZtM0zHy6UcxTBn5gNIc8t8d7L5XlGg/NS9f/3sT58u24oFhYpxX8g
         jP/2fzPuf/oxETKTDCyF5omYX5q2o+GtNKBShnrfrRTjwztfQsdpK7jhsBRwOGuflorm
         Cu330OkBoOcP9ICT+4tccknIiy3KmwZ9alViY19y4nbAgkgMuY/MIr6KGd9vlUmJbt0t
         DZqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=U59K72pNk0kFFPXl2b8QZjxYzI68eAa8RQscUzqyoW4=;
        b=L1Wh/OF530PYU0wPBhBNhUW+A2tbzX1oaU6rp4SVHRV90iOrEThsCX7ozKvIQivqZO
         GzEKR+UU7n/wtiK4BCeNNX3kzF0jnTuarf/9n9DIYLY6db0tN8aymmbue0asrW1c+xZI
         aSTsIBXWq6/MjS1bAJYoWtRWDGeqSjLv5r+8VyfM/s0Eeewd4d2PJQ7QUWegmpT8SxaO
         MMhbBkLKULSQBFJa54sSTJXekzKunPur3EGb7SSg/OJWoVbUMvx+GsJVeHP41Ep4AOWn
         lxLwwKVxLbXRlZVZy/e6pxbAo+ym/g6T2bAyRSW5p1DKowt4MDTL2jCdMiDmp/YOUTx6
         TKQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id c11si242980pgk.383.2019.07.17.12.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 12:25:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R291e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TX8x0ih_1563391508;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX8x0ih_1563391508)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Jul 2019 03:25:10 +0800
Subject: Re: [v2 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages
 mapped correctly in mbind
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Linux API <linux-api@vger.kernel.org>
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <1561162809-59140-3-git-send-email-yang.shi@linux.alibaba.com>
 <0cbc99f6-76a9-7357-efa7-a2d551b3cd12@suse.cz>
 <9defdc16-c825-05b7-b394-abdf39000220@linux.alibaba.com>
 <3197a7df-c7bc-2bac-3d40-dbfc97d4a909@linux.alibaba.com>
 <7be3d36a-19fe-2e3b-8840-27fb5fd60f15@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <a5c48e13-68a3-ae0f-6554-d06fc79b2fe4@linux.alibaba.com>
Date: Wed, 17 Jul 2019 12:25:07 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <7be3d36a-19fe-2e3b-8840-27fb5fd60f15@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/17/19 11:50 AM, Vlastimil Babka wrote:
> On 7/17/19 8:23 PM, Yang Shi wrote:
>>
>> On 7/16/19 10:28 AM, Yang Shi wrote:
>>>
>>> On 7/16/19 5:07 AM, Vlastimil Babka wrote:
>>>> On 6/22/19 2:20 AM, Yang Shi wrote:
>>>>> @@ -969,10 +975,21 @@ static long do_get_mempolicy(int *policy,
>>>>> nodemask_t *nmask,
>>>>>    /*
>>>>>     * page migration, thp tail pages can be passed.
>>>>>     */
>>>>> -static void migrate_page_add(struct page *page, struct list_head
>>>>> *pagelist,
>>>>> +static int migrate_page_add(struct page *page, struct list_head
>>>>> *pagelist,
>>>>>                    unsigned long flags)
>>>>>    {
>>>>>        struct page *head = compound_head(page);
>>>>> +
>>>>> +    /*
>>>>> +     * Non-movable page may reach here.  And, there may be
>>>>> +     * temporaty off LRU pages or non-LRU movable pages.
>>>>> +     * Treat them as unmovable pages since they can't be
>>>>> +     * isolated, so they can't be moved at the moment.  It
>>>>> +     * should return -EIO for this case too.
>>>>> +     */
>>>>> +    if (!PageLRU(head) && (flags & MPOL_MF_STRICT))
>>>>> +        return -EIO;
>>>>> +
>>>> Hm but !PageLRU() is not the only way why queueing for migration can
>>>> fail, as can be seen from the rest of the function. Shouldn't all cases
>>>> be reported?
>>> Do you mean the shared pages and isolation failed pages? I'm not sure
>>> whether we should consider these cases break the semantics or not, so
>>> I leave them as they are. But, strictly speaking they should be
>>> reported too, at least for the isolation failed page.
> CC'd linux-api, should be done on v3 posting also.
>
>> By reading mbind man page, it says:
>>
>> If MPOL_MF_MOVE is specified in flags, then the kernel will attempt to
>> move all the existing pages in the memory range so that they follow the
>> policy.  Pages that are shared with other processes will not be moved.
>> If MPOL_MF_STRICT is also specified, then the call fails with the error
>> EIO if some pages could not be moved.
> I don't think this means that for shared pages, -EIO should not be
> reported. I can imagine both interpretations of the paragraph. I guess
> we can be conservative and keep not reporting them, if that was always
> the case - but then perhaps clarify the man page?

Yes, I agree the man page does looks ambiguous.  Anyway, I think we 
could add a patch later to kernel or manpage for either interpretations 
once it gets clarified.

>
>> It looks the code already handles shared page correctly, we just need
>> return -EIO for isolation failed page if MPOL_MF_STRICT is specified.
>>
>>> Thanks,
>>> Yang
>>>
>>>>>        /*
>>>>>         * Avoid migrating a page that is shared with others.
>>>>>         */
>>>>> @@ -984,6 +1001,8 @@ static void migrate_page_add(struct page *page,
>>>>> struct list_head *pagelist,
>>>>>                    hpage_nr_pages(head));
>>>>>            }
>>>>>        }
>>>>> +
>>>>> +    return 0;
>>>>>    }
>>>>>      /* page allocation callback for NUMA node migration */
>>>>> @@ -1186,9 +1205,10 @@ static struct page *new_page(struct page
>>>>> *page, unsigned long start)
>>>>>    }
>>>>>    #else
>>>>>    -static void migrate_page_add(struct page *page, struct list_head
>>>>> *pagelist,
>>>>> +static int migrate_page_add(struct page *page, struct list_head
>>>>> *pagelist,
>>>>>                    unsigned long flags)
>>>>>    {
>>>>> +    return -EIO;
>>>>>    }
>>>>>      int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
>>>>>

