Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1A8F6B007E
	for <linux-mm@kvack.org>; Mon,  9 May 2016 19:55:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so406951844pfb.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 16:55:57 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id c8si41612108pag.244.2016.05.09.16.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 16:55:57 -0700 (PDT)
In-Reply-To: <1462434849-14935-2-git-send-email-oohall@gmail.com>
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [v2,2/2] powerpc/mm: Ensure "special" zones are empty
Message-Id: <3r3fQw4Xbnz9t79@ozlabs.org>
Date: Tue, 10 May 2016 09:55:51 +1000 (AEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>, linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org

On Thu, 2016-05-05 at 07:54:09 UTC, Oliver O'Halloran wrote:
> The mm zone mechanism was traditionally used by arch specific code to
> partition memory into allocation zones. However there are several zones
> that are managed by the mm subsystem rather than the architecture. Most
> architectures set the max PFN of these special zones to zero, however on
> powerpc we set them to ~0ul. This, in conjunction with a bug in
> free_area_init_nodes() results in all of system memory being placed in
> ZONE_DEVICE when enabled. Device memory cannot be used for regular kernel
> memory allocations so this will cause a kernel panic at boot.

This is breaking my freescale machine:

  Sorting __ex_table...
  Unable to handle kernel paging request for data at address 0xc000000101e28020
  Faulting instruction address: 0xc0000000009ab698
  cpu 0x0: Vector: 300 (Data Access) at [c000000000acbb30]
      pc: c0000000009ab698: .reserve_bootmem_region+0x64/0x8c
      lr: c0000000009883d0: .free_all_bootmem+0x70/0x200
      sp: c000000000acbdb0
     msr: 80021000
     dar: c000000101e28020
   dsisr: 800000
    current = 0xc000000000a07640
    paca    = 0xc00000003fff5000	 softe: 0	 irq_happened: 0x01
      pid   = 0, comm = swapper
  Linux version 4.6.0-rc3-00160-gc09920947f23 (michael@ka1) (gcc version 5.3.0 (GCC) ) #5 SMP Tue May 10 09:44:11 AEST 2016
  enter ? for help
  [link register   ] c0000000009883d0 .free_all_bootmem+0x70/0x200
  [c000000000acbdb0] c000000000988398 .free_all_bootmem+0x38/0x200 (unreliable)
  [c000000000acbe80] c00000000097b700 .mem_init+0x5c/0x7c
  [c000000000acbef0] c000000000971a0c .start_kernel+0x28c/0x4e4
  [c000000000acbf90] c000000000000544 start_here_common+0x20/0x5c
  0:mon> ? 

I can give you access some time if you need to debug it.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
