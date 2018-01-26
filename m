Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91CD86B000A
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 08:35:30 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 14so2079838itm.6
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 05:35:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i82si825941ioo.25.2018.01.26.05.35.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Jan 2018 05:35:29 -0800 (PST)
Subject: Re: [virtio-dev] Re: [PATCH v25 2/2] virtio-balloon:
 VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1516871646-22741-1-git-send-email-wei.w.wang@intel.com>
 <1516871646-22741-3-git-send-email-wei.w.wang@intel.com>
 <20180125154708-mutt-send-email-mst@kernel.org> <5A6A871C.6040408@intel.com>
 <20180126042649-mutt-send-email-mst@kernel.org> <5A6AA107.3000607@intel.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <3c2c00e7-07c3-d291-4446-f77a9a9e421b@I-love.SAKURA.ne.jp>
Date: Fri, 26 Jan 2018 22:35:04 +0900
MIME-Version: 1.0
In-Reply-To: <5A6AA107.3000607@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 2018/01/26 12:31, Wei Wang wrote:
> On 01/26/2018 10:42 AM, Michael S. Tsirkin wrote:
>> On Fri, Jan 26, 2018 at 09:40:44AM +0800, Wei Wang wrote:
>>> On 01/25/2018 09:49 PM, Michael S. Tsirkin wrote:
>>>> On Thu, Jan 25, 2018 at 05:14:06PM +0800, Wei Wang wrote:
>>>>
> 
>>> The controversy is that the free list is not static
>>> once the lock is dropped, so everything is dynamically changing, including
>>> the state that was recorded. The method we are using is more prudent, IMHO.
>>> How about taking the fundamental solution, and seek to improve incrementally
>>> in the future?
>>>
>>>
>>> Best,
>>> Wei
>> I'd like to see kicks happen outside the spinlock. kick with a spinlock
>> taken looks like a scalability issue that won't be easy to
>> reproduce but hurt workloads at random unexpected times.
>>
> 
> Is that "kick inside the spinlock" the only concern you have? I think we can remove the kick actually. If we check how the host side works, it is worthwhile to let the host poll the virtqueue after it receives the cmd id from the guest (kick for cmd id isn't within the lock).

We should start from the worst case.

+ * The callback itself must not sleep or perform any operations which would
+ * require any memory allocations directly (not even GFP_NOWAIT/GFP_ATOMIC)
+ * or via any lock dependency. It is generally advisable to implement
+ * the callback as simple as possible and defer any heavy lifting to a
+ * different context.

Making decision based on performance numbers of idle guests is dangerous.
There might be busy CPUs waiting for zone->lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
