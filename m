Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C3EB56B000D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 05:22:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g5-v6so703455edp.1
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 02:22:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r11-v6si2764163edp.9.2018.08.08.02.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 02:22:34 -0700 (PDT)
Subject: Re: [RFC v6 PATCH 2/2] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1532628614-111702-1-git-send-email-yang.shi@linux.alibaba.com>
 <1532628614-111702-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180803090759.GI27245@dhcp22.suse.cz>
 <aff7e86d-2e48-ff58-5d5d-9c67deb68674@linux.alibaba.com>
 <20180806094005.GG19540@dhcp22.suse.cz>
 <76c0fc2b-fca7-9f22-214a-920ee2537898@linux.alibaba.com>
 <20180806204119.GL10003@dhcp22.suse.cz>
 <28de768b-c740-37b3-ea5a-8e2cb07d2bdc@linux.alibaba.com>
 <20180806205232.GN10003@dhcp22.suse.cz>
 <0cdff13a-2713-c5be-a33e-28c07e093bcc@linux.alibaba.com>
 <20180807054524.GQ10003@dhcp22.suse.cz>
 <04a22c49-fe30-63ac-c1b7-46a405c810e2@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3f960117-1485-9a61-8468-cb1590494e3c@suse.cz>
Date: Wed, 8 Aug 2018 11:22:32 +0200
MIME-Version: 1.0
In-Reply-To: <04a22c49-fe30-63ac-c1b7-46a405c810e2@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/08/2018 03:51 AM, Yang Shi wrote:
> On 8/6/18 10:45 PM, Michal Hocko wrote:
>> On Mon 06-08-18 15:19:06, Yang Shi wrote:
>>>
>>> On 8/6/18 1:52 PM, Michal Hocko wrote:
>>>> On Mon 06-08-18 13:48:35, Yang Shi wrote:
>>>>> On 8/6/18 1:41 PM, Michal Hocko wrote:
>>>>>> On Mon 06-08-18 09:46:30, Yang Shi wrote:
>>>>>>> On 8/6/18 2:40 AM, Michal Hocko wrote:
>>>>>>>> On Fri 03-08-18 14:01:58, Yang Shi wrote:
>>>>>>>>> On 8/3/18 2:07 AM, Michal Hocko wrote:
>>>>>>>>>> On Fri 27-07-18 02:10:14, Yang Shi wrote:
>>>>>> [...]
>>>>>>>>>>> If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, they are
>>>>>>>>>>> considered as special mappings. They will be dealt with before zapping
>>>>>>>>>>> pages with write mmap_sem held. Basically, just update vm_flags.
>>>>>>>>>> Well, I think it would be safer to simply fallback to the current
>>>>>>>>>> implementation with these mappings and deal with them on top. This would
>>>>>>>>>> make potential issues easier to bisect and partial reverts as well.
>>>>>>>>> Do you mean just call do_munmap()? It sounds ok. Although we may waste some
>>>>>>>>> cycles to repeat what has done, it sounds not too bad since those special
>>>>>>>>> mappings should be not very common.
>>>>>>>> VM_HUGETLB is quite spread. Especially for DB workloads.
>>>>>>> Wait a minute. In this way, it sounds we go back to my old implementation
>>>>>>> with special handling for those mappings with write mmap_sem held, right?
>>>>>> Yes, I would really start simple and add further enhacements on top.
>>>>> If updating vm_flags with read lock is safe in this case, we don't have to
>>>>> do this. The only reason for this special handling is about vm_flags update.
>>>> Yes, maybe you are right that this is safe. I would still argue to have
>>>> it in a separate patch for easier review, bisectability etc...
>>> Sorry, I'm a little bit confused. Do you mean I should have the patch
>>> *without* handling the special case (just like to assume it is safe to
>>> update vm_flags with read lock), then have the other patch on top of it,
>>> which simply calls do_munmap() to deal with the special cases?
>> Just skip those special cases in the initial implementation and handle
>> each special case in its own patch on top.
> 
> Thanks. VM_LOCKED area will not be handled specially since it is easy to 
> handle it, just follow what do_munmap does. The special cases will just 
> handle VM_HUGETLB, VM_PFNMAP and uprobe mappings.

So I think you could maybe structure code like this: instead of
introducing do_munmap_zap_rlock() and all those "bool skip_vm_flags"
additions, add a boolean parameter in do_munmap() to use the new
behavior, with only the first user SYSCALL_DEFINE2(munmap) setting it to
true. If true, do_munmap() will do the
- down_write_killable() itself instead of assuming it's already locked
- munmap_lookup_vma()
- check if any of the vma's in the range is "special", if yes, change
the boolean param to "false", and continue like previously, e.g. no mmap
sem downgrade etc.

That would be a basis for further optimizing the special vma cases in
subsequent patches (maybe it's really ok to touch the vma flags with
mmap sem for read as vma's are detached), and to eventually convert more
do_munmap() callers to the new mode.

HTH,
Vlastimil
