Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0B81E6B0036
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 07:11:52 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so744197pbb.38
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 04:11:52 -0700 (PDT)
Received: by mail-ea0-f171.google.com with SMTP id n15so319932ead.16
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 04:11:49 -0700 (PDT)
Date: Wed, 9 Oct 2013 13:11:47 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/63] Basic scheduler support for automatic NUMA
 balancing V9
Message-ID: <20131009111146.GA19610@gmail.com>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131009110353.GA19370@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20131009110353.GA19370@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Ingo Molnar <mingo@kernel.org> wrote:

> 3)
> 
> Plus in addition to PeterZ's build fix I noticed this new build warning on 
> i386 UP kernels:
> 
>  kernel/sched/fair.c:819:22: warning: 'task_h_load' declared 'static' but never defined [-Wunused-function]
> 
> Introduced here I think:
> 
>     sched/numa: Use a system-wide search to find swap/migration candidates

4)

allyes builds fail on x86 32-bit:

   mm/mmzone.c:101:5: error: redefinition of a??page_cpupid_xchg_lasta??

The reason is the mismatch in definitions:

 mm.h:

  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS

 mmzone.c:

  #if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_CPUPID_IN_PAGE_FLAGS)

Note the missing 'NOT_' in the latter line. I've changed it to:

  #if defined(CONFIG_NUMA_BALANCING) && defined(LAST_CPUPID_NOT_IN_PAGE_FLAGS)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
