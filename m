Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D73F26B0269
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 22:53:48 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id m15-v6so16614530qkk.9
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 19:53:48 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y45-v6si4040448qtb.355.2018.07.01.19.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 19:53:48 -0700 (PDT)
Date: Mon, 2 Jul 2018 10:53:43 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
Message-ID: <20180702025343.GN3223@MiWiFi-R3L-srv>
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com>
 <20180702021121.GL3223@MiWiFi-R3L-srv>
 <CAGM2rebY1_-3hvp_+kqF==nLawC0FN6Q1J5X5pm5qxHdDJzjiQ@mail.gmail.com>
 <20180702023130.GM3223@MiWiFi-R3L-srv>
 <CAGM2rebUsJ2r-2F38Vv13zbaEPPgTn0w6H3j6fpg0WVa9wB6Uw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2rebUsJ2r-2F38Vv13zbaEPPgTn0w6H3j6fpg0WVa9wB6Uw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On 07/01/18 at 10:43pm, Pavel Tatashin wrote:
> On Sun, Jul 1, 2018 at 10:31 PM Baoquan He <bhe@redhat.com> wrote:
> >
> > On 07/01/18 at 10:18pm, Pavel Tatashin wrote:
> > > > Here, I think it might be not right to jump to 'failed' directly if one
> > > > section of the node failed to populate memmap. I think the original code
> > > > is only skipping the section which memmap failed to populate by marking
> > > > it as not present with "ms->section_mem_map = 0".
> > > >
> > >
> > > Hi Baoquan,
> > >
> > > Thank you for a careful review. This is an intended change compared to
> > > the original code. Because we operate per-node now, if we fail to
> > > allocate a single section, in this node, it means we also will fail to
> > > allocate all the consequent sections in the same node and no need to
> > > check them anymore. In the original code we could not simply bailout,
> > > because we still might have valid entries in the following nodes.
> > > Similarly, sparse_init() will call sparse_init_nid() for the next node
> > > even if previous node failed to setup all the memory.
> >
> > Hmm, say the node we are handling is node5, and there are 100 sections.
> > If you allocate memmap for section at one time, you have succeeded to
> > handle for the first 99 sections, now the 100th failed, so you will mark
> > all sections on node5 as not present. And the allocation failure is only
> > for single section memmap allocation case.
> 
> No, unless I am missing something, that's not how code works:
> 
> 463                 if (!map) {
> 464                         pr_err("%s: memory map backing failed.
> Some memory will not be available.",
> 465                                __func__);
> 466                         pnum_begin = pnum;
> 467                         goto failed;
> 468                 }
> 
> 476 failed:
> 477         /* We failed to allocate, mark all the following pnums as
> not present */
> 478         for_each_present_section_nr(pnum_begin, pnum) {
> 
> We continue from the pnum that failed as we set pnum_begin to pnum,
> and mark all the consequent sections as not-present.

Ah, yes, I misunderstood it, sorry for that.

Then I have only one concern, for vmemmap case, if one section doesn't
succeed to populate its memmap, do we need to skip all the remaining
sections in that node?

> 
> The only change compared to the original code is that once we found an
> empty pnum we stop checking the consequent pnums in this node, as we
> know they are empty as well, because there is no more memory in this
> node to allocate from.
> 
