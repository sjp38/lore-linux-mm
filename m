Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 21E996B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 01:33:01 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id n21-v6so2688295plp.9
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 22:33:01 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id q2-v6si2991291plh.485.2018.08.02.22.32.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 22:32:59 -0700 (PDT)
Message-ID: <5B63E99D.9070003@intel.com>
Date: Fri, 03 Aug 2018 13:35:25 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] virtio_balloon: replace oom notifier with shrinker
References: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com> <1532683495-31974-3-git-send-email-wei.w.wang@intel.com> <20180730090041.GC24267@dhcp22.suse.cz> <5B619599.1000307@intel.com> <20180801113444.GK16767@dhcp22.suse.cz> <5B62DDCC.3030100@intel.com> <20180802114755.GI10808@dhcp22.suse.cz>
In-Reply-To: <20180802114755.GI10808@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org

On 08/02/2018 07:47 PM, Michal Hocko wrote:
> On Thu 02-08-18 18:32:44, Wei Wang wrote:
>> On 08/01/2018 07:34 PM, Michal Hocko wrote:
>>> On Wed 01-08-18 19:12:25, Wei Wang wrote:
>>>> On 07/30/2018 05:00 PM, Michal Hocko wrote:
>>>>> On Fri 27-07-18 17:24:55, Wei Wang wrote:
>>>>>> The OOM notifier is getting deprecated to use for the reasons mentioned
>>>>>> here by Michal Hocko: https://lkml.org/lkml/2018/7/12/314
>>>>>>
>>>>>> This patch replaces the virtio-balloon oom notifier with a shrinker
>>>>>> to release balloon pages on memory pressure.
>>>>> It would be great to document the replacement. This is not a small
>>>>> change...
>>>> OK. I plan to document the following to the commit log:
>>>>
>>>>     The OOM notifier is getting deprecated to use for the reasons:
>>>>       - As a callout from the oom context, it is too subtle and easy to
>>>>         generate bugs and corner cases which are hard to track;
>>>>       - It is called too late (after the reclaiming has been performed).
>>>>         Drivers with large amuont of reclaimable memory is expected to be
>>>>         released them at an early age of memory pressure;
>>>>       - The notifier callback isn't aware of the oom contrains;
>>>>       Link: https://lkml.org/lkml/2018/7/12/314
>>>>
>>>>       This patch replaces the virtio-balloon oom notifier with a shrinker
>>>>       to release balloon pages on memory pressure. Users can set the amount of
>>>>       memory pages to release each time a shrinker_scan is called via the
>>>>       module parameter balloon_pages_to_shrink, and the default amount is 256
>>>>       pages. Historically, the feature VIRTIO_BALLOON_F_DEFLATE_ON_OOM has
>>>>       been used to release balloon pages on OOM. We continue to use this
>>>>       feature bit for the shrinker, so the shrinker is only registered when
>>>>       this feature bit has been negotiated with host.
>>> Do you have any numbers for how does this work in practice?
>> It works in this way: for example, we can set the parameter,
>> balloon_pages_to_shrink, to shrink 1GB memory once shrink scan is called.
>> Now, we have a 8GB guest, and we balloon out 7GB. When shrink scan is
>> called, the balloon driver will get back 1GB memory and give them back to
>> mm, then the ballooned memory becomes 6GB.
>>
>> When the shrinker scan is called the second time, another 1GB will be given
>> back to mm. So the ballooned pages are given back to mm gradually.
>>
>>> Let's say
>>> you have a medium page cache workload which triggers kswapd to do a
>>> light reclaim? Hardcoded shrinking sounds quite dubious to me but I have
>>> no idea how people expect this to work. Shouldn't this be more
>>> adaptive? How precious are those pages anyway?
>> Those pages are given to host to use usually because the guest has enough
>> free memory, and host doesn't want to waste those pieces of memory as they
>> are not used by this guest. When the guest needs them, it is reasonable that
>> the guest has higher priority to take them back.
>> But I'm not sure if there would be a more adaptive approach than "gradually
>> giving back as the guest wants more".
> I am not sure I follow. Let me be more specific. Say you have a trivial
> stream IO triggering reclaim to recycle clean page cache. This will
> invoke slab shrinkers as well. Do you really want to drop your batch of
> pages on each invocation? Doesn't that remove them very quickly? Just
> try to dd if=large_file of=/dev/null and see how your pages are
> disappearing. Shrinkers usually scale the number of objects they are
> going to reclaim based on the memory pressure (aka targer to be
> reclaimed).

Thanks, I think it looks better to make it more adaptive. I'll send out 
a new version for review.

Best,
Wei
