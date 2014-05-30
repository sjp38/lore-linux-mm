Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 334626B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 03:46:55 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so1451772pbb.39
        for <linux-mm@kvack.org>; Fri, 30 May 2014 00:46:54 -0700 (PDT)
Received: from mail-pb0-x22d.google.com (mail-pb0-x22d.google.com [2607:f8b0:400e:c01::22d])
        by mx.google.com with ESMTPS id ce7si4380049pad.113.2014.05.30.00.46.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 00:46:54 -0700 (PDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so1441414pbc.18
        for <linux-mm@kvack.org>; Fri, 30 May 2014 00:46:53 -0700 (PDT)
Date: Fri, 30 May 2014 15:41:45 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH] swap: Avoid scanning invalidated region for cheap seek
Message-ID: <20140530074145.GA2688@kernel.org>
References: <1401069659-29589-1-git-send-email-slaoub@gmail.com>
 <alpine.LSU.2.11.1405272037080.1126@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1405272037080.1126@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Chen Yucong <slaoub@gmail.com>, akpm@linux-foundation.org, ddstreet@ieee.org, mgorman@suse.de, k.kozlowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 27, 2014 at 08:53:00PM -0700, Hugh Dickins wrote:
> On Mon, 26 May 2014, Chen Yucong wrote:
> 
> > For cheap seek, when we scan the region between si->lowset_bit
> > and scan_base, if san_base is greater than si->highest_bit, the
> > scan operation between si->highest_bit and scan_base is not
> > unnecessary.
> > 
> > This patch can be used to avoid scanning invalidated region for
> > cheap seek.
> > 
> > Signed-off-by: Chen Yucong <slaoub@gmail.com>
> 
> I was going to suggest that you are adding a little code to a common
> path, in order to optimize a very unlikely case: which does not seem
> worthwhile to me.
> 
> But digging a little deeper, I think you have hit upon something more
> interesting (though still in no need of your patch): it looks to me
> like that is not even a common path, but dead code.
> 
> Shaohua, am I missing something, or does all SWP_SOLIDSTATE "seek is
> cheap" now go your si->cluster_info scan_swap_map_try_ssd_cluster()
> route?  So that the "last_in_cluster < scan_base" loop in the body
> of scan_swap_map() is just redundant, and should have been deleted?

Sorry for the delay, you are right. SSD case always goes
scan_swap_map_try_ssd_cluster, otherwise we just scan from lowest_bit to
highest_bit, so the "last_in_cluster < scan_base" loop is dead.

Yucong, can you resent a patch to delete it as Hugh suggested?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
