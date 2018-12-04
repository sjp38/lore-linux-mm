Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id F21B96B707C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:13:53 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n68so17627277qkn.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:13:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y52si3577727qty.161.2018.12.04.12.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 12:13:53 -0800 (PST)
Date: Tue, 4 Dec 2018 15:13:47 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181204201347.GK2937@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com>
 <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
 <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
 <20181204192221.GG2937@redhat.com>
 <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Tue, Dec 04, 2018 at 12:41:39PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-04 12:22 p.m., Jerome Glisse wrote:
> > So version is a bad prefix, what about type, prefixing target with a
> > type id. So that application that are looking for a certain type of
> > memory (which has a set of define properties) can select them. Having
> > a type file inside the directory and hopping application will read
> > that sysfs file is a recipies for failure from my point of view. While
> > having it in the directory name is making sure that the application
> > has some idea of what it is doing.
> 
> Well I don't think it can be a prefix. It has to be a mask. It might be
> things like cache coherency, persistence, bandwidth and none of those
> things are mutually exclusive.

You are right many are non exclusive. It is just my feeling that having
a mask as a file inside the target directory might be overlook by the
application which might start using things it should not. At same time
i guess if i write the userspace library that abstract this kernel API
then i can enforce application to properly select thing.

I will use mask in v2.

> 
> >> Also, in the same vein, I think it's wrong to have the API enumerate all
> >> the different memory available in the system. The API should simply
> >> allow userspace to say it wants memory that can be accessed by a set of
> >> initiators with a certain set of attributes and the bind call tries to
> >> fulfill that or fallback on system memory/hmm migration/whatever.
> > 
> > We have existing application that use topology today to partition their
> > workload and do load balancing. Those application leverage the fact that
> > they are only running on a small set of known platform with known topology
> > here i want to provide a common API so that topology can be queried in a
> > standard by application.
> 
> Existing applications are not a valid excuse for poor API design.
> Remember, once this API is introduced and has real users, it has to be
> maintained *forever*, so we need to get it right. Providing users with
> more information than they need makes it exponentially harder to get
> right and support.

I am not disagreeing on the pain of maintaining API forever but the fact
remain that they are existing user and without a standard way of exposing
this it is impossible to say if we will see more users for that information
or if it will just be the existing user that will leverage this.

I do not think there is a way to answer that question. I am siding on the
side of this API can be dumb down in userspace by a common library. So let
expose the topology and let userspace dumb it down.

If we dumb it down in the kernel i see few pitfalls:
    - kernel dumbing it down badly
    - kernel dumbing down code can grow out of control with gotcha
      for platform
    - it is still harder to fix kernel than userspace in commercial
      user space (the whole RHEL business of slow moving and long
      supported kernel). So on those being able to fix thing in
      userspace sounds pretty enticing

Cheers,
J�r�me
