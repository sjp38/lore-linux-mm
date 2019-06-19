Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 528CCC31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 18:19:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C19621734
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 18:19:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C19621734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B50FA6B0005; Wed, 19 Jun 2019 14:19:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD8D98E0002; Wed, 19 Jun 2019 14:19:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A1AF8E0001; Wed, 19 Jun 2019 14:19:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7162B6B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 14:19:30 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id q16so10883otn.11
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 11:19:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=OhJnBoKlATJUCj/JD01NB7lr1Um0+XSiV0rNmZrQRHc=;
        b=Jz2YAUgiQpmZYUR2Ze4P/9Et72uTxgioYQIyymlYA/S9TuChRLep+xoq/N88ib7YoE
         eBUfs8wjzNEuqDOrj7JzvUFlwEbjCunY0e3LenUM5aqgfX1M0z0k1ZsqnIIPZGaN8B1r
         G5xuuAt4FOrLIRTNtUXkTI3g1V5KVubftdd7djeKXlQsHc14Ru2oy93MUbzvRfeu0jRa
         Q9V87n+3WYmpt1zKc8rMCceZ5u0A5xqKCU+X+CxgUuaEpxn4u/Vb5TiNzTADfzlJarAi
         0xpTLpyS4r+PVTcqr+CgMh2QCmafHenjR42VSB85hQLGVtfOt/OQbc08vT7c7WhLtNhA
         0WwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX4Se+HuoQYqu6Ljb5IVaXp/aiEYOO6qlrSBM/qgTPZjyQmy8hA
	i137oTd/daN8xC9VzsOX3z8bg6GxgOtKJKz0GtTtDco6emNrcqaxQ0VFg5K0cSFBEMdacUlxt+O
	sGYCMvf9F9Exl9JJVOCn4+/a/2v4/IH7Nx+Fp9LAFZnac4mfG2RTjbyKyoRuxjOiolA==
X-Received: by 2002:aca:d60c:: with SMTP id n12mr1373000oig.105.1560968370086;
        Wed, 19 Jun 2019 11:19:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyy9nnE5Bt6yNz9NCgSVd17AW3eK7sNKFjUKEyzVEeAyw2+XRrxTCnDvBI8DjvX/KnhnaR8
X-Received: by 2002:aca:d60c:: with SMTP id n12mr1372981oig.105.1560968369478;
        Wed, 19 Jun 2019 11:19:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560968369; cv=none;
        d=google.com; s=arc-20160816;
        b=Il/JkJRyzO2GAw2OY1/fGVO0zBnSoNGImR4dIR/0hDtUSZHrep7y4OkMbTg0PCaKHw
         Jziybd4kLTON5vuqPdaz0GB4fXXhhlWDL6IvVLbuEJL8ZK6219M0PMrTnmlOdVrJ2zZx
         1adIE5oEthgXGvMl4ZB8uNzXvoTO4piYfIVRRVZP1++cAUgZqmh0d8qTwwDF4TXtD/Hc
         6D6WXxWwAprmz4gmGDALaIZXY+dAZtSqYBouOMeeijGqCnwIzaGWj6MRQf8o7BAEMDAt
         UYr7ciQYO1VVU9h8tTn1fzJHgmqT4wCPFSMVFGH7FhXqIZ87GEpAhG+kkraM31SachD4
         skEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=OhJnBoKlATJUCj/JD01NB7lr1Um0+XSiV0rNmZrQRHc=;
        b=zp3/NgUe8sMEfNaiuj2rJryVW7pX/UwtDEaRRkz+gkPjzpn5vvK2aI3pn83h5xkzUK
         BHgjeBqeSUqPsahbPUJ4WT0qpzo+HtsG2ZqdlwxqCDesk3A3FFT6tj6dp1ycIKTp+l2x
         aUAyGQ4IsU6JfAWsI9ovu2kibsMmVhSBh9JuJt8BLRTrey56fzGCJr0sCAwCBJ718bMl
         6OD1L+LHfgij5vBmxCbPfQUOonZtuVcDvxO7hN+mBTEq/iCwaQQ+NsurBuiOs13IlWID
         vHRqDxjRm2abubT+TsXi0mGHnOc1q6hBr8N9TzrybIbc/oMR99wzKqdALT6qdEYJrh/r
         PoCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id y38si11293715ota.213.2019.06.19.11.19.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 11:19:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TUfkZRu_1560968352;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TUfkZRu_1560968352)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 20 Jun 2019 02:19:15 +0800
Subject: Re: [PATCH] mm: mempolicy: handle vma with unmovable pages mapped
 correctly in mbind
From: Yang Shi <yang.shi@linux.alibaba.com>
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
Message-ID: <55eb2ea9-2c74-87b1-4568-b620c7913e17@linux.alibaba.com>
Date: Wed, 19 Jun 2019 11:19:09 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <687f4e57-5c50-7900-645e-6ef3a5c1c0c7@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/19/19 9:21 AM, Yang Shi wrote:
>
>
> On 6/19/19 1:22 AM, Vlastimil Babka wrote:
>> On 6/19/19 7:21 AM, Michal Hocko wrote:
>>> On Tue 18-06-19 14:13:16, Yang Shi wrote:
>>> [...]
>>>> I used to have !__PageMovable(page), but it was removed since the
>>>> aforementioned reason. I could add it back.
>>>>
>>>> For the temporary off LRU page, I did a quick search, it looks the 
>>>> most
>>>> paths have to acquire mmap_sem, so it can't race with us here. Page
>>>> reclaim/compaction looks like the only race. But, since the mapping 
>>>> should
>>>> be preserved even though the page is off LRU temporarily unless the 
>>>> page is
>>>> reclaimed, so we should be able to exclude temporary off LRU pages by
>>>> calling page_mapping() and page_anon_vma().
>>>>
>>>> So, the fix may look like:
>>>>
>>>> if (!PageLRU(head) && !__PageMovable(page)) {
>>>>      if (!(page_mapping(page) || page_anon_vma(page)))
>>>>          return -EIO;
>>> This is getting even more muddy TBH. Is there any reason that we 
>>> have to
>>> handle this problem during the isolation phase rather the migration?
>> I think it was already said that if pages can't be isolated, then
>> migration phase won't process them, so they're just ignored.
>
> Yes，exactly.
>
>> However I think the patch is wrong to abort immediately when
>> encountering such page that cannot be isolated (AFAICS). IMHO it should
>> still try to migrate everything it can, and only then return -EIO.
>
> It is fine too. I don't see mbind semantics define how to handle such 
> case other than returning -EIO.

By looking into the code, it looks not that easy as what I thought. 
do_mbind() would check the return value of queue_pages_range(), it just 
applies the policy and manipulates vmas as long as the return value is 0 
(success), then migrate pages on the list. We could put the movable 
pages on the list by not breaking immediately, but they will be ignored. 
If we migrate the pages regardless of the return value, it may break the 
policy since the policy will *not* be applied at all.

>
>

