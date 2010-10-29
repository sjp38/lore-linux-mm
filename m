Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AE90B6B0123
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 07:03:43 -0400 (EDT)
Date: Fri, 29 Oct 2010 19:03:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v4 02/11] memcg: document cgroup dirty memory interfaces
Message-ID: <20101029110331.GA29774@localhost>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
 <1288336154-23256-3-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1288336154-23256-3-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Hi Greg,

On Fri, Oct 29, 2010 at 03:09:05PM +0800, Greg Thelen wrote:

> Document cgroup dirty memory interfaces and statistics.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---

> +Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
> +page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
> +not be able to consume more than their designated share of dirty pages and will
> +be forced to perform write-out if they cross that limit.

It's more pertinent to say "will be throttled", as "perform write-out"
is some implementation behavior that will change soon. 

> +- memory.dirty_limit_in_bytes: the amount of dirty memory (expressed in bytes)
> +  in the cgroup at which a process generating dirty pages will start itself
> +  writing out dirty data.  Suffix (k, K, m, M, g, or G) can be used to indicate
> +  that value is kilo, mega or gigabytes.

The suffix feature is handy, thanks! It makes sense to also add this
for the global interfaces, perhaps in a standalone patch.

> +A cgroup may contain more dirty memory than its dirty limit.  This is possible
> +because of the principle that the first cgroup to touch a page is charged for
> +it.  Subsequent page counting events (dirty, writeback, nfs_unstable) are also
> +counted to the originally charged cgroup.
> +
> +Example: If page is allocated by a cgroup A task, then the page is charged to
> +cgroup A.  If the page is later dirtied by a task in cgroup B, then the cgroup A
> +dirty count will be incremented.  If cgroup A is over its dirty limit but cgroup
> +B is not, then dirtying a cgroup A page from a cgroup B task may push cgroup A
> +over its dirty limit without throttling the dirtying cgroup B task.

It's good to document the above "misbehavior". But why not throttling
the dirtying cgroup B task? Is it simply not implemented or makes no
sense to do so at all?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
