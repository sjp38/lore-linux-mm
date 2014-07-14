Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4046B0039
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 15:56:39 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so2132618igb.14
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 12:56:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wo18si20785585icb.48.2014.07.14.12.56.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jul 2014 12:56:38 -0700 (PDT)
Date: Mon, 14 Jul 2014 12:56:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/3] mm: vmscan: clean up struct scan_control
Message-Id: <20140714125636.45e6a186a428499b5bd00726@linux-foundation.org>
In-Reply-To: <1405344049-19868-4-git-send-email-hannes@cmpxchg.org>
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
	<1405344049-19868-4-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Jul 2014 09:20:49 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Reorder the members by input and output, then turn the individual
> integers for may_writepage, may_unmap, may_swap, compaction_ready,
> hibernation_mode into flags that fit into a single integer.

bitfields would be a pretty good fit here.  I usually don't like them
because of locking concerns with the RMWs, but scan_control is never
accessed from another thread.

> -		if (!sc->may_unmap && page_mapped(page))
> +		if (!(sc->flags & MAY_UNMAP) && page_mapped(page))

Then edits such as this are unneeded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
