Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 409BF6B0253
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 11:22:00 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id y205so319060605qkb.4
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 08:22:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p11si14839523qkh.21.2016.12.07.08.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 08:21:59 -0800 (PST)
Subject: Re: [PATCH kernel v5 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
 <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
 <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
Date: Wed, 7 Dec 2016 17:21:53 +0100
MIME-Version: 1.0
In-Reply-To: <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "Li, Liang Z" <liang.z.li@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

>>>
>>> I did something similar. Filled the balloon with 15GB for a 16GB idle
>>> guest, by
>>> using bitmap, the madvise count was reduced to 605. when using the
>>> PFNs, the madvise count
>>> was 3932160. It means there are quite a lot consecutive bits in the
>>> bitmap.
>>> I didn't test for a guest with heavy memory workload.
>>
>> Would it then even make sense to go one step further and report {pfn,
>> length} combinations?
>>
>> So simply send over an array of {pfn, length}?
>
> Li's current patches do that.  Well, maybe not pfn/length, but they do
> take a pfn and page-order, which fits perfectly with the kernel's
> concept of high-order pages.

So we can send length in powers of two. Still, I don't see any benefit
over a simple pfn/len schema. But I'll have a more detailed look at the
implementation first, maybe that will enlighten me :)

>
>> And it makes sense if you think about:
>>
>> a) hugetlb backing: The host may only be able to free huge pages (we
>> might want to communicate that to the guest later, that's another
>> story). Still we would have to send bitmaps full of 4k frames (512 bits
>> for 2mb frames). Of course, we could add a way to communicate that we
>> are using a different bitmap-granularity.
>
> Yeah, please read the patches.  If they're not clear, then the
> descriptions need work, but this is done already.
>

I missed the page_shift, thanks for the hint.

-- 

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
