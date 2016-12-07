Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7835A6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 10:34:26 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so98753245pgd.0
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 07:34:26 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 63si24596278plf.32.2016.12.07.07.34.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 07:34:25 -0800 (PST)
Subject: Re: [PATCH kernel v5 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f7b47cc4-ee94-bacb-5a17-d049b402263e@intel.com>
Date: Wed, 7 Dec 2016 07:34:23 -0800
MIME-Version: 1.0
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>, David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>

On 12/07/2016 05:35 AM, Li, Liang Z wrote:
>> Am 30.11.2016 um 09:43 schrieb Liang Li:
>> IOW in real examples, do we have really large consecutive areas or are all
>> pages just completely distributed over our memory?
> 
> The buddy system of Linux kernel memory management shows there should
> be quite a lot of consecutive pages as long as there are a portion of
> free memory in the guest.
...
> If all pages just completely distributed over our memory, it means
> the memory fragmentation is very serious, the kernel has the
> mechanism to avoid this happened.

While it is correct that the kernel has anti-fragmentation mechanisms, I
don't think it invalidates the question as to whether a bitmap would be
too sparse to be effective.

> In the other hand, the inflating should not happen at this time because the guest is almost
> 'out of memory'.

I don't think this is correct.  Most systems try to run with relatively
little free memory all the time, using the bulk of it as page cache.  We
have no reason to expect that ballooning will only occur when there is
lots of actual free memory and that it will not occur when that same
memory is in use as page cache.

In these patches, you're effectively still sending pfns.  You're just
sending one pfn per high-order page which is giving a really nice
speedup.  IMNHO, you're avoiding doing a real bitmap because creating a
bitmap means either have a really big bitmap, or you would have to do
some sorting (or multiple passes) of the free lists before populating a
smaller bitmap.

Like David, I would still like to see some data on whether the choice
between bitmaps and pfn lists is ever clearly in favor of bitmaps.  You
haven't convinced me, at least, that the data isn't even worth collecting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
