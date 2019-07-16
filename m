Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5834DC7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:19:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25F932173C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:19:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25F932173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E19C6B000C; Tue, 16 Jul 2019 13:19:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96AB26B000E; Tue, 16 Jul 2019 13:19:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 884346B0010; Tue, 16 Jul 2019 13:19:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 550D56B000C
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 13:19:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d2so10519205pla.18
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:19:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=DbybCuOwdgNv0GvrvJMavJmQckFflSOQWSOR18tASAw=;
        b=IqAU/UQd9dSZGFbPIgIRzxtJSHTA3MihSVwV9gDdnbf682zZ0LAxpSlOYJG0SUqrnS
         FpusptYRZ7mPcvdXc4VoMeXYAT5ej5bXRERS6YsvKm5IT9rkRka0mmBLL9gF7to/IMzE
         bmjYoeOwUGfFhLZxO+7VRWpkITA8WloJXx58drmqULyr45NkBDZA7ZVeANq7f2fvGqxt
         7E484HDwcM6JI6NNfJUzT8c7OmCERdbSL8k9fF+1B/kylYgArmHlVshNYOABoeSouoez
         Qvmr1q+rx2snd6MLtHuXgEcujEdpwEfMERf7CO8mSaL+IE798uWWeH2y9kCrhTY++cCJ
         iCMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWK7MnyhqRRQVRfKgZtaL2zhy7So9Hbzd633oyXKOHqKau/pthD
	EVOCzHq8TT0XTLhDU6QWKAkRmvWYtXgP7BaTTEv6bmzWppxtCevqw9FSjrdxCzswYAdMwuTnDrw
	kJqvb3RGgKWyj3mAilmSgIXcfm+Aiy/H6+tsoGhQKqizcwjU/9L34uwLhD3RwxM62dg==
X-Received: by 2002:a63:6c02:: with SMTP id h2mr32811276pgc.61.1563297564967;
        Tue, 16 Jul 2019 10:19:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOqE79/4v0nr4Y78UvM1C5kdquw9ogr4p+EaGfO6BXcInftTHmlfyEdIM1aPQA3FVGH/NH
X-Received: by 2002:a63:6c02:: with SMTP id h2mr32811138pgc.61.1563297563954;
        Tue, 16 Jul 2019 10:19:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563297563; cv=none;
        d=google.com; s=arc-20160816;
        b=twmxSEMUEr9u+/bhjcroGs7Xs5e96A3/eLWN/philXVUX1zRGyHJ78EChtGuqX3JOv
         igzu1rU35nKOE03LN+bAw6pnwjBK1HeMmaXAxiQBJxDG8iTqHfLvl3MsmUsJHgkxL0ZB
         uO8At1oZY2+3z6g7DUbv+SVvTULlLdlYrh4Rufa6QSO/iQ5MROmY0+ylaD8YNrfX5Lt0
         +iMlyB+dukDgVknbYgGjBtjlmOwpfsa+F+203dMVsjGbpOnLFX4QuyjLv3S1nhbygyF1
         JD4Ce3heC83rhtRkrY3HmH8YbsqErVrqReIgAsTSNn2b9j/FZgNPsOqgRolESI78feJ2
         FiYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DbybCuOwdgNv0GvrvJMavJmQckFflSOQWSOR18tASAw=;
        b=s6yaBU8hec/UbwGtdZlCS+31asi4c2EfbNV2/Fyi1ng/PPY4c1XN0OWjellOoismy9
         5drbSYMdqgcrR62nmKL2eBVqPtNYGVpBea2h4HDIPnS0/q7yxS5A51oFnob/BdWMBFql
         bqqES3P5spYRbeyH2DEgzFGoz2GgNu/FyjY/WuCW3mUaC7Lz18ZSC3QURdXEukjjmzi6
         Cp5pdbsMFt9UIiLUA8JPb1Jgl81Uj5jVuml63Q9Nn3oYTkY4oO3eN7WSFzayl0SauL8o
         wwB05h7/mphKGsntkbEwiC5+0Ekv/YIOLOMcVWbuidx1ATadbZ2sgOosoyMy+S8wvQ5O
         +45A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id 4si13051136pfg.55.2019.07.16.10.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 10:19:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TX4BD5v_1563297559;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX4BD5v_1563297559)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 17 Jul 2019 01:19:21 +0800
Subject: Re: [v2 PATCH 1/2] mm: mempolicy: make the behavior consistent when
 MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <1561162809-59140-2-git-send-email-yang.shi@linux.alibaba.com>
 <fb74d657-90cd-6667-f253-162c951f1b05@suse.cz>
 <0a57d280-a56c-ceef-282b-b9dec380c7c7@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3933e4b1-e6cd-3e6b-d1a3-7a835767ab44@linux.alibaba.com>
Date: Tue, 16 Jul 2019 10:19:17 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <0a57d280-a56c-ceef-282b-b9dec380c7c7@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/16/19 1:47 AM, Vlastimil Babka wrote:
> On 7/16/19 10:12 AM, Vlastimil Babka wrote:
>>> --- a/mm/mempolicy.c
>>> +++ b/mm/mempolicy.c
>>> @@ -429,11 +429,14 @@ static inline bool queue_pages_required(struct page *page,
>>>   }
>>>   
>>>   /*
>>> - * queue_pages_pmd() has three possible return values:
>>> + * queue_pages_pmd() has four possible return values:
>>> + * 2 - there is unmovable page, and MPOL_MF_MOVE* & MPOL_MF_STRICT were
>>> + *     specified.
>>>    * 1 - pages are placed on the right node or queued successfully.
>>>    * 0 - THP was split.
>> I think if you renumbered these, it would be more consistent with
>> queue_pages_pte_range() and simplify the code there.
>> 0 - pages on right node/queued
>> 1 - unmovable page with right flags specified
>> 2 - THP split
> Ah, alternatively you could add a boolean to struct queue_pages
> accessible from mm_walk, set true to indicate that unmovable page has
> been encountered, without propagating it back through special return values.

I will try both to see which one (renumbering return value or use flag) 
is better.

Thanks,
Yang


