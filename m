Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CFECC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:13:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 325F02175B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:13:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 325F02175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E57B8E0002; Thu, 13 Jun 2019 13:13:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 896688E0001; Thu, 13 Jun 2019 13:13:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7847B8E0002; Thu, 13 Jun 2019 13:13:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 425818E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:13:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i2so4299057pfe.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:13:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=MFsgK+IE36w0ET36HY/Y/1ZMSo/8rsy2hTpVb2io/tM=;
        b=TQMCQ7UeqjLVl8qKQgExMiMkIK79De3iUjsjTGeYUMPtJprFWzY2U580U2kQQRhJla
         xicneYaPWYC5dY6rBVccdsUN7f5/eE5Ji7KrU/xX5IVKW8LyWkZYFUkFCvzUaEwR1xJI
         zlKcp7ltw3bfLixR3NRxfHKPIxNaHPxsniLCQf35s+ULBWPW1g+dIzzAQ7CFdvWAc0n0
         eeIUgzqUENnXO3LZegTe8Dr4ywzqlmN8pnp4yT8rEJih4OylTm9RI3KneDCzGFzyxAt1
         QW7ORYfFSOUgjmWGllCJsHrSyKflEONsj6uNnfioMazW/EXJgZNHmowQ6s8CkJ8b+4kH
         m/tA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWuFHPTzxas97t1bsOGIUfjkPlPjnxuaF1l0RZ5lcg0dw56uesO
	tyWL0DGilB43/YFtPZOd8teUuur8/IeiLIGr75nWzk3TFIF2xvW63PE2WtLe6+KEZgdrvdhca4p
	w+ShrxsfBLyPKDNpllOH8rICecJgZEKS0v0E10eHzoLZd7HcbPfCxiYCjAHe0EOZprg==
X-Received: by 2002:aa7:8212:: with SMTP id k18mr44939750pfi.246.1560446011938;
        Thu, 13 Jun 2019 10:13:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgPUzIvERa6a3OD3SPimy2G0vrRkPvTYJXAy8Dm1iieugDNGiuyCLG8seqIjpdbzoWGUXL
X-Received: by 2002:aa7:8212:: with SMTP id k18mr44939706pfi.246.1560446011241;
        Thu, 13 Jun 2019 10:13:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560446011; cv=none;
        d=google.com; s=arc-20160816;
        b=R6IkalruRo9xeR9CjhQ8OoX8cQT/eZC0KUEe04R46UqDvmyE3jQuq2qac/F59VS0UJ
         sgwqhpJwFKbahSTmgym0lKZflOC6hsRb4tc0skXWxKDAbhxjk5vYM9NC78ZmKrEUcgj6
         Ryt54w3WglF01Hz2OK8H2yTPel9xKx+sMLe2uM7j1bSUuJluANnlkhyaPibAcwkmMV6V
         bI2WWKyIw/P65nXNupmi6N0KTU3AAiNBOOMEfO54zwcuZsgPKA2HMcSLxlZ2AaHO8Juf
         xQO7/LpDJeL/vftt4NEePCrD5gtZlVWLvnW6s+syUxvBO1nprsnS2NA/amGrPO52WOLV
         BzAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=MFsgK+IE36w0ET36HY/Y/1ZMSo/8rsy2hTpVb2io/tM=;
        b=NRjLZK3j+lzTSFzh/69rEp/R9Aq2mpO5PbSO/oXGD3It5JJg9HKB0FJbb2kDJp6eOs
         itAMEtGa15nD4n498bAMlvg95m+0T7R5pDl1CE66jJRIPTtIDqQ9pBTcmsxatEu5uUAo
         aeKpOLo3/USiZzi42rtgvsYKhVYoQeppisuxcPLf5cRPDnLV+5gCnFx1IFbg0Zwp/EOX
         uZ6KPsPf8iUL9rrx/G+VP0J4v3rgrz/TDmZu9JxLL4z40N9nPsUvhTcKa10USSpylMrI
         3Eb2sXHyhJlnNqFN4+4aTL9TPk8p1/JIiQlnc+gb/gLrNf113abJ1cKyVH3tjFn+cvif
         DHvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id h11si125249pls.374.2019.06.13.10.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 10:13:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R591e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TU55.Xp_1560446003;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU55.Xp_1560446003)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 14 Jun 2019 01:13:26 +0800
Subject: Re: [v3 PATCH 2/4] mm: move mem_cgroup_uncharge out of
 __page_cache_release()
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560376609-113689-3-git-send-email-yang.shi@linux.alibaba.com>
 <20190613113943.ahmqpezemdbwgyax@box>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <2909ce59-86ba-ea0b-479f-756020fb32af@linux.alibaba.com>
Date: Thu, 13 Jun 2019 10:13:19 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190613113943.ahmqpezemdbwgyax@box>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/13/19 4:39 AM, Kirill A. Shutemov wrote:
> On Thu, Jun 13, 2019 at 05:56:47AM +0800, Yang Shi wrote:
>> The later patch would make THP deferred split shrinker memcg aware, but
>> it needs page->mem_cgroup information in THP destructor, which is called
>> after mem_cgroup_uncharge() now.
>>
>> So, move mem_cgroup_uncharge() from __page_cache_release() to compound
>> page destructor, which is called by both THP and other compound pages
>> except HugeTLB.  And call it in __put_single_page() for single order
>> page.
>
> If I read the patch correctly, it will change behaviour for pages with
> NULL_COMPOUND_DTOR. Have you considered it? Are you sure it will not break
> anything?

So far a quick search shows NULL_COMPOUND_DTOR is not used by any type 
of compound page. The HugeTLB code sets destructor to NULL_COMPOUND_DTOR 
when freeing hugetlb pages via hugetlb specific destructor.

The prep_new_page() would call prep_compound_page() if __GFP_COMP is 
used, which sets dtor to COMPOUND_PAGE_DTOR by default.  Just hugetlb 
and THP set their specific dtors.

And, it looks __put_compound_page() doesn't check if dtor is NULL or not 
at all.

>

