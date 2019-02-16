Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39E90C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 02:18:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3F72222D0
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 02:18:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3F72222D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 281A18E0002; Fri, 15 Feb 2019 21:18:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22FCD8E0001; Fri, 15 Feb 2019 21:18:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11F238E0002; Fri, 15 Feb 2019 21:18:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5E348E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 21:18:43 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id i4so5958402otf.3
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 18:18:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cvyCuyOPTdVhsKv//0bWBBKQQA8ZYZfiC6FsQJbeOj4=;
        b=f2cFC4r1CA/NNdRJTXbVlcZzXYnD6HGFejz76oQL+cNYjFsdpYP9eDBwDcv6LZUiGI
         qC4FFqJaeZZuN+nXNkKFdfKiQqp0UOghBEJNBsIzFKWzJ9L9aOQq8O2qH48+TAswcmun
         kc3RlwEVR0Z6mqFQfrU24FpabzrYqRMKmxXxNaPX1iosxxRG7Vpc6uIvTUv9hiGxgYE3
         K7g5WEcvASybjprBj5ueS8KYkHHvNAtMca/gcVxK2zBEUHkOFW91fn6gEn3U6ehSdmhY
         RzF1aE5BpvIVVqRGEqCqvinc8de3yU15ZOz6JQWqTyOoPxUeRaBslF/wJR70NXHX+MJn
         yT9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuZdTHx8xn016fdVpzTYOcx4cKRK83mzpuepQkL/YlXD1tUu0rnj
	CY1pbjGg6aHd10GHGP0bAC7i5PCBCaCHnReiZXpGargIPxqC9qOtNMGmWm5umqhmCeN8cQbjf7q
	SD9WJ5AbSb21r2zCc5INcAL6ElIPNwGK9MuvNjz9Zr2j2KcmOP4TwzZKjjfUrXgniHA==
X-Received: by 2002:a9d:6b94:: with SMTP id b20mr7465342otq.42.1550283523569;
        Fri, 15 Feb 2019 18:18:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYZjlRmL2PCetgGsgISs64EXo7h8V9mHd4EKJJih2Niw2Rw+Az18N4jaq13p3kIyGrMiPDA
X-Received: by 2002:a9d:6b94:: with SMTP id b20mr7465318otq.42.1550283522804;
        Fri, 15 Feb 2019 18:18:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550283522; cv=none;
        d=google.com; s=arc-20160816;
        b=LVvD6XtXzLL2L7OhUAR+7Lgxf91bAn/LYXgVMS5rPEDHra9JDkPLkl8NsCw1WPQue8
         xngr6ptWBYWVRg/baeyKVzUeFno76jtyCF9eB5o1clSdqyplDu/AIz1Xq/LJrxTjcPS8
         jKVBHYNshf9Ez5aXe1lCJEMBDEQe+Dg5dMIxCyVmJvh+g8PO5iVx+K1zXmGzxRGAKabS
         kD+GxYm3C9XW7e/M5bh7ph/cD74HeJ37gjCe7ky5ZGcTB+3DfjoLcWljDjY+Tdhi6cPG
         jrn2LBUG4/lZJyfZIfbkjpXRAY63/3iv88bsp2j7Wk1o+aHB8LT1iuumsytXO836SBjR
         rJjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cvyCuyOPTdVhsKv//0bWBBKQQA8ZYZfiC6FsQJbeOj4=;
        b=UI17tddJLgLXeUFy0JtT+TFV2AoI9b0/LJz0sUbAINtfZE/zp+d2seiNvcLqG69j7/
         Y0bIcTqsJD1bNKej42t7JD+j+0iBgK5qSOVSS+ihFjdXL7GXA7a7odp5XQk7t/Yuuqar
         Utf38TXIzNDUGxqm53UBJ4XHMrh/0TliCgRM46+TQYwGwc+Wf0RM9zLfsqtaKR1IwStQ
         /gGsbx1JjSfV6lvKaDaft5TWMJ+lFkEn995vrnVZ09pbJqDwotpDt+9658KP8b7Ex1nf
         X+3lu6SM3zxlC8tNomC7TX2SuQIXBO594D9iyNM7PqHZVav/tLOmgiH/VYdFyClTKcTv
         Gdlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x186si1546092oif.108.2019.02.15.18.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 18:18:42 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav105.sakura.ne.jp (fsav105.sakura.ne.jp [27.133.134.232])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1G2ICme056271;
	Sat, 16 Feb 2019 11:18:12 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav105.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav105.sakura.ne.jp);
 Sat, 16 Feb 2019 11:18:12 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav105.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1G2I76W056252
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sat, 16 Feb 2019 11:18:12 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [linux-next-20190214] Free pages statistics is broken.
To: Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>
References: <201902150227.x1F2RBhh041762@www262.sakura.ne.jp>
 <20190215130147.GZ4525@dhcp22.suse.cz>
 <1189d67e-3672-5364-af89-501cad94a6ac@i-love.sakura.ne.jp>
 <e7197148-4612-3d6a-f367-1c647193c509@suse.cz>
 <CAPcyv4ihKWkONbnaParFKLke7sHBWJzXzN2auUKPQvhcEnJjdg@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <11e41efb-e04d-119c-fcaa-24a01b471930@i-love.sakura.ne.jp>
Date: Sat, 16 Feb 2019 11:18:04 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ihKWkONbnaParFKLke7sHBWJzXzN2auUKPQvhcEnJjdg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/16 3:13, Dan Williams wrote:
> On Fri, Feb 15, 2019 at 9:44 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>> On 2/15/19 3:27 PM, Tetsuo Handa wrote:
>>> On 2019/02/15 22:01, Michal Hocko wrote:
>>>> On Fri 15-02-19 11:27:10, Tetsuo Handa wrote:
>>>>> I noticed that amount of free memory reported by DMA: / DMA32: / Normal: fields are
>>>>> increasing over time. Since 5.0-rc6 is working correctly, some change in linux-next
>>>>> is causing this problem.
>>>>
>>>> Just a shot into the dark. Could you try to disable the page allocator
>>>> randomization (page_alloc.shuffle kernel command line parameter)? Not
>>>> that I see any bug there but it is a recent change in the page allocator
>>>> I am aware of and it might have some anticipated side effects.
>>>>
>>>
>>> I tried CONFIG_SHUFFLE_PAGE_ALLOCATOR=n but problem still exists.
>>
>> I think it's the preparation patch [1], even with randomization off:
>>
>> @@ -1910,7 +1900,7 @@ static inline void expand(struct zone *zone, struct page *page,
>>                 if (set_page_guard(zone, &page[size], high, migratetype))
>>                         continue;
>>
>> -               list_add(&page[size].lru, &area->free_list[migratetype]);
>> +               add_to_free_area(&page[size], area, migratetype);
>>                 area->nr_free++;
>>                 set_page_order(&page[size], high);
>>         }
>>
>> This should have removed the 'area->nr_free++;' line, as add_to_free_area()
>> includes the increment.
> 
> Yes, good find! I'll send an incremental fixup patch in a moment
> unless someone beats me to it.
> 

Removing the 'area->nr_free++;' line solved the problem. Thank you.

