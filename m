Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C10D16B0297
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:47:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l132so10400204wmf.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:47:40 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id 13si2253402wme.99.2016.09.23.01.47.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 01:47:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 5A622999DB
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 08:47:39 +0000 (UTC)
Date: Fri, 23 Sep 2016 09:47:29 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: delete unnecessary and unsafe init_tlb_ubc()
Message-ID: <20160923084729.GA2838@techsingularity.net>
References: <alpine.LSU.2.11.1609221037170.17333@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1609221037170.17333@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 22, 2016 at 10:41:50AM -0700, Hugh Dickins wrote:
> init_tlb_ubc() looked unnecessary to me: tlb_ubc is statically initialized
> with zeroes in the init_task, and copied from parent to child while it is
> quiescent in arch_dup_task_struct(); so I went to delete it.
> 
> But inserted temporary debug WARN_ONs in place of init_tlb_ubc() to check
> that it was always empty at that point, and found them firing: because
> memcg reclaim can recurse into global reclaim (when allocating biosets
> for swapout in my case), and arrive back at the init_tlb_ubc() in
> shrink_node_memcg().
> 
> Resetting tlb_ubc.flush_required at that point is wrong: if the upper
> level needs a deferred TLB flush, but the lower level turns out not to,
> we miss a TLB flush.  But fortunately, that's the only part of the
> protocol that does not nest: with the initialization removed, cpumask 
> collects bits from upper and lower levels, and flushes TLB when needed.
> 
> Fixes: 72b252aed506 ("mm: send one IPI per CPU to TLB flush all entries after unmapping pages")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org # 4.3+

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
