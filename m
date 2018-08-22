Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8D806B2643
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 16:46:14 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m25-v6so1577491pgv.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 13:46:14 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id d13-v6si2392733pll.337.2018.08.22.13.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 13:46:13 -0700 (PDT)
Subject: Re: [RFC v8 PATCH 3/5] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
 <e691d054-f807-80ad-9934-a1917d8e2e77@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3c62f605-2244-6a05-2dc4-34a3f1c56300@linux.alibaba.com>
Date: Wed, 22 Aug 2018 13:45:44 -0700
MIME-Version: 1.0
In-Reply-To: <e691d054-f807-80ad-9934-a1917d8e2e77@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 8/22/18 4:19 AM, Vlastimil Babka wrote:
> On 08/15/2018 08:49 PM, Yang Shi wrote:
>> +	downgrade_write(&mm->mmap_sem);
>> +
>> +	/* Zap mappings with read mmap_sem */
>> +	unmap_region(mm, start_vma, prev, start, end);
>> +
>> +	arch_unmap(mm, start_vma, start, end);
> Hmm, did you check that all architectures' arch_unmap() is safe with
> read mmap_sem instead of write mmap_sem? E.g. x86 does
> mpx_notify_unmap() there where I would be far from sure at first glance...

Yes, I'm also not quite sure if it is 100% safe or not. I was trying to 
move this before downgrade_write, however, I'm not sure if it is ok or 
not too, so I keep the calling sequence.

For architectures, just x86 and ppc really do something. PPC just uses 
it for vdso unmap which should just happen during process exit, so it 
sounds safe.

For x86, mpx_notify_unmap() looks finally zap the VM_MPX vmas in bound 
table range with zap_page_range() and doesn't update vm flags, so it 
sounds ok to me since vmas have been detached, nobody can find those 
vmas. But, I'm not familiar with the details of mpx, maybe Kirill could 
help to confirm this?

Thanks,
Yang

>
>> +	remove_vma_list(mm, start_vma);
>> +	up_read(&mm->mmap_sem);
