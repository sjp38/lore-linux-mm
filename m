Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB1E6B0038
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 16:35:04 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id b16so2432531igk.17
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 13:35:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id us10si39635729icb.68.2015.01.05.13.35.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 13:35:02 -0800 (PST)
Date: Mon, 5 Jan 2015 13:35:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] fs: proc: task_mmu: show page size in
 /proc/<pid>/numa_maps
Message-Id: <20150105133500.e0ce4b090e6b378c3edc9c56@linux-foundation.org>
In-Reply-To: <734bca19b3a8f4e191ccc9055ad4740744b5b2b6.1420464466.git.aquini@redhat.com>
References: <734bca19b3a8f4e191ccc9055ad4740744b5b2b6.1420464466.git.aquini@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, jweiner@redhat.com, dave.hansen@linux.intel.com, rientjes@google.com, linux-mm@kvack.org

On Mon,  5 Jan 2015 12:44:31 -0500 Rafael Aquini <aquini@redhat.com> wrote:

> This patch introduces 'kernelpagesize_kB' line element to /proc/<pid>/numa_maps
> report file in order to help identifying the size of pages that are backing
> memory areas mapped by a given task. This is specially useful to
> help differentiating between HUGE and GIGANTIC page backed VMAs.
> 
> This patch is based on Dave Hansen's proposal and reviewer's follow-ups
> taken from the following dicussion threads:
>  * https://lkml.org/lkml/2011/9/21/454

Dave's changelog contains useful information which this one lacked.  I
stole some of it.

: The output of /proc/$pid/numa_maps is in terms of number of pages like
: anon=22 or dirty=54.  Here's some output:
: 
: 7f4680000000 default file=/hugetlb/bigfile anon=50 dirty=50 N0=50
: 7f7659600000 default file=/anon_hugepage\040(deleted) anon=50 dirty=50 N0=50
: 7fff8d425000 default stack anon=50 dirty=50 N0=50
: Looks like we have a stack and a couple of anonymous hugetlbfs
: areas page which both use the same amount of memory.  They don't.
: 
: The 'bigfile' uses 1GB pages and takes up ~50GB of space.  The
: anon_hugepage uses 2MB pages and takes up ~100MB of space while the stack
: uses normal 4k pages.  You can go over to smaps to figure out what the
: page size _really_ is with KernelPageSize or MMUPageSize.  But, I think
: this is a pretty nasty and counterintuitive interface as it stands.
: 
: This patch introduces 'kernelpagesize_kB' line element to
: /proc/<pid>/numa_maps report file in order to help identifying the size of
: pages that are backing memory areas mapped by a given task.  This is
: specially useful to help differentiating between HUGE and GIGANTIC page
: backed VMAs.
: 
: This patch is based on Dave Hansen's proposal and reviewer's follow-ups
: taken from the following dicussion threads:
:  * https://lkml.org/lkml/2011/9/21/454
:  * https://lkml.org/lkml/2014/12/20/66


> +	seq_printf(m, " kernelpagesize_kB=%lu", vma_kernel_pagesize(vma) >> 10);

This changes the format of the numa_maps file and can potentially break
existing parsers.  Please discuss.

I'd complain about the patch's failure to update the documentation,
except numa_maps appears to be undocumented.  Sigh.  What the heck is "N0"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
