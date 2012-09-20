Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 086886B006C
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 14:54:24 -0400 (EDT)
Message-ID: <505B6658.1080706@redhat.com>
Date: Thu, 20 Sep 2012 14:54:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] mm: compaction: Acquire the zone->lru_lock as late
 as possible
References: <1348149875-29678-1-git-send-email-mgorman@suse.de> <1348149875-29678-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1348149875-29678-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/20/2012 10:04 AM, Mel Gorman wrote:
> Compactions migrate scanner acquires the zone->lru_lock when scanning a range
> of pages looking for LRU pages to acquire. It does this even if there are
> no LRU pages in the range. If multiple processes are compacting then this
> can cause severe locking contention. To make matters worse commit b2eef8c0
> (mm: compaction: minimise the time IRQs are disabled while isolating pages
> for migration) releases the lru_lock every SWAP_CLUSTER_MAX pages that are
> scanned.
>
> This patch makes two changes to how the migrate scanner acquires the LRU
> lock. First, it only releases the LRU lock every SWAP_CLUSTER_MAX pages if
> the lock is contended. This reduces the number of times it unnecessarily
> disables and re-enables IRQs. The second is that it defers acquiring the
> LRU lock for as long as possible. If there are no LRU pages or the only
> LRU pages are transhuge then the LRU lock will not be acquired at all
> which reduces contention on zone->lru_lock.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
