Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 2A0016B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 19:40:17 -0500 (EST)
Date: Mon, 5 Nov 2012 16:40:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 23/29] memcg: destroy memcg caches
Message-Id: <20121105164015.4f82c958.akpm@linux-foundation.org>
In-Reply-To: <1351771665-11076-24-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<1351771665-11076-24-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Thu,  1 Nov 2012 16:07:39 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This patch implements destruction of memcg caches. Right now,
> only caches where our reference counter is the last remaining are
> deleted. If there are any other reference counters around, we just
> leave the caches lying around until they go away.
> 
> When that happen, a destruction function is called from the cache
> code. Caches are only destroyed in process context, so we queue them
> up for later processing in the general case.
> 
> ...
>
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -181,6 +181,7 @@ unsigned int kmem_cache_size(struct kmem_cache *);
>  #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
>  #endif
>  
> +#include <linux/workqueue.h>

Was there any reason for putting this include 185 lines into the file?

If not, then let's not do it.  It reduces readability and increases the
risk that someone will later include the saame file (or somthing it includes)
a second time, to satisfy some dependency at line 100.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
