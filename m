Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 690426B0047
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 15:55:01 -0500 (EST)
Date: Fri, 29 Jan 2010 12:54:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFP 2/3] Fix unmap_vma() bug related to mmu_notifiers
Message-Id: <20100129125426.2cde0a5f.akpm@linux-foundation.org>
In-Reply-To: <20100128195634.355405000@alcatraz.americas.sgi.com>
References: <20100128195627.373584000@alcatraz.americas.sgi.com>
	<20100128195634.355405000@alcatraz.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 2010 13:56:29 -0600
Robin Holt <holt@sgi.com> wrote:

> 
> unmap_vmas() can fail to correctly flush the TLB if a
> callout to mmu_notifier_invalidate_range_start() sleeps.
> The mmu_gather list is initialized prior to the callout. If it is reused
> while the thread is sleeping, the mm field may be invalid.
> 
> If the task migrates to a different cpu, the task may use the wrong
> mmu_gather.

I don't think that description is complete.

There might be ways in which we can prevent this task from being
migrated to another CPU, but that doesn't fix the problem because the
mmu_gather is a per-CPU resource and might get trashed if another task
is scheduled on THIS cpu, and uses its mmu_gather.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
