Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F962C76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 19:49:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C96CE20659
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 19:49:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C96CE20659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56D406B0003; Mon, 15 Jul 2019 15:49:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F5FC6B0005; Mon, 15 Jul 2019 15:49:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 396D26B0006; Mon, 15 Jul 2019 15:49:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0CCB6B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 15:49:32 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g18so8793493plj.19
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:49:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=dWjYy+tZWbTpTj5GaUB8ZuwaemgkRjIlDXWN0Hi0Anc=;
        b=iSlSm/HuTzv8kL/7GAklLoGzrcVV2vh/oyUqFK840AES94tBXzX1oGmZY0i4eznwZs
         uhOkvM9ER46Ml805hMYapRVLKm+h45maBYhyoNqj46JhxlYohvuELmnH4LynnHAjqykl
         glCsgSNLkZN1B+pel6L1Hc+koCFX/pewXf2/I/fk0KJpgmTbXhDLZcOgdNG0cpksBVeZ
         ANVJrH6gmcjqxsf0vCNK/uCuxGG4uxRcEMrqs0ry1SmEnvE1XwCTYaUUz4WdQArYKq0E
         WVsM1EvhAdH6pd6IxxB8bIGqXcqOoSR1EZtzBf4zXFPh7Jss+0YH6Dt1rt40WyVUgdTV
         PF6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWWc01sdd4lWAvd9YGljkYdIOmOa5EmV86mid/tSnouZ25rzSDe
	J+w8w2lXdZr2NtJFN/6OZZKEZ3UkIKsx9zr1Y04jis2kyb9Ct2C31PEZb7RkuSytmDhx5Sln8lx
	sNLktPm+YAoCrHwDqS/MsM/uj+kK1eKxFUmFKLBusb59XeZF7qoHn61T7SeEuuYltFQ==
X-Received: by 2002:a17:902:4283:: with SMTP id h3mr29509787pld.15.1563220172589;
        Mon, 15 Jul 2019 12:49:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTG2Yb7LOE2g1OAPJnZd/vh76V/rzb8LJXT5o6FOX9+exuWKAdLPVFEyixxwXVXUo61KjR
X-Received: by 2002:a17:902:4283:: with SMTP id h3mr29509742pld.15.1563220171879;
        Mon, 15 Jul 2019 12:49:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563220171; cv=none;
        d=google.com; s=arc-20160816;
        b=cX7iM5lyVHzN1qDYbQ4Ix4B3AfEppDQ1u94l7Fjt6YsT3Et7iyP5HPs/CxN9ctLQdo
         qqVMjJUSiCPoBCVNdv+QiNM3jMz0OLyImouyRGuQwUVSWmrgBDiNpjPFTfsiwmwmvsLc
         kYrTJxj8gKEHjZwQG2MoybeF0ulw7kyQhm7kflgwVfXTdinjgWxhAWrBg6cdlM6WXnPh
         YnmhcTByaTzuBNTxCM8UFnUSy+xinH/u42jiu4HfGUCgkZG1+rBODL9V+f0m+i/16YsK
         L8d4sj8F8j7oW2mEdhVZiay/edY6Vd70LGtXAi7UDBiM0/ece2yYE6RW+r6i7oRlRqGJ
         Rs5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=dWjYy+tZWbTpTj5GaUB8ZuwaemgkRjIlDXWN0Hi0Anc=;
        b=tPbwXuXxVMQDi3zbvJfQ4UnNHrjDzk1zkAOg+wFOiOxbvrb6CoUX8z9uORwvvC5pwW
         8WCmRcysAAdeU2eU79abWCbcJtM+LrVHsevHjAWDl7mESKD7Ye6Xs0RBwqseCuyMA/Wd
         ILpbl5CsW5SYFsaArXI6ZwWFkMwyqfLLT6SE7gtB43Wb0nnBKiVlhfdzUY1oJ/77hBk6
         k6gJf6P81a9wZY8XOkmvWIplIElhYxuLnv4q9iWqzXDQHB31u2VX2PEX7QfV4mk0FZ5D
         +Nj7npdq+qdKxojUHV3NVqexmG9oTrnhHw7K87qUF4l847ESourER99vvHEMlhaRZQ+9
         dhYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id z185si17499344pfb.109.2019.07.15.12.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 12:49:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R231e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TX.eHB5_1563220162;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX.eHB5_1563220162)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Jul 2019 03:49:25 +0800
Subject: Re: [v3 PATCH 0/2] Fix false negative of shmem vma's THP eligibility
To: hughd@google.com, kirill.shutemov@linux.intel.com, mhocko@suse.com,
 vbabka@suse.cz, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <11e1c58e-ffa4-fcb0-dc9e-95354e21c392@linux.alibaba.com>
Date: Mon, 15 Jul 2019 12:49:19 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,


Any comments for this version? Although they have been in -mm tree, they 
didn't make in 5.3 merge window, I'm supposed Andrew needs ack from you 
or someone else.


Thanks,

Yang



On 6/12/19 9:43 PM, Yang Shi wrote:
> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
> vma") introduced THPeligible bit for processes' smaps. But, when checking
> the eligibility for shmem vma, __transparent_hugepage_enabled() is
> called to override the result from shmem_huge_enabled().  It may result
> in the anonymous vma's THP flag override shmem's.  For example, running a
> simple test which create THP for shmem, but with anonymous THP disabled,
> when reading the process's smaps, it may show:
>
> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
> Size:               4096 kB
> ...
> [snip]
> ...
> ShmemPmdMapped:     4096 kB
> ...
> [snip]
> ...
> THPeligible:    0
>
> And, /proc/meminfo does show THP allocated and PMD mapped too:
>
> ShmemHugePages:     4096 kB
> ShmemPmdMapped:     4096 kB
>
> This doesn't make too much sense.  The shmem objects should be treated
> separately from anonymous THP.  Calling shmem_huge_enabled() with checking
> MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
> dax vma check since we already checked if the vma is shmem already.
>
> The transhuge_vma_suitable() is needed to check vma, but it was only
> available for shmem THP.  The patch 1/2 makes it available for all kind of
> THPs and does some code duplication cleanup, so it is made a separate patch.
>
>
> Changelog:
> v3: * Check if vma is suitable for allocating THP per Hugh Dickins
>      * Fixed smaps output alignment and documentation per Hugh Dickins
> v2: * Check VM_NOHUGEPAGE per Michal Hocko
>
>
> Yang Shi (2):
>        mm: thp: make transhuge_vma_suitable available for anonymous THP
>        mm: thp: fix false negative of shmem vma's THP eligibility
>
>   Documentation/filesystems/proc.txt |  4 ++--
>   fs/proc/task_mmu.c                 |  3 ++-
>   mm/huge_memory.c                   | 11 ++++++++---
>   mm/internal.h                      | 25 +++++++++++++++++++++++++
>   mm/memory.c                        | 13 -------------
>   mm/shmem.c                         |  3 +++
>   6 files changed, 40 insertions(+), 19 deletions(-)

