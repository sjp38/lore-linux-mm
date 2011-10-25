Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D07576B0023
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 18:12:35 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p9PMCVQY021783
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 15:12:31 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by wpaz29.hot.corp.google.com with ESMTP id p9PMBDkm030449
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 15:12:29 -0700
Received: by pzk1 with SMTP id 1so3705792pzk.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 15:12:29 -0700 (PDT)
Date: Tue, 25 Oct 2011 15:12:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <CAMbhsRQs+P9djqW_62ajfZTHE3yxsOs0agek81aZrBzZ2-5-Fg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1110251510240.26017@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com> <CAOJsxLGuHZG9pvx5bCp9tOLA40uDz+U_ZY=_xOddtR9423-Jww@mail.gmail.com> <CAMbhsRQs+P9djqW_62ajfZTHE3yxsOs0agek81aZrBzZ2-5-Fg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, 25 Oct 2011, Colin Cross wrote:

> GFP_KERNEL is __GFP_WAIT | __GFP_IO | __GFP_FS.  Once driver suspend
> has started, gfp_allowed_mask is ~(__GFP_IO | GFP_FS), so any call to
> __alloc_pages_nodemask(GFP_KERNEL, ...) gets masked to effectively
> __alloc_pages_nodemask(__GFP_WAIT, ...).
> 

Just passing __GFP_WAIT is the problem that you're trying to address, 
though.  Why not include __GFP_NORETRY since you know the liklihood of 
allocation being successful on the second iteration is very slim since 
you're not in a context where you can force reclaim or oom killing?

> The loop is in __alloc_pages_slowpath, from the rebalance label to
> should_alloc_retry.

The loop is by design and is activated because you're just passing 
__GFP_WAIT in this context for no sensible reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
