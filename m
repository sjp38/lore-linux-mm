Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC976B00D2
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 11:26:49 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wy17so5801270pbc.39
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 08:26:49 -0700 (PDT)
Received: from psmtp.com ([74.125.245.138])
        by mx.google.com with SMTP id yj4si12577403pac.50.2013.10.22.08.26.47
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 08:26:48 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 22 Oct 2013 20:56:41 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 4C916DA8056
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:59:06 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9MBSTV535913728
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:30 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9MBSWKQ022977
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:32 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 0/9] powerpc: mm: Numa faults support for ppc64
Date: Tue, 22 Oct 2013 16:58:11 +0530
Message-Id: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org

Hi,

This patch series add support for numa faults on ppc64 architecture. We steal the
_PAGE_COHERENCE bit and use that for indicating _PAGE_NUMA. We clear the _PAGE_PRESENT bit
and also invalidate the hpte entry on setting _PAGE_NUMA. The next fault on that
page will be considered a numa fault.


NOTE:
______
Issue:
I am finding large lock contention on page_table_lock with this series on a 95 cpu 4 node box with autonuma benchmark

I will out on vacation till NOV 6 without email access. Hence i will not be able to respond to review feedbacks
till then. 


lock_stat version 0.3
-------------------------------------------------------------------------------------------------------------------------------------------------------
                      class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-mi  hold time hold total
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  &(&mm->page_table_lock)->rlock:     713531791      719610919           0.09     3038193.19 357867523236.3      729709189      750040162    0.0  236991.36  1159646899.68
  ------------------------------
  &(&mm->page_table_lock)->rlock              1          [<c000000000218880>] .anon_vma_prepare+0xb0/0x1e0
  &(&mm->page_table_lock)->rlock             93          [<c000000000207ebc>] .do_numa_page+0x4c/0x190
  &(&mm->page_table_lock)->rlock         301678          [<c0000000002139d4>] .change_protection+0x1d4/0x560
  &(&mm->page_table_lock)->rlock         244524          [<c000000000213be8>] .change_protection+0x3e8/0x560
  ------------------------------
  &(&mm->page_table_lock)->rlock              1          [<c000000000206a38>] .__do_fault+0x198/0x6b0
  &(&mm->page_table_lock)->rlock         704163          [<c0000000002139d4>] .change_protection+0x1d4/0x560
  &(&mm->page_table_lock)->rlock         207227          [<c000000000213be8>] .change_protection+0x3e8/0x560
  &(&mm->page_table_lock)->rlock             95          [<c000000000207ebc>] .do_numa_page+0x4c/0x190
 
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
