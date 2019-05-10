Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64918C04AB1
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 02:25:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24F9D217F5
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 02:25:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24F9D217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA6546B0003; Thu,  9 May 2019 22:25:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2F516B0006; Thu,  9 May 2019 22:25:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F87D6B0007; Thu,  9 May 2019 22:25:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62A706B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 22:25:39 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y9so2734331plt.11
        for <linux-mm@kvack.org>; Thu, 09 May 2019 19:25:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=uS9/ksYuUIT8ZBiKQL05bD/A38ycreIcjG1GMtHRHuU=;
        b=PTkFbeE76mC0WPQKzSa9zhKkklDhfE/9Rw66Q0FqpgfUVcwKhjVbeIOY6rkdNonzBY
         gIZBlOMdk0tkQWsXGocVFruQfgyH2qlY3nAW1rOEC7JFCM4mzcp4GsHp5so1d4BoxVF0
         h/pGNcZKLXTDCT945biJmPCd5+oyum/ArqHSiMw5rW725xR2OK1BKbFIm+PvxTOa0oZp
         Ge8p3gcz7W6/lbuWk4iqw8t0+HRBC+miG2iLlw9nv7AWlriqZNqiLJydt0EOtFKGiY3o
         aaOn8FtCxb1M9ZIKzenYZW/Z1KkrxA0rySmcp3ttlfQr+tknNKfiPIoa+65irrCQxpYB
         3v6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXZOniKTjp9OfEDG3knKHR0DZcqqzXGTxJ+0TiFOzXkRYB8PTso
	NPYZzyE+phBu/P2eEZ/RWqMm7v/olO9IMCc+3dyjo1QTdXNo1S2c6uUmn9PBgp626EaM1Ae9Iaj
	qca6JNGvDI33qLFQV4olLKiz+h63dKH0omowh2+OLjA45eDQemee0Mbk0I3fJu71drQ==
X-Received: by 2002:a17:902:8ec8:: with SMTP id x8mr9667564plo.21.1557455139063;
        Thu, 09 May 2019 19:25:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzj36LB9ozsgEcsB3UoKgvo025raqMkEaQ3RA2QsDgEr5XIzeJOzEaEDFe2AxW0tZNrQ+/S
X-Received: by 2002:a17:902:8ec8:: with SMTP id x8mr9667487plo.21.1557455138313;
        Thu, 09 May 2019 19:25:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557455138; cv=none;
        d=google.com; s=arc-20160816;
        b=Oah0nYjoFziPeAcHDekQjcnJS7brgqu7qkaNDardM1weToHZTWRIKsTIuG3QW42f5z
         qDy+ii8ZTufnO7OqWvBpT3otzENzb9hvZAyW03I1eimZOUhTHwTdWf3rtsIch5taOlNO
         fULG16izZwsUPpTevKiBqVl9RMaW/fp2xjhMLsdmMzJpAd8dWPZrF2PtLxd4+yxgjXa7
         b5a8XD5B2ORcOKUHTVYqTb4541pZmfahu1764gbHipBLWSGwzh4StbKf6yNwOuNhVnLB
         fLDD0TXnzIq3n1x9Xf1gPTCCiV68RTTmRSCEUYxZcj0tp/7hHjWp3Pgj+V+nX+EU+HpU
         5Hpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uS9/ksYuUIT8ZBiKQL05bD/A38ycreIcjG1GMtHRHuU=;
        b=LBBMHpYxGqk+yTfbzV1tWSVSj2op97YUqP3wczDzmlcFF8nf9wn9cE2G1JtowNnDHq
         ajuSmnzxD4cskhDXxeSz2nTP/A7ZLfh0a0X3FV/7xE/LWX7wyTFr6GIKZKtd6puyt2+U
         ISlF/PwAaXNMaYhqstROPyXSUdbhOLonHnFRqcaBv+2YNH+jeVcFTuW6goeM3ju1cz30
         f8OC2b7KpWY+9CEPukfbB4WnCFJwlEx3bcNX1kn/WXrxvFeS+yoDrFjnbTxZZ3N7KupB
         aZog/nD0s66lJUbYiNqIJj1Y4IKwQsbtQ6VPIFG3lQX/DIkT92NZKSJIii8b2ikyat4s
         9OGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id d62si5783293pfa.72.2019.05.09.19.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 19:25:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TRIa4cz_1557455120;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRIa4cz_1557455120)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 10 May 2019 10:25:23 +0800
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
To: "Huang, Ying" <ying.huang@intel.com>
Cc: hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net,
 kirill.shutemov@linux.intel.com, hughd@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <1fb73973-f409-1411-423b-c48895d3dde8@linux.alibaba.com>
Date: Thu, 9 May 2019 19:25:20 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <87y33fjbvr.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/9/19 7:12 PM, Huang, Ying wrote:
> Yang Shi <yang.shi@linux.alibaba.com> writes:
>
>> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
>> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
>> still gets inc'ed by one even though a whole THP (512 pages) gets
>> swapped out.
>>
>> This doesn't make too much sense to memory reclaim.  For example, direct
>> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
>> could fulfill it.  But, if nr_reclaimed is not increased correctly,
>> direct reclaim may just waste time to reclaim more pages,
>> SWAP_CLUSTER_MAX * 512 pages in worst case.
>>
>> This change may result in more reclaimed pages than scanned pages showed
>> by /proc/vmstat since scanning one head page would reclaim 512 base pages.
>>
>> Cc: "Huang, Ying" <ying.huang@intel.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>> I'm not quite sure if it was the intended behavior or just omission. I tried
>> to dig into the review history, but didn't find any clue. I may miss some
>> discussion.
>>
>>   mm/vmscan.c | 6 +++++-
>>   1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index fd9de50..7e026ec 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1446,7 +1446,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>   
>>   		unlock_page(page);
>>   free_it:
>> -		nr_reclaimed++;
>> +		/*
>> +		 * THP may get swapped out in a whole, need account
>> +		 * all base pages.
>> +		 */
>> +		nr_reclaimed += (1 << compound_order(page));
>>   
>>   		/*
>>   		 * Is there need to periodically free_page_list? It would
> Good catch!  Thanks!
>
> How about to change this to
>
>
>          nr_reclaimed += hpage_nr_pages(page);

Either is fine to me. Is this faster than "1 << compound_order(page)"?

>
> Best Regards,
> Huang, Ying

