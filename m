Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B1DFC606BA
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 13:53:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C64912086D
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 13:53:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C64912086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A6E98E0015; Mon,  8 Jul 2019 09:53:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3301D8E0002; Mon,  8 Jul 2019 09:53:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F9338E0015; Mon,  8 Jul 2019 09:53:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E69D58E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 09:53:01 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id j22so6114503oib.7
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 06:53:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=TUkIvjJKzd39q304CsWbn/aPqgrFbfyYcTjUxfaonDE=;
        b=MWJxvf5f7XT7i7sAE6KB4eh43pMCEC+IquaafyQOUW08ORGovFhKf5OTvgasCN/IbA
         4mP2C0FxrDFCqLI6XYsCSNR0K2jmBBJh2KwGnzVrdrHfIU+5s2N5SVeKGsMZU37xPpnm
         9ZFAelc3NoZkH6O2tGYCoNBsUN9Y11EKdWyDM656JvP9lTKAs87ESS+wtqsSlGDmIYIj
         zzhNJRC3Lxus29q0178RLRK20TU/peUSZIb+33MDk4VqZzjDJIuClKTMCUs3Y9nQmrOb
         6zS27z72ewiQ9VZCFAukOyzHyHq9RirBfPEwC/xz0s4hWFEJKHW6IkQi/NJyJGYBcVFd
         t7nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAUqD/kF5HZBqsuHAb8V9kWVf9SPHO9HHsb7YCGEPfLvB94O64h7
	YZtQ7mqcaaaPKwGQ6ePvTmQI+nuQw7yVB7D4mQZeIslucbnWrbpPMfh8/LjM+iKCuhiNiKGG8Uq
	IhBSy9q6XTdqsdhZZSBPigAVWw2ChbvdBOnRnQmnprkyuBmeVWxCQYvIhVTKjsVnMeg==
X-Received: by 2002:aca:cfd0:: with SMTP id f199mr8790450oig.50.1562593981552;
        Mon, 08 Jul 2019 06:53:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhllyI7UxWa8h684IWqLm5Lr3tIYlQIZyoN02C7v6XgXB/FcNjZZSg/kEGtuqAH2WbST8Y
X-Received: by 2002:aca:cfd0:: with SMTP id f199mr8790418oig.50.1562593980716;
        Mon, 08 Jul 2019 06:53:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562593980; cv=none;
        d=google.com; s=arc-20160816;
        b=Ohnl7RrUWo0Nbv7EcEGWufl4zYs1lhkD+Pb39WS6jM4ucwHatKO9IqcmplDDGihE8s
         ycq2F0qgIsnwrU39oeGYXqNqaZ66D7VATlEe8TIidTuOteoIQZogKxSo0/Otm3AA0VJj
         rgM9rH5v7Njigjhc2ZIv9a4q+YKcim0VZp/GiV3OHylfJo/OhjXvyWl9lzufAghnA9uN
         dCXc5MstwxeS2AiYhtpxRG2AFnMgyG8Qu40u42s/GZ+3MjFk9h/CzqVUKwymgBwHkmvo
         1BPtZYZ0nVAtNdwi0OZCmySgcZZEn8GYyua9A3dnYQJHSZoMGi5lcbEweJ19dfWyD+ON
         +gsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=TUkIvjJKzd39q304CsWbn/aPqgrFbfyYcTjUxfaonDE=;
        b=R4xl7ZofAjvJHB7Gi/BRdSHr/tAZUhKskN5yuyPpNjAvQN4MuI6gEK0A1mXWO9JA8u
         QM7clzrZw2F5EJFJlJM8gRE1UQ/l5qbhNNvsFNw7OfRtXSmxDKiS6qq+tgakG24s+6aq
         eI6DKKLl8nGLxVjn0ws2DNajrMkpz2vkVAKEae8tDZewjn2/zzIoOdRqmnMOc1ftfUd7
         WVxSTPXcFDyjBVpOk/9ymOXvAdffWJ8HNu0mmvrADEbgakStn41YBq0HkJzRoZ3CDknP
         tq4ggDLyrXy34CYK3Cxqa+SYhp/V0BBfNlOAY2a+geU39lJZPjLEjh1QcR0T5ci/Rjsj
         97+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id z19si1941219oic.97.2019.07.08.06.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 06:53:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 3C77DE75C088BAA6CFB6;
	Mon,  8 Jul 2019 21:52:55 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.439.0; Mon, 8 Jul 2019
 21:52:53 +0800
Message-ID: <5D234AB5.2070508@huawei.com>
Date: Mon, 8 Jul 2019 21:52:53 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Michal Hocko <mhocko@suse.com>
CC: <akpm@linux-foundation.org>, <anshuman.khandual@arm.com>,
	<mst@redhat.com>, <linux-mm@kvack.org>, Dan Williams
	<dan.j.williams@intel.com>
Subject: Re: [PATCH] mm: redefine the MAP_SHARED_VALIDATE to other value
References: <1562573141-11258-1-git-send-email-zhongjiang@huawei.com> <20190708092045.GA20617@dhcp22.suse.cz>
In-Reply-To: <20190708092045.GA20617@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/7/8 17:20, Michal Hocko wrote:
> [Cc Dan]
>
> On Mon 08-07-19 16:05:41, zhong jiang wrote:
>> As the mman manual says, mmap should return fails when we assign
>> the flags to MAP_SHARED | MAP_PRIVATE.
>>
>> But In fact, We run the code successfully and unexpected.
> What is the code that you are running and what is the code version.
Just an following code, For example,
addr = mmap(ADDR, PAGE_SIZE, PROT_WRITE|PROT_EXEC, MAP_SHARED|MAP_PRIVATE, fildes, OFFSET);

We test it and works well in linux 4.19.   As the mmap manual says,  it should fails.
>> It is because MAP_SHARED_VALIDATE is introduced and equal to
>> MAP_SHARED | MAP_PRIVATE.
> This was a deliberate decision IIRC. Have a look at 1c9725974074 ("mm:
> introduce MAP_SHARED_VALIDATE, a mechanism to safely define new mmap
> flags").
I  has seen the patch,  It introduce the issue.  but it only define the MAP_SHARED_VALIDATE incorrectly.
Maybe the author miss the condition that MAP_SHARED_VALIDATE is equal to MAP_PRIVATE | MAP_SHARE.


Thanks,
zhong jiang
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  include/uapi/linux/mman.h                          | 2 +-
>>  tools/include/uapi/asm-generic/mman-common-tools.h | 2 +-
>>  tools/include/uapi/linux/mman.h                    | 2 +-
>>  3 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
>> index fc1a64c..1d3098e 100644
>> --- a/include/uapi/linux/mman.h
>> +++ b/include/uapi/linux/mman.h
>> @@ -14,7 +14,7 @@
>>  
>>  #define MAP_SHARED	0x01		/* Share changes */
>>  #define MAP_PRIVATE	0x02		/* Changes are private */
>> -#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
>> +#define MAP_SHARED_VALIDATE 0x04	/* share + validate extension flags */
>>  
>>  /*
>>   * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
>> diff --git a/tools/include/uapi/asm-generic/mman-common-tools.h b/tools/include/uapi/asm-generic/mman-common-tools.h
>> index af7d0d3..4fc44d2 100644
>> --- a/tools/include/uapi/asm-generic/mman-common-tools.h
>> +++ b/tools/include/uapi/asm-generic/mman-common-tools.h
>> @@ -18,6 +18,6 @@
>>  #ifndef MAP_SHARED
>>  #define MAP_SHARED	0x01		/* Share changes */
>>  #define MAP_PRIVATE	0x02		/* Changes are private */
>> -#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
>> +#define MAP_SHARED_VALIDATE 0x04	/* share + validate extension flags */
>>  #endif
>>  #endif // __ASM_GENERIC_MMAN_COMMON_TOOLS_ONLY_H
>> diff --git a/tools/include/uapi/linux/mman.h b/tools/include/uapi/linux/mman.h
>> index fc1a64c..1d3098e 100644
>> --- a/tools/include/uapi/linux/mman.h
>> +++ b/tools/include/uapi/linux/mman.h
>> @@ -14,7 +14,7 @@
>>  
>>  #define MAP_SHARED	0x01		/* Share changes */
>>  #define MAP_PRIVATE	0x02		/* Changes are private */
>> -#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
>> +#define MAP_SHARED_VALIDATE 0x04	/* share + validate extension flags */
>>  
>>  /*
>>   * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
>> -- 
>> 1.7.12.4


