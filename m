Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB076B02F4
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 12:38:31 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c123so9640023ith.20
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 09:38:31 -0700 (PDT)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id o188si3438489ioo.21.2017.04.27.09.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 09:38:30 -0700 (PDT)
Received: by mail-io0-x230.google.com with SMTP id a103so27378027ioj.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 09:38:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d2b0159c-9227-3283-2a57-74e03d47a0cd@deltatee.com>
References: <20170423233125.nehmgtzldgi25niy@node.shutemov.name>
 <149325431313.40660.7404075559824162131.stgit@dwillia2-desk3.amr.corp.intel.com>
 <3e595ba6-2ea1-e25d-e254-6c7edcf23f88@deltatee.com> <CAPcyv4it4eGhLjws_j8+M1BeAzr_gHRZ4zE-nC+4QMpFp72Hyg@mail.gmail.com>
 <d2b0159c-9227-3283-2a57-74e03d47a0cd@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 27 Apr 2017 09:38:29 -0700
Message-ID: <CAPcyv4iFKb9VbwdjRwF4KLQ=2R6-=vYb6BbHQG6Kk-8QemC6WA@mail.gmail.com>
Subject: Re: [PATCH] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Thu, Apr 27, 2017 at 9:33 AM, Logan Gunthorpe <logang@deltatee.com> wrote:
>
>
> On 27/04/17 10:14 AM, Dan Williams wrote:
>> You're overlooking that the page reference count 1 after
>> arch_add_memory(). So at the end of time we're just dropping the
>> arch_add_memory() reference to release the page and related
>> dev_pagemap.
>
> Thanks, that does actually make a lot more sense to me now. However,
> there still appears to be an asymmetry in that the pgmap->ref is
> incremented once and decremented once per page...
>

No, this hunk...

@@ -379,6 +374,7 @@ void *devm_memremap_pages(struct device *dev,
struct resource *res,
                 */
                list_del(&page->lru);
                page->pgmap = pgmap;
+               percpu_ref_get(ref);
        }


...is inside a for_each_device_pfn() loop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
