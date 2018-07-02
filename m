Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4F586B0006
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 22:43:49 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k7-v6so1843553iog.2
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 19:43:49 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o9-v6si4483292itf.26.2018.07.01.19.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 19:43:48 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w622dYLL088984
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 02:43:47 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2jx19sjnga-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 02:43:47 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w622hkSX015347
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 02:43:46 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w622hk8C000713
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 02:43:46 GMT
Received: by mail-oi0-f45.google.com with SMTP id 8-v6so9015673oin.10
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 19:43:46 -0700 (PDT)
MIME-Version: 1.0
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com> <20180702021121.GL3223@MiWiFi-R3L-srv>
 <CAGM2rebY1_-3hvp_+kqF==nLawC0FN6Q1J5X5pm5qxHdDJzjiQ@mail.gmail.com> <20180702023130.GM3223@MiWiFi-R3L-srv>
In-Reply-To: <20180702023130.GM3223@MiWiFi-R3L-srv>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sun, 1 Jul 2018 22:43:09 -0400
Message-ID: <CAGM2rebUsJ2r-2F38Vv13zbaEPPgTn0w6H3j6fpg0WVa9wB6Uw@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On Sun, Jul 1, 2018 at 10:31 PM Baoquan He <bhe@redhat.com> wrote:
>
> On 07/01/18 at 10:18pm, Pavel Tatashin wrote:
> > > Here, I think it might be not right to jump to 'failed' directly if one
> > > section of the node failed to populate memmap. I think the original code
> > > is only skipping the section which memmap failed to populate by marking
> > > it as not present with "ms->section_mem_map = 0".
> > >
> >
> > Hi Baoquan,
> >
> > Thank you for a careful review. This is an intended change compared to
> > the original code. Because we operate per-node now, if we fail to
> > allocate a single section, in this node, it means we also will fail to
> > allocate all the consequent sections in the same node and no need to
> > check them anymore. In the original code we could not simply bailout,
> > because we still might have valid entries in the following nodes.
> > Similarly, sparse_init() will call sparse_init_nid() for the next node
> > even if previous node failed to setup all the memory.
>
> Hmm, say the node we are handling is node5, and there are 100 sections.
> If you allocate memmap for section at one time, you have succeeded to
> handle for the first 99 sections, now the 100th failed, so you will mark
> all sections on node5 as not present. And the allocation failure is only
> for single section memmap allocation case.

No, unless I am missing something, that's not how code works:

463                 if (!map) {
464                         pr_err("%s: memory map backing failed.
Some memory will not be available.",
465                                __func__);
466                         pnum_begin = pnum;
467                         goto failed;
468                 }

476 failed:
477         /* We failed to allocate, mark all the following pnums as
not present */
478         for_each_present_section_nr(pnum_begin, pnum) {

We continue from the pnum that failed as we set pnum_begin to pnum,
and mark all the consequent sections as not-present.

The only change compared to the original code is that once we found an
empty pnum we stop checking the consequent pnums in this node, as we
know they are empty as well, because there is no more memory in this
node to allocate from.

Pavel
