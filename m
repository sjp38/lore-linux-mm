Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 58A436B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 01:23:59 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m2-v6so590395plt.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 22:23:59 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f19-v6si1807984plj.437.2018.06.26.22.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 22:23:57 -0700 (PDT)
Message-ID: <5B33205B.2040702@intel.com>
Date: Wed, 27 Jun 2018 13:27:55 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v34 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com> <1529928312-30500-3-git-send-email-wei.w.wang@intel.com> <20180626002822-mutt-send-email-mst@kernel.org> <5B31B71B.6080709@intel.com> <20180626064338-mutt-send-email-mst@kernel.org> <5B323140.1000306@intel.com> <20180626163139-mutt-send-email-mst@kernel.org> <5B32E742.8080902@intel.com> <20180627053952-mutt-send-email-mst@kernel.org> <5B32FDB5.4040506@intel.com> <20180627065637-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180627065637-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On 06/27/2018 11:58 AM, Michael S. Tsirkin wrote:
> On Wed, Jun 27, 2018 at 11:00:05AM +0800, Wei Wang wrote:
>> On 06/27/2018 10:41 AM, Michael S. Tsirkin wrote:
>>> On Wed, Jun 27, 2018 at 09:24:18AM +0800, Wei Wang wrote:
>>>> On 06/26/2018 09:34 PM, Michael S. Tsirkin wrote:
>>>>> On Tue, Jun 26, 2018 at 08:27:44PM +0800, Wei Wang wrote:
>>>>>> On 06/26/2018 11:56 AM, Michael S. Tsirkin wrote:
>>>>>>> On Tue, Jun 26, 2018 at 11:46:35AM +0800, Wei Wang wrote:
>>>>>>>
>>>>>>>>>> +	if (!arrays)
>>>>>>>>>> +		return NULL;
>>>>>>>>>> +
>>>>>>>>>> +	for (i = 0; i < max_array_num; i++) {
>>>>>>>>> So we are getting a ton of memory here just to free it up a bit later.
>>>>>>>>> Why doesn't get_from_free_page_list get the pages from free list for us?
>>>>>>>>> We could also avoid the 1st allocation then - just build a list
>>>>>>>>> of these.
>>>>>>>> That wouldn't be a good choice for us. If we check how the regular
>>>>>>>> allocation works, there are many many things we need to consider when pages
>>>>>>>> are allocated to users.
>>>>>>>> For example, we need to take care of the nr_free
>>>>>>>> counter, we need to check the watermark and perform the related actions.
>>>>>>>> Also the folks working on arch_alloc_page to monitor page allocation
>>>>>>>> activities would get a surprise..if page allocation is allowed to work in
>>>>>>>> this way.
>>>>>>>>
>>>>>>> mm/ code is well positioned to handle all this correctly.
>>>>>> I'm afraid that would be a re-implementation of the alloc functions,
>>>>> A re-factoring - you can share code. The main difference is locking.
>>>>>
>>>>>> and
>>>>>> that would be much more complex than what we have. I think your idea of
>>>>>> passing a list of pages is better.
>>>>>>
>>>>>> Best,
>>>>>> Wei
>>>>> How much memory is this allocating anyway?
>>>>>
>>>> For every 2TB memory that the guest has, we allocate 4MB.
>>> Hmm I guess I'm missing something, I don't see it:
>>>
>>>
>>> +       max_entries = max_free_page_blocks(ARRAY_ALLOC_ORDER);
>>> +       entries_per_page = PAGE_SIZE / sizeof(__le64);
>>> +       entries_per_array = entries_per_page * (1 << ARRAY_ALLOC_ORDER);
>>> +       max_array_num = max_entries / entries_per_array +
>>> +                       !!(max_entries % entries_per_array);
>>>
>>> Looks like you always allocate the max number?
>> Yes. We allocated the max number and then free what's not used.
>> For example, a 16TB guest, we allocate Four 4MB buffers and pass the 4
>> buffers to get_from_free_page_list. If it uses 3, then the remaining 1 "4MB
>> buffer" will end up being freed.
>>
>> For today's guests, max_array_num is usually 1.
>>
>> Best,
>> Wei
> I see, it's based on total ram pages. It's reasonable but might
> get out of sync if memory is onlined quickly. So you want to
> detect that there's more free memory than can fit and
> retry the reporting.
>


- AFAIK, memory hotplug isn't expected to happen during live migration 
today. Hypervisors (e.g. QEMU) explicitly forbid this.

- Allocating buffers based on total ram pages already gives some 
headroom for newly plugged memory if that could happen in any case. 
Also, we can think about why people plug in more memory - usually 
because the existing memory isn't enough, which implies that the free 
page list is very likely to be close to empty.

- This method could be easily scaled if people really need more headroom 
for hot-plugged memory. For example, calculation based on "X * 
total_ram_pages", X could be a number passed from the hypervisor.

- This is an optimization feature, and reporting less free memory in 
that rare case doesn't hurt anything.

So I think it is good to start from a fundamental implementation, which 
doesn't confuse people, and complexities can be added when there is a 
real need in the future.

Best,
Wei
