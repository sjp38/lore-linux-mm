Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 012526B0278
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:37:42 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o18-v6so673676qtm.11
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 01:37:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w44-v6si715543qtg.179.2018.07.26.01.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 01:37:41 -0700 (PDT)
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
References: <20180723123043.GD31229@dhcp22.suse.cz>
 <8daae80c-871e-49b6-1cf1-1f0886d3935d@redhat.com>
 <20180724072536.GB28386@dhcp22.suse.cz>
 <8eb22489-fa6b-9825-bc63-07867a40d59b@redhat.com>
 <20180724131343.GK28386@dhcp22.suse.cz>
 <af5353ee-319e-17ec-3a39-df997a5adf43@redhat.com>
 <20180724133530.GN28386@dhcp22.suse.cz>
 <6c753cae-f8b6-5563-e5ba-7c1fefdeb74e@redhat.com>
 <20180725135147.GN28386@dhcp22.suse.cz>
 <344d5f15-c621-9973-561e-6ed96b29ea88@redhat.com>
 <20180726082723.GB28386@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <60975612-9b91-65dd-03d8-579ba23a6c01@redhat.com>
Date: Thu, 26 Jul 2018 10:37:33 +0200
MIME-Version: 1.0
In-Reply-To: <20180726082723.GB28386@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On 26.07.2018 10:27, Michal Hocko wrote:
> On Wed 25-07-18 16:20:41, David Hildenbrand wrote:
>> On 25.07.2018 15:51, Michal Hocko wrote:
>>> On Tue 24-07-18 16:13:09, David Hildenbrand wrote:
>>> [...]
>>>> So I see right now:
>>>>
>>>> - Pg_reserved + e.g. new page type (or some other unique identifier in
>>>>   combination with Pg_reserved)
>>>>  -> Avoid reads of pages we know are offline
>>>> - extend is_ram_page()
>>>>  -> Fake zero memory for pages we know are offline
>>>>
>>>> Or even both (avoid reading and don't crash the kernel if it is being done).
>>>
>>> I really fail to see how that can work without kernel being aware of
>>> PageOffline. What will/should happen if you run an old kdump tool on a
>>> kernel with this partially offline memory?
>>>
>>
>> New kernel with old dump tool:
>>
>> a) we have not fixed up is_ram_page()
>>
>> -> crash, as we access memory we shouldn't
> 
> this is not acceptable, right? You do not want to crash your crash
> kernel ;)

Well, the same can happen today with PageHWPoison. The "new" kernel will
happily access such pages and crash as far as I understand (it has has
no idea of the old struct pages). Of course, this is "less likely" than
what I describe.

> 
>> b) we have fixed up is_ram_page()
>>
>> -> We have a callback to check for applicable memory in the hypervisor
>> whether the parts are accessible / online or not accessible / offline.
>> (e.g. via a device driver that controls a certain memory region)
>>
>> -> Don't read, but fake a page full of 0
>>
>>
>> So instead of the kernel being aware of it, it asks via is_ram_page()
>> the hypervisor.
> 
> I am still confused why do we even care about hypervisor. What if
> somebody wants to have partial memory hotplug on native OS?

Good point I was ignoring so far (too much focusing on my use case I
assume). So for these, we would have to catch illegal accesses and

a) report them (-EINVAL / - EIO) as you said
b) fake a zero page

I assume catching illegal accesses should be possible. Might require
some work across all architectures.

Still, dump tools should in addition not even try to read if possible.

>  
>> I don't think a) is a problem. AFAICS, we have to update makedumpfile
>> for every new kernel. We can perform changes and update makedumpfile
>> to be compatible with new dump tools.
> 
> Not really. You simply do not crash the kernel just because you are
> trying to dump the already crashed kernel.
> 
>> E.g. remember SECTION_IS_ONLINE you introduced ? It broke dump
>> tools and required
> 
> But has it crashed the kernel when reading the dump? If yes then the
> whole dumping is fragile as hell...

No, I think it simply didn't work. At least that's what I assume ;) I
was rather saying that dump tools may have to be fixed up to work with a
new kernel.


-- 

Thanks,

David / dhildenb
