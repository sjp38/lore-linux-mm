Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DA43A6B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 22:58:55 -0500 (EST)
Date: Fri, 19 Feb 2010 04:58:54 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/1] mm: invalidate_mapping_pages checks boundaries when lock fails
Message-ID: <20100219035854.GA11856@cmpxchg.org>
References: <1266542537-5040-1-git-send-email-yehuda@hq.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1266542537-5040-1-git-send-email-yehuda@hq.newdream.net>
Sender: owner-linux-mm@kvack.org
To: Yehuda Sadeh <yehuda@hq.newdream.net>
Cc: linux-mm@kvack.org, linux-btrfs@vger.kernel.org, sage@newdream.net
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Feb 18, 2010 at 05:22:17PM -0800, Yehuda Sadeh wrote:
> Not sure that I'm not missing something obvious. When invalidate_mapping_pages
> fails to lock the page, we continue to the next iteration, skipping the
> next > end check. This can lead to a case where we invalidate a page that is
> beyond the requested boundaries. Currently there are two callers that might be
> affected, one is btrfs and the second one is the fadvice syscall.
> Does that look right, or am I just missing something?

This can already happen with the first page being at an index above end
as the check only happens after we invalidated the page.

The damage is losing one cache-only (clean, unmapped) page.  It is a bit
ugly but not a huge problem I suppose.

How about checking page->index against end, like in the truncation case,
before the invalidation?  That should take care of both cases.

We already rely on a page->index when the page is pinned but locked by
somebody else.  And I think that's fine.

Can we not just make that the default?  That could simplify the inner
loop to something like

	index = page->index;
	if (index > end)
		break;
	next = max(index, next) + 1;
	if (!trylock_page(page))
		continue;
	ret += invalidate_inode_page(page);
	unlock_page(page);

or something.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
