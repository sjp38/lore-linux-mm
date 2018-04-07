Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0DE6B0007
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 10:45:47 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p131-v6so2285205oig.10
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 07:45:47 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 92-v6si3760086otw.33.2018.04.07.07.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Apr 2018 07:45:46 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w37EVjv3162532
	for <linux-mm@kvack.org>; Sat, 7 Apr 2018 14:45:45 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2h6pn48nwd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 07 Apr 2018 14:45:45 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w37Ejioa000668
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 7 Apr 2018 14:45:44 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w37Ejio2010772
	for <linux-mm@kvack.org>; Sat, 7 Apr 2018 14:45:44 GMT
Received: by mail-ot0-f181.google.com with SMTP id h55-v6so4206393ote.9
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 07:45:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180406124535.k3qyxjfrlo55d5if@xakep.localdomain>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
 <20180131210300.22963-2-pasha.tatashin@oracle.com> <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
 <CAGM2reaPK=ZcLBOnmBiC2-u86DZC6ukOhL1xxZofB2OTW3ozoA@mail.gmail.com>
 <20180314005350.6xdda2uqzuy4n3o6@sasha-lappy> <20180315190430.o3vs7uxlafzdwgzd@xakep.localdomain>
 <20180315204312.n7p4zzrftgg6m7zw@sasha-lappy> <20180404021746.m77czxidkaumkses@xakep.localdomain>
 <20180405134940.2yzx4p7hjed7lfdk@xakep.localdomain> <20180405192256.GQ7561@sasha-vm>
 <20180406124535.k3qyxjfrlo55d5if@xakep.localdomain>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sat, 7 Apr 2018 10:45:03 -0400
Message-ID: <CAGM2reYtCb2_czEt1M8KhFz+YxGq=iSGnTskC=FGNM4kXOiS5g@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity checking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "bharata@linux.vnet.ibm.com" <bharata@linux.vnet.ibm.com>

> Let me study your trace, perhaps I will able to figure out the issue
> without reproducing it.

Hi Sasha,

I've been studying this problem more. The issue happens in this stack:

...subsys_init...
 topology_init()
  register_one_node(nid)
   link_mem_sections(nid, pgdat->node_start_pfn, pgdat->node_spanned_pages)
    register_mem_sect_under_node(mem_blk, nid)
     get_nid_for_pfn(pfn)
      pfn_to_nid(pfn)
       page_to_nid(page)
        PF_POISONED_CHECK(page)

We are trying to get nid from struct page which has not been
initialized.  My patches add this extra scrutiny to make sure that we
never get invalid nid from a "struct page" by adding
PF_POISONED_CHECK() to page_to_nid(). So, the bug already exists in
Linux where incorrect nid is read. The question is why does happen?

First, I thought, that perhaps struct page is not yet initialized.
But, the initcalls are done after deferred pages are initialized, and
thus every struct page must be initialized by now. Also, if deferred
pages were enabled, we would take a slightly different path and avoid
this bug by getting nid from memblock instead of struct page:

get_nid_for_pfn(pfn)
#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 if (system_state < SYSTEM_RUNNING)
  return early_pfn_to_nid(pfn);
#endif

I also verified in your config that CONFIG_DEFERRED_STRUCT_PAGE_INIT
is not set. So, one way to fix this issue, is to remove this "#ifdef"
(I have not checked for dependancies), but this is simply addressing
symptom, not fixing the actual issue.

Thus, we have a "struct page" backing memory for this pfn, but we have
not initialized it. For some reason memmap_init_zone() decided to skip
it, and I am not sure why. Looking at the code we skip initializing
if:
!early_pfn_valid(pfn)) aka !pfn_valid(pfn) and if !early_pfn_in_nid(pfn, nid).

I suspect, this has something to do with !pfn_valid(pfn). But, without
having a machine on which I could reproduce this problem, I cannot
study it further to determine exactly why pfn is not valid.

Please replace !pfn_valid_within() with !pfn_valid() in
get_nid_for_pfn() and see if problem still happens. If it does not
happen, lets study the memory map, pgdata's start end, and the value
of this pfn.

Thank you,
Pasha
