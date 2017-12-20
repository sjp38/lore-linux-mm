Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E19D6B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 05:32:31 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w22so14152895pge.10
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 02:32:31 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id bj7si12641142plb.557.2017.12.20.02.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 02:32:30 -0800 (PST)
Message-ID: <5A3A3CBC.4030202@intel.com>
Date: Wed, 20 Dec 2017 18:34:36 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v20 0/7] Virtio-balloon Enhancement
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com> <201712192305.AAE21882.MtQHJOFFSFVOLO@I-love.SAKURA.ne.jp>
In-Reply-To: <201712192305.AAE21882.MtQHJOFFSFVOLO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 12/19/2017 10:05 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
>> ChangeLog:
>> v19->v20:
>> 1) patch 1: xbitmap
>> 	- add __rcu to "void **slot";
>> 	- remove the exceptional path.
>> 2) patch 3: xbitmap
>> 	- DeveloperNotes: add an item to comment that the current bit range
>> 	  related APIs operating on extremely large ranges (e.g.
>>            [0, ULONG_MAX)) will take too long time. This can be optimized in
>> 	  the future.
>> 	- remove the exceptional path;
>> 	- remove xb_preload_and_set();
>> 	- reimplement xb_clear_bit_range to make its usage close to
>> 	  bitmap_clear;
>> 	- rename xb_find_next_set_bit to xb_find_set, and re-implement it
>> 	  in a style close to find_next_bit;
>> 	- rename xb_find_next_zero_bit to xb_find_clear, and re-implement
>> 	  it in a stytle close to find_next_zero_bit;
>> 	- separate the implementation of xb_find_set and xb_find_clear for
>> 	  the convenience of future updates.
> Removing exceptional path made this patch easier to read.
> But what I meant is
>
>    Can you eliminate exception path and fold all xbitmap patches into one, and
>    post only one xbitmap patch without virtio-balloon changes?
>
> .
>
> I still think we don't need xb_preload()/xb_preload_end().

Why would you think preload is not needed?

The bitmap is allocated via preload "bitmap = 
this_cpu_cmpxchg(ida_bitmap, NULL, bitmap);", this allocated bitmap 
would be used in xb_set_bit().


> I think xb_find_set() has a bug in !node path.

I think we can probably remove the "!node" path for now. It would be 
good to get the fundamental part in first, and leave optimization to 
come as separate patches with corresponding test cases in the future.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
