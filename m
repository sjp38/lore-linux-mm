Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7696B027D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:40:53 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id y124so93982146iof.4
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:40:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p201si6331357ioe.103.2016.12.16.07.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 07:40:52 -0800 (PST)
Date: Fri, 16 Dec 2016 16:40:49 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
 fast (de)inflating & fast live migration
Message-ID: <20161216154049.GB6168@redhat.com>
References: <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
 <20161207183817.GE28786@redhat.com>
 <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
 <20161207202824.GH28786@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A14E2AD@SHSMSX104.ccr.corp.intel.com>
 <060287c7-d1af-45d5-70ea-ad35d4bbeb84@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3C31D0E6@SHSMSX104.ccr.corp.intel.com>
 <01886693-c73e-3696-860b-086417d695e1@intel.com>
 <20161215173901-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E3C32A899@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3C32A899@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Fri, Dec 16, 2016 at 01:12:21AM +0000, Li, Liang Z wrote:
> There still exist the case if the MAX_ORDER is configured to a large value, e.g. 36 for a system
> with huge amount of memory, then there is only 28 bits left for the pfn, which is not enough.

Not related to the balloon but how would it help to set MAX_ORDER to
36?

What the MAX_ORDER affects is that you won't be able to ask the kernel
page allocator for contiguous memory bigger than 1<<(MAX_ORDER-1), but
that's a driver issue not relevant to the amount of RAM. Drivers won't
suddenly start to ask the kernel allocator to allocate compound pages
at orders >= 11 just because more RAM was added.

The higher the MAX_ORDER the slower the kernel runs simply so the
smaller the MAX_ORDER the better.

> Should  we limit the MAX_ORDER? I don't think so.

We shouldn't strictly depend on MAX_ORDER value but it's mostly
limited already even if configurable at build time.

We definitely need it to reach at least the hugepage size, then it's
mostly driver issue, but drivers requiring large contiguous
allocations should rely on CMA only or vmalloc if they only require it
virtually contiguous, and not rely on larger MAX_ORDER that would
slowdown all kernel allocations/freeing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
