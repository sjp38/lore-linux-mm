Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4783D6B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 15:07:05 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y71so184228156pgd.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 12:07:05 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 201si30186702pfc.120.2016.12.08.12.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 12:07:04 -0800 (PST)
Subject: Re: [HMM v14 05/16] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory
References: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
 <1481215184-18551-6-git-send-email-jglisse@redhat.com>
 <be2861b4-d830-fbd7-e9eb-ebc8e4d913a2@intel.com>
 <152004793.3187283.1481215199204.JavaMail.zimbra@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7df66ace-ef29-c76b-d61c-88263a61c6d0@intel.com>
Date: Thu, 8 Dec 2016 12:07:01 -0800
MIME-Version: 1.0
In-Reply-To: <152004793.3187283.1481215199204.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 12/08/2016 08:39 AM, Jerome Glisse wrote:
>> On 12/08/2016 08:39 AM, JA(C)rA'me Glisse wrote:
>>> > > Architecture that wish to support un-addressable device memory should make
>>> > > sure to never populate the kernel linar mapping for the physical range.
>> > 
>> > Does the platform somehow provide a range of physical addresses for this
>> > unaddressable area?  How do we know no memory will be hot-added in a
>> > range we're using for unaddressable device memory, for instance?
> That's what one of the big issue. No platform does not reserve any range so
> there is a possibility that some memory get hotpluged and assign this range.
> 
> I pushed the range decision to higher level (ie it is the device driver that
> pick one) so right now for device driver using HMM (NVidia close driver as
> we don't have nouveau ready for that yet) it goes from the highest physical
> address and scan down until finding an empty range big enough.

I don't think you should be stealing physical address space for things
that don't and can't have physical addresses.  Delegating this to
individual device drivers and hoping that they all get it right seems
like a recipe for disaster.

Maybe worth adding to the changelog:

	This feature potentially breaks memory hotplug unless every
	driver using it magically predicts the future addresses of
	where memory will be hotplugged.

BTW, how many more of these "big issues" does this set have?  I didn't
see any mention of this in the changelogs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
