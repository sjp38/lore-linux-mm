Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E57076B0007
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 18:55:05 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u22-v6so24944736qkk.10
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 15:55:05 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e12-v6si14343858qkj.3.2018.07.09.15.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 15:55:05 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w69MsVjs002275
	for <linux-mm@kvack.org>; Mon, 9 Jul 2018 22:55:04 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2k2p7v7g6p-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 09 Jul 2018 22:55:04 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w69Mt2I0012253
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 9 Jul 2018 22:55:03 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w69Mt20p030577
	for <linux-mm@kvack.org>; Mon, 9 Jul 2018 22:55:02 GMT
Received: by mail-oi0-f43.google.com with SMTP id c6-v6so39078945oiy.0
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 15:55:02 -0700 (PDT)
MIME-Version: 1.0
References: <20180709175312.11155-1-pasha.tatashin@oracle.com> <20180709142928.c8af4a1ddf80c407fe66b224@linux-foundation.org>
In-Reply-To: <20180709142928.c8af4a1ddf80c407fe66b224@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 9 Jul 2018 18:54:25 -0400
Message-ID: <CAGM2reaB-jtqg1fhHZtopUy0N5dwMr4yF3iWFViLEFjbBqD_AA@mail.gmail.com>
Subject: Re: [PATCH v4 0/3] sparse_init rewrite
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On Mon, Jul 9, 2018 at 5:29 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Mon,  9 Jul 2018 13:53:09 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
>
> > In sparse_init() we allocate two large buffers to temporary hold usemap and
> > memmap for the whole machine. However, we can avoid doing that if we
> > changed sparse_init() to operated on per-node bases instead of doing it on
> > the whole machine beforehand.
> >
> > As shown by Baoquan
> > http://lkml.kernel.org/r/20180628062857.29658-1-bhe@redhat.com
> >
> > The buffers are large enough to cause machine stop to boot on small memory
> > systems.
> >
> > These patches should be applied on top of Baoquan's work, as
> > CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER is removed in that work.
> >
> > For the ease of review, I split this work so the first patch only adds new
> > interfaces, the second patch enables them, and removes the old ones.
>
> This clashes pretty significantly with patches from Baoquan and Oscar:
>
> mm-sparse-make-sparse_init_one_section-void-and-remove-check.patch
> mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix.patch
> mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix-2.patch
> mm-sparse-add-a-static-variable-nr_present_sections.patch
> mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
> mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
>
> Is there duplication of intent here?  Any thoughts on the
> prioritization of these efforts?

Hi Andrew,

In the cover letter I wrote that these should be applied on top of
Baoquan's patches. His work fixes a bug by making temporary buffers
smaller on smaller machines, and also starts the sparse_init cleaning
process by getting rid of CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER. My
patches remove those buffers entirely. However, if my patches
conflict, I should resend based on mm-tree as Baoquan's patches are
already in and probably were slightly modified compared to what I have
locally, which I took from the mailing list.

Pavel
