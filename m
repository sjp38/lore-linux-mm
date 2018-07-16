Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 878626B0007
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 02:40:44 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t20-v6so3449106pgu.9
        for <linux-mm@kvack.org>; Sun, 15 Jul 2018 23:40:44 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id o8-v6si631975pgo.175.2018.07.15.23.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 15 Jul 2018 23:40:43 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v5 0/5] sparse_init rewrite
In-Reply-To: <CAGM2reavPdp48_=cw1g3Jmz2+ZLU9DkOQbdwAu17v39OCkjVPg@mail.gmail.com>
References: <20180712203730.8703-1-pasha.tatashin@oracle.com> <20180713095934.GB15039@techadventures.net> <CAGM2reavPdp48_=cw1g3Jmz2+ZLU9DkOQbdwAu17v39OCkjVPg@mail.gmail.com>
Date: Mon, 16 Jul 2018 16:40:34 +1000
Message-ID: <87bmb7znrx.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, osalvador@techadventures.net
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com

Pavel Tatashin <pasha.tatashin@oracle.com> writes:

>> About PPC64, your patchset fixes the issue as the population gets followed by a
>> sparse_init_one_section().
>>
>> It can be seen here:
>>
>> Before:
>>
>> kernel: vmemmap_populate f000000000000000..f000000000004000, node 0
>> kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
>> kernel: vmemmap_populate f000000000000000..f000000000008000, node 0
>> kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
>> kernel: vmemmap_populate f000000000000000..f00000000000c000, node 0
>> kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
>>
>>
>> After:
>>
>> kernel: vmemmap_populate f000000000000000..f000000000004000, node 0
>> kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
>> kernel: vmemmap_populate f000000000000000..f000000000008000, node 0
>> kernel: vmemmap_populate f000000000000000..f00000000000c000, node 0
>> kernel: vmemmap_populate f000000000000000..f000000000010000, node 0
>> kernel: vmemmap_populate f000000000010000..f000000000014000, node 0
>> kernel:       * f000000000010000..f000000000020000 allocated at (____ptrval____)
>>
>>
>> As can be seen, before the patchset, we keep calling vmemmap_create_mapping() even if we
>> populated that section already, because of vmemmap_populated() checking for SECTION_HAS_MEM_MAP.
>>
>> After the patchset, since each population is being followed by a call to sparse_init_one_section(),
>> when vmemmap_populated() gets called, we have SECTION_HAS_MEM_MAP already in case the section
>> was populated.
>
> Hi Oscar,
>
> Right, I also like that this solution removes one extra loop, thus
> reduces the code size. We were populating pages in one place, and then
> loop again to set sections, now we do both in one place, but still
> allow preallocation of memory to reduces fragmentation on all
> platforms. However, I still wanted to see if someone could test on
> real hardware.

I booted it on a small VM and a 160 CPU 4 node machine, both booted
fine.

If you want:
  Tested-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)


Thanks for fixing it up for us.

cheers
