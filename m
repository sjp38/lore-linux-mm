Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 32F6F6B0039
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 13:16:27 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so1208960pbc.36
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 10:16:26 -0700 (PDT)
Received: by mail-ob0-f177.google.com with SMTP id wm4so831569obc.22
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 10:16:24 -0700 (PDT)
Date: Wed, 9 Oct 2013 12:16:17 -0500
From: Seth Jennings <spartacus06@gmail.com>
Subject: Re: [PATCH v3 5/6] zswap: replace tree in zswap with radix tree in
 zbud
Message-ID: <20131009171617.GA21057@variantweb.net>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
 <1381238980-2491-6-git-send-email-k.kozlowski@samsung.com>
 <20131009153022.GB5406@variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131009153022.GB5406@variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Wed, Oct 09, 2013 at 10:30:22AM -0500, Seth Jennings wrote:
> In my approach, I was also looking at allowing the zbud pools to use
> HIGHMEM pages, since the handle is no longer an address.  This requires
> the pages that are being mapped to be kmapped (atomic) which will
> disable preemption.  This isn't an additional overhead since the
> map/unmap corresponds with a compress/decompress operation at the zswap
> level which uses per-cpu variables that disable preemption already.

On second though, lets not mess with the HIGHMEM page support for now.
Turns out it is tricker than I thought since the unbuddied lists are
linked through the zbud header stored in the page.  But we can still
disable preemption to allow per-cpu tracking of the current mapping and
avoid a lookup (and races) in zbud_unmap().

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
