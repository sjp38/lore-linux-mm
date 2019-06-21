Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B55DAC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 18:24:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ABE32083B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 18:24:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ABE32083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12F426B0003; Fri, 21 Jun 2019 14:24:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E11B8E0002; Fri, 21 Jun 2019 14:24:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F38008E0001; Fri, 21 Jun 2019 14:24:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CADC66B0003
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 14:24:01 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id f11so3270937otq.3
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 11:24:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=KX7HCFYrLCKeFznvVwe76VFG7ENGp02D2Tj5/06jtas=;
        b=d57a4ePOK+6+Le/6OkAU9djP9aJ0J17Q8WL4QVhg3CfZY8HQ/Bw+t8/CKl4pOQ/fnE
         Eo49lO1ZjiPlCE0NtGDjOy3pCkh2ZuLu1ReWV4kao3GRX2ao6bGjXflOFt9b5TnrgMKl
         ibLcEX9l6uEZmgZYtWHGG8xk9qZ/ddAeDaT44BjDVoLgOE990y1tW/YqTNjLo9UgEqX0
         8DH+ZEtStvqobR3RkSOWVz51P0cXICMnXWuu1/AAAcfZeHx+TAIiWtgCMLE1A6a+KJig
         FZor01mOMOJZSoIfma4aoIAYdN7YbX7nbXGVLELTlVP8y7Xt9AKxLyzvBgEY1AlaIB3+
         c4GA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXD0cLsbHQOJEroxUBCettBiuZqjviVmRyafyBKkVRcgfoqhHdg
	RFbY/NobPmxcIDCkk5gBOllGhKJ9myWX7iulzoflcRrnUgFatbbAO8nyKeY2CkHoJIUNDGjyKaF
	P1OxPjKdoo239zLUCoYeSpjFU8+EwAm0Uk/1hi2gEWUqCMuhFtepOtTcdAW4122q6Aw==
X-Received: by 2002:aca:a902:: with SMTP id s2mr3610836oie.62.1561141441366;
        Fri, 21 Jun 2019 11:24:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyHiE/ktpIkRKkKlDqwv+25faLzJPZLm07ujxYIKe/WkmWjDx/CvHIb5KGZs8BT5p4Dufn
X-Received: by 2002:aca:a902:: with SMTP id s2mr3610794oie.62.1561141440445;
        Fri, 21 Jun 2019 11:24:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561141440; cv=none;
        d=google.com; s=arc-20160816;
        b=SuG8sTh6bWx7fiy+ZVZUczfbwyujA2ORMzyNYsHo5pjv6+QDTPlt74gPhxiYJZDDBp
         tDm4ACp+NXqGd0IBGUjNNsXwn9+4q21AM5DeKu9pEL+Dl54PgVDeZaOngIdLmzdaoYj3
         JwUEwpyPTQhx/HZLuBP2GqtkRlUwO1ADg+hL5ZCvqkXUSi4c2RsI4VlU+EDb2ccvAKZ3
         u8zajv8QzcLVxPWpAGHx1wAW4bsdqn3yeGJGRQP5+lV/eM9M9bwUcuSCM45XXBKrXna4
         Wfbkndi4kRBL2n+azkl2qm87X/o7zjBw3aL02p7cw2kVs2btlq1O3qc+f8xmqN+bmXxy
         m9EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=KX7HCFYrLCKeFznvVwe76VFG7ENGp02D2Tj5/06jtas=;
        b=OB1jRSG7c1lN+FNbVAdkjW7waU+LDwI011nwL1fHMD5IPp17SPRFbt9quCAtHwSybS
         vglUEkyX0ICZirXZtJBT/dA1hmZCn0XuUdYG2VKXBvFqsdQD4IKzNIsmVABER65jj/4E
         1xuyPAmTgAZIh8hT3rkZynEPGPfieh1EP9JHVBfLw7nIFdoow/2FMpHhEPzK6Yg/6D9f
         RDyj/0BsYrmMs/JGPaBjiKdzWOvdR+jJGS9/F5+wzz27ChdmpDID5wwnfK5hZnR0YpcW
         YE3YhUq8kdRMMCoSK5opY6bkGcXgHfMMUFs3habRsiBjEYatd+MXThhBVVQbL5hhdFIp
         R1AA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id n2si2079684otk.63.2019.06.21.11.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 11:24:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TUqdGdq_1561141423;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TUqdGdq_1561141423)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 22 Jun 2019 02:23:46 +0800
Subject: Re: [PATCH] mm: mempolicy: handle vma with unmovable pages mapped
 correctly in mbind
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>,
 netdev@vger.kernel.org
References: <1560797290-42267-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190618130253.GH3318@dhcp22.suse.cz>
 <cf33b724-fdd5-58e3-c06a-1bc563525311@linux.alibaba.com>
 <20190618182848.GJ3318@dhcp22.suse.cz>
 <68c2592d-b747-e6eb-329f-7a428bff1f86@linux.alibaba.com>
 <20190619052133.GB2968@dhcp22.suse.cz>
 <21a0b20c-5b62-490e-ad8e-26b4b78ac095@suse.cz>
 <687f4e57-5c50-7900-645e-6ef3a5c1c0c7@linux.alibaba.com>
 <55eb2ea9-2c74-87b1-4568-b620c7913e17@linux.alibaba.com>
 <d81b36bb-876e-917a-6115-cedf496b4923@suse.cz>
 <d185f277-85ed-4dc1-8ff2-2984b54a0d64@linux.alibaba.com>
 <9945a66f-4434-b2a6-63ac-3240ef1d52c9@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <7d770cda-3f62-f1a2-6f48-529ca71bd6bd@linux.alibaba.com>
Date: Fri, 21 Jun 2019 11:23:40 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <9945a66f-4434-b2a6-63ac-3240ef1d52c9@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/21/19 4:33 AM, Vlastimil Babka wrote:
> On 6/20/19 6:08 PM, Yang Shi wrote:
>>
>> On 6/20/19 12:18 AM, Vlastimil Babka wrote:
>>> On 6/19/19 8:19 PM, Yang Shi wrote:
>>>>>>> This is getting even more muddy TBH. Is there any reason that we
>>>>>>> have to
>>>>>>> handle this problem during the isolation phase rather the migration?
>>>>>> I think it was already said that if pages can't be isolated, then
>>>>>> migration phase won't process them, so they're just ignored.
>>>>> Yes，exactly.
>>>>>
>>>>>> However I think the patch is wrong to abort immediately when
>>>>>> encountering such page that cannot be isolated (AFAICS). IMHO it should
>>>>>> still try to migrate everything it can, and only then return -EIO.
>>>>> It is fine too. I don't see mbind semantics define how to handle such
>>>>> case other than returning -EIO.
>>> I think it does. There's:
>>> If MPOL_MF_MOVE is specified in flags, then the kernel *will attempt to
>>> move all the existing pages* ... If MPOL_MF_STRICT is also specified,
>>> then the call fails with the error *EIO if some pages could not be moved*
>>>
>>> Aborting immediately would be against the attempt to move all.
>>>
>>>> By looking into the code, it looks not that easy as what I thought.
>>>> do_mbind() would check the return value of queue_pages_range(), it just
>>>> applies the policy and manipulates vmas as long as the return value is 0
>>>> (success), then migrate pages on the list. We could put the movable
>>>> pages on the list by not breaking immediately, but they will be ignored.
>>>> If we migrate the pages regardless of the return value, it may break the
>>>> policy since the policy will *not* be applied at all.
>>> I think we just need to remember if there was at least one page that
>>> failed isolation or migration, but keep working, and in the end return
>>> EIO if there was such page(s). I don't think it breaks the policy. Once
>>> pages are allocated in a mapping, changing the policy is a best effort
>>> thing anyway.
>> The current behavior is:
>> If queue_pages_range() return -EIO (vma is not migratable, ignore other
>> conditions since we just focus on page migration), the policy won't be
>> set and no page will be migrated.
> Ah, I see. IIUC the current behavior is due to your recent commit
> a7f40cfe3b7a ("mm: mempolicy: make mbind() return -EIO when
> MPOL_MF_STRICT is specified") in order to fix commit 6f4576e3687b
> ("mempolicy: apply page table walker on queue_pages_range()"), which
> caused -EIO to be not returned enough. But I think you went too far and
> instead return -EIO too much. If I look at the code in parent commit of
> 6f4576e3687b, I can see in queue_pages_range():
>
> if ((flags & MPOL_MF_STRICT) ||
>          ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
>          vma_migratable(vma))) {
>
>          err = queue_pages_pgd_range(vma, start, endvma, nodes,
>                                  flags, private);
>          if (err)
>                  break;
> }
>
> and in queue_pages_pte_range():
>
> if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
>          migrate_page_add(page, private, flags);
> else
>          break;
>
> So originally, there was no returning of -EIO due to !vma_migratable() -
> as long as MPOL_MF_STRICT and MPOL_MF_MOVE* was specified, the code
> tried to queue for migration everything it could and didn't ever abort,
> AFAICS. And I still think that's the best possible behavior.
>
>> However, the problem here is the vma might look migratable, but some or
>> all the underlying pages are unmovable. So, my patch assumes the vma is
>> *not* migratable if at least one page is unmovable. I'm not sure if it
>> is possible to have both movable and unmovable pages for the same
>> mapping or not, I'm supposed the vma would be split much earlier.
>>
>> If we don't abort immediately, then we record if there is unmovable
>> page, then we could do:
>> #1. Still follows the current behavior (then why not abort immediately?)
> See above how the current behavior differs from the original one.
>
>> #2. Set mempolicy then migrate all the migratable pages. But, we may end
>> up with the pages on node A, but the policy says node B. Doesn't it
>> break the policy?
> The policy can already be "broken" (violated is probably better word) by
> migrate_pages() failing. If that happens, we don't rollback the migrated
> pages and reset the policy back, right? I think the manpage is clear
> that MPOL_MF_MOVE is a best-effort. Userspace will know that not
> everything was successfully migrated (via -EIO), and can take whatever
> steps it deems necessary - attempt rollback, determine which exact
> page(s) are violating the policy, etc.

I see your point. It makes some sense to me. So, the policy should be 
set if MPOL_MF_MOVE* is specified even though no page is migrated so 
that we have consistent behavior for different cases:
* vma is not migratable
* vma is migratable, but pages are unmovable
* vma is migratable, pages are movable, but migrate_pages() fails

>

