Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD556B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 10:42:12 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id w39so265499912qtw.0
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 07:42:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z47si14741391qtb.204.2016.12.07.07.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 07:42:11 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: Re: [PATCH kernel v5 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
Message-ID: <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
Date: Wed, 7 Dec 2016 16:42:05 +0100
MIME-Version: 1.0
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

Am 07.12.2016 um 14:35 schrieb Li, Liang Z:
>> Am 30.11.2016 um 09:43 schrieb Liang Li:
>>> This patch set contains two parts of changes to the virtio-balloon.
>>>
>>> One is the change for speeding up the inflating & deflating process,
>>> the main idea of this optimization is to use bitmap to send the page
>>> information to host instead of the PFNs, to reduce the overhead of
>>> virtio data transmission, address translation and madvise(). This can
>>> help to improve the performance by about 85%.
>>
>> Do you have some statistics/some rough feeling how many consecutive bits are
>> usually set in the bitmaps? Is it really just purely random or is there some
>> granularity that is usually consecutive?
>>
>
> I did something similar. Filled the balloon with 15GB for a 16GB idle guest, by
> using bitmap, the madvise count was reduced to 605. when using the PFNs, the madvise count
> was 3932160. It means there are quite a lot consecutive bits in the bitmap.
> I didn't test for a guest with heavy memory workload.

Would it then even make sense to go one step further and report {pfn, 
length} combinations?

So simply send over an array of {pfn, length}?

This idea came up when talking to Andrea Arcangeli (put him on cc).

And it makes sense if you think about:

a) hugetlb backing: The host may only be able to free huge pages (we 
might want to communicate that to the guest later, that's another 
story). Still we would have to send bitmaps full of 4k frames (512 bits 
for 2mb frames). Of course, we could add a way to communicate that we 
are using a different bitmap-granularity.

b) if we really inflate huge memory regions (and it sounds like that 
according to your measurements), we can minimize the communication to 
the hypervisor and therefore the madvice calls.

c) we don't want to optimize for inflating guests with almost full 
memory (and therefore little consecutive memory areas) - my opinion :)


Thanks for the explanation!

-- 

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
