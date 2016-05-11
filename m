Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41B3B6B0253
	for <linux-mm@kvack.org>; Wed, 11 May 2016 03:12:03 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b203so69347396pfb.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 00:12:03 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id j7si7902433paj.199.2016.05.11.00.12.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 00:12:02 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id gh9so2957008pac.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 00:12:02 -0700 (PDT)
Message-ID: <1462950715.20338.3.camel@gmail.com>
Subject: Re: [v2,2/2] powerpc/mm: Ensure "special" zones are empty
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 11 May 2016 17:11:55 +1000
In-Reply-To: <3r3fQw4Xbnz9t79@ozlabs.org>
References: <3r3fQw4Xbnz9t79@ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Oliver O'Halloran <oohall@gmail.com>, linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org

On Tue, 2016-05-10 at 09:55 +1000, Michael Ellerman wrote:
> On Thu, 2016-05-05 at 07:54:09 UTC, Oliver O'Halloran wrote:
> >A 
> > The mm zone mechanism was traditionally used by arch specific code to
> > partition memory into allocation zones. However there are several zones
> > that are managed by the mm subsystem rather than the architecture. Most
> > architectures set the max PFN of these special zones to zero, however on
> > powerpc we set them to ~0ul. This, in conjunction with a bug in
> > free_area_init_nodes() results in all of system memory being placed in
> > ZONE_DEVICE when enabled. Device memory cannot be used for regular kernel
> > memory allocations so this will cause a kernel panic at boot.
> This is breaking my freescale machine:
>A 
> A  Sorting __ex_table...
> A  Unable to handle kernel paging request for data at address 0xc000000101e28020
> A  Faulting instruction address: 0xc0000000009ab698
> A  cpu 0x0: Vector: 300 (Data Access) at [c000000000acbb30]
> A A A A A A pc: c0000000009ab698: .reserve_bootmem_region+0x64/0x8c
> A A A A A A lr: c0000000009883d0: .free_all_bootmem+0x70/0x200
> A A A A A A sp: c000000000acbdb0
> A A A A A msr: 80021000
> A A A A A dar: c000000101e28020
> A A A dsisr: 800000
> A A A A current = 0xc000000000a07640
> A A A A pacaA A A A = 0xc00000003fff5000	A softe: 0	A irq_happened: 0x01
> A A A A A A pidA A A = 0, comm = swapper
> A  Linux version 4.6.0-rc3-00160-gc09920947f23 (michael@ka1) (gcc version 5.3.0 (GCC) ) #5 SMP Tue May 10 09:44:11 AEST 2016
> A  enter ? for help
> A  [link registerA A A ] c0000000009883d0 .free_all_bootmem+0x70/0x200
> A  [c000000000acbdb0] c000000000988398 .free_all_bootmem+0x38/0x200 (unreliable)
> A  [c000000000acbe80] c00000000097b700 .mem_init+0x5c/0x7c
> A  [c000000000acbef0] c000000000971a0c .start_kernel+0x28c/0x4e4
> A  [c000000000acbf90] c000000000000544 start_here_common+0x20/0x5c
> A  0:mon> ?A 
>A 
> I can give you access some time if you need to debug it.
>A 


Could you also please post the bits on the boot containing the zone
and node information. That would provide some information about what
is broken. Or you could just send the whole dmesg

Thanks,
Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
