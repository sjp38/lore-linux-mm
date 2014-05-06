Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF5D6B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 17:05:21 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id bs8so266585wib.6
        for <linux-mm@kvack.org>; Tue, 06 May 2014 14:05:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m3si6086533wje.91.2014.05.06.14.05.19
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 14:05:20 -0700 (PDT)
Message-ID: <53694E7D.6060706@redhat.com>
Date: Tue, 06 May 2014 17:05:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] nfsd: Only set PF_LESS_THROTTLE when really needed.
References: <20140423022441.4725.89693.stgit@notabene.brown> <20140423024058.4725.38098.stgit@notabene.brown>
In-Reply-To: <20140423024058.4725.38098.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Mel Gorman <mgorman@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On 04/22/2014 10:40 PM, NeilBrown wrote:
> PF_LESS_THROTTLE has a very specific use case: to avoid deadlocks
> and live-locks while writing to the page cache in a loop-back
> NFS mount situation.
> 
> It therefore makes sense to *only* set PF_LESS_THROTTLE in this
> situation.
> We now know when a request came from the local-host so it could be a
> loop-back mount.  We already know when we are handling write requests,
> and when we are doing anything else.
> 
> So combine those two to allow nfsd to still be throttled (like any
> other process) in every situation except when it is known to be
> problematic.

The FUSE code has something similar, but on the "client"
side.

See BDI_CAP_STRICTLIMIT in mm/writeback.c

Would it make sense to use that flag on loopback-mounted
NFS filesystems?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
