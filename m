Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD2CD6B25EE
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 15:21:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z18-v6so1717514pfe.19
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 12:21:20 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id w18-v6si2242349plq.104.2018.08.22.12.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 12:21:19 -0700 (PDT)
Subject: Re: [RFC v8 PATCH 3/5] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
 <7145895b-ef56-f5ee-d139-609819d9a107@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <2f447d4e-9e16-8030-85f0-4e258a7eafa3@linux.alibaba.com>
Date: Wed, 22 Aug 2018 12:20:37 -0700
MIME-Version: 1.0
In-Reply-To: <7145895b-ef56-f5ee-d139-609819d9a107@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 8/22/18 4:11 AM, Vlastimil Babka wrote:
> On 08/15/2018 08:49 PM, Yang Shi wrote:
>
>> +	start_vma = munmap_lookup_vma(mm, start, end);
>> +	if (!start_vma)
>> +		goto out;
>> +	if (IS_ERR(start_vma)) {
>> +		ret = PTR_ERR(start_vma);
>> +		goto out;
>> +	}
>> +
>> +	prev = start_vma->vm_prev;
>> +
>> +	if (unlikely(uf)) {
>> +		ret = userfaultfd_unmap_prep(start_vma, start, end, uf);
>> +		if (ret)
>> +			goto out;
>> +	}
>> +
> You sure it's ok to redo this in case of goto regular path? The
> preparations have some side-effects... I would rather move this after
> the regular path check?

This preparation sets vma->vm_userfaultfd_ctx.ctx for each vmas. But, 
before doing this, it calls has_unmap_ctx() to check if the ctx has been 
set or not. If it has been set, it just skip the vma. It sounds ok, right?
