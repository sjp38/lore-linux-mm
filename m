Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ED81C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:34:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FB7920659
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:34:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FB7920659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE5958E0003; Tue, 25 Jun 2019 18:34:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABED18E0002; Tue, 25 Jun 2019 18:34:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 986738E0003; Tue, 25 Jun 2019 18:34:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE258E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 18:34:07 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so222595pff.11
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:34:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=7gA2hlwrbY7eN7MPbR5WAR26EEorDXR9DUPU6NexVyI=;
        b=ceLO9nDhQR4rEF+1DKa59XBLOUoqdDvF50MoHnRzK5+EpsngE6Tr/NCHCG32eEdv9z
         go+s5SmloxR1uEFTMOogAypuIN4U2uoyX4lef5ZcseFokILuX5TmgfxjfoLqCzrO80/T
         RvZA6O5v9Nq6QUrRziHOjYL1OeAtntPpJJVe0UUqYc0mZbP8nGaRToz3BW2+1IhFS9lE
         fYKrBnY8GT02rz/62aglb6ZMsNjLXlq0YGXvNB2lFsRw2Wpu+pI60w0WcNjOhEKss3+t
         IcxlMrY9dMdKVdmXMmxrQSUUce9HbfuOkIfOd7XGBI5T/8xlIzkc0JNP1LTRR0t9FzxR
         UkAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVD5PfG82/KMKcjfy2bsOmVpMLBPhZwIVOVjxmxyESSiPJELo7i
	H8yJoU/SUe0ozlfZuQrp9rmjx5b4bAmoA5UqlaFnU1GEn/lq952O2SQ//iRk501ROHk+qLUS9Xy
	Zkp9iMmYTlE6+kV3IzrFDe6q51Uh04zHyldJrWIWKiBMtHtMbggw413hxSto19L/+UA==
X-Received: by 2002:a17:902:d915:: with SMTP id c21mr1118959plz.335.1561502047045;
        Tue, 25 Jun 2019 15:34:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzm4gFTsnuFBfy+xsH6HaGbr9fKpdaymPTk/h6Hs9XRsoMERXNl40FZ2o3OxdVNOa5QFPJ0
X-Received: by 2002:a17:902:d915:: with SMTP id c21mr1118911plz.335.1561502046361;
        Tue, 25 Jun 2019 15:34:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561502046; cv=none;
        d=google.com; s=arc-20160816;
        b=uM7sB2uGkbCtzi7EdZYdcs9iW73KdLstn/UbICHaG0yAIkH36/0IbQz4U0dIFgDDk+
         9sAZM8UrXiw7EJbVbbaps6zpGyDHIBfW8dj1srgDR1QQR8i/SX9B5syecXkimjr0vWvZ
         3qhGuk0LXkuXD6B1pQo0XfrgcrhvcTVrduJXQRR2uiCU6kD7RRYY1xXzDIPjVNtpZt93
         epJsYxrur2xT9pp9TIgnlQrMFyr4gQEzS0o66zqjm7qG2mvJIGKRBRELp6oWMF1QvfEP
         EKQ/6EuVRedeVvkCuRu5lBRnKq/LexA6uqM9XrHuFt+3p5NF7TBcszWRASRjQ9EW+uWe
         ZWkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=7gA2hlwrbY7eN7MPbR5WAR26EEorDXR9DUPU6NexVyI=;
        b=Ja3PYte1RTZMBmFJc3uxkXd8cGc25O0vwFyArEXLts/3WMP4XvEN3vtDmSUwfAx97d
         NLZh2az33eQDBa8RS+KB1GSwfU033II9wMbs4UV2uPwWJpl0pyK6uiErVgC14A6Z0k37
         Z6KLxSTfz5ZR5A7Lf0saJ0YiDxO8kOvWFAHCRbWT+xxql/vXsXIa1oUffdQwBJ0jBCCb
         A3KX5EVB0vbLr85X5lRFvyndDQI4dCHBzPV0da5dOVSQgeJ+BECpK2LFCU2qIpB/2QLp
         tAow1LiE1ImJqjQBQIuphJ48qs8BeLhnpLTqgMImFQb5kl8QioSv1DLPHIWTGW/CLhUZ
         VJVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id f26si15883520pfd.193.2019.06.25.15.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 15:34:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R941e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TVCOb2O_1561502020;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVCOb2O_1561502020)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 26 Jun 2019 06:33:44 +0800
Subject: Re: [v3 PATCH 4/4] mm: thp: make deferred split shrinker memcg aware
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560376609-113689-5-git-send-email-yang.shi@linux.alibaba.com>
 <20190625150040.feb6ea9d11fff73a57320a3c@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b21bc991-b375-82d8-46f3-a5a9779b79c9@linux.alibaba.com>
Date: Tue, 25 Jun 2019 15:33:40 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190625150040.feb6ea9d11fff73a57320a3c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/25/19 3:00 PM, Andrew Morton wrote:
> On Thu, 13 Jun 2019 05:56:49 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>> Currently THP deferred split shrinker is not memcg aware, this may cause
>> premature OOM with some configuration. For example the below test would
>> run into premature OOM easily:
>>
>> $ cgcreate -g memory:thp
>> $ echo 4G > /sys/fs/cgroup/memory/thp/memory/limit_in_bytes
>> $ cgexec -g memory:thp transhuge-stress 4000
>>
>> transhuge-stress comes from kernel selftest.
>>
>> It is easy to hit OOM, but there are still a lot THP on the deferred
>> split queue, memcg direct reclaim can't touch them since the deferred
>> split shrinker is not memcg aware.
>>
>> Convert deferred split shrinker memcg aware by introducing per memcg
>> deferred split queue.  The THP should be on either per node or per memcg
>> deferred split queue if it belongs to a memcg.  When the page is
>> immigrated to the other memcg, it will be immigrated to the target
>> memcg's deferred split queue too.
>>
>> Reuse the second tail page's deferred_list for per memcg list since the
>> same THP can't be on multiple deferred split queues.
>>
>> ...
>>
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -4579,6 +4579,11 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>>   #ifdef CONFIG_CGROUP_WRITEBACK
>>   	INIT_LIST_HEAD(&memcg->cgwb_list);
>>   #endif
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	spin_lock_init(&memcg->deferred_split_queue.split_queue_lock);
>> +	INIT_LIST_HEAD(&memcg->deferred_split_queue.split_queue);
>> +	memcg->deferred_split_queue.split_queue_len = 0;
>> +#endif
>>   	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
>>   	return memcg;
>>   fail:
>> @@ -4949,6 +4954,14 @@ static int mem_cgroup_move_account(struct page *page,
>>   		__mod_memcg_state(to, NR_WRITEBACK, nr_pages);
>>   	}
>>   
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	if (compound && !list_empty(page_deferred_list(page))) {
>> +		spin_lock(&from->deferred_split_queue.split_queue_lock);
>> +		list_del(page_deferred_list(page));
> It's worrisome that this page still appears to be on the deferred_list
> and that the above if() would still succeed.  Should this be
> list_del_init()?

list_del_init() sounds safe although I'm not quite sure this is 
possible. Will update this with fixing build issue together.

>
>> +		from->deferred_split_queue.split_queue_len--;
>> +		spin_unlock(&from->deferred_split_queue.split_queue_lock);
>> +	}
>> +#endif

