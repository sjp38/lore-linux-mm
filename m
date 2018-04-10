Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 647F46B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 22:41:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v191so6215358wmd.1
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 19:41:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k5si1130521wrh.458.2018.04.09.19.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 19:41:58 -0700 (PDT)
Date: Mon, 9 Apr 2018 19:41:52 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180410024152.GC31282@bombadil.infradead.org>
References: <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
 <20180409144958.GA211679@rodete-laptop-imager.corp.google.com>
 <20180409152032.GB11756@bombadil.infradead.org>
 <20180409230409.GA214542@rodete-desktop-imager.corp.google.com>
 <20180410011211.GA31282@bombadil.infradead.org>
 <20180410023339.GB214542@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410023339.GB214542@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Chao Yu <yuchao0@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Tue, Apr 10, 2018 at 11:33:39AM +0900, Minchan Kim wrote:
> @@ -522,7 +532,7 @@ EXPORT_SYMBOL(radix_tree_preload);
>   */
>  int radix_tree_maybe_preload(gfp_t gfp_mask)
>  {
> -	if (gfpflags_allow_blocking(gfp_mask))
> +	if (gfpflags_allow_blocking(gfp_mask) && !(gfp_mask & __GFP_ZERO))
>  		return __radix_tree_preload(gfp_mask, RADIX_TREE_PRELOAD_SIZE);
>  	/* Preloading doesn't help anything with this gfp mask, skip it */
>  	preempt_disable();

No, you've completely misunderstood what's going on in this function.
