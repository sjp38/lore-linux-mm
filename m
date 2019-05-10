Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73891C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:54:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D8C72070D
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:54:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D8C72070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D61A96B0003; Fri, 10 May 2019 12:54:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D117A6B0006; Fri, 10 May 2019 12:54:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C014F6B0007; Fri, 10 May 2019 12:54:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF3C6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 12:54:20 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d7so4416785pgc.8
        for <linux-mm@kvack.org>; Fri, 10 May 2019 09:54:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=NlNpxiNBfeC4du3cFApLVF35slSBP97aolAUyYL/GkY=;
        b=gcmoUIS6AyAQQIVizxkipn8B1mzT3Hb5Cu1QM/CiysDVDvbDfcGzvwYZETahIlZLco
         ZbNaJxGVHo9A5q0FP5VzhSWu16OzGvwzVBZmkHujrB7jtaPmt1+lpSHLDp//tmwGU0j6
         9qf2r7kr4hM4K5tJCbjOSAnqKuo5MlCmUKGl3ETpp8mnhu6LHpMPfU4wqjKZOPifHVjH
         Y4fkZrJOrD69mWYwvPew+7WOSQmiORrapRa2Nk3JuhjTUeq9CYvubyjs3YgFDibqjd+y
         /mPI/hvsKTuignE5YkCn7xT4bCqZhhn3yymXpbK6e/oUN1ZEu+aXLj0KAW1bfJ6H1G0f
         CNsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV2QcObZPgnLN7Lksnlb7Sq4Cdt13tHd5j+ua5i/rRa3gXZEqpx
	DA3LSIifJl4Iajk6u5unBkWkBp+UIN3Mev0Rv7vS0+VhatcGIdDuTiFVEZ25SwyQ6bqMeIH2M+w
	Qt2SjCaChPHNlmfsiFbofaVe4DzVULZ2Z4Qr/XlI64qkGwR9MnE9d2jYSpn8Pp7C3dA==
X-Received: by 2002:a17:902:7241:: with SMTP id c1mr14384812pll.326.1557507260242;
        Fri, 10 May 2019 09:54:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9oL89cVWcZH2ckImS7SutFLIEzNB+CX700TDEevuxOJlVQC1SqZYkFyF1cA+KioVLbjio
X-Received: by 2002:a17:902:7241:: with SMTP id c1mr14384725pll.326.1557507259628;
        Fri, 10 May 2019 09:54:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557507259; cv=none;
        d=google.com; s=arc-20160816;
        b=Sw96hL3aVZvu3c9Q4iDe8t2TyX9iGB1xBSAmmtt/k3bB8SNlA/hUy2GVytq2LfeGZz
         1anIak9T/DDETVp5br3QU+MB8ind7RysAy78zZnwgxCPpT4yqoFpLInrfx6Ygq2BqASo
         D435LfG27AhrjJLZNom8RGA2Jy+6yGZYsBwNgE6qZcJs93p9ivrt/H6YNw1xL+OkMTvB
         u8VsPhB/RNye0Ng7kA6ct3i4EOZ3v9k8yQzxKyJeDSgFI+WonA0/rZXUuaUIo5Yk1f64
         cXHuYrJr2LgQO49IYoXJtgQUflc5oYDkLWYtJ2P22h7xW0aqM9yk7r5ED+P1EsaMtNd5
         ZabA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=NlNpxiNBfeC4du3cFApLVF35slSBP97aolAUyYL/GkY=;
        b=QbuqyzhDcSveoJ9bMR7qhhnnyVuKcODQ/o4QouiW0VVfovLDYc3s61sFRd4jV0FBN2
         MJD8WYR6apEdaXoTfsUFag6/9D56fnvzLvZuqoxZeoNpby9ApfofPJrMRdg1XKdxT22/
         VlbMxASMtYMMZodab5h4bgHJaQi/2o/WxRRW7/C/OulhCdPBxcKnZ+7cDAmgyENnILia
         M8xS5doQDooHbh21W57MfvjOYRz2Gkujbwgp4bK+JPkrdSN/olwWCj+vtiaXrP+6vfhd
         YZjPMNJZAyzIvU9LierkO1Dtvlv7RQVAffgvbJWqEbSqPIusJnZjFszXuWWOzzWtZGig
         gC9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id r6si8190501pgp.466.2019.05.10.09.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 09:54:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R471e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TRMMEdW_1557507254;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRMMEdW_1557507254)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 11 May 2019 00:54:17 +0800
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
To: Matthew Wilcox <willy@infradead.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, hannes@cmpxchg.org,
 mhocko@suse.com, mgorman@techsingularity.net,
 kirill.shutemov@linux.intel.com, hughd@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com>
 <20190510163612.GA23417@bombadil.infradead.org>
 <3a919cba-fefe-d78e-313a-8f0d81a4a75d@linux.alibaba.com>
 <20190510165207.GB3162@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <72fb1554-4cda-27f4-8c09-038ab3350ff8@linux.alibaba.com>
Date: Fri, 10 May 2019 09:54:11 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190510165207.GB3162@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/10/19 9:52 AM, Matthew Wilcox wrote:
> On Fri, May 10, 2019 at 09:50:04AM -0700, Yang Shi wrote:
>> On 5/10/19 9:36 AM, Matthew Wilcox wrote:
>>> On Fri, May 10, 2019 at 10:12:40AM +0800, Huang, Ying wrote:
>>>>> +		nr_reclaimed += (1 << compound_order(page));
>>>> How about to change this to
>>>>
>>>>           nr_reclaimed += hpage_nr_pages(page);
>>> Please don't.  That embeds the knowledge that we can only swap out either
>>> normal pages or THP sized pages.  I'm trying to make the VM capable of
>>> supporting arbitrary-order pages, and this would be just one more place
>>> to fix.
>>>
>>> I'm sympathetic to the "self documenting" argument.  My current tree has
>>> a patch in it:
>>>
>>>       mm: Introduce compound_nr
>>>       Replace 1 << compound_order(page) with compound_nr(page).  Minor
>>>       improvements in readability.
>>>
>>> It goes along with this patch:
>>>
>>>       mm: Introduce page_size()
>>>
>>>       It's unnecessarily hard to find out the size of a potentially huge page.
>>>       Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).
>> So you prefer keeping using  "1 << compound_order" as v1 did? Then you will
>> convert all "1 << compound_order" to compound_nr?
> Yes.  Please, let's merge v1 and ignore v2.

Fine to me. I think Andrew will take care of it, Andrew?


