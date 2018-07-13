Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB8426B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 07:11:22 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id w23-v6so27684637ioa.1
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 04:11:22 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id z16-v6si462745jan.112.2018.07.13.04.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 04:11:21 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6DB4E1b170596
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:11:20 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2k2p767abd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:11:20 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6DBBJ0h015481
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:11:19 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6DBBI82018914
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:11:19 GMT
Received: by mail-oi0-f44.google.com with SMTP id v8-v6so61533437oie.5
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 04:11:18 -0700 (PDT)
MIME-Version: 1.0
References: <20180712203730.8703-1-pasha.tatashin@oracle.com> <20180713095934.GB15039@techadventures.net>
In-Reply-To: <20180713095934.GB15039@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 13 Jul 2018 07:10:42 -0400
Message-ID: <CAGM2reavPdp48_=cw1g3Jmz2+ZLU9DkOQbdwAu17v39OCkjVPg@mail.gmail.com>
Subject: Re: [PATCH v5 0/5] sparse_init rewrite
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

> About PPC64, your patchset fixes the issue as the population gets followed by a
> sparse_init_one_section().
>
> It can be seen here:
>
> Before:
>
> kernel: vmemmap_populate f000000000000000..f000000000004000, node 0
> kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
> kernel: vmemmap_populate f000000000000000..f000000000008000, node 0
> kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
> kernel: vmemmap_populate f000000000000000..f00000000000c000, node 0
> kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
>
>
> After:
>
> kernel: vmemmap_populate f000000000000000..f000000000004000, node 0
> kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
> kernel: vmemmap_populate f000000000000000..f000000000008000, node 0
> kernel: vmemmap_populate f000000000000000..f00000000000c000, node 0
> kernel: vmemmap_populate f000000000000000..f000000000010000, node 0
> kernel: vmemmap_populate f000000000010000..f000000000014000, node 0
> kernel:       * f000000000010000..f000000000020000 allocated at (____ptrval____)
>
>
> As can be seen, before the patchset, we keep calling vmemmap_create_mapping() even if we
> populated that section already, because of vmemmap_populated() checking for SECTION_HAS_MEM_MAP.
>
> After the patchset, since each population is being followed by a call to sparse_init_one_section(),
> when vmemmap_populated() gets called, we have SECTION_HAS_MEM_MAP already in case the section
> was populated.

Hi Oscar,

Right, I also like that this solution removes one extra loop, thus
reduces the code size. We were populating pages in one place, and then
loop again to set sections, now we do both in one place, but still
allow preallocation of memory to reduces fragmentation on all
platforms. However, I still wanted to see if someone could test on
real hardware.

Thank you,
Pavel
