Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E443C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:18:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15375206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:18:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15375206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2C9A6B0005; Thu, 18 Apr 2019 12:18:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DC336B0006; Thu, 18 Apr 2019 12:18:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CC856B0007; Thu, 18 Apr 2019 12:18:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5383B6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:18:23 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d10so1758143plo.12
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:18:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=TaYlV25LJSfSRJZwjOsJqihnJJrlo+VyWuK9+fdtdT0=;
        b=uPJD/VlGd3QZ4v6w5mmkYwNXlq3M+77dvQBKQaEe7iihIhlZwYVjx+Gtv36FIABQR0
         /BVpG1TKEmqf9kBKDmvr+4cVwp+zETcUleMzSeNBmdI2JzDla+TWgKak5gqkSXmduHOe
         bvVlrdj2CvS/3/4Btf0tF1XNQUp1LRLfwMzENRIu5WQgkWJ/tFCSGYjuzyWw7NY5LyHm
         TcYbpUwLsbGP9R3jyiqOmBXcZ1P9zZTtRh5zGzdm7HaiPTjZWGnu5j+HHhRVAQ76XwsY
         p5F3/IU97vpMAjKRii1kAb5lLRZpgGaON8xdacfUD6cSSIq9mF0ZVK5BmTb8hxhZr4Sj
         h7UQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUXxvMbSS1jHzNMxR+fM7/C1m0eSkmlgSXHQKp+pJ7kdeitwTcd
	iYKpdm7IegFYSDBy6A9+izdIj+BQWXuRGnlCoweT8wot9nvbERpeMNxpFKJbLfkBkL/osLgvLnX
	ZR0PAVltCjaq7Wn5RHfT3bvTPB7JKHMPZnxzW3ZHOfyPz2UGC2E0d3UY/5YXEqak/gg==
X-Received: by 2002:a63:8848:: with SMTP id l69mr85125443pgd.137.1555604302986;
        Thu, 18 Apr 2019 09:18:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1356LFGzy5Y61EvrUCeKGHgaLGxCR5oNB/zZz5EtSdit5yQFLDhMt0vRbtjwQcVZlvB2y
X-Received: by 2002:a63:8848:: with SMTP id l69mr85125372pgd.137.1555604302123;
        Thu, 18 Apr 2019 09:18:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555604302; cv=none;
        d=google.com; s=arc-20160816;
        b=Mh5WRdLiWm43MQfz6bnQqaYWxnrml6NQyOR2NkxLxf6Y4pZ7HCzo7cHMAUz2CJ59Sb
         GREYI+yD9NMBTJ92xLgc0MJDr1JD5U3KiWr6jdMVmHFgy4/PPMu8gxpgHAogUKVO3RNn
         tQwTqgPq5x2mvPFS5hE/csYhyxo0igJlCwFl9UYTrdrLlAZNJ6PHLia5mzboyfncBoav
         8YvAtwMLwHz8pj7lIbBOVIngAv+FSJqJ97JT0VEjVnZSeN5v6kUobs79LdsAf7MCLtoh
         wGZ34l+171SRYDNPwZyxhJs8b57mG0aig1s4G4X7r7K7rhv/5WfnwEofdW6JCYCQtSaJ
         BBwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=TaYlV25LJSfSRJZwjOsJqihnJJrlo+VyWuK9+fdtdT0=;
        b=fXgRlqD2Gz3QRa6a2m24vY59t3qzQGd/8Jirnn0N4GV3tC8+AjoEpYYC/83T2J6rCQ
         Tm061hJtYKpplsBb11EguXlzZ/W0pZfcHUaXLTAW4srEniaZKKQ6VIyp6ZHfYUGgR4Dd
         d9B+ojjgyZZH3i0UlT/mdXQgDWvZgvWwtkkUO0aUsUeo9pPmjAUt5dla9KIWXpW1D49o
         VJdUqWippTqotn2c6xgGetvy/Aa0yfrVvJgQqnful7oZlUfe14YmCYdt2iElhyKrMTaG
         n35e6Qs2kjBc0xul+UsxMo5LwLw4D8+GldKCSdOQCwD7hYyrVbOd38vLkbknHZmiF6QE
         Vy7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id a6si2484283plm.62.2019.04.18.09.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 09:18:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TPeaAyH_1555604295;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPeaAyH_1555604295)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 19 Apr 2019 00:18:18 +0800
Subject: Re: [QUESTIONS] THP allocation in NUMA fault migration path
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>,
 Andrea Arcangeli <aarcange@redhat.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 linux-kernel <linux-kernel@vger.kernel.org>
References: <aa34f38e-5e55-bdb2-133c-016b91245533@linux.alibaba.com>
 <20190418063218.GA6567@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <bb2464c9-dc45-eff1-b9ac-f29105ccd27b@linux.alibaba.com>
Date: Thu, 18 Apr 2019 09:18:15 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190418063218.GA6567@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/17/19 11:32 PM, Michal Hocko wrote:
> On Wed 17-04-19 21:15:41, Yang Shi wrote:
>> Hi folks,
>>
>>
>> I noticed that there might be new THP allocation in NUMA fault migration
>> path (migrate_misplaced_transhuge_page()) even when THP is disabled (set to
>> "never"). When THP is set to "never", there should be not any new THP
>> allocation, but the migration path is kind of special. So I'm not quite sure
>> if this is the expected behavior or not?
>>
>>
>> And, it looks this allocation disregards defrag setting too, is this
>> expected behavior too?H
> Could you point to the specific code? But in general the miTgration path

Yes. The code is in migrate_misplaced_transhuge_page() called by 
do_huge_pmd_numa_page().

It would just do:
alloc_pages_node(node, (GFP_TRANSHUGE_LIGHT | __GFP_THISNODE), 
HPAGE_PMD_ORDER);
without checking if transparent_hugepage is enabled or not.

THP may be disabled before calling into do_huge_pmd_numa_page(). The 
do_huge_pmd_wp_page() does check if THP is disabled or not. If THP is 
disabled, it just tries to allocate 512 base pages.

> should allocate the memory matching the migration origin. If the origin
> was a THP then I find it quite natural if the target was a huge page as

Yes, this is what I would like to confirm. Migration allocates a new THP 
to replace the old one.

> well. How hard the allocation should try is another question and I
> suspect we do want to obedy the defrag setting.

Yes, I thought so too. However, THP NUMA migration was added in 3.8 by 
commit b32967f ("mm: numa: Add THP migration for the NUMA working set 
scanning fault case."). It disregarded defrag setting at the very 
beginning. So, I'm not quite sure if it was done on purpose or just 
forgot it.

Thanks,
Yang


