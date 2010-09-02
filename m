Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5FA6D6B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 05:56:32 -0400 (EDT)
Received: by iwn33 with SMTP id 33so486169iwn.14
        for <linux-mm@kvack.org>; Thu, 02 Sep 2010 02:56:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100901103653.974C.A69D9226@jp.fujitsu.com>
References: <20100901103653.974C.A69D9226@jp.fujitsu.com>
Date: Thu, 2 Sep 2010 18:56:30 +0900
Message-ID: <AANLkTikKYFkvtAktnwzrmGPf7RNVdakWn0UbcJnc5w_a@mail.gmail.com>
Subject: Re: [PATCH] vmscan,tmpfs: treat used once pages on tmpfs as used once
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi KOSAKI,

On Wed, Sep 1, 2010 at 10:37 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> When a page has PG_referenced, shrink_page_list() discard it only
> if it is no dirty. This rule works completely fine if the backend
> filesystem is regular one. PG_dirty is good signal that it was used
> recently because flusher thread clean pages periodically. In addition,
> page writeback is costly rather than simple page discard.
>
> However, When a page is on tmpfs, this heuristic don't works because
> flusher thread don't writeback tmpfs pages. then, tmpfs pages always
> rotate lru twice at least and it makes unnecessary lru churn. Merely
> tmpfs streaming io shouldn't cause large anonymous page swap-out.

It seem to make sense.
But the why admin use tmps is to keep the contents in memory as far as
possible than other's file system.
But this patch has a possibility for tmpfs pages to reclaim early than
old behavior.

I admit this routine's goal is not to protect tmpfs page from too early reclaim.
But at least, it would have affected until now.
If it is, we might need other demotion prevent mechanism to protect tmpfs pages.
Is split LRU enough? (I mean we consider tmpfs pages as anonymous
which is hard to reclaim than file backed pages).

I don't mean to oppose this patch and I don't have a any number to
insist on my opinion.
Just what I want is that let's think about it more carefully and
listen other's opinions. :)

Thanks for good suggestion.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
