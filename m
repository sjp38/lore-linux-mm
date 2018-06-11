Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E10526B0003
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:54:00 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z10-v6so19303788qki.5
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 04:54:00 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u186-v6si461635qkf.355.2018.06.11.04.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 04:53:59 -0700 (PDT)
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
From: David Hildenbrand <david@redhat.com>
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
 <20180524093121.GZ20441@dhcp22.suse.cz>
 <c0b8bbd5-6c01-f550-ae13-ef80b2255ea6@redhat.com>
 <20180524120341.GF20441@dhcp22.suse.cz>
 <1a03ac4e-9185-ce8e-a672-c747c3e40ff2@redhat.com>
 <20180524142241.GJ20441@dhcp22.suse.cz>
 <819e45c5-6ae3-1dff-3f1d-c0411b6e2e1d@redhat.com>
Message-ID: <3748f033-f349-6d88-d189-d77c76565981@redhat.com>
Date: Mon, 11 Jun 2018 13:53:49 +0200
MIME-Version: 1.0
In-Reply-To: <819e45c5-6ae3-1dff-3f1d-c0411b6e2e1d@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On 24.05.2018 23:07, David Hildenbrand wrote:
> On 24.05.2018 16:22, Michal Hocko wrote:
>> I will go over the rest of the email later I just wanted to make this
>> point clear because I suspect we are talking past each other.
> 
> It sounds like we are now talking about how to solve the problem. I like
> that :)
> 

Hi Michal,

did you have time to think about the details of your proposed idea?
(especially the questions I had as response below to make it work at all?)

Personally, I still think that using Pg_reserved is wrong and that your
proposal will be significantly more complicated.

Thanks!

>>
>> On Thu 24-05-18 16:04:38, David Hildenbrand wrote:
>> [...]
>>> The point I was making is: I cannot allocate 8MB/128MB using the buddy
>>> allocator. All I want to do is manage the memory a virtio-mem device
>>> provides as flexible as possible.
>>
>> I didn't mean to use the page allocator to isolate pages from it. We do
>> have other means. Have a look at the page isolation framework and have a
>> look how the current memory hotplug (ab)uses it. In short you mark the
>> desired physical memory range as isolated (nobody can allocate from it)
>> and then simply remove it from the page allocator. And you are done with
>> it. Your particular range is gone, nobody will ever use it. If you mark
>> those struct pages reserved then pfn walkers should already ignore them.
>> If you keep those pages with ref count 0 then even hotplug should work
>> seemlessly (I would have to double check).
>>
>> So all I am arguing is that whatever your driver wants to do can be
>> handled without touching the hotplug code much. You would still need
>> to add new ranges in the mem section units and manage on top of that.
>> You need to do that anyway to keep track of what parts are in use or
>> offlined anyway right? Now the mem sections. You have to do that anyway
>> for memmaps. Our sparse memory model simply works in those units. Even
>> if you make a part of that range unavailable then the section will still
>> be there.
>>
>> Do I make at least some sense or I am completely missing your point?
>>
> 
> I think we're heading somewhere. I understand that you want to separate
> this "semi" offline part from the general offlining code. If so, we
> should definitely enforce segment alignment for online_pages/offline_pages.
> 
> Importantly, what I need is:
> 
> 1. Indicate and prepare memory sections to be used for adding memory
>    chunks (right now add_memory())
> 2. Make memory chunks of a section available to the system (right now
>    online_pages())
> 3. Remove memory chunks of a section from the system (right now
>    offline_pages())
> 4. Remove memory sections from the system (right now remove_memory())
> 5. Hinder dumping tools from reading memory chunks that are logically
>    offline (right now PageOffline())
> 6. For 3. find removable memory chunks in a certain memory range with a
>    variable size.
> 
> In an ideal world, 2. would never fail (in contrast to online_pages()
> right now). This might make some further developments I have in mind
> easier :) So if we can come up with an approach that can guarantee that,
> extra points.
> 
> So what I think you are talking about is the following.
> 
> For 1. Use add_memory() followed by online_pages(). Don't actually
>        online the pages, keep them reserved (like XEN balloon). Fixup
>        stats.
> For 2. Expose reserved pages to Buddy allocator. Clear reserved bit.
>        Fixup stats. This can never fail. (yay)
> For 3. Isolate pages, try to move everything away (basically but not
>        comletely offlining code). Set reserved flag. Fixup flags.
> For 4. offline_pages() followed by remove_memory().
>        -> Q: How to distinguish reserved offline from other reserved
>              pages? offline_pages() has to be able to deal with that
> For 5. I don't think we can use reserved flag here.
>        -> Q: What else to use?
> For 6. Scan for movable ranges. The use
> 
> 
> "You need to do that anyway to keep track of what parts are in use or
>  offlined anyway right?"
> 
> I would manually track which chunks of a section is logically offline (I
> do that right now already).
> 
> Is that what you had in mind? If not, where does your idea differ.
> How could we solve 4/5. Of course, PageOffline() is again an option.
> 
> Thanks!
> 


-- 

Thanks,

David / dhildenb
