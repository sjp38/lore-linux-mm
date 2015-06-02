Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8FB6B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 08:36:29 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so138985894wgb.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 05:36:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m5si24130883wiw.97.2015.06.02.05.36.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 05:36:27 -0700 (PDT)
Date: Tue, 2 Jun 2015 13:36:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/4] sunrpc: keep a count of swapfiles associated with
 the rpc_clnt
Message-ID: <20150602123623.GE26425@suse.de>
References: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
 <1432987393-15604-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1432987393-15604-2-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>

On Sat, May 30, 2015 at 08:03:10AM -0400, Jeff Layton wrote:
> Jerome reported seeing a warning pop when working with a swapfile on
> NFS. The nfs_swap_activate can end up calling sk_set_memalloc while
> holding the rcu_read_lock and that function can sleep.
> 
> To fix that, we need to take a reference to the xprt while holding the
> rcu_read_lock, set the socket up for swapping and then drop that
> reference. But, xprt_put is not exported and having NFS deal with the
> underlying xprt is a bit of layering violation anyway.
> 
> Fix this by adding a set of activate/deactivate functions that take a
> rpc_clnt pointer instead of an rpc_xprt, and have nfs_swap_activate and
> nfs_swap_deactivate call those.
> 
> Also, add a per-rpc_clnt atomic counter to keep track of the number of
> active swapfiles associated with it. When the counter does a 0->1
> transition, we enable swapping on the xprt, when we do a 1->0 transition
> we disable swapping on it.
> 
> This also allows us to be a bit more selective with the RPC_TASK_SWAPPER
> flag. If non-swapper and swapper clnts are sharing a xprt, then we only
> need to flag the tasks from the swapper clnt with that flag.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Reported-by: Jerome Marchand <jmarchan@redhat.com>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
