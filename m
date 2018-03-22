Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D08A36B0062
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 13:34:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p128so4494544pga.19
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 10:34:17 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id c16si4510374pgv.729.2018.03.22.10.34.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 10:34:16 -0700 (PDT)
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321130833.GM23100@dhcp22.suse.cz>
 <f88deb20-bcce-939f-53a6-1061c39a9f6c@linux.alibaba.com>
 <20180321172932.GE4780@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <af814bbe-b6b5-12f8-72e5-7935e767bd87@linux.alibaba.com>
Date: Thu, 22 Mar 2018 10:34:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180321172932.GE4780@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/21/18 10:29 AM, Matthew Wilcox wrote:
> On Wed, Mar 21, 2018 at 09:31:22AM -0700, Yang Shi wrote:
>> On 3/21/18 6:08 AM, Michal Hocko wrote:
>>> Yes, this definitely sucks. One way to work that around is to split the
>>> unmap to two phases. One to drop all the pages. That would only need
>>> mmap_sem for read and then tear down the mapping with the mmap_sem for
>>> write. This wouldn't help for parallel mmap_sem writers but those really
>>> need a different approach (e.g. the range locking).
>> page fault might sneak in to map a page which has been unmapped before?
>>
>> range locking should help a lot on manipulating small sections of a large
>> mapping in parallel or multiple small mappings. It may not achieve too much
>> for single large mapping.
> I don't think we need range locking.  What if we do munmap this way:
>
> Take the mmap_sem for write
> Find the VMA
>    If the VMA is large(*)
>      Mark the VMA as deleted
>      Drop the mmap_sem
>      zap all of the entries
>      Take the mmap_sem
>    Else
>      zap all of the entries
> Continue finding VMAs
> Drop the mmap_sem
>
> Now we need to change everywhere which looks up a VMA to see if it needs
> to care the the VMA is deleted (page faults, eg will need to SIGBUS; mmap
> does not care; munmap will need to wait for the existing munmap operation

The other question is why munmap need wait? If the other parallel munmap 
finds the vma has been marked as "deleted", it just need return 0 as it 
doesn't find vma.

Currently do_munmap() does the below logic:
     vma = find_vma(mm, start);
     if (!vma)
         return 0;

Yang

> to complete), but it gives us the atomicity, at least on a per-VMA basis.
>
> We could also do:
>
> Take the mmap_sem for write
> Mark all VMAs in the range as deleted & modify any partial VMAs
> Drop mmap_sem
> zap pages from deleted VMAs
>
> That would give us the same atomicity that we have today.
>
> Deleted VMAs would need a pointer to a completion, so operations that
> need to wait can queue themselves up.  I'd recommend we use the low bit
> of vm_file and treat it as a pointer to a struct completion if set.
