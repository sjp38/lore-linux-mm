Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94AC42802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 19:19:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m188so137155533pgm.2
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 16:19:27 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id s6si7436353plj.156.2017.06.30.16.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 16:19:26 -0700 (PDT)
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
From: Evgeny Baskakov <ebaskakov@nvidia.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
Message-ID: <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
Date: Fri, 30 Jun 2017 16:19:25 -0700
MIME-Version: 1.0
In-Reply-To: <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 6/26/17 5:07 PM, Evgeny Baskakov wrote:

 > Hi Jerome,
 >
 > The documentation shown above doesn't tell what the alloc_and_copy 
callback should do for source pages that have not been allocated yet. 
Instead, it unconditionally suggests checking if the MIGRATE_PFN_VALID 
and MIGRATE_PFN_MIGRATE flags are set.
 >
 > Based on my testing and looking in the source code, I see that for 
such pages the respective 'src' PFN entries are always set to 0 without 
any flags.
 >
 > The sample driver specifically handles that by checking if there's no 
page in the 'src' entry, and ignores any flags in such case:
 >
 >     struct page *spage = migrate_pfn_to_page(*src_pfns);
 >     ...
 >     if (spage && !(*src_pfns & MIGRATE_PFN_MIGRATE))
 >         continue;
 >
 >     if (spage && (*src_pfns & MIGRATE_PFN_DEVICE)) {
 >
 > I would like to suggest reflecting that in the documentation. Or, 
which would be more logical, migrate_vma could keep the zero in the PFN 
entries for not allocated pages, but set the MIGRATE_PFN_MIGRATE flag 
anyway.
 >
 > Thanks!
 >
 > Evgeny Baskakov
 > NVIDIA
 >

Hi Jerome,

It seems that the kernel can pass 0 in src_pfns for pages that it cannot 
migrate (i.e. the kernel knows that they cannot migrate prior to calling 
alloc_and_copy).

So, a zero in src_pfns can mean either "the page is not allocated yet" 
or "the page cannot migrate".

Can migrate_vma set the MIGRATE_PFN_MIGRATE flag for not allocated 
pages? On the driver side it is difficult to differentiate between the 
cases.

Thanks!

Evgeny Baskakov
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
