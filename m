Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8826B0008
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 21:24:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w11-v6so9033702pfk.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:24:42 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id q13-v6si14767834pgq.526.2018.07.10.18.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 18:24:41 -0700 (PDT)
Message-ID: <5B455D50.90902@intel.com>
Date: Wed, 11 Jul 2018 09:28:48 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v35 1/5] mm: support to get hints of free page blocks
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com> <1531215067-35472-2-git-send-email-wei.w.wang@intel.com> <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
In-Reply-To: <CA+55aFz9a=D-kquM=sG5uhV_HrBAw+VAhcJmtPNz+howy4j9ow@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, Rik van Riel <riel@redhat.com>, peterx@redhat.com

On 07/11/2018 01:33 AM, Linus Torvalds wrote:
> NAK.
>
> On Tue, Jul 10, 2018 at 2:56 AM Wei Wang <wei.w.wang@intel.com> wrote:
>> +
>> +       buf_page = list_first_entry_or_null(pages, struct page, lru);
>> +       if (!buf_page)
>> +               return -EINVAL;
>> +       buf = (__le64 *)page_address(buf_page);
> Stop this garbage.
>
> Why the hell would you pass in some crazy "liost of pages" that uses
> that lru list?
>
> That's just insane shit.
>
> Just pass in a an array to fill in. No idiotic games like this with
> odd list entries (what's the locking?) and crazy casting to
>
> So if you want an array of page addresses, pass that in as such. If
> you want to do it in a page, do it with
>
>      u64 *array = page_address(page);
>      int nr = PAGE_SIZE / sizeof(u64);
>
> and now you pass that array in to the thing. None of this completely
> insane crazy crap interfaces.
>
> Plus, I still haven't heard an explanation for why you want so many
> pages in the first place, and why you want anything but MAX_ORDER-1.

Sorry for missing that explanation.
We only get addresses of the "MAX_ORDER-1" blocks into the array. The 
max size of the array that could be allocated by kmalloc is 
KMALLOC_MAX_SIZE (i.e. 4MB on x86). With that max array, we could load 
"4MB / sizeof(u64)" addresses of "MAX_ORDER-1" blocks, that is, 2TB free 
memory at most. We thought about removing that 2TB limitation by passing 
in multiple such max arrays (a list of them).

But 2TB has been enough for our use cases so far, and agree it would be 
better to have a simpler API in the first place. So I plan to go back to 
the previous version of just passing in one simple array 
(https://lkml.org/lkml/2018/6/15/21) if no objections.

Best,
Wei
