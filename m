Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63A716B75A5
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 13:13:28 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v64so20945638qka.5
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 10:13:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e7si941897qvp.159.2018.12.05.10.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 10:13:27 -0800 (PST)
Subject: Re: [PATCH RFC 7/7] mm: better document PG_reserved
References: <20181205122851.5891-1-david@redhat.com>
 <20181205122851.5891-8-david@redhat.com>
 <20181205143510.GA17232@bombadil.infradead.org>
 <46d0e90f-f0bb-815e-7a5b-4429de1c502a@redhat.com>
 <20181205173201.GA11646@bombadil.infradead.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <35689ede-d86e-d692-adae-bc2f1adfb2ab@redhat.com>
Date: Wed, 5 Dec 2018 19:13:21 +0100
MIME-Version: 1.0
In-Reply-To: <20181205173201.GA11646@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Anthony Yznaga <anthony.yznaga@oracle.com>, Miles Chen <miles.chen@mediatek.com>, yi.z.zhang@linux.intel.com, Dan Williams <dan.j.williams@intel.com>

On 05.12.18 18:32, Matthew Wilcox wrote:
> On Wed, Dec 05, 2018 at 04:05:12PM +0100, David Hildenbrand wrote:
>> On 05.12.18 15:35, Matthew Wilcox wrote:
>>> On Wed, Dec 05, 2018 at 01:28:51PM +0100, David Hildenbrand wrote:
>>>> I don't see a reason why we have to document "Some of them might not even
>>>> exist". If there is a user, we should document it. E.g. for balloon
>>>> drivers we now use PG_offline to indicate that a page might currently
>>>> not be backed by memory in the hypervisor. And that is independent from
>>>> PG_reserved.
>>>
>>> I think you're confused by the meaning of "some of them might not even
>>> exist".  What this means is that there might not be memory there; maybe
>>> writes to that memory will be discarded, or maybe they'll cause a machine
>>> check.  Maybe reads will return ~0, or 0, or cause a machine check.
>>> We just don't know what's there, and we shouldn't try touching the memory.
>>
>> If there are users, let's document it. And I need more details for that :)
>>
>> 1. machine check: if there is a HW error, we set PG_hwpoison (except
>> ia64 MCA, see the list)
>>
>> 2. Writes to that memory will be discarded
>>
>> Who is the user of that? When will we have such pages right now?
>>
>> 3. Reads will return ~0, / 0?
>>
>> I think this is a special case of e.g. x86? But where do we have that,
>> are there any user?
> 
> When there are gaps in the physical memory.  As in, if you put that
> physical address on the bus (or in a packet), no device will respond
> to it.  Look:
> 
> 00000000-00000fff : Reserved
> 00001000-00057fff : System RAM
> 00058000-00058fff : Reserved
> 00059000-0009dfff : System RAM
> 0009e000-000fffff : Reserved
> 
> Those examples I gave are examples of how various different architectures
> respond to "no device responded to this memory access".
> 

Okay, so for this memory we will have
a) vmmaps
b) Memory block devices
c) A sections that is online

So essentially "Gaps in physical memory" which is part of a online section.

This might be a candidate for PG_offline as well.

Thanks for the info, I'll try to find out how such things are handled.
In general I assume this memory has to be readable, because otherwise
kdump and friends would crash already when trying to dump?

-- 

Thanks,

David / dhildenb
