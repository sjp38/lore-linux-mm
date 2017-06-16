Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF65883293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 14:04:17 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id z22so40556095qtz.10
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:04:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p51si2565751qtc.73.2017.06.16.11.04.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 11:04:16 -0700 (PDT)
Date: Fri, 16 Jun 2017 14:04:13 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v23
Message-ID: <20170616180412.GC2420@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
 <BN6PR12MB134879159CFDA7B7C4F78E2CE8C10@BN6PR12MB1348.namprd12.prod.outlook.com>
 <20170616144737.GA2420@redhat.com>
 <BN6PR12MB1348BFA811E8A5539EBD9056E8C10@BN6PR12MB1348.namprd12.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BN6PR12MB1348BFA811E8A5539EBD9056E8C10@BN6PR12MB1348.namprd12.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Bridgman, John" <John.Bridgman@amd.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, "Sander, Ben" <ben.sander@amd.com>, "Kuehling, Felix" <Felix.Kuehling@amd.com>

On Fri, Jun 16, 2017 at 05:55:52PM +0000, Bridgman, John wrote:
> >-----Original Message-----
> >From: Jerome Glisse [mailto:jglisse@redhat.com]
> >Sent: Friday, June 16, 2017 10:48 AM
> >To: Bridgman, John
> >Cc: akpm@linux-foundation.org; linux-kernel@vger.kernel.org; linux-
> >mm@kvack.org; Dan Williams; Kirill A . Shutemov; John Hubbard; Sander, Ben;
> >Kuehling, Felix
> >Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v23
> >
> >On Fri, Jun 16, 2017 at 07:22:05AM +0000, Bridgman, John wrote:
> >> Hi Jerome,
> >>
> >> I'm just getting back to this; sorry for the late responses.
> >>
> >> Your description of HMM talks about blocking CPU accesses when a page
> >> has been migrated to device memory, and you treat that as a "given" in
> >> the HMM design. Other than BAR limits, coherency between CPU and
> >> device caches and performance on read-intensive CPU accesses to device
> >> memory are there any other reasons for this ?
> >
> >Correct this is the list of reasons for it. Note that HMM is more of a toolboox
> >that one monolithic thing. For instance you also have the HMM-CDM patchset
> >that does allow to have GPU memory map to the CPU but this rely on CAPI or
> >CCIX to keep same memory model garanty.
> >
> >
> >> The reason I'm asking is that we make fairly heavy use of large BAR
> >> support which allows the CPU to directly access all of the device
> >> memory on each of the GPUs, albeit without cache coherency, and there
> >> are some cases where it appears that allowing CPU access to the page
> >> in device memory would be more efficient than constantly migrating
> >> back and forth.
> >
> >The thing is we are designing toward random program and we can not make
> >any assumption on what kind of instruction a program might run on such
> >memory. So if program try to do atomic on it iirc it is un- define what is
> >suppose to happen.
> 
> Thanks... thought I was missing something from the list. Agree that we
> need to provide consistent behaviour, and we definitely care about atomics.
> If we could get consistent behaviour with the page still in device memory
> are you aware of any other problems related to HMM itself ?

Well only way to get consistent is with CCIX or CAPI bus, i would need to
do an in depth reading of PCIE but from my memory this isn't doable with
any of the existing PCIE standard.

Note that i have HMM-CDM especially for the case you have cache coherent
device memory that behave just like regular memory. When you use HMM-CDM
and you migrate to GPU memory the page is still map into the CPU address
space. HMM-CDM is a separate patchset that i posted couple days ago.

So if you have cache coherent device memory that behave like regular memory
what you want is HMM-CDM and when migrated thing are still map into the
CPU page table.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
