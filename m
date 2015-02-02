Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 835176B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 17:05:08 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so87609635pac.13
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 14:05:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b11si99257pdm.95.2015.02.02.14.05.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Feb 2015 14:05:07 -0800 (PST)
Date: Mon, 2 Feb 2015 14:05:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm: madvise: Ignore repeated MADV_DONTNEED hints
Message-Id: <20150202140506.392ff6920743f19ea44cff59@linux-foundation.org>
In-Reply-To: <20150202165525.GM2395@suse.de>
References: <20150202165525.GM2395@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On Mon, 2 Feb 2015 16:55:25 +0000 Mel Gorman <mgorman@suse.de> wrote:

> glibc malloc changed behaviour in glibc 2.10 to have per-thread arenas
> instead of creating new areans if the existing ones were contended.
> The decision appears to have been made so the allocator scales better but the
> downside is that madvise(MADV_DONTNEED) is now called for these per-thread
> areans during free. This tears down pages that would have previously
> remained. There is nothing wrong with this decision from a functional point
> of view but any threaded application that frequently allocates/frees the
> same-sized region is going to incur the full teardown and refault costs.

MADV_DONTNEED has been there for many years.  How could this problem
not have been noticed during glibc 2.10 development/testing?  Is there
some more recent kernel change which is triggering this?

> This patch identifies when a thread is frequently calling MADV_DONTNEED
> on the same region of memory and starts ignoring the hint.

That's pretty nasty-looking :(

And presumably there are all sorts of behaviours which will still
trigger the problem but which will avoid the start/end equality test in
ignore_madvise_hint()?

Really, this is a glibc problem and only a glibc problem. 
MADV_DONTNEED is unavoidably expensive and glibc is calling
MADV_DONTNEED for a region which it *does* need.  Is there something
preventing this from being addressed within glibc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
