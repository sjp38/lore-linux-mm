Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0016B000A
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 08:09:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a12-v6so10151249pfn.12
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 05:09:43 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id ay5-v6si16658195plb.459.2018.06.19.05.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 05:09:42 -0700 (PDT)
Message-ID: <5B28F371.9020308@intel.com>
Date: Tue, 19 Jun 2018 20:13:37 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v33 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com> <1529037793-35521-3-git-send-email-wei.w.wang@intel.com> <20180615144000-mutt-send-email-mst@kernel.org> <286AC319A985734F985F78AFA26841F7396A3D04@shsmsx102.ccr.corp.intel.com> <20180615171635-mutt-send-email-mst@kernel.org> <286AC319A985734F985F78AFA26841F7396A5CB0@shsmsx102.ccr.corp.intel.com> <20180618051637-mutt-send-email-mst@kernel.org> <286AC319A985734F985F78AFA26841F7396AA10C@shsmsx102.ccr.corp.intel.com> <20180619055449-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180619055449-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On 06/19/2018 11:05 AM, Michael S. Tsirkin wrote:
> On Tue, Jun 19, 2018 at 01:06:48AM +0000, Wang, Wei W wrote:
>> On Monday, June 18, 2018 10:29 AM, Michael S. Tsirkin wrote:
>>> On Sat, Jun 16, 2018 at 01:09:44AM +0000, Wang, Wei W wrote:
>>>> Not necessarily, I think. We have min(4m_page_blocks / 512, 1024) above,
>>> so the maximum memory that can be reported is 2TB. For larger guests, e.g.
>>> 4TB, the optimization can still offer 2TB free memory (better than no
>>> optimization).
>>>
>>> Maybe it's better, maybe it isn't. It certainly muddies the waters even more.
>>> I'd rather we had a better plan. From that POV I like what Matthew Wilcox
>>> suggested for this which is to steal the necessary # of entries off the list.
>> Actually what Matthew suggested doesn't make a difference here. That method always steal the first free page blocks, and sure can be changed to take more. But all these can be achieved via kmalloc
> I'd do get_user_pages really. You don't want pages split, etc.

>> by the caller which is more prudent and makes the code more straightforward. I think we don't need to take that risk unless the MM folks strongly endorse that approach.
>>
>> The max size of the kmalloc-ed memory is 4MB, which gives us the limitation that the max free memory to report is 2TB. Back to the motivation of this work, the cloud guys want to use this optimization to accelerate their guest live migration. 2TB guests are not common in today's clouds. When huge guests become common in the future, we can easily tweak this API to fill hints into scattered buffer (e.g. several 4MB arrays passed to this API) instead of one as in this version.
>>
>> This limitation doesn't cause any issue from functionality perspective. For the extreme case like a 100TB guest live migration which is theoretically possible today, this optimization helps skip 2TB of its free memory. This result is that it may reduce only 2% live migration time, but still better than not skipping the 2TB (if not using the feature).
> Not clearly better, no, since you are slowing the guest.

Not really. Live migration slows down the guest itself. It seems that 
the guest spends a little extra time reporting free pages, but in return 
the live migration time gets reduced a lot, which makes the guest endure 
less from live migration. (there is no drop of the workload performance 
when using the optimization in the tests)



>
>
>> So, for the first release of this feature, I think it is better to have the simpler and more straightforward solution as we have now, and clearly document why it can report up to 2TB free memory.
> No one has the time to read documentation about how an internal flag
> within a device works. Come on, getting two pages isn't much harder
> than a single one.

>>   
>>> If that doesn't fly, we can allocate out of the loop and just retry with more
>>> pages.
>>>
>>>> On the other hand, large guests being large mostly because the guests need
>>> to use large memory. In that case, they usually won't have that much free
>>> memory to report.
>>>
>>> And following this logic small guests don't have a lot of memory to report at
>>> all.
>>> Could you remind me why are we considering this optimization then?
>> If there is a 3TB guest, it is 3TB not 2TB mostly because it would need to use e.g. 2.5TB memory from time to time. In the worst case, it only has 0.5TB free memory to report, but reporting 0.5TB with this optimization is better than no optimization. (and the current 2TB limitation isn't a limitation for the 3TB guest in this case)
> I'd rather not spend time writing up random limitations.

This is not a random limitation. It would be more clear to see the code. 
Also I'm not sure how get_user_pages could be used in our case, and what 
you meant by "getting two pages". I'll post out a new version, and we 
can discuss on the code.


Best,
Wei
