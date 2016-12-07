Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 299426B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 10:45:26 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y71so99373769pgd.0
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 07:45:26 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t90si24631033pfi.85.2016.12.07.07.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 07:45:25 -0800 (PST)
Subject: Re: [PATCH kernel v5 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
 <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
Date: Wed, 7 Dec 2016 07:45:21 -0800
MIME-Version: 1.0
In-Reply-To: <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "Li, Liang Z" <liang.z.li@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On 12/07/2016 07:42 AM, David Hildenbrand wrote:
> Am 07.12.2016 um 14:35 schrieb Li, Liang Z:
>>> Am 30.11.2016 um 09:43 schrieb Liang Li:
>>>> This patch set contains two parts of changes to the virtio-balloon.
>>>>
>>>> One is the change for speeding up the inflating & deflating process,
>>>> the main idea of this optimization is to use bitmap to send the page
>>>> information to host instead of the PFNs, to reduce the overhead of
>>>> virtio data transmission, address translation and madvise(). This can
>>>> help to improve the performance by about 85%.
>>>
>>> Do you have some statistics/some rough feeling how many consecutive
>>> bits are
>>> usually set in the bitmaps? Is it really just purely random or is
>>> there some
>>> granularity that is usually consecutive?
>>>
>>
>> I did something similar. Filled the balloon with 15GB for a 16GB idle
>> guest, by
>> using bitmap, the madvise count was reduced to 605. when using the
>> PFNs, the madvise count
>> was 3932160. It means there are quite a lot consecutive bits in the
>> bitmap.
>> I didn't test for a guest with heavy memory workload.
> 
> Would it then even make sense to go one step further and report {pfn,
> length} combinations?
> 
> So simply send over an array of {pfn, length}?

Li's current patches do that.  Well, maybe not pfn/length, but they do
take a pfn and page-order, which fits perfectly with the kernel's
concept of high-order pages.

> And it makes sense if you think about:
> 
> a) hugetlb backing: The host may only be able to free huge pages (we
> might want to communicate that to the guest later, that's another
> story). Still we would have to send bitmaps full of 4k frames (512 bits
> for 2mb frames). Of course, we could add a way to communicate that we
> are using a different bitmap-granularity.

Yeah, please read the patches.  If they're not clear, then the
descriptions need work, but this is done already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
