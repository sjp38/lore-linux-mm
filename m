Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 051C56B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 21:04:08 -0400 (EDT)
Date: Fri, 3 Sep 2010 17:02:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH v2] compaction: fix COMPACTPAGEFAILED counting
Message-Id: <20100903170227.b2f18ba4.akpm@linux-foundation.org>
In-Reply-To: <1283438087-11842-1-git-send-email-minchan.kim@gmail.com>
References: <1283438087-11842-1-git-send-email-minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu,  2 Sep 2010 23:34:47 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Now update_nr_listpages doesn't have a role. That's because
> lists passed is always empty just after calling migrate_pages.
> The migrate_pages cleans up page list which have failed to migrate
> before returning by aaa994b3.
> 
>  [PATCH] page migration: handle freeing of pages in migrate_pages()
> 
>  Do not leave pages on the lists passed to migrate_pages().  Seems that we will
>  not need any postprocessing of pages.  This will simplify the handling of
>  pages by the callers of migrate_pages().
> 
> At that time, we thought we don't need any postprocessing of pages.
> But the situation is changed. The compaction need to know the number of
> failed to migrate for COMPACTPAGEFAILED stat
> 
> This patch makes new rule for caller of migrate_pages to call putback_lru_pages.
> So caller need to clean up the lists so it has a chance to postprocess the pages.
> [suggested by Christoph Lameter]

I'm having trouble predicting what the user-visible effects of this bug
might be.  Just an inaccuracy in the COMPACTPAGEFAILED vm event?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
