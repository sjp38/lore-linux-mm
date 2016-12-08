Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16D0A6B026A
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:40:06 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id y205so349966540qkb.4
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:40:06 -0800 (PST)
Received: from mx5-phx2.redhat.com (mx5-phx2.redhat.com. [209.132.183.37])
        by mx.google.com with ESMTPS id s82si17699006qke.158.2016.12.08.08.40.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:40:05 -0800 (PST)
Date: Thu, 8 Dec 2016 11:39:59 -0500 (EST)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <152004793.3187283.1481215199204.JavaMail.zimbra@redhat.com>
In-Reply-To: <be2861b4-d830-fbd7-e9eb-ebc8e4d913a2@intel.com>
References: <1481215184-18551-1-git-send-email-jglisse@redhat.com> <1481215184-18551-6-git-send-email-jglisse@redhat.com> <be2861b4-d830-fbd7-e9eb-ebc8e4d913a2@intel.com>
Subject: Re: [HMM v14 05/16] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

> On 12/08/2016 08:39 AM, J=C3=A9r=C3=B4me Glisse wrote:
> > Architecture that wish to support un-addressable device memory should m=
ake
> > sure to never populate the kernel linar mapping for the physical range.
>=20
> Does the platform somehow provide a range of physical addresses for this
> unaddressable area?  How do we know no memory will be hot-added in a
> range we're using for unaddressable device memory, for instance?

That's what one of the big issue. No platform does not reserve any range so
there is a possibility that some memory get hotpluged and assign this range=
.

I pushed the range decision to higher level (ie it is the device driver tha=
t
pick one) so right now for device driver using HMM (NVidia close driver as
we don't have nouveau ready for that yet) it goes from the highest physical
address and scan down until finding an empty range big enough.

I don't think i can control or enforce at platform level how to choose
specific physical address for hotplug.

So right now with my patchset what happens is that the hotplug will fail
because i already registered a resource for the physical range. What i can
add is a way to migrate the device memory to a different physical range.
I am bit afraid on how complex this can be.

The ideal solution would be to increase the MAX_PHYSMEM_BITS by one and use
physical address that can never be valid. We would not need to increase the
the direct mapping size of memory (this memory is not mappable by CPU). But
i am afraid of complication this might cause.

I think for sparse memory model it should be easy enough and i already rely
on sparse for HMM.

In any case i think this is something that can be solve after. If it become=
s
a real issue. Maybe i should add a debug printk that when hotplug fails
because of an existing un-addressable ZONE_DEVICE resource.

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
