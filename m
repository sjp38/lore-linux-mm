Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0FB86B70BB
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 16:15:53 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a199so17759384qkb.23
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 13:15:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s11si729866qvc.143.2018.12.04.13.15.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 13:15:53 -0800 (PST)
Date: Tue, 4 Dec 2018 16:15:47 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181204211547.GN2937@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com>
 <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
 <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
 <20181204201432.GH18167@tassilo.jf.intel.com>
 <8ed92aba-a129-144f-34ab-f77102d54cfc@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8ed92aba-a129-144f-34ab-f77102d54cfc@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Tue, Dec 04, 2018 at 01:47:17PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-04 1:14 p.m., Andi Kleen wrote:
> >> Also, in the same vein, I think it's wrong to have the API enumerate all
> >> the different memory available in the system. The API should simply
> 
> > We need an enumeration API too, just to display to the user what they
> > have, and possibly for applications to size their buffers 
> > (all we do with existing NUMA nodes)
> 
> Yes, but I think my main concern is the conflation of the enumeration
> API and the binding API. An application doesn't want to walk through all
> the possible memory and types in the system just to get some memory that
> will work with a couple initiators (which it somehow has to map to
> actual resources, like fds). We also don't want userspace to police
> itself on which memory works with which initiator.

How application would police itself ? The API i am proposing is best
effort and as such kernel can fully ignore userspace request as it is
doing now sometimes with mbind(). So kernel always have the last call
and can always override application decission.

Device driver can also decide to override, anything that is kernel
side really have more power than userspace would have. So while we
give trust to userspace we do not abdicate control. That is not the
intention here.


> Enumeration is definitely not the common use case. And if we create a
> new enumeration API now, it may make it difficult or impossible to unify
> these types of memory with the existing NUMA node hierarchies if/when
> this gets more integrated with the mm core.

The point i am trying to make is that it can not get integrated as
regular NUMA node inside the mm core. But rather the mm core can
grow to encompass non NUMA node memory. I explained why in other
part of this thread but roughly:

- Device driver need to be in control of device memory allocation
  for backward compatibility reasons and to keep full filling thing
  like graphic API constraint (OpenGL, Vulkan, X, ...).

- Adding new node type is problematic inside mm as we are running
  out of bits in the struct page

- Excluding node from the regular allocation path was reject by
  upstream previously (IBM did post patchset for that IIRC).

I feel it is a safer path to avoid a one model fits all here and
to accept that device memory will be represented and managed in
a different way from other memory. I believe persistent memory
folks feels the same on that front.

Nonetheless i do want to expose this device memory in a standard
way so that we can consolidate and improve user experience on
that front. Eventually i hope that more of the device memory
management can be turn into a common device memory management
inside core mm but i do not want to enforce that at first as it
is likely to fail (building a moonbase before you have a moon
rocket). I rather grow organicaly from high level API that will
get use right away (it is a matter of converting existing user
to it s/computeAPIBind/HMSBind).

Cheers,
J�r�me
