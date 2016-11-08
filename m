Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBEA6B0069
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 13:30:32 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y68so75778468pfb.6
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 10:30:32 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z26si38052298pfk.57.2016.11.08.10.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 10:30:30 -0800 (PST)
Subject: Re: [PATCH kernel v4 7/7] virtio-balloon: tell host vm's unused page
 info
References: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
 <1478067447-24654-8-git-send-email-liang.z.li@intel.com>
 <b25eac6e-3744-3874-93a8-02f814549adf@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A106DAA@shsmsx102.ccr.corp.intel.com>
 <281acd8d-fd94-6318-35e5-9eb130303dc6@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A108196@shsmsx102.ccr.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2dcef4a7-4909-a994-a7d0-bc54a268e991@intel.com>
Date: Tue, 8 Nov 2016 10:30:30 -0800
MIME-Version: 1.0
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3A108196@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "pbonzini@redhat.com" <pbonzini@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>

On 11/07/2016 09:50 PM, Li, Liang Z wrote:
> Sounds good.  Should we ignore some of the order-0 pages in step 4 if the bitmap is full?
> Or should retry to get a complete list of order-0 pages?

I think that's a pretty reasonable thing to do.

>>> It seems the benefit we get for this feature is not as big as that in fast
>> balloon inflating/deflating.
>>>>
>>>> You should not be using get_max_pfn().  Any patch set that continues
>>>> to use it is not likely to be using a proper algorithm.
>>>
>>> Do you have any suggestion about how to avoid it?
>>
>> Yes: get the pfns from the page free lists alone.  Don't derive
>> them from the pfn limits of the system or zones.
> 
> The ' get_max_pfn()' can be avoid in this patch, but I think we can't
> avoid it completely. We need it as a hint for allocating a proper
> size bitmap. No?

If you start with higher-order pages, you'll be unlikely to get anywhere
close to filling up a bitmap that was sized to hold all possible order-0
pages on the system.  Any use of max_pfn also means that you'll
completely mis-size bitmaps on sparse systems with large holes.

I think you should size it based on the size of the free lists, if anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
