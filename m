Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE6B280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 04:19:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l132so74931034wmf.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:19:50 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id ud2si18499956wjc.0.2016.09.26.01.19.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 01:19:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id B727598B6F
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:19:48 +0000 (UTC)
Date: Mon, 26 Sep 2016 09:19:47 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA
 balancing
Message-ID: <20160926081947.GB2838@techsingularity.net>
References: <20160911225425.10388-1-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160911225425.10388-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, riel@redhat.com, tbsaunde@tbsaunde.org, robert@ocallahan.org

On Sun, Sep 11, 2016 at 11:54:25PM +0100, Lorenzo Stoakes wrote:
> The NUMA balancing logic uses an arch-specific PROT_NONE page table flag defined
> by pte_protnone() or pmd_protnone() to mark PTEs or huge page PMDs respectively
> as requiring balancing upon a subsequent page fault. User-defined PROT_NONE
> memory regions which also have this flag set will not normally invoke the NUMA
> balancing code as do_page_fault() will send a segfault to the process before
> handle_mm_fault() is even called.
> 
> However if access_remote_vm() is invoked to access a PROT_NONE region of memory,
> handle_mm_fault() is called via faultin_page() and __get_user_pages() without
> any access checks being performed, meaning the NUMA balancing logic is
> incorrectly invoked on a non-NUMA memory region.
> 
> A simple means of triggering this problem is to access PROT_NONE mmap'd memory
> using /proc/self/mem which reliably results in the NUMA handling functions being
> invoked when CONFIG_NUMA_BALANCING is set.
> 
> This issue was reported in bugzilla (issue 99101) which includes some simple
> repro code.
> 
> There are BUG_ON() checks in do_numa_page() and do_huge_pmd_numa_page() added at
> commit c0e7cad to avoid accidentally provoking strange behaviour by attempting
> to apply NUMA balancing to pages that are in fact PROT_NONE. The BUG_ON()'s are
> consistently triggered by the repro.
> 
> This patch moves the PROT_NONE check into mm/memory.c rather than invoking
> BUG_ON() as faulting in these pages via faultin_page() is a valid reason for
> reaching the NUMA check with the PROT_NONE page table flag set and is therefore
> not always a bug.
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=99101
> Reported-by: Trevor Saunders <tbsaunde@tbsaunde.org>
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
