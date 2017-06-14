Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFF766B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 17:38:07 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w1so8236699qtg.6
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 14:38:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s8si1082533qts.144.2017.06.14.14.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 14:38:06 -0700 (PDT)
Date: Wed, 14 Jun 2017 17:38:01 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-CDM 0/5] Cache coherent device memory (CDM) with HMM
Message-ID: <20170614213800.GD4160@redhat.com>
References: <20170614201144.9306-1-jglisse@redhat.com>
 <8219f8fb-65bb-7c6b-6c4c-acc0601c1e0f@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8219f8fb-65bb-7c6b-6c4c-acc0601c1e0f@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, cgroups@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Wed, Jun 14, 2017 at 02:20:23PM -0700, Dave Hansen wrote:
> On 06/14/2017 01:11 PM, Jerome Glisse wrote:
> > Cache coherent device memory apply to architecture with system bus
> > like CAPI or CCIX. Device connected to such system bus can expose
> > their memory to the system and allow cache coherent access to it
> > from the CPU.
> 
> How does this interact with device memory that's enumerated in the new
> ACPI 6.2 HMAT?  That stuff is also in the normal e820 and, by default,
> treated as normal system RAM.  Would this mechanism be used for those
> devices as well?
> 
> http://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf

It doesn't interact with that. HMM-CDM is a set of helper that don't
do anything unless instructed so. So for device memory to be presented
as HMM-CDM you need to hotplug it as ZONE_DEVICE(DEVICE_PUBLIC) which
can be done with the helper introduced in patch 2 of this patchset.

I don't think that the HMAT inside ACPI is restricted or even intended
for device memory. The kind of memory i am refering too in HMM-CDM is
for instance GPU on board memory. On PCIE system the CPU can not access
such memory in the same manner as regular memory but on CAPI or CCIX
system it can.

How such memory is listed is platform/architecture specific and HMM-CDM
does not deal with that. So PowerPC CAPI will have its own way of
discovering such device memory. So will CCIX platform (thought for CCIX
i expect that UEFI/ACPI will be involve through HMAT or something new).

Also if HMAT allow represent device memory, the choice to use HMM-CDM
would still be with the device driver. For persistent memory is does not
make sense and it might not make sense for other devices too. I expect
this to be usefull for GPU, FPGA or similar accelerator (like Xeon Phi
as add on card if there is ever something like CCIX supported by Intel).

Hope this answer your question

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
