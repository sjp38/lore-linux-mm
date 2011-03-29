Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2D1A68D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 16:45:54 -0400 (EDT)
Date: Tue, 29 Mar 2011 22:45:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
Message-ID: <20110329204550.GN12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
 <4D91FC2D.4090602@redhat.com>
 <20110329190520.GJ12265@random.random>
 <BANLkTi=cysSDYUaRX3nXHgKmEB9acjCMsA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTi=cysSDYUaRX3nXHgKmEB9acjCMsA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Rik van Riel <riel@redhat.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Tue, Mar 29, 2011 at 01:35:24PM -0700, Ying Han wrote:
> In page reclaim, I would like to discuss on the magic "8" *
> high_wmark() in balance_pgdat(). I recently found the discussion on
> thread "too big min_free_kbytes", where I didn't find where we proved
> it is still a problem or not. This might not need reserve time slot,
> but something I want to learn more on.

That is merged in 2.6.39-rc1. It's hopefully working good enough. We
still use high+balance_gap but the balance_gap isn't high*8 anymore. I
still think the balance_gap may as well be zero but the gap now is
small enough (not 600M on 4G machine anymore) that it's ok and this
was a safer change.

This is an LRU ordering issue to try to keep the lru balance across
the zones and not just rotate a lot a single one. I think it can be
covered in the LRU ordering topic too. But we could also expand it to
a different slot if we expect too many issues to showup in that
slot... Hugh what's your opinion?

The subtopics that comes to mind for that topic so far would be:

- reclaim latency
- compaction issues (Mel)
- lru ordering altered by compaction/migrate/khugepaged or other
  features requiring lru page isolation (Minchan)
- lru rotation balance across zones in kswapd (balance_gap) (Ying)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
