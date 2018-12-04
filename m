Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD6D6B7043
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 14:12:04 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id j3so13709467itf.5
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 11:12:04 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 29si10692782jan.108.2018.12.04.11.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 11:12:03 -0800 (PST)
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com> <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
Date: Tue, 4 Dec 2018 12:11:42 -0700
MIME-Version: 1.0
In-Reply-To: <20181204185725.GE2937@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com



On 2018-12-04 11:57 a.m., Jerome Glisse wrote:
>> That sounds needlessly restrictive. Let the kernel arbitrate what
>> memory an application gets, don't design a system where applications
>> are hard coded to a memory type. Applications can hint, or optionally
>> specify an override and the kernel can react accordingly.
> 
> You do not want to randomly use non cache coherent memory inside your
> application :) This is not gonna go well with C++ or atomic :) Yes they
> are legitimate use case where application can decide to give up cache
> coherency temporarily for a range of virtual address. But the application
> needs to understand what it is doing and opt in to do that knowing full
> well that. The version thing allows for scenario like. You do not have
> to define a new version with every new type of memory. If your new memory
> has all the properties of v1 than you expose it as v1 and old application
> on the new platform will use your new memory type being non the wiser.

I agree with Dan and the general idea that this version thing is really
ugly. Define some standard attributes so the application can say "I want
cache-coherent, high bandwidth memory". If there's some future
new-memory attribute, then the application needs to know about it to
request it.

Also, in the same vein, I think it's wrong to have the API enumerate all
the different memory available in the system. The API should simply
allow userspace to say it wants memory that can be accessed by a set of
initiators with a certain set of attributes and the bind call tries to
fulfill that or fallback on system memory/hmm migration/whatever.

Logan
