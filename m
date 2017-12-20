Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB2C26B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 20:36:00 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t88so5327513pfg.17
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 17:36:00 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTPS id y4si12129560pfl.122.2017.12.19.17.35.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 17:35:59 -0800 (PST)
Subject: Re: [PATCH] mm: thp: use down_read_trylock in khugepaged to avoid
 long block
References: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
 <20171215102753.GY16951@dhcp22.suse.cz>
 <13f935a9-42af-98f4-1813-456a25200d9d@alibaba-inc.com>
 <20171216114525.GH16951@dhcp22.suse.cz>
 <20171216200925.kxvkuqoyhkonj7m6@node.shutemov.name>
 <20171218084119.GJ16951@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <155d6243-8219-3a8a-826c-0f0480639274@alibaba-inc.com>
Date: Wed, 20 Dec 2017 09:35:39 +0800
MIME-Version: 1.0
In-Reply-To: <20171218084119.GJ16951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/18/17 12:41 AM, Michal Hocko wrote:
> On Sat 16-12-17 23:09:25, Kirill A. Shutemov wrote:
>> On Sat, Dec 16, 2017 at 12:45:25PM +0100, Michal Hocko wrote:
>>> On Sat 16-12-17 04:04:10, Yang Shi wrote:
> [...]
>>>> Shall we add "cond_resched()" in unmap_vmas(), i.e for every 100 vmas? It
>>>> may improve the responsiveness a little bit for non-preempt kernel, although
>>>> it still can't release the semaphore.
>>>
>>> We already do, once per pmd (see zap_pmd_range).
>>
>> It doesn't help. We would need to find a way to drop mmap_sem, if we're
>> holding it way too long. And doing it on per-vma count basis is not right
>> call. It won't address issue with single huge vma.
> 
> Absolutely agreed. I just wanted to point out that a new cond_resched is
> not really needed. One way to reduce the lock starvation is to use range
> locking.

It looks the range locking development is stalled?

Yang

> 
>> Do we have any instrumentation that would help detect starvation on a
>> rw_semaphore?
> 
> I am afraid we don't.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
