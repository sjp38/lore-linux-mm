Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 804EF6B0266
	for <linux-mm@kvack.org>; Sat,  5 Nov 2016 14:02:15 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d67so31344317qkc.0
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 11:02:15 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id a134si11330749qkb.306.2016.11.05.11.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Nov 2016 11:02:14 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id h201so7523752qke.3
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 11:02:14 -0700 (PDT)
Date: Sat, 5 Nov 2016 14:02:06 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
Message-ID: <20161105180206.GA3083@gmail.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com>
 <87a8dtawas.fsf@linux.vnet.ibm.com>
 <581D6C51.3070102@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <581D6C51.3070102@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

On Sat, Nov 05, 2016 at 10:51:21AM +0530, Anshuman Khandual wrote:
> On 10/25/2016 09:56 AM, Aneesh Kumar K.V wrote:
> > I looked at the hmm-v13 w.r.t migration and I guess some form of device
> > callback/acceleration during migration is something we should definitely
> > have. I still haven't figured out how non addressable and coherent device
> > memory can fit together there. I was waiting for the page cache
> > migration support to be pushed to the repository before I start looking
> > at this closely.
> 
> Aneesh, did not get that. Currently basic page cache migration is supported,
> right ? The device callback during migration, fault etc are supported through
> page->pgmap pointer and extending dev_pagemap structure to accommodate new
> members. IIUC that is the reason ZONE_DEVICE is being modified so that page
> ->pgmap overloading can be used for various driver/device specific callbacks
> while inside core VM functions or HMM functions.
> 
> HMM V13 has introduced non-addressable ZONE_DEVICE based device memory which
> can have it's struct pages in system RAM but they cannot be accessed from the
> CPU. Now coherent device memory is kind of similar to persistent memory like
> NVDIMM which is already supported through ZONE_DEVICE (though we might not
> want to use vmemap_altmap instead have the struct pages in the system RAM).
> Now HMM has to learn working with 'dev_pagemap->addressable' type of device
> memory and then support all possible migrations through it's API. So in a
> nutshell, these are the changes we need to do to make HMM work with coherent
> device memory.
> 
> (0) Support all possible migrations between system RAM and device memory
>     for current un-addressable device memory and make the HMM migration
>     API layer comprehensive and complete.

What is no comprehensive or complete in the API layer ? I think the API is
pretty clear the migrate function does not rely on anything except HMM pfn.


> 
> (1) Create coherent device memory representation in ZONE_DEVICE
> 	(a) Make it exactly the same as that of persistent memory/NVDIMM
> 
> 	or
> 
> 	(b) Create a new type for coherent device memory representation

So i will soon push an updated tree with modification to HMM API (from device
driver point of view but the migrate stuff is virtually the same). I slpitted
the addressable and movable concept and thus it is now easy to support coherent
addressable memory and non addressable memory.

> 
> (2) Support all possible migrations between system RAM and device memory
>     for new addressable coherent device memory represented in ZONE_DEVICE
>     extending the HMM migration API layer.
>
> Right now, HMM V13 patch series supports migration for a subset of private
> anonymous pages for un-addressable device memory. I am wondering how difficult
> is it to implement all possible anon, file mapping migration support for both
> un-addressable and addressable coherent device memory through ZONE_DEVICE.
>
 
There is no need to extend the API to support file back as matter of fact the
2 patches i sent you do support migration of file back page (page->mapping)
to and from ZONE_DEVICE as long as this ZONE_DEVICE memory is accessible by
the CPU and coherent. What i am still working on is the non addressable case
that is way more tedious (handle direct IO, read, write and writeback).

So difficulty for coherent memory is nill, it is the non addressable memory that
is hard to support in respect to file back page.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
