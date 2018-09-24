Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6537B8E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 17:08:53 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id t17-v6so6875255qtq.12
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 14:08:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i25-v6si277835qta.379.2018.09.24.14.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 14:08:52 -0700 (PDT)
Date: Mon, 24 Sep 2018 17:08:50 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Question about a pte with PTE_PROT_NONE and !PTE_VALID on
 !PROT_NONE vma
Message-ID: <20180924210850.GV28957@redhat.com>
References: <CGME20180921150147epcas5p33964436b2e609016311e4f12b715779d@epcas5p3.samsung.com>
 <CANYKp7ufttxsNkewBqgYDexMAoyVnMxgoy-EydCqmHadxyn+QQ@mail.gmail.com>
 <10146a73-4788-ba89-001f-f928bbb314f5@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <10146a73-4788-ba89-001f-f928bbb314f5@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: Chulmin Kim <cmkim.laika@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello,

On Sat, Sep 22, 2018 at 01:38:07PM +0900, Chulmin Kim wrote:
> Dear Arcangeli,
> 
> 
> I think this problem is very much related with
> 
> the race condition shown in the below commit.
> 
> (e86f15ee64d8, mm: vma_merge: fix vm_page_prot SMP race condition 
> against rmap_walk)
> 
> 
> I checked that
> 
> the the thread and its child threads are doing mprotect(PROT_{NONE or 
> R|W}) things repeatedly
> 
> while I didn't reproduce the problem yet.
> 
> 
> Do you think this is one of the phenomenon you expected
> 
> from the race condition shown in the above commit?

Yes that commit will fix your problem in a v4.4 based tree that misses
that fix. You just need to cherry-pick that commit to fix the problem.

Page migrate sets the pte to PROT_NONE by mistake because it runs
concurrently with the mprotect that transitions an adjacent vma from
PROT_NONE to PROT_READ|WRITE. vma_merge (before the fix) temporarily
shown an erratic PROT_NONE vma prot for the virtual range under page
migration.

With NUMA disabled, it's likely compaction that triggered page migrate
for you. Disabling compaction at build time would have likely hidden
the problem. Compaction uses migration and you most certainly have
CONFIG_COMPACTION=y (rightfully so).

On a side note, I suggest to cherry pick the last upstream commit of
mm/vmacache.c too.

Hope this helps,
Andrea
