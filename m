Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B573A6B0722
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 04:12:45 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t187so11223697pfb.0
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 01:12:45 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s13si769508plj.719.2017.08.04.01.12.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 01:12:44 -0700 (PDT)
Message-ID: <59842D1C.5020608@intel.com>
Date: Fri, 04 Aug 2017 16:15:24 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v13 4/5] mm: support reporting free page blocks
References: <5982FE07.3040207@intel.com> <20170803104417.GI12521@dhcp22.suse.cz> <59830897.2060203@intel.com> <20170803112831.GN12521@dhcp22.suse.cz> <5983130E.2070806@intel.com> <20170803124106.GR12521@dhcp22.suse.cz> <59832265.1040805@intel.com> <20170803135047.GV12521@dhcp22.suse.cz> <286AC319A985734F985F78AFA26841F73928C971@shsmsx102.ccr.corp.intel.com> <20170804000043-mutt-send-email-mst@kernel.org> <20170804075337.GC26029@dhcp22.suse.cz>
In-Reply-To: <20170804075337.GC26029@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On 08/04/2017 03:53 PM, Michal Hocko wrote:
> On Fri 04-08-17 00:02:01, Michael S. Tsirkin wrote:
>> On Thu, Aug 03, 2017 at 03:20:09PM +0000, Wang, Wei W wrote:
>>> On Thursday, August 3, 2017 9:51 PM, Michal Hocko:
>>>> As I've said earlier. Start simple optimize incrementally with some numbers to
>>>> justify a more subtle code.
>>>> --
>>> OK. Let's start with the simple implementation as you suggested.
>>>
>>> Best,
>>> Wei
>> The tricky part is when you need to drop the lock and
>> then restart because the device is busy. Would it maybe
>> make sense to rotate the list so that new head
>> will consist of pages not yet sent to device?
> No, I this should be strictly non-modifying API.


Just get the context here for discussion:

     spin_lock_irqsave(&zone->lock, flags);
     ...
     visit(opaque2, pfn, 1<<order);
     spin_unlock_irqrestore(&zone->lock, flags);

The concern is that the callback may cause the lock be
taken too long.


I think here we can have two options:
- Option 1: Put a Note for the callback: the callback function
     should not block and it should finish as soon as possible.
     (when implementing an interrupt handler, we also have
     such similar rules in mind, right?).

For our use case, the callback just puts the reported page
block to the ring, then returns. If the ring is full as the host
is busy, then I think it should skip this one, and just return.
Because:
     A. This is an optimization feature, losing a couple of free
          pages to report isn't that important;
     B. In reality, I think it's uncommon to see this ring getting
         full (I didn't observe ring full in the tests), since the host
         (consumer) is notified to take out the page block right
         after it is added.

- Option 2: Put the callback function outside the lock
     What's input into the callback is just a pfn, and the callback
     won't access the corresponding pages. So, I still think it won't
     be an issue no matter what status of the pages is after they
     are reported (even they doesn't exit due to hot-remove).


What would you guys think?

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
