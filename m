Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B14976B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 05:59:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v25-v6so5749034wmc.8
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 02:59:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k15-v6sor5912214wrm.34.2018.07.13.02.59.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 02:59:36 -0700 (PDT)
Date: Fri, 13 Jul 2018 11:59:34 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 0/5] sparse_init rewrite
Message-ID: <20180713095934.GB15039@techadventures.net>
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712203730.8703-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Thu, Jul 12, 2018 at 04:37:25PM -0400, Pavel Tatashin wrote:
> Changelog:
> v5 - v4
> 	- Fixed the issue that was reported on ppc64 when
> 	  CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER is removed
> 	- Consolidated the new buffer allocation between vmemmap
> 	  and non-vmemmap variants of sparse layout.
> 	- Removed all review-by comments, because I had to do
> 	  significant amount of changes compared to previous version
> 	  and need another round of review.
> 	- I also would appreciate if those who reported problems with
> 	  PPC64 could test this change.

About PPC64, your patchset fixes the issue as the population gets followed by a
sparse_init_one_section().

It can be seen here:

Before:

kernel: vmemmap_populate f000000000000000..f000000000004000, node 0
kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
kernel: vmemmap_populate f000000000000000..f000000000008000, node 0
kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
kernel: vmemmap_populate f000000000000000..f00000000000c000, node 0
kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)


After:

kernel: vmemmap_populate f000000000000000..f000000000004000, node 0
kernel:       * f000000000000000..f000000000010000 allocated at (____ptrval____)
kernel: vmemmap_populate f000000000000000..f000000000008000, node 0
kernel: vmemmap_populate f000000000000000..f00000000000c000, node 0
kernel: vmemmap_populate f000000000000000..f000000000010000, node 0
kernel: vmemmap_populate f000000000010000..f000000000014000, node 0
kernel:       * f000000000010000..f000000000020000 allocated at (____ptrval____)


As can be seen, before the patchset, we keep calling vmemmap_create_mapping() even if we
populated that section already, because of vmemmap_populated() checking for SECTION_HAS_MEM_MAP.

After the patchset, since each population is being followed by a call to sparse_init_one_section(),
when vmemmap_populated() gets called, we have SECTION_HAS_MEM_MAP already in case the section
was populated.
-- 
Oscar Salvador
SUSE L3
