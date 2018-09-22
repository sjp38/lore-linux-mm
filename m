Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7939A8E0001
	for <linux-mm@kvack.org>; Sat, 22 Sep 2018 00:38:14 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b69-v6so7421571pfc.20
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 21:38:14 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id x14-v6si6068164pfi.138.2018.09.21.21.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 21:38:12 -0700 (PDT)
MIME-version: 1.0
Content-type: text/plain; charset="utf-8"; format="flowed"
Subject: Re: Question about a pte with PTE_PROT_NONE and !PTE_VALID on
 !PROT_NONE vma
From: Chulmin Kim <cmlaika.kim@samsung.com>
Message-id: <10146a73-4788-ba89-001f-f928bbb314f5@samsung.com>
Date: Sat, 22 Sep 2018 13:38:07 +0900
In-reply-to: 
	<CANYKp7ufttxsNkewBqgYDexMAoyVnMxgoy-EydCqmHadxyn+QQ@mail.gmail.com>
Content-transfer-encoding: 8bit
Content-language: en-US
References: <CGME20180921150147epcas5p33964436b2e609016311e4f12b715779d@epcas5p3.samsung.com>
	<CANYKp7ufttxsNkewBqgYDexMAoyVnMxgoy-EydCqmHadxyn+QQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmkim.laika@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, aarcange@redhat.com

Dear Arcangeli,


I think this problem is very much related with

the race condition shown in the below commit.

(e86f15ee64d8, mm: vma_merge: fix vm_page_prot SMP race condition 
against rmap_walk)


I checked that

the the thread and its child threads are doing mprotect(PROT_{NONE or 
R|W}) things repeatedly

while I didn't reproduce the problem yet.


Do you think this is one of the phenomenon you expected

from the race condition shown in the above commit?


Thanks.

Chulmin Kim



On 09/22/2018 12:01 AM, Chulmin Kim wrote:
> Hi all.
> I am developing an android smartphone.
>
> I am facing a problem that a thread is looping the page fault routine 
> forever.
> (The kernel version is around v4.4 though it may differ from the 
> mainline slightly
> as the problem occurs in a device being developed in my company.)
>
> The pte corresponding to the fault address is with PTE_PROT_NONE and 
> !PTE_VALID.
> (by the way, the pte is mapped to anon page (ashmem))
> The weird thing, in my opinion, is that
> the VMA of the fault address is not withA PROT_NONEA but with PROT_READ 
> & PROT_WRITE.
> So, the page fault routine (handle_pte_fault()) returns 0 and fault 
> loops forever.
>
> I don't think this is a normal situation.
>
> As I didn't enable NUMA, a pte with PROT_NONE and !PTE_VALID is likely 
> set by mprotect().
> 1. mprotect(PROT_NONE) -> vma split & set pte with PROT_NONE
> 2. mprotect(PROT_READ & WRITE) -> vma merge & revert pte
> I suspect that the revert pte in #2 didn't work somehow
> but no clue.
>
> I googled and found a similar situation 
> (http://linux-kernel.2935.n7.nabble.com/pipe-page-fault-oddness-td953839.html) 
> which is relevant to NUMA and huge pagetable configs
> while my device is nothing to do with those configs.
>
> Am I missing any possible scenario? or is it already known BUG?
> It will be pleasure if you can give any idea about this problem.
>
> Thanks.
> Chulmin Kim
