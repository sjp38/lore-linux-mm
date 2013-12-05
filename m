Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 009566B0036
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 15:05:10 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id e16so5341849qcx.17
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 12:05:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id hj7si23246231qeb.78.2013.12.05.12.05.09
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 12:05:09 -0800 (PST)
Message-ID: <52A0DC7F.7050403@redhat.com>
Date: Thu, 05 Dec 2013 15:05:19 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/15] mm: numa: Flush TLB if NUMA hinting faults race
 with PTE scan update
References: <1386060721-3794-1-git-send-email-mgorman@suse.de> <1386060721-3794-15-git-send-email-mgorman@suse.de> <529E641A.7040804@redhat.com> <20131203234637.GS11295@suse.de> <529F3D51.1090203@redhat.com> <20131204160741.GC11295@suse.de> <20131205104015.716ed0fe@annuminas.surriel.com> <20131205195446.GI11295@suse.de>
In-Reply-To: <20131205195446.GI11295@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com

On 12/05/2013 02:54 PM, Mel Gorman wrote:

> I think that's a better fit and a neater fix. Thanks! I think it barriers
> more than it needs to (definite cost vs maybe cost), the flush can be
> deferred until we are definitely trying to migrate and the pte case is
> not guaranteed to be flushed before migration due to pte_mknonnuma causing
> a flush in ptep_clear_flush to be avoided later. Mashing the two patches
> together yields this.

I think this would fix the numa migrate case.

However, I believe the same issue is also present in
mprotect(..., PROT_NONE) vs. compaction, for programs
that trap SIGSEGV for garbage collection purposes.

They could lose modifications done in-between when
the pte was set to PROT_NONE, and the actual TLB
flush, if compaction moves the page around in-between
those two events.

I don't know if this is a case we need to worry about
at all, but I think the same fix would apply to that
code path, so I guess we might as well make it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
