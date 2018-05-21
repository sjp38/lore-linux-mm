Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D812E6B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 05:05:52 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 72-v6so9757316pld.19
        for <linux-mm@kvack.org>; Mon, 21 May 2018 02:05:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e9-v6si13922224pli.576.2018.05.21.02.05.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 May 2018 02:05:51 -0700 (PDT)
Date: Mon, 21 May 2018 10:05:47 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: do we still need ->is_dirty_writeback
Message-ID: <20180521090547.shpifu2sivrishas@suse.de>
References: <20180518170812.GA5190@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180518170812.GA5190@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trondmy@hammerspace.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org

On Fri, May 18, 2018 at 07:08:12PM +0200, Christoph Hellwig wrote:
> Hi Mel,
> 
> you added the is_dirty_writeback callback a couple years ago mostly
> to work around the crazy ext3 writeback code, which is long gone now.
> We still use buffer_check_dirty_writeback on the block device, but
> without that ext3 case we really should not need it anymore.
> 
> That leaves NFS, where I don't understand why it doesn't simply
> use PageWrite?

If you mean PageWriteback the patch was to treat some pages as if they were
under writeback even if the page state didn't reflect that. The intent was
to catch the case when kswapd was scanning that it would not prematurely
skip over pages under writeback or were really dirty from being skipped and
clean pages being reclaimed instead. In an extreme case, it would avoid
a premature OOM if the number of clean pages that could be reclaimed was
too small. However, it was (is?) a corner case and the mechanisms that
control throttling have changed a lot since.

If the callback is problematic for some reason, I don't object to it
being removed. At worst, there will be rare cases where reclaim finds
clean pages and steals them prematurely. There are plenty of other cases
where page age inversion issues exist (e.g. NUMA machines that reclaim
young pages from local node when the working set is larger than a node)
and it's rare that people notice.

-- 
Mel Gorman
SUSE Labs
