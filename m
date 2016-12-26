Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C16286B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 04:12:22 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a190so634083990pgc.0
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 01:12:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k9si42529103pli.242.2016.12.26.01.12.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 01:12:21 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBQ993eq110003
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 04:12:21 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 27jy6521y7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 04:12:20 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 26 Dec 2016 19:12:18 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 5DF9B2CE8057
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:12:16 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uBQ9CGEo23593070
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:12:16 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uBQ9CGUX015052
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:12:16 +1100
Subject: Re: [HMM v14 05/16] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory
References: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
 <1481215184-18551-6-git-send-email-jglisse@redhat.com>
 <be2861b4-d830-fbd7-e9eb-ebc8e4d913a2@intel.com>
 <152004793.3187283.1481215199204.JavaMail.zimbra@redhat.com>
 <7df66ace-ef29-c76b-d61c-88263a61c6d0@intel.com>
 <2093258630.3273244.1481229443563.JavaMail.zimbra@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 26 Dec 2016 14:42:07 +0530
MIME-Version: 1.0
In-Reply-To: <2093258630.3273244.1481229443563.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <5860DEE7.5040505@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 12/09/2016 02:07 AM, Jerome Glisse wrote:
>> On 12/08/2016 08:39 AM, Jerome Glisse wrote:
>>>> > >> On 12/08/2016 08:39 AM, JA(C)rA'me Glisse wrote:
>>>>>>> > >>> > > Architecture that wish to support un-addressable device memory should
>>>>>>> > >>> > > make
>>>>>>> > >>> > > sure to never populate the kernel linar mapping for the physical
>>>>>>> > >>> > > range.
>>>>> > >> > 
>>>>> > >> > Does the platform somehow provide a range of physical addresses for this
>>>>> > >> > unaddressable area?  How do we know no memory will be hot-added in a
>>>>> > >> > range we're using for unaddressable device memory, for instance?
>>> > > That's what one of the big issue. No platform does not reserve any range so
>>> > > there is a possibility that some memory get hotpluged and assign this
>>> > > range.
>>> > > 
>>> > > I pushed the range decision to higher level (ie it is the device driver
>>> > > that
>>> > > pick one) so right now for device driver using HMM (NVidia close driver as
>>> > > we don't have nouveau ready for that yet) it goes from the highest physical
>>> > > address and scan down until finding an empty range big enough.
>> > 
>> > I don't think you should be stealing physical address space for things
>> > that don't and can't have physical addresses.  Delegating this to
>> > individual device drivers and hoping that they all get it right seems
>> > like a recipe for disaster.
> Well i expected device driver to use hmm_devmem_add() which does not take
> physical address but use the above logic to pick one.
> 
>> > 
>> > Maybe worth adding to the changelog:
>> > 
>> > 	This feature potentially breaks memory hotplug unless every
>> > 	driver using it magically predicts the future addresses of
>> > 	where memory will be hotplugged.
> I will add debug printk to memory hotplug in case it fails because of some
> un-addressable resource. If you really dislike memory hotplug being broken
> then i can go down the way of allowing to hotplug memory above the max
> physical memory limit. This require more changes but i believe this is
> doable for some of the memory model (sparsemem and sparsemem extreme).

Did not get that. Hotplug memory request will come within the max physical
memory limit as they are real RAM. The address range also would have been
specified. How it can be added beyond the physical limit irrespective of
which we memory model we use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
