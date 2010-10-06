Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A3CF26B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 17:36:53 -0400 (EDT)
Date: Wed, 6 Oct 2010 16:26:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] HWPOISON: Attempt directed shrinking of slabs
In-Reply-To: <1286398930-11956-3-git-send-email-andi@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1010061618470.8083@router.home>
References: <1286398930-11956-1-git-send-email-andi@firstfloor.org> <1286398930-11956-3-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, mpm@selenic.com, Andi Kleen <ak@linux.intel.com>, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010, Andi Kleen wrote:

> When a slab page is found try to shrink the specific slab first
> before trying to shrink all slabs and call other shrinkers.
> This can be done now using the new kmem_page_cache() call.

What you really would need here is targeted reclaim or the ability to move
objects into other slabs. The likelyhood of the shaking having any effect
is quite low.

The calling of the shrinkers is much more effective but it only works for
certain slabs. This is a broad shot against all slabs. It would be best to
call the fs shrinkers before kmem_cache_shrink(). You have to call
kmem_cache_shrink afterwards anyways because the slabs may keep recently
emptied slab pages around. The fs shrinkers may have evicted the objects
but the empty slab page is still around.

Maybe the best idea is to first call drop_slab() instead (evicts all possible fs
objects) and then call kmem_cache_shrink().




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
