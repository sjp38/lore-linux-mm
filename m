Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 497226B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 18:12:10 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id uo5so3270669pbc.24
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 15:12:09 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id wm7si6322178pab.202.2014.03.06.15.12.08
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 15:12:09 -0800 (PST)
Date: Thu, 6 Mar 2014 15:12:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [merged]
 mm-page_alloc-reset-aging-cycle-with-gfp_thisnode-v2.patch removed from -mm
 tree
Message-Id: <20140306151206.6228ae8933af538048aa056c@linux-foundation.org>
In-Reply-To: <20140306230404.GY6963@cmpxchg.org>
References: <5318dca5.AwhU/92X21JgbpdE%akpm@linux-foundation.org>
	<20140306214927.GB11171@cmpxchg.org>
	<20140306135635.6999d703429afb7fd3949304@linux-foundation.org>
	<20140306230404.GY6963@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: stable@kernel.org, riel@redhat.com, mgorman@suse.de, jstancek@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 6 Mar 2014 18:04:04 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> > what bug does it fix and what are the user-visible effects??
> 
> Ok, maybe this is better?
> 
> ---
> 
> GFP_THISNODE is for callers that implement their own clever fallback
> to remote nodes.  It restricts the allocation to the specified node
> and does not invoke reclaim, assuming that the caller will take care
> of it when the fallback fails, e.g. through a subsequent allocation
> request without GFP_THISNODE set.
> 
> However, many current GFP_THISNODE users only want the node exclusive
> aspect of the flag, without actually implementing their own fallback
> or triggering reclaim if necessary.  This results in things like page
> migration failing prematurely even when there is easily reclaimable
> memory available, unless kswapd happens to be running already or a
> concurrent allocation attempt triggers the necessary reclaim.
> 
> Convert all callsites that don't implement their own fallback strategy
> to __GFP_THISNODE.  This restricts the allocation a single node too,
> but at the same time allows the allocator to enter the slowpath, wake
> kswapd, and invoke direct reclaim if necessary, to make the allocation
> happen when memory is full.

Looks good, thanks.  I'll send this Linuswards next week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
